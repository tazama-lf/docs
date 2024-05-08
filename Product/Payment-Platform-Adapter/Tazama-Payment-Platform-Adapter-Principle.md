# Tazama Payment Platform Adapter - Principle

Tazama system accepts transactions/messages in ISO 20022 compliant format. We do understand that few of the Hubs / Switches / DFSPs do not support ISO 20022. For them, we offer the Tazama Payment Platform Adapter (PPA).

PPA is offered as part of the Tazama system. However it is designed and implemented in one of the two ways:

1. PPA hosted within the DFSP infrastructure to talk to DFSP backend
2. PPA hosted within Mojaloop / Hub / Switch infrastructure
3. PPA as part of the Mojaloop SDK

## PPA hosted within the DFSP infrastructure

PPA within the DFSP infrastructure will support both ISO 20022 as well as DFSP transaction formats. The PPA securely connects to the Tazama Transaction Monitoring platform.

PPA will need to be customized to perform the DFSP format ↔︎ ISO 20022 compliant format transformations.

![](../../Images/PPA-DFSP.drawio.png)

## PPA hosted within Mojaloop / Hub / Switch infrastructure

PPA within Mojaloop infrastructure will support both ISO 20022 as well as Mojaloop / Hub / Switch formats. The PPA securely connects to the Action Transaction Monitoring platform.

PPA will need to be customized to perform the Mojaloop / Hub / Switch format ↔︎ ISO 20022 compliant format transformations. Below is the high-level diagram for Mojaloop and Tazama Integration using PPA.

![](../../Images/PPA-2.drawio.png)

## PPA as part of the Mojaloop SDK

DFSP can install Mojaloop Scheme Adapter SDK (containing Tazama PPA) to connect to the Tazama Transaction Monitoring platform.

![](../../Images/PPA-3.drawio.png)