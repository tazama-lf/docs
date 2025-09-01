# Environment Variables

## Overview

Rules and Processors currently follow an approach to environmental variables where each application contains it’s own local copy of environment variables that will be loaded one time into a config data class at startup. Application behavior is thus static and any desired changes to config will require a full restart of the application with new environmental variables provided.

## Environment variables encapsulation

The frms-coe-lib library enables Tazama services to seamlessly integrate with third-party resources, including ArangoDB, Redis, Elastic APM, and logging systems. Each resource connection is facilitated by specific environment variables required to establish and maintain secure, efficient connections. This design ensures that only essential environment variables are loaded and validated per request, avoiding unnecessary configuration and potential security risks associated with excessive environment exposure. The library includes a function for validating General Variables, with a parameter that accepts additional variables, allowing for processor-specific customization as needed.

### How It Works
1. **Resource-Specific Environment Variable Loading**:  
   When a Tazama service requests a connection to a specific resource, `frms-coe-lib` identifies and loads only the environment variables required for that resource. This resource-based encapsulation prevents loading unrelated environment variables, adhering to the principle of minimal configuration.

2. **Validation Process**:  
   Upon loading the environment variables, `frms-coe-lib` validates each variable against the specific requirements of the requested resource. This includes checking for presence, type, and format as needed by the resource configuration standards.

3. **Connection Establishment**:  
   After validation, the library proceeds with establishing the connection to the resource using the validated environment variables, ensuring a safe and stable interaction with the third-party service.


### Benefits
- **Enhanced Security**: Limits exposure to only required environment variables.
- **Efficiency**: Reduces memory footprint and potential configuration errors by only loading essential variables.
- **Simplified Configuration**: Allows service developers to focus on only the environment variables necessary for their specific resource connections.

### Example
To connect a Tazama service to Redis, `frms-coe-lib` will only load and validate the Redis-specific environment variables (e.g., `REDIS_HOST`, `REDIS_PORT`, `REDIS_AUTH`). If these variables are properly configured, the library establishes the connection; otherwise, an error log is generated, detailing any missing or invalid variables.

# Current Environmental Variables (Tazama 2.0 Release)
Each service in Tazama utilizes specific resources to accomplish its tasks, and each resource requires distinct environment variables tailored to the service's needs below is a list for each service and environment variables being used



### Additional Variables
| TMS       | event-director | rule-executor | typology-processor | TADP                         |
|-----------|----------------|---------------|--------------------|------------------------------|
| PORT      | REST_PORT      |               |                    |                              |
| CACHE_TTL | CACHETTL       | CACHE_TTL     | CACHE_TTL          |                              |
| QUOTING   |                |               |                    |                              |
|           |                | RULE_NAME     |                    |                              |
|           |                | RULE_VERSION  |                    |                              |
|           |                |               | SUPPRESS_ALERTS    | SUPPRESS_ALERTS              |
|           |                |               |                    | NODE_TLS_REJECT_UNAUTHORIZED |


### General Variables

| TMS           | event-director | rule-executor | typology-processor | TADP          |
|---------------|----------------|---------------|--------------------|---------------|
| FUNCTION_NAME | FUNCTION_NAME  | FUNCTION_NAME | FUNCTION_NAME      | FUNCTION_NAME |
| NODE_ENV      | NODE_ENV       | NODE_ENV      | NODE_ENV           | NODE_ENV      |
| MAX_CPU       | MAX_CPU        |               | MAX_CPU            | MAX_CPU       |


### Nats Variables

| TMS             | event-director            | rule-executor             | typology-processor    | TADP         |
|-----------------|---------------------------|---------------------------|-----------------------|--------------|
| SERVER_URL      | SERVER_URL                | SERVER_URL                | SERVER_URL            | SERVER_URL   |
| PRODUCER_STREAM | PRODUCER_STREAM           | PRODUCER_STREAM           | PRODUCER_STREAM       |              |
| STARTUP_TYPE    | STARTUP_TYPE              | STARTUP_TYPE              | STARTUP_TYPE          | STARTUP_TYPE |
|                 | CONSUMER_STREAM           | CONSUMER_STREAM           |                       |              |
|                 | STREAM_SUBJECT            | STREAM_SUBJECT            |                       |              |
|                 | ACK_POLICY                | ACK_POLICY                |                       |              |
|                 | PRODUCER_STORAGE          | PRODUCER_STORAGE          |                       |              |
|                 | PRODUCER_RETENTION_POLICY | PRODUCER_RETENTION_POLICY |                       |              |
|                 |                           |                           | INTERDICTION_PRODUCER |              |


### Cache Variables (Redis or NodeCache)

| TMS                       | event-director            | rule-executer       | typology-processor        | TADP                      |
|---------------------------|---------------------------|---------------------|---------------------------|---------------------------|
| REDIS_DB                  | REDIS_DB                  |                     | REDIS_DB                  | REDIS_DB                  |
| REDIS_AUTH                | REDIS_AUTH                |                     | REDIS_AUTH                | REDIS_AUTH                |
| REDIS_SERVERS             | REDIS_SERVERS             |                     | REDIS_SERVERS             | REDIS_SERVERS             |
| REDIS_IS_CLUSTER          | REDIS_IS_CLUSTER          |                     | REDIS_IS_CLUSTER          | REDIS_IS_CLUSTER          |
|                           | LOCAL_CACHE_ENABLED       | LOCAL_CACHE_ENABLED | LOCAL_CACHE_ENABLED       | LOCAL_CACHETTL            |
|                           | LOCAL_CACHETTL            | LOCAL_CACHETTL      | LOCAL_CACHETTL            | LOCAL_CACHETTL            |
| DISTRIBUTED_CACHETTL      | DISTRIBUTED_CACHETTL      |                     | DISTRIBUTED_CACHETTL      | DISTRIBUTED_CACHETTL      |
| DISTRIBUTED_CACHE_ENABLED | DISTRIBUTED_CACHE_ENABLED |                     | DISTRIBUTED_CACHE_ENABLED | DISTRIBUTED_CACHE_ENABLED |


### Database Variables (PostgreSQL)

| TMS                              | event-director                   | rule-executer                    | typology-processor               | TADP                             |
|----------------------------------|----------------------------------|----------------------------------|----------------------------------|----------------------------------|
| RAW_HISTORY_DATABASE             |                                  | RAW_HISTORY_DATABASE             |                                  |                                  |
| RAW_HISTORY_DATABASE_HOST        |                                  | RAW_HISTORY_DATABASE_HOST        |                                  |                                  |
| RAW_HISTORY_DATABASE_PORT        |                                  | RAW_HISTORY_DATABASE_PORT        |                                  |                                  |
| RAW_HISTORY_DATABASE_USER        |                                  | RAW_HISTORY_DATABASE_USER        |                                  |                                  |
| RAW_HISTORY_DATABASE_PASSWORD    |                                  | RAW_HISTORY_DATABASE_PASSWORD    |                                  |                                  |
| RAW_HISTORY_DATABASE_CERT_PATH   |                                  | RAW_HISTORY_DATABASE_CERT_PATH   |                                  |                                  |
| EVENT_HISTORY_DATABASE           |                                  | EVENT_HISTORY_DATABASE           |                                  |                                  |
| EVENT_HISTORY_DATABASE_HOST      |                                  | EVENT_HISTORY_DATABASE_HOST      |                                  |                                  |
| EVENT_HISTORY_DATABASE_PORT      |                                  | EVENT_HISTORY_DATABASE_PORT      |                                  |                                  |
| EVENT_HISTORY_DATABASE_USER      |                                  | EVENT_HISTORY_DATABASE_USER      |                                  |                                  |
| EVENT_HISTORY_DATABASE_PASSWORD  |                                  | EVENT_HISTORY_DATABASE_PASSWORD  |                                  |                                  |
| EVENT_HISTORY_DATABASE_CERT_PATH |                                  | EVENT_HISTORY_DATABASE_CERT_PATH |                                  |                                  |
|                                  | CONFIGURATION_DATABASE           | CONFIGURATION_DATABASE           | CONFIGURATION_DATABASE           | CONFIGURATION_DATABASE           |
|                                  | CONFIGURATION_DATABASE_HOST      | CONFIGURATION_DATABASE_HOST      | CONFIGURATION_DATABASE_HOST      | CONFIGURATION_DATABASE_HOST      |
|                                  | CONFIGURATION_DATABASE_PORT      | CONFIGURATION_DATABASE_PORT      | CONFIGURATION_DATABASE_PORT      | CONFIGURATION_DATABASE_PORT      |
|                                  | CONFIGURATION_DATABASE_USER      | CONFIGURATION_DATABASE_USER      | CONFIGURATION_DATABASE_USER      | CONFIGURATION_DATABASE_USER      |
|                                  | CONFIGURATION_DATABASE_PASSWORD  | CONFIGURATION_DATABASE_PASSWORD  | CONFIGURATION_DATABASE_PASSWORD  | CONFIGURATION_DATABASE_PASSWORD  |
|                                  | CONFIGURATION_DATABASE_CERT_PATH | CONFIGURATION_DATABASE_CERT_PATH | CONFIGURATION_DATABASE_CERT_PATH | CONFIGURATION_DATABASE_CERT_PATH |
|                                  |                                  |                                  |                                  | EVALUATION_DATABASE              |
|                                  |                                  |                                  |                                  | EVALUATION_DATABASE_HOST         |
|                                  |                                  |                                  |                                  | EVALUATION_DATABASE_PORT         |
|                                  |                                  |                                  |                                  | EVALUATION_DATABASE_USER         |
|                                  |                                  |                                  |                                  | EVALUATION_DATABASE_PASSWORD     |
|                                  |                                  |                                  |                                  | EVALUATION_DATABASE_CERT_PATH    |


### Elastic Variables

| TMS              | event-director   | rule-executer    | typology-processor |            |
|------------------|------------------|------------------|--------------------|------------|
| APM_ACTIVE       | APM_ACTIVE       | APM_ACTIVE       | APM_ACTIVE         | APM_ACTIVE |
| APM_SERVICE_NAME |                  |                  | APM_SERVICE_NAME   |            |
| APM_URL          | APM_URL          | APM_URL          | APM_URL            | APM_URL    |
| APM_SECRET_TOKEN | APM_SECRET_TOKEN | APM_SECRET_TOKEN | APM_SECRET_TOKEN   | APM_SECRET |


### Logging Variables

| TMS           | event-director | rule-executer | typology-processor | TADP          |
|---------------|----------------|---------------|--------------------|---------------|
| LOGSTASH_HOST | LOGSTASH_HOST  | LOGSTASH_HOST | LOGSTASH_HOST      | LOGSTASH_HOST |
| LOGSTASH_PORT | LOGSTASH_PORT  | LOGSTASH_PORT | LOGSTASH_PORT      | LOGSTASH_PORT |
| LOG_LEVEL     | LOG_LEVEL      | LOG_LEVEL     | LOG_LEVEL          | LOG_LEVEL     |
| SIDECAR_HOST  | SIDECAR_HOST   |               | SIDECAR_HOST       | SIDECAR_HOST  |
