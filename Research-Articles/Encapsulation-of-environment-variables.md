# Environment variable encapsulation
## Third party service based

Desc: The encapsulation of environment variables involves centralizing configuration management within the `frms-coe-lib` library, reducing the need for each service to manage its own environment variables independently. Since additional service-based environment variables are not predefined in the library, this approach allows us to focus on external, third-party service variables.

When a service is instantiated from the processor side, the goal is to validate all necessary environment variables as early as possible to ensure that each third-party service has the required configuration for effective communication. This validation process is especially crucial in projects like Tazama, where reliable interaction with external services is key to maintaining system integrity and performance.

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
   
Desc: Encapsulation takes on a new dimension when focusing on service-based environment variables. These variables are categorized into two groups: common service-based variables and additional service-specific variables.

Let's first discuss the common service-based variables. These are essential variables expected to be used by every processor that imports the `frms-coe-lib` library and utilizes the processor validation supplied by the library. Key variables in this category include `FUNCTION_NAME`, `MAX_CPU`, and `NODE_ENV`. These are mandatory for processor-based validation, and it is recommended to trigger this validation as early as possible during the service startup process.

On the other hand, additional service variables are specific to each processor and can be passed in as arguments during processor validation. These variables can vary in number, depending on the needs of the processor. The validation function will validate both common and additional variables. It returns an array of objects, each containing a key-value pair representing the variable name and its corresponding value. Internally, this array is reduced to a configuration object, where the keys are the variable names and the values are the corresponding values extracted from the `.env` file.

Diagram of how service-based variables work:
![image](https://github.com/user-attachments/assets/c11610f9-0b48-4a90-9e9b-bee518b3e609)
