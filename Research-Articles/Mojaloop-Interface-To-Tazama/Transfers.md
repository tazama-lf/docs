<!-- SPDX-License-Identifier: Apache-2.0 -->

# Transfers

Request the creation of a transfer for a financial transaction.

Information based on **Open API for FSP Interoperability** (FSPIOP) currently based on API Definition.docx updated on 2020-05-19 Version 1.1.

## POST /transfers

Transfers

Used to request the creation of a transfer for the next ledger, and a financial transaction for the Payee FSP.

## PUT /transfers/{ID}

TransfersByIDPut

Used to inform the client of a requested or created transfer. The in the URI should contain the transferId that was used for the creation of the transfer, or the that was used in the GET /transfers/.

## GET /transfers/{ID}

TransfersByIDGet

Used to get information regarding an earlier created or requested transfer. The in the URI should contain the transferId that was used for the creation of the transfer.
