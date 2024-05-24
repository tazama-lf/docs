# Composition

The Tazama system has the following implementation components:

1. Transaction Monitoring Service (TMS API)
2. Data Preparation (DP)
3. Channel Routing Setup Processor (CRSP)
4. Rules Processor (RP)
5. Typology Processor (TP)
6. Channel Aggregation and Decisioning Processor (CADP)
7. Transaction Aggregation and Decisioning Processor (TADP)

## Products used

All the products used to host/deploy the above components are Cloud-native / Kubernetes-native products

| **Components** | **Deployment** | **Service Mesh** |
| --- | --- | --- |
| Transaction Monitoring Service (TMS API) | OpenFaaS | Linkerd |
| Data Preparation (PD) | NIFI | Linkerd |
| Channel Routing Setup Processor (CRSP) | OpenFaaS | Linkerd |
| Rules Processor (RP) | OpenFaaS | Linkerd |
| Typology Processor (TP) | OpenFaaS | Linkerd |
| Channel Aggregation and Decisioning Processor (CADP) | OpenFaaS | Linkerd |
| Transaction Aggregation and Decisioning Processor (TADP) | OpenFaaS | Linkerd |

## Inputs and Outputs

All the products run independently in their own Kubernetes containers. They take inputs and product outputs. Below are the input and output formats

| **Components** | **Input Protocol / Format** | **Output Format** |
| --- | --- | --- |
| Transaction Monitoring Service (TMS API) | HTTPS REST / JSON | JSON |
| Data Preparation (DP) | HTTPS REST / JSON | JSON |
| Channel Routing Setup Processor (CRSP) | HTTPS REST / JSON | JSON |
| Rules Processor (RP) | HTTPS REST / JSON | JSON |
| Typology Processor (TP) | HTTPS REST / JSON | JSON |
| Channel Aggregation and Decisioning Processor (CADP) | HTTPS REST / JSON | JSON |
| Transaction Aggregation and Decisioning Processor (TADP) | HTTPS REST / JSON | JSON |

## Load Balancing

Linkerd provides the load balancing for any input calls / traffic to all of the above components. Below is an example of how Rules Processor (scaled independently by Kubernetes and load balanced using Linkerd) sends Rule Result to two different Typology Processors (each of them scaled independently by Kubernetes and load balanced using Linkerd)

![](../../images/Untitled_Diagram.drawio.png)
