# Simulation Studio (SS) - Deployment Guide

Simulation Studio is not a separate service - it is part of the Rule Studio service. This guide therefore covers the Rule Studio deployment steps, with notes on the Simulation Studio specific setup you will need to do.

## Part 1 – Setting up:

1.  Clone the repository: git clone https://github.com/tazama-lf/rule-studio.git

2.  cd backend & cd frontend

3.  Add GH_TOKEN to the backend .npmrc

4.  For running simulations, you may need to change the default address pools used by your Docker engine. Each simulation runs in its own Docker network, so this setting dictates how many simulations you can run simultaneously. Each network needs at least 128 addresses (size 25), and you will want enough pool space to support a large number of concurrent networks.

Here is a suggested daemon.json that provides up to 65,536 networks of 128 addresses each, drawn from the 10.128.0.0/9 range:

```json
{
  "default-address-pools": [
    { "base": "10.128.0.0/9", "size": 25 }
  ]
}
```

If you need to draw from multiple private ranges (for example, to avoid conflicts with existing 10.x routes), you can combine pools:

```json
{
  "default-address-pools": [
    { "base": "10.128.0.0/9", "size": 25 },
    { "base": "172.16.0.0/12", "size": 25 },
    { "base": "192.168.0.0/16", "size": 25 }
  ]
}
```

## Part 2 - Running Rule Studio through Docker Compose:

1. While being in the backend directory, create .env file through editing the .env.example file by renaming to .env or use command:

mv .env.example .env

Add TAZAMA_AUTH_URL, ADMIN_SERVICE_URL, SIMULATION_SANDBOX_URL and OPENSEARCH envs.

For Simulation Studio specifically, also add TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE, TESTCONTAINERS_HOST_OVERRIDE, and TESTCONTAINERS_RYUK_DISABLED envs. Optionally add DEBUG=testcontainers* to surface testcontainers debug logs in the Rule Studio logs, which is useful when troubleshooting testcontainers issues.

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

2. Run the docker-compose.yaml to run Rule Studio backend and Frontend along with Database, Valkey and NATS.

docker compose up -d

## Part 3 - Running with Full Stack Docker Tazama:

1. Use Full Stack Docker Tazama environment variables in the .env file of the rule-studio service.

```env
ADMIN_SERVICE_URL=http://tazama-admin-service-1:3100
```

```env
TAZAMA_AUTH_URL=http://tazama-auth-1:3020/v1/auth
```

For Backend run:

cd backend

docker build -t trs-backend:latest .

docker run -d -p 3005:3005 --env-file /backend/.env --name trs-backend --network tazama_default trs-backend:latest

For Frontend run:

cd ../frontend

docker build -t trs-frontend:latest .

docker run -d -p 5174:5174 --env-file /frontend/.env --name trs-frontend --network tazama_default trs-frontend:latest

Debug Commands

docker logs -f trs-backend
