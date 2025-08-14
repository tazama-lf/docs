<!-- SPDX-License-Identifier: Apache-2.0 -->

<a id="top"></a>

# Tazama coding practices <!-- omit from toc -->

## Table of Contents <!-- omit from toc -->

- [1. Linting \& Linting rules](#1-linting--linting-rules)
  - [Configuration Overview](#configuration-overview)
  - [Rules Summary](#rules-summary)
    - [Standard and Plugin Rules](#standard-and-plugin-rules)
    - [TypeScript Specific Rules](#typescript-specific-rules)
    - [Stylistic Rules (Custom Plugin)](#stylistic-rules-custom-plugin)
    - [ESLint Comments Plugin](#eslint-comments-plugin)
    - [Ignored Files and Directories](#ignored-files-and-directories)
- [2. Gather asynchronous requests](#2-gather-asynchronous-requests)
- [3. Further reading](#3-further-reading)

## 1. Linting & Linting rules  

Tazama uses [ESLint](https://eslint.org/) to enforce consistency and specific rules in our use of TypeScript. We implemented the ESLint "[flat config](https://eslint.org/blog/2022/08/new-config-system-part-2/)" in release 2.0.0 of Tazama.

This document details the ESLint configuration for TypeScript files as specified in the `eslint.config.mjs` file. The configuration integrates multiple plugins to enforce style and quality standards.

### Configuration Overview 
 
- **Files Targeted**: 
  - Applies to all `.ts` files across the project.

- **Plugins Used**: 
  - Integrates plugins from `eslint-config-love`, `eslint-plugin-eslint-comments`, `@typescript-eslint/eslint-plugin`, and `@stylistic/eslint-plugin`.

- **Parser**: 
  - Uses `@typescript-eslint/parser` for parsing TypeScript files.

- **ECMA Version**: 
  - Configured for ECMAScript 2022 to support modern JavaScript features.

- **Source Type**: 
  - Files are treated as ECMAScript modules.

### Rules Summary  

#### Standard and Plugin Rules  
- Inherits rules from `eslint-config-love`.
- Incorporates recommended rules from `eslint-plugin-eslint-comments`.

#### TypeScript Specific Rules 
- `@typescript-eslint/restrict-template-expressions`: Errors on unsafe usage in template literals.
- `@typescript-eslint/no-non-null-assertion`: Disabled.
- `@typescript-eslint/strict-boolean-expressions`: Disabled to allow any type in conditions.
- `@typescript-eslint/no-explicit-any`: Errors when the `any` type is used, promoting type safety.
- `@typescript-eslint/no-floating-promises`: Allows floating promises without handling.
- `@typescript-eslint/no-var-requires`: Permits using `require` statements in TypeScript.
- `@typescript-eslint/no-use-before-define`: Disabled to allow hoisting.
- `@typescript-eslint/prefer-optional-chain`: Does not enforce using optional chaining.

#### Stylistic Rules (Custom Plugin) 
- `@stylistic/indent`: Enforces 2 spaces for indentation.
- `@stylistic/semi`: Requires semicolons at the end of statements, warning level.
- `@stylistic/quotes`: Enforces single quotes for strings.
- `@stylistic/quote-props`: Requires quotes around object properties when necessary.
- `@stylistic/arrow-parens`: Requires parentheses around arrow function arguments.

#### ESLint Comments Plugin 
- `eslint-comments/require-description`: Warns if ESLint directive comments lack a description.
- `eslint-comments/disable-enable-pair`: Warns to ensure proper use of `eslint-disable` and `eslint-enable` pairs. Sometimes, linting and coding practices collide and a linting override is required to suppress linting alerts over a specific segment of code. While it is possible to override linting for an entire code module, this is not the Tazama way and instead a linting override is expected to only be applied to the specific problematic segment of code via the use of these comment tags above and below the code segment.

#### Ignored Files and Directories 
- **Ignored Locations**: 
  - `**/build/**` or `**/lib/**` // tsc output directory (project)
  - `**/node_modules/**`
  - `**/docs/**`
  - `**/__tests__/**`
  - `**/coverage/**` // jest coverage
  - `**/jest.config.ts` // jest main config
  - `**/jest.testEnv.ts` // jest env config

This setup ensures a robust framework for maintaining high code quality and consistency in TypeScript projects, leveraging ESLint's core capabilities and additional style rules from external plugins.

#### Running Linting

Eslint rules should run by default if husky is set up correctly. Through lint-staged as well as husky's hooks folder for pre-commit and pre-push hooks specifically. If any errors occurs it will prevent a successful commit/push to a branch as errors need to be addressesd before proceeding.

Linting rules can also be manually trigged by developers by running one of the linting scripts found in the package.json usually called `npm run lint:eslint` or `npm run fix` (to also include prettier formatting)

#### Disabling a linting rule

Sometimes linting errors need to be ignored or cannot be addressed and in such cases we allow for inline eslint-disable rules. Accompanied by every eslint-disable a eslint-enable should follow, full file eslint-disables are not allowed. The linter will then error if a justifiable comment is not given alongside the eslint-disable

eg. 
```typescript
/* eslint-disable @typescript-eslint/disallow-funky-code -- <Justified comment here> */
// funky code here
/* eslint-enable @typescript-eslint/disallow-funky-code */
```

<div style="text-align: right"><a href="#top">Top</a></div>

## 2. Gather asynchronous requests 

When you have multiple asynchronous requests to make, Tazama prefers the requests to operate in parallel using [`Promise.all`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all).

<div style="text-align: right"><a href="#top">Top</a></div>

## 3. Further reading

Read the [CONTRIBUTING guide](https://github.com/tazama-lf/.github/blob/main/CONTRIBUTING.md) for more details on the contribution process.

Thank you for contributing to Tazama! Your efforts help make our platform smarter, safer, and more insightful for financial ecosystems everywhere. Need assistance? [Open a Discussion](https://github.com/tazama-lf/tazama-project/discussions) or [raise an Issue](https://github.com/tazama-lf/tazama-project/issues).


<div style="text-align: right"><a href="#top">Top</a></div>
