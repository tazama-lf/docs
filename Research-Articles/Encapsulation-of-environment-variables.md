# Environment variable encapsulation
## Third party service based

Desc: The encapsulation of environment variables entails moving the configuration from each service to the frms-coe-lib library. Due to additional service-based environment variables not being pre-defined in the library, this process allows us to move only the third-party service environment variables
each service when created from the processor side we aim to validate every environment variable as early as possible to ensure that each third-party service has every required environment variable for communication which Tazama

These are the third-party services used by Tazama
| Service | Library |
| --------- | ----------- |
| 1. Arango | frms-coe-lib |
| 2. Redis | frms-coe-lib |
| 3. Logger (Elastic) | frms-coe-lib |
| 4. Apm (Elastic) | frms-coe-lib |
| 5. Auth (Keycloak) | auth-lib |
| 6. Valkey (redis) | frms-coe-lib |
| 7. Nats | frms-coe-start-up-lib |


#### Logger Service-based encapsulation
![image](https://github.com/user-attachments/assets/80d4cd8f-50da-4a39-a2d3-3808b898822e)

#### APM Service-based encapsulation
![image](https://github.com/user-attachments/assets/d3ae6b64-5d13-4035-9c20-aeacca6117d9)

#### Database Service-based encapsulation
![image](https://github.com/user-attachments/assets/bc99ddd8-1738-4198-82dd-4e874a17ed84)



Reading environment variables within a library can be a useful approach but should be handled carefully, as it comes with some pros and cons:

### **Pros of Reading Environment Variables in a Library:**

1. **Configuration Flexibility**:  
   Environment variables allow you to customize your library's behavior without hardcoding values. This is especially useful for settings like API keys, database credentials, or feature toggles that vary between environments (development, staging, production).

2. **Security**:  
   Sensitive data, like tokens and credentials, can be kept outside the codebase, reducing the risk of exposing them in version control. Storing these in environment variables is a common best practice for security.

3. **Seamless Integration**:  
   Libraries that can read configuration from environment variables allow for smoother integration with different applications or environments. Users of the library don’t have to explicitly pass configuration in every function call, simplifying the setup.

### **Cons and Considerations:**

1. **Implicit Behavior**:  
   If your library silently reads from environment variables, it can introduce implicit behavior that may be hard to debug or understand. Developers might not realize why the library is behaving a certain way if they aren’t aware of the environment variables being used.

2. **Reduced Portability**:  
   If a library relies too heavily on environment variables, it might become less portable or harder to use in environments that don't support them (e.g., browser-based apps). You'd need to ensure there's a fallback mechanism.

3. **Testability**:  
   When libraries depend on environment variables, testing can become more complex. Test suites often need to mock or set environment variables, which can make tests more cumbersome. This can be mitigated with clear documentation and test setups, but it's something to keep in mind.

4. **Less Control for the Consumer**:  
   A library that automatically reads environment variables might reduce the control that the consuming application has over the configuration. Some developers prefer explicitly passing configuration to the library, rather than relying on hidden global state-like environment variables.


   ## Service based
   
Desc: encapsulation takes another look when focusing on the environment variables that are service-based, on this side variables are classified into two categories we have common service-based variables and additional service variables. Let us discuss common service-based variables first these are variables that are expected to be used by every processor that is importing the frms-coe-lib and using the validation of the processor that the library supplies to list them we have `FUNCTION_NAME`,`MAX_CPU` and `NODE_ENV` these are all mandatory for processor based validation and ideally we trigger this validation as early as possible in the startup process of each service. Now additional service variables are variables that can be listed by the processor and passed in as arguments from the parameter of processor validation and these can be as many as necessary for the processor using them the function will validate the common variables and additional variables and this function should return an array of object that has key pair of name of the variable and value of the variable this internal will be reduced to the configuration object that has just the keys as Variables names and Values as values of the variable that was found from the file of the .env.

Diagram of how service-based variables work:
![image](https://github.com/user-attachments/assets/c11610f9-0b48-4a90-9e9b-bee518b3e609)
