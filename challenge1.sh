#Create docker network (optiona)
docker network create --driver bridge ohnw 
docker network inspect ohnw 

#Run sql container 
docker run --network=ohnw -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=rX29i9Ul2" -p 1433:1433 --name sql1 -d mcr.microsoft.com/mssql/server:2017-latest  
 
#create the database
docker exec sql1 ./opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "rX29i9Ul2" -Q "CREATE DATABASE mydrivingDB" 
 
#Run the data ingestion container
docker run --network=ohnw -e SQLFQDN=sql1 -e SQLUSER=sa -e SQLPASS=rX29i9Ul2 -e SQLDB=mydrivingDB openhack/data-load:v1 
 
#Build poi app
docker build --no-cache --build-arg IMAGE_VERSION="1.0" --build-arg IMAGE_CREATE_DATE="$(Get-Date((Get-Date).ToUniversalTime()) -UFormat '%Y-%m-%dT%H:%M:%SZ')" --build-arg IMAGE_SOURCE_REVISION="$(git rev-parse HEAD)" -f Dockerfile -t "tripinsights/poi:1.0" . 
 
#run poi app 
docker run --network=ohnw -d -p 8080:80 --name poi -e "SQL_USER=sa" -e "SQL_PASSWORD=rX29i9Ul2" -e "SQL_SERVER=sql1" -e "ASPNETCORE_ENVIRONMENT=Local" tripinsights/poi:1.0 
 
#push container to acr
az acr login --name registryzwl7908 
docker tag  tripinsights/poi:1.0 registryzwl7908.azurecr.io/tripinsights/poi:1.0jd  
docker push registryzwl7908.azurecr.io/tripinsights/poi:1.0 

 
#Prepare for the next lab 
az acr build -t tripinsights/poi:1.0 --registry registryzwl7908 .
az acr build -t tripinsights/trips:1.0 --registry registryzwl7908 .
az acr build -t tripinsights/tripviewer:1.0 --registry registryzwl7908 .
az acr build -t tripinsights/user-java:1.0 --registry registryzwl7908 . 
az acr build -t tripinsights/userprofile:1.0 --registry registryzwl7908 .
