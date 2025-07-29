---
id: "P0010"
title: "Documentation Update Principle"
type: "principle"
date_created: "2025-04-02"
author: "Claude"
derives_from:
  - "MP0015": "Currency Principle"
  - "MP0007": "Documentation Organization"
implements:
  - "MP0009": "Discrepancy Principle"
related_to:
  - "R0009": "Global Scripts Synchronization"
  - "R0002": "Principle Documentation"
---

# Documentation Update Principle

This principle establishes that any modification to the system must be accompanied by corresponding updates to all relevant documentation, ensuring that documentation remains accurate, current, and useful at all times.

## Core Concept

Documentation must evolve alongside the code, configuration, and structure it describes. Every change to the system requires an immediate, corresponding update to all affected documentation. No change is complete until its documentation is updated.

## Documentation Update Requirements

### 1. Simultaneous Documentation Updates

Documentation updates must occur within the same commit as the code changes they describe. This applies to:

1. **README.md files**: General overview, usage instructions, and examples
2. **Principle documents**: MP, P, and R documents in the `00_principles` directory
3. **Function documentation**: Roxygen comments, parameter descriptions, and return value documentation
4. **Code comments**: Inline documentation explaining complex logic or decisions
5. **API documentation**: Endpoint descriptions, parameter specifications, and response formats
6. **User manuals**: End-user documentation and training materials
7. **Architecture diagrams**: Visual representations of system design
8. **Project wikis**: Historical context and project knowledge

### 2. Required Documentation Updates by Change Type

Different types of changes require specific documentation updates:

#### 2.1 Function/API Changes

When changing a function's signature, behavior, or API endpoint:

- Update the function's Roxygen/JSDoc comments
- Update parameter descriptions and types
- Update return value documentation
- Update usage examples in documentation
- Update affected README.md files
- Update any principles that reference the function
- Update API documentation if applicable

#### 2.2 Data Structure Changes

When changing database schemas, object models, or data structures:

- Update data model documentation
- Update entity relationship diagrams
- Update schema definitions
- Update data dictionaries
- Update database README files
- Update any principles that reference the data structure
- Update affected code comments

#### 2.3 Architecture Changes

When modifying system architecture or component interactions:

- Update architecture diagrams
- Update system documentation
- Update component interface descriptions
- Update principles that document architecture
- Update deployment documentation
- Update READMEs at affected levels

#### 2.4 Configuration Changes

When changing configuration options or formats:

- Update configuration documentation
- Update configuration examples
- Update setup guides
- Update R0004 (App YAML Configuration) if relevant
- Update README files with new configuration information
- Update deployment scripts that use configurations

#### 2.5 Principle Changes

When modifying MP, P, or R documents:

- Update the principle document itself
- Update cross-referenced principles
- Update MP0000 (Axiomatization System) if needed
- Update README.md to reflect principle changes
- Update implementation code that follows the principle
- Update examples that demonstrate the principle

### 3. README.md Specific Requirements

README.md files serve as primary entry points for understanding code. When updating any README.md:

#### 3.1 Scope of Updates

Ensure the README.md accurately reflects:
- Current directory structure and contents
- Current features and capabilities
- Current installation and setup instructions
- Current usage examples and patterns
- Current principles and organizational frameworks
- Current dependencies and requirements
- Current maintenance procedures

#### 3.2 README.md Update Triggers

Update README.md files when:
- Adding, removing, or significantly changing files in the directory
- Changing function signatures, parameters, or return values
- Modifying configuration formats or options
- Restructuring directories or moving functionality
- Adding new capabilities or features
- Changing project requirements or dependencies
- Updating architectural patterns or designs
- Revising principles that affect implementation

#### 3.3 README.md Consistency

Ensure README.md files:
- Maintain consistent formatting and structure
- Use the current terminology from principles
- Reflect current file naming conventions
- Include current contact information
- Show the current date of last update

## Implementation Guidelines

### 1. Documentation-First Approach

Prefer a documentation-first approach where feasible:

1. **Documentation Planning**: Plan documentation changes before or alongside code changes
2. **Documentation-Driven Development**: Update documentation first, then implement changes
3. **Documentation Reviews**: Include documentation in all code reviews
4. **Documentation Tests**: Test that examples in documentation work correctly

### 2. Documentation Update Practice

Implement these practices to ensure documentation remains current:

1. **Single-Commit Updates**: Include documentation updates in the same commit as code changes
2. **Commit Messages**: Include documentation updates in commit messages
3. **Documentation Change Logs**: Track significant documentation changes
4. **Cross-Reference Verification**: Verify cross-references between documents
5. **Example Testing**: Test that examples in documentation work correctly

### 3. Documentation Verification

Verify documentation currency through:

1. **Documentation Reviews**: Include documentation in all code reviews
2. **Reader Perspective**: Review documentation from a new user's perspective
3. **Cross-Reference Checks**: Verify links and references between documents
4. **Example Verification**: Ensure examples work with current code
5. **Outdated Content Alerts**: Flag potentially outdated content for review

## Practical Examples

### Example 1: Function Change with Documentation Update

When changing a function's signature:

```r
# Before: 
# process_data <- function(data, filter_type) { ... }

# After:
# process_data <- function(data, filter_type, include_outliers = FALSE) { ... }

# Documentation Updates Required in Same Commit:
#
# 1. Update function Roxygen documentation:
#' @param include_outliers Logical indicating whether to include outliers in processing (default: FALSE)
#
# 2. Update the README.md example:
# ```r
# # Process data excluding outliers (default)
# result <- process_data(customer_data, "standard")
#
# # Process data including outliers
# result_with_outliers <- process_data(customer_data, "standard", include_outliers = TRUE)
# ```
#
# 3. Update any principles that reference this function
# 4. Update unit tests to cover the new parameter
```

### Example 2: Directory Structure Change

When adding a new directory or significantly changing structure:

```bash
# Action: Add new directory 13_modules/ with M/S/D structure

# Documentation Updates Required in Same Commit:
#
# 1. Update README.md directory structure section:
# - **13_modules/** - Company-specific module implementations
#   - **COMPANY_NAME/** - Directories for each company
#     - **M** - Modules (minimal purpose functionality)
#     - **S** - Sequences (multi-purpose processes)
#     - **D** - Derivations (complete transformation processes)
#
# 2. Update relevant principles (e.g., MP0001_primitive_terms_and_definitions.md)
# 3. Add README.md to the new directory explaining its purpose and structure
# 4. Update project structure diagram or visual representation
# 5. Update any cross-references in other documentation
```

### Example 3: Principle Modification

When updating a principle:

```markdown
# Action: Update R0004_app_yaml_configuration.md to add Pattern 6 (External Parameter Files)

# Documentation Updates Required in Same Commit:
#
# 1. Update R0004_app_yaml_configuration.md with the new pattern
# 2. Update README.md YAML Configuration section to include Pattern 6
# 3. Update any cross-references to R0004 in other principles
# 4. Update code examples to demonstrate the new pattern
# 5. Update implementation code that processes YAML files
# 6. Add or update the loadComponentParameters function documentation
```

## Relationship to Other Principles

This principle:

1. **Implements MP0015 (Currency Principle)**: Provides concrete requirements for maintaining documentation currency
2. **Derives from MP0007 (Documentation Organization)**: Builds on how documentation is organized to ensure it stays current
3. **Implements MP0009 (Discrepancy Principle)**: Prevents discrepancies between documentation and implementation
4. **Complements R0009 (Global Scripts Synchronization)**: Ensures documentation changes are committed and pushed with code
5. **Extends R0002 (Principle Documentation)**: Ensures principle documentation remains current with implementation

## Benefits

1. **Reduced Onboarding Time**: New team members can rely on accurate documentation
2. **Improved Maintainability**: Current documentation makes maintenance easier
3. **Reduced Errors**: Fewer mistakes from following outdated documentation
4. **Better Knowledge Transfer**: Documentation accurately preserves system knowledge
5. **Higher Code Quality**: Documentation requirements encourage clearer implementations
6. **Faster Development**: Current documentation reduces time spent investigating how things work
7. **Improved Collaboration**: Team members can trust shared documentation
8. **Preserved Context**: Documentation preserves the "why" behind decisions

## Conclusion

The Documentation Update Principle ensures that documentation remains a trustworthy, valuable asset by requiring simultaneous updates whenever system changes occur. By treating documentation as an integral part of the system—not an afterthought—we create a more maintainable, understandable, and efficient codebase. Documentation is complete, correct, and current only when it evolves in lockstep with the code it describes.
