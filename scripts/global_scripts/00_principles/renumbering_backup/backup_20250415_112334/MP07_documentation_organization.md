---
id: "MP07"
title: "Documentation Organization"
type: "meta-principle"
date_created: "2025-04-01"
date_modified: "2025-04-02"
author: "Claude"
derives_from:
  - "MP00": "Axiomatization System"
  - "MP05": "Instance vs. Principle"
influences:
  - "MP01": "Primitive Terms and Definitions"
  - "MP02": "Structural Blueprint"
---

# Documentation Organization Meta-Principle

This meta-principle establishes guidelines for organizing principle documents and other documentation within the precision marketing framework.

## Core Concept

Documentation should be organized using a consistent, simple structure that balances chronological development history with topical categorization, while maintaining compatibility with existing code and infrastructure.

## Organizational Guidelines

### 1. Flat Structure Primacy

Principle documentation should use a flat directory structure rather than deep hierarchies:

- **Simple Access**: All principles are directly accessible in a single location
- **Easy Discovery**: New team members can quickly find all principles
- **Reduced Complexity**: No need to navigate nested directories
- **Path Stability**: File paths remain consistent and predictable

```
# Preferred (flat structure)
/principles/
  MP00_axiomatization_system.md
  MP01_primitive_terms_and_definitions.md
  P00_project_principles.md

# Avoid (nested structure)
/principles/
  /meta/
    MP00_axiomatization_system.md
    MP01_primitive_terms_and_definitions.md
  /core/
    P00_project_principles.md
```

### 2. Logical Classification

Use the MP/P/R classification system to establish a clear organizational structure:

- **Conceptual Hierarchy**: MP documents establish foundations, P documents provide guidelines, R documents give specifics
- **Development Narrative**: The classification system tells the story of the project's evolution
- **Unique Identifiers**: MP/P/R prefixes provide unambiguous references to specific principles
- **Natural Grouping**: Files automatically group by principle type

```
# Good (MP/P/R classification)
MP00_axiomatization_system.md
MP01_primitive_terms_and_definitions.md
P00_project_principles.md
R00_directory_structure.md

# Avoid (no classification)
axiomatization_system.md
primitive_terms.md
project_principles.md
```

### 3. Topical Indication

Include topic identifiers in filenames while maintaining the classification system:

- **Dual Organization**: Combines classification with topical grouping
- **Pattern Recognition**: Related documents share common patterns or keywords
- **Searchability**: Easy to find all documents on a particular topic
- **Clear Boundaries**: Topic identifiers make document purpose immediately apparent

```
# Good (topic indication with classification)
P04_app_construction_principles.md
P07_app_bottom_up_construction.md
R04_app_yaml_configuration.md

# Avoid (ambiguous grouping)
app_principles.md
bottom_up.md
yaml_config.md
```

### 4. Reference Compatibility

Maintain compatibility with existing code and documentation references:

- **Stable References**: File paths should remain stable over time
- **Backward Compatibility**: Changes to organization should not break existing references
- **Forward Compatibility**: Organization should accommodate future additions
- **Consistent Patterns**: Reference patterns should be uniform across the codebase

```r
# Organization should support existing reference patterns
source(file.path("update_scripts", "global_scripts", "00_principles", "MP03_operating_modes.md"))
```

### 5. Infrastructure Alignment

Documentation organization should align with existing infrastructure and tools:

- **Tool Compatibility**: Structure should work with existing tooling (initialization scripts, etc.)
- **Search Efficiency**: Organization should support efficient search and retrieval
- **Build Integration**: Documentation should integrate with build processes if applicable
- **Link Navigation**: Internal links between documents should be reliable

## Implementation Examples

### Good Documentation Organization

```
/update_scripts/global_scripts/00_principles/
  MP00_axiomatization_system.md
  MP01_primitive_terms_and_definitions.md
  MP02_structural_blueprint.md
  ...
  P00_project_principles.md
  P01_script_separation.md
  ...
  R00_directory_structure.md
  R01_file_naming_convention.md
  ...
  README.md  # Contains topical index
```

### Topical Index in README

A topical index in the README.md provides organization without changing file structure:

```markdown
## Principles by Category

### Meta-Principles (MP)
- [MP00_axiomatization_system.md](MP00_axiomatization_system.md) - Meta-meta-principle establishing the formal axiomatic system
- [MP01_primitive_terms_and_definitions.md](MP01_primitive_terms_and_definitions.md) - Fundamental vocabulary and primitive terms
...

### Principles (P)
- [P00_project_principles.md](P00_project_principles.md) - Core project principles
- [P04_app_construction_principles.md](P04_app_construction_principles.md) - Core app construction principles
...

### Rules (R)
- [R00_directory_structure.md](R00_directory_structure.md) - Directory structure organization rules
- [R01_file_naming_convention.md](R01_file_naming_convention.md) - File naming convention rules
...
```

## Benefits

1. **Simplicity**: Flat structures are easier to navigate and understand
2. **Compatibility**: Maintains compatibility with existing code references
3. **Logical Organization**: Preserves the conceptual hierarchy of principle evolution
4. **Clear References**: Makes cross-references between principles more straightforward
5. **Infrastructure Support**: Works seamlessly with current initialization and tooling

## Relationship to Other Principles

This meta-principle works in conjunction with:

1. **Axiomatization System** (MP00): Establishes the core classification approach
2. **Instance vs. Principle Meta-Principle** (MP05): Reinforces proper location of principles
3. **Structural Blueprint** (MP02): Ensures principles are in a single, central location

## Conclusion

By following these organizational guidelines, we ensure that our documentation remains accessible, understandable, and maintainable as the project evolves. The balanced approach of MP/P/R classification with topic indicators provides both conceptual context and topical grouping without sacrificing simplicity or compatibility.
