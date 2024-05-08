# Securing a NodeJS app using Keycloak

In this article we will setup a NodeJS application that authorizes using Keycloak bearer tokens

## Instructions

Step-by-step guide:

1. Firstly clone the demo application:

```bash
git clone https://github.com/welshstew/keycloak-simple-examples.git
```

2. Navigate into the “keycloak-nodejs-example”:

```bash
cd keycloak-simple-examples/keycloak-nodejs-example/
```

3. Install the required packages:

```bash
npm install 
```

4. Change the `keycloak.json` to reflect the values hereunder:

```json
{
    "realm": "example",
    "bearer-only": true,
    "auth-server-url": "http://51.143.233.102/auth",
    "ssl-required": "external",
    "resource": "keycloak-nodejs-example"
}
```

5. Run the test application:

```bash
npm start
```

6. Open the attached (at the bottom of this guide) Postman Collection:

    ![](../../../../../Images/image-20210517-133407.png)
    ![](../../../../../Images/image-20210517-133456.png)

7. Run the “Public” Get request and receive a valid response:

    ![](../../../../../Images/image-20210517-133600.png)

8. Run the “Secured” Get request and receive an “Access denied” response:

    ![](../../../../../Images/image-20210517-133705.png)

9. Run the “Get Bearer” Post request and receive a Bearer token from Keycloak:

    ![](../../../../../Images/image-20210517-133911.png)

10. Copy the “access_token” you received and place it in the Authorization section of your “Secured” Get request as a Bearer Token:

    ![](../../../../../Images/image-20210517-134122.png)

11. Run the “Secured” Get request with the new Bearer Token and receive a valid secured response:

    ![](../../../../../Images/image-20210517-134249.png)

[Tazama_-_Keycloak_Test.postman_collection.json](../../../../../Images/FRM -- Keycloak Test.postman_collection.json)

If you want to test this using your own Realm follow this [guide](01-Setting-Up-A-Keycloak-Realm.md) and change the “example” realm where necessary.
