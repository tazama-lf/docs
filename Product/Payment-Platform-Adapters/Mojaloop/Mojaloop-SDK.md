# Mojaloop SDK

![](../../Images/image-20210616-092254.png)

From the April 2020 Convening, ModusBox presented the [SDK](https://github.com/mojaloop/documentation-artifacts/blob/master/presentations/April%202020%20Community%20Event/Presentations/ModusBox_Community_Update_SDK_FXP_20200423.pptx.pdf)

- Standard Components to implement:
  - Mojaloop-specification-compliant security:
    - two-way TLS with mutual X.509 authentication
    - JSON Web Signature (JWS) signing of messages
    - generation of the Interledger Protocol (ILP) packet with signing and validation
  - HTTP headers and header processing
  - Scheme Adapter to allow presenting a simplified version of the Mojaloop API to the simulator backend

[Standard Components](https://github.com/mojaloop/sdk-standard-components)

[Scheme Adaptor](https://github.com/mojaloop/sdk-scheme-adapter)
