# Tazama Database Indexes
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
