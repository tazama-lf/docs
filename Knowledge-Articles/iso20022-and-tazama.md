<!-- SPDX-License-Identifier: Apache-2.0 -->

# ISO20022 and Tazama

- [ISO20022 and Tazama](#iso20022-and-tazama)
  - [What is it?](#what-is-it)
  - [Why do we need it?](#why-do-we-need-it)
  - [What does ISO20022 compliance mean?](#what-does-iso20022-compliance-mean)
  - [Business Model](#business-model)
  - [Data Dictionary](#data-dictionary)
  - [Message Definition Reports](#message-definition-reports)
  - [Mapping Mojaloop to Tazama](#mapping-mojaloop-to-tazama)
  - [Mojaloop message analysis](#mojaloop-message-analysis)
  - [ISO20022: XML vs JSON](#iso20022-xml-vs-json)
  - [Mojaloop to ISO 20022 mapping](#mojaloop-to-iso-20022-mapping)
  - [Mojaloop message enrichment](#mojaloop-message-enrichment)

## What is it?

**ISO 20022** is a multi-part International Standard prepared by ISO Technical Committee TC68 Financial Services. It describes a common system for the development of messages using:

- a modelling methodology to capture in a syntax-independent way financial business areas, business transactions and associated message flows.
- a central dictionary of business items used in financial communications
- a set of XML and ASN.1 design rules to convert the message models into XML or ASN.1 schemas, whenever the use of the ISO 20022 XML or ASN.1-based syntax is preferred

[About ISO 20022 | ISO20022](https://www.iso20022.org/about-iso-20022)

Of particular concern for Tazama is the modelling of business transactions (between users of Tazama client systems and the Tazama systems itself) and associated message flows (external and internal to the Tazama systems).

## Why do we need it?

Our expectation is that we would benefit from the implementation of ISO20022 in two significant ways:

- Because it is an International Standard (not my capitalisation…), we expect to see an increase in the adoption of the standard by companies and platforms that might want to use Tazama for Financial Crime Risk Management services associated with their business transactions. If our interfaces and internal messaging is already ISO20022 compliant, integration with these platforms is generally expected to be easier.
- More directly, the emerging popularity of ISO20022 in Financial Services has created something of an atmosphere of FOMO amongst financial services companies and even though many companies themselves are not yet ISO20022 compliant in the modelling of their business transactions and associated message flows, these companies are increasingly more loathe to even consider introducing new ISO20022 non-compliant products into their eco-systems. For viability and desirability of Tazama as a long-term Financial Crime Risk Management solution, ISO20022 compliance has become essential.

As an OC platform that we are building from scratch (with the help of many open-source products), we have a unique opportunity to build ISO20022 compliance into the design from the beginning.

## What does ISO20022 compliance mean?

ISO20022 compliance is not only about the formatting of messages into, within and out of the Tazama system, but also relates to:

- the terminology that we use to describe business concepts, message concepts and data types, and
- the communication and interaction requirements in and between various Business Areas.

While Tazama itself does not necessarily have any Business Areas, Tazama is expected to be implemented in complex business environments with varied and distributed business operations.

ISO20022 is split into 3 main building blocks:

1. The data model, which is referred to as the ISO20022 Business Model
    1. [Business Model | ISO20022](https://www.iso20022.org/iso20022-repository/business-model)
2. The data dictionary, known as the ISO20022 Repository
    1. [The ISO 20022 Repository | ISO20022](https://www.iso20022.org/financial-repository) :
      - [https://www.iso20022.org/sites/default/files/2020-03/Understanding\_Data\_Dictionary.pdf](https://www.iso20022.org/sites/default/files/2020-03/Understanding_Data_Dictionary.pdf)
      - [https://www.iso20022.org/sites/default/files/2020-02/ISO20022\_Business\_Process\_Catalogue.pdf](https://www.iso20022.org/sites/default/files/2020-02/ISO20022_Business_Process_Catalogue.pdf)
3. Messaging definition reports
    1. [ISO 20022 Message Definitions | ISO20022](https://www.iso20022.org/iso-20022-message-definitions)

From the perspective of the 3 main building blocks of ISO20022, the impact on Tazama can be broadly described as follows:

## Business Model

The business model covered a number of business domains:

| **Domain** | **Description** | **Tazama** |
| --- | --- | --- |
| Common | The business components and their elements that are used to described the Business Concepts that are common to business domains. | MVP |
| Securities | The Securities domain provides the business components and their elements for cash movements related to transactions on equities, fixed income and other securities industry related financial instruments. |     |
| Payments and Cash Management | The Payments domain provides the business components and their elements for all payment activities that relate to transfer of funds between parties. | MVP |
| Trade Services | The Trade Services domain provides the business components and their elements related to all of the Trade Services operations that need to be reported in the statements. |     |
| Foreign Exchange | The Foreign Exchange domain provides the business components and their elements of all operations that are related to the foreign exchange market. Often abbreviated as FOREX. |     |
| Cards and Related Services | The Cards and Related Services domain provides the business components and their elements of all operations that are related to the following non-exhaustive list of financial instruments:<br><br>- Debit card<br>    <br>- Charge and credit card<br>    <br>- Prepaid card |     |

There are currently several thousand different business concepts identified in the business model.

## Data Dictionary

Painfully, you have to browse the data dictionary through search terms online or you have to download the e-repository in EMF format for plug it into the Eclipse Indigo SR2 IDE.

The data dictionary contains terms and definitions, as well as associated elements for each term. For example the Business Component “party” is defined as follows:

![](../../images/image-20210510-075236.png)

Each of the Business Components can be referenced in the Business Model where the components are placed in a simplified business information model represented in UML:

![](../../images/image-20210510-075745.png)

The components that are then involved in a payment can be mapped as follows:

![](../../images/image-20210510-081102.png)

## Message Definition Reports

The Payments and Cash Management domain includes a number of specific Business Areas for which messages have been classified. The following Business Areas are likely to be relevant to the Tazama system, its operator or its clients.

| **Business Area** | **Code** | **Description** | **Tazama** |
| --- | --- | --- | --- |
| Payments Initiation | pain | Messages that support the initiation of a payment from the ordering customer to a financial institution that services a cash account and reporting its status | MVP |
| Payments Clearing and Settlement | pacs | Messages that support the clearing and settlement processes for payment transactions between financial institutions | MVP |
| Cash Management | camt | Messages that support the reporting and advising of the cash side of any financial transactions, including cash movements, transactions and balances, plus any exceptions and investigations related to cash transactions. |     |
| Payments Remittance Advice | remt | Messages that support communication between creditors and debtors regarding remittance details associated with payments. |     |
| Account Management | acmt | Messages that support the management of account related activities, such as the opening and maintenance of an account. |     |
| Administration | admi | Generic messages, ie, system event notifications, generic rejections, etc… |     |
| Authorities Financial  <br>Investigations | auth | Messages that support the provision of miscellaneous financial information to authorities, such as Regulators, Police,  <br>Customs, Tax authorities, Enforcement authorities, Ministries, etc. |     |

[https://www.iso20022.org/sites/default/files/documents/D7/ISO20022\_BusinessAreas.pdf](https://www.iso20022.org/sites/default/files/documents/D7/ISO20022_BusinessAreas.pdf)

Tazama currently focuses on instant payments and funds transfers, but in the future may also include a wider variety of transaction types or lines of business. The scope of the ISO 20022 messages accommodated by Tazama would have to be revisited when the variety increases.

Of particular future interest to Tazama would be the messages related to the Fraud Reporting and Disposition Business Area; however these messages are currently related to the Card Payments and Related Transactions domain and are not suitable in a general context. It may be worth exploring the content of the Fraud Reporting messages to see if there is any benefit in using these as a template for the results reporting out of Tazama.

**Business Area: Fraud Reporting and Disposition**

[https://www.iso20022.org/business-area-message-set/366/881/download](https://www.iso20022.org/business-area-message-set/366/881/download)

| **Message ID** | **Description** |
| --- | --- |
| cafr.001.001.01 | A **FraudReportingInitiation** message is usually sent by a financial institution acting as an acquirer or as an issuer to an agent (processor, agent) to inform about a confirmed fraudulent transaction. |
| cafr.002.001.01 | A **FraudReportingResponse** message is sent by an agent (processor, agent) to an issuer or acquirer in response to a FraudReportingInitiation message. |
| cafr.003.001.01 | A **FraudDispositionInitiation** message is usually sent by an agent to a financial institution acting as an acquirer or as an issuer to report about the disposition of a confirmed fraudulent transaction. |
| cafr.004.001.01 | A **FraudDispositionResponse** message is sent by an issuer or acquirer to an agent (processor, agent) in response to a FraudDispositionInitiation message. |

Within each of the Business Areas, there are several messages defined to meet specific business model/process requirements. The messages available for pacs and pain are listed below. Note the structure of each message:

![](../../images/image-20210519-104337.png)

| **Message ID** | **Description** | **Tazama** |
| --- | --- | --- |
| pacs.002.001.11 | The **FIToFIPaymentStatusReport** message is sent by an instructed agent to the previous party in the payment chain. It is used to inform this party about the positive or negative status of an instruction (either single or file). It is also used to report on a pending instruction. | **MVP** |
| pacs.003.001.08 | The **FIToFICustomerDirectDebit** message is sent by the creditor agent to the debtor agent, directly or through other agents and/or a payment clearing and settlement system.  <br>It is used to collect funds from a debtor account for a creditor. |     |
| pacs.004.001.10 | The **PaymentReturn** message is sent by an agent to the previous agent in the payment chain to undo a payment previously settled. |     |
| pacs.007.001.10 | The **FIToFIPaymentReversal** message is sent by an agent to the next party in the payment chain. It is used to reverse a payment previously executed. |     |
| pacs.008.001.09 | The **FIToFICustomerCreditTransfer** message is sent by the debtor agent to the creditor agent, directly or through other agents and/or a payment clearing and settlement system. It is used to move funds from a debtor account to a creditor. | **MVP** |
| pacs.009.001.09 | The **FinancialInstitutionCreditTransfer** message is sent by a debtor financial institution to a creditor financial institution, directly or through other agents and/or a payment clearing and settlement system.  <br>It is used to move funds from a debtor account to a creditor, where both debtor and creditor are financial institutions. |     |
| pacs.010.001.04 | The **FinancialInstitutionDirectDebit** message is sent by an exchange or clearing house, or a financial institution, directly or through another agent, to the DebtorAgent. It is used to instruct the DebtorAgent to move funds from one or more debtor(s) account(s) to one or more creditor(s), where both debtor and creditor are financial institutions. |     |
| pacs.028.001.04 | The **FIToFIPaymentStatusRequest** message is sent by the debtor agent to the creditor agent, directly or through other agents and/or a payment clearing and settlement system. It is used to request a FIToFIPaymentStatusReport message containing information on the status of a previously sent instruction. |     |
| pain.001.001.11 | The **CustomerCreditTransferInitiation** message is sent by the initiating party to the forwarding agent or debtor agent. It is used to request movement of funds from the debtor account to a creditor. | **MVP** |
| pain.002.001.11 | The **CustomerPaymentStatusReport** message is sent by an instructed agent to the previous party in the payment chain. It is used to inform this party about the positive or negative status of an instruction (either single or file). It is also used to report on a pending instruction. |     |
| pain.007.001.10 | The **CustomerPaymentReversal** message is sent by the initiating party to the next party in the payment chain. It is used to reverse a payment previously executed. |     |
| pain.008.001.09 | The **CustomerDirectDebitInitiation** message is sent by the initiating party to the forwarding agent or creditor agent. It is used to request single or bulk collection(s) of funds from one or various debtor's account(s) for a creditor. |     |
| pain.009.001.05 | The **MandateInitiationRequest** message is sent by the initiator of the request to his agent. The initiator can either be the debtor or the creditor.  <br>The MandateInitiationRequest message is forwarded by the agent of the initiator to the agent of the counterparty.  <br>The MandateInitiationRequest message is used to setup the instruction that allows the debtor agent to accept instructions from the creditor, through the creditor agent, to debit the account of the debtor. |     |
| pain.010.001.05 | The **MandateAmendmentRequest** message is sent by the initiator of the request to his agent and/or counterparty. The initiator can both be the debtor or the creditor (or where appropriate the debtor agent).  <br>The MandateAmendmentRequest message is forwarded by the agent of the initiator to the agent of the counterparty.  <br>A MandateAmendmentRequest message is used to request the amendment of specific information in an existing mandate. The MandateAmendmentRequest message must reflect the new data of the element(s) to be amended and at a minimum a unique reference to the existing mandate. If accepted, this MandateAmendmentRequest message together with the MandateAcceptanceReport message confirming the acceptance will be considered as a valid amendment on an existing mandate, agreed upon by all parties. The amended mandate will from then on be considered the valid mandate. |     |
| pain.011.001.05 | The **MandateCancellationRequest** message is sent by the initiator of the request to his agent. The initiator can either be the debtor or the creditor.  <br>The MandateCancellationRequest message is forwarded by the agent of the initiator to the agent of the counterparty.  <br>A MandateCancellationRequest message is used to request the cancellation of an existing mandate. If accepted, this MandateCancellationRequest message together with the MandateAcceptanceReport message confirming the acceptance will be considered a valid cancellation of an existing mandate, agreed upon by all parties. |     |
| pain.012.001.05 | The **MandateAcceptanceReport** message is sent from the agent of the receiver (debtor or creditor) of the MandateRequest message (initiation, amendment or cancellation) to the agent of the initiator of the MandateRequest message (debtor or creditor).  <br>A MandateAcceptanceReport message is used to confirm the acceptance or rejection of a MandateRequest message. Where acceptance is part of the full process flow, a MandateRequest message only becomes valid after a confirmation of acceptance is received through a MandateAcceptanceReport message from the agent of the receiver. |     |
| pain.013.001.08 | The **CreditorPaymentActivationRequest** message is sent by the Creditor sending party to the Debtor receiving party, directly or through agents. It is used by a Creditor to request movement of funds from the debtor account to a creditor. | **MVP** |
| pain.014.001.08 | The **CreditorPaymentActivationRequestStatusReport** message is sent by a party to the next party in the creditor payment activation request chain. It is used to inform the latter about the positive or negative status of a creditor payment activation request (either single or file). |     |
| pain.017.001.01 | The **MandateCopyRequest** message is sent by the initiator of the request to his agent. The initiator can either be the debtor or the creditor.  <br>The MandateCopyRequest message is forwarded by the agent of the initiator to the agent of the counterparty.  <br>A MandateCopyRequest message is used to request a copy of an existing mandate. If accepted, the mandate copy can be sent using the MandateAcceptanceReport message. |     |
| pain.018.001.01 | The **MandateSuspensionRequest** message is sent by the initiator of the request to its agent. The initiator can either be the debtor, debtor agent, creditor or creditor agent.  <br>A MandateSuspensionRequest message is used to request the suspension of an existing mandate until the suspension is lifted. |     |

PACS MDR: [https://www.iso20022.org/message/mdr/20766/download](https://www.iso20022.org/message/mdr/20766/download)

PAIN 001 - 008 MDR: [https://www.iso20022.org/message/mdr/20821/download](https://www.iso20022.org/message/mdr/20821/download)

PAIN 009 - 012, 017, 018 MDR: [https://www.iso20022.org/message/mdr/14536/download](https://www.iso20022.org/message/mdr/14536/download)

PAIN 013 - 014 MDR: [https://www.iso20022.org/message/mdr/20381/download](https://www.iso20022.org/message/mdr/20381/download)

## Mapping Mojaloop to Tazama

![](../../images/Untitled_Diagram.drawio.png)

***Figure 1**: PAIN and PACS in Mojaloop*

In Mojaloop, the QUOTES messages are translated to pain.001 (POST) and pain.013 (PUT) and the TRANSFER messages are translated to pacs.008 (POST) and pacs.002 (PUT).

Our approach for mapping the data requirements for Tazama, and specifically in relation to incoming Mojaloop data, is to:

1. Identify the Mojaloop data fields that are available to Tazama as part of the QUOTE and TRANSFER messages
2. Group the Mojaloop data fields by ISO20022 business components, as defined in the ISO20022 data dictionary
3. Identify a suitable data element to represent the data in the Tazama system as an ISO20022 compliant element
4. Specify the transformation requirements for the Mojaloop field to the ISO20022 element
5. Identify additional minimum data fields required in the ISO20022 message that are not available in the Mojaloop messages and source suitable values for these fields.

Further work will be required to design a fully compliant ISO20022 data model for Tazama that includes the data that we are intending to use for the Transaction Monitoring Service.

## Mojaloop message analysis

Initial analysis of the current Mojaloop messages show the following:

- The POST /quotes messages contains the most detailed information out of the all of the Mojaloop messages. Later messages do not repeat the information in the POST /quotes message. If later messages are to be evaluated effectively, they would need to be enriched with the data from earlier messages during Tazama data preparation.
- Not every Mojaloop implementation follows the quote-transfer pattern and some systems may be deployed without a quotes process. The transfers messages do not currently contain any identifying information for either the Payer (debtor) or the Payee (creditor) and without the preceding quotes messages, the Tazama system will not be able to reference this information for the transaction evaluation.
- Not all of the data that is required for transaction evaluation is available from Mojaloop. The Tazama team have taken the design decision that all data required for evaluation of a transaction would be supplied in the transaction message, and not through parallel enrichment. Privacy legislation such as GDPR constrains Tazama’s ability to collect personal information for an unauthorised purpose and we would not be able to collect personal information on the expectation of a future transaction - we would only be able to collect personal information as part of the actual transaction.
- The Mojaloop message provides an Extension List facility where additional data that does not fit natively withing the Mojaloop message can be supplied. It is recommended that the Extension List be used to supply additional information that is required for transaction evaluation, and also to supplement transfers messages in the absence of a quotes process.
- The Mojaloop quotes messages do not have a direct equivalent in the ISO 20022 message schema. The ISO20022 messages are more concerned with the fulfilment of the payment, and not so much with the protocols and processes employed by a system to set up the circumstances for a payment, such as a quoting process. Mojaloop selected the Payment Initiation Business Area and specifically the pain.001 and pain.013 messages to represent the quotes messages and Tazama has adopted this approach as well.

## ISO20022: XML vs JSON

In ISO 20022, the most widely used syntax is eXtensible Mark-up Language (XML), while the preferred syntax in Tazama interfaces and messaging to date has been JavaScript Object Notation (JSON). In reality, ISO20022 as a standard is syntax-neutral and the ISO20022 Technical Support Group has issued a best-practices white paper on to assist implementers to define RESTful Web Service APIs with resources represented in XML and/or JSON syntax.

[https://www.iso20022.org/sites/default/files/documents/D7/ISO20022\_API\_JSON\_Whitepaper\_Final\_20180129.pdf](https://www.iso20022.org/sites/default/files/documents/D7/ISO20022_API_JSON_Whitepaper_Final_20180129.pdf)

## Mojaloop to ISO 20022 mapping

The spreadsheet below details the mapping between Mojaloop quotes and transfers messages and their ISO 20022 equivalents:

[Mojaloop_to_ISO20022_mapping_-_v.0.5_20210824.xlsx](/images/Mojaloop_to_ISO20022_mapping_-_v.0.5_20210824.xlsx)

Note: this version of the mapping contains an update for the following mapping:

**pain.001: corrected:**

CustomerCreditTransferInitiationV11.PaymentInformation.DebtorAccount.Identification.Other.**~Identification~**.SchemeName.Proprietary

CustomerCreditTransferInitiationV11.PaymentInformation.CreditTransferTransactionInformation.CreditorAccount.Identification.Other.**~Identification~**.SchemeName.Proprietary

**pain.013: corrected:**

CreditorPaymentActivationRequestV09.PaymentInformation.DebtorAccount.Identification.Other.**~Identification~**.SchemeName.Proprietary

CreditorPaymentActivationRequestV09.PaymentInformation.CreditTransferTransactionInformation.CreditorAccount.Identification.Other.**~Identification~**.SchemeName.Proprietary

**pacs.008: corrected:**

FIToFICustomerCreditTransferV10.CreditTransferTransactionInformation.CreditorAccount.Identification.Other.**~Identification~**.SchemeName.Proprietary

FIToFICustomerCreditTransferV10.CreditTransferTransactionInformation.DebtorAccount.Identification.Other.**~Identification~**.SchemeName.Proprietary

**pacs.002: no change**

Previous version of the mapping:

[Mojaloop_to_ISO20022_mapping_-_v.0.4_20210630.xlsx](/images/Mojaloop_to_ISO20022_mapping_-_v.0.4_20210630.xlsx)

| **Tab** | **Contents** |
| --- | --- |
| Mojaloop Messages | This tab details the fields available in each of the four Mojaloop messages:<br><br>- POST /quotes<br>    <br>- PUT /quotes<br>    <br>- POST /transfers<br>    <br>- PUT /transfers<br>    <br><br>Each field is defined according to the Mojaloop specification:<br><br>[https://github.com/mojaloop/mojaloop-specification/blob/master/fspiop-api/documents/API-Definition\_v1.1.md](https://github.com/mojaloop/mojaloop-specification/blob/master/fspiop-api/documents/API-Definition_v1.1.md)<br><br>and Swagger definition:<br><br>[https://docs.mojaloop.io/api-snippets/?urls.primaryName=v1.1](https://docs.mojaloop.io/api-snippets/?urls.primaryName=v1.1) |
| pain.001.001.11 | This tab contains the mapping of the Mojaloop POST /quotes message to ISO 20022 pain.001.001.11.<br><br>**A**: pain.001 field XPath<br><br>**B (hidden)**: Reconciliation with the initial Tazama implementation of pain.001 to close any gaps<br><br>**C**: The Mojaloop equivalent for the ISO field, or a substitute/default alternative if a Mojaloop field is not available<br><br>**D**: The origin of the field, i.e.<br><br>- **Created**: The ISO field is created/populated by the Payment Platform Adapter<br>    <br>- **Inferred**: The ISO field is defaulted based on our understanding of the Mojaloop message<br>    <br>- **Calculated**: The ISO field is derived based on other, related information in the Mojaloop message<br>    <br>- **Copied**: The ISO field is directly copied from the indicated Mojaloop field.<br>    <br><br>**E**: The standard ISO type (field description) for the field<br><br>**F**: The ISO field description for the field<br><br>**G**: Any pertinent notes on the transformation of the field |
| pain.013.001.09 | This tab contains the mapping of the Mojaloop PUT /quotes message to ISO 20022 pain.013.001.09.<br><br>The structure in this sheet is similar to that of pain.001.001.11. |
| pacs.008.001.10 | This tab contains the mapping of the Mojaloop POST /transfers message to ISO 20022 pacs.008.001.10.<br><br>The structure in this sheet is similar to that of pain.001.001.11. |
| pacs.002.001.12 | This tab contains the mapping of the Mojaloop PUT /transfers message to ISO 20022 pacs.002.001.12.<br><br>The structure in this sheet is similar to that of pain.001.001.11. |
| Rules Coverage | This sheet details the current identified rules and maps the rule data requirements to the pain.001.001.11 message. |
| POST quotes<br><br>PUT quotes<br><br>POST transfers<br><br>PUT transfers | For reference only, the original Mojaloop mapping of the messages as provided by Michael Richards of ModusBox. |
| Etc | The remaining tabs contain lists of values for some of the fields in the Mojaloop messages. The tab name is the field name that relates to the list of values for that field. |

## Mojaloop message enrichment

![](../../images/Tazama_ISO_enrichment.png)
