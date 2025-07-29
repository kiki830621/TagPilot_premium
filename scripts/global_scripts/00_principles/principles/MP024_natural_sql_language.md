---
id: "MP0024"
title: "Natural SQL Language"
type: "meta-principle"
date_created: "2025-04-03"
date_modified: "2025-04-04"
author: "Claude"
derives_from:
  - "MP0000": "Axiomatization System"
  - "MP0020": "Principle Language Versions"
  - "MP0023": "Language Preferences"
influences:
  - "P13": "Language Standard Adherence Principle"
---

# Natural SQL Language (NSQL)

## Core Principle

The Natural SQL Language (NSQL) serves as a human-readable, precise meta-language for expressing data transformation operations. By focusing on what data manipulations should be performed rather than how they should be implemented, NSQL enables clearer communication, better documentation, and more flexible implementation of data operations across the precision marketing system.

## Implementation Reference

The complete specification, implementation, and usage guidelines for NSQL are maintained in the 16_NSQL_Language directory:

```
/global_scripts/16_NSQL_Language/
```

The NSQL implementation includes:

1. **Formal Definition**:
   - Complete grammar in EBNF format
   - Dictionary of terms, functions, and translations
   - Syntax patterns and their interpretations

2. **Rules and Principles**:
   - R21: NSQL Dictionary Rule
   - R22: NSQL Interactive Update Rule
   - Reference resolution and disambiguation rules
   - Natural language and language usage guidelines

3. **Implementation Components**:
   - Parsers for different NSQL patterns
   - Translators to implementation languages
   - Validators and disambiguation systems
   - Extension frameworks

## Key Concepts

NSQL is defined by these key concepts:

1. **Human Readability**: Prioritizes clear, understandable syntax
2. **Precision**: Ensures statements have unambiguous meanings
3. **Implementation Neutrality**: Focuses on intent rather than implementation
4. **Syntactic Flexibility**: Supports multiple expression patterns
5. **Disambiguation Process**: Resolves ambiguities through user interaction
6. **Natural Language Integration**: Bridges natural and formal languages

## Expression Patterns

NSQL supports multiple expression patterns:

1. **Transform-To Pattern**:
   ```
   transform [SOURCE] to [TARGET] as
     [OPERATIONS]
     [GROUP CLAUSE]
     [FILTER CLAUSE]
     [ORDER CLAUSE]
   ```

2. **Arrow Operator Pattern**:
   ```
   [SOURCE] -> [OPERATION] -> [OPERATION] -> ...
   ```

3. **Natural Language Pattern**:
   ```
   show [dimension] by [metric]
   calculate [metric] for [filter]
   ```

## Governance Structure

This meta-principle governs the following rules, which define specific aspects of NSQL implementation:

1. **R21 (NSQL Dictionary Rule)**: Defines the dictionary structure and update process
2. **R22 (NSQL Interactive Update Rule)**: Defines the process for analyzing and adding new patterns

While these rules are physically located in the 16_NSQL_Language/rules/ directory for implementation organization, they remain conceptually governed by this meta-principle in accordance with the MP/P/R hierarchy.

## Relationship to Other Meta-Principles

This meta-principle:

1. **Implements MP0020 (Principle Language Versions)** by providing a formal language for data operations
2. **Implements MP0023 (Language Preferences)** by establishing NSQL as the preferred language for data transformations
3. **Relates to P13 (Language Standard Adherence)** by defining a standard that implementations must adhere to

## For Complete Details

For complete language specification, examples, and implementation details, please refer to the comprehensive documentation in the 16_NSQL_Language directory.

## Changelog

- 2025-04-03: Initial creation
- 2025-04-04: Updated to reference implementation in 16_NSQL_Language
- 2025-04-04: Clarified governance of R21 and R22 in 16_NSQL_Language/rules/
