from django.db import models
 # Postgres only

class Event(models.Model):
    event_type = models.CharField(max_length=10)  # 'sms' or 'call'
    payload = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.event_type} - {self.timestamp}"
