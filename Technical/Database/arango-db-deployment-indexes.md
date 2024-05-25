<!-- SPDX-License-Identifier: Apache-2.0 -->

# Tazama Database Indexes

This document provides indexes that are to be created in the database deployment to improve query performance. The following content is grouped by databases (main heading), the collection (sub-heading), and the list of indexes along with their various properties (the contents of tables).

> [!NOTE]  
> Some indexes can contain multiple fields, in that case, the tables will represent them as `[field_one, field_two]`. 

For convenience, a [`Postman`](https://www.postman.com/) collection is [available](https://github.com/frmscoe/postman/blob/main/ArangoDB%20Setup.json) to automatically create these indexes. You would need to import this collection and in there, there are sub-collections representing databases, and each subcollection, you will find requests you can send to create the indexes listed below. If you prefer a more manual approach, this document will help you get setup.

## transactionHistory
#### transactionHistoryPacs002
| Name | Field(s) | Unique | Sparse | Type |
| ------ | ------ | -----  | ----- | ----- |
| OrgnlEndToEndId | `FIToFIPmtSts.TxInfAndSts.OrgnlEndToEndId` |`true` | `false`| `persistent` |

#### transactionHistoryPacs008
| Name | Field(s) | Unique | Sparse | Type |
| ------ | ------ | -----  | ----- | ----- |
| EndToEndId | `FIToFICstmrCdt.CdtTrfTxInf.PmtId.EndToEndId` | `true` | `false` | `persistent` |
| DbtrAcctId | `FIToFICstmrCdt.CdtTrfTxInf.DbtrAcct.Id.Othr.Id` | `false` | `false` | `persistent` |
| CdtrAcctId | `FIToFICstmrCdt.CdtTrfTxInf.CdtrAcct.Id.Othr.Id` | `false` | `false` | `persistent` |
| DbtrAcct_ID-TxTp | `[FIToFICstmrCdt.CdtTrfTxInf.DbtrAcct.Id.Othr.Id, TxTp]` | `false` | `false` | `persistent` |
| CreDtTm | `FIToFICstmrCdt.GrpHdr.CreDtTm` | `false` | `false` | `persistent` |

#### transactionHistoryPain001
| Name | Field(s) | Unique | Sparse | Type |
| ------ | ------ | -----  | ----- | ----- |
| EndToEndId | `CstmrCdtTrfInitn.PmtInf.CdtTrfTxInf.PmtId.EndToEndId` | `true` | `false` | `persistent` |
| DbtrAcct_ID-TxTp | `[CstmrCdtTrfInitn.PmtInf.DbtrAcct.Id.Othr.Id, TxTp]` | `false` | `false` | `persistent` |
| CreDtTm | `CstmrCdtTrfInitn.GrpHdr.CreDtTm` | `false` | `false` | `persistent` |
| CdtrAcctId | `CstmrCdtTrfInitn.PmtInf.CdtTrfTxInf.CdtrAcct.Id.Othr.Id` | `false` | `false` | `persistent` |
| DbtrAcctId | `CstmrCdtTrfInitn.PmtInf.DbtrAcct.Id.Othr.Id` | `false` | `false` | `persistent` |

#### transactionHistoryPain013
| Name | Field(s) | Unique | Sparse | Type |
| ------ | ------ | -----  | ----- | ----- |
| EndToEndId | `CdtrPmtActvtnReq.PmtInf.CdtTrfTxInf.PmtId.EndToEndId` | `true` | `false` | `persistent` |

## pseudonyms
#### transactionRelationship
| Name | Field(s) | Unique | Sparse | Type |
| ------ | ------ | -----  | ----- | ----- |
| EndToEndId-TxTp | `[EndToEndId, TxTp]` | `false` | `false`| `persistent` |
| CreDtTm | `CreDtTm` | `false` | `false`| `inverted` |


## Configuration
#### transactionConfiguration
| Name | Field(s) | Unique | Sparse | Type |
| ------ | ------ | -----  | ----- | ----- |
| id-cfg | `[id, cfg]` | `true` | `false`| `persistent` |

#### channelExpression
| Name | Field(s) | Unique | Sparse | Type |
| ------ | ------ | -----  | ----- | ----- |
| id-cfg | `[id, cfg]` | `true` | `false`| `persistent` |

#### configuration
| Name | Field(s) | Unique | Sparse | Type |
| ------ | ------ | -----  | ----- | ----- |
| id-cfg | `[id, cfg]` | `true` | `false`| `persistent` |

#### typologyExpression
| Name | Field(s) | Unique | Sparse | Type |
| ------ | ------ | -----  | ----- | ----- |
| id-cfg | `[id, cfg]` | `true` | `false`| `persistent` |
