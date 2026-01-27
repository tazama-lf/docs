This document will outline the steps needed for a minimal example on enabling row-level security for multi-tenancy on PostgreSQL.

The key objectives:
- Tenants can only view their specific data
- "Support" users are able to oversee multiple tenants' data

# Setting-up
Start by enabling an extension to automatically generate IDs as well as a schema to be used by the example.

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto; -- autogen UUIDs
CREATE SCHEMA app; where we will be working
```

Create the tables:
```
CREATE TABLE app.tenant (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), --pgcrypto extension kicks in
  name text UNIQUE NOT NULL
  -- you may want to store additional tenant data, but for the POC, this is all that's needed
);
```

Enable row-level-security on the table:
```sql
ALTER TABLE app.tenant ENABLE ROW LEVEL SECURITY;
```
Create the 'DEFAULT' tenant. Currently, Tazama uses this value if a `tenantId` is not provided. This needs to be tracked:

```sql
INSERT INTO app.tenant (name) VALUES ('DEFAULT');
```

Create a table that tracks which users belong to which tenant:
```sql
CREATE TABLE app.user_tenant (
  role_name text PRIMARY KEY,     -- e.g. 'myorg_readwrite'
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) on delete cascade
);
```
---
## Utility Functions
Create some utility functions to minimise the code needed by clients:

```sql
CREATE OR REPLACE FUNCTION app.set_tenant_id(t UUID)
RETURNS void AS $$
BEGIN
    PERFORM set_config('app.tenant_id', t::text, true); -- true = is_local
END;
$$ LANGUAGE plpgsql;
```
This takes in a UUID and sets it as the `app.tenant_id` parameter for the current transaction. 

With the "setter" created, create another function to get that value:
```sql
CREATE OR REPLACE FUNCTION app.current_tenant_id()
RETURNS UUID LANGUAGE sql
SECURITY DEFINER
SET search_path = app
STABLE AS
$$
    SELECT COALESCE(
               NULLIF(current_setting('app.tenant_id', true), '')::uuid, 
               (SELECT id 
                FROM app.tenant
                WHERE name = 'DEFAULT'
                LIMIT 1),
               (SELECT ut.tenant_id
                FROM app.user_tenant ut
                WHERE ut.role_name = current_user
                LIMIT 1)
           );
$$;
```

---
## Tables for Business Logic
Create a table - this example picks the Pacs008 table for transactions:

```sql
create table app.pacs008 (
    document jsonb not null,
    tenant_id uuid not null references app.tenant(id) on delete cascade default app.current_tenant_id(), -- this sets a default value for this column if the tenant_id is not specified
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
    constraint unique_msgid_e2eid_pacs008 unique (messageId, endToEndId),
    constraint unique_e2eid_pacs008 unique (endToEndId),
    constraint message_id_not_null check (messageId is not null),
    constraint cre_dt_tm check (creDtTm is not null),
    constraint dbtr_acct_id_not_null check (debtorAccountId is not null),
    constraint cdtr_acct_id_not_null check (creditorAccountId is not null),
    constraint end_to_end_id_not_null check (endToEndId is not null)
);

CREATE INDEX ON app.pacs008 (tenant_id); -- index the column
```

Enable row-level-security for this table as well:
```sql
ALTER TABLE app.pacs008 ENABLE ROW LEVEL SECURITY;
```

---
## Create Roles
These can represent the different tenants:
```sql
CREATE ROLE foo_rw LOGIN PASSWORD '12345';
CREATE ROLE bar_rw LOGIN PASSWORD '12345';
```

Register these users in the `app.tenant` table:
```sql
INSERT INTO app.tenant (name) VALUES ('Foo'), ('Bar')
```

Register these users in the `app.user_tenant` table:
```sql
INSERT INTO app.user_tenant(role_name, tenant_id)
VALUES
    ('foo_rw',  (SELECT id FROM app.tenant WHERE name='Foo')),
    ('bar_rw',(SELECT id FROM app.tenant WHERE name='Bar'));
```

Allow these users to use the schema:
```sql
GRANT USAGE ON SCHEMA app TO foo_rw, bar_rw;
GRANT SELECT, INSERT, UPDATE, DELETE ON app.pacs008 TO foo_rw, bar_rw;
```

## Support Users
For users that can oversee multiple tenants, they need to be tracked separately:
```sql
CREATE TABLE app.support_tenant_access (
  role_name text NOT NULL,                    -- e.g. 'support_1'
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE CASCADE,
  PRIMARY KEY (role_name, tenant_id)
);
CREATE INDEX ON app.support_tenant_access (tenant_id);
```

Create a utility function to return whether the current user has access to a specific tenant's data:
```sql
CREATE OR REPLACE FUNCTION app.has_tenant(p_tenant_id uuid, u text)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = app
AS $$
  SELECT EXISTS (
    -- regular user mapping: 1 role → 1 tenant
    SELECT 1 FROM app.user_tenant ut
     WHERE ut.role_name = u
       AND ut.tenant_id = p_tenant_id
    UNION ALL
    -- support-user mapping: 1 role → many tenants
    SELECT 1 FROM app.support_tenant_access s
     WHERE s.role_name = u
       AND s.tenant_id = p_tenant_id
  );
$$;
```

Grant it just the `execute` priviledge:
```
REVOKE ALL ON FUNCTION app.has_tenant(uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.has_tenant(uuid, text) TO PUBLIC;
```

### Create the Roles and Register them
This example creates two support users and gives them read only access (adjust as needed):
```sql
CREATE ROLE support_1 LOGIN PASSWORD '12345'; 
CREATE ROLE support_2 LOGIN PASSWORD '12345';

GRANT USAGE ON SCHEMA app TO support_1, support_2;
GRANT SELECT ON app.pacs008 TO support_1, support_2;
GRANT SELECT ON app.tenant TO support_1, support_2;
```

Register the support users:
```sql
INSERT INTO app.support_tenant_access(role_name, tenant_id)
VALUES
  ('support_1', (SELECT id FROM app.tenant WHERE name='Foo')),
  ('support_1', (SELECT id FROM app.tenant WHERE name='Bar')),
  ('support_2', (SELECT id FROM app.tenant WHERE name='Foo'));
```
Support 1 should be able to access **both** tenant "Foo" and tenant "Bar" data.
Support 2 should **only** be able to access tenant "Foo" data but be restricted from accessing tenant "Bar" data

---
## Policies
```sql
CREATE POLICY pacs008s_tenant_isolation ON app.pacs008
  FOR ALL
  TO PUBLIC
  USING (app.has_tenant(tenant_id, current_user));

-- view only what you're allowed
CREATE POLICY tenants_visibility ON app.tenant
  FOR SELECT
  TO PUBLIC
  USING (app.has_tenant(id, current_user));
```
---
# Inserting Data and Testing
## Unspecified (Default) Tenant
As the postgres user, insert a sample transaction:
```sql
insert into app.pacs008 (document) values ('{}'); --json is omitted
```
Switch the role to `foo_rw` and verify no rows are returned from a select operation:

```sql
set role foo_rw;
select * from app.pacs008;
-- should have no rows
```

Likewise for `bar_rw`:
```sql
set role bar_rw;
select * from app.pacs008;
-- should have no rows
```
Check that `postgres` user can view the data:
```sql
reset role; -- go back to pg user
select * from app.pacs008; -- 1 row
```
## Specified Tenant
This will leverage the custom `app.set_tenant_id(text)` function created earlier.
```sql
BEGIN;
select app.set_tenant_id('bar's tenant id'); -- use Bar's tenant id
select app.current_tenant_id(); -- (not needed but just verify that the same value you passed in is returned)
insert into app.pacs008 (document) values ('');
commit;
```
Verify that the postgres superuser can see the newly created transaction:
```sql
select * from app.pacs008;
```

Verify that the `support_2` user **cannot** see the row (since they were not registered to this tenant):
```sql
set role support_2;
select * from app.pacs008;
-- no rows here
```

However, `support_1` user should be able to view the data:
```sql
set role support_1;
select * from app.pacs008; -- returns one row
reset role;
```
---
# Important

- The `tenantId` **must** be a UUID if provided.
  - A `'DEFAULT'` tenant name is reserved for cases where it is not provided
 
# Quick Tips

To create a new tenant:

```sql
CREATE ROLE new_tenant LOGIN PASSWORD 'secret';
INSERT INTO app.tenant (name) VALUES ('New Tenant');
INSERT INTO app.user_tenant(role_name, tenant_id)
VALUES
    ('new_tenant',  (SELECT id FROM app.tenant WHERE name='New Tenant'));
GRANT USAGE ON SCHEMA app TO new_tenant;
GRANT SELECT, INSERT, UPDATE, DELETE ON app.pacs008 TO new_tenant;
```

To create a new support user:
```sql
CREATE ROLE new_support LOGIN PASSWORD '12345'; 

GRANT USAGE ON SCHEMA app TO new_support;

GRANT SELECT ON app.pacs008 TO new_support;
GRANT SELECT ON app.tenant TO new_support;

INSERT INTO app.support_tenant_access(role_name, tenant_id)
VALUES
  ('new_support', (SELECT id FROM app.tenant WHERE name='Tenant Name'));
```
