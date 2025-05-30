# FAQ: Sidecar & Lumberjack

This FAQ addresses common issues when using the `event-sidecar` and `lumberjack`

---

### 1. Why am I not seeing logs in Elasticsearch?

**Possible Causes:**

* `ELASTIC=true` is not set. This variable controls whether lumberjack should forward logs to Elastic (as opposed to just `STDOUT`)
* `ELASTIC_HOST` is empty or incorrect.
* Elasticsearch is not reachable from Lumberjack.
* Authentication failed (check `ELASTIC_USERNAME` and `ELASTIC_PASSWORD`).

**How to Debug:**

* Set `STDOUT=true` to confirm logs are processed by Lumberjack.
* Check Elasticsearch logs to see if it is in a healthy state and ready to receive connections:

`curl http://localhost:9200` should return a 200 OK - assuming Elasticsearch is running on localhost.
---

### 2. Sidecar and Lumberjack are running, but Lumberjack is not receiving any logs

**Possible Causes:**

* `NATS_SERVER` is misconfigured between Sidecar and Lumberjack.
* The NATS server is not running or not listening on expected port
* `NATS_SUBJECT` mismatch between services.

**How to Debug:**

* Ensure network connectivity to the NATS server
* Ensure that the `event-sidecar` and `lumberjack` are connected to the same NATS server
* Check both processors are using the same subject - it is case-sensitive (`NATS_SUBJECT=Lumberjack`).

---

### 3. NATS connection errors in Sidecar or Lumberjack

**Possible Causes:**

* Invalid or unreachable `NATS_SERVER` address.
* Port conflict
* The NATS server is not running

**How to Debug:**

* Check if the NATS server is running
* Check if nothing else in your environment is occupying the port NATS is trying to use

---

### 4. Logs are printed but not saved in Elasticsearch

**Possible Causes:**

* `STDOUT=true` and `ELASTIC=false`
* Flush threshold (`ELASTIC_FLUSH_BYTES`) too high for low-volume logs.

**How to Debug:**

* Reduce `ELASTIC_FLUSH_BYTES` for testing.
* Ensure `ELASTIC=true` to opt into sending logs to elastic

---

### 5. I changed an env variable but it has no effect

**Possible Causes:**

* Container needs to be restarted to apply env changes.

**How to Debug:**

* Restart the container and inspect its environment to see the variables and their values

---

### 6. Logs are delayed or dropped

**Possible Causes:**

* High `ELASTIC_FLUSH_BYTES` value causing batching.
* Network issues with NATS or Elasticsearch.
* Backpressure from Elasticsearch.

**How to Debug:**

* Monitor NATS server throughput.
* Check Elasticsearch health.
* Reduce batching for testing.

---
### 6. I set NODE_ENV to dev in my processor but I don't see logs on the processor itself

**Possible Causes:**

* `SIDECAR_HOST` is set in your environment. Even if your NODE_ENV variable is set to dev, the logger treats the availability of this sidecar host as your opting in to sidecar logging

**How to Debug:**

* Remove `SIDECAR_HOST` from your environment or set it to an empty string
