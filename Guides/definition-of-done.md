<!-- SPDX-License-Identifier: Apache-2.0 -->

<a id="top"></a>

# Tazama definition of done

The tasks below must be completed by the code contributor before the Pull Request(PR) is submitted:

**Code Complete** - Source code changes are complete for all items in the acceptance criteria in the issue supporting the story. In Tazama, code is distributed amongst a number of different repositories for specific purposes. Code changes in a single repository should be linked to an issue in that repository. Similar changes that affect a number of different repositories, should be documented as an issue in each of those repositories separately.

**Coding Practices** - source code should conform to [Tazama coding practices](https://github.com/tazama-lf/docs/blob/dev/Guides/dev-coding-practices.md) 

**Code Refactoring** - Source code has been refactored to make it comprehensive, maintainable and amenable to change (*unless agreed otherwise as part of refactoring existing legacy code).

**Code Check-in** - Source code is checked in to source code control repository and the PR process is followed.

**Code & Peer reviews** (pull requests) - Code reviews and Peer reviews have been carried out and all improvements implemented and tests completed. Contributor to follow-up and ensure code gets merged in a reasonable time.

**Code Documentation** - Source code has been commented. Complex or compound statements should be explained with a comment, either a comment block (e.g. `/* comment block here */` in TypeScript) or an in-line comment (e.g. `// in-line comment here` in TypeScript). Every function in Tazama must be documented with a preceding [JSDocs docstring](https://www.typescriptlang.org/docs/handbook/jsdoc-supported-types.html).

**Developer Documentation** - The `README.md` file in every GitHub code repository must contain documentation to explain how the code works, in markdown and in diagrams, either in Mermaid or editable `.svg` or `.png` images. See [guide for draw.io](https://github.com/tazama-lf/docs/blob/dev/Guides/drawio-guide.md)

**Licensing comment** Add the following string as a comment ("SPDX-License-Identifier: Apache-2.0") at the top of every file in the organization in GitHub that is capable of including a comment i.e. extensions="ts" "js" "env" "template" "eslintignore" "yaml" "properties" "npmrc" "editorconfig" "dockerignore" "gitignore" "prettierignore" "md" "helmignore" "Makefile" "sh" "npmignore" "plantuml" "yml".

**Unit testing** - Unit test cases have been created in Jest (https://jestjs.io/), executed and are working successfully. Follow [coverage guidelines](https://github.com/tazama-lf/docs/blob/dev/Technical/unit-test-coverage.md). 

<div style="text-align: right"><a href="#top">Top</a></div>

**Processor performance benchmarking** Ensure that the Newman benchmark results have been presented on the PR as a comment. If you notice any spikes in the benchmark, please report the spike or reevaluate the implemented code.

**Automated Builds** - All code is included in automated builds and any updates to the build scripts have been completed and tested and checked in. Jenkins / CircleCI - Poly vs Mono repo

**GitHub CI/CD** - Ensure that all GitHub workflows have completed successfully during PR checks.

**Logging** - Integration with the Tazama Logger Service. Appropriate logging and log levels implemented 
- [Logging framework](https://github.com/tazama-lf/docs/blob/5965e608eaf560b650642de734d98b0f2e7168a0/Technical/Logging/Logging-Framework-Architecture.md) - Architecture of logging services
- [Code Sample](https://github.com/tazama-lf/docs/blob/dev/Guides/dev-logger-service.md) - Logger service code template for processors

**All acceptance criteria are met and Testing complete**

 - **Automated testing** - All existing automated tests have been run successfully

 - **Regression testing** – Regression testing has been carried out successfully

### Guide for maintainers  

**Architecture** - All new code conforms to the agreed architecture (*unless agreed otherwise as part of refactoring existing legacy code). 
<div style="text-align: right"><a href="#top">Top</a></div>

## Further reading

- Read the [CONTRIBUTING guide](https://github.com/tazama-lf/.github/blob/main/CONTRIBUTING.md) for more details on the contribution process.

Thank you for contributing to Tazama! Your efforts help make our platform smarter, safer, and more insightful for financial ecosystems everywhere. Need assistance? [Open a Discussion](https://github.com/tazama-lf/tazama-project/discussions) or [raise an Issue](https://github.com/tazama-lf/tazama-project/issues).