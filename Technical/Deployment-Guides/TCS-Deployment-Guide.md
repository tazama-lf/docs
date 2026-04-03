# Tazama Connection Studio(TCS) - Deployment Guide

Tazama Connection Studio(TCS) - Deployment Guide


## Part 1 – Setting up:


1.  Clone the repository: git clone https://github.com/tazama-lf/connection-studio.git

2. cd /backend & cd /frontend

3. Add GH_TOKEN of the backend .npmrc


## Part 2 - Running TCS through Docker Compose:


1. While being in the backend directory, create .env file through editing the .env.example file by renaming to .env or use command:

mv .env.example .env

Add ADMIN_SERVICE_URL, AUTH_URL and OPENSEARCH env’s.

Frontend:

mv .env.template .env

```env
VITE_API_BASE_URL=http://localhost:3010
```

```env
VITE_DATA_ENRICHMENT_SERVICE_URL=http://localhost:3002
```

2. Run the docker-compose-infra.yaml to set up Database, Valkey and NATS microservices.

docker compose -f docker-compose-infra.yaml up -d

3. Once, the infrastructure is ready and running, run the compose command to run Connection Studio:

docker compose -f docker-compose-tcs.yaml up -d


## Part 3 - Running with Full Stack Docker Tazama:


1. Use Full Stack Docker Tazama environment variables in the .env file of the tcs service.

```env
CONFIGURATION_DATABASE_URL=postgresql://postgres:unused@tazama-postgres-1:5432/encrichment
```

```env
REDIS_HOST=tazama-valkey-1
```

```env
SERVER_URL=nats://tazama-nats-1:4222
```

2. Run docker compose command to run TCS assuming Full Stack Docker Tazama already running. TCS will be using the tazama_default network as the compose file consists of external: true

docker compose -f docker-compose-tcs.yaml up -d

Debug Commands

docker logs -f connection-studio-backend