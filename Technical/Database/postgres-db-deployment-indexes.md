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
| idx_pacs002_msg_id | `messageId` |
| idx_pacs002_end_to_end_id | `endToEndId` | 

#### pacs008
| Name | Field(s) |
| ------ | ------ | 
| idx_pacs008_msg_id | `messageId` | 
| idx_pacs008_end_to_end_id | `endToEndId` | 
| idx_pacs008_dbtr_acct_id | `debtorAccountId` |
| idx_pacs008_cdtr_acct_id | `creditoraccountid` |
| idx_pacs008_credttm | `creDtTm` |

#### pain001
| Name | Field(s) |
| ------ | ------ | 
| idx_pain001_msg_id | `messageId` |
| idx_pain001_end_to_end_id | `endToEndId` |
| idx_pain001_dbtr_acct_id | `debtorAccountId` |
| idx_pain001_cdtr_acct_id | `creditorAccountId` |
| idx_pain001_credttm | `creDtTm` |

#### pain013
| Name | Field(s) |
| ------ | ------ | 
| idx_pain013_msg_id | `messageId` |
| idx_pain013_end_to_end_id | `endToEndId` |
| idx_pain013_dbtr_acct_id | `debtorAccountId` |
| idx_pain013_cdtr_acct_id | `creditorAccountId` |
| idx_pain013_credttm | `creDtTm` |

## event_history

#### transaction
| Name | Field(s) | 
| ------ | ------ | 
| idx_tr_e2d_txtp | `[endToEndId, txTp]` | 
| idx_tr_cre_dt_tm | `creDtTm` | 
| idx_tr_source_txtp_credttm | `[source, txTp, creDtTm]` |
| idx_tr_txsts | `txSts` | 
| idx_tr_endtoendid | `endToEndId` | 
| idx_tr_pacs002_accc | `[endToEndId, creDtTm]` | 
| idx_tr_dest_txtp_txsts_credttm | `[creDtTm, destination, txTp, TxSts, creDtTm, source]` | 
