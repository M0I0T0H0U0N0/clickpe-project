from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Drink
from .serializer import DrinkSerializer

@api_view(['GET', 'POST'])
def drink_list(request):
    if request.method == 'GET':
        drinks = Drink.objects.all()
        print(drinks)
        serializer = DrinkSerializer(drinks, many=True)
        return Response({'drinks': serializer.data}, status=status.HTTP_200_OK)

    if request.method == 'POST':
        print("Incoming data:", request.data)
        email = request.data.get('mail')  # Get email
        password = request.data.get('password')
        print(email, password)
        drinks = Drink.objects.all()
       
        serializer = DrinkSerializer(drinks, many=True)
        print(serializer.data)



        serializer = DrinkSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({'drinking': serializer.data}, status=status.HTTP_201_CREATED)
        else:
            print("Serializer errors:", serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
