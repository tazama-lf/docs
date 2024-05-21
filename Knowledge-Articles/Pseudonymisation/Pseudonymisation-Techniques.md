# Pseudonymisation Techniques

Whichever technique is employed, pseudonymisation must be unambiguously reversible.

## Single-identifier Pseudonymisation

### Counter

An identifier (the data that identifies a data subject) is substituted by a unique number chosen by a monotonic counter. First, an inception seed 𝑠 is set to an arbitrary value, such as 0, and then it is incremented before being assigned to represent an identifier.

### Random Number Generator

This approach is similar to the counter with the difference that a random number is assigned to the identifier. Two options are available to create this mapping: a true random number generator or a cryptographic pseudo-random generator. Collisions must be resolved to ensure unambiguous reversal.

### Cryptographic Hash Function

A cryptographic hash function takes input strings of arbitrary length (i.e. identifiers) and maps them to fixed  
length outputs. A cryptographic hash function is directly applied to the identifier to obtain the corresponding pseudonym: 𝑃𝑠𝑒𝑢𝑑𝑜 = 𝐻(𝐼𝑑).

### Message Authentication Code

This primitive can be seen as a keyed-hash function. It is very similar to the previous solution except that a secret key is introduced to generate the pseudonym. Without the knowledge of this key, it is not possible to map the identifiers and the pseudonyms.

### Deterministic Encryption

Symmetric (deterministic) encryption and in particular block ciphers like the AES are used to encrypt an identifier using a secret key, which is both the pseudonymisation secret and the recovery secret.

### Probabilistic Encryption

Probabilistic encryption is the use of randomness in an encryption algorithm so that when encrypting the same identifier several times it will, in general, yield different pseudonyms.
