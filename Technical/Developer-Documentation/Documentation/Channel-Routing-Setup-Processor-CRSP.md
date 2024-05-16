# 2. Channel Routing & Setup Processor (CRSP)

- [2. Channel Routing \& Setup Processor (CRSP)](#2-channel-routing--setup-processor-crsp)
  - [Sequence Diagram](#sequence-diagram)
  - [Repository](#repository)
  - [Code Activity Diagram](#code-activity-diagram)
  - [Usage](#usage)
  - [Sample JSON Request \& Response](#sample-json-request--response)
    - [Request for Pain001](#request-for-pain001)
    - [Response for Pain001](#response-for-pain001)
    - [Request for Pain013](#request-for-pain013)
    - [Response for Pain013](#response-for-pain013)
    - [Request for Pacs002](#request-for-pacs002)
    - [Response for Pacs002](#response-for-pacs002)
    - [Request for Pacs008](#request-for-pacs008)
    - [Response for Pacs008](#response-for-pacs008)

## Sequence Diagram

Below is the sequence diagram for CRSP

![image](../../../../images/image-20210817-043926.png)

The Channel Router & Setup Processor (CRSP) is where most of the heavy lifting happens. The CRSP is responsible for branching the transaction to all the different rules in the different channels. It uses the Network Map as configuration source, de-duplicates all the rules, generates a network submap (that is sent to Rule Processors), allowing the Rule Processors to know to which Typologies they need to send their results.

## Repository

[channel-router-setup-processor](https://github.com/frmscoe/channel-router-setup-processor)

## Code Activity Diagram

[CRSP.plantuml](https://github.com/frmscoe/uml-diagrams/blob/main/services/CRSP.plantuml)

![](../../../../images/CRSP-Activity-Diagram.png)
![](../../../../images/CRSP.png)

## Usage

CRSP can be initialized by sending an HTTP with the below Postman Collection Example for all current Messaging Types.

[pacs008_postman_request.json](/images/pacs008_postman_request.json)  
[pacs002_postman_request.json](/images/pacs002_postman_request.json)  
[pain013_postman_request.json](/images/pain013_postman_request.json)  
[pain001_postman_request.json](/images/pain001_postman_request.json)  

## Sample JSON Request & Response

``POST request to `/execute endpoint``

### Request for Pain001

```json
{
"TxTp": "pain.001.001.11",
    "CstmrCdtTrfInitn": {
      "GrpHdr": {
        "MsgId": "2669e349-500d-44ba-9e27-7767a16608a0",
        "CreDtTm": "2021-10-07T09:25:31.000Z",
        "NbOfTxs": 1,
        "InitgPty": {
          "Nm": "Ivan Reese Russel-Klein",
          "Id": {
            "PrvtId": {
              "DtAndPlcOfBirth": {
                "BirthDt": "1967-11-23",
                "CityOfBirth": "Unknown",
                "CtryOfBirth": "ZZ"
              },
              "Othr": {
                "Id": "+27783078685",
                "SchmeNm": {
                  "Prtry": "MSISDN"
                }
              }
            }
          },
          "CtctDtls": {
            "MobNb": "+27-783078685"
          }
        }
      },
      "PmtInf": {
        "PmtInfId": "b51ec534-ee48-4575-b6a9-ead2955b8069",
        "PmtMtd": "TRA",
        "ReqdAdvcTp": {
          "DbtAdvc": {
            "Cd": "ADWD",
            "Prtry": "Advice with transaction details"
          }
        },
        "ReqdExctnDt": {
          "Dt": "2021-10-07",
          "DtTm": "2021-10-07T09:25:31.000Z"
        },
        "Dbtr": {
          "Nm": "Ivan Reese Russel-Klein",
          "Id": {
            "PrvtId": {
              "DtAndPlcOfBirth": {
                "BirthDt": "1957-10-05",
                "CityOfBirth": "Unknown",
                "CtryOfBirth": "ZZ"
              },
              "Othr": {
                "Id": "+27783078685",
                "SchmeNm": {
                  "Prtry": "MSISDN"
                }
              }
            }
          },
          "CtctDtls": {
            "MobNb": "+27-783078685"
          }
        },
        "DbtrAcct": {
          "Id": {
            "Othr": {
              "Id": "+27783078685",
              "SchmeNm": {
                "Prtry": "PASSPORT"
              }
            }
          },
          "Nm": "Ivan Russel-Klein"
        },
        "DbtrAgt": {
          "FinInstnId": {
            "ClrSysMmbId": {
              "MmbId": "dfsp001"
            }
          }
        },
        "CdtTrfTxInf": {
          "PmtId": {
            "EndToEndId": "b51ec534-ee48-4575-b6a9-ead2955b8069"
          },
          "PmtTpInf": {
            "CtgyPurp": {
              "Prtry": "TRANSFER"
            }
          },
          "Amt": {
            "InstdAmt": {
              "Amt": {
                "Amt": "50431891779910900",
                "Ccy": "USD"
              }
            },
            "EqvtAmt": {
              "Amt": {
                "Amt": "50431891779910900",
                "Ccy": "USD"
              },
              "CcyOfTrf": "USD"
            }
          },
          "ChrgBr": "DEBT",
          "CdtrAgt": {
            "FinInstnId": {
              "ClrSysMmbId": {
                "MmbId": "dfsp002"
              }
            }
          },
          "Cdtr": {
            "Nm": "April Sam Adamson",
            "Id": {
              "PrvtId": {
                "DtAndPlcOfBirth": {
                  "BirthDt": "1923-04-26",
                  "CityOfBirth": "Unknown",
                  "CtryOfBirth": "ZZ"
                },
                "Othr": {
                  "Id": "+27782722305",
                  "SchmeNm": {
                    "Prtry": "MSISDN"
                  }
                }
              }
            },
            "CtctDtls": {
              "MobNb": "+27-782722305"
            }
          },
          "CdtrAcct": {
            "Id": {
              "Othr": {
                "Id": "+27783078685",
                "SchmeNm": {
                  "Prtry": "MSISDN"
                }
              }
            },
            "Nm": "April Adamson"
          },
          "Purp": {
            "Cd": "MP2P"
          },
          "RgltryRptg": {
            "Dtls": {
              "Tp": "BALANCE OF PAYMENTS",
              "Cd": "100"
            }
          },
          "RmtInf": {
            "Ustrd": "Payment of USD 49932566118723700.89 from Ivan to April"
          },
          "SplmtryData": {
            "Envlp": {
              "Doc": {
                "Cdtr": {
                  "FrstNm": "Ivan",
                  "MddlNm": "Reese",
                  "LastNm": "Russel-Klein",
                  "MrchntClssfctnCd": "BLANK"
                },
                "Dbtr": {
                  "FrstNm": "April",
                  "MddlNm": "Sam",
                  "LastNm": "Adamson",
                  "MrchntClssfctnCd": "BLANK"
                },
                "DbtrFinSvcsPrvdrFees": {
                  "Ccy": "USD",
                  "Amt": "499325661187237"
                },
                "Xprtn": "2021-10-07T09:30:31.000Z"
              }
            }
          }
        }
      },
      "SplmtryData": {
        "Envlp": {
          "Doc": {
            "InitgPty": {
              "InitrTp": "CONSUMER",
              "Glctn": {
                "Lat": "-3.1291",
                "Long": "39.0006"
              }
            }
          }
        }
      }
    }
}
```

### Response for Pain001

```json
{
    "rulesSentTo": [
        "028@1.0",
        "003@1.0"
    ],
    "failedToSend": [
        "005@1.0",
        "006@1.0",
        "007@1.0"
    ],
    "transaction": {
        "TxTp": "pain.001.001.11",
        "CstmrCdtTrfInitn": {
            "GrpHdr": {
                "MsgId": "2669e349-500d-44ba-9e27-7767a16608a0",
                "CreDtTm": "2021-10-07T09:25:31.000Z",
                "NbOfTxs": 1,
                "InitgPty": {
                    "Nm": "Ivan Reese Russel-Klein",
                    "Id": {
                        "PrvtId": {
                            "DtAndPlcOfBirth": {
                                "BirthDt": "1967-11-23",
                                "CityOfBirth": "Unknown",
                                "CtryOfBirth": "ZZ"
                            },
                            "Othr": {
                                "Id": "+27783078685",
                                "SchmeNm": {
                                    "Prtry": "MSISDN"
                                }
                            }
                        }
                    },
                    "CtctDtls": {
                        "MobNb": "+27-783078685"
                    }
                }
            },
            "PmtInf": {
                "PmtInfId": "b51ec534-ee48-4575-b6a9-ead2955b8069",
                "PmtMtd": "TRA",
                "ReqdAdvcTp": {
                    "DbtAdvc": {
                        "Cd": "ADWD",
                        "Prtry": "Advice with transaction details"
                    }
                },
                "ReqdExctnDt": {
                    "Dt": "2021-10-07",
                    "DtTm": "2021-10-07T09:25:31.000Z"
                },
                "Dbtr": {
                    "Nm": "Ivan Reese Russel-Klein",
                    "Id": {
                        "PrvtId": {
                            "DtAndPlcOfBirth": {
                                "BirthDt": "1957-10-05",
                                "CityOfBirth": "Unknown",
                                "CtryOfBirth": "ZZ"
                            },
                            "Othr": {
                                "Id": "+27783078685",
                                "SchmeNm": {
                                    "Prtry": "MSISDN"
                                }
                            }
                        }
                    },
                    "CtctDtls": {
                        "MobNb": "+27-783078685"
                    }
                },
                "DbtrAcct": {
                    "Id": {
                        "Othr": {
                            "Id": "+27783078685",
                            "SchmeNm": {
                                "Prtry": "PASSPORT"
                            }
                        }
                    },
                    "Nm": "Ivan Russel-Klein"
                },
                "DbtrAgt": {
                    "FinInstnId": {
                        "ClrSysMmbId": {
                            "MmbId": "dfsp001"
                        }
                    }
                },
                "CdtTrfTxInf": {
                    "PmtId": {
                        "EndToEndId": "b51ec534-ee48-4575-b6a9-ead2955b8069"
                    },
                    "PmtTpInf": {
                        "CtgyPurp": {
                            "Prtry": "TRANSFER"
                        }
                    },
                    "Amt": {
                        "InstdAmt": {
                            "Amt": {
                                "Amt": "50431891779910900",
                                "Ccy": "USD"
                            }
                        },
                        "EqvtAmt": {
                            "Amt": {
                                "Amt": "50431891779910900",
                                "Ccy": "USD"
                            },
                            "CcyOfTrf": "USD"
                        }
                    },
                    "ChrgBr": "DEBT",
                    "CdtrAgt": {
                        "FinInstnId": {
                            "ClrSysMmbId": {
                                "MmbId": "dfsp002"
                            }
                        }
                    },
                    "Cdtr": {
                        "Nm": "April Sam Adamson",
                        "Id": {
                            "PrvtId": {
                                "DtAndPlcOfBirth": {
                                    "BirthDt": "1923-04-26",
                                    "CityOfBirth": "Unknown",
                                    "CtryOfBirth": "ZZ"
                                },
                                "Othr": {
                                    "Id": "+27782722305",
                                    "SchmeNm": {
                                        "Prtry": "MSISDN"
                                    }
                                }
                            }
                        },
                        "CtctDtls": {
                            "MobNb": "+27-782722305"
                        }
                    },
                    "CdtrAcct": {
                        "Id": {
                            "Othr": {
                                "Id": "+27783078685",
                                "SchmeNm": {
                                    "Prtry": "MSISDN"
                                }
                            }
                        },
                        "Nm": "April Adamson"
                    },
                    "Purp": {
                        "Cd": "MP2P"
                    },
                    "RgltryRptg": {
                        "Dtls": {
                            "Tp": "BALANCE OF PAYMENTS",
                            "Cd": "100"
                        }
                    },
                    "RmtInf": {
                        "Ustrd": "Payment of USD 49932566118723700.89 from Ivan to April"
                    },
                    "SplmtryData": {
                        "Envlp": {
                            "Doc": {
                                "Cdtr": {
                                    "FrstNm": "Ivan",
                                    "MddlNm": "Reese",
                                    "LastNm": "Russel-Klein",
                                    "MrchntClssfctnCd": "BLANK"
                                },
                                "Dbtr": {
                                    "FrstNm": "April",
                                    "MddlNm": "Sam",
                                    "LastNm": "Adamson",
                                    "MrchntClssfctnCd": "BLANK"
                                },
                                "DbtrFinSvcsPrvdrFees": {
                                    "Ccy": "USD",
                                    "Amt": "499325661187237"
                                },
                                "Xprtn": "2021-10-07T09:30:31.000Z"
                            }
                        }
                    }
                }
            },
            "SplmtryData": {
                "Envlp": {
                    "Doc": {
                        "InitgPty": {
                            "InitrTp": "CONSUMER",
                            "Glctn": {
                                "Lat": "-3.1291",
                                "Long": "39.0006"
                            }
                        }
                    }
                }
            }
        }
    },
    "networkMap": {
        "messages": [
            {
                "id": "001@1.0",
                "host": "http://openfaas:8080",
                "cfg": "1.0",
                "txTp": "pain.001.001.11",
                "channels": [
                    {
                        "id": "001@1.0",
                        "host": "http://openfaas:8080",
                        "cfg": "1.0",
                        "typologies": [
                            {
                                "id": "028@1.0",
                                "host": "https://frmfaas.sybrin.com/function/off-typology-processor",
                                "cfg": "028@1.0",
                                "rules": [
                                    {
                                        "id": "003@1.0",
                                        "host": "https://frmfaas.sybrin.com/function/off-rule-003",
                                        "cfg": "1.0"
                                    },
                                    {
                                        "id": "028@1.0",
                                        "host": "https://frmfaas.sybrin.com/function/off-rule-028",
                                        "cfg": "1.0"
                                    }
                                ]
                            },
                            {
                                "id": "029@1.0",
                                "host": "https://frmfaas.sybrin.com/function/off-typology-processor",
                                "cfg": "029@1.0",
                                "rules": [
                                    {
                                        "id": "003@1.0",
                                        "host": "https://frmfaas.sybrin.com/function/off-rule-003",
                                        "cfg": "1.0"
                                    },
                                    {
                                        "id": "005@1.0",
                                        "host": "http://openfaas:8080",
                                        "cfg": "1.0"
                                    }
                                ]
                            }
                        ]
                    },
                    {
                        "id": "002@1.0",
                        "host": "http://openfaas:8080",
                        "cfg": "1.0",
                        "typologies": [
                            {
                                "id": "030@1.0",
                                "host": "https://frmfaas.sybrin.com/function/off-typology-processor",
                                "cfg": "030@1.0",
                                "rules": [
                                    {
                                        "id": "003@1.0",
                                        "host": "https://frmfaas.sybrin.com/function/off-rule-003",
                                        "cfg": "1.0"
                                    },
                                    {
                                        "id": "006@1.0",
                                        "host": "http://openfaas:8080",
                                        "cfg": "1.0"
                                    }
                                ]
                            },
                            {
                                "id": "031@1.0",
                                "host": "https://frmfaas.sybrin.com/function/off-typology-processor",
                                "cfg": "031@1.0",
                                "rules": [
                                    {
                                        "id": "003@1.0",
                                        "host": "https://frmfaas.sybrin.com/function/off-rule-003",
                                        "cfg": "1.0"
                                    },
                                    {
                                        "id": "007@1.0",
                                        "host": "http://openfaas:8080",
                                        "cfg": "1.0"
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        ]
    }
}
```

### Request for Pain013

```json
{
"TxTp": "pain.013.001.09",
    "CstmrCdtTrfInitn": {
      "GrpHdr": {
        "MsgId": "2669e349-500d-44ba-9e27-7767a16608a0",
        "CreDtTm": "2021-10-07T09:25:31.000Z",
        "NbOfTxs": 1,
        "InitgPty": {
          "Nm": "Ivan Reese Russel-Klein",
          "Id": {
            "PrvtId": {
              "DtAndPlcOfBirth": {
                "BirthDt": "1967-11-23",
                "CityOfBirth": "Unknown",
                "CtryOfBirth": "ZZ"
              },
              "Othr": {
                "Id": "+27783078685",
                "SchmeNm": {
                  "Prtry": "MSISDN"
                }
              }
            }
          },
          "CtctDtls": {
            "MobNb": "+27-783078685"
          }
        }
      },
      "PmtInf": {
        "PmtInfId": "b51ec534-ee48-4575-b6a9-ead2955b8069",
        "PmtMtd": "TRA",
        "ReqdAdvcTp": {
          "DbtAdvc": {
            "Cd": "ADWD",
            "Prtry": "Advice with transaction details"
          }
        },
        "ReqdExctnDt": {
          "Dt": "2021-10-07",
          "DtTm": "2021-10-07T09:25:31.000Z"
        },
        "Dbtr": {
          "Nm": "Ivan Reese Russel-Klein",
          "Id": {
            "PrvtId": {
              "DtAndPlcOfBirth": {
                "BirthDt": "1957-10-05",
                "CityOfBirth": "Unknown",
                "CtryOfBirth": "ZZ"
              },
              "Othr": {
                "Id": "+27783078685",
                "SchmeNm": {
                  "Prtry": "MSISDN"
                }
              }
            }
          },
          "CtctDtls": {
            "MobNb": "+27-783078685"
          }
        },
        "DbtrAcct": {
          "Id": {
            "Othr": {
              "Id": "+27783078685",
              "SchmeNm": {
                "Prtry": "PASSPORT"
              }
            }
          },
          "Nm": "Ivan Russel-Klein"
        },
        "DbtrAgt": {
          "FinInstnId": {
            "ClrSysMmbId": {
              "MmbId": "dfsp001"
            }
          }
        },
        "CdtTrfTxInf": {
          "PmtId": {
            "EndToEndId": "b51ec534-ee48-4575-b6a9-ead2955b8069"
          },
          "PmtTpInf": {
            "CtgyPurp": {
              "Prtry": "TRANSFER"
            }
          },
          "Amt": {
            "InstdAmt": {
              "Amt": {
                "Amt": "50431891779910900",
                "Ccy": "USD"
              }
            },
            "EqvtAmt": {
              "Amt": {
                "Amt": "50431891779910900",
                "Ccy": "USD"
              },
              "CcyOfTrf": "USD"
            }
          },
          "ChrgBr": "DEBT",
          "CdtrAgt": {
            "FinInstnId": {
              "ClrSysMmbId": {
                "MmbId": "dfsp002"
              }
            }
          },
          "Cdtr": {
            "Nm": "April Sam Adamson",
            "Id": {
              "PrvtId": {
                "DtAndPlcOfBirth": {
                  "BirthDt": "1923-04-26",
                  "CityOfBirth": "Unknown",
                  "CtryOfBirth": "ZZ"
                },
                "Othr": {
                  "Id": "+27782722305",
                  "SchmeNm": {
                    "Prtry": "MSISDN"
                  }
                }
              }
            },
            "CtctDtls": {
              "MobNb": "+27-782722305"
            }
          },
          "CdtrAcct": {
            "Id": {
              "Othr": {
                "Id": "+27783078685",
                "SchmeNm": {
                  "Prtry": "MSISDN"
                }
              }
            },
            "Nm": "April Adamson"
          },
          "Purp": {
            "Cd": "MP2P"
          },
          "RgltryRptg": {
            "Dtls": {
              "Tp": "BALANCE OF PAYMENTS",
              "Cd": "100"
            }
          },
          "RmtInf": {
            "Ustrd": "Payment of USD 49932566118723700.89 from Ivan to April"
          },
          "SplmtryData": {
            "Envlp": {
              "Doc": {
                "Cdtr": {
                  "FrstNm": "Ivan",
                  "MddlNm": "Reese",
                  "LastNm": "Russel-Klein",
                  "MrchntClssfctnCd": "BLANK"
                },
                "Dbtr": {
                  "FrstNm": "April",
                  "MddlNm": "Sam",
                  "LastNm": "Adamson",
                  "MrchntClssfctnCd": "BLANK"
                },
                "DbtrFinSvcsPrvdrFees": {
                  "Ccy": "USD",
                  "Amt": "499325661187237"
                },
                "Xprtn": "2021-10-07T09:30:31.000Z"
              }
            }
          }
        }
      },
      "SplmtryData": {
        "Envlp": {
          "Doc": {
            "InitgPty": {
              "InitrTp": "CONSUMER",
              "Glctn": {
                "Lat": "-3.1291",
                "Long": "39.0006"
              }
            }
          }
        }
      }
    }
}
```

### Response for Pain013

```json
{
    "rulesSentTo": [
        "003@1.0",
        "028@1.0"
    ],
    "failedToSend": [],
    "networkMap": {},
    "transaction": {
        "TxTp": "pain.013.001.09",
        "CstmrCdtTrfInitn": {
            "GrpHdr": {
                "MsgId": "2669e349-500d-44ba-9e27-7767a16608a0",
                "CreDtTm": "2021-10-07T09:25:31.000Z",
                "NbOfTxs": 1,
                "InitgPty": {
                    "Nm": "Ivan Reese Russel-Klein",
                    "Id": {
                        "PrvtId": {
                            "DtAndPlcOfBirth": {
                                "BirthDt": "1967-11-23",
                                "CityOfBirth": "Unknown",
                                "CtryOfBirth": "ZZ"
                            },
                            "Othr": {
                                "Id": "+27783078685",
                                "SchmeNm": {
                                    "Prtry": "MSISDN"
                                }
                            }
                        }
                    },
                    "CtctDtls": {
                        "MobNb": "+27-783078685"
                    }
                }
            },
            "PmtInf": {
                "PmtInfId": "b51ec534-ee48-4575-b6a9-ead2955b8069",
                "PmtMtd": "TRA",
                "ReqdAdvcTp": {
                    "DbtAdvc": {
                        "Cd": "ADWD",
                        "Prtry": "Advice with transaction details"
                    }
                },
                "ReqdExctnDt": {
                    "Dt": "2021-10-07",
                    "DtTm": "2021-10-07T09:25:31.000Z"
                },
                "Dbtr": {
                    "Nm": "Ivan Reese Russel-Klein",
                    "Id": {
                        "PrvtId": {
                            "DtAndPlcOfBirth": {
                                "BirthDt": "1957-10-05",
                                "CityOfBirth": "Unknown",
                                "CtryOfBirth": "ZZ"
                            },
                            "Othr": {
                                "Id": "+27783078685",
                                "SchmeNm": {
                                    "Prtry": "MSISDN"
                                }
                            }
                        }
                    },
                    "CtctDtls": {
                        "MobNb": "+27-783078685"
                    }
                },
                "DbtrAcct": {
                    "Id": {
                        "Othr": {
                            "Id": "+27783078685",
                            "SchmeNm": {
                                "Prtry": "PASSPORT"
                            }
                        }
                    },
                    "Nm": "Ivan Russel-Klein"
                },
                "DbtrAgt": {
                    "FinInstnId": {
                        "ClrSysMmbId": {
                            "MmbId": "dfsp001"
                        }
                    }
                },
                "CdtTrfTxInf": {
                    "PmtId": {
                        "EndToEndId": "b51ec534-ee48-4575-b6a9-ead2955b8069"
                    },
                    "PmtTpInf": {
                        "CtgyPurp": {
                            "Prtry": "TRANSFER"
                        }
                    },
                    "Amt": {
                        "InstdAmt": {
                            "Amt": {
                                "Amt": "50431891779910900",
                                "Ccy": "USD"
                            }
                        },
                        "EqvtAmt": {
                            "Amt": {
                                "Amt": "50431891779910900",
                                "Ccy": "USD"
                            },
                            "CcyOfTrf": "USD"
                        }
                    },
                    "ChrgBr": "DEBT",
                    "CdtrAgt": {
                        "FinInstnId": {
                            "ClrSysMmbId": {
                                "MmbId": "dfsp002"
                            }
                        }
                    },
                    "Cdtr": {
                        "Nm": "April Sam Adamson",
                        "Id": {
                            "PrvtId": {
                                "DtAndPlcOfBirth": {
                                    "BirthDt": "1923-04-26",
                                    "CityOfBirth": "Unknown",
                                    "CtryOfBirth": "ZZ"
                                },
                                "Othr": {
                                    "Id": "+27782722305",
                                    "SchmeNm": {
                                        "Prtry": "MSISDN"
                                    }
                                }
                            }
                        },
                        "CtctDtls": {
                            "MobNb": "+27-782722305"
                        }
                    },
                    "CdtrAcct": {
                        "Id": {
                            "Othr": {
                                "Id": "+27783078685",
                                "SchmeNm": {
                                    "Prtry": "MSISDN"
                                }
                            }
                        },
                        "Nm": "April Adamson"
                    },
                    "Purp": {
                        "Cd": "MP2P"
                    },
                    "RgltryRptg": {
                        "Dtls": {
                            "Tp": "BALANCE OF PAYMENTS",
                            "Cd": "100"
                        }
                    },
                    "RmtInf": {
                        "Ustrd": "Payment of USD 49932566118723700.89 from Ivan to April"
                    },
                    "SplmtryData": {
                        "Envlp": {
                            "Doc": {
                                "Cdtr": {
                                    "FrstNm": "Ivan",
                                    "MddlNm": "Reese",
                                    "LastNm": "Russel-Klein",
                                    "MrchntClssfctnCd": "BLANK"
                                },
                                "Dbtr": {
                                    "FrstNm": "April",
                                    "MddlNm": "Sam",
                                    "LastNm": "Adamson",
                                    "MrchntClssfctnCd": "BLANK"
                                },
                                "DbtrFinSvcsPrvdrFees": {
                                    "Ccy": "USD",
                                    "Amt": "499325661187237"
                                },
                                "Xprtn": "2021-10-07T09:30:31.000Z"
                            }
                        }
                    }
                }
            },
            "SplmtryData": {
                "Envlp": {
                    "Doc": {
                        "InitgPty": {
                            "InitrTp": "CONSUMER",
                            "Glctn": {
                                "Lat": "-3.1291",
                                "Long": "39.0006"
                            }
                        }
                    }
                }
            }
        }
    }
}
```

### Request for Pacs002

```json
{
"TxTp": "pacs.002.001.12",
    "CstmrCdtTrfInitn": {
      "GrpHdr": {
        "MsgId": "2669e349-500d-44ba-9e27-7767a16608a0",
        "CreDtTm": "2021-10-07T09:25:31.000Z",
        "NbOfTxs": 1,
        "InitgPty": {
          "Nm": "Ivan Reese Russel-Klein",
          "Id": {
            "PrvtId": {
              "DtAndPlcOfBirth": {
                "BirthDt": "1967-11-23",
                "CityOfBirth": "Unknown",
                "CtryOfBirth": "ZZ"
              },
              "Othr": {
                "Id": "+27783078685",
                "SchmeNm": {
                  "Prtry": "MSISDN"
                }
              }
            }
          },
          "CtctDtls": {
            "MobNb": "+27-783078685"
          }
        }
      },
      "PmtInf": {
        "PmtInfId": "b51ec534-ee48-4575-b6a9-ead2955b8069",
        "PmtMtd": "TRA",
        "ReqdAdvcTp": {
          "DbtAdvc": {
            "Cd": "ADWD",
            "Prtry": "Advice with transaction details"
          }
        },
        "ReqdExctnDt": {
          "Dt": "2021-10-07",
          "DtTm": "2021-10-07T09:25:31.000Z"
        },
        "Dbtr": {
          "Nm": "Ivan Reese Russel-Klein",
          "Id": {
            "PrvtId": {
              "DtAndPlcOfBirth": {
                "BirthDt": "1957-10-05",
                "CityOfBirth": "Unknown",
                "CtryOfBirth": "ZZ"
              },
              "Othr": {
                "Id": "+27783078685",
                "SchmeNm": {
                  "Prtry": "MSISDN"
                }
              }
            }
          },
          "CtctDtls": {
            "MobNb": "+27-783078685"
          }
        },
        "DbtrAcct": {
          "Id": {
            "Othr": {
              "Id": "+27783078685",
              "SchmeNm": {
                "Prtry": "PASSPORT"
              }
            }
          },
          "Nm": "Ivan Russel-Klein"
        },
        "DbtrAgt": {
          "FinInstnId": {
            "ClrSysMmbId": {
              "MmbId": "dfsp001"
            }
          }
        },
        "CdtTrfTxInf": {
          "PmtId": {
            "EndToEndId": "b51ec534-ee48-4575-b6a9-ead2955b8069"
          },
          "PmtTpInf": {
            "CtgyPurp": {
              "Prtry": "TRANSFER"
            }
          },
          "Amt": {
            "InstdAmt": {
              "Amt": {
                "Amt": "50431891779910900",
                "Ccy": "USD"
              }
            },
            "EqvtAmt": {
              "Amt": {
                "Amt": "50431891779910900",
                "Ccy": "USD"
              },
              "CcyOfTrf": "USD"
            }
          },
          "ChrgBr": "DEBT",
          "CdtrAgt": {
            "FinInstnId": {
              "ClrSysMmbId": {
                "MmbId": "dfsp002"
              }
            }
          },
          "Cdtr": {
            "Nm": "April Sam Adamson",
            "Id": {
              "PrvtId": {
                "DtAndPlcOfBirth": {
                  "BirthDt": "1923-04-26",
                  "CityOfBirth": "Unknown",
                  "CtryOfBirth": "ZZ"
                },
                "Othr": {
                  "Id": "+27782722305",
                  "SchmeNm": {
                    "Prtry": "MSISDN"
                  }
                }
              }
            },
            "CtctDtls": {
              "MobNb": "+27-782722305"
            }
          },
          "CdtrAcct": {
            "Id": {
              "Othr": {
                "Id": "+27783078685",
                "SchmeNm": {
                  "Prtry": "MSISDN"
                }
              }
            },
            "Nm": "April Adamson"
          },
          "Purp": {
            "Cd": "MP2P"
          },
          "RgltryRptg": {
            "Dtls": {
              "Tp": "BALANCE OF PAYMENTS",
              "Cd": "100"
            }
          },
          "RmtInf": {
            "Ustrd": "Payment of USD 49932566118723700.89 from Ivan to April"
          },
          "SplmtryData": {
            "Envlp": {
              "Doc": {
                "Cdtr": {
                  "FrstNm": "Ivan",
                  "MddlNm": "Reese",
                  "LastNm": "Russel-Klein",
                  "MrchntClssfctnCd": "BLANK"
                },
                "Dbtr": {
                  "FrstNm": "April",
                  "MddlNm": "Sam",
                  "LastNm": "Adamson",
                  "MrchntClssfctnCd": "BLANK"
                },
                "DbtrFinSvcsPrvdrFees": {
                  "Ccy": "USD",
                  "Amt": "499325661187237"
                },
                "Xprtn": "2021-10-07T09:30:31.000Z"
              }
            }
          }
        }
      },
      "SplmtryData": {
        "Envlp": {
          "Doc": {
            "InitgPty": {
              "InitrTp": "CONSUMER",
              "Glctn": {
                "Lat": "-3.1291",
                "Long": "39.0006"
              }
            }
          }
        }
      }
    }
}
```

### Response for Pacs002

```json
{
    "rulesSentTo": [
       "018@1.0.0"
    ],
    "failedToSend": [],
    "transaction": {
        "TxTp": "pacs.002.001.12",
        "CstmrCdtTrfInitn": {
            "GrpHdr": {
                "MsgId": "2669e349-500d-44ba-9e27-7767a16608a0",
                "CreDtTm": "2021-10-07T09:25:31.000Z",
                "NbOfTxs": 1,
                "InitgPty": {
                    "Nm": "Ivan Reese Russel-Klein",
                    "Id": {
                        "PrvtId": {
                            "DtAndPlcOfBirth": {
                                "BirthDt": "1967-11-23",
                                "CityOfBirth": "Unknown",
                                "CtryOfBirth": "ZZ"
                            },
                            "Othr": {
                                "Id": "+27783078685",
                                "SchmeNm": {
                                    "Prtry": "MSISDN"
                                }
                            }
                        }
                    },
                    "CtctDtls": {
                        "MobNb": "+27-783078685"
                    }
                }
            },
            "PmtInf": {
                "PmtInfId": "b51ec534-ee48-4575-b6a9-ead2955b8069",
                "PmtMtd": "TRA",
                "ReqdAdvcTp": {
                    "DbtAdvc": {
                        "Cd": "ADWD",
                        "Prtry": "Advice with transaction details"
                    }
                },
                "ReqdExctnDt": {
                    "Dt": "2021-10-07",
                    "DtTm": "2021-10-07T09:25:31.000Z"
                },
                "Dbtr": {
                    "Nm": "Ivan Reese Russel-Klein",
                    "Id": {
                        "PrvtId": {
                            "DtAndPlcOfBirth": {
                                "BirthDt": "1957-10-05",
                                "CityOfBirth": "Unknown",
                                "CtryOfBirth": "ZZ"
                            },
                            "Othr": {
                                "Id": "+27783078685",
                                "SchmeNm": {
                                    "Prtry": "MSISDN"
                                }
                            }
                        }
                    },
                    "CtctDtls": {
                        "MobNb": "+27-783078685"
                    }
                },
                "DbtrAcct": {
                    "Id": {
                        "Othr": {
                            "Id": "+27783078685",
                            "SchmeNm": {
                                "Prtry": "PASSPORT"
                            }
                        }
                    },
                    "Nm": "Ivan Russel-Klein"
                },
                "DbtrAgt": {
                    "FinInstnId": {
                        "ClrSysMmbId": {
                            "MmbId": "dfsp001"
                        }
                    }
                },
                "CdtTrfTxInf": {
                    "PmtId": {
                        "EndToEndId": "b51ec534-ee48-4575-b6a9-ead2955b8069"
                    },
                    "PmtTpInf": {
                        "CtgyPurp": {
                            "Prtry": "TRANSFER"
                        }
                    },
                    "Amt": {
                        "InstdAmt": {
                            "Amt": {
                                "Amt": "50431891779910900",
                                "Ccy": "USD"
                            }
                        },
                        "EqvtAmt": {
                            "Amt": {
                                "Amt": "50431891779910900",
                                "Ccy": "USD"
                            },
                            "CcyOfTrf": "USD"
                        }
                    },
                    "ChrgBr": "DEBT",
                    "CdtrAgt": {
                        "FinInstnId": {
                            "ClrSysMmbId": {
                                "MmbId": "dfsp002"
                            }
                        }
                    },
                    "Cdtr": {
                        "Nm": "April Sam Adamson",
                        "Id": {
                            "PrvtId": {
                                "DtAndPlcOfBirth": {
                                    "BirthDt": "1923-04-26",
                                    "CityOfBirth": "Unknown",
                                    "CtryOfBirth": "ZZ"
                                },
                                "Othr": {
                                    "Id": "+27782722305",
                                    "SchmeNm": {
                                        "Prtry": "MSISDN"
                                    }
                                }
                            }
                        },
                        "CtctDtls": {
                            "MobNb": "+27-782722305"
                        }
                    },
                    "CdtrAcct": {
                        "Id": {
                            "Othr": {
                                "Id": "+27783078685",
                                "SchmeNm": {
                                    "Prtry": "MSISDN"
                                }
                            }
                        },
                        "Nm": "April Adamson"
                    },
                    "Purp": {
                        "Cd": "MP2P"
                    },
                    "RgltryRptg": {
                        "Dtls": {
                            "Tp": "BALANCE OF PAYMENTS",
                            "Cd": "100"
                        }
                    },
                    "RmtInf": {
                        "Ustrd": "Payment of USD 49932566118723700.89 from Ivan to April"
                    },
                    "SplmtryData": {
                        "Envlp": {
                            "Doc": {
                                "Cdtr": {
                                    "FrstNm": "Ivan",
                                    "MddlNm": "Reese",
                                    "LastNm": "Russel-Klein",
                                    "MrchntClssfctnCd": "BLANK"
                                },
                                "Dbtr": {
                                    "FrstNm": "April",
                                    "MddlNm": "Sam",
                                    "LastNm": "Adamson",
                                    "MrchntClssfctnCd": "BLANK"
                                },
                                "DbtrFinSvcsPrvdrFees": {
                                    "Ccy": "USD",
                                    "Amt": "499325661187237"
                                },
                                "Xprtn": "2021-10-07T09:30:31.000Z"
                            }
                        }
                    }
                }
            },
            "SplmtryData": {
                "Envlp": {
                    "Doc": {
                        "InitgPty": {
                            "InitrTp": "CONSUMER",
                            "Glctn": {
                                "Lat": "-3.1291",
                                "Long": "39.0006"
                            }
                        }
                    }
                }
            }
        }
    },
    "networkMap": {
        "messages": [
            {
                "id": "004@1.0.0",
                "host": "https://gateway.openfaas:8080/function/off-transaction-aggregation-decisioning-processor-rel-1-1-0",
                "cfg": "1.0.0",
                "txTp": "pacs.002.001.12",
                "channels": [
                    {
                        "id": "001@1.0.0",
                        "host": "https://gateway.openfaas:8080/function/off-channel-aggregation-decisioning-processor-rel-1-1-0",
                        "cfg": "1.0.0",
                        "typologies": [
                            {
                                "id": "028@1.0.0",
                                "host": "https://gateway.openfaas:8080/function/off-typology-processor-rel-1-0-0",
                                "cfg": "1.0.0",
                                "rules": [
                                    {
                                        "id": "018@1.0.0",
                                        "host": "https://gateway.openfaas:8080/function/off-rule-018-rel-1-0-0",
                                        "cfg": "1.0.0"
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        ]
    }
}
```

### Request for Pacs008

```json
{
"TxTp": "pacs.008.001.10",
    "CstmrCdtTrfInitn": {
      "GrpHdr": {
        "MsgId": "2669e349-500d-44ba-9e27-7767a16608a0",
        "CreDtTm": "2021-10-07T09:25:31.000Z",
        "NbOfTxs": 1,
        "InitgPty": {
          "Nm": "Ivan Reese Russel-Klein",
          "Id": {
            "PrvtId": {
              "DtAndPlcOfBirth": {
                "BirthDt": "1967-11-23",
                "CityOfBirth": "Unknown",
                "CtryOfBirth": "ZZ"
              },
              "Othr": {
                "Id": "+27783078685",
                "SchmeNm": {
                  "Prtry": "MSISDN"
                }
              }
            }
          },
          "CtctDtls": {
            "MobNb": "+27-783078685"
          }
        }
      },
      "PmtInf": {
        "PmtInfId": "b51ec534-ee48-4575-b6a9-ead2955b8069",
        "PmtMtd": "TRA",
        "ReqdAdvcTp": {
          "DbtAdvc": {
            "Cd": "ADWD",
            "Prtry": "Advice with transaction details"
          }
        },
        "ReqdExctnDt": {
          "Dt": "2021-10-07",
          "DtTm": "2021-10-07T09:25:31.000Z"
        },
        "Dbtr": {
          "Nm": "Ivan Reese Russel-Klein",
          "Id": {
            "PrvtId": {
              "DtAndPlcOfBirth": {
                "BirthDt": "1957-10-05",
                "CityOfBirth": "Unknown",
                "CtryOfBirth": "ZZ"
              },
              "Othr": {
                "Id": "+27783078685",
                "SchmeNm": {
                  "Prtry": "MSISDN"
                }
              }
            }
          },
          "CtctDtls": {
            "MobNb": "+27-783078685"
          }
        },
        "DbtrAcct": {
          "Id": {
            "Othr": {
              "Id": "+27783078685",
              "SchmeNm": {
                "Prtry": "PASSPORT"
              }
            }
          },
          "Nm": "Ivan Russel-Klein"
        },
        "DbtrAgt": {
          "FinInstnId": {
            "ClrSysMmbId": {
              "MmbId": "dfsp001"
            }
          }
        },
        "CdtTrfTxInf": {
          "PmtId": {
            "EndToEndId": "b51ec534-ee48-4575-b6a9-ead2955b8069"
          },
          "PmtTpInf": {
            "CtgyPurp": {
              "Prtry": "TRANSFER"
            }
          },
          "Amt": {
            "InstdAmt": {
              "Amt": {
                "Amt": "50431891779910900",
                "Ccy": "USD"
              }
            },
            "EqvtAmt": {
              "Amt": {
                "Amt": "50431891779910900",
                "Ccy": "USD"
              },
              "CcyOfTrf": "USD"
            }
          },
          "ChrgBr": "DEBT",
          "CdtrAgt": {
            "FinInstnId": {
              "ClrSysMmbId": {
                "MmbId": "dfsp002"
              }
            }
          },
          "Cdtr": {
            "Nm": "April Sam Adamson",
            "Id": {
              "PrvtId": {
                "DtAndPlcOfBirth": {
                  "BirthDt": "1923-04-26",
                  "CityOfBirth": "Unknown",
                  "CtryOfBirth": "ZZ"
                },
                "Othr": {
                  "Id": "+27782722305",
                  "SchmeNm": {
                    "Prtry": "MSISDN"
                  }
                }
              }
            },
            "CtctDtls": {
              "MobNb": "+27-782722305"
            }
          },
          "CdtrAcct": {
            "Id": {
              "Othr": {
                "Id": "+27783078685",
                "SchmeNm": {
                  "Prtry": "MSISDN"
                }
              }
            },
            "Nm": "April Adamson"
          },
          "Purp": {
            "Cd": "MP2P"
          },
          "RgltryRptg": {
            "Dtls": {
              "Tp": "BALANCE OF PAYMENTS",
              "Cd": "100"
            }
          },
          "RmtInf": {
            "Ustrd": "Payment of USD 49932566118723700.89 from Ivan to April"
          },
          "SplmtryData": {
            "Envlp": {
              "Doc": {
                "Cdtr": {
                  "FrstNm": "Ivan",
                  "MddlNm": "Reese",
                  "LastNm": "Russel-Klein",
                  "MrchntClssfctnCd": "BLANK"
                },
                "Dbtr": {
                  "FrstNm": "April",
                  "MddlNm": "Sam",
                  "LastNm": "Adamson",
                  "MrchntClssfctnCd": "BLANK"
                },
                "DbtrFinSvcsPrvdrFees": {
                  "Ccy": "USD",
                  "Amt": "499325661187237"
                },
                "Xprtn": "2021-10-07T09:30:31.000Z"
              }
            }
          }
        }
      },
      "SplmtryData": {
        "Envlp": {
          "Doc": {
            "InitgPty": {
              "InitrTp": "CONSUMER",
              "Glctn": {
                "Lat": "-3.1291",
                "Long": "39.0006"
              }
            }
          }
        }
      }
    }
}
```

### Response for Pacs008

```json
{
    "rulesSentTo": [
       "018@1.0.0"
    ],
    "failedToSend": [],
    "transaction": {
        "TxTp": "pacs.008.001.10",
        "CstmrCdtTrfInitn": {
            "GrpHdr": {
                "MsgId": "2669e349-500d-44ba-9e27-7767a16608a0",
                "CreDtTm": "2021-10-07T09:25:31.000Z",
                "NbOfTxs": 1,
                "InitgPty": {
                    "Nm": "Ivan Reese Russel-Klein",
                    "Id": {
                        "PrvtId": {
                            "DtAndPlcOfBirth": {
                                "BirthDt": "1967-11-23",
                                "CityOfBirth": "Unknown",
                                "CtryOfBirth": "ZZ"
                            },
                            "Othr": {
                                "Id": "+27783078685",
                                "SchmeNm": {
                                    "Prtry": "MSISDN"
                                }
                            }
                        }
                    },
                    "CtctDtls": {
                        "MobNb": "+27-783078685"
                    }
                }
            },
            "PmtInf": {
                "PmtInfId": "b51ec534-ee48-4575-b6a9-ead2955b8069",
                "PmtMtd": "TRA",
                "ReqdAdvcTp": {
                    "DbtAdvc": {
                        "Cd": "ADWD",
                        "Prtry": "Advice with transaction details"
                    }
                },
                "ReqdExctnDt": {
                    "Dt": "2021-10-07",
                    "DtTm": "2021-10-07T09:25:31.000Z"
                },
                "Dbtr": {
                    "Nm": "Ivan Reese Russel-Klein",
                    "Id": {
                        "PrvtId": {
                            "DtAndPlcOfBirth": {
                                "BirthDt": "1957-10-05",
                                "CityOfBirth": "Unknown",
                                "CtryOfBirth": "ZZ"
                            },
                            "Othr": {
                                "Id": "+27783078685",
                                "SchmeNm": {
                                    "Prtry": "MSISDN"
                                }
                            }
                        }
                    },
                    "CtctDtls": {
                        "MobNb": "+27-783078685"
                    }
                },
                "DbtrAcct": {
                    "Id": {
                        "Othr": {
                            "Id": "+27783078685",
                            "SchmeNm": {
                                "Prtry": "PASSPORT"
                            }
                        }
                    },
                    "Nm": "Ivan Russel-Klein"
                },
                "DbtrAgt": {
                    "FinInstnId": {
                        "ClrSysMmbId": {
                            "MmbId": "dfsp001"
                        }
                    }
                },
                "CdtTrfTxInf": {
                    "PmtId": {
                        "EndToEndId": "b51ec534-ee48-4575-b6a9-ead2955b8069"
                    },
                    "PmtTpInf": {
                        "CtgyPurp": {
                            "Prtry": "TRANSFER"
                        }
                    },
                    "Amt": {
                        "InstdAmt": {
                            "Amt": {
                                "Amt": "50431891779910900",
                                "Ccy": "USD"
                            }
                        },
                        "EqvtAmt": {
                            "Amt": {
                                "Amt": "50431891779910900",
                                "Ccy": "USD"
                            },
                            "CcyOfTrf": "USD"
                        }
                    },
                    "ChrgBr": "DEBT",
                    "CdtrAgt": {
                        "FinInstnId": {
                            "ClrSysMmbId": {
                                "MmbId": "dfsp002"
                            }
                        }
                    },
                    "Cdtr": {
                        "Nm": "April Sam Adamson",
                        "Id": {
                            "PrvtId": {
                                "DtAndPlcOfBirth": {
                                    "BirthDt": "1923-04-26",
                                    "CityOfBirth": "Unknown",
                                    "CtryOfBirth": "ZZ"
                                },
                                "Othr": {
                                    "Id": "+27782722305",
                                    "SchmeNm": {
                                        "Prtry": "MSISDN"
                                    }
                                }
                            }
                        },
                        "CtctDtls": {
                            "MobNb": "+27-782722305"
                        }
                    },
                    "CdtrAcct": {
                        "Id": {
                            "Othr": {
                                "Id": "+27783078685",
                                "SchmeNm": {
                                    "Prtry": "MSISDN"
                                }
                            }
                        },
                        "Nm": "April Adamson"
                    },
                    "Purp": {
                        "Cd": "MP2P"
                    },
                    "RgltryRptg": {
                        "Dtls": {
                            "Tp": "BALANCE OF PAYMENTS",
                            "Cd": "100"
                        }
                    },
                    "RmtInf": {
                        "Ustrd": "Payment of USD 49932566118723700.89 from Ivan to April"
                    },
                    "SplmtryData": {
                        "Envlp": {
                            "Doc": {
                                "Cdtr": {
                                    "FrstNm": "Ivan",
                                    "MddlNm": "Reese",
                                    "LastNm": "Russel-Klein",
                                    "MrchntClssfctnCd": "BLANK"
                                },
                                "Dbtr": {
                                    "FrstNm": "April",
                                    "MddlNm": "Sam",
                                    "LastNm": "Adamson",
                                    "MrchntClssfctnCd": "BLANK"
                                },
                                "DbtrFinSvcsPrvdrFees": {
                                    "Ccy": "USD",
                                    "Amt": "499325661187237"
                                },
                                "Xprtn": "2021-10-07T09:30:31.000Z"
                            }
                        }
                    }
                }
            },
            "SplmtryData": {
                "Envlp": {
                    "Doc": {
                        "InitgPty": {
                            "InitrTp": "CONSUMER",
                            "Glctn": {
                                "Lat": "-3.1291",
                                "Long": "39.0006"
                            }
                        }
                    }
                }
            }
        }
    },
    "networkMap": {
        "messages": [
            {
                "id": "005@1.0.0",
                "host": "https://gateway.openfaas:8080/function/off-transaction-aggregation-decisioning-processor-rel-1-1-0",
                "cfg": "1.0.0",
                "txTp": "pacs.008.001.10",
                "channels": [
                    {
                        "id": "001@1.0.0",
                        "host": "https://gateway.openfaas:8080/function/off-channel-aggregation-decisioning-processor-rel-1-1-0",
                        "cfg": "1.0.0",
                        "typologies": [
                            {
                                "id": "028@1.0.0",
                                "host": "https://gateway.openfaas:8080/function/off-typology-processor-rel-1-0-0",
                                "cfg": "1.0.0",
                                "rules": [
                                    {
                                        "id": "018@1.0.0",
                                        "host": "https://gateway.openfaas:8080/function/off-rule-018-rel-1-0-0",
                                        "cfg": "1.0.0"
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        ]
    }
}
