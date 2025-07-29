---
id: "MP0062"
title: "NSQL Detailed Specification"
type: "meta-principle"
date_created: "2025-04-29"
author: "Claude"
derives_from:
  - "MP0024": "Natural SQL Language"
  - "MP0027": "Specialized Natural SQL Language"
influences:
  - "MP0063": "Graph Theory in NSQL"
  - "MP0064": "NSQL Set Theory Foundations"
  - "MP0065": "Radical Translation in NSQL"
---

# NSQL Detailed Specification

## Core Principle

This meta-principle provides the comprehensive technical specification for the Natural SQL Language (NSQL), building upon the foundation established in MP0024 (Natural SQL Language) and MP0027 (Specialized Natural SQL Language). While those meta-principles establish the conceptual framework and primary use cases, this document serves as the authoritative reference for the complete syntax, grammar, and implementation details.

## Implementation Reference

The complete implementation of NSQL is maintained in the `/global_scripts/16_NSQL_Language/` directory, which serves as the single source of truth for:

1. **Core Language Definition**: Grammar, syntax, and semantic rules
2. **Extension Mechanisms**: Graph theory, radical translation, and documentation formats
3. **Implementation Components**: Parsers, translators, validators, and utility functions
4. **Usage Guidelines**: Best practices and patterns for effective NSQL usage

For all technical details, examples, and implementation code, refer to:
```
/global_scripts/16_NSQL_Language/README.md
```

## Key Technical Components

NSQL's specification encompasses these key technical components, which are fully detailed in the implementation directory:

1. **Formal Grammar** (`/16_NSQL_Language/grammar.ebnf`): Defines the syntax in Extended Backus-Naur Form
2. **Dictionary** (`/16_NSQL_Language/dictionary.yaml`): Terminology mapping and translations
3. **Default Rules** (`/16_NSQL_Language/default_rules.md`): Default interpretation guidelines
4. **Reference Resolution** (`/16_NSQL_Language/reference_resolution_rule.md`): Disambiguation process
5. **Extension Modules** (`/16_NSQL_Language/extensions/`): Domain-specific language extensions

## Principle Organization

The NSQL documentation follows this organizational structure:

1. Meta-Principles (MP):
   - MP0024: Core NSQL concept and purpose
   - MP0027: Specialized NSQL extensions
   - MP0062 (this document): Complete technical specification
   - MP0063: Graph theory extensions
   - MP0064: Set theory foundations
   - MP0065: Radical translation mechanisms

2. Implementation Details (in `/16_NSQL_Language/`):
   - Full technical documentation
   - Examples and usage patterns
   - Implementation code
   - Extension definitions

## Relationship to Other Principles

This specification meta-principle:

1. **Derives from**:
   - MP0024 (Natural SQL Language): Builds upon the core concept
   - MP0027 (Specialized Natural SQL Language): Extends the application domains

2. **Influences**:
   - MP0063 (Graph Theory in NSQL): Provides foundation for graph notation
   - MP0064 (NSQL Set Theory Foundations): Underpins mathematical formalism
   - MP0065 (Radical Translation in NSQL): Enables cross-language transformation

## Usage

For all implementation details, usage guidelines, and technical specifics, refer to the comprehensive documentation in the `/global_scripts/16_NSQL_Language/` directory. This meta-principle serves primarily as a pointer to that implementation while establishing its position within the meta-principle hierarchy.