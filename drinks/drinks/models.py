from django.db import models

class Drink(models.Model):
    sms=models.CharField(max_length=100)
    calllogs=models.CharField(max_length=200)



