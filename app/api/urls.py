from django.conf.urls import patterns, url, include
from django.http import HttpResponse
from django.db import connection
from rest_framework.urlpatterns import format_suffix_patterns
from app.api.user import UserList, UserDetail, GroupList, GroupDetail
from app.util.JSONResponse import JSONResponse
from app.models.interest import Interest
from app.models.user_profile import UserProfile
from app.settings import base as settings
from app.api import user

import traceback, sys, json

# define result constants
SUCCESS = 'success'
ERROR = 'error'

def add_interest(request):
    '''
    Add a new interest to the user's list of interests. If the interest
    doesn't already exist, first add a new interest object to the database.
    '''
    data = json.loads(request.body)

    try:
        interest, created = Interest.objects.get_or_create(name=data['interest'].lower())
        profile = UserProfile.objects.get(user=request.user)
        profile.interests.add(interest)
        profile.save()
        data = { 'result': SUCCESS,
                 'message': ''}
        response = JSONResponse(data)
    except:
        data = { 'result': ERROR,
                 'message': 'There was a problem adding an interest to your profile.'}
        response = JSONResponse(data)
        response.status_code = 409

    return response


def remove_interest(request):
    '''
    Remove an interest from the user's list of interests.
    '''
    data = json.loads(request.body)

    try:
        interest = Interest.objects.get(name=data['interest'].lower())
        profile = UserProfile.objects.get(user=request.user)
        profile.interests.remove(interest)
        profile.save()
        data = { 'result': SUCCESS,
                 'message': '' }
        response = JSONResponse(data)
    except:
        data = { 'result': ERROR,
                 'message': 'There was an error removing an interest from your profile.' }
        response = JSONResponse(data)
        response.status_code = 409

    return response


def fetch_interests(request):
    '''
    Returns a list of all interests currently in the database
    '''
    try:
        cursor = connection.cursor()
        sql = "SELECT name FROM app_interest ORDER BY name"
        cursor.execute(sql, [])
        interests = [item[0] for item in cursor.fetchall()]
        data = { 'result': SUCCESS,
                 'message': '',
                 'data': interests }
        response = JSONResponse(data)
    except:
        data = { 'result': ERROR,
                 'message': 'There was an error retrieving interests from the sever.' }
        response = JSONResponse(data)
        response.status_code = 500

    return response


def update_avatar(request):
    '''
    Update the user's profile picture
    '''
    try:
        if request.method == 'POST':
            profile = UserProfile.objects.get(user=request.user)
            profile.avatar = request.FILES['file']
            profile.save()

            serializer = user.UserSerializer(request.user)
            data = {'result': SUCCESS,
                    'message': '',
                    'user': serializer.data }
            response = JSONResponse(data)
        else:
            raise
    except:
        data = {'result': ERROR,
                'message': 'There was an error processing your request.'}
        response = JSONResponse(data)
        response.status_code = 500

    return response

urlpatterns = patterns('',
    url(r'^/users/?$', UserList.as_view(), name='user-list'),
    url(r'^/users/(?P<pk>\d+)/?$', UserDetail.as_view(), name='user-detail'),
    url(r'^/groups/?$', GroupList.as_view(), name='group-list'),
    url(r'^/groups/(?P<pk>\d+)/?$', GroupDetail.as_view(), name='group-detail'),
)

# Format suffixes
urlpatterns = format_suffix_patterns(urlpatterns, allowed=['json', 'api'])

# API urls
urlpatterns += patterns('',
    url(r'^/api-auth/', include('rest_framework.urls', namespace='rest_framework')),
    url(r'^/add_interest/', add_interest),
    url(r'^/remove_interest/', remove_interest),
    url(r'^/change_avatar/', update_avatar),
    url(r'^/fetch_interests/', fetch_interests)
)

