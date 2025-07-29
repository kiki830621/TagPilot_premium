---
id: "R0039"
title: "Derivation Platform Independence"
type: "rule"
date_created: "2025-04-07"
date_modified: "2025-04-07"
author: "Claude"
implements:
  - "MP0001": "Primitive Terms and Definitions"
  - "MP0017": "Separation of Concerns"
related_to:
  - "D01": "DNA Analysis Derivation Flow"
  - "R0038": "Platform Numbering Convention"
---

# R0039: Derivation Platform Independence

This rule establishes the requirement for platform independence in derivation documents, ensuring that derivations describe the abstract transformation flow rather than specific platform implementations.

## Core Requirement

Derivation documents must define transformation flows that are platform-independent, with platform-specific implementations provided separately. This ensures that a single derivation can serve as the template for multiple platform-specific implementations.

## Separation of Concerns

### 1. Derivation vs. Implementation

- **Derivation (D)**: Provides the abstract, platform-independent transformation flow
- **Implementation (Script)**: Provides the platform-specific implementation of the derivation

### 2. Platform-Specific Annotations

When a derivation document includes platform-specific examples:
- They must be clearly marked as examples
- They must not be integral to understanding the derivation flow
- Multiple platform examples should be provided where possible
- The examples should use proper platform identifiers per [R0038: Platform Numbering Convention](R0038_platform_numbering_convention.md)

## Document Structure Requirements

### 1. Platform-Independent Main Content

The main content of a derivation document must:
- Use abstract terminology not tied to a specific platform
- Define operations in terms of their logical purpose, not platform-specific implementation
- Specify data transformations using generic field names where possible
- Reference general data structures rather than platform-specific ones

### 2. Platform-Specific Examples Section

Platform-specific examples should be contained in a dedicated section:
- Clearly marked as "Platform-Specific Examples"
- Use platform codes or aliases as defined in R38
- Include examples from multiple platforms where possible
- Highlight platform-specific considerations or variations

## Implementation Guidelines

### 1. Derivation Structure

A platform-independent derivation document should:

1. Begin with an abstract description of the transformation flow
2. Define steps using generic identifiers (D01_XX)
3. Specify input/output relationships in abstract terms
4. Define requirements that apply regardless of platform
5. Include a separate section for platform-specific examples

### 2. Platform-Specific Extensions

Platform-specific extensions should follow a consistent pattern:
```
D01_[platform]_XX
```

Where:
- `D01`: The derivation identifier
- `[platform]`: The platform code or alias (01/AMZ)
- `XX`: The sequential step number from the platform-independent derivation

### 3. Converting Existing Derivations

When converting an existing platform-specific derivation to a platform-independent one:

1. Identify and remove platform-specific terminology
2. Replace platform-specific field names with generic equivalents
3. Abstract platform-specific operations to their general purpose
4. Move platform-specific details to a dedicated examples section
5. Update references to use platform-independent step identifiers

## Benefits of Platform Independence

1. **Reusability**: The same derivation can be applied across multiple platforms
2. **Consistency**: Ensures consistent data transformation approaches across platforms
3. **Maintainability**: Changes to the abstract flow automatically apply to all platforms
4. **Documentation Efficiency**: Reduces redundancy in documentation
5. **Onboarding Improvement**: Makes it easier to understand the system conceptually

## Relationship to Other Principles

This rule implements:

- **MP0001 (Primitive Terms and Definitions)**: Ensures clear distinction between abstract derivations and platform-specific implementations
- **MP0017 (Separation of Concerns)**: Separates the conceptual transformation flow from its platform-specific implementations

It is related to:

- **D01 (DNA Analysis Derivation Flow)**: Provides guidance for making D01 platform-independent
- **R0038 (Platform Numbering Convention)**: Works with platform identification for examples

## Implementation Timeline

This platform independence requirement is effective immediately for all new derivations. Existing derivations should be updated to conform to this standard as part of regular maintenance cycles.
