# Mojaloop Payment Platform Adapter

The updated Payment Platform Adapter (PPA) is required to transform Mojaloop transactions/messages into the ISO 20022 format, so that Mojaloop messages can be send to the [Transaction Monitoring Service API](https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/6389785/Transaction+Monitoring+Service+API)

The PPA is deployed within Mojaloop as it requires access to Mojaloop's message event store built using Kafka. The PPA will transform the relevant events into the appropriate [pain and pacs](https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/6389792/ISO20022+and+Actio) messages and forwarded to the FRMS Platform.

As events in Mojaloop do not have full context of a transaction a cache is used to keep reference of the initial pain001 message to map out the formatted ISO message and their subsequent events. The transformations done on these Mojaloop events can be found in the mapper module.

![](../../Images/ppa-flow-20221010-144730.png)

ISO Mappings

[Mojaloop_to_ISO20022_mapping_V1.1_20210531.xlsx](/Images/Mojaloop_to_ISO20022_mapping_V1.1_20210531.xlsx)
