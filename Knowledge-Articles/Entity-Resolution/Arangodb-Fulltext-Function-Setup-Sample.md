<!-- SPDX-License-Identifier: Apache-2.0 -->

# ArangoDB FullText Function Setup & Sample

## Setup Analyzer

1. In Lens, connect to the Shell of the ArangoDB pod
2. Type `arangosh` in the shell and hit Enter - this will connect to ArangoSH
3. To connect to the correct DB, type  
`db.useDatabase("transactionHistory")`
4. Then import analyzers:  
`var analyzers = require("@arangodb/analyzers")`
1. Add a new analyzer:  
`analyzers.save("text_en_no_stem", "text", { locale: "en.utf-8", accent: false, case: "lower", stemming: false, stopwords: [] }, ["position", "frequency", "norm"])`

That's it! We've added the new analyzer!

The FullText Index (FTI) can be used to find words, or prefixes of words inside documents. In the function used to query a FTI, it will search for all the words exactly. See some samples below.

With the below dataset:

| Data                  |
| --------------------- |
| Johannes Petrus Foley |
| Johannes              |
| Petrus                |
| Foley                 |
| Johannes Petrus       |
| Johannes Foley        |
| Petrus Foley          |

The following queries will yield the following results:

### Search for “Foley”:

```bash
FOR i IN 
FULLTEXT(transactionHistory,"CstmrCdtTrfInitn.PmtInf.Dbtr","Foley",10)
RETURN i.CstmrCdtTrfInitn.PmtInf.Dbtr.Nm

```

```json
[
  "Foley",
  "Johannes Petrus Foley",
  "Johannes Foley",
  "Petrus Foley"
]
```
a
### Search for “Petrus”:

```bash
FOR i IN 
FULLTEXT(transactionHistory,"CstmrCdtTrfInitn.PmtInf.Dbtr","Petrus",10)
RETURN i.CstmrCdtTrfInitn.PmtInf.Dbtr.Nm
```

```json
[
  "Petrus",
  "Johannes Petrus Foley",
  "Johannes Petrus",
  "Petrus Foley"
]

```

###### Search for “Johannes Foley”:

```bash
FOR i IN 
FULLTEXT(transactionHistory,"CstmrCdtTrfInitn.PmtInf.Dbtr","Johannes Foley",10)
RETURN i.CstmrCdtTrfInitn.PmtInf.Dbtr.Nm
```

```json
[
  "Johannes Petrus Foley",
  "Johannes Foley"
]
```

### Search for “Johannes” or “Foley”:

```bash
FOR i IN 
FULLTEXT(transactionHistory,"CstmrCdtTrfInitn.PmtInf.Dbtr","Johannes,|Foley",10)
RETURN i.CstmrCdtTrfInitn.PmtInf.Dbtr.Nm
```

```json
[
  "Johannes",
  "Foley",
  "Johannes Petrus Foley",
  "Johannes Petrus",
  "Johannes Foley",
  "Petrus Foley"
]
```

## Conclusion

So we can see that each keyword supplied in the search function, needs to be in the result exactly in the above examples. The OR operator and others could also be applied, as per their documentation:  

> If multiple search words (or prefixes) are given, then by default the results will be AND-combined, meaning only the logical intersection of all searches will be returned. It is also possible to combine partial results with a logical OR, and with a logical NOT:
> 
> `* FULLTEXT(emails, "body", "+this,+text,+document")`  
> Will return all documents that contain all the mentioned words. Note: specifying the `+` symbols is optional here.
> 
> `* FULLTEXT(emails, "body", "banana,|apple")`  
> Will return all documents that contain either (or both) words *banana* or *apple*.
> 
> `* FULLTEXT(emails, "body", "banana,-apple")`  
> Will return all documents that contain the word *banana*, but do not contain the word *apple*.
> 
> `* FULLTEXT(emails, "body", "banana,pear,-cranberry")`  
> Will return all documents that contain both the words *banana* and *pear*, but do not contain the word *cranberry*.
> 
> [Fulltext Functions in AQL](https://www.arangodb.com/docs/stable/aql/functions-fulltext.html)
