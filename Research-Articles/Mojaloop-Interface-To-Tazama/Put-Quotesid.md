<!-- SPDX-License-Identifier: Apache-2.0 -->

# PUT /quotes{ID}

The data fields we can expect in the PUT /quotes{ID} method in mojaloop.

## Headers

*(See parent page).*

{ID} is a required field for this method.

## Body

| **Data Field** | **Sample Value** | **Source** | **ISO20022 compliant Data Field** |
| --- | --- | --- | --- |
| transferAmount.currency | USD | ENUM |     |
| transferAmount.amount | 124.45 |     |     |
| payeeReceiveAmount.currency | USD | ENUM |     |
| payeeReceiveAmount.amount | 123.45 |     |     |
| payeeFspFee.currency | USD | ENUM |     |
| payeeFspFee.amount | 1.45 |     |     |
| payeeFspCommission.currency | USD | ENUM |     |
| payeeFspCommission.amount | 0   |     |     |
| expiration | 2016-05-24T08:38:08.699-04:00 |     |     |
| geoCode.latitude | +45.4215 |     |     |
| geoCode.longitude | +75.6972 |     |     |
| ilpPacket | AYIBgQAAAAAAAASwNGxldmVsb25lLmRmc3AxLm1lci45T2RTOF81MDdqUUZERmZlakgyOVc4bXFmNEpLMHlGTFGCAUBQU0svMS4wCk5vbmNlOiB1SXlweUYzY3pYSXBFdzVVc05TYWh3CkVuY3J5cHRpb246IG5vbmUKUGF5bWVudC1JZDogMTMyMzZhM2ItOGZhOC00MTYzLTg0NDctNGMzZWQzZGE5OGE3CgpDb250ZW50LUxlbmd0aDogMTM1CkNvbnRlbnQtVHlwZTogYXBwbGljYXRpb24vanNvbgpTZW5kZXItSWRlbnRpZmllcjogOTI4MDYzOTEKCiJ7XCJmZWVcIjowLFwidHJhbnNmZXJDb2RlXCI6XCJpbnZvaWNlXCIsXCJkZWJpdE5hbWVcIjpcImFsaWNlIGNvb3BlclwiLFwiY3JlZGl0TmFtZVwiOlwibWVyIGNoYW50XCIsXCJkZWJpdElkZW50aWZpZXJcIjpcIjkyODA2MzkxXCJ9IgA | encrypted |     |
| condition | f5sqb7tBTWPd5Y8BDFdMm9BJR_MNI4isf8p8n4D5pHA | encrypted |     |
| extension.key | AdditionalInfo |     |     |
| extension.value | “This is a customized extension for the ABC Scheme” |     |     |
