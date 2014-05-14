from math import sin, cos, sqrt, atan2, radians
from django.db import connection
from django.utils import simplejson
from django.views.decorators.csrf import csrf_exempt
from rest_framework.renderers import JSONRenderer
from django.http import HttpResponse
import json

class JSONResponse(HttpResponse):
    """
    An HttpResponse that renders it's content into JSON.
    """
    def __init__(self, data, **kwargs):
        content = JSONRenderer().render(data)
        kwargs['content_type'] = 'application/json'
        super(JSONResponse, self).__init__(content, **kwargs)

@csrf_exempt
def zips_view(request):
   data = json.loads(request.body)
   result = get_zips_in_range(data['zipcode'], data['range'])
   print result
   return JSONResponse(result)


def calculate_milage(lat1, lon1, lat2, lon2):
    R = 6373.0
    miles_per_kil = 0.621371

    # convert coords from degrees to radians
    lat1 = radians(lat1)
    lon1 = radians(lon1)
    lat2 = radians(lat2)
    lon2 = radians(lon2)

    # calculate distance
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = (sin(dlat/2))**2 + cos(lat1) * cos(lat2) * (sin(dlon/2))**2
    c = 2 * atan2(sqrt(a), sqrt(1-a))
    distance = R * c

    # convert dist from kil to miles
    return distance * miles_per_kil

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
    return cursor.execute(sql, [min_lat, max_lat, min_lon, max_lon])
