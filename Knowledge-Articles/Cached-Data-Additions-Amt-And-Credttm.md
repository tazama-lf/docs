<!-- SPDX-License-Identifier: Apache-2.0 -->

# Cached Data Additions: Amt and CreDtTm

Some rule queries search the database for an associated Pacs008 message (or some specific fields there-in).

Because we previously had access to the entire Pacs008 message over at TMS, we can extract the fields we know we may need in the future, for the aforementioned rule queries and cache them for their use later on.

**Note: this change is only applied to Pacs008 messages, not Pain001**

For clarity, the fields we’re most interested in are `Amt` and `CreDtTm`,  
The proto file was updated to cater for these new additions:  

```typescript
message dataCache {
  string dbtrId = 1;
  string cdtrId = 2;
  string cdtrAcctId = 3;
  string dbtrAcctId = 4;
  Amt amt = 5; // addition
  string CreDtTm = 6; // addition
} 
```

Where `Amt` is reused from the Pacs008 definition.

This translates to this Typescript extract:

```typescript
export interface DataCache {
  dbtrId?: string;
  cdtrId?: string;
  dbtrAcctId?: string;
  cdtrAcctId?: string;
  evtId?: string;
  amt?: {
    Amt: number;
    Ccy: string;
  };
  CreDtTm?: string;
}
```

The rule queries needed to be modified, as we no longer need to lookup the Amt or CreDtTm. For example, a rule query that needed the Amt to calculate the rule outcome no longer needs to search the database for that transaction’s amount, but instead, the query will now accept an input parameter of the amount which comes from the cache.  
  
Implications:

- Rules will fail if this information is not cached.

An alternative implementation would have used a database lookup as a fallback, but as we are in control of the entire environment, we can guarantee that these fields will always be available in the cache. Another reason to consider is that we want to optimise for performance, with the cache implementation, our database is less busy and reading from memory is very much faster than reading from disk. While it’s generally up to the system architecture, reading from memory will usually be constant time, whereas finding the associated Pacs008 message will likely be longer the more Pacs008 messages we have to go through.

![Blank diagram.png](../../images/10-Cached-Data-Additions-Amt-And-Credttm.png)
