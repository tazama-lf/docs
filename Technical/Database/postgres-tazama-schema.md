Tazama Postgres database schema
SoT: Source of Truth 

```
-- Create databases
CREATE DATABASE configuration;
CREATE DATABASE event_history;
CREATE DATABASE raw_history;
CREATE DATABASE evaluation;

-- ========== CONFIGURATION DB ==========
\connect configuration;

CREATE TABLE network_map (
    configuration JSONB NOT NULL
);

CREATE TABLE typology (
    configuration JSONB NOT NULL,
    typologyId TEXT GENERATED ALWAYS AS (configuration ->> 'id') STORED,
    typologyCfg TEXT GENERATED ALWAYS AS (configuration ->> 'cfg') STORED,
    UNIQUE (typologyId, typologyCfg)
);

CREATE TABLE rule (
    configuration JSONB NOT NULL,
    ruleId TEXT GENERATED ALWAYS AS (configuration ->> 'id') STORED,
    ruleCfg TEXT GENERATED ALWAYS AS (configuration ->> 'cfg') STORED,
    UNIQUE (ruleId, ruleCfg)
);

-- ========== EVALUATION DB ==========
\connect evaluation;

CREATE TABLE evaluation (
    evaluation JSONB NOT NULL,
    messageId TEXT GENERATED ALWAYS AS (
        evaluation -> 'transaction' -> 'FIToFIPmtSts' -> 'GrpHdr' ->> 'MsgId'
    ) STORED
);

-- ========== EVENT_HISTORY DB ==========
\connect event_history;

CREATE TABLE account (
    id VARCHAR PRIMARY KEY
);

CREATE TABLE entity (
    id VARCHAR PRIMARY KEY,
    creDtTm TIMESTAMPTZ NOT NULL
);

CREATE TABLE account_holder (
    source VARCHAR REFERENCES entity(id),
    destination VARCHAR REFERENCES account(id),
    creDtTm TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (source, destination)
);

CREATE TABLE condition (
    id VARCHAR PRIMARY KEY GENERATED ALWAYS AS (condition ->> 'condId') STORED,
    condition JSONB NOT NULL
);

CREATE TABLE governed_as_creditor_account_by (
    source VARCHAR REFERENCES account(id),
    destination VARCHAR REFERENCES condition(id),
    evtTp TEXT[] NOT NULL,
    incptnDtTm TIMESTAMPTZ NOT NULL,
    xprtnDtTm TIMESTAMPTZ,
    PRIMARY KEY (source, destination)
);

CREATE TABLE governed_as_creditor_by (
    source VARCHAR REFERENCES entity(id),
    destination VARCHAR REFERENCES condition(id),
    evtTp TEXT[] NOT NULL,
    incptnDtTm TIMESTAMPTZ NOT NULL,
    xprtnDtTm TIMESTAMPTZ,
    PRIMARY KEY (source, destination)
);

CREATE TABLE governed_as_debtor_account_by (
    source VARCHAR REFERENCES account(id),
    destination VARCHAR REFERENCES condition(id),
    evtTp TEXT[] NOT NULL,
    incptnDtTm TIMESTAMPTZ NOT NULL,
    xprtnDtTm TIMESTAMPTZ,
    PRIMARY KEY (source, destination)
);

CREATE TABLE governed_as_debtor_by (
    source VARCHAR REFERENCES entity(id),
    destination VARCHAR REFERENCES condition(id),
    evtTp TEXT[] NOT NULL,
    incptnDtTm TIMESTAMPTZ NOT NULL,
    xprtnDtTm TIMESTAMPTZ,
    PRIMARY KEY (source, destination)
);

-- Transactions
CREATE TABLE transaction (
    source VARCHAR REFERENCES account(id),
    destination VARCHAR REFERENCES account(id),
    transaction JSONB NOT NULL,
    endToEndId TEXT GENERATED ALWAYS AS (transaction ->> 'EndToEndId') STORED,
    amt NUMERIC(18, 2) GENERATED ALWAYS AS ((transaction ->> 'Amt')::NUMERIC(18, 2)) STORED,
    ccy VARCHAR GENERATED ALWAYS AS (transaction ->> 'Ccy') STORED,
    msgId VARCHAR GENERATED ALWAYS AS (transaction ->> 'MsgId') STORED,
    creDtTm TEXT GENERATED ALWAYS AS (transaction ->> 'CreDtTm') STORED,
    txTp VARCHAR GENERATED ALWAYS AS (transaction ->> 'TxTp') STORED,
    txSts VARCHAR GENERATED ALWAYS AS (transaction ->> 'TxSts') STORED,
    PRIMARY KEY (msgId, endToEndId, txTp)
);

-- Indexes
CREATE INDEX idx_tr_e2d_txtp ON transaction (endToEndId, txTp);
CREATE INDEX idx_tr_cre_dt_tm ON transaction (creDtTm);
CREATE INDEX idx_tr_source_txtp_credttm ON transaction (source, txTp, creDtTm);
CREATE INDEX idx_tr_txsts ON transaction (txSts);
CREATE INDEX idx_tr_endtoendid ON transaction (endToEndId);
CREATE INDEX idx_tr_pacs002_accc ON transaction (endToEndId, creDtTm)
  WHERE txTp = 'pacs.002.001.12' AND txSts = 'ACCC';
CREATE INDEX idx_tr_dest_txtp_txsts_credttm ON transaction (destination, txTp, txSts, creDtTm DESC)
  INCLUDE (source);

-- ========== RAW_HISTORY DB ==========
\connect raw_history;

-- PACS.002
CREATE TABLE pacs002 (
    document JSONB NOT NULL,
    creDtTm TEXT GENERATED ALWAYS AS (
        document -> 'FIToFIPmtSts' -> 'GrpHdr' ->> 'CreDtTm'
    ) STORED,
    messageId TEXT GENERATED ALWAYS AS (
        document -> 'FIToFIPmtSts' -> 'GrpHdr' ->> 'MsgId'
    ) STORED,
    endToEndId TEXT GENERATED ALWAYS AS (
        document -> 'FIToFIPmtSts' -> 'TxInfAndSts' ->> 'OrgnlEndToEndId'
    ) STORED,
    CONSTRAINT unique_e2eid_pacs002 UNIQUE (endToEndId),
    CONSTRAINT unique_msgid_pacs002 UNIQUE (messageId),
    CONSTRAINT message_id_not_null CHECK (messageId IS NOT NULL),
    CONSTRAINT cre_dt_tm CHECK (creDtTm IS NOT NULL),
    CONSTRAINT end_to_end_id_not_null CHECK (endToEndId IS NOT NULL)
);

CREATE INDEX idx_pacs002_msg_id ON pacs002 (messageId);
CREATE INDEX idx_pacs002_end_to_end_id ON pacs002 (endToEndId);

-- PACS.008
CREATE TABLE pacs008 (
    document JSONB NOT NULL,
    creDtTm TEXT GENERATED ALWAYS AS (
        document -> 'FIToFICstmrCdtTrf' -> 'GrpHdr' ->> 'CreDtTm'
    ) STORED,
    messageId TEXT GENERATED ALWAYS AS (
        document -> 'FIToFICstmrCdtTrf' -> 'GrpHdr' ->> 'MsgId'
    ) STORED,
    endToEndId TEXT GENERATED ALWAYS AS (
        document -> 'FIToFICstmrCdtTrf' -> 'CdtTrfTxInf' -> 'PmtId' ->> 'EndToEndId'
    ) STORED,
    debtorAccountId TEXT GENERATED ALWAYS AS (
        document -> 'FIToFICstmrCdtTrf' -> 'CdtTrfTxInf' -> 'DbtrAcct' -> 'Id' -> 'Othr' -> 0 ->> 'Id'
    ) STORED,
    creditorAccountId TEXT GENERATED ALWAYS AS (
        document -> 'FIToFICstmrCdtTrf' -> 'CdtTrfTxInf' -> 'CdtrAcct' -> 'Id' -> 'Othr' -> 0 ->> 'Id'
    ) STORED,
    CONSTRAINT unique_msgid_e2eid_pacs008 UNIQUE (messageId, endToEndId),
    CONSTRAINT unique_e2eid_pacs008 UNIQUE (endToEndId),
    CONSTRAINT message_id_not_null CHECK (messageId IS NOT NULL),
    CONSTRAINT cre_dt_tm CHECK (creDtTm IS NOT NULL),
    CONSTRAINT dbtr_acct_id_not_null CHECK (debtorAccountId IS NOT NULL),
    CONSTRAINT cdtr_acct_id_not_null CHECK (creditorAccountId IS NOT NULL),
    CONSTRAINT end_to_end_id_not_null CHECK (endToEndId IS NOT NULL)
);

CREATE INDEX idx_pacs008_msg_id ON pacs008 (messageId);
CREATE INDEX idx_pacs008_end_to_end_id ON pacs008 (endToEndId);
CREATE INDEX idx_pacs008_dbtr_acct_id ON pacs008 (debtorAccountId);
CREATE INDEX idx_pacs008_cdtr_acct_id ON pacs008 (creditorAccountId);
CREATE INDEX idx_pacs008_credttm ON pacs008 (creDtTm);

```