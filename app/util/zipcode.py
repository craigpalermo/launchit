from math import sin, cos, sqrt, atan2, radians
from django.db import connection
from django.utils import simplejson
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User
from app.models.user_profile import UserProfile
from app import api
from JSONResponse import JSONResponse
import json
import math
import operator
import traceback

# define success/error constants
SUCCESS = 'success'
ERROR = 'error'

@csrf_exempt
def users_in_range(request):
    # get zipcodes in range
    range = 10
    data = json.loads(request.body)
    zipcode = data['zipcode']

    if not zipcode:
        # missing zipcode or other input, return nothing
		data = {'status': ERROR, 'message': 'Missing zipcode.'}
		response = JSONResponse(data)
		response.status_code = 409
		return response
    
    try:
        zips = get_zips_in_range(zipcode, range)
    except:
        data = {'status': ERROR, 'message': traceback.format_exc()}
        response = JSONResponse(data)
        response.status_code = 409
        return response

    # extract just the zipcode from query results
    zip_distances = {}
    for zip in zips:
        zip_distances[zip[0]] = zip[4] # store zip code w/ distance from current

    # get users in those zipcodes
    users_in_range = UserProfile.objects.filter(zipcode__in=zip_distances.keys()).exclude(user__username=request.user.username)
    results = []

    for profile in users_in_range:
        serializer = api.user.UserSerializer(profile.user)
        serializer.data['distance'] = zip_distances[profile.zipcode]
        results.append(serializer.data)

	data = {'status': SUCCESS, 'message': 'Successfully retrieved users in range.', 'data': results}
    return JSONResponse(data)
    
@csrf_exempt
def zips_view(request):
    '''
    returns json containing all zipcodes within range of the given zipcode
    '''
    data = json.loads(request.body)
    result = get_zips_in_range(data['zipcode'], data['range'])
    return JSONResponse(result)

def calculate_milage(lat1, long1, lat2, long2):
    # Convert latitude and longitude to 
    # spherical coordinates in radians.
    degrees_to_radians = math.pi/180.0
        
    # phi = 90 - latitude
    phi1 = (90.0 - lat1)*degrees_to_radians
    phi2 = (90.0 - lat2)*degrees_to_radians
            
    # theta = longitude
    theta1 = long1*degrees_to_radians
    theta2 = long2*degrees_to_radians
                
    # Compute spherical distance from spherical coordinates.
                    
    # For two locations in spherical coordinates 
    # (1, theta, phi) and (1, theta, phi)
    # cosine( arc length ) = 
    #    sin phi sin phi' cos(theta-theta') + cos phi cos phi'
    # distance = rho * arc length

    cos = (math.sin(phi1)*math.sin(phi2)*math.cos(theta1 - theta2) + 
                   math.cos(phi1)*math.cos(phi2))
    arc = math.acos( cos )

    # Remember to multiply arc by the radius of the earth 
    # in your favorite set of units to get length.
    return arc * 3960

def get_zip_point(zip):
    '''
    retrieves only latitude and longitude for zip
    '''
    cursor = connection.cursor()
    sql = "SELECT lat, lon from zip_code WHERE zip_code=%s"
    cursor.execute(sql, [zip])
    return cursor.fetchone()

def get_zips_in_range(zip, range):
    # get lat and lon for zip
    range = float(range)
    details = get_zip_point(zip)
    base_lat = float(details[0])
    base_lon = float(details[1])
    
    # calculate max and min longitudes within range of zip to
    # reduce query size
    lat_range = range / 69.172
    lon_range = abs(range/(cos(base_lat) * 69.172))
    min_lat = base_lat - lat_range
    max_lat = base_lat + lat_range
    min_lon = base_lon - lon_range
    max_lon = base_lon + lon_range

    # build and execute query
    cursor = connection.cursor()
    sql = "SELECT zip_code, city, lat, lon FROM zip_code WHERE lat BETWEEN %s AND %s AND lon BETWEEN %s AND %s"
    r = cursor.execute(sql, [min_lat, max_lat, min_lon, max_lon])
    
    # limit results to only zipcodes in range
    results = []
    for row in r.fetchall():
        dist = calculate_milage(base_lat, base_lon, row[2], row[3])
        if (dist <= range):
            results.append(row + (dist,))

    # sort results by distance in ascending order
    results.sort(key=operator.itemgetter(4)) 

    return results
