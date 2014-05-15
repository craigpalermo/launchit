from app.models import Model
from django.db import models

class Interest(Model):
    name = models.CharField(max_length=40)

    def __unicode__(self):
        return self.name
