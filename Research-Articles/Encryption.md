Encryption

1. NATS 

Following the [nats documentation](https://docs.nats.io/running-a-nats-service/configuration/securing_nats/auth_callout#encryption-1) we can use their build in encryption to encrypt messages between processors. This puts the responsibility on the message bus.

Advantages

- Follows JWT Standard, easy to understand and maintain. We already use this standard for our Authentication and Multitenancy
- Changes is mostly config based
- Single point en encryption and decryption

Disadvantages 

- Ties Encryption to NATS, should we ever upgrade or change our message system, we will have to re-do encryption.

Questions

- Which user will be the one using NATS? Platform user, or Org user?

2. Custom Encryption

Using the typescript library crypto, we can manualy perform Encryption using RSA or Public/Private Key encryption. [Crypto Documentation](https://nodejs.org/api/crypto.html)

Advantages 

- Platform Agnostic, once done it will work irrelevant to any changes in our tech stack.
- More Control over encryption

Disadvantages

- Much higher Development time. Would propably require additional functions in the AUTH-LIB
- Key Distribution. The relevant keys would have to be distributed accross the platform.


