# Tazama Rule Studio (TRS) - Deployment Guide

## Part 1 – Setting up:

1.  Clone the repository: git clone https://github.com/tazama-lf/rule-studio.git

2.  cd backend & cd frontend

3.  Add GH_TOKEN to the backend .npmrc

## Part 2 - Running TRS through Docker Compose:

1. While being in the backend directory, create .env file through editing the .env.example file by renaming to .env or use command:

mv .env.example .env

Add TAZAMA_AUTH_URL, ADMIN_SERVICE_URL and OPENSEARCH envs.

Frontend:

mv .env.template .env

```env
VITE_API_BASE_URL=http://localhost:3005
```

```env
VITE_SANDBOX_API_URL=simulation-sandbox-url
```

```env
VITE_NATS_API_URL=nats-utilities-url
```

```env
VITE_SIMULATION_ENDPOINT=tms-url
```

2. Run the docker-compose.yaml to run TRS backend and Frontend along with Database, Valkey and NATS.

docker compose up -d

## Part 3 - Running with Full Stack Docker Tazama:

1. Use Full Stack Docker Tazama environment variables in the .env file of the trs service.

```env
ADMIN_SERVICE_URL=http://tazama-admin-service-1:3100
```

```env
TAZAMA_AUTH_URL=http://tazama-auth-1:3020/v1/auth
```

For Backend run:

cd /backend

docker build -t trs-backend:latest .

docker run -d -p 3005:3005 --env-file /backend/.env --name trs-backend --network tazama_default trs-backend:latest

For Frontend run:

cd /frontend

docker build -t trs-frontend:latest .

docker run -d -p 5174:5174 --env-file /frontend/.env --name trs-frontend --network tazama_default trs-frontend:latest

Debug Commands

docker logs -f trs-backend
