# Entity Resolution Implementation

- [Entity Resolution Implementation](#entity-resolution-implementation)
- [Entity resolution](#entity-resolution)
  - [Objective:](#objective)
  - [Pre-requisites](#pre-requisites)
  - [Process steps](#process-steps)

# Entity resolution

## Objective:

To determine if the debtor (or creditor) in a transaction is the same person that had transacted previously, even if from a different account.

## Pre-requisites

1. Account information from previous transactions have been independently pseudonymised and stored in the Account Lookup Table and includes:

a. DFSP ID  
b. Account ID Type  
c. Account ID  

    The sum of this information provides a unique reference for the account in the platform.

    The account pseudonym can be used to reference the account without exposing the underlying information

2. The Date of Birth information has not (yet) been pseudonymised and is exposed in the following messages:

a. pain.001 – e.g. `CstmrCdtTrfInitn.PmtInf.Dbtr.Id.PrvtId.DtAndPlcOfBirth.BirthDt`

```json
"CstmrCdtTrfInitn": {
    "PmtInf": {
        "Dbtr": {
            "Id": {
                "PrvtId": {
                    "DtAndPlcOfBirth": {
                        "BirthDt": "1953-11-26",
                        "CityOfBirth": "Unknown",
                        "CtryOfBirth": "ZZ"
                    },
```

b. pain.013 – e.g. `CdtrPmtActvtnReq.PmtInf.Dbtr.Id.PrvtId.DtAndPlcOfBirth.BirthDt`  
c. pacs.008 – e.g. `FIToFICstmrCdt.CdtTrfTxInf.Dbtr.Id.PrvtId.DtAndPlcOfBirth.BirthDt`  
d. pacs.002 does not contain any date of birth information  

3. The name information in the ISO 20022 message is a concatenated field that contains the first name, middle name and last name of the debtor. The name information has not (yet) been pseudonymised. The components of these values are stored in the Supplementary Data envelope in the following messages (and only for messages sourced through Mojaloop and the PPA; messages sourced from elsewhere will need an alternative solution, if possible, or utilise the concatenated value.):

a. pain.001 – e.g. `CstmrCdtTrfInitn.PmtInf.CdtTrfTxInf.SplmtryData.Envlp.Doc.Dbtr.FrstNm`  

```json
"CstmrCdtTrfInitn": {
    "PmtInf": {
        "Dbtr": {
            "Nm": "Adam Harper Manfrey",
    
                        .
    
                        .
    
                        .
        },
        "SplmtryData": {
            "Envlp": {
                "Doc": {
                    "Dbtr": {
                        "FrstNm": "Adam",
                        "MddlNm": "Harper",
                        "LastNm": "Manfrey",
```

b. pain.013 does not contain supplementary name information  
c. pacs.008 does not contain supplementary name information  
d. pacs.002 does not contain any name information  

4. There is no address information available (by default) in the ISO message for a Mojaloop implementation, though the Mojaloop extension list could be utilised to host this information. ISO 20022 provides for address information in its structure, but has not been implemented as such for the MVP.

5. There is no citizenship, residency, or place of birth information available (by default) in the ISO message for a Mojaloop implementation, though the Mojaloop extension list could be utilised to host this information. ISO 20022 provides for citizenship, residency and place of birth information in its structure, but has not been implemented as such for the MVP.

![](../../../../images/image-20220901-121651.png)

## Process steps

1. Retrieve all pain.001 transactions from the historical transaction data where the Date of Birth for either the debtor or the creditor matches the Date of Birth for the subject in the current (incoming) transaction

a. It is assumed that the information will not change from pain.001 through to pacs.008 and therefore only pain.001 will be evaluated. If we are evaluating changes to the data from one message to another, that should be either the subject of a typology (data manipulation) or a data quality assurance process (post-MVP).  

2. Check the history for an exact match.

a. Evaluate each record retrieved in step 1.

3. Match incoming debtor against historical debtor

a. Check if the First Name, Middle Name and Last Name of the debtor in the incoming transaction exactly matches the First Name, Middle Name and Last Name of the debtor in the transaction history record

4. If an exact match is found, add the Tazama Entity Identifier from the debtor in the historical record to the debtor in the incoming record, as follows:

a. The current Mojaloop identifier for the debtor is presented in the ISO 20022 pain.001 (and pain.013 and pacs.008) JSON message in the following structure:

```json
"Dbtr": {
    "Nm": "Adam Harper Manfrey",
    "Id": {
        "PrvtId": {
            "DtAndPlcOfBirth": {
                "BirthDt": "1953-11-26",
                "CityOfBirth": "Unknown",
                "CtryOfBirth": "ZZ"
            },
            "Othr": {
                "Id": "+27768052926",
                "SchmeNm": {
                    "Prtry": "MSISDN"
                }
            }
        }
    },
```

 b. The Private Identification data type ([PersonIdentification13](https://www.iso20022.org/standardsrepository/type/PersonIdentification13)) allows for an unbounded number of “Other” ([GenericPersonIdentification1](https://www.iso20022.org/standardsrepository/type/GenericPersonIdentification1)) identification records. Our current implementation of “Other” only caters for a single identification record. To cater for the Tazama Entity Identifier, we have to convert “Other” to an array, as follows:

```json
"Othr": [
    {
        "Id": "+27768052926",
        "SchmeNm": {
            "Prtry": "MSISDN"
        }
    }
]
```

c. Now that the “Other” is an array, we can add another element to the array, as follows:

```json
"Othr": [
    {
        "Id": "+27768052926",
        "SchmeNm": {
            "Prtry": "MSISDN"
        }
    },
    {
        "Id": "",
        "SchmeNm": {
            "Prtry": "TAZAMA_EID"
        }
    }
]
```

The scheme name is proprietary and set to “TAZAMA_EID”.

d. Once the element has been added, set the value of Othr[1].Id in the incoming message to the value for Othr[x].Id in the historical transaction where SchmeNm.Prtry = "TAZAMA_EID".

5. Log the discovery of the match and then stop further entity resolution for the debtor.
6. If the debtor information in the historical record does not match the debtor information in the incoming record, check the creditor information in the historical transaction

a. Check if the First Name, Middle Name and Last Name of the debtor in the incoming transaction exactly matches the First Name, Middle Name and Last Name of the creditor in the transaction history record

7. If an exact match is found, add the Tazama Entity Identifier from the creditor in the historical record to the debtor in the incoming record (see step 4 above).
8. Log the discovery of the match and then stop further entity resolution for the debtor.
9. If an exact match has not been found among the debtors and creditors in the transaction history, the program must check for a suitable fuzzy match instead against each of the transactions in the transaction history result in step 1.

a. Tazama must provide for a configurable threshold to limit the range of a fuzzy match.

i. A threshold value of 0 (zero) means that ONLY exact matches will be allowed and no fuzzy match must be attempted.  
ii. A [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance#:~:text=Informally%2C%20the%20Levenshtein%20distance%20between,considered%20this%20distance%20in%201965.) between two terms of less than or equal to the threshold value will result in a fuzzy match between the two terms.  
iii. The default Levenshtein threshold for the Tazama MVP will be 2.

10. Fuzzy match incoming debtor against historical debtor

a. If the incoming debtor last name fuzzy-matches against the historical record debtor last name (i.e. Levenshtein distance less or equal to the threshold), AND
b. If the incoming debtor first name fuzzy-matches against the historical record debtor first name OR middle name, AND
c. If the incoming debtor middle name is not blank AND fuzzy-matches against the historical record debtor first name OR middle name, THEN

11. Add the historical record message ID and debtor information to a “shortlist”.
a. Message ID:

```json
"CstmrCdtTrfInitn": {
    "GrpHdr": {
        "MsgId": "3cdcc1fb-6008-444f-b5d5-217ad2e6e75b",
```

b. Debtor information:

```json
"CstmrCdtTrfInitn": {
    "PmtInf": {
        "Dbtr": {
            "Nm": "Adam Harper Manfrey",
            "Id": {
                "PrvtId": {
                    "DtAndPlcOfBirth": {
                        "BirthDt": "1953-11-26",
                        "CityOfBirth": "Unknown",
                        "CtryOfBirth": "ZZ"
                    },
                    "Othr": [
                        {
                            "Id": "+27768052926",
                            "SchmeNm": {
                                "Prtry": "MSISDN"
                            }
                        },
                        {
                            "Id": "217ad2e6e75b3cdcc1fb6008444fb5d5",
                            "SchmeNm": {
                                "Prtry": "TAZAMA_EID"
                            }
                        }
                    ]
                }
            },
```

12. Fuzzy match incoming debtor against historical creditor

a. If the incoming debtor last name fuzzy-matches against the historical record creditor last name (i.e. Levenshtein distance less or equal to the threshold), AND  
b. If the incoming debtor first name fuzzy-matches against the historical record creditor first name OR middle name, AND  
c. If the incoming debtor middle name is not blank AND fuzzy-matches against the historical record creditor first name OR middle name, THEN

13. Add the historical record message ID and creditor information to a “shortlist”.

a. Message ID (see 10.d.i. above)  
b. Creditor information:

```json
"CstmrCdtTrfInitn": {
    "PmtInf": {
        "CdtTrfTxInf": {
            "Cdtr": {
                "Nm": "John Manfrey",
                "Id": {
                    "PrvtId": {
                        "DtAndPlcOfBirth": {
                            "BirthDt": "1947-04-09",
                            "CityOfBirth": "Unknown",
                            "CtryOfBirth": "ZZ"
                        },
                        "Othr": [
                            {
                                "Id": "+27768052926",
                                "SchmeNm": {
                                    "Prtry": "MSISDN"
                                }
                            },
                            {
                                "Id": "1fb6008444fb5d5217ad2e6e75b3cdcc",
                                "SchmeNm": {
                                    "Prtry": "TAZAMA_EID"
                                }
                            }
                        ]
                    }
                },
```

14. Count the number of unique Tazama Entity Identifiers in the shortlist.

15. The unique number of Tazama Entity Identifiers in the shortlist must be evaluated to finally resolve the debtor entity.

16. If the unique number of Tazama Entity Identifiers in the shortlist is greater than 1, then there are multiple potential matches for the debtor and these ambiguous matches have not yet been resolved manually by an analyst.

a. Create a new Tazama Entity Identifier for the debtor. Because we cannot resolve the entity against existing entities, we are treating the debtor in the incoming record as if we had not seen the entity on the platform before.  
b. See step 4a to c for guidance on how to prepare the message for the Tazama Entity Identifier.  
c. Create a new Tazama Entity Identifier as a UUIDv4 code (without dashes).  
d. Set the value of `Othr[1].Id` in the incoming message to the new Tazama Entity Identifier.

17. Log the activity
18. Create an entity resolution alert (post-MVP functionality)
19. If the unique number of Tazama Entity Identifiers in the shortlist is equal to 1, then there is only a single potential match for the debtor and it is assumed that the debtor in the incoming transaction is the same as the entity we had previously identified.

a. Add the Tazama Entity Identifier from the only record in the shortlist to the debtor in the incoming record. See step 4 for guidance.

20. Log the activity
21. If the unique number of Tazama Entity Identifiers in the shortlist is 0 (zero), then there are no potential matches for the debtor and we assume that this is the first time we are seeing this debtor in the system.

a. Create a new Tazama Entity Identifier for the debtor, similar to Step 16.

22. Log the activity.
23. Repeat the process above from the perspective of the creditor in the incoming transaction.
