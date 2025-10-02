<!-- SPDX-License-Identifier: Apache-2.0 -->

# Tazama Database Indexes

This document provides indexes that are to be created in the database deployment to improve query performance. The following content is grouped by databases (main heading), the table (sub-heading), and the list of indexes along with their various properties (the contents of tables).

> [!NOTE]  
> Some indexes can contain multiple fields, in that case, the tables will represent them as `[field_one, field_two]`. 

Indexes are created during initialization of Tazama from all supported deployments e.g. Full-Stack-Docker, Helm Charts

## raw_history
#### pacs002
| Name | Field(s) |
| ------ | ------ | 
| idx_pacs002_msg_id | `messageid` |
| idx_pacs002_end_to_end_id | `endtoendid` | 

#### pacs008
| Name | Field(s) |
| ------ | ------ | 
| idx_pacs008_msg_id | `messageid` | 
| idx_pacs008_end_to_end_id | `endtoendid` | 
| idx_pacs008_dbtr_acct_id | `debtoraccountid` |
| idx_pacs008_cdtr_acct_id | `creditoraccountid` |
| idx_pacs008_credttm | `credttm` |

#### pain001
| Name | Field(s) |
| ------ | ------ | 
| EndToEndId | `CstmrCdtTrfInitn.PmtInf.CdtTrfTxInf.PmtId.EndToEndId` |
| DbtrAcct_ID-TxTp | `[CstmrCdtTrfInitn.PmtInf.DbtrAcct.Id.Othr.Id, TxTp]` |
| CreDtTm | `CstmrCdtTrfInitn.GrpHdr.CreDtTm` |
| CdtrAcctId | `CstmrCdtTrfInitn.PmtInf.CdtTrfTxInf.CdtrAcct.Id.Othr.Id` |
| DbtrAcctId | `CstmrCdtTrfInitn.PmtInf.DbtrAcct.Id.Othr.Id` |

#### pain013
| Name | Field(s) |
| ------ | ------ | 
| EndToEndId | `CdtrPmtActvtnReq.PmtInf.CdtTrfTxInf.PmtId.EndToEndId` | `true` | `false` | 

## event_history
#### transaction
| Name | Field(s) |
| ------ | ------ | 
| EndToEndId-TxTp | `[EndToEndId, TxTp]` | `false` | `false`| 
| CreDtTm | `CreDtTm` | `false` | `false`| 

#### account
| Name | Field(s) |
| ------ | ------ | 
| EndToEndId-TxTp | `[EndToEndId, TxTp]` | `false` | `false`| 
| CreDtTm | `CreDtTm` | `false` | `false`| 

#### account_holder
| Name | Field(s) | 
| ------ | ------ | 
| EndToEndId-TxTp | `[EndToEndId, TxTp]` | 
| CreDtTm | `CreDtTm` | 

#### condition
| Name | Field(s) | 
| ------ | ------ | 


#### entity
| Name | Field(s) |
| ------ | ------ | 


#### governed_as_creditor_by
| Name | Field(s) | 
| ------ | ------ | 
| EndToEndId-TxTp | `[EndToEndId, TxTp]` |
| CreDtTm | `CreDtTm` |

#### governed_as_debtor_by
| Name | Field(s) |
| ------ | ------ | 
| EndToEndId-TxTp | `[EndToEndId, TxTp]` | 
| CreDtTm | `CreDtTm` | 

#### governed_as_debtor_account_by
| Name | Field(s) | 
| ------ | ------ | 
| EndToEndId-TxTp | `[EndToEndId, TxTp]` |
| CreDtTm | `CreDtTm` |


#### governed_as_creditor_account_by
| Name | Field(s) | 
| ------ | ------ | 
| EndToEndId-TxTp | `[endtoendid, txtp]` | 
| CreDtTm | `credttm` |

#### transaction
| Name | Field(s) | 
| ------ | ------ | 
| idx_tr_e2d_txtp | `[endtoendid, TxTp]` | 
| idx_tr_cre_dt_tm | `credttm` | `false` | 
| idx_tr_source_txtp_credttm | `[source, txtp, credttm]` |
| idx_tr_txsts | `txsts` | 
| idx_tr_endtoendid | `endtoendid` | 
| idx_tr_pacs002_accc | `[endtoendid, credttm]` | 
| idx_tr_dest_txtp_txsts_credttm | `[credttm, destination, txtp, txsts, credttm, source]` | 




## configuration
#### rule
| Name | Field(s) | 
| ------ | ------ | 
| id-cfg | `[id, cfg]` | 

#### typology
| Name | Field(s) | 
| ------ | ------ |
| id-cfg | `[id, cfg]` |

#### network_map
| Name | Field(s) | 
| ------ | ------ |

