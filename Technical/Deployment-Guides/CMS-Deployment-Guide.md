# Tazama Case Management System (CMS) - Deployment Guide

## Part 1 – Setting up

1. Clone the repository:

```bash
git clone https://github.com/tazama-lf/case-management-system.git
```

2. Move into the backend directory:

```bash
cd backend
```

3. Add `GH_TOKEN` to the backend `.npmrc`.

---

## Part 2 - Running CMS through Docker Compose

1. While in the backend directory, create the `.env` file by renaming `.env.example` to `.env`:

```bash
mv .env.example .env
```

For the frontend:

```bash
mv .env.template .env
```

Set the following frontend environment variables:

```env
VITE_API_BASE_URL=http://localhost:3000
VITE_VOILA_BASE_URL=http://localhost:8866
```

2. Run `docker-compose-infra.yaml` to set up the database, Valkey, and NATS microservices:

```bash
docker compose -f docker-compose-infra.yaml up -d
```

3. Once the infrastructure is ready and running, run CMS:

```bash
docker compose -f docker-compose-cms.yaml up -d
```

---

## Part 3 - Running with Full Stack Docker Tazama

1. Use the Full Stack Docker Tazama environment variables in the `.env` file of the CMS service:

```env
CONFIGURATION_DATABASE_URL=postgresql://postgres:unused@tazama-postgres-1:5432/encrichment
REDIS_HOST=tazama-valkey-1
SERVER_URL=nats://tazama-nats-1:4222
```

2. Run CMS assuming Full Stack Docker Tazama is already running. CMS will use the `tazama_default` network because the compose file uses `external: true`.

```bash
docker compose -f docker-compose-cms.yaml up -d
```

---

## Debug Commands

```bash
docker logs -f cms-backend
```
