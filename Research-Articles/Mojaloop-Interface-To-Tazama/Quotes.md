<!-- SPDX-License-Identifier: Apache-2.0 -->

# Quotes

As per the **Open API for FSP Interoperability** (FSPIOP) currently based on API Definition.docx updated on 2020-05-19 Version 1.1.

With the option that the quote is not essential to the transaction (the HUB/Switch is optional) it will always be a risk to depend on this data.

## POST /quotes

Used to request the creation of a quote for the provided financial transaction in the server.

The POST /quotes method has the most data, and would recommended as the preferred source to feed into FRM.

If we look at the Mojaloop POST /quote sequence diagram [ref - [https://docs.mojaloop.io/documentation/mojaloop-technical-overview/quoting-service/qs-post-quotes.html](https://docs.mojaloop.io/documentation/mojaloop-technical-overview/quoting-service/qs-post-quotes.html) ], the information that would be most useful to the FRM system, would be the message send during step 13.

See [POST /quotes method](05-Post-Quotes.md) for data content in the POST /quotes method.

## PUT /quotes{ID}

Used to inform the client of a requested or created quote.

The PUT /quotes{ID} method mostly contains transactional information. Could be use to enrich the initial POST /quotes request.

If we look at the Mojaloop PUT /quotes{ID} sequence diagram [ref - [https://docs.mojaloop.io/documentation/mojaloop-technical-overview/quoting-service/qs-post-quotes.html](https://docs.mojaloop.io/documentation/mojaloop-technical-overview/quoting-service/qs-post-quotes.html) ], the information that would be most useful to the FRM system, would be the message send during step 16 or 25.

See [PUT /quotes{ID}](06-Put-Quotesid.md) for data content in the PUT /quotes{ID} method.

## GET /quote{ID}

This method is not used during a transaction process, and is therefore not covered in this exercise.
