SPDX-License-Identifier: Apache-2.0 

# KeyCloak Operator Guide for Tazama


<!-- SPDX-License-Identifier: Apache-2.0 -->

# Auth-Lib-Provider-Keycloak

## Overview

A provider to be used to bridge Tazama Authentication with a keycloak backend. This provider is reliant on the [auth-lib](https://github.com/tazama-lf/auth-lib) package to function.

## Installation

A personal access token is required to install this repository. For more information read the following.
https://docs.github.com/en/packages/learn-github-packages/about-permissions-for-github-packages#about-scopes-and-permissions-for-package-registries

Make sure you've got an .npmrc file in the root of your project, specifying where the @tazama-lf repo is. 
```
@tazama-lf:registry=https://npm.pkg.github.com
```

Thereafter you can run 
  > npm install @tazama-lf/auth-lib 
  > npm install @tazama-lf/auth-lib-provider-keycloak 

## Usage

Ensure whichever application consumes this provider alongside auth-lib set the environmental variables unique to this provider as defined below. These variables are typically configured in the `.env` file of your Tazama deployment or in the environment configuration of your auth-service container.

##### Environment variables

| Variable | Purpose | Example | Tazama Default Configuration
| ------ | ------ | ------ | ------ |
| `AUTH_URL` | Base URL where KeyCloak is hosted | `https://keycloak.example.com:8080` | `http://keycloak:8080` (internal Docker network) |
| `KEYCLOAK_REALM` | KeyCloak Realm for Tazama | `tazama` | `tazama` |
| `CLIENT_ID` | KeyCloak defined client for auth-lib | `auth-lib-client` | `auth-lib-client` |
| `CLIENT_SECRET` | The secret of the KeyCloak client | `someClientGeneratedSecret123` | Generated during client creation (see security note below) |

##### Complete .env configuration example for Tazama auth-service:

This example shows the complete `.env` file used to deploy the auth-service component in the Tazama ecosystem. The auth-service acts as the authentication gateway that integrates with KeyCloak using this provider.

```bash
# SPDX-License-Identifier: Apache-2.0

# Service Configuration
FUNCTION_NAME=auth-service
NODE_ENV=dev
MAX_CPU=1

# Fastify Web Server Configuration
PORT=3020
HOST=0.0.0.0

# Auth Library Configuration
AUTH_PROVIDER=@tazama-lf/auth-lib-provider-keycloak
CERT_PATH_PRIVATE=private-key.pem
CERT_PATH_PUBLIC=public-key.pem

# KeyCloak Provider Configuration
AUTH_URL=http://keycloak.your-domain.com:8080
KEYCLOAK_REALM=tazama
CLIENT_SECRET=your-generated-client-secret-here
CLIENT_ID=your-client-id-here
KEYCLOAK_CLIENT_ID=your-client-id-here
KEYCLOAK_CLIENT_SECRET=your-generated-client-secret-here
```
**Deployment:**
This `.env` file is used when deploying the auth-service container, which serves as the authentication endpoint that other Tazama services call to validate tokens and permissions. The auth-service uses this provider to communicate with your KeyCloak instance configured following the steps in this guide.

---

## KeyCloak Operator Guide for Tazama

Official documentation found [here](https://www.keycloak.org/docs/23.0.6/server_admin/index.html)

### Logging into Admin Console

An admin account would have been created with KeyCloak deployment and management console is reached at the following endpoint:
`{keycloak_url}/admin/master/console`

### Creating a Realm
First we need to create a Realm for Tazama to house our management of users and credentials. Realm creation is available at the KeyCloak web admin panel. Note a default master realm will exist but we will want a realm for our custom entity.

<details open>
    <summary> 
      Navigate Realm
    </summary>

![1-create-realm-nav](../images/keycloak/1-create-realm-nav.png)

</details>

<details open>
    <summary> 
      Create Realm
    </summary>

![2-create-realm](../images/keycloak/2-create-realm.png)
</details>

---

### Creating a Client
We want to create a client to be able to authenticate and authorize using KeyCloak. In our scenario we are using the `auth lib` in Tazama. So we want to create a client for this purpose.
To create a client first ensure we are on the right realm on the dropdown top left then navigate to the create client button under Clients.

<details open>
    <summary> 
      Navigate Client
    </summary>

![3-create-client-nav](../images/keycloak/3-create-client-nav.png)

Then you can create the client 
</details>

<details open>
    <summary> 
      Create Client
    </summary>

![4-create-client](../images/keycloak/4-create-client.png)

And enable authentication and authorization
</details>


<details open>
    <summary> 
      Client Capabilities
    </summary>

![5-create-client-capability](../images/keycloak/5-create-client-capability.png)

Now that you have created a client just need to navigate to the client-secret as these details are needed by the auth-lib to function.
</details>

<details open>
    <summary> 
      Client Id and Secret
    </summary>

![6-client-id-and-secret](../images/keycloak/6-client-id-and-secret.png)

We have now created the following variables for auth-lib.

| Variable  | Value               | 
|-----------|---------------------|
| **client_id**  | auth-lib-client    | 
| **client_secret** | your-generated-client-secret-here    | 

</details>

---

### Creating roles 
Roles are permissions to define varying scope of access for users (also clients) in a KeyCloak realm. Roles can either be created on the realm level or in the individual client level. For this use case we will only be using realm roles.
To create a realm role navigate to Realm roles and click on Create role button.

<details open>
    <summary> 
      Navigate Realm
    </summary>

![7-realm-role-nav](../images/keycloak/7-realm-role-nav.png)

Here we can create many roles for different permissions we will use in `auth lib` 
Let's create a role for `POST_V1_EVALUATE_ISO20022_PAIN_001_001_11`
</details>

<details open>
    <summary> 
      Create Realm Role
    </summary>

![8-realm-role-create](../images/keycloak/8-realm-role-create.png)

We can repeat this process for `POST_V1_EVALUATE_ISO20022_PAIN_013_001_09`, `POST_V1_EVALUATE_ISO20022_PACS_008_001_10` and `POST_V1_EVALUATE_ISO20022_PACS_002_001_12`
</details>


---

### Creating groups
Now that we have a roles defined we can create a group with roles assigned to them. To create a group navigate to Groups and click on create group button.

<details open>
    <summary> 
      Navigate Group
    </summary>

![9-groups-nav](../images/keycloak/9-groups-nav.png)

Let's create a group called tazama-tms to assign the role(s) we previously created to the tazama-tms group.
</details>

<details open>
    <summary> 
      Create Group
    </summary>

![10-groups-create](../images/keycloak/10-groups-create.png)

Then click on the group and navigate to Role mappings to assign the role(s)

</details>

<details open>
    <summary> 
      Navigate Group Role Mappings
    </summary>

![11-groups-role-mappings](../images/keycloak/11-groups-role-mappings.png)
</details>

<details open>
    <summary> 
      Assign Group Role Mappings
    </summary>

![12-groups-role-mappings-assign](../images/keycloak/12-groups-role-mappings-assign.png)

We now have a tazama-tms group but no users. Let's create some users next.
</details>

---

### Configuring Tenant ID in Tokens
To support multi-tenancy in Tazama, we need to configure Keycloak to include tenant information in the JWT tokens. This is achieved by creating a custom user attribute mapper that adds the TENANT_ID attribute to access tokens.

<details open>
    <summary> 
      Step 1: Create User Attribute Mapper
    </summary>

First, navigate to your client settings and go to the "Client scopes" tab, then select "Dedicated scopes" and click on your client scope (e.g., `auth-lib-client-dedicated`).

<img width="1906" height="871" alt="tenant-id-mapper-step1" src="https://github.com/user-attachments/assets/54bfda68-390d-4c7c-8490-e32676f35bb9" />


In the client scope configuration:
1. **Mapper type**: Select "User Attribute" 
2. **Name**: Set to "tenant_id" (this will be the claim name in the token)
3. **User Attribute**: Set to "TENANT_ID" (this should match the attribute name in user profiles)
4. **Token Claim Name**: Set to "tenant_id" (this is how it appears in the JWT)
5. **Claim JSON Type**: Select "String"
6. **Add to ID token**: Toggle "On" 
7. **Add to access token**: Toggle "On"
8. **Add to lightweight access token**: Can be left "Off" for this use case
9. **Add to userinfo**: Toggle "On"
10. **Add to token introspection**: Toggle "On"
11. **Multivalued**: Toggle "Off" (since tenant_id should be a single value)
12. **Aggregate attribute values**: Toggle "Off"

</details>

<details open>
    <summary> 
      Step 2: Configure Group Attributes for Tenant ID
    </summary>

Navigate to Groups and select the group you want to assign a tenant ID to (e.g., "paysys"). Go to the "Attributes" tab and add the tenant information.

<img width="1919" height="867" alt="tenant-id-group-attributes" src="https://github.com/user-attachments/assets/c1572788-60b7-4fa4-b623-f57b7a877f1d" />

Add a new attribute:
1. **Key**: `TENANT_ID`
2. **Value**: The actual tenant identifier (e.g., `tenant_value_005`)

This ensures that all users in this group will inherit this tenant ID, which will then be included in their JWT tokens through the mapper configured in Step 1.

**Important Notes:**
- Each group can have its own TENANT_ID attribute value
- Users will inherit the TENANT_ID from their primary group
- The Tazama auth library will use this tenant_id claim for multi-tenant authorization
- Make sure the TENANT_ID attribute name matches exactly what's configured in the user attribute mapper

</details>

---

### Creating users
Users are individuals that will authenticate through KeyCloak to obtain permissions to use Tazama. There are two types of users in the Tazama ecosystem:

1. **Tenant Users**: Users who belong to specific tenant organizations and inherit tenant-specific permissions and tenant ID attributes
2. **Operator Users**: Administrative users who manage the Tazama system across multiple tenants

#### Creating Tenant Users

For tenant-specific users, follow these steps to ensure proper multi-tenancy setup:

To create a tenant user in KeyCloak navigate to the Users section and click on add user button.

<details open>
    <summary> 
      Navigate Users
    </summary>

![13-users-nav](../images/keycloak/13-users-nav.png)

When creating tenant users, ensure you assign them to the appropriate tenant group (e.g., "paysys" with TENANT_ID "tenant_value_005").
</details>

<details open>
    <summary> 
      Create Tenant User and Join Tenant Group
    </summary>

![14-users-create-and-group-join](../images/keycloak/14-users-create-and-group-join.png)

**Important**: For tenant users, make sure to:
- Assign them to the correct tenant group (not the general tazama-tms group)
- Verify the group has the proper TENANT_ID attribute configured
- The user will automatically inherit the TENANT_ID from their group membership

While the user is created a password was not yet set. So let's create a password for the newly created user under Credentials
</details>

<details open>
    <summary> 
      Set User Password
    </summary>

![15-users-set-password](../images/keycloak/15-users-set-password.png)
---
![16-users-set-password-extra](../images/keycloak/16-users-set-password-extra.png)

#### Creating Operator Users

For operator-specific users who need cross-tenant access or system-wide management capabilities:

1. **Create the user** following the same navigation steps above
2. **Assign them to a group**
3. **Do NOT assign a tenant-specific group** (or assign a special operator tenant ID if required)

**Operator User Configuration:**
- Group membership: None
- TENANT_ID: None
- Permissions: Cross-tenant visibility and system administration
- Use case: System administrators, support staff, cross-tenant analysts

**User Type Summary:**

| User Type | Group Assignment | TENANT_ID | Access Scope | Use Case |
|-----------|-----------------|-----------|--------------|----------|
| **Tenant Users** | Tenant-specific group (e.g., "paysys") | Inherited from group (e.g., "tenant_value_005") | Restricted to tenant data only | End users, tenant administrators |
| **Operator Users** | None |

**Important Multi-Tenancy Notes:**
- Tenant users can ONLY access data associated with their tenant ID
- Operator users can access system-wide data and configurations
- The auth-lib will automatically enforce tenant restrictions based on the user's token claims
- Each tenant group should have a unique TENANT_ID attribute value
- Users can only be members of one tenant group at a time to avoid conflicts

Congratulations. You now have users configured for the appropriate access level to interact with Tazama TMS.
</details>

<details>
    <summary>
        <strong>Additionally</strong>
    </summary> 
    If the user is expected to change their password the temporary password option should stay toggled at password creation or on the client page you can set required actions to `update password` and `verify email`.
    This will require the user to login to the KeyCloak account portal. The link is found by the Clients sidebar for the account entries home URL.
    <details>
        <summary> 
        Account Portal
        </summary>

![17-account-portal](../images/keycloak/17-account-portal.png)

   </details>
</details>

---

### Deleting users
Deleting users are simple.
We navigate to the Users section

<details open>
    <summary> 
      Navigate Users
    </summary>

![18-users-del-nav](../images/keycloak/18-users-del-nav.png)

We check the user(s) we want to delete and press the delete user button.
</details>

<details open>
    <summary> 
      Deleting a User
    </summary>

![19-users-deletion](../images/keycloak/19-users-deletion.png)

The user is deleted.
</details>

---

### Local Deployment
<details>
    <summary>
        <strong>Docker Compose</strong>
    </summary> 
    <details open>
        <summary> 
        docker-compose.yaml
        </summary>

```yaml
services:
    postgres:
        image: postgres:16.2
        volumes:
        - postgres_data:/var/lib/postgresql/data
        environment:
        POSTGRES_DB: ${POSTGRES_DB}
        POSTGRES_USER: ${POSTGRES_USER}
        POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
        networks:
        - kc_net

    keycloak:
        image: quay.io/keycloak/keycloak:23.0.6
        command: start
        environment:
        KC_HOSTNAME: localhost                  # local use only 
        KC_HOSTNAME_STRICT_BACKCHANNEL: false   # local use only
        KC_HTTP_ENABLED: true                   # local use only
        KC_HOSTNAME_STRICT_HTTPS: false         # local use only
        KC_HOSTNAME_PORT: 8080
        KC_HEALTH_ENABLED: true
        KEYCLOAK_ADMIN: ${KEYCLOAK_ADMIN}
        KEYCLOAK_ADMIN_PASSWORD: ${KEYCLOAK_ADMIN_PASSWORD}
        KC_DB: postgres
        KC_DB_URL: jdbc:postgresql://postgres/${POSTGRES_DB}
        KC_DB_USERNAME: ${POSTGRES_USER}
        KC_DB_PASSWORD: ${POSTGRES_PASSWORD}
        ports:
        - 8080:8080
        restart: always
        depends_on:
        - postgres
        networks:
        - kc_net

volumes:
    postgres_data:
        driver: local

networks:
    kc_net:
        driver: bridge
```
</details>
<details open>
        <summary> 
        .env
        </summary>

```yaml
POSTGRES_DB=keycloak_db
POSTGRES_USER=keycloak_db_user
POSTGRES_PASSWORD=keycloak_db_user_password
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin
```
   </details>
</details>

## Integration with Tazama Ecosystem

The KeyCloak provider works as part of the Tazama authentication architecture:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client App    │───▶│  Auth-Service   │───▶│    KeyCloak     │
│                 │    │ (using this     │    │   (Identity     │
│                 │    │  provider)      │    │   Provider)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

1. **Client applications** (TMS API, other Tazama services) send authentication requests
2. **Auth-service** validates these requests using this KeyCloak provider
3. **KeyCloak** performs the actual authentication and returns tokens
4. **Auth-service** processes the response and provides tokens back to clients

The auth-service container runs independently and is configured via the `.env` file shown above. Other Tazama services then call the auth-service endpoint (typically `http://auth-service:3020`) to validate tokens and check permissions.

---

### User Management Best Practices

When managing users in a multi-tenant Tazama environment, follow these guidelines:

**For Tenant Users:**
1. Always create users within the appropriate tenant group first
2. Verify the tenant group has the correct TENANT_ID attribute configured
3. Test that the user receives the correct tenant_id claim in their JWT token
4. Ensure the user can only access data from their assigned tenant

**For Operator Users:**
1. Create users in the general tazama-tms group for system-wide access
2. Grant minimal necessary permissions following the principle of least privilege
3. Consider creating sub-groups for different operator roles (e.g., read-only operators, full administrators)
4. Document operator access for audit purposes

**Security Considerations:**
- Regular audit of user group memberships
- Periodic review of tenant group TENANT_ID attributes
- Monitor for users accidentally assigned to multiple tenant groups
- Implement strong password policies and MFA where possible
