# Operational Procedures

The FRMS operates a number of environments that need managing and maintaining on a daily basis. The standard procedures described in this document outline the operations processes that enable the Hub Operator to handle all aspects of managing a live service.

The following procedures need to be in place:

- **Incident management** Managing incidents that have been reported to the Technical Operations team or that reached the team via alerts or monitoring activities.
- **Problem management** Getting to the root cause of incidents or the potential causes of incidents, and instigating actions to improve or correct the situation at once.
- **Change management** Controlling the lifecycle of all changes, enabling changes to be made with minimum disruption to IT services.
- **Release management** Managing, planning, scheduling, and controlling a software change through deployment and testing across various environments.
- **Defect triage** Ensuring that all the bugs identified in the client’s Production environment are captured, evaluated, prioritized, and submitted to the Service Desk.

A quick overview of the environments managed by the Hub Operator is provided below:

- **Development**: Non-production software development environment where Mojaloop OSS code is merged with customizations. Gives developers fast test feedback on new code submissions. Digital Financial Service Providers (DFSPs) do not interact with this environment. Developer and QA access only.
- **User Acceptance Testing (UAT)**: Testing environment for user acceptance and regression testing to validate new releases.
- **Sandbox (SBX)**: Testing environment to validate DFSP connectivity on both API and security requirements.
- **Staging (STG)**: Pre-production environment that mirrors production as closely as possible. Validation of new releases and DFSP integration.
- **Production (PRD)**: Production environment compatible with production release.
