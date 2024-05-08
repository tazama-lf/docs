# Foxx Microservices

#### What are Foxx Microservices?

Foxx Microservice is a framework built in Arango Engine that uses V8 engine for executing vanilla javascript to have a javascript code running very close to data stored in Arango, Foxx microservices run directly within the database with native access to in-memory data.

#### How does it work?

Foxx services consist of JavaScript code running in the V8 JavaScript runtime embedded inside ArangoDB. Each service is mounted in each available V8 context (the number of contexts can be adjusted in the server configuration). Incoming requests are distributed across these contexts automatically.

If you’re coming from another JavaScript environment like Node.js this is similar to running multiple Node.js processes behind a load balancer: you should not rely on server-side state (other than the database itself) between different requests as there is no way of making sure consecutive requests will be handled in the same context.

Because the JavaScript code is running inside the database another difference is that all Foxx and ArangoDB APIs are purely synchronous and should be considered **blocking**. This is especially important for transactions, which in ArangoDB can execute arbitrary code but may have to lock entire collections (effectively preventing any data to be written) until the code has completed.

#### What are the limitations known?

Because Foxx services use the V8 JavaScript engine, the engine’s default memory limit of 512 MB is applied.

**Link** For more information from Arango documentation follow: [Foxx Microservices | ArangoDB Documentation](https://docs.arangodb.com/3.11/develop/foxx-microservices/)

### What are the use cases for Foxx Services in Tazama?

**Case 1:** Targeting a certain collection and getting a pre-scripted result from the endpoint of the service e.g. analytics, data (put, delete, post). This means the collection that ends up with the documents of the final result can be post-analyzed.

**Case 2:** Pre-build database structure from the service end-point, with the script of AQL database and collection can be built from a certain service’s endpoint.

**Case 3:** Pre-save queries and run them from different service’s endpoints, case of rules they tend to have one main part changing about them which is the query for getting records for a certain case the rule is covering, with the Foxx services the rules can get the results from these services optimizing the execution time of node application.

**Case 4**: With Event Listeners the end point of services can achieve real-time data reports like the total number of documents in a certain collection at a certain time
