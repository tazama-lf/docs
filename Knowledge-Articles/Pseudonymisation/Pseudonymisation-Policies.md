# Pseudonymisation Policies

Consider an identifier 𝐼𝑑 which appears several times in two datasets 𝐴 and 𝐵. After pseudonymisation, the identifier 𝐼𝑑 is substituted with respect to one of the following policies:

### Deterministic Pseudonymisation

𝐼𝑑 is universally replaced by the same pseudonym 𝑝𝑠𝑒𝑢𝑑𝑜. It is consistent within a database and between different databases.

### Document-randomised pseudonymisation

Each time 𝐼𝑑 appears in a database, it is substituted with a different pseudonym (𝑝𝑠𝑒𝑢𝑑𝑜1, 𝑝𝑠𝑒𝑢𝑑𝑜2,...). However, 𝐼𝑑 is always mapped to the same collection of ( 𝑝𝑠𝑒𝑢𝑑𝑜1, 𝑝𝑠𝑒𝑢𝑑𝑜2) in the dataset 𝐴 and 𝐵.

### Fully randomised pseudonymisation

For any occurrences of 𝐼𝑑 within database 𝐴 or 𝐵, 𝐼𝑑 is replaced by a different pseudonym (𝑝𝑠𝑒𝑢𝑑𝑜1, 𝑝𝑠𝑒𝑢𝑑𝑜2,...).
