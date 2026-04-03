# Dynamic Event Monitoring Service - Deployment Guide

Dynamic Event Monitoring Service - Deployment Guide


## Part 1 – Setting up:


1.  Clone the repository: git clone https://github.com/tazama-lf/event-monitoring-service.git

2. Add GH_TOKEN in .npmrc

3. Build the docker image:

docker build -t tazama-dems:latest


## Part 2 - Running DEMS:


1. Create .env file through editing the .env.template file by renaming or use command: 
mv .env.template .env

2. Confirm the use of localhost for all the required microservices to run dynamic event monitoring service.

```env
CONFIGURATION_DATABASE_URL=postgresql://postgres:postgres@localhost:5432/configuration
```

```env
REDIS_HOST=localhost
```

```env
SERVER_URL=nats://localhost:4222
```

3. Run the service through docker container by using the command through terminal: 
- docker run -d -p 3002:3002 –-name tazama-dems –-env-file .env tazama-dems:latest


## Part 3 - Running with Full Stack Docker Tazama:


1. Use Full Stack Docker Tazama environment variables in the .env file of the dynamic event monitoring service.

```env
CONFIGURATION_DATABASE_URL=postgresql://postgres:unused@tazama-postgres-1:5432/encrichment
```

```env
REDIS_HOST=tazama-valkey-1
```

```env
SERVER_URL=nats://tazama-nats-1:4222
```

2. Run docker images through command and network: 
docker run -d -p 3002:3002 --name tazama-dems --env-file .env --network tazama_default tazama-dems:latest

Debug Commands

docker logs -f tazama-dems