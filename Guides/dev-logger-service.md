<!-- SPDX-License-Identifier: Apache-2.0 -->

<a id="top"></a>

# Logger Service Template

A simple template for the minimum to integrate a logger service
#### index.ts
```ts
import { LoggerService } from '@tazama-lf/frms-coe-lib';
import type { ProcessorConfig } from '@tazama-lf/frms-coe-lib/lib/config/processor.config';
import { validateProcessorConfig } from '@tazama-lf/frms-coe-lib/lib/config';

// this line will validate that you've got the mandatory processor ENV variables set, and populate the response with the values:
let configuration: ProcessorConfig = validateProcessorConfig();

export const loggerService: LoggerService = new LoggerService(configuration);

// By default, the logger will log to Console if NODE_ENV=dev or NODE_ENV=test
// This will log to the Sidecar which will be deployed with your processor based on the deployment file.
const msgId = crypto.randomUUID(); 
const service = 'logger-example';

// trace, debug, log (info), warn, error, fatal
loggerService.log('sample log', service, msgId);  
```

### .env
```
NODE_ENV=dev
FUNCTION_NAME=relay-service
# MAX_CPU requirement as part of standard env validation for processors in tazama
MAX_CPU=1 

# SIDECAR_HOST requirement for sidecar companion processor (kubernetes)
# SIDECAR_HOST=0.0.0.0:5000 
```

### Dockerfile
```Dockerfile
ARG BUILD_IMAGE=node:20-bullseye
ARG RUN_IMAGE=gcr.io/distroless/nodejs20-debian11:nonroot

# Transpile to JS
FROM ${BUILD_IMAGE} AS builder
LABEL stage=build

WORKDIR /home/app
COPY ./src ./src
COPY ./package*.json ./
COPY ./tsconfig.json ./
COPY .npmrc ./
ARG GH_TOKEN

RUN npm ci --ignore-scripts
RUN npm run build

# Clean up dev
FROM ${BUILD_IMAGE} AS dep-resolver
LABEL stage=pre-prod

COPY package*.json ./
COPY .npmrc ./
ARG GH_TOKEN
RUN npm ci --omit=dev --ignore-scripts

# Runtime
FROM ${RUN_IMAGE} AS run-env
USER nonroot

WORKDIR /home/app
COPY --from=dep-resolver /node_modules ./node_modules
COPY --from=builder /home/app/build ./build
COPY package.json ./
COPY service.yaml ./
COPY deployment.yaml ./

ENV FUNCTION_NAME=relay-service
ENV NODE_ENV=production
ENV SIDECAR_HOST=0.0.0.0:5000

CMD ["build/index.js"]
```
<div style="text-align: right"><a href="#top">Top</a></div>

## 3. Further reading

- Read the [CONTRIBUTING guide](https://github.com/tazama-lf/.github/blob/main/CONTRIBUTING.md) for more details on the contribution process.

Thank you for contributing to Tazama! Your efforts help make our platform smarter, safer, and more insightful for financial ecosystems everywhere. Need assistance? [Open a Discussion](https://github.com/tazama-lf/tazama-project/discussions) or [raise an Issue](https://github.com/tazama-lf/tazama-project/issues).

<div style="text-align: right"><a href="#top">Top</a></div>
