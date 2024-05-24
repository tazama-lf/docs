# Data Models

Data Models in Tazama system are stored in the code and not in the Database/Datastore. Datastore simply provides data storage, and efficient CRUD functionalities. In other words, ArangoDB provides the ability to create/add records, update records, query/read records and delete records.

How the Data object is design is not stored in ArangoDB but rather the code base. Example: ISO20022 Quote or ISO20022 Transfer data model is stored in the code. This data design pattern is called ORM (Object-Relationship-Mapping).

In the code, the table / collection for ISO20022 is defined. All the columns and their data types as well as constraints are defined (example: Primary Key, Foreign Key, Nullable etc). Any validation functions for any of the columns is also defined in the code (example: Date needs to store the TimeZone, Transaction ID is only X characters long etc)

When the code that hosts the Data model is run, it provides the functionality to create, update or delete the data model in the Datastore. The data model in the code and its implementation in the Datastore is thus kept in sync.

### Recommended ORM

ORM for Tazama / ArangoDB: [https://www.npmjs.com/package/arangojs](https://www.npmjs.com/package/arangojs)

```typescript
<script src="https://cdnjs.cloudflare.com/ajax/libs/babel-polyfill/6.26.0/polyfill.js"></script>
<script src="https://unpkg.com/arangojs@7.0.0/web.js"></script>
```

#### Connecting to ArangoDB

[https://www.npmjs.com/package/arangojs](https://www.npmjs.com/package/arangojs)

```typescript
const { Database, aql } = require("arangojs");
```

[https://sequelize.org/master/manual/getting-started.html](https://sequelize.org/master/manual/getting-started.html)

```typescript
const { Sequelize } = require('sequelize');
const sequelize = new Sequelize('<connection\_string>') 
```

#### Example Code

```typescript
// TS: import { Database, aql } from "arangojs";
const { Database, aql } = require("arangojs");

const db = new Database();
const Pokemons = db.collection("my-pokemons");

async function main() {
  try {
    const pokemons = await db.query(aql\`
      FOR pokemon IN ${Pokemons}
      FILTER pokemon.type == "fire"
      RETURN pokemon
    \`);
    console.log("My pokemons, let me show you them:");
    for await (const pokemon of pokemons) {
      console.log(pokemon.name);
    }
  } catch (err) {
    console.error(err.message);
  }
}

main();
```

### ArangoJS

#### Installation

```bash
npm install --save arangojs
## - or -
yarn add arangojs
```

### Transaction based processing

```typescript
const collection = db.collection(collectionName);
const trx = db.transaction(transactionId);

// WARNING: This code will not work as intended!
await trx.step(async () => {
  await collection.save(doc1);
  await collection.save(doc2); // Not part of the transaction!
});

// INSTEAD: Always perform a single operation per step:
await trx.step(() => collection.save(doc1));
await trx.step(() => collection.save(doc2));
```

## Sequelize

The Sequelize models are [ES6 classes](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes). You can very easily add custom instance or class level methods.

#### Transactions

Sequelize supports the following types of transactions:

- Unmanaged - Manual commit and rollback
- Managed - Automatic commit and rollback

## Design Consideration

We should use raw queries. ArangoJS supports raw queries. We can write raw queries in a separate file so we separate code and sql/aql. Reasoning behind choosing raw queries:

1. Ability to switch Database choices (replace Arango)
2. Ability to switch Sequelize
3. Ability to switch framework (nodejs)
4. Ability to switch language implementation (Typescript)
5. Lack of support for advanced SQL (custom SQL specific to the chosen Database tool) or AQL (Arango Query Language)

Alternative ORM for Tazama: [https://sequelize.org/](https://sequelize.org/)

Sequelize will work for any DB (using the connection string).

Another Alternative to Sequelize (Orango For ArangoDB): Orango [https://github.com/roboncode/orango](https://github.com/roboncode/orango)
