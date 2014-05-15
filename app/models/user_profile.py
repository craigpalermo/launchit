from app.models import Model
from django.db import models
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token
from interest import Interest

class UserProfile(Model):
    user = models.ForeignKey(User, unique=True)
    zipcode = models.CharField(max_length=5)
    confirmed_email = models.BooleanField(default=False)
    interests = models.ManyToManyField(Interest)

    def __unicode__(self):
        return self.user.username

# Create an easy way to use the user profile
# using user.profile will get or create a user profile
# object
User.profile = property(lambda u: UserProfile.objects.get_or_create(user=u)[0])
User.api_key = property(lambda u: Token.objects.get_or_create(user=u)[0].key)
