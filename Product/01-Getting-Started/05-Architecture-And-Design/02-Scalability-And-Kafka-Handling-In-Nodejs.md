# Scalability and Kafka handling in NodeJS

Actio is being developed in NodeJS with Kafka, which brings some scalability issues.

taking in count we plan to do 35ms for transfer, in 1 second, one "pipe" (pipe being a list of all services [Rule Engines, Scoring engine, etc] required to process one transaction from start to finish) can process 1000 / 35 = 28 transactions in sequence (one-by-one). to be able to process 3000, we'll need 3000 / 28 = 107 pipes to run concurrently.

All the above math does NOT take into consideration that NodeJS is single-threaded, and each running instance of a container can hence only handle one transaction at a time. This makes us face both CPU and IO tasks. While [this isn't a problem for producers](https://stackoverflow.com/questions/61865459/how-to-implement-parallelism-in-kafka-using-nodejs-consumers#comment109423596_61865459) we face a constraint while reading from Kafka.

All Kafka clients will fetch messages as fast as possible, passing them to the handler, which needs to process the message. This can be done in a synchronized process, which will have to wait for the process to finish before passing the next fetched message. This is incredibly slow and not at all what we want. Trying to use an async method would eventually fill the event loop, causing a heap overflow.

The "solution" for this issue is to stop receiving Kafka messages in the applications, and let the event loop empty before taking more messages. Example can be [found here.](https://medium.com/walkme-engineering/managing-consumer-commits-and-back-pressure-with-node-js-and-kafka-in-production-cfd20c8120e3)

This will mean that the application will be inoperative during a short period of time. Which shouldn't be a problem since we can produce multiple instances of the services using Kubernetes replicas. However, we face another issue: All instances will be listening to all Kafka messages. In a HTTP service, Kubernetes takes cares of handling traffic and distributing it through the replicas. However, we're not sure if this would be the case with Kafka messages.  
This means we have multiple replicas listening to the same message doing the same job, which create a result that gets outsourced to Kafka and could probably create replicas of the same result.
