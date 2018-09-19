#!/bin/bash

docker network create $PROJECT_NAME
docker run --rm --network=$PROJECT_NAME --name=$PROJECT_NAME-redis -d redis
docker run --rm --network=$PROJECT_NAME --name=$PROJECT_NAME-postgres -e POSTGRES_PASSWORD=password -d postgres
sleep 2

docker build \
    --network $PROJECT_NAME \
    --build-arg SIDEKIQ_CREDS=$SIDEKIQ_CREDS \
    --build-arg DB_ENV_POSTGRESQL_PASS=password \
    --build-arg DB_ENV_POSTGRESQL_USER=postgres \
    --build-arg DB_PORT_5432_TCP_ADDR=$PROJECT_NAME-postgres \
    --build-arg REDIS_PORT_6379_TCP_ADDR=$PROJECT_NAME-redis \
    -t 056154071827.dkr.ecr.us-east-1.amazonaws.com/$PROJECT_NAME:$ENVIRONMENT-$BUILD_NUMBER .

docker stop $PROJECT_NAME-redis $PROJECT_NAME-postgres && docker rm $PROJECT_NAME-redis $PROJECT_NAME-postgres
docker network rm $PROJECT_NAME
