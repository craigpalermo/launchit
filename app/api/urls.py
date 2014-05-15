from django.conf.urls import patterns, url, include
from rest_framework.urlpatterns import format_suffix_patterns
from app.api.user import UserList, UserDetail, GroupList, GroupDetail
from app.util.JSONResponse import JSONResponse
from app.models.interest import Interest
from app.models.user_profile import UserProfile
import json

def add_interest(request):
    data = json.loads(request.body)
    interest, created = Interest.objects.get_or_create(name=data['interest'].lower())
    profile = UserProfile.objects.get(user=request.user)
    profile.interests.add(interest)
    profile.save()
    data = {
            'result': 'success',
            'message': ''
            }
    return JSONResponse(json.dumps(data))

urlpatterns = patterns('',
    url(r'^/users/?$', UserList.as_view(), name='user-list'),
    url(r'^/users/(?P<pk>\d+)/?$', UserDetail.as_view(), name='user-detail'),
    url(r'^/groups/?$', GroupList.as_view(), name='group-list'),
    url(r'^/groups/(?P<pk>\d+)/?$', GroupDetail.as_view(), name='group-detail'),
)

# Format suffixes
urlpatterns = format_suffix_patterns(urlpatterns, allowed=['json', 'api'])

# Default login/logout views
urlpatterns += patterns('',
    url(r'^/api-auth/', include(
        'rest_framework.urls', namespace='rest_framework')),
    url(r'^/add_interest/', add_interest)
)
