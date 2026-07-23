<!-- SPDX-License-Identifier: Apache-2.0 -->
<!-- Last reviewed: 2026-03-31 -->

# Documentation Style Guide

This style guide ensures that Tazama documentation is consistent, clear, and professional, regardless of the number of contributors.

## Table of Contents

- [Documentation Style Guide](#documentation-style-guide)
  - [Table of Contents](#table-of-contents)
  - [Location](#location)
  - [Document Metadata](#document-metadata)
  - [File Names](#file-names)
  - [Format](#format)
  - [Language and Grammar](#language-and-grammar)
  - [Tone](#tone)
  - [Voice](#voice)
  - [Clarity](#clarity)
  - [Inclusive Language](#inclusive-language)
  - [Terminology](#terminology)
  - [Consistency](#consistency)
  - [Headings and Structure](#headings-and-structure)
  - [Table of Contents](#table-of-contents-1)
  - [Detail](#detail)
  - [Code Formatting](#code-formatting)
  - [Backticks](#backticks)
  - [Admonitions](#admonitions)
  - [Links and References](#links-and-references)
  - [Images](#images)
  - [Further Reading](#further-reading)

## Location

General documentation is maintained in the `docs` repository. Developer documentation is maintained in the README in the repository where the source code is located.

## Document Metadata

Long-lived documents should include a `<!-- Last reviewed: YYYY-MM-DD -->` HTML comment on the second line of the file, directly below the license header. Update this date whenever the document content is reviewed for accuracy.

## File Names

Markdown file names in the `docs` repository should be all lower case with dashes `-` (and no spaces), e.g., rule-processor-overview. The README files in the repositories are named with all CAPS.

## Format

Documentation is created in Markdown files. We recommend using [Markdown All in One by Yu Zhang](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one).

## Language and Grammar

Tazama documentation uses American English. We recommend using [LTeX – LanguageTool grammar/spell checking by Julian Valentin](https://valentjn.github.io/ltex).

## Tone

Friendly, encouraging, and welcoming. The style should convey openness and support for new contributors, making them feel valued and part of the community.

## Voice

Use an active voice and address the reader directly using the second person ("you"). Prefer "Configure the file" or "You can configure the file" over "The file should be configured" or "Users should configure the file."

## Clarity

Ensure that instructions are clear and straightforward. Avoid jargon or overly technical language to make the content accessible to new contributors.

## Inclusive Language

Use inclusive, bias-free language. Avoid terms such as `whitelist`/`blacklist` (use `allowlist`/`denylist`), `master`/`slave` (use `primary`/`replica` or `leader`/`follower`), and `sanity check` (use `confidence check` or `quick check`). Refer to the [Linux Foundation Inclusive Naming Initiative](https://inclusivenaming.org/) for guidance.

## Terminology

Update the project [Glossary](https://github.com/tazama-lf/docs/blob/main/Product/Glossary.md) with acronyms, abbreviations, and industry-specific jargon. Consistent use of terminology helps avoid confusion. Spell out an acronym in full the first time it appears in a document, followed by the acronym in parentheses, e.g., "Transaction Monitoring Service (TMS)". Subsequent uses may use the acronym alone.

## Consistency

Maintain a consistent structure in the text, using bullet points or numbered lists for step-by-step instructions. This helps in readability and easy navigation. We recommend [The Ultimate Markdown Cheat Sheet/ numbered lists and bullets](https://github.com/lifeparticle/Markdown-Cheatsheet?tab=readme-ov-file#lists).

## Headings and Structure

Use multiple levels of numbered headings; see the [Tazama Contribution Guide](https://github.com/tazama-lf/docs/blob/main/Community/Tazama-Contribution-Guide.md) for an example. This helps in organizing content logically and makes it easier to navigate. Capitalize each word for all headings e.g., `## Code Formatting` not `## Code formatting`. We recommend [The Ultimate Markdown Cheat Sheet/ headings](https://github.com/lifeparticle/Markdown-Cheatsheet?tab=readme-ov-file#headings).

## Table of Contents

Include a table of contents at the top of the page and link to the top of the page at intervals throughout the document.

## Detail

Provide enough detail to guide the contributor but avoid overwhelming them with information. Include links to additional resources for those who want to dive deeper.

## Code Formatting

Code snippets should be formatted in their own distinct block, using triple backticks. Always specify the language after the opening backticks, e.g., `json`. This enables syntax highlighting and signals to the reader what syntax to expect. Within documentation, JSON should be formatted automatically using `Shift`+`Alt`+`f`.
![json snippet](/images/contribution-guide-style-json.png)

## Backticks

Single `backticks` are used to format inline code, commands, variables, file names within a sentence. Using backticks appropriately helps in clearly distinguishing code or special text from regular content, enhancing readability and comprehension.

## Admonitions

Use standardized callout blocks to draw attention to important content. Four types are available:

> **NOTE:** Supplementary information that is useful but not critical.
> **TIP:** Optional best-practice suggestions.
> **WARNING:** Information that could cause data loss or unexpected behavior if ignored.
> **IMPORTANT:** Information that the reader must not skip.

## Links and References

Link text should describe the destination, not the action. Never use `click here`, `here`, or `this link` as link text. For example, use "see the [Glossary](link)" not "[click here for the Glossary](link)". We recommend [The Ultimate Markdown Cheat Sheet /links and references](https://github.com/lifeparticle/Markdown-Cheatsheet?tab=readme-ov-file#links).

## Images

Images should be editable `.svg` or `.png` files. See [guide for draw.io](https://github.com/tazama-lf/docs/blob/main/Guides/drawio-guide.md). All images should be saved in the docs/images folder.  

![docs/images folder](/images/contribution-guide-style-images-folder.png)

Image file names should be lower case with dashes `-` (and no spaces). Include the document name and/or section name where the image will be inserted, e.g., contribution-guide-style-images-folder.png.

All images must include descriptive alt text that describes what the image shows, not just the file name, e.g., `![Diagram showing JSON snippet formatting in VS Code](/images/contribution-guide-style-json.png)`. This is required for accessibility (WCAG compliance).

## Further Reading

Read the [CONTRIBUTING guide](https://github.com/tazama-lf/.github/blob/main/CONTRIBUTING.md) for more details on the contribution process.

Thank you for contributing to Tazama! Your efforts help make our platform smarter, safer, and more insightful for financial ecosystems everywhere. Need assistance? [Open a Discussion](https://github.com/tazama-lf/tazama-project/discussions) or [raise an Issue](https://github.com/tazama-lf/tazama-project/issues).