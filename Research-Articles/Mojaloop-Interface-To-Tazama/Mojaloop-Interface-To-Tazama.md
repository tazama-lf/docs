<!-- SPDX-License-Identifier: Apache-2.0 -->

# Mojaloop - Interface to Tazama

Created this page to answer a couple of question.

1. What is messages are we looking at for MVP.
2. What is the content of the selected message.
3. What would be the best point of “interception”.
4. Proposal to Mojaloop.

## Ledger

This ledger is used during the data analysis pages within this section.

|     |     |
| --- | --- |
| Green | Available in Mojaloop messages |
| Orange | Optional in Mojaloop messages |
| Blue | Encrypted part of messages (can’t be used) |
| Purple | Depend on scheme rules enforced |

## Message Headers

The Headers are standard on all messages to, within and from Mojaloop platform.

# Headers

- $ref: '#/parameters/Accept'  
- $ref: '#/parameters/Content-Length'  
- 
- $ref: '#/parameters/Content-Type'  
- $ref: '#/parameters/Date'  
- $ref: '#/parameters/X-Forwarded-For'  
- $ref: '#/parameters/FSPIOP-Source'  
- $ref: '#/parameters/FSPIOP-Destination'  
- $ref: '#/parameters/FSPIOP-Encryption'  
- $ref: '#/parameters/FSPIOP-Signature'  
- $ref: '#/parameters/FSPIOP-URI'  
- $ref: '#/parameters/FSPIOP-HTTP-Method'  
