# Data Enrichment Service - Deployment Guide

## Part 1 – Setting up:

1.  Clone the repository: git clone https://github.com/tazama-lf/data-enrichment-service

2.  Add GH_TOKEN in .npmrc

3.  Set up Database, Redis and NATS through compose file:

docker compose up -d

4. Build the docker image:
   docker build -t data-enrichment-service:latest .

## Part 2 - Running Data Enrichment Service:

1. Create .env file through editing the .env.template file by renaming or use command:
   mv .env.template .env

2. Confirm the use of localhost for all the required microservices to run data enrichment service.

```env
CONFIGURATION_DATABASE_URL=postgresql://postgres:postgres@localhost:5432/enrichment
```

```env
REDIS_HOST=localhost
```

```env
SERVER_URL=nats://localhost:4222
```

3. Run the service through docker container by using the command through terminal:

- docker run -d -p 3001:3001 --name tazama-deapi –-env-file .env data-enrichment-service:latest

## Part 3 - Running with Full Stack Docker Tazama:

1. Use Full Stack Docker Tazama environment variables in the .env file of the data enrichment service.

```env
CONFIGURATION_DATABASE_URL=postgresql://postgres:unused@tazama-postgres-1:5432/enrichment
```

```env
REDIS_HOST=tazama-valkey-1
```

```env
SERVER_URL=nats://tazama-nats-1:4222
```

```env
AUTH_URL=tazama-auth-1
```

2. Run docker images through command and network:
   docker run -d -p 3001:3001 --name tazama-deapi --env-file .env --network tazama_default data-enrichment-service:latest

Debug Commands

docker logs -f data-enrichment-service
