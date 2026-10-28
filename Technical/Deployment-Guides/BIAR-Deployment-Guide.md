# Tazama Business Intelligence, Analytics and Reporting (BIAR) - Deployment Guide

## Prerequisites

- Docker and Docker Compose, with at least 8 GB of memory available to Docker
- A running Tazama core (PostgreSQL on port 15432) and CMS (PostgreSQL on port 15433, CouchDB on port 5984)
- The auth-service public key (`public.pem`)

---

## Part 1 – Setting up

1. Clone the repository:

```bash
git clone -b dev https://github.com/tazama-lf/biar.git
cd biar
```

2. Create the environment file:

```bash
cp .env.example .env
```

3. Create the warehouse folder and copy the public key:

```bash
sudo mkdir -p /opt/Tazama_Warehouse /opt/biar/secrets
sudo cp public.pem /opt/biar/secrets/tazama-public-key.pem
```

---

## Part 2 - Running BIAR through Docker Compose

1. Set the following values in `.env`:

```env
SERVER_C_HOST=<this machine>
SERVER_B_HOST=<cms host>
TAZAMA_WAREHOUSE_HOST_PATH=/opt/Tazama_Warehouse
TAZAMA_AUTH_PUBLIC_KEY_HOST_PATH=/opt/biar/secrets/tazama-public-key.pem
S3A_ACCESS_KEY=<access-key>
S3A_SECRET_KEY=<secret-key>
COUCHDB_URL=http://<user>:<password>@${SERVER_B_HOST}:5984/cms-evidence
NIFI_URL=http://${SERVER_C_HOST}:8081
PB_OZONE_ENDPOINT=http://s3g:9878
JUPYTERHUB_AUTH=native
JUPYTERHUB_ADMIN=admin
```

To log in to JupyterHub with Keycloak instead, set `JUPYTERHUB_AUTH=keycloak` together with `KEYCLOAK_ISSUER_URL`, `JUPYTERHUB_PUBLIC_URL`, `KEYCLOAK_CLIENT_SECRET` and `JUPYTERHUB_CRYPT_KEY`.

2. Start BIAR:

```bash
docker compose up -d --build
```

The first start takes 2–3 minutes.

3. Configure NiFi (Part 4).

| Interface | URL |
| --- | --- |
| NiFi | `http://<server-c>:8088/nifi` |
| Automation Orchestrator | `http://<server-c>:7619/docs` |
| Datalakehouse API | `http://<server-c>:8282/docs` |
| JupyterHub | `http://<server-c>:8888` |

---

## Part 3 - Running with Full Stack Docker Tazama

1. Start the Full Stack Docker Tazama core and extensions stacks.

2. In `Full-Stack-Docker-Tazama/biar/`, create the secrets file and fill in every `[required]` key:

```bash
cp secrets.env.template secrets.env
```

`TAZAMA_CORE_PG_PASSWORD`, `TAZAMA_EXT_PG_PASSWORD`, `TAZAMA_COUCHDB_USERNAME`/`TAZAMA_COUCHDB_PASSWORD` and `TAZAMA_JUPYTERHUB_OIDC_CLIENT_SECRET` must match the core and extensions `secrets.env`.

3. In `biar/.env`, set `SERVER_A_HOST`, `SERVER_B_HOST`, `SERVER_C_HOST` and `TAZAMA_WAREHOUSE_HOST_PATH`.

4. In `biar/env/biar-unstructured-pipeline.env`, set `NIFI_URL=http://biar-nifi:8081`. The pipeline adds `/contentListener` itself.

5. Run the launcher and choose option **1**:

```bash
./tazama-biar.sh      # Linux / macOS
tazama-biar.bat       # Windows
```

6. Configure NiFi (Part 4).

| Interface | URL |
| --- | --- |
| NiFi | `http://localhost:8088/nifi` |
| Automation Orchestrator | `http://<server-c>:7619/docs` |
| Datalakehouse API | `http://<server-c>:8282/docs` |
| JupyterHub | `http://<server-c>:8000` |

---

## Part 4 - Configuring NiFi

The flow template uses the database host `10.10.80.18`. Update it after the first start:

1. Open NiFi, then open the imported process group's **Controller Services**.

2. Edit each `DBCPConnectionPool` service. Set the **Database Connection URL**, **Database User** (`postgres`) and **Password**, then **Enable** it:

| Service | Database Connection URL |
| --- | --- |
| `event_history` | `jdbc:postgresql://<core-host>:15432/event_history` |
| `raw_history` | `jdbc:postgresql://<core-host>:15432/raw_history` |
| `evaluation` | `jdbc:postgresql://<core-host>:15432/evaluation` |
| `configuration` | `jdbc:postgresql://<core-host>:15432/configuration` |
| `enrichment` | `jdbc:postgresql://<core-host>:15432/enrichment` |
| `tazama_cms` | `jdbc:postgresql://<cms-host>:15433/tazama_cms` |

3. Set the Ozone S3 access and secret keys on `AWSCredentialsProviderControllerService` and enable it.

4. Right-click the process group and select **Start**.

---

## Part 5 - Connecting CMS

Set these values in the CMS backend environment:

```env
GOLD_LAKEHOUSE_API_URL=http://<server-c>:8282
GOLD_LAKEHOUSE_TIMEOUT=120000
```

CMS users need the `QUERY_LAKEHOUSE` realm role in Keycloak.

---

## Debug Commands

```bash
docker logs -f biar-nifi
docker logs -f biar-automation-orchestrator
docker logs -f biar-datalakehouse-api
docker logs -f biar-jupyterhub
docker logs -f biar-unstructured-pipeline
```
