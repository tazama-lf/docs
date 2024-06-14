<!-- SPDX-License-Identifier: Apache-2.0 -->

# POST /transactionRequests

The data fields we can expect in the in the POST /transactionRequests method from Mojaloop.

## Headers

*(See parent page).*

## Body

| **Data Field** | **Sample Value** | **Source** | **ISO20022 compliant Data Field** |
| --- | --- | --- | --- |
| transactionRequestId | a8323bc6-c228-4df2-ae82-e5a997baf890 | UUID |     |
| payee.partyIdInfo.partyIdType | PERSONAL_ID | ENUM<br><br>[https://github.com/mojaloop/central-ledger/blob/master/seeds/partyIdentifierType.js](https://github.com/mojaloop/central-ledger/blob/master/seeds/partyIdentifierType.js) |     |
| payee.partyIdInfo.partyIdentifier | 16135551212 |     |     |
| payee.partyIdInfo.partySubIdOrType | DRIVING_LICENSE | ENUM<br><br>[https://github.com/mojaloop/central-ledger/blob/master/seeds/partyIdentifierType.js](https://github.com/mojaloop/central-ledger/blob/master/seeds/partyIdentifierType.js) |     |
| payee.partyIdInfo.fspId | 1234 |     |     |
| payee.merchantClassificationCode | 4321 |     |     |
| payee.name | Justin Trudeau |     |     |
| payee.personalInfo.complexName.firstName | Justin |     |     |
| payee.personalInfo.complexName.middelName | Pierre |     |     |
| payee.personalInfo.complexName.lastName | Trudeau |     |     |
| payee.personalInfo.dateOfBirth | 1971-12-25 |     |     |
| payer.partyIdInfo.partyIdType | PERSONAL_ID | ENUM<br><br>[https://github.com/mojaloop/central-ledger/blob/master/seeds/partyIdentifierType.js](https://github.com/mojaloop/central-ledger/blob/master/seeds/partyIdentifierType.js) |     |
| payer.partyIdInfo.partyIdentifier | 16135551212 |     |     |
| payer.partyIdInfo.partySubIdOrType | PASSPORT | ENUM<br><br>[https://github.com/mojaloop/central-ledger/blob/master/seeds/partyIdentifierType.js](https://github.com/mojaloop/central-ledger/blob/master/seeds/partyIdentifierType.js) |     |
| payer.partyIdInfo.fspId | 1234 |     |     |
| amount.currency | USD | ENUM<br><br>[https://github.com/mojaloop/central-ledger/blob/master/seeds/currency.js](https://github.com/mojaloop/central-ledger/blob/master/seeds/currency.js) |     |
| amount.amount | 123.45 |     |     |
| transactionType.scenario | DEPOSIT | ENUM<br><br>[https://github.com/mojaloop/central-ledger/blob/master/seeds/transactionScenario.js](https://github.com/mojaloop/central-ledger/blob/master/seeds/transactionScenario.js) |     |
| transactionType.subScenario | “locally defined sub-scenario” |     |     |
| transactionType.initiator | PAYEE | ENUM<br><br>[https://github.com/mojaloop/central-ledger/blob/master/seeds/transactionInitiator.js](https://github.com/mojaloop/central-ledger/blob/master/seeds/transactionInitiator.js) |     |
| transactionType.initiatorType | CONSUMER | ENUM<br><br>[https://github.com/mojaloop/central-ledger/blob/master/seeds/transactionInitiatorType.js](https://github.com/mojaloop/central-ledger/blob/master/seeds/transactionInitiatorType.js) |     |
| transactionType.refundInfo.originalTransactionId | b51ec534-ee48-4575-b6a9-ead2955b8069 |     |     |
| transactionType.refundInfo.refundReason | “free text indicating reason for the refund“ |     |     |
| transactionType.balanceOfPayments | 123 | ENUM<br><br>[https://github.com/mojaloop/central-ledger/blob/master/seeds/balanceOfPayments.js](https://github.com/mojaloop/central-ledger/blob/master/seeds/balanceOfPayments.js) |     |
| note | “Free-text memo” |     |     |
| geoCode.latitude | +45.4215 |     |     |
| geoCode.longitude | +75.6972 |     |     |
| authenticationType | OTP |     |     |
| expiration | 2016-05-24T08:38:08.699-04:00 |     |     |
| extensionList.extension.key | “AdditionalInfo“ |     |     |
| extensionList.extension.value | “This is an ABC Scheme specific element“ |     |     |
