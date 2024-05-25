<!-- SPDX-License-Identifier: Apache-2.0 -->

# Encryption at rest database decision

As we need to secure private personal data from users, we should decide on a database and model on data encryption at rest.

## Database encryption offerings

So far we’ve had data stored in **ArangoDB**, but the database only allows us to encrypt the data in the Enterprise version, which is a total blocker to use with the standalone Tazama project.

Similarly to ArangoDB, **MongoDB** also only allows to use encryption at rest using the enterprise version. We can add on top of it, that it uses a a mix of licenses that are not Apache-2 compliant.

A good Apache 2 Alternative for these databases is **Cassandra**, which is developed by Apache. Which allows us to use no-sql data (which goes pretty well with our data structures). The issue with Cassandra is that it only allows for encryption at rest on the enterprise version.

So far, a good alternative that allows for encryption is **PostgreSQL**. Postgres allows [Transparent Data Encryption](https://wiki.postgresql.org/wiki/Transparent_Data_Encryption) which will do the job. Postgres however, uses it’s own [License](https://www.postgresql.org/about/licence/) that is similar to the Apache 2 license. However, it’s fully relational so we’ll need to decide on how to store data on it.

## Client encryption

Client encryption means the data gets encrypted before being inserted in the database and gets decrypted when pulled out. This may cause some issues when operating certaing queries that the database won’t be able to solve since the data will be decrypted only when it reaches the client. Ideally, we should be able to encrypt the data at rest and decrypt it when it reaches the database so it can operate on it. This is something that PostgreSQL TDE model allows out of the box.

## Volume encryption

A similar approach to TDE is to encrypt the volume which holds the data. This way the data stored is encrypted and decrypted at buffer when it reaches the database. This is a common practice and should allow us to use a database that doesn’t provide encryption at rest by default. However, since we use kubernetes pods to run our database, we should investigate on volume encryption if we decide to take this route.
