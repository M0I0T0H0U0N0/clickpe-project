from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Event
from .serializer import EventSerializer

@api_view(['GET', 'POST'])
def event_list(request):
    if request.method == 'GET':
        events = Event.objects.all().order_by('-timestamp')
        serializer = EventSerializer(events, many=True)
        return Response({'events': serializer.data}, status=status.HTTP_200_OK)

    elif request.method == 'POST':
        incoming = request.data
        print("Incoming data: - views.py:16", incoming)

        # Support batch or single event
        if isinstance(incoming, list):
            serializer = EventSerializer(data=incoming, many=True)
        else:
            serializer = EventSerializer(data=incoming)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            print("Serializer errors: - views.py:28", serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
