# Creating Postman Tests

- [Creating Postman Tests](#creating-postman-tests)
  - [Overview](#overview)
  - [Repository](#repository)
  - [Debug](#debug)
    - [Rule Scenario Debugging](#rule-scenario-debugging)

## Overview

Postman tests are created to test to functionality of the different rules that are developed. Tests confirm that your API is working as expected, that integrations between services are functioning reliably, and that any changes haven't broken existing functionality. You can write test scripts for your Postman API requests in JavaScript. You can also use test code to aid the debugging process when something goes wrong with your API project. For example, you might write a test to validate your API's error handling by sending a request with incomplete data or incorrect parameters.

## Repository

[https://github.com/frmscoe/postman](https://github.com/frmscoe/postman)

## Debug

### Rule Scenario Debugging

**Checkout and host a rule from github** [https://github.com/frmscoe](https://github.com/frmscoe)

Populate the .env with the same environment as Arango in postman.  

**Get the postman test suite on github with it’s rule scenarios** [https://github.com/frmscoe/postman](https://github.com/frmscoe/postman)

Import the .json into postman  

**Set up environmental variables in postman for the following:**

1. arangoUrl
2. arangoUsername
3. arangoPassword
4. arangoToken
5. TMSversion
6. version
7. ofUrl  
  
**Generating a database auth token saved to arangoToken variable**

```http
POST {{arangoUrl}}\_open/auth
{
  "username": "{{arangoUsername}}",
  "password": "{{arangoPassword}}"
}
```

**In-flight rules for postman**

In console when sending requests ensure all communication responses are of code 2XX  
Ensure all tests pass on every scenario  
Ensure request response body is valid json and contains the property `"message": "Result for Rule XXX@X.X.X is true/false"`  

Each rule outcome scenario logic is laid out here  [AM-752](https://frmscoe.atlassian.net/browse/AM-752) - Getting issue details... STATUS

![](../Images/image-20230516-093241.png)

And their scenario information can be found at the bottom of a specific rules subtask

![](../Images/image-20230516-093501.png)

**Updated pre-request scripts in postman reflect latest changes to collection structure for transactionHistory**

The following template can be used to update `pm.sendRequest` which target `_db/transactionHistory` that contain the updated fields

```sql
// pacs.008
query:
  `FOR transaction IN ${JSON.stringify(pacs008Transactions)}
  INSERT {
    _key: "xxx" || transaction.key,
    TxTp: transaction.TxTp,
    FIToFICstmrCdt: transaction.FIToFICstmrCdt,
    } INTO transactionHistoryPacs008
  OPTIONS { overwrite: true }`

// pain.001
query:
  `FOR transaction IN ${JSON.stringify(pain001Transactions)}     INSERT {
      _key: "xxx" || transaction.key,
      TxTp: transaction.TxTp,
      CstmrCdtTrfInitn: transaction.CstmrCdtTrfInitn,
      } INTO transactionHistoryPain001
    OPTIONS { overwrite: true }`

// pain.013
query:
  `FOR transaction IN ${JSON.stringify(pain013Transactions)}     INSERT {
      _key: "xxx" || transaction.key,
      TxTp: transaction.TxTp,
      CdtrPmtActvtnReq: transaction.CdtrPmtActvtnReq,
      } INTO transactionHistoryPain013
    OPTIONS { overwrite: true }`

// pacs.002
query:
  `FOR transaction IN ${JSON.stringify(pacs002Transactions)}     INSERT {
      _key: "xxx" || transaction.key,
      TxTp: transaction.TxTp,
      FIToFIPmtSts: transaction.FIToFIPmtSts,
      } INTO transactionHistoryPacs002
    OPTIONS { overwrite: true }\`  
```

**Helpful insights**

Use arango queries along with debug data from the rule break points (remember that cleanup happens after results are returned to postman so it doesn’t persist)

Monitor the console in postman to inspect the request body going to ArangoDB  

**Post-flight rules for postman**

Ensure that the collections referenced in seeding the database in your pre-request scripts (`INSERT` queries) are also referenced in the functions that remove seed data.
