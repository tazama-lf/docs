## Configure environment

| Variable | Purpose | Example
| ------ | ------ | ------ |
| `FUNCTION_NAME` | Denotes the type of application that is running. This is also used in logs to show the source of logs | `APP_1`
| `NODE_ENV` | Represents the environment the application is currently running in | `dev`
| `CACHETTL` | Duration in milliseconds until a cache key is expired |`5000`
| `MAX_CPU` | Max number of CPUs to use | `1`
| `APM_ACTIVE` | Enable Application Performance Monitoring through [Elastic](https://www.elastic.co/) | `false`
| `REDIS_DB` | [Redis](https://redis.io/) database | `0`
| `REDIS_AUTH` | [Redis](https://redis.io/) password | `01ARZ3Example`
| `REDIS_SERVERS` | [Redis](https://redis.io/) Host in `json` format | `[{"host":"redis", "port":6379}]`
| `REDIS_IS_CLUSTER` | A flag to indicate if [Redis] is served in cluster mode | `false`
| `SERVER_URL` | A URL where [NATS](https://nats.io) is served | `nats:4222`
| `STARTUP_TYPE` | Configure [NATS](https://nats.io) features | `nats`
| `CONSUMER_STREAM` | The [NATS](https://nats.io) subject that this application listens on | `CRSP`
| `PRODUCER_STREAM` | The [NATS](https://nats.io) subject(s) that this application sends messages to | `Rule901`
| `ACK_POLICY` | [NATS] Ack [policy](https://docs.nats.io/nats-concepts/jetstream/consumers#ackpolicy) | `Explicit`
| `PRODUCER_STORAGE` | [NATS] Producer [Storage](https://docs.nats.io/using-nats/developer/develop_jetstream/model_deep_dive#storage-overhead) | `File`
| `PRODUCER_RETENTION_POLICY` | [NATS] Producer Retention [Policy](https://docs.nats.io/using-nats/developer/develop_jetstream/model_deep_dive#stream-limits-retention-and-policy) | `Workqueue`
