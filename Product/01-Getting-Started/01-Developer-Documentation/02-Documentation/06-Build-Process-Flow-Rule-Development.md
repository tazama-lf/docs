# Build Process Flow - Rule development

![](../../../../Images/Build_Process.jpg)

## Build process breakdown

1. License scan
    1. Scan the relevant licenses using the Mojaloop License scanning tool
2. Package Vulnerability Scan
    1. Scan package vulnerabilities using Snyk
3. Code Quality Scan
    1. Complete code quality scan using Sonar Cloud
4. Build code and container
    1. Publish to DockerHub
5. Merge Code
    1. Merge the code into the main Branch
6. Notify Developer
    1. Send a notification to the merge request developer
