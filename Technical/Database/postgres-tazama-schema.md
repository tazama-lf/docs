## Tazama Postgres database schema
[Download file](https://raw.githubusercontent.com/tazama-lf/Full-Stack-Docker-Tazama/refs/heads/tazama/postgres-with-multitenancy/postgres/migration/base/00-CREATE.sql) 
```
create database configuration;

create database event_history;

create database raw_history;

create database evaluation;

\connect configuration;

create table network_map (
    configuration jsonb not null,
    tenantId text generated always as (configuration ->> 'tenantId') stored
);

create table typology (
    configuration jsonb not null,
    typologyId text generated always as (configuration ->> 'id') stored,
    typologyCfg text generated always as (configuration ->> 'cfg') stored,
    tenantId text generated always as (configuration ->> 'tenantId') stored,
    primary key (typologyId, typologyCfg, tenantId)
);

create table rule (
    configuration jsonb not null,
    ruleId text generated always as (configuration ->> 'id') stored,
    ruleCfg text generated always as (configuration ->> 'cfg') stored,
    tenantId text generated always as (configuration ->> 'tenantId') stored,
    primary key (ruleId, ruleCfg, tenantId)
);

\connect evaluation;

create table evaluation (
    evaluation jsonb not null,
    messageId text generated always as (
        evaluation -> 'transaction' -> 'FIToFIPmtSts' -> 'GrpHdr' ->> 'MsgId'
    ) stored,
    tenantId text generated always as (evaluation -> 'transaction' ->> 'TenantId') stored
);

\connect event_history;

create table account (
    id varchar not null,
    tenantId text not null,
    primary key (id, tenantId)
);

create table entity (
    id varchar not null,
    tenantId text not null,
    creDtTm timestamptz not null,
    primary key (id, tenantId)
);

create table account_holder (
    source varchar not null,
    destination varchar not null,
    tenantId text not null,
    creDtTm timestamptz not null,
    foreign key (source, tenantId) references entity (id, tenantId),
    foreign key (destination, tenantId) references account (id, tenantId),
    primary key (source, destination, tenantId)
);

create table condition (
    id varchar generated always as (condition ->> 'condId') stored,
    tenantId text generated always as (condition ->> 'tenantId') stored,
    condition jsonb not null,
    primary key (id, tenantId)
);

create table governed_as_creditor_account_by (
    source varchar not null,
    destination varchar not null,
    evtTp text [] not null,
    incptnDtTm timestamptz not null,
    xprtnDtTm timestamptz,
    tenantId text not null,
    foreign key (source, tenantId) references account (id, tenantId),
    foreign key (destination, tenantId) references condition (id, tenantId),
    primary key (source, destination, tenantId)
);

create table governed_as_creditor_by (
    source varchar not null,
    destination varchar not null,
    evtTp TEXT [] not null,
    incptnDtTm timestamptz not null,
    xprtnDtTm timestamptz,
    tenantId text not null,
    foreign key (source, tenantId) references entity (id, tenantId),
    foreign key (destination, tenantId) references condition (id, tenantId),
    primary key (source, destination, tenantId)
);

create table governed_as_debtor_account_by (
    source varchar not null,
    destination varchar not null,
    evtTp TEXT [] not null,
    incptnDtTm timestamptz not null,
    xprtnDtTm timestamptz,
    tenantId text not null,
    foreign key (source, tenantId) references account (id, tenantId),
    foreign key (destination, tenantId) references condition (id, tenantId),
    primary key (source, destination, tenantId)
);

create table governed_as_debtor_by (
    source varchar not null,
    destination varchar not null,
    evtTp TEXT [] not null,
    incptnDtTm timestamptz not null,
    xprtnDtTm timestamptz,
    tenantId text not null,
    foreign key (source, tenantId) references entity (id, tenantId),
    foreign key (destination, tenantId) references condition (id, tenantId),
    primary key (source, destination, tenantId)
);
/* transaction_relationship*/
create table transaction (
    source varchar not null,
    destination varchar not null,
    transaction jsonb not null,
    endToEndId text generated always as (transaction->>'EndToEndId') stored,
    amt numeric(18, 2) generated always as (
        (transaction->>'Amt')::numeric(18, 2)
    ) stored,
    ccy varchar generated always as (transaction->>'Ccy') stored,
    msgId varchar generated always as (transaction->>'MsgId') stored,
    creDtTm text generated always as (transaction->>'CreDtTm') stored,
    txTp varchar generated always as (transaction->>'TxTp') stored,
    txSts varchar generated always as (transaction->>'TxSts') stored,
    tenantId text generated always as (transaction->>'TenantId') stored,
    constraint unique_msgid unique (msgId, tenantId),
    foreign key (source, tenantId) references account (id, tenantId),
    foreign key (destination, tenantId) references account (id, tenantId),
    primary key (endToEndId, txTp, tenantId)
);

create index idx_tr_cre_dt_tm on transaction (creDtTm, tenantId);

create index idx_tr_source_txtp_credttm ON transaction (source, txtp, creDtTm, tenantId);


create index idx_tr_pacs002_accc on transaction (endtoendid, creDtTm, tenantId)
where
    txtp = 'pacs.002.001.12'
    and txsts = 'ACCC';

create index idx_tr_dest_txtp_txsts_credttm on transaction (
    destination,
    txtp,
    txsts,
    creDtTm desc
) include (source);

\connect raw_history;

create table pacs002 (
    document jsonb not null,
    -- cast when querying
    creDtTm text generated always as (
        document -> 'FIToFIPmtSts' -> 'GrpHdr' ->> 'CreDtTm'
    ) stored,
    messageId text generated always as (
        document -> 'FIToFIPmtSts' -> 'GrpHdr' ->> 'MsgId'
    ) stored,
    endToEndId text generated always as (
        document -> 'FIToFIPmtSts' -> 'TxInfAndSts' ->> 'OrgnlEndToEndId'
    ) stored,
    tenantId text generated always as (
        document ->> 'TenantId' ) stored,
    constraint unique_msgid_pacs002 unique (messageId, tenantId),
    constraint message_id_not_null check (messageId is not null),
    constraint cre_dt_tm check (creDtTm is not null),
    primary key (endToEndId, tenantId)
);


create table pacs008 (
    document jsonb not null,
    -- cast when querying
    creDtTm text generated always as (
        document -> 'FIToFICstmrCdtTrf' -> 'GrpHdr' ->> 'CreDtTm'
    ) stored,
    messageId text generated always as (
        document -> 'FIToFICstmrCdtTrf' -> 'GrpHdr' ->> 'MsgId'
    ) stored,
    endToEndId text generated always as (
        document -> 'FIToFICstmrCdtTrf' -> 'CdtTrfTxInf' -> 'PmtId' ->> 'EndToEndId'
    ) stored,
    debtorAccountId text generated always as (
        document -> 'FIToFICstmrCdtTrf' -> 'CdtTrfTxInf' -> 'DbtrAcct' -> 'Id' -> 'Othr' -> 0 ->> 'Id'
    ) stored,
    creditorAccountId text generated always as (
        document -> 'FIToFICstmrCdtTrf' -> 'CdtTrfTxInf' -> 'CdtrAcct' -> 'Id' -> 'Othr' -> 0 ->> 'Id'
    ) stored,
    tenantId text generated always as (
        document ->> 'TenantId' ) stored,
    constraint unique_msgid_e2eid_pacs008 unique (messageId, tenantId),
    constraint message_id_not_null check (messageId is not null),
    constraint cre_dt_tm check (creDtTm is not null),
    constraint dbtr_acct_id_not_null check (debtorAccountId is not null),
    constraint cdtr_acct_id_not_null check (creditorAccountId is not null),
    primary key (endToEndId, tenantId)
);


create index idx_pacs008_dbtr_acct_id on pacs008 (debtorAccountId, tenantId);

create index idx_pacs008_cdtr_acct_id on pacs008 (creditorAccountId, tenantId);

create index idx_pacs008_credttm on pacs008 (creDtTm, tenantId);

create table pain001 (
    document jsonb not null,
    -- cast when querying
    creDtTm text generated always as (
        document -> 'CstmrCdtTrfInitn' -> 'GrpHdr' ->> 'CreDtTm'
    ) stored,
    messageId text generated always as (
        document -> 'CstmrCdtTrfInitn' -> 'GrpHdr' ->> 'MsgId'
    ) stored,
    endToEndId text generated always as (
        document -> 'CstmrCdtTrfInitn' -> 'PmtInf' -> 'CdtTrfTxInf' -> 'PmtId' ->> 'EndToEndId'
    ) stored,
    debtorAccountId text generated always as (
        document -> 'CstmrCdtTrfInitn' -> 'PmtInf' -> 'DbtrAcct' -> 'Id' -> 'Othr' -> 0 ->> 'Id'
    ) stored,
    creditorAccountId text generated always as (
        document -> 'CstmrCdtTrfInitn' -> 'PmtInf' -> 'CdtTrfTxInf' -> 'CdtrAcct' -> 'Id' -> 'Othr' -> 0 ->> 'Id'
    ) stored,
    tenantId text generated always as (
        document ->> 'TenantId' ) stored,
    constraint unique_msgid_e2eid_pain001 unique (messageId, tenantId),
    constraint message_id_not_null check (messageId is not null),
    constraint cre_dt_tm check (creDtTm is not null),
    constraint dbtr_acct_id_not_null check (debtorAccountId is not null),
    constraint cdtr_acct_id_not_null check (creditorAccountId is not null),
    primary key (endToEndId, tenantId)
);


create index idx_pain001_dbtr_acct_id on pain001 (debtorAccountId, tenantId);

create index idx_pain001_cdtr_acct_id on pain001 (creditorAccountId, tenantId);

create index idx_pain001_credttm on pain001 (creDtTm, tenantId);

create table pain013 (
    document jsonb not null,
    -- cast when querying
    creDtTm text generated always as (
        document -> 'CdtrPmtActvtnReq' -> 'GrpHdr' ->> 'CreDtTm'
    ) stored,
    messageId text generated always as (
        document -> 'CdtrPmtActvtnReq' -> 'GrpHdr' ->> 'MsgId'
    ) stored,
    endToEndId text generated always as (
        document -> 'CdtrPmtActvtnReq' -> 'PmtInf' -> 'CdtTrfTxInf' -> 'PmtId' ->> 'EndToEndId'
    ) stored,
    debtorAccountId text generated always as (
        document -> 'CdtrPmtActvtnReq' -> 'PmtInf' -> 'DbtrAcct' -> 'Id' -> 'Othr' -> 0 ->> 'Id'
    ) stored,
    creditorAccountId text generated always as (
        document -> 'CdtrPmtActvtnReq' -> 'PmtInf' -> 'CdtTrfTxInf' -> 'CdtrAcct' -> 'Id' -> 'Othr' -> 0 ->> 'Id'
    ) stored,
    tenantId text generated always as (
        document ->> 'TenantId' ) stored,
    constraint unique_msgid_e2eid_pain013 unique (messageId, tenantId),
    constraint message_id_not_null check (messageId is not null),
    constraint cre_dt_tm check (creDtTm is not null),
    constraint dbtr_acct_id_not_null check (debtorAccountId is not null),
    constraint cdtr_acct_id_not_null check (creditorAccountId is not null),
    primary key (endToEndId, tenantId)
);


create index idx_pain013_dbtr_acct_id on pain013 (debtorAccountId, tenantId);

create index idx_pain013_cdtr_acct_id on pain013 (creditorAccountId, tenantId);

create index idx_pain013_credttm on pain013 (creDtTm, tenantId);
```