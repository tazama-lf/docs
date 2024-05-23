<!-- SPDX-License-Identifier: Apache-2.0 -->

# PUT /transactionRequest{ID}

The data fields we can expect in the in the PUT /transactionRequests method from Mojaloop.

## Headers

The transactionRequestId \<ID> is a required field for this method.

*(See parent page).*

## Body

| **Data Field** | **Sample Value** | **Source** | **ISO20022 compliant Data Field** |
| --- | --- | --- | --- |
| transactionId | a8323bc6-c228-4df2-ae82-e5a997baf890 | UUID |     |
| transactionRequestState | RECEIVED | ENUM<br><br>[https://github.com/mojaloop/central-ledger/blob/master/seeds/transferState.js](https://github.com/mojaloop/central-ledger/blob/master/seeds/transferState.js) |     |
| extensionList.extension.key | “AdditionalInfo“ |     |     |
| extensionList.extension.value | “This is an ABC Scheme specific element“ |     |     |
