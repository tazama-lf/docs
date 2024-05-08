# Environment Variables

## Overview

Rules and Processors currently follow an approach to environmental variables where each application contains it’s own local copy of environment variables that will be loaded one time into a config data class at startup. Application behavior is thus static and any desired changes to config will require a full restart of the application with new environmental variables provided.

## Drawbacks

1. Decentralized Environment Variables
    1. Requires higher maintenance effort for changes
    2. Version control synchronization - Ensuring correctness of variables without variance
    3. Deployment complexity - Build and deploy tools need additional config tweaking
    4. Prone to user error

2. Static Config Behavior
    1. Operation control inflexibility - Cannot fine tune live application or adapt to external changes
    2. Prolonged downtime - Full restart on changes
    3. Debugging difficulty

## Future

### Requirement concerns

- How do you make environmental configuration of all the processors in the platform cleaner and simpler?  
  - Centralized repository (HashiCorp Vault, Embedded Sub Repository)
- How do you change the behavior of all platform processors via an environment variable without restarting all the pods? (Environmental change control)  
  - Example: Updating the Arango certificate
- How do we change the behavior of a (or some) processors via an override to environment variables without restarting the pods? (Operational control)  
  - Example: Turning on debug-level logging in a specific rule processor  
  - Challenge: Updating all the instances behind Kubernetes – *you cannot update config maps or environment variables without restarting a pod*
