# ArangoDB client side benchmarking

Launched an investigation to determine whether or not additional connection pooling was needed to get more out of the ArangoJS driver. As well as determining if we are following the best approach from the ArangoJS node library and or alternatives.

One way to determine performance loss is to run comparisons between different protocols and with different connection settings. This may also uncover some other potential optimizations.

Tests were then set up as follow:

> Server
>  
> - Will host ArangoDB with out of the box features as we are only interested in client side optimizations in this test.
> - On same network as client
> - 200'000 database records inserted to simulate closer to real world environment conditions

> Client
>  
> - Will run node client with arangojs library (v8.3.0) and axios for HTTP
> - Configurable Iterations, and connection config
> - Tests run the following query for each iteration
>  
> `FOR doc IN transactionRelationship FILTER doc.EndToEndId == ${endToEndId} RETURN doc`
>  
> ${endToEndId} is a `crypto.randomUUID()`
> *query caching will be disabled to ensure consistency in testing*
> - Time will only capture the duration of the queries and not include setup/startup time

Below are the results of 3 runs per iteration averaged.

| **Connection Type** | **Connection Options** | **Iterations** | **Time (milliseconds)** |
| --- | --- | --- | --- |
| ArangoJS | Default | 500 | 5146 |
| ArangoJS | maxSockets: 10 | 500 | 1651 |
| ArangoJS | maxSockets: 100 | 500 | 1108 |
| HTTP | Default | 500 | 1277 |
|     |     |     |     |
| ArangoJS | Default | 1000 | 10008 |
| ArangoJS | maxSockets: 10 | 1000 | 3235 |
| ArangoJS | maxSockets: 100 | 1000 | 2179 |
| HTTP | Default | 1000 | 2466 |
|     |     |     |     |
| ArangoJS | Default | 5000 | 49430 |
| ArangoJS | maxSockets: 10 | 5000 | 16210 |
| ArangoJS | maxSockets: 100 | 5000 | 10640 |
| HTTP | Default | 5000 | **DNF** |
|     |     |     |     |
| ArangoJS | Default | 10000 | 99647 |
| ArangoJS | maxSockets: 10 | 10000 | 32282 |
| ArangoJS | maxSockets: 100 | 10000 | 21310 |
| HTTP | Default | 10000 | **DNF** |

Notes:

DNF = did not finish; queue fill from server side

More sockets add additional CPU load especially on the SERVER

### Conclusion

The ArangoJS library does indeed have it’s own connection pooling but ensuring we explicitly set the connection options would allow parallel execution and thus faster response times.

The following connection options are recommended according to ArangoJS spec with the following advice

“When using arangojs in a cluster with load balancing, you may need to adjust the value of agentOptions.maxSockets to accommodate the number of transactions you need to be able to run in parallel. The default value is likely to be too low for most cluster scenarios involving frequent streaming transactions.

Note: When using a high value for agentOptions.maxSockets you may have to adjust the maximum number of threads in the ArangoDB configuration using the server.maximal-threads option to support larger numbers of concurrent transactions on the server side.”

server.maximal-threads [https://www.arangodb.com/docs/stable/programs-arangod-options.html#--servermaximal-threads](https://www.arangodb.com/docs/stable/programs-arangod-options.html#--servermaximal-threads)

```
agentOptions: {
      keepAlive: true,
      maxSockets: max(32, 2 \* available server cores),
      // so twice the number of Server CPU cores, but at least 32 threads 
    }
```

Further Optimizations - Take a look at ArangoJS Connection Config [https://arangodb.github.io/arangojs/8.3.1/types/connection.Config.html](https://arangodb.github.io/arangojs/8.3.1/types/connection.Config.html)

For settings such as `LoadBalancingStrategy: "NONE" | "ROUND_ROBIN" | "ONE_RANDOM"` which target multiple ArangoDB URLs
