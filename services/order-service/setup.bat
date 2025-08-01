@echo off
echo Setting up Order Service...

REM Build the service
echo Building Order Service...
call mvn clean package -DskipTests

REM Run the service
echo Starting Order Service...
java -jar target\order-service-1.0.0.jar

echo Order Service is running on http://localhost:8083
pause