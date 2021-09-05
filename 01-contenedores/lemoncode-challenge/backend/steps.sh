#Crear el MongoDB ya en Docker
docker run -d --name some-mongo -p 27017:27017 mongo

#Ejecutar la API con la variable de entorno MONGO_URI
MONGO_URI="mongodb://localhost:27017" dotnet run