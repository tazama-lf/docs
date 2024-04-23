# Setting up a Keycloak realm

In this guide I will take you through the step by step instructions on how to create your own Keycloak realm, complete with users and roles.

## Instructions

1. Navigate to the [Keycloak Dashboard](http://51.143.233.102/auth/)

2. Click on the “Administration Console”:

    ![](../../../../../Images/image-20210517-134858.png)

3. Log in using the Credentials provided to you:

    ![](../../../../../Images/image-20210517-134956.png)

4. Click on the “Master” realm and select Add Realm:

    ![](../../../../../Images/image-20210517-135054.png)

5. Provide the realm with a name:

    ![](../../../../../Images/image-20210517-135139.png)

6. Navigate to the “Users” section:

    ![](../../../../../Images/image-20210517-135219.png)

7. Click on the “Add User” button:

    ![](../../../../../Images/image-20210517-135249.png)

8. Provide a Username and ensure the User is enabled:

    ![](../../../../../Images/image-20210517-135344.png)

9. Navigate to “Credentials” and provide a password:

    ![](../../../../../Images/image-20210517-135515.png)

    **Ensure that “Temporary” is set to Off**

10. Navigate to Roles:

    ![](../../../../../Images/image-20210517-135710.png)

11.  Add a Role:

    ![](../../../../../Images/image-20210517-135733.png)

12. Provide a memorable name and Save the Role:

    ![](../../../../../Images/image-20210517-135818.png)

13. Navigate to your User and Click edit:

    ![](../../../../../Images/image-20210517-135912.png)

14. Add your Role to your User:

    ![](../../../../../Images/image-20210517-135956.png)

15. Navigate to Clients:

    ![](../../../../../Images/image-20210517-140028.png)

16. Provide your Client with a memorable name:

    ![](../../../../../Images/image-20210517-140102.png)

Your Realm is now setup and ready for use.
