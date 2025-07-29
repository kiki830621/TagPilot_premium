---
id: "P95"
title: "Template Organization Principle"
type: "principle"
date_created: "2025-04-10"
date_modified: "2025-04-10"
author: "Claude"
derives_from:
  - "MP00": "Axiomatization System"
  - "MP01": "Primitive Terms and Definitions"
  - "MP17": "Separation of Concerns"
influences:
  - "RC01": "Template of Function Files"
  - "R21": "One Main Function, One File Rule"
---

# Template Organization Principle

## Core Concept

Templates in the system should be organized as Rule Composites (RC) with distinct, sequentially-ordered sections that address different aspects of the implementation. Each template should aggregate multiple atomic rules into a coherent whole that can be consistently applied across the codebase.

## Template Structure Requirements

### 1. Rule Composite Classification

All templates in the system must be formally documented as Rule Composites (RC). This classification acknowledges that templates:

1. Combine multiple atomic rules into a coherent implementation pattern
2. Provide a comprehensive guidance framework for a specific type of file or component
3. Represent a higher-level abstraction formed from simpler rules
4. Serve as standardized patterns for consistent implementation

### 2. Sequential Organization

Each template must be organized into sequential sections that follow a logical progression:

1. **Metadata Section**: Information about the file, author, purpose, and relationships
2. **Documentation Section**: Detailed description of purpose, usage, and examples
3. **Interface Section**: Definition of inputs, outputs, parameters, and contracts
4. **Implementation Section**: The actual code, organized by functionality
5. **Auxiliary Section**: Supporting functions, constants, and utilities
6. **Test Hooks Section**: Elements designed to facilitate testing when appropriate

### 3. Section Independence

Each section of a template should:

1. Serve a distinct purpose with clear boundaries
2. Be maintainable independently of other sections
3. Follow its own specific formatting and documentation rules
4. Have clearly defined relationships with other sections

### 4. Completeness Requirement

Templates must be complete, addressing all aspects necessary for implementation:

1. Provide all required guidance for the file or component
2. Include both structural and content guidance
3. Specify not just what to include but how to organize it
4. Define both minimum requirements and recommended extensions

### 5. Visual Separation

Templates must use clear visual separation between sections:

1. Consistent comment blocks to delineate sections
2. Standard spacing patterns between sections
3. Sequential ordering that maintains a logical flow
4. Hierarchical organization within sections when appropriate

## Implementation Guidelines

### Template Documentation

Templates should be documented using this structure:

```
# Template Name

## Purpose
[Brief description of what this template is used for]

## Sections
1. [Section Name]: [Description of purpose and contents]
2. [Section Name]: [Description of purpose and contents]
   ...

## Rules Aggregated
- R##: [Rule Name] - [How it's applied in this template]
- R##: [Rule Name] - [How it's applied in this template]
   ...

## Usage Examples
[Example of the template in use]
```

### Template Application

When applying a template:

1. Follow all sections in the specified order
2. Maintain the visual separation between sections
3. Include all required elements from each section
4. Document any deviations from the template with clear rationale

### Template Versioning

Templates should be versioned using:

1. Major version: Significant structural changes
2. Minor version: Content additions that don't change structure
3. Patch version: Clarifications or minor adjustments

## Examples

### Code File Template Structure

```
# File metadata and relationship documentation
# ----------------------------------------------
# [Metadata section with standardized format]

# Detailed documentation
# ----------------------------------------------
# [Documentation section with purpose, examples, etc.]

# Interface definition
# ----------------------------------------------
# [Function signatures, parameter definitions, etc.]

# Implementation
# ----------------------------------------------
# [Main code implementation]

# Auxiliary functions
# ----------------------------------------------
# [Helper functions and utilities]

# Test hooks
# ----------------------------------------------
# [Elements to support testing]
```

### Document Template Structure

```
---
# Metadata section in YAML format
id: "XX"
title: "Document Title"
type: "document-type"
date_created: "YYYY-MM-DD"
author: "Author Name"
relationships:
  - type: "relation-type"
    target: "target-id"
---

# Document Title

## Core Concept
[Brief explanation of central idea]

## [Main Content Sections]
[Detailed content organized sequentially]

## Examples
[Usage examples]

## Related Items
[Cross-references]
```

## Benefits

1. **Consistency**: Ensures all similar files follow the same structure
2. **Comprehensiveness**: Addresses all aspects required for implementation
3. **Clarity**: Makes it easy to find specific elements in any file
4. **Maintainability**: Enables focused changes to specific sections
5. **Learnability**: Reduces learning curve for new team members

## Relationship to Other Principles

This principle:

1. **Implements**: MP17 (Separation of Concerns) by organizing templates into distinct sections
2. **Derives from**: MP00 (Axiomatization System) by establishing templates as Rule Composites
3. **Influences**: RC01 (Template of Function Files) as the first template implementation
4. **Relates to**: R21 (One Main Function, One File Rule) by providing a structured way to implement it

## Conclusion

The Template Organization Principle establishes templates as formal Rule Composites with a structured, sequential organization. By standardizing templates across the system, we ensure consistency, clarity, and maintainability while providing comprehensive guidance for implementation.