# Tazama Database Schema Documentation

This document explains the logical purpose and structure of each database and table created for Tazama, including key columns, constraints, indexes, and common usage notes.

---

## Database: `configuration`

### Purpose

Holds reference/configuration data used by Tazama’s rule/typology engine and network mappings. Data is modeled as JSONB for flexibility and versioning via `(id, cfg)` tuples.

### Tables

#### `network_map`

**Role:** Stores network configuration documents (free‑form JSON) for building graph or routing contexts.

| Column          | Type  | Details                                       |
| --------------- | ----- | --------------------------------------------- |
| `configuration` | JSONB | Required. Arbitrary network mapping document. |
| `tenantId`      | TEXT (generated)| Tenant Identifier.`configuration ->> 'tenantId'`|

**Constraints/Indexes:** none by default.

**Typical usage:** persist/import network definitions; retrieve by JSON path in event-director application code.

---

#### `typology`

**Role:** Versioned typology definitions used by Typology processor logic.

| Column          | Type             | Details                                                 |
| --------------- | ---------------- | ------------------------------------------------------- |
| `configuration` | JSONB            | Full typology document. Must contain keys: `id`, `cfg`. |
| `typologyId`    | TEXT (generated) | `configuration ->> 'id'`.                               |
| `typologyCfg`   | TEXT (generated) | `configuration ->> 'cfg'`.                              |
| `tenantId`      | TEXT (generated)| Tenant Identifier.`configuration ->> 'tenantId'`      |

**Constraints:** `UNIQUE(typologyId, typologyCfg, tenantId)` ensures versioned uniqueness per typology.

**Notes:** Use `(id,cfg)` for safe updates; older configs remain addressable.

---

#### `rule`

**Role:** Versioned rule definitions consumed by the Tazama rules.

| Column          | Type               | Details                                         |
| --------------- | ------------------ | ----------------------------------------------- |
| `configuration` | JSONB              | Full rule document. Keys required: `id`, `cfg`. |
| `ruleId`        | TEXT (generated)   | `configuration ->> 'id'`.                       |
| `ruleCfg`       | TEXT (generated)   | `configuration ->> 'cfg'`.                      |
| `tenantId`      | TEXT (generated)| Tenant Identifier.`configuration ->> 'tenantId'`   |

**Constraints:** `UNIQUE(ruleId, ruleCfg, tenantId)`

---

## Database: `evaluation`

### Purpose

Stores evaluation report when Tazama is done evaluating the message.

### Tables

#### `evaluation`

**Role:** Holds raw evaluation documents (JSON) and extracts the message identifier from ISO 20022 `FIToFIPmtSts` payloads.

| Column       | Type                | Details                                                                  |
| ------------ | ------------------- | ------------------------------------------------------------------------ |
| `evaluation` | JSONB               | Required. Full evaluation payload/document.                              |
| `messageId`  | TEXT (generated)    | `evaluation -> 'transaction' -> 'FIToFIPmtSts' -> 'GrpHdr' ->> 'MsgId'`. |
| `tenantId`   | TEXT (generated) | Tenant Identifier.  `evaluation -> 'transaction' ->> 'tenantId'`         |

**Constraints/Indexes:** none defined by default.

---

## Database: `event_history`

### Purpose

Event‑sourced ledger of entities, accounts, governance/condition relationships, and normalized transaction summaries for operational read models.

### Tables

#### `account`

**Role:** Canonical account registry.

| Column     | Type    | Details                                                                     |
| ---------- | ------- | --------------------------------------------------------------------------- |
| `id`       | VARCHAR | Primary key. External account identifier (e.g., bank account number/alias). |
| `tenantId` | TEXT  | Tenant Identifier.    

**PK** (`id`, `tenantId`)                                                     |

---

#### `entity`

**Role:** Party registry (persons or organizations).

| Column    | Type        | Details                                  |
| --------- | ----------- | ---------------------------------------- |
| `id`      | VARCHAR     | Primary key. External entity identifier. |
| `creDtTm` | TIMESTAMPTZ | Creation timestamp.                      |
| `tenantId`| TEXT     | Tenant Identifier.                       |

---

#### `account_holder`

**Role:** Many‑to‑many relationship mapping entities to accounts over time.

| Column        | Type        | Details             |
| ------------- | ----------- | ------------------- |
| `source`      | VARCHAR     | FK → `entity(id)`.  |
| `destination` | VARCHAR     | FK → `account(id)`. |
| `creDtTm`     | TIMESTAMPTZ | Link creation time. |
| `tenantId`    | TEXT     | Tenant Identifier.  |

**PK:** (`source`, `destination`, `tenantId`).

---

#### `condition`

**Role:** Stores governance/condition documents (JSON) referenced by various relationships.

| Column      | Type                | Details                                             |
| ----------- | ------------------- | --------------------------------------------------- |
| `id`        | VARCHAR (generated) | Derived from `condition ->> 'condId'`. Primary key. |
| `condition` | JSONB               | Required. Full condition object.                    |
| `tenantId`  | TEXT             | Tenant Identifier.  `condition ->> 'tenantId'`         |

**PK** (`id`, `tenantId`)

**Notes:** Provides a reusable reference entity to avoid duplicating condition blobs.

---

#### `governed_as_creditor_account_by`

**Role:** Applies a `condition` to a creditor **account** (object level) across a time range.

| Column        | Type        | Details                                   |
| ------------- | ----------- | ----------------------------------------- |
| `source`      | VARCHAR     | FK → `account(id)`. The governed account. |
| `destination` | VARCHAR     | FK → `condition(id)`. Applied condition.  |
| `evtTp`       | TEXT[]      | Event types this governance applies to.   |
| `incptnDtTm`  | TIMESTAMPTZ | Start/activation time.                    |
| `xprtnDtTm`   | TIMESTAMPTZ | Optional expiry.                          |
| `tenantId`    | TEXT     | Tenant Identifier.                        |

**PK:** (`source`, `destination`, `tenantId`).

---

#### `governed_as_creditor_by`

**Role:** Applies a `condition` to a creditor **entity** (party level) across a time range.

| Column        | Type        | Details                                |
| ------------- | ----------- | -------------------------------------- |
| `source`      | VARCHAR     | FK → `entity(id)`. The governed party. |
| `destination` | VARCHAR     | FK → `condition(id)`.                  |
| `evtTp`       | TEXT[]      | Event types covered.                   |
| `incptnDtTm`  | TIMESTAMPTZ | Start/activation time.                 |
| `xprtnDtTm`   | TIMESTAMPTZ | Optional expiry.                       |
| `tenantId`    | TEXT     | Tenant Identifier.                     |

**PK:** (`source`, `destination`, `tenantId`).

---

#### `governed_as_debtor_account_by`

**Role:** Applies a `condition` to a debtor **account** across a time range.

| Column        | Type        | Details                |
| ------------- | ----------- | ---------------------- |
| `source`      | VARCHAR     | FK → `account(id)`.    |
| `destination` | VARCHAR     | FK → `condition(id)`.  |
| `evtTp`       | TEXT[]      | Event types covered.   |
| `incptnDtTm`  | TIMESTAMPTZ | Start/activation time. |
| `xprtnDtTm`   | TIMESTAMPTZ | Optional expiry.       |
| `tenantId`    | TEXT     | Tenant Identifier.     |

**PK:** (`source`, `destination`,  `tenantId`).

---

#### `governed_as_debtor_by`

**Role:** Applies a `condition` to a debtor **entity** across a time range.

| Column        | Type        | Details                |
| ------------- | ----------- | ---------------------- |
| `source`      | VARCHAR     | FK → `entity(id)`.     |
| `destination` | VARCHAR     | FK → `condition(id)`.  |
| `evtTp`       | TEXT[]      | Event types covered.   |
| `incptnDtTm`  | TIMESTAMPTZ | Start/activation time. |
| `xprtnDtTm`   | TIMESTAMPTZ | Optional expiry.       |
| `tenantId`    | TEXT     | Tenant Identifier.     |

**PK:** (`source`, `destination`, `tenantId`).

---

#### `transaction`

**Role:** Denormalized transaction facts keyed by `(msgId, endToEndId, txTp)` with attributes extracted from the embedded JSON.

| Column        | Type                      | Details                                                    |
| ------------- | ------------------------- | ---------------------------------------------------------- |
| `source`      | VARCHAR                   | FK → `account(id)`. Debtor account (for credit transfer).  |
| `destination` | VARCHAR                   | FK → `account(id)`. Creditor account.                      |
| `transaction` | JSONB                     | Full transaction payload.                                  |
| `endToEndId`  | TEXT (generated)          | `transaction ->> 'EndToEndId'`.                            |
| `amt`         | NUMERIC(18,2) (generated) | Cast of `transaction ->> 'Amt'`.                           |
| `ccy`         | VARCHAR (generated)       | ISO currency from `transaction ->> 'Ccy'`.                 |
| `msgId`       | VARCHAR (generated)       | `transaction ->> 'MsgId'`.                                 |
| `creDtTm`     | TEXT (generated)          | Creation timestamp string. Consider casting when querying. |
| `txTp`        | VARCHAR (generated)       | Message type (e.g., `pacs.008...`, `pacs.002...`).         |
| `txSts`       | VARCHAR (generated)       | Status (e.g., `ACCC`).                                     |
| `tenantId`    | TEXT (generated)       | `transaction->>'TenantId'` Tenant Identifier.              |

**Primary key:** (`msgId`, `endToEndId`, `txTp`).

**Indexes:**

* `idx_tr_e2d_txtp (endToEndId, txTp)` — E2E lookups by type.
* `idx_tr_cre_dt_tm (creDtTm)` — time range filtering (string; consider derived timestamp for performance).
* `idx_tr_source_txtp_credttm (source, txTp, creDtTm)` — account/time patterns.
* `idx_tr_txsts (txSts)` — status filters.
* `idx_tr_endtoendid (endToEndId)` — direct E2E lookups.
* `idx_tr_pacs002_accc (endToEndId, creDtTm)` **WHERE** `txTp='pacs.002.001.12' AND txSts='ACCC'` — acceptance correlation.
* `idx_tr_dest_txtp_txsts_credttm (destination, txTp, txSts, creDtTm DESC) INCLUDE(source)` — latest inbound by dest with source for joins.

---

## Database: `raw_history`

### Purpose

Immutable storage for raw ISO 20022 documents as received/produced by the system, with generated columns to accelerate joins into `event_history.transaction`.

### Tables

#### `pacs002`

**Role:** Stores FIToFIPmtSts (Financial Institution to Financial Institution Payment Status) messages.

| Column       | Type             | Details                                                              |
| ------------ | ---------------- | -------------------------------------------------------------------- |
| `document`   | JSONB            | Full PACS.002 document.                                              |
| `creDtTm`    | TEXT (generated) | `document -> 'FIToFIPmtSts' -> 'GrpHdr' ->> 'CreDtTm'`.              |
| `messageId`  | TEXT (generated) | `document -> 'FIToFIPmtSts' -> 'GrpHdr' ->> 'MsgId'`.                |
| `endToEndId` | TEXT (generated) | `document -> 'FIToFIPmtSts' -> 'TxInfAndSts' ->> 'OrgnlEndToEndId'`. |
| `tenantId`   | TEXT (generated) | `document -> 'TenantId'`.                                         |

**Constraints:**

* `UNIQUE(endToEndId)`
* `UNIQUE(messageId)`
* CHECKs enforcing non‑null on generated keys

**Indexes:** `messageId`, `endToEndId`.

---

#### `pacs008`

**Role:** Stores FIToFICstmrCdtTrf (Financial Institution to Financial Institution Customer Credit Transfer) messages.

| Column              | Type             | Details                                                                         |
| ------------------- | ---------------- | ------------------------------------------------------------------------------- |
| `document`          | JSONB            | Full PACS.008 document.                                                         |
| `creDtTm`           | TEXT (generated) | `document -> 'FIToFICstmrCdtTrf' -> 'GrpHdr' ->> 'CreDtTm'`.                    |
| `messageId`         | TEXT (generated) | `document -> 'FIToFICstmrCdtTrf' -> 'GrpHdr' ->> 'MsgId'`.                      |
| `endToEndId`        | TEXT (generated) | `document -> 'FIToFICstmrCdtTrf' -> 'CdtTrfTxInf' -> 'PmtId' ->> 'EndToEndId'`. |
| `debtorAccountId`   | TEXT (generated) | `... -> 'DbtrAcct' -> 'Id' -> 'Othr' -> 0 ->> 'Id'`.                            |
| `creditorAccountId` | TEXT (generated) | `... -> 'CdtrAcct' -> 'Id' -> 'Othr' -> 0 ->> 'Id'`.                            |
| `tenantId`          | TEXT (generated) | `document -> 'TenantId'`.                                                    |

**Constraints:**

* `UNIQUE(messageId, endToEndId)`
* `UNIQUE(endToEndId)`
* CHECKs enforcing non‑null on generated keys

**Indexes:** `messageId`, `endToEndId`, `debtorAccountId`, `creditorAccountId`, `creDtTm`.

---

#### `pain013`

**Role:** Stores CdtrPmtActvtnReq (Creditor Payment Activation Request) messages.

| Column              | Type             | Details                                                                         |
| ------------------- | ---------------- | ------------------------------------------------------------------------------- |
| `document`          | JSONB            | Full PAIN.013 document.                                                         |
| `creDtTm`           | TEXT (generated) | `document -> 'CdtrPmtActvtnReq' -> 'GrpHdr' ->> 'CreDtTm'`.                    |
| `messageId`         | TEXT (generated) | `document -> 'CdtrPmtActvtnReq' -> 'GrpHdr' ->> 'MsgId'`.                      |
| `endToEndId`        | TEXT (generated) | `document -> 'CdtrPmtActvtnReq' -> 'CdtTrfTxInf' -> 'PmtId' ->> 'EndToEndId'`. |
| `debtorAccountId`   | TEXT (generated) | `... -> 'DbtrAcct' -> 'Id' -> 'Othr' -> 0 ->> 'Id'`.                            |
| `creditorAccountId` | TEXT (generated) | `... -> 'CdtrAcct' -> 'Id' -> 'Othr' -> 0 ->> 'Id'`.                            |
| `tenantId`          | TEXT (generated) | `document -> 'TenantId'`.                                                    |

**Constraints:**

* `UNIQUE(messageId, endToEndId)`
* `UNIQUE(endToEndId)`
* CHECKs enforcing non‑null on generated keys

**Indexes:** `messageId`, `endToEndId`, `debtorAccountId`, `creditorAccountId`, `creDtTm`.

---

#### `pain001`

**Role:** Stores CstmrCdtTrfInitn (Customer Credit Transfer Initiation) messages.

| Column              | Type             | Details                                                                         |
| ------------------- | ---------------- | ------------------------------------------------------------------------------- |
| `document`          | JSONB            | Full PAIN.001 document.                                                         |
| `creDtTm`           | TEXT (generated) | `document -> 'CstmrCdtTrfInitn' -> 'GrpHdr' ->> 'CreDtTm'`.                    |
| `messageId`         | TEXT (generated) | `document -> 'CstmrCdtTrfInitn' -> 'GrpHdr' ->> 'MsgId'`.                      |
| `endToEndId`        | TEXT (generated) | `document -> 'CstmrCdtTrfInitn' -> 'CdtTrfTxInf' -> 'PmtId' ->> 'EndToEndId'`. |
| `debtorAccountId`   | TEXT (generated) | `... -> 'DbtrAcct' -> 'Id' -> 'Othr' -> 0 ->> 'Id'`.                            |
| `creditorAccountId` | TEXT (generated) | `... -> 'CdtrAcct' -> 'Id' -> 'Othr' -> 0 ->> 'Id'`.                            |
| `tenantId`          | TEXT (generated) | `document -> 'TenantId'`.                                                    |

**Constraints:**

* `UNIQUE(messageId, endToEndId)`
* `UNIQUE(endToEndId)`
* CHECKs enforcing non‑null on generated keys

**Indexes:** `messageId`, `endToEndId`, `debtorAccountId`, `creditorAccountId`, `creDtTm`.

---