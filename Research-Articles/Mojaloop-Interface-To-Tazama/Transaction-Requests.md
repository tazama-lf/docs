<!-- SPDX-License-Identifier: Apache-2.0 -->

# Transaction Requests

To request the creation of a transaction request for the provided financial transaction in the server.

Information based on **Open API for FSP Interoperability** (FSPIOP) currently based on API Definition.docx updated on 2020-05-19 Version 1.1.

## POST /TransactionRequests

Used to request the creation of a transaction request for the provided financial transaction in the server.

## PUT /TransactionRequestsByID

Used to inform the client of a requested or created transaction request. The \<ID> in the URI should contain the transactionRequestId that was used for the creation of the transaction request, or the \<ID> that was used in the GET /transactionRequests/\<ID>.

## GET /TransactionRequestsByID

Used to get information regarding an earlier created or requested transaction request. The \<ID> in the URI should contain the transactionRequestId that was used for the creation of the transaction request.
