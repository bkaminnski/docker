docker rmi bkaminnski/spring-boot-service
docker build -t bkaminnski/spring-boot-service .
docker run -it --rm --env "WAIT_FOR=urls-database;8333;READY" bkaminnski/spring-boot-service /bin/bash