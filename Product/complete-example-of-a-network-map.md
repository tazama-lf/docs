<!-- SPDX-License-Identifier: Apache-2.0 -->

# Complete example of a network map

```
    {
        "active": true,
        "cfg": "1.0.0",
        "messages": [
            {
                "id": "004@1.0.0",
                "cfg": "1.0.0",
                "txTp": "pacs.002.001.12",
                "typologies": [
                    {
                        "id": "typology-processor@1.0.0",
                        "cfg": "001@1.0.0",
                        "rules": [
                            {
                                "id": "006@1.0.0",
                                "cfg": "1.0.0"
                            },
                            {
                                "id": "078@1.0.0",
                                "cfg": "1.0.0"
                            },
                            {
                                "id": "EFRuP@1.0.0",
                                "cfg": "none"
                            }
                        ]
                    }
                ]
            }
        ]
    }
```

This network map executes two rule processors (006 and 078) when a pacs.002 transaction is received and summarizes the rule results into typology 001.  The event flow rule processor (EFRuP) is also configured in this typology.