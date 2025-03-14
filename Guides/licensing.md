<!-- SPDX-License-Identifier: Apache-2.0 -->

## Licensing Guide <!-- omit in toc -->

## Table of Contents <!-- omit in toc -->

- [Overview](#overview)
- [License Information](#license-information)
- [SPDX License Header](#spdx-license-header)
- [Developer Certificate of Origin (DCO)](#developer-certificate-of-origin-dco)
- [Contributing](#contributing)

## Overview

The Tazama project is licensed under the Apache License, Version 2.0 (Apache-2.0). This allows for open collaboration while ensuring that all contributions and modifications are properly licensed under an open-source standard. The Tazama Design Principle, [Open Source First](https://github.com/tazama-lf/docs/blob/dev/Guides/tazama-design-principles.md), provides more context and background information on Tazama licensing.

## License Information

All Tazama source code and content contained in the repositories in the [frmscoe](https://github.com/frmscoe) and [tazama-lf](https://github.com/tazama-lf) organizations is subject to the Apache-2.0 license. By contributing, you agree that your contributions fall under this license.

A copy of the full Apache-2.0 license is available in the LICENSE file in the root of this repository. For more details, visit [Apache License 2.0](https://github.com/tazama-lf/.github/blob/main/LICENSE)

## SPDX License Header

Each file in Tazama repositories (in both frmscoe and tazama-lf organizations) must include the following SPDX license header as a comment at the top of the file:

```
<!-- SPDX-License-Identifier: Apache-2.0 -->
```

This ensures consistency and compliance with licensing requirements across all project files. A GitHub Action will check for the license header when a PR is created.

## Developer Certificate of Origin (DCO)

We require all contributors to sign off their Git commits using the Developer Certificate of Origin (DCO). This means that every commit message must include the following line:

```
Signed-off-by: Your Name <your.email@example.com>
```

By signing off, you certify that you have the right to contribute the changes under the project's license. The DCO ensures that all contributions are made with proper legal authorization and transparency. A [GitHub Action](https://github.com/tazama-lf/workflows/blob/dev/workflow-docs/dco-check.md) will check for DCO when a PR is created.

## Contributing

Before making a contribution, please:

- Ensure your changes include the SPDX license header. This requirement is included in the Definition of Done in the contribution guide.

- Sign off all your commits following the DCO requirements.

- Read the [CONTRIBUTING guide](https://github.com/tazama-lf/.github/blob/main/CONTRIBUTING.md) for more details on the contribution process.

- If you have any questions about licensing or contribution requirements, feel free to open an issue or reach out to the maintainers.

Thank you for contributing!
