<!-- SPDX-License-Identifier: Apache-2.0 -->

These environment variables are used across processors in the system. The specific variables related to a specific processor can be found in the `.env.template` file in each processor's repository.

| Variable | Purpose | Example
| ------ | ------ | ------ |
| `FUNCTION_NAME` | Denotes the type of application that is running. This is also used in logs to show the source of logs | `APP_1`
| `MAX_CPU` | Max number of CPUs to use | `1`
| `NODE_ENV` | Represents the environment the application is currently running in | `dev`
| `SUPPRESS_ALERTS` | Enable forwarding of alerts from transaction-transaction-aggregation-decisioning-processor to next subscribed processor | `false`
| `AUTHENTICATED` | Enable authentication request checks for a service's configured endpoints | `false`
| `QUOTING` | Enable submission of quoting transactions e.g `pain.001.001.11` and `pain.013.001.09`  | `false`
| `INTERDICTION_PRODUCER` | A NATS subscribed subject that should receive a message if interdiction occurred during typology evaluation  | `false`
| `PORT` | Number assigned to uniquely identify a connection endpoint and to direct data to a specific service | `3000`
| `DISTRIBUTED_CACHETTL` | Duration in milliseconds until a cache key is expired for distributed cache system e.g Redis, Valkey |`5000`
| `SIDECAR_HOST` | (Optional) configures logging through a [sidecar](https://github.com/frmscoe/event-sidecar) via gRPC | `http://localhost:5000`
| `APM_ACTIVE` | Enable Application Performance Monitoring through [Elastic](https://www.elastic.co/) | `false`
| `APM_SECRET_TOKEN` | Enable Application Performance Monitoring secret token | `secrethere`
| `LOCAL_CACHETTL` | Duration in milliseconds until a cache key is expired for local cache e.g NodeCache |`5000`
| `DISTRIBUTED_CACHE_ENABLED` | Switch to allow distributed cache use  |`false`
| `LOCAL_CACHE_ENABLED` | Switch to allow local cache use |`false`
| `REDIS_DB` | [Redis](https://redis.io/) database | `0`
| `REDIS_AUTH` | [Redis](https://redis.io/) password | `01ARZ3Example`
| `REDIS_SERVERS` | [Redis](https://redis.io/) Host in `json` format | `[{"host":"redis", "port":6379}]`
| `REDIS_IS_CLUSTER` | A flag to indicate if [Redis](https://redis.io) is served in cluster mode | `false`
| `SERVER_URL` | A URL where [NATS](https://nats.io) is served | `nats:4222`
| `STARTUP_TYPE` | Configure [NATS](https://nats.io) features | `nats`
| `CONSUMER_STREAM` | The [NATS](https://nats.io) subject that this application listens on | `APP_2`
| `PRODUCER_STREAM` | The [NATS](https://nats.io) subject(s) that this application sends messages to | `Rule901`
| `ACK_POLICY` | [NATS] Ack [policy](https://docs.nats.io/nats-concepts/jetstream/consumers#ackpolicy) | `Explicit`
| `PRODUCER_STORAGE` | [NATS] Producer [Storage](https://docs.nats.io/using-nats/developer/develop_jetstream/model_deep_dive#storage-overhead) | `File`
| `PRODUCER_RETENTION_POLICY` | [NATS] Producer Retention [Policy](https://docs.nats.io/using-nats/developer/develop_jetstream/model_deep_dive#stream-limits-retention-and-policy) | `Workqueue`
| `TRANSACTION_HISTORY_DATABASE_CERT_PATH` | Path to the certificate for the transaction history database | `certs/transaction_history_cert.pem` |
| `TRANSACTION_HISTORY_DATABASE` | Name of the transaction history database | `transactionHistory` |
| `TRANSACTION_HISTORY_DATABASE_USER` | Username for accessing the transaction history database | `root` |
| `TRANSACTION_HISTORY_DATABASE_PASSWORD` | Password for accessing the transaction history database | `password123` |
| `TRANSACTION_HISTORY_DATABASE_URL` | URL for accessing the transaction history database | `http://localhost:8529` |
| `CONFIGURATION_DATABASE_CERT_PATH` | Path to the certificate for the configuration database | `certs/config_db_cert.pem` |
| `CONFIGURATION_DATABASE` | Name of the configuration database | `configuration` |
| `CONFIGURATION_DATABASE_USER` | Username for accessing the configuration database | `root` |
| `CONFIGURATION_DATABASE_URL` | URL for accessing the configuration database | `http://localhost:8529` |
| `CONFIGURATION_DATABASE_PASSWORD` | Password for accessing the configuration database | `configPass123` |
| `PSEUDONYMS_DATABASE_CERT_PATH` | Path to the certificate for the pseudonyms database | `certs/pseudonyms_db_cert.pem` |
| `PSEUDONYMS_DATABASE` | Name of the pseudonyms database | `pseudonyms` |
| `PSEUDONYMS_DATABASE_USER` | Username for accessing the pseudonyms database | `root` |
| `PSEUDONYMS_DATABASE_URL` | URL for accessing the pseudonyms database | `http://localhost:8529` |
| `PSEUDONYMS_DATABASE_PASSWORD` | Password for accessing the pseudonyms database | `pseudoPass456` |
| `EVALUATION_DATABASE_CERT_PATH` | Path to the certificate for the evaluation database | `certs/eval_db_cert.pem` |
| `EVALUATION_DATABASE` | Name of the evaluation database | `evaluationResults` |
| `EVALUATION_DATABASE_USER` | Username for accessing the pseudonyms database | `root` |
| `EVALUATION_DATABASE_URL` | URL for accessing the evaluation database | `http://localhost:8529` |
| `EVALUATION_DATABASE_PASSWORD` | Password for accessing the evaluation database | `evalPass456` |
