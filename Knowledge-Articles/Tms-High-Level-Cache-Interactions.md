<!-- SPDX-License-Identifier: Apache-2.0 -->

# TMS - High Level (Cache) Interactions

## Pain001

![](../../images/high_level_pain001.png)

@startuml
|Retrieve or Rebuild Cache|
start
:Write Data Cache;
:Write Transaction History to Database;
:Write Entities and Account to Database;
:Save Transaction Relationship to Database;
:Send to CRSP;
stop
@enduml

## Pain013

![](../../images/High_Level_Pain013_cache_interactions.png)

@startuml
|Pain013|
start
:Check Cache;
if (Cache Hit?) then (yes)
  :Retrieve Pain.001 from Cache;
else (no)
  :Get Pain.001 from Database;
  :Cache Pain.001;
endif
:Insert TransactionHistory;
:Insert Creditor and Debtor Accounts;
:Save Transaction Relationship;
:Send to CRSP;
stop
@enduml

## Pacs008

![](../../images/high_level_cache_interactions_pacs008.png)

@startuml
|Insert Creditor and Debtor Accounts|
start
:Insert Creditor and Debtor Accounts;
if (Quoting Enabled?) then (yes)
  :Create Data Cache from Request;
  :|Add Entities to Database|
  : Add Creditor and Debtor Entities to Database;
  :Write Cache to Redis;
  :Add Creditor and Account Holders to Database;
else (no)
  :Add Creditor and Account Holders to CacheDB Service;
endif
:Save Transaction Relationship to Database;
:|Read Data Cache from Redis|
if (Cache Miss?) then (yes)
  :Rebuild Data Cache;
  :Cache to Redis;
else (no)
endif
:|Write Transaction History|
:Write Transaction History to Database;
:|Send to CRSP|
:Send to CRSP;
stop
@enduml

## Pacs002

![](../../images/high_level_pacs_002_cache_interactions.png)

@startuml
|Retrieve or Rebuild Cache|
start
:Check Redis Cache;
if (Cache hit?) then (yes)
  :Retrieve Data from Redis Cache;
else (no)
  :Rebuild Data Cache;
  :Write Data Cache to Redis;
endif
:Write Transaction History to Database;
:Get PACS008 from Storage;
:Save Transaction Relationship to Database;
:Send to CRSP;
stop
@enduml