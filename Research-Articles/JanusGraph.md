# JanusGraph

## Guides

[https://www.npmjs.com/package/gremlin](https://www.npmjs.com/package/gremlin)  
[https://tinkerpop.apache.org/docs/current/reference/#io-step](https://tinkerpop.apache.org/docs/current/reference/#io-step)

## Installation

```bash
docker run --name jg-cassandra -d -e CASSANDRA\_START\_RPC=true -p 9160:9160 -p 9042:9042 -p 7199:7199 -p 7001:7001 -p 7000:7000 cassandra:latest
docker run --name janusgraph-default -e JAVA\_OPTIONS='-Xmx1024m' -p 8182:8182 janusgraph/janusgraph
# Do this one ONLY for debugging - this just spins up a Gremlin shell for you. 
docker run --link janusgraph-default --link jg-cassandra:cassandradb -e GREMLIN\_REMOTE\_HOSTS=janusgraph -it janusgraph/janusgraph ./bin/gremlin.sh

# In console that pops up, you can run this to create a graph on the Cassandra DB
graph = JanusGraphFactory.build().
  set("storage.backend", "cql").
  set("storage.hostname", "jg-cassandra").
  open();
```

## Sample data

```janusgraph
g.addV('User').property('name', 'John').property('age', '30').as('a').
  addV('User').property('name', 'Francois').property('age', '31').as('b').
  addV('User').property('name', 'Francois').property('age', '31').as('e').
  addV('User').property('name', 'Sean').property('age', '32').as('c').
  addV('User').property('name', 'Ricardo').property('age', '33').as('d').
  addE('Pays').from('a').to('b').addE('Pays').
  from('b').to('c').addE('Pays').
  from('b').to('e').addE('Pays').from('c').
  to('d').addE('Pays').from('d').to('a')
```

## Queries

Get Vertex self-referencing itself within x (change the 3 to whatever number) levels:

```janusgraph
g.V().as("a").repeat(out().simplePath()).times(3).where(out().as("a")).path().dedup().by(unfold().order().by(id).dedup().fold())
g.V(6652128).repeat(out().simplePath()).until(hasId(12432)).path().count(local)
```

## Code

A [NodeJS application](https://github.com/johanfol/JanusGraph) was written to communicate with above JanusGraph server with a CassandraDB backend.

## Helpful links

[https://gremlify.com/nw2kqz7ehkj](https://gremlify.com/nw2kqz7ehkj)  
[https://dkuppitz.github.io/gremlin-cheat-sheet/101.html](https://dkuppitz.github.io/gremlin-cheat-sheet/101.html)  
[https://dkuppitz.github.io/gremlin-cheat-sheet/102.html](https://dkuppitz.github.io/gremlin-cheat-sheet/102.html)  
[https://tinkerpop.apache.org/docs/current/recipes/#cycle-detection](https://tinkerpop.apache.org/docs/current/recipes/#cycle-detection)  
[https://tinkerpop.apache.org/docs/current/reference/#until-step](https://tinkerpop.apache.org/docs/current/reference/#until-step)

## Problems

1. Support - googling any errors is not very helpful
2. Setup - following the tutorials alone doesn’t necessarily get you there - lots of gaps to be filled
3. Bulk Uploading data - we have to [build graphson/graphml](https://github.com/johanfol/ConvertCSVToGraphML) files to be able to bulk upload data
4. Tinkerpop server (server translating Gremlin to CassandraQL) difficult to communicate with from NodeJS, and not much support. Focus seems to be heavy on Java implementations.
5. When uploading transaction data, the Tinkerpop server gets many unexplained issues (deadlocks, transaction locks, etc) - that causes you to have to restart the process - which is not ideal.
