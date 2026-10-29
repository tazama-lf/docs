# Tazama Case Management System (CMS) - Deployment Guide

## Prerequisites

- Docker and Docker Compose
- A running Tazama core (NATS, auth-service, Keycloak) and the auth-service public key (`public.pem`)
- A GitHub token with `read:packages` access to the `@tazama-lf` npm packages
- An OpenSearch instance (not included in the CMS compose files; see Part 2, step 7)

---

## Part 1 – Setting up

1. Clone the repository:

```bash
git clone -b dev https://github.com/tazama-lf/case-management-system.git
cd case-management-system
```

2. Export `GH_TOKEN` in your shell before building. `backend/.npmrc` already reads it as `${GH_TOKEN}`, and the build receives it as a BuildKit secret. Do not paste the token into `backend/.npmrc`.

```bash
export GH_TOKEN=<your-github-token>      # Linux / macOS
```

```powershell
$env:GH_TOKEN = "<your-github-token>"    # Windows PowerShell
```

3. Copy the auth-service public key to `backend/public.pem`.

---

## Part 2 - Running CMS through Docker Compose

1. Create the environment files:

```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
cp docker/couchdb/local.ini.example docker/couchdb/local.ini
```

2. Add these variables to `backend/.env`. They are required but missing from `.env.example`:

```env
PRIORITY_FIRST_HALF=0.33
PRIORITY_SECOND_HALF=0.66
PRIORITY_THIRD_HALF=1.0
DEFAULT_SLA_HOURS=72
VOILA_URL=http://voila:8866
```

Also add the following two variables. They are read by the Voila container, not the backend: `docker-compose-cms.yml` uses `backend/.env` as the `env_file` of both services.

```env
CASE_MGMT_BACKEND_URL=http://backend:3090
CMS_FRONTEND_ORIGIN=http://localhost:5175
```

3. Set the following values in `backend/.env`:

```env
TAZAMA_AUTH_URL=http://<auth-service-host>:3020/v1/auth
SERVER_URL=nats://<nats-host>:4222
COUCHDB_USERNAME=<couchdb-admin>
COUCHDB_PASSWORD=<couchdb-password>
CORS_ALLOWED_ORIGINS=http://localhost:5175
SESSION_COOKIE_SECURE=false
SESSION_COOKIE_SAMESITE=lax
OPENSEARCH_NODE=http://opensearch:9200
GOLD_LAKEHOUSE_API_URL=http://<biar-host>:8282
GOLD_LAKEHOUSE_TIMEOUT=120000
TRIAGE_TYPE=MANUAL
SMTP_NOTIFICATIONS=false
```

If you use an existing OpenSearch instance, replace `OPENSEARCH_NODE` with its URL. Keep `http://opensearch:9200` when you use the OpenSearch container from step 7 or the Tazama Stack service.

`SMTP_NOTIFICATIONS` is required. Set it to `true` only with a working SMTP account (`SMTP_HOST`, `SMTP_USER`, `SMTP_PASS` and `MAIL_FROM` all set).

4. In `docker/couchdb/local.ini`, set the `[admins]` entry to the same username and password as `COUCHDB_USERNAME` / `COUCHDB_PASSWORD`, and set `uuid` and `[chttpd_auth] secret`.

5. In `docker-compose-cms.yml`, pass `GH_TOKEN` to the `migrate` and `backend` builds as a BuildKit secret, and change the frontend port mapping to `5175:5175` (the frontend listens on 5175 inside the container):

```yaml
services:
  migrate:
    build:
      context: ./backend
      target: migrate
      secrets:
        - GH_TOKEN
  # ...
  backend:
    build:
      context: ./backend
      target: run-env
      secrets:
        - GH_TOKEN
  # ...
  frontend:
    ports:
      - '5175:5175'

secrets:
  GH_TOKEN:
    environment: GH_TOKEN
```

6. Start the database, Valkey and NATS:

```bash
docker compose -f docker-compose-infra.yml up -d
```

7. If you do not have an OpenSearch instance, start one on the same network. On Linux, first raise `vm.max_map_count` to at least `262144`, otherwise OpenSearch exits during startup:

```bash
sudo sysctl -w vm.max_map_count=262144      # Linux only
docker run -d --name opensearch --network tazama_default -p 127.0.0.1:9200:9200 \
  -e discovery.type=single-node -e DISABLE_SECURITY_PLUGIN=true \
  -v opensearch_data:/usr/share/opensearch/data \
  opensearchproject/opensearch:2.13.0
```

This instance has the security plugin disabled, so the port is bound to `127.0.0.1` only. CMS reaches it over the Docker network. Do not publish port 9200 on other interfaces.

The `sysctl` setting is lost on reboot. To keep it, add `vm.max_map_count=262144` to `/etc/sysctl.conf`. The named volume keeps the audit data when the container is recreated.

Alternatively, use the `opensearch` service from Tazama Stack (`extensions/docker-compose.extensions.infrastructure.yaml`).

8. Start CMS, with `GH_TOKEN` exported in the same shell:

```bash
docker compose -f docker-compose-cms.yml up -d --build
```

CMS UI: `http://localhost:5175`. API docs: `http://localhost:3090/api/docs`.

---

## Part 3 - Running with Tazama Stack

1. Start the Tazama Stack core with the authentication services.

2. In `tazama-stack/extensions/`, create the secrets file and fill in every `[required]` key:

```bash
cp secrets.env.template secrets.env
```

3. In `extensions/.env`, set `SERVER_A_HOST` (core), `SERVER_B_HOST` (this machine) and `SERVER_C_HOST` (BIAR).

4. Check these values in `extensions/env/case-management-system.env`, and add `SMTP_NOTIFICATIONS` if it is missing:

```env
TRIAGE_TYPE=MANUAL
GOLD_LAKEHOUSE_API_URL=http://${SERVER_C_HOST}:8282
CORS_ALLOWED_ORIGINS=http://${SERVER_B_HOST}:5175
CMS_FRONTEND_ORIGIN=http://${SERVER_B_HOST}:5175
SMTP_NOTIFICATIONS=false
```

`CORS_ALLOWED_ORIGINS` and `CMS_FRONTEND_ORIGIN` must both be the origin users type in the browser. The defaults (`http://localhost:5175`) work only when the browser runs on Server B. If users reach CMS through a different address or domain, use that origin instead.

5. In the core stack's `env/event-adjudicator.env`, set `SUPPRESS_ALERTS=false`. Otherwise no alerts are sent to CMS.

6. Run the launcher and choose the extensions deployment:

```bash
./tazama-extensions.sh      # Linux / macOS
tazama-extensions.bat       # Windows
```

CMS UI: `http://<server-b>:5175`. API docs: `http://<server-b>:3090/api/docs`.

---

## Debug Commands

```bash
docker logs -f tazama-cms-backend               # Part 2
docker logs -f case-management-system-backend   # Part 3
```
