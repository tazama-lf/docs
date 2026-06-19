# Tazama Rule Studio (TRS) - Deployment Guide

## Part 1 – Setting up:

1.  Clone the repository: git clone https://github.com/tazama-lf/rule-studio.git

2.  cd backend & cd frontend

3.  Add GH_TOKEN to the backend .npmrc

## Part 2 - Running TRS through Docker Compose:

1. While being in the backend directory, create .env file through editing the .env.example file by renaming to .env or use command:

mv .env.example .env

Set the following backend environment variables:

```env
NODE_ENV=dev
MAX_CPU=2
FUNCTION_NAME=model-management-backend
PORT=3005
TAZAMA_AUTH_URL=http://<auth-host>:3020/v1/auth
AUTH_PUBLIC_KEY_PATH=/path/to/public.pem
CERT_PATH_PUBLIC=/path/to/public.pem
ADMIN_SERVICE_URL=http://<admin-host>:3100
ALLOWED_ORIGINS=<frontend-host>:5174
CRYPTO_SECRET_KEY=<shared-crypto-key>
ENCRYPTION_KEY=<shared-encryption-key>
IV_LENGTH=<16-char-iv>
AUDIT_PROVIDER=opensearch
OPENSEARCH_NODE=http://<opensearch-host>:9200
OPENSEARCH_USERNAME=admin
OPENSEARCH_PASSWORD=admin
OPENSEARCH_INDEX=rule-studio-audit
REDIS_HOST=<valkey-host>
REDIS_PORT=6379
REDIS_PASSWORD=<redis-password>
```

CRYPTO_SECRET_KEY and ENCRYPTION_KEY are shared with the frontend (see VITE_CRYPTO_KEY below) — the same values must be set on both sides for payload encryption to work.

Rule images are published to a DockerHub registry when rules are built, so the backend needs DockerHub credentials and access to a Docker socket:

```env
DOCKERHUB_USERNAME=<dockerhub-username>
DOCKERHUB_NAMESPACE=<dockerhub-namespace>
DOCKERHUB_TOKEN=<dockerhub-access-token>
DOCKER_HOST=unix:///var/run/docker.sock
```

The backend also uses testcontainers to spin up isolated environments for rule simulations. Set the following so testcontainers can reach the host Docker daemon:

```env
TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
TESTCONTAINERS_HOST_OVERRIDE=host.docker.internal
TESTCONTAINERS_RYUK_DISABLED=true
```

Optionally add `DEBUG=testcontainers*` to surface testcontainers debug logs in the Rule Studio logs, which is useful when troubleshooting testcontainers issues.

Frontend:

mv .env.template .env

```env
VITE_API_URL=http://<backend-host>:3005
VITE_SANDBOX_API_URL=http://<sandbox-host>:3050
VITE_NATS_API_URL=http://<nats-utilities-host>:4000
VITE_DEMS_ENDPOINT=http://<dems-host>:3002/dems-engine
VITE_ADMIN_ENDPOINT=http://<admin-host>:3100
VITE_SIMULATION_ENDPOINT=http://<tms-host>:5000/v1/evaluate/iso20022/pacs.002.001.12
VITE_CRYPTO_KEY=<shared-crypto-key>
VITE_APP_NAME="Model Management"
VITE_APP_VERSION=0.0.1
```

VITE_CRYPTO_KEY must match the backend's CRYPTO_SECRET_KEY / ENCRYPTION_KEY values.

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

cd backend

docker build -t trs-backend:latest .

docker run -d -p 3005:3005 --env-file /backend/.env --name trs-backend --network tazama_default trs-backend:latest

For Frontend run:

cd ../frontend

docker build -t trs-frontend:latest .

docker run -d -p 5174:5174 --env-file /frontend/.env --name trs-frontend --network tazama_default trs-frontend:latest

Debug Commands

docker logs -f trs-backend
