# Rule Building Flow — Setup and Deployment Guide

Setup, secrets, and deployment guide for the Tazama Rule Studio + DevTestOps + Rule Executer stack. Covers environment variables, GitHub secrets/variables, runner prerequisites, and the order of operations to get a rule container running against NATS. The previously-shipped Docker Hub publish/pull path is documented in §8 but currently disabled.

Open PRs this doc is written against:

- [`rule-studio-example#13`](https://github.com/tazama-lf/rule-studio-example/pull/13) — moves the deploy workflow to BuildKit secret mounts, makes runner label / server IP configurable, upgrades `frms-coe-lib`.
- [`rule-studio#132`](https://github.com/tazama-lf/rule-studio/pull/132) — refactors the rule-only simulation flow; NATS subject-shape bug still present (§7).
- [`rule-studio-devtestops#5`](https://github.com/tazama-lf/rule-studio-devtestops/pull/5) — replaces the GitHub `generate` API with a `simple-git` clone-and-push bootstrap, renames `GITHUB_DEFAULT_BRANCH` → `GITHUB_BRANCH`, adds `git` to the runtime image.

Repos in scope (all under `tazama-lf`; tenant forks live under a different org, e.g. `psl-copilot`):

| Repo                                                                             | Role                                                                                                                                         |
| -------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| [`rule-studio`](https://github.com/tazama-lf/rule-studio)                       | React frontend + NestJS/Fastify backend. Rule authoring, simulation, promotion, test reports.                                                |
| [`rule-studio-devtestops`](https://github.com/tazama-lf/rule-studio-devtestops) | Fastify REST API. Translates UI actions (bootstrap / populate / promote) into GitHub REST +`git` calls.                                    |
| [`rule-studio-example`](https://github.com/tazama-lf/rule-studio-example)       | GitHub template repo. Every rule is cloned from this. Carries the four workflows that drive test → publish → deploy.                       |
| [`rule-executer`](https://github.com/tazama-lf/rule-executer)                   | Runtime. Wraps a rule npm package, connects to NATS, subscribes to`sub-rule-<name>@<version>`, publishes on `pub-rule-<name>@<version>`. |
| [`frms-coe-lib`](https://github.com/tazama-lf/frms-coe-lib)                     | Shared library used by rule packages and rule-executer.                                                                                      |

---

## Table of Contents

- [1. Architecture](#1-architecture)
- [2. Prerequisites](#2-prerequisites)
- [3. `TAZAMA_TOKEN`](#3-tazama_token)
- [4. `rule-studio-devtestops`](#4-rule-studio-devtestops)
- [5. Per-rule repos (`rule-studio-example` template)](#5-per-rule-repos-rule-studio-example-template)
- [6. `rule-studio` (the UI)](#6-rule-studio-the-ui)
- [7. Simulation request flow](#7-simulation-request-flow)
- [8. Docker Hub publishing (disabled)](#8-docker-hub-publishing-disabled)
- [9. Secrets and variables reference](#9-secrets-and-variables-reference)
- [10. Known issues](#10-known-issues)
- [11. Smoke test](#11-smoke-test)
- [12. Troubleshooting](#12-troubleshooting)

---

## 1. Architecture

```
  ┌─────────────────────┐
  │   Rule Author (UI)  │
  │  browser → frontend │
  └──────────┬──────────┘
             │ REST
             ▼
  ┌──────────────────────┐         ┌──────────────────────┐
  │   rule-studio        │  REST   │  rule-studio-        │
  │   backend (Nest/     │───────▶│  devtestops          │
  │   Fastify)           │         │  (Fastify)           │
  └──────┬───────────────┘         └────────┬─────────────┘
         │                                  │
         │ NATS (simulation)                │ GitHub REST + `simple-git`
         ▼                                  ▼
  ┌─────────────────────┐         ┌──────────────────────┐
  │ nats-utilities REST │         │  GitHub organisation │
  │ bridge → NATS       │         │  (rule-<id> repos    │
  └──────┬──────────────┘         │  from template repo) │
         │                        └───────────┬──────────┘
         │ pub/sub                            │
         │                                    │ push triggers Actions
         │                                    ▼
         │                        ┌──────────────────────┐
         │                        │ .github/workflows:   │
         │                        │  unit-test.yml       │
         │                        │  publish.yml         │
         │                        │  deploy.yml          │
         │                        │  deploy-to-uat.yml   │
         │                        └───────────┬──────────┘
         │                                    │
         │                                    │ workflow_run
         │                                    ▼
  ┌──────────────────────────────────────────────────┐
  │  Self-hosted GitHub Actions runner:              │
  │   - clones rule-executer (dev branch)            │
  │   - installs rule from npm.pkg.github.com        │
  │   - docker build (BuildKit --secret GH_TOKEN)    │
  │   - docker run rule container                    │
  │                                                  │
  │   [disabled — see §8]                            │
  │   - docker push to Docker Hub registry           │
  └──────────────────────┬───────────────────────────┘
                         │
                         ▼
  ┌──────────────────────────────────────────────────┐
  │  Rule container connects to:                     │
  │   - PostgreSQL (raw_history, configuration,      │
  │                 event_history)                   │
  │   - NATS on <SERVER_IP>:14222                    │
  │   - Redis/Valkey on <SERVER_IP>:6379             │
  └──────────────────────────────────────────────────┘
```

Rule containers subscribe to `sub-rule-<RULE_NAME>@<RULE_VERSION>` and reply on `pub-rule-<RULE_NAME>@<RULE_VERSION>`. Simulation from the UI publishes to the same subject via the `nats-utilities` HTTP bridge.

---

## 2. Prerequisites

### 2.1 GitHub / accounts

- Owner on the target GitHub org (to create org-level secrets, variables, and repos).
- AES-256-CBC key material: 32-byte key, 16-byte IV. Used to encrypt the GitHub PAT for `rule-studio-devtestops`.
- Docker Hub org account with a PAT — optional; needed only for simulation image listing today, and for §8 if reinstated.

### 2.2 Servers

- One or more self-hosted GitHub Actions runners. Each needs:
  - Docker 20.10+ with BuildKit (`docker buildx version`).
  - `git` on `$PATH`.
  - Node.js 20+ (`deploy.yml` installs it via `actions/setup-node@v4`; OS toolchain still required).
  - Network reachability to Postgres, NATS, Redis/Valkey (see §5.5).
  - Registered with the label from `RUNNER_LABEL` (§5.4).
- PostgreSQL with databases `raw_history`, `configuration`, `event_history`.
- NATS server on `:14222` (JetStream not required for rule-only mode).
- Redis/Valkey on `:6379`.

### 2.3 Workstation

- `gh` (authenticated), `openssl`, `docker`, `docker compose`, Node.js 20+.

---

## 3. `TAZAMA_TOKEN`

GitHub PAT used by every workflow in `rule-studio-example` and by every git operation in `rule-studio-devtestops`.

### 3.1 Scopes

Classic PAT: `repo`, `write:packages`, `workflow`.

Fine-grained PAT on the target org: **Administration** R/W, **Contents** R/W, **Actions** R/W, **Packages** R/W (org-level).

### 3.2 Where to install it

1. **GitHub org → Settings → Secrets and variables → Actions → New organization secret**, name `TAZAMA_TOKEN`. Consumed by workflows as `${{ secrets.TAZAMA_TOKEN }}`.
2. **In `rule-studio-devtestops` `.env`** as `GITHUB_TOKEN`, AES-encrypted. See §3.3.

### 3.3 Encrypting the token for DevTestOps

The service decrypts `GITHUB_TOKEN` at startup using `ENCRYPTION_KEY` (32 bytes) and `ENCRYPTION_IV` (16 bytes), AES-256-CBC. Decryption in [`src/utils/decrypt-utilis.ts`](../repos/rule-studio-devtestops/src/utils/decrypt-utilis.ts) reads the ciphertext as hex.

```javascript
// encrypt-token.js
const crypto = require('node:crypto');
const key = Buffer.from(process.env.ENCRYPTION_KEY, 'utf8'); // 32 bytes
const iv  = Buffer.from(process.env.ENCRYPTION_IV,  'utf8'); // 16 bytes
const cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
const encrypted = Buffer.concat([
  cipher.update(process.env.PLAIN_TOKEN, 'utf8'),
  cipher.final(),
]);
console.log(encrypted.toString('hex'));
```

```bash
ENCRYPTION_KEY='<32-char string>' \
ENCRYPTION_IV='<16-char string>'  \
PLAIN_TOKEN='ghp_xxx…'            \
  node encrypt-token.js
# → paste into GITHUB_TOKEN in .env
```

Notes:

- `ENCRYPTION_KEY` must be 32 bytes and `ENCRYPTION_IV` 16, in the same encoding you'll pass at runtime. `openssl rand -hex 32` → 64 hex chars = 32 bytes; `openssl rand -hex 16` → 32 hex chars = 16 bytes. Verify with `Buffer.byteLength(process.env.ENCRYPTION_KEY, 'utf8')`.
- Re-encrypt when the underlying PAT is rotated.

---

## 4. `rule-studio-devtestops`

Fastify service that translates UI actions into GitHub operations. Runs as a container or Node process.

### 4.1 Environment variables

From [`src/config.ts`](../repos/rule-studio-devtestops/src/config.ts) via `validateProcessorConfig()` in `frms-coe-lib`. "Required" = process throws on startup if missing or empty.

**Required:**

| Variable                    | Notes                                                                           |
| --------------------------- | ------------------------------------------------------------------------------- |
| `NODE_ENV`                | Must be`dev` / `production` / `test`. `development` is rejected.        |
| `FUNCTION_NAME`           | Service identifier used by the logger.                                          |
| `PORT`                    | HTTP port. No code default.                                                     |
| `HOST`                    | Bind address. No code default.                                                  |
| `GITHUB_API_URL`          | e.g.`https://api.github.com`.                                                 |
| `GITHUB_TEMPLATE_OWNER`   | Org that owns the template repo.                                                |
| `GITHUB_TEMPLATE_REPO`    | Template repo name.                                                             |
| `GITHUB_BRANCH`           | Template branch to clone. Was`GITHUB_DEFAULT_BRANCH` pre-PR-#5 (§10.4).      |
| `GITHUB_TEST_REPORT_PATH` | Path within each rule repo to the unit-test HTML report.                        |
| `ENCRYPTION_KEY`          | 32-byte AES-256-CBC key (§3.3).                                                |
| `ENCRYPTION_IV`           | 16-byte AES-256-CBC IV (§3.3).                                                 |
| `GITHUB_TOKEN`            | AES-encrypted`TAZAMA_TOKEN` (§3.3).                                          |
| `GITHUB_ORG_NAME`         | Org where per-rule repos are created. Can differ from`GITHUB_TEMPLATE_OWNER`. |
| `GITHUB_INIT_BRANCH`      | Initial branch name in each new rule repo, e.g.`staging`.                     |

**Optional with defaults:**

| Variable      | Default  |
| ------------- | -------- |
| `LOG_LEVEL` | `info` |
| `MAX_CPU`   | `1`    |

**Optional, no default:**

`CERT_PATH_PRIVATE`, `CERT_PATH_PUBLIC`, `SIDECAR_HOST`, `ELASTIC_USERNAME`, `ELASTIC_PASSWORD`, `ELASTIC_HOST`, `ELASTIC_INDEX`, `ELASTIC_FLUSH_BYTES`, `ELASTIC_SEARCH_VERSION`.

`NATS_URL` appears in `.env.sample` but is not read anywhere in `src/`. Ignore it.

### 4.2 Runtime requirements

- The runtime image must have `git` installed (`RUN apk add --no-cache git` in the Dockerfile runner stage). Without it, `simple-git` fails with `spawn git ENOENT`.
- `simple-git` shells out via `child_process.spawn`; process supervisors must not block `/usr/bin/git`.

### 4.3 Running

```bash
npm ci
cp .env.sample .env    # then edit per §4.1
npm run dev            # or `npm run start`
```

Health check: `curl http://localhost:3050/health` → 200. Note: the container `HEALTHCHECK` in the Dockerfile targets `/api/health`, which does not exist — the in-container healthcheck reports unhealthy. Fix at the Dockerfile.

---

## 5. Per-rule repos (`rule-studio-example` template)

Every rule becomes its own GitHub repo cloned from `rule-studio-example`. The template's `.github/workflows/`:

| Workflow              | Trigger                                                       | Purpose                                                                                                                                                               |
| --------------------- | ------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `unit-test.yml`     | push/PR to`staging`                                         | Install deps from GitHub Packages, run Jest, commit HTML report back to the branch.                                                                                   |
| `publish.yml`       | push to`dev`, `workflow_dispatch`                         | Auto-increment version if published; build;`npm publish` to `npm.pkg.github.com` as `@<org>/<repo>@<version>`.                                                  |
| `deploy.yml`        | `workflow_run` after `publish.yml`, `workflow_dispatch` | Clone`rule-executer -b dev`, patch its Dockerfile to install the published rule, `docker build` with a BuildKit secret, `docker run` on the self-hosted runner. |
| `deploy-to-uat.yml` | push to`prod`                                               | UAT variant of`deploy.yml`. No `workflow_dispatch`. See §10.1 for other deltas.                                                                                  |

### 5.1 Secrets and variables

Set at **GitHub org → Settings → Secrets and variables → Actions**.

**Organization secrets:**

| Secret           | Consumed by        | Purpose                                                                                                                                      |
| ---------------- | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `TAZAMA_TOKEN` | all four workflows | Authenticates`git clone` of `rule-executer`, `npm ci` / `npm publish` against `npm.pkg.github.com`, and the BuildKit secret mount. |

**Organization variables** (repo-level overrides work; §5.4):

| Variable         | Consumed by    | Default (in workflow) |
| ---------------- | -------------- | --------------------- |
| `RUNNER_LABEL` | `deploy.yml` | `server-18`         |
| `SERVER_IP`    | `deploy.yml` | `10.10.80.18`       |

`deploy-to-uat.yml` has different defaults — see §10.1.

### 5.2 Creating the template repo

Under `tazama-lf` this already exists. For a new tenant org:

```bash
gh repo create <your-org>/rule-studio-example \
  --template tazama-lf/rule-studio-example \
  --public
```

Then Settings → Template repository → check. Post-PR-#5, devtestops uses `simple-git` clone-and-push and does not need the "template" flag; the pre-#5 flow used `POST /repos/…/generate` and did. Keep the flag on for backwards compatibility.

### 5.3 Bootstrapping a rule repo

Triggered from the UI: *Create Rule* → frontend POSTs to devtestops' `/v1/bootstrap`. The service:

1. Creates `<GITHUB_ORG_NAME>/<ruleId>` via `POST /orgs/{org}/repos`.
2. Clones `<GITHUB_TEMPLATE_OWNER>/<GITHUB_TEMPLATE_REPO>` at `<GITHUB_BRANCH>` into a temp dir with `simple-git`.
3. Renames the branch to `<GITHUB_INIT_BRANCH>` (e.g. `staging`) via `git branch -M`.
4. Pushes to the new repo.
5. Copies templated files (`package.json` with the new rule version, etc.) via the GitHub Contents API.

Manual invocation:

The GitHub PAT, target org, and init branch are read from the service's `.env` (`GITHUB_TOKEN`, `GITHUB_ORG_NAME`, `GITHUB_INIT_BRANCH`) by `tenantMiddleware`. The middleware only inspects the `Authorization` header, from which it extracts a `tenantId` claim.

```bash
curl -X POST http://localhost:3050/v1/bootstrap \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <JWT with tenantId claim>' \
  -d '{"ruleId":"001","ruleVersion":"1.0.0"}'
```

### 5.4 `RUNNER_LABEL` and `SERVER_IP`

- Org-wide: set both as Actions variables at the org level.
- Per-repo override: repo → Settings → Secrets and variables → Actions → Variables. Repo values win over org values.

Set them explicitly rather than relying on the workflow's hardcoded default — the defaults have shifted across PR revisions (§10.3).

### 5.5 Self-hosted runner setup

1. Register the runner with the org and label it per `RUNNER_LABEL`.
2. Install Docker 20.10+, start the daemon.
3. Install `git`.
4. Verify BuildKit:

   ```bash
   docker buildx version
   DOCKER_BUILDKIT=1 docker build --help | grep -- --secret
   ```

   `--secret` must be listed — `deploy.yml` uses `docker build --secret id=GH_TOKEN,env=GH_TOKEN`.
5. Reachability from the runner:

   - Postgres on `<SERVER_IP>:15432` (dbs `raw_history`, `configuration`, `event_history`).
   - NATS on `<SERVER_IP>:14222`.
   - Redis/Valkey on `<SERVER_IP>:6379`.

   `deploy.yml` uses a single `$SERVER_IP` for all three. If they live on different hosts, split the workflow env block or use DNS names.
6. Verify registry access on the runner:

   ```bash
   echo "//npm.pkg.github.com/:_authToken=$TAZAMA_TOKEN" > ~/.npmrc
   npm whoami --registry=https://npm.pkg.github.com
   ```

### 5.6 Rule container runtime env

Set by `deploy.yml` via `docker run -e …`. Values are derived from `$SERVER_IP` or hardcoded. Listed for debugging.

| Env var                                                        | Value                                                               | Notes                                                  |
| -------------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------ |
| `RULE_NAME`                                                  | `$RULE_ID` (repo name with `rule-` stripped)                    | Builds NATS subject`sub-rule-<RULE_NAME>@<VERSION>`. |
| `RULE_VERSION`                                               | `1.0.0` (hardcoded)                                               | §10.2.                                                |
| `RAW_HISTORY_DATABASE`                                       | `raw_history`                                                     |                                                        |
| `RAW_HISTORY_DATABASE_HOST`                                  | `$SERVER_IP`                                                      |                                                        |
| `RAW_HISTORY_DATABASE_PORT`                                  | `15432`                                                           |                                                        |
| `RAW_HISTORY_DATABASE_USER`                                  | `postgres`                                                        |                                                        |
| `RAW_HISTORY_DATABASE_PASSWORD`                              | `unused` in `deploy.yml`, `postgres` in `deploy-to-uat.yml` | §10.9.                                                |
| `RAW_HISTORY_DATABASE_CERT_PATH`                             | `/usr/local/share/ca-certificates/ca-certificates.crt`            |                                                        |
| `CONFIGURATION_DATABASE*`                                    | same shape                                                          |                                                        |
| `EVENT_HISTORY_DATABASE*`                                    | same shape                                                          |                                                        |
| `STARTUP_TYPE`                                               | `nats`                                                            |                                                        |
| `SERVER_URL`                                                 | `$SERVER_IP:14222`                                                | NATS host:port.                                        |
| `PRODUCER_STREAM` / `CONSUMER_STREAM` / `STREAM_SUBJECT` | empty                                                               | Empty → core NATS, not JetStream.                     |
| `ACK_POLICY`                                                 | `Explicit`                                                        |                                                        |
| `PRODUCER_STORAGE`                                           | `File`                                                            |                                                        |
| `PRODUCER_RETENTION_POLICY`                                  | `Workqueue`                                                       |                                                        |
| `REDIS_HOST`                                                 | `$SERVER_IP`                                                      |                                                        |
| `REDIS_PORT`                                                 | `6379`                                                            |                                                        |
| `REDIS_PASSWORD`                                             | `redis-password` (hardcoded)                                      |                                                        |
| `REDIS_AUTH`                                                 | empty                                                               |                                                        |

---

## 6. `rule-studio` (the UI)

Backend + frontend, brought up together via `docker-compose.yml` for local dev.

### 6.1 Backend env (`backend/.env`)

The `EnvironmentVariables` class in `backend/src/services/config/env.validation.ts` is dead code — never wired into `ConfigModule.forRoot({ validate })`. Startup-time validation only enforces `NODE_ENV`, `FUNCTION_NAME`, `MAX_CPU` via `validateProcessorConfig()` in `logger-service.module.ts`. Other vars are either lazy (throw when the feature is exercised) or have code defaults.

**Required at startup:**

| Variable          | Notes                                |
| ----------------- | ------------------------------------ |
| `NODE_ENV`      | `dev` / `production` / `test`. |
| `FUNCTION_NAME` | Service identifier.                  |

**Lazy-required (throws when the feature is used):**

| Variable              | Where it throws                                                     |
| --------------------- | ------------------------------------------------------------------- |
| `CRYPTO_SECRET_KEY` | Symmetric decrypt helper (`backend/src/utils/helperFunction.ts`). |
| `TAZAMA_AUTH_URL`   | Login (`ServiceUnavailableException`).                            |
| `SMTP_FROM_EMAIL`   | When sending an approval-workflow email.                            |

**Optional with defaults:**

| Variable                         | Default                               | Notes                              |
| -------------------------------- | ------------------------------------- | ---------------------------------- |
| `PORT`                         | `3005`                              | Swagger at`/api/docs`.           |
| `API_HOST`                     | `localhost`                         |                                    |
| `ALLOWED_ORIGINS`              | `''`                                | CORS.                              |
| `MAX_CPU`                      | `1`                                 |                                    |
| `LOG_LEVEL`                    | `info`                              |                                    |
| `ADMIN_SERVICE_URL`            | `http://localhost:3100`             |                                    |
| `DEMS_BASE_URL`                | `http://localhost:3002/dems-engine` |                                    |
| `DLH_URL`                      | `http://localhost:5000`             |                                    |
| `IV_LENGTH`                    | `12`                                |                                    |
| `ENCRYPTION_KEY`               | `''`                                | Empty produces broken output.      |
| `REDIS_HOST`                   | `localhost`                         |                                    |
| `REDIS_PORT`                   | `6379`                              |                                    |
| `REDIS_PASSWORD`               | `redis-password`                    |                                    |
| `BULL_PREFIX`                  | `bull`                              |                                    |
| `TAZAMA_REPO_BRANCH`           | `dev`                               | Used by ephemeral simulation env.  |
| `DOCKERHUB_NAMESPACE`          | `tazamaorg`                         |                                    |
| `TESTCONTAINERS_HOST_OVERRIDE` | `localhost`                         | `host.docker.internal` on macOS. |
| `SMTP_FROM_NAME`               | `Tazama Rule Studio`                |                                    |

**Optional, no default:**

- `WRITE_SWAGGER_JSON` — dump generated Swagger to disk.
- `SMTP_HOST` / `SMTP_PORT` / `SMTP_USER` / `SMTP_PASS` / `SMTP_SECURE` — mail config. If `SMTP_HOST`/`SMTP_PASS` are unset, email is disabled with a warning.
- `DOCKERHUB_TOKEN` / `DOCKERHUB_USERNAME` — currently only used to list simulation images, not to push (see §8).

**Not read by any code in `backend/src`**:

`AUTH_PUBLIC_KEY_PATH`, `CERT_PATH_PUBLIC`, `OPENSEARCH_NODE`, `OPENSEARCH_SSL_REJECT_UNAUTHORIZED`, `OPENSEARCH_USERNAME`, `OPENSEARCH_PASSWORD`, `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `DOCKER_HOST`, `TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE`, `TESTCONTAINERS_RYUK_DISABLED`, `DEBUG`.

`POSTGRES_*` values appear only as hardcoded strings passed to spawned testcontainers, not read via `process.env`.

### 6.2 Frontend env (`frontend/.env`)

Vite build-time env — inlined at `npm run build`. Nothing throws at runtime on missing values; unset vars produce broken URLs. Rebuilding the bundle is required to change these.

**Needed for the app to function:**

| Variable                 | Notes                                                                                                                     |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| `VITE_API_URL`         | Backend API URL (e.g.`http://localhost:3005`). Fallback `http://localhost:3000` only in `service/socketService.ts`. |
| `VITE_NATS_API_URL`    | URL of the`nats-utilities` REST bridge. Rule-only simulation POSTs to `${VITE_NATS_API_URL}/natsPublish`.             |
| `VITE_DEMS_ENDPOINT`   | DEMS end-to-end simulation service URL.                                                                                   |
| `VITE_ADMIN_ENDPOINT`  | Admin service URL.                                                                                                        |
| `VITE_CRYPTO_KEY`      | Client-side encryption key.                                                                                               |
| `VITE_SANDBOX_API_URL` | Simulation studio API URL.                                                                                                |

**Optional:**

- `VITE_SIMULATION_ENDPOINT` — additional simulation endpoint.
- `VITE_ALLOWED_HOSTS` — read only in `vite.config.ts` for the dev-server host allow-list.

`VITE_APP_NAME` / `VITE_APP_VERSION` are not read by frontend source (only used as build labels in `frontend/Dockerfile`). Do not set them.

### 6.3 Local bring-up

```bash
git clone git@github.com:tazama-lf/rule-studio.git
cd rule-studio
cp backend/.env.example  backend/.env
cp frontend/.env.example frontend/.env
# Edit both per §6.1 and §6.2
docker compose up -d
```

Backend `http://localhost:3005`, frontend `http://localhost:5174`, Swagger `http://localhost:3005/api/docs`.

---

## 7. Simulation request flow

To verify the stack end-to-end, run a rule-only simulation.

1. `rule-studio` is up.
2. A rule is deployed via `deploy.yml` — `docker ps` on the runner shows the container.
3. In the UI, open the rule → Simulation tab → read-only mode → paste a transaction payload → Run.
4. Frontend POSTs to `${VITE_NATS_API_URL}/natsPublish`:
   ```json
   {
     "functionName": "",
     "awaitReply": true,
     "destination": "sub-<rule_config_id>",
     "consumer":    "pub-<rule_config_id>",
     "message":     { "…transaction payload…": "…" }
   }
   ```
5. `nats-utilities` publishes to `destination`, awaits reply on `consumer`, returns the result.

**Subject-shape mismatch (PR #132).** The frontend uses `sub-<rule_config_id>` / `pub-<rule_config_id>`. The rule-executer subscribes to `sub-rule-<RULE_NAME>@<RULE_VERSION>`. Unless `rule_config_id` in your data is already `rule-<name>@<version>`, subjects will not match and simulation times out. See [TRS-PR-132.md](../pull-requests/TRS-PR-132.md).

---

## 8. Docker Hub publishing (disabled)

A Docker Hub publish/pull step was previously in `.github/workflows/deploy.yml` (commits `dbac433` "feat: dockerhub" through `d1f4139` on `feat-paysys-poc`). It was removed in the current PR-#13 iteration because of the issues in §8.4. Documented here so it can be reintroduced once those are addressed.

### 8.1 What the removed flow did

After building the rule-executer image locally:

1. Logged in to Docker Hub via `docker/login-action@v3` with `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN`.
2. Created the Docker Hub repo at runtime: `POST https://hub.docker.com/v2/users/login` → JWT → `POST https://hub.docker.com/v2/repositories/` with `{ name, namespace, description, is_private: false }`. HTTP 201 = created; 409/400 = already exists.
3. Tagged and pushed twice: `${DOCKERHUB_NAMESPACE}/${RULE_NAME}:${RULE_VERSION}` and `:latest`.
4. Pulled `:latest` back on the runner and `docker run` from the Docker Hub image.

Excerpt from commit `d1f4139:.github/workflows/deploy.yml`:

```yaml
- name: Log in to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}

- name: Create Docker Hub Repository
  run: |
    DOCKERHUB_REPO="${DOCKERHUB_NAMESPACE}/${RULE_NAME}"
    HUB_JWT=$(curl -s -X POST "https://hub.docker.com/v2/users/login" \
      -H "Content-Type: application/json" \
      -d "{\"username\":\"${{ secrets.DOCKERHUB_USERNAME }}\",\"password\":\"${{ secrets.DOCKERHUB_TOKEN }}\"}" \
      | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")
    curl -s -X POST "https://hub.docker.com/v2/repositories/" \
      -H "Authorization: Bearer ${HUB_JWT}" \
      -H "Content-Type: application/json" \
      -d "{\"name\":\"${RULE_NAME}\",\"namespace\":\"${DOCKERHUB_NAMESPACE}\",
           \"description\":\"Rule executer image for ${RULE_NAME}\",\"is_private\":false}"

- name: Build and Push Docker Image to Docker Hub
  run: |
    IMAGE_TAG_VERSIONED="${DOCKERHUB_REPO}:${RULE_VERSION}"
    IMAGE_TAG_LATEST="${DOCKERHUB_REPO}:latest"
    docker build --build-arg GH_TOKEN=${GH_TOKEN} \
      -t "${IMAGE_TAG_VERSIONED}" -t "${IMAGE_TAG_LATEST}" rule-executer-$RULE_NAME
    docker push "${IMAGE_TAG_VERSIONED}"
    docker push "${IMAGE_TAG_LATEST}"

- name: Pull and Deploy Container from Docker Hub
  run: |
    docker pull "${IMAGE_TAG_LATEST}"
    docker stop $RULE_NAME || true
    docker rm   $RULE_NAME || true
    docker run -d --name $RULE_NAME  <…env vars…>  --restart unless-stopped "${IMAGE_TAG_LATEST}"
```

### 8.2 Secrets and variables the removed flow needed

**Organization secrets:**

| Secret                 | Purpose                                                       |
| ---------------------- | ------------------------------------------------------------- |
| `DOCKERHUB_USERNAME` | Docker Hub username.                                          |
| `DOCKERHUB_TOKEN`    | Docker Hub PAT with Public Repo Write (or Read/Write/Delete). |

**Organization variables:**

| Variable                | Purpose                                                                                                                                              |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `DOCKERHUB_NAMESPACE` | Namespace under which repos are created and images pushed, e.g.`pslcopilot`. Was a secret in the removed workflow; a variable is more appropriate. |

### 8.3 What worked

- Idempotent repo creation — 409/400 treated as "already exists."
- Two tags per publish: versioned + `:latest`.
- `docker/login-action@v3` for the login (maintained by Docker, does not persist credentials beyond the runner's Docker config).

### 8.4 Reasons the step was removed

Security:

1. `docker build --build-arg GH_TOKEN=${GH_TOKEN}` embeds the token in image layers; recoverable via `docker history <image>` and by any downstream puller. PR #13 fixed this for the local build with `--mount=type=secret,id=GH_TOKEN`; the Docker Hub push step never got the same treatment. Do not reinstate without the BuildKit-secret migration.
2. `docker pull ${DOCKERHUB_REPO}:latest` on the runner deploys whatever was most recently pushed. Pin to `${RULE_VERSION}` or an image digest.
3. The workflow POSTs the plain PAT to `https://hub.docker.com/v2/users/login` to obtain a JWT, then holds it in a shell variable. `set -x` or a log leak echoes it into the workflow log. Reuse `docker/login-action`'s credentials or move repo creation out of the workflow.
4. The Docker Hub PAT is scoped across the entire `DOCKERHUB_NAMESPACE`. Consider per-rule tokens or signed images (Cosign / Docker Content Trust).
5. `is_private: false` publishes rule logic publicly. Default to `is_private: true` and let tenants opt in.

Stability:

6. `rm -f package-lock.json` in the clone step (still present in the current `deploy.yml`) means `npm install` runs unpinned inside the image.
7. The JWT parse via `python3 -c "…json.load…"` fails silently on a non-JSON response; the follow-up `curl` gets a 401. The step only fails on unexpected repo-create HTTP status.
8. `docker pull` runs `:latest` without digest or signature verification.
9. No tag retention — Docker Hub storage grows linearly with publishes.

### 8.5 Reinstatement checklist

Before re-enabling:

- [ ] Migrate the Docker Hub `docker build` step to `--mount=type=secret,id=GH_TOKEN`.
- [ ] Deploy from a digest-pinned image (`${DOCKERHUB_REPO}@sha256:<digest>`), not `:latest`.
- [ ] Default new repos to `is_private: true`.
- [ ] Replace the manual `HUB_JWT` password-grant with the `docker/login-action` credentials, or move repo creation out of the workflow.
- [ ] Sign images (Cosign / DCT) and verify on pull.
- [ ] Add a tag retention policy.
- [ ] Reintroduce a `package-lock.json` for the rule-executer clone so builds are reproducible.
- [ ] Reduce the Docker Hub PAT scope; consider per-repo tokens.

### 8.6 Alternative: GHCR

`ghcr.io` reuses `TAZAMA_TOKEN`, inherits GitHub org access controls, and needs no separate PAT:

```yaml
- name: Log in to GHCR
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.TAZAMA_TOKEN }}

- name: Build, push, deploy
  run: |
    IMAGE="ghcr.io/$ORG/$RULE_NAME:$RULE_VERSION"
    docker build --secret id=GH_TOKEN,env=GH_TOKEN -t "$IMAGE" rule-executer-$RULE_NAME
    docker push "$IMAGE"
    DIGEST=$(docker inspect --format '{{index .RepoDigests 0}}' "$IMAGE")
    docker pull "$DIGEST"
    docker run -d --name "$RULE_NAME" <…env vars…> "$DIGEST"
  env:
    GH_TOKEN: ${{ secrets.TAZAMA_TOKEN }}
```

Sidesteps the JWT bootstrap, per-namespace PAT scope, and public-by-default issues. Still needs the BuildKit-secret and digest-pinning items from §8.5.

---

## 9. Secrets and variables reference

### 9.1 GitHub org secrets

| Secret                  | Consumed by                                            | Required?              |
| ----------------------- | ------------------------------------------------------ | ---------------------- |
| `TAZAMA_TOKEN`        | all four workflows                                     | Yes                    |
| `DOCKERHUB_USERNAME`  | `deploy.yml` Docker Hub steps                        | Only if §8 reinstated |
| `DOCKERHUB_TOKEN`     | `deploy.yml` Docker Hub steps                        | Only if §8 reinstated |
| `DOCKERHUB_NAMESPACE` | `deploy.yml` Docker Hub steps (better as a variable) | Only if §8 reinstated |

### 9.2 GitHub org variables

| Variable         | Consumed by                | Default                                |
| ---------------- | -------------------------- | -------------------------------------- |
| `RUNNER_LABEL` | `deploy.yml` `runs-on` | `server-18` (UAT: `tazama-uat`)    |
| `SERVER_IP`    | `deploy.yml` env         | `10.10.80.18` (UAT: `10.10.80.37`) |

### 9.3 `rule-studio-devtestops/.env`

See §4.1. Startup-required: `NODE_ENV`, `FUNCTION_NAME`, `PORT`, `HOST`, `GITHUB_TOKEN`, `ENCRYPTION_KEY`, `ENCRYPTION_IV`, `GITHUB_API_URL`, `GITHUB_TEMPLATE_OWNER`, `GITHUB_TEMPLATE_REPO`, `GITHUB_BRANCH`, `GITHUB_TEST_REPORT_PATH`, `GITHUB_ORG_NAME`, `GITHUB_INIT_BRANCH`.

### 9.4 `rule-studio/backend/.env`

See §6.1. Startup-required: `NODE_ENV`, `FUNCTION_NAME`. Lazy-required: `CRYPTO_SECRET_KEY`, `TAZAMA_AUTH_URL`, `SMTP_FROM_EMAIL`. Notable defaults: `PORT`=3005, `REDIS_*`, `ADMIN_SERVICE_URL`, `DEMS_BASE_URL`, `DLH_URL`, `DOCKERHUB_NAMESPACE`.

### 9.5 `rule-studio/frontend/.env`

See §6.2. Needed for the app to function: `VITE_API_URL`, `VITE_NATS_API_URL`, `VITE_DEMS_ENDPOINT`, `VITE_ADMIN_ENDPOINT`, `VITE_CRYPTO_KEY`, `VITE_SANDBOX_API_URL`. Inlined at build time — rebuild to change.

### 9.6 Rule container runtime env

See §5.6. Set by `deploy.yml`. Debug with `docker inspect <rule-container>` on the runner.

---

## 10. Known issues

### 10.1 UAT vs prod workflow — remaining differences

An earlier revision of PR #13 had `deploy-to-uat.yml` on `--build-arg GH_TOKEN=…` while `deploy.yml` already used `--mount=type=secret,id=GH_TOKEN`. Commit `09e15c9 refactor: deploy to yat workflow made same` closed the gap; both workflows now use the same BuildKit-secret mount and the same `sed 's|RUN --mount=type=secret,id=GH_TOKEN,env=GH_TOKEN npm ci …|…|'` rewrite.

Remaining deltas on `feat-paysys-poc`:

- `deploy-to-uat.yml` triggers on `push: prod` only. No `workflow_dispatch`.
- `RUNNER_LABEL` default: `tazama-uat` (UAT) vs `server-18` (prod).
- `SERVER_IP` default: `10.10.80.37` (UAT) vs `10.10.80.18` (prod).
- `RAW_HISTORY_DATABASE_PASSWORD`: `postgres` (UAT) vs `unused` (prod, §10.9).

Override via `vars.RUNNER_LABEL` / `vars.SERVER_IP` and `secrets.POSTGRES_PASSWORD` instead of relying on the defaults.

### 10.2 `RULE_VERSION` hardcoded to `1.0.0` in `deploy.yml`

The `docker run` block sets `-e RULE_VERSION=1.0.0` regardless of what `publish.yml` produced. `$RULE_VERSION` is extracted correctly earlier in the workflow but not used here. Result: the container's NATS subject is always `sub-rule-<name>@1.0.0`. Fix: `-e RULE_VERSION=$RULE_VERSION`.

### 10.3 `SERVER_IP` / `RUNNER_LABEL` defaults have moved between PR revisions

Earlier PR #13 iterations defaulted to `server-35` / `10.10.80.35`; current HEAD is `server-18` / `10.10.80.18`. Set `vars.RUNNER_LABEL` and `vars.SERVER_IP` explicitly so template updates cannot silently retarget you.

### 10.4 `GITHUB_DEFAULT_BRANCH` → `GITHUB_BRANCH` (PR #5)

Config validation is strict. When PR #5 merges, deployments with `GITHUB_DEFAULT_BRANCH=main` in `.env` will fail startup because the config now requires `GITHUB_BRANCH=main`. Roll out the `.env` change in lockstep with the code deploy.

### 10.5 Encrypted `GITHUB_TOKEN` key/IV mismatch

DevTestOps failing on startup with a decrypt error → `ENCRYPTION_KEY` is not 32 bytes or `ENCRYPTION_IV` is not 16. Verify with `Buffer.byteLength(process.env.ENCRYPTION_KEY, 'utf8')`. See §3.3.

### 10.6 PAT handling in the bootstrap flow (resolved)

An earlier revision of PR #5 cloned with `https://x-access-token:<TOKEN>@github.com/…`, which would have written the token to `<tempDir>/.git/config`. Current HEAD (commits `660e684`, `32cc302`) uses `git -c http.extraheader=Authorization: basic <base64>` on `clone` and `push` with a clean URL, so the token is never persisted. `fs.rm(tempDir, { recursive: true, force: true })` in the `finally` cleans up either way.

### 10.7 rule-executer branch: `feat-paysys` → `dev`

Both `deploy.yml` and `deploy-to-uat.yml` clone `rule-executer -b dev`. If your fork uses a different branch, update the `git clone` line. The workflow's `sed` patch expects the BuildKit-secret Dockerfile (`RUN --mount=type=secret,id=GH_TOKEN,env=GH_TOKEN npm ci --ignore-scripts`); older Dockerfiles will not match.

### 10.8 npm publish scope collisions

`publish.yml` publishes as `@<github.repository_owner>/<repo-name>`. Renaming the org (e.g. `psl-copilot` → `paysys`) republishes the same rule under a different scope; installers need updating. Pick one org name upfront.

### 10.9 `RAW_HISTORY_DATABASE_PASSWORD=unused` in `deploy.yml`

The workflow sets the literal string `unused`, implying `trust`/`peer` auth on the Postgres side. Not suitable for production. Read from `${{ secrets.POSTGRES_PASSWORD }}` per environment.

### 10.10 No rollback in `deploy.yml`

`docker stop $RULE_NAME || true; docker rm $RULE_NAME || true; docker run -d --name $RULE_NAME …`. If the new container fails to start, the old one is already gone. Add a `docker inspect` health check post-`docker run` and roll back if unhealthy.

### 10.11 NATS subject mismatch (PR #132)

Container subscribes to `sub-rule-<name>@<version>`; UI publishes to `sub-<rule_config_id>`. Simulation will time out unless `rule_config_id` is already `rule-<name>@<version>`. See §7.

---

## 11. Smoke test

1. **Bootstrap** — create a rule in the UI. New repo appears at `<GITHUB_ORG_NAME>/<ruleId>` with template contents on `staging`.
2. **Populate** — edit the rule in the UI and save. `src/rule.ts` and `__tests__/unit/rule.test.ts` on `staging` update.
3. **Unit tests** — `unit-test.yml` runs on push, succeeds; HTML report committed under `${GITHUB_TEST_REPORT_PATH}`.
4. **Promote** — promote `staging` → `dev` in the UI. `dev` on GitHub now matches `staging`.
5. **Publish** — `publish.yml` runs on push to `dev` and publishes `@<org>/<ruleId>@<version>` to `npm.pkg.github.com`.
6. **Deploy** — `deploy.yml` runs after publish (or via dispatch), lands on the runner with matching `RUNNER_LABEL`, succeeds. `docker ps | grep <ruleId>` on the runner shows the container.
7. **Simulate** — run a read-only simulation in the Rule Editor. `docker logs -f <ruleId>` on the runner shows the payload received and processed; UI displays the result.
8. *(If §8 reinstated)* verify the image at `${DOCKERHUB_NAMESPACE}/<ruleId>:<version>` or `ghcr.io/<org>/<ruleId>:<version>`, digest matches.

If step 7 hangs, check §10.11 (NATS subject shape).

---

## 12. Troubleshooting

| Symptom                                  | First place to look                                                                                                                                                    |
| ---------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DevTestOps fails at startup              | `ENCRYPTION_KEY` / `ENCRYPTION_IV` byte length; encrypted `GITHUB_TOKEN` format. §3.3, §10.5.                                                                  |
| Bootstrap fails with`spawn git ENOENT` | `git` not installed in the DevTestOps runtime image. §4.2.                                                                                                          |
| Bootstrap succeeds but new repo is empty | Template branch doesn't match`GITHUB_BRANCH`, or `simple-git` failed after repo create (atomicity issue in [RSDTO-PR-5.md](../pull-requests/RSDTO-PR-5.md)). §4.1. |
| `npm ci` in `deploy.yml` returns 401 | `TAZAMA_TOKEN` scopes; BuildKit `--secret` syntax mismatch between the workflow and the rule-executer Dockerfile. §5.5, §10.7.                                   |
| Simulation times out                     | Subject mismatch — container subscribes to`sub-rule-<name>@<version>`, UI publishes to `sub-<rule_config_id>`. §7, §10.11.                                      |
| Container starts then exits              | Wrong`SERVER_URL`, `RAW_HISTORY_DATABASE_HOST`, etc. `docker logs <container>` on the runner. §5.6.                                                             |
| Wrong runner picks up the workflow       | `RUNNER_LABEL` unset; workflow falls back to its hardcoded default. §5.4, §10.3.                                                                                   |
| Docker image not on Docker Hub           | Expected — flow disabled. §8.                                                                                                                                        |
| Unit-test HTML report missing            | `GITHUB_TEST_REPORT_PATH` in DevTestOps; check `unit-test.yml` ran. §4.1.                                                                                         |

---

## Change log

- **2026-07-17** — Initial version. Written against `rule-studio-example#13` (branch `feat-paysys-poc`), `rule-studio#132` (branch `feat-paysys-fix-simulation`), `rule-studio-devtestops#5` (branch `fix/bootstrap`), and against the removed Docker Hub steps from commit `d1f4139` on `feat-paysys-poc`.
