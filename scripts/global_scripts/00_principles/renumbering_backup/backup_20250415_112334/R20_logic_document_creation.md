---
id: "R20"
title: "Logic Document Creation Rule"
type: "rule"
date_created: "2025-04-04"
date_modified: "2025-04-04"
author: "Claude"
implements:
  - "MP20": "Principle Language Versions"
  - "MP21": "Formal Logic Language"
related_to:
  - "MP01": "Primitive Terms and Definitions"
  - "MP00": "Axiomatization System"
---

# Logic Document Creation Rule

## Core Requirement

For each meta-principle and principle document created within the precision marketing system, a corresponding logical formulation document must be created that expresses the same concepts using formal logic, set theory, and/or mathematical notation. This rule establishes the standards for creating, maintaining, and relating these logical formulations to their natural language counterparts.

## Document Structure and Naming

### 1. File Naming Convention

Logical formulation documents must follow this naming pattern:

```
[Original Document ID]_logic.md
```

Examples:
- `MP00_axiomatization_system_logic.md`
- `MP01_primitive_terms_and_definitions_logic.md`
- `P14_dot_notation_property_access_logic.md`

### 2. Document ID Convention

The document ID in the YAML frontmatter should follow this pattern:

```
id: "[Original Document ID]_LOGIC"
```

Examples:
- `id: "MP00_LOGIC"`
- `id: "MP01_LOGIC"`
- `id: "P14_LOGIC"`

### 3. Required YAML Frontmatter Fields

All logical formulation documents must include these YAML frontmatter fields:

```yaml
---
id: "[Original ID]_LOGIC"
title: "[Original Title] - Logical Formulation"
type: "[Original Type]"
date_created: "[Creation Date]"
date_modified: "[Modification Date]"
author: "[Author]"
derives_from:
  - "[Original ID]": "[Original Title]"
influences:
  - "[Influenced Document IDs]": "[Influenced Document Titles]"
alternative_of:
  - "[Original ID]": "[Original Title]"
---
```

The `alternative_of` field explicitly links the logical formulation to its natural language counterpart.

## Logical Formulation Guidelines

### 1. Type Theory Notation Standards

Logic documents should use these notation standards:

- **Type Theory**: Use type notation (x : T for "x is of type T")
- **Dependent Types**: Use Π-types for dependent functions (Π(x:A), B(x))
- **First-Order Logic**: Use standard logical operators (∀, ∃, ∧, ∨, ¬, →, ↔)
- **Set Theory**: Use standard set notation (∈, ⊆, ∩, ∪, ∖, ℘)
- **Functions**: Denote functions using the notation f: X → Y
- **Type Hierarchies**: Use subtyping notation (S <: T)
- **Interpretation**: Use double brackets for interpretations (⟦x⟧_c)
- **Variables and Constants**: Distinguish between Variable T and Constant T
- **LaTeX Math**: Use LaTeX notation within Markdown using $...$ for inline and $$...$$ for blocks

### 2. Formalization Process

When creating a logical formulation document:

1. **Identify Core Concepts**: Extract the key concepts, rules, and relationships
2. **Define a Formal Language**: Establish primitive terms, predicates, and functions
3. **Express Axioms and Rules**: Translate principles into logical statements
4. **Formalize Inference Rules**: Convert reasoning patterns into logical inference rules
5. **Define Properties**: Formalize system properties like consistency and completeness
6. **Correlate with Original**: Ensure every natural language statement has a formal counterpart

### 3. Content Organization

Logic documents should be organized with these sections:

1. **Formal Language Definition**: Defines the vocabulary and syntax
2. **Primitive Terms and Sets**: Establishes foundational concepts
3. **Axioms**: States fundamental assumptions
4. **Inference Rules**: Specifies valid reasoning patterns
5. **Theorems/Derived Results**: Presents consequences of the axioms
6. **Properties**: Describes formal properties of the system
7. **Examples**: Demonstrates application of the formalism
8. **Relationship to Other Formal Systems**: Places the formalism in context

## Maintenance and Consistency

### 1. Synchronization Requirement

Logic documents must be kept synchronized with their natural language counterparts:

1. When a natural language document is updated, its logical formulation must be updated within 5 working days
2. All changes to core concepts must be reflected in both versions
3. The `date_modified` field must be updated to match in both documents

### 2. Cross-Validation

Before publishing updates to either document:

1. Verify that no logical contradictions or inconsistencies exist between versions
2. Ensure all key concepts are represented in both documents
3. Confirm that relationships to other documents are consistently represented

### 3. Version Control

Both documents should be:

1. Committed together in the same version control transaction
2. Tagged with the same version identifier
3. Referenced together in documentation

## Examples

### Example 1: Principle as Logical Statement

**Natural Language Version (P07):**
```
"Every component must have a UI part, a server part, and a defaults part."
```

**Logical Formulation:**
```
∀c ∈ Component, ∃ui, server, defaults [
   has_attribute(c, "ui_part", ui) ∧
   has_attribute(c, "server_part", server) ∧
   has_attribute(c, "defaults_part", defaults)
]
```

### Example 2: Relationship as Logical Implication

**Natural Language Version (MP13):**
```
"If a meta-principle governs a principle, and that principle governs a rule, 
then the meta-principle indirectly governs that rule."
```

**Logical Formulation:**
```
∀x, y, z [
   (MetaPrinciple(x) ∧ Principle(y) ∧ Rule(z) ∧ 
    Governs(x, y) ∧ Governs(y, z)) → 
   IndirectlyGoverns(x, z)
]
```

### Example 3: Decision Procedure as Algorithm

**Natural Language Version (MP00):**
```
"When two principles conflict, the more specific principle takes precedence over the more general one."
```

**Logical Formulation:**
```
∀x, y [
   (Conflicts(x, y) ∧ Specificity(x) > Specificity(y)) →
   Precedence(x, y)
]
```

## Relationship to Other Principles

This rule implements:

1. **Principle Language Versions (MP20)**: By establishing formal logic as an alternate expression of principles
2. **Formal Logic Language (MP21)**: By defining standards for formal logical expressions

This rule relates to:

1. **Primitive Terms and Definitions (MP01)**: By providing formal definitions of terminology
2. **Axiomatization System (MP00)**: By formalizing the axiomatic structure

## Benefits

1. **Precision**: Removes ambiguity inherent in natural language
2. **Verifiability**: Enables formal verification of consistency and completeness
3. **Derivability**: Allows rigorous derivation of consequences
4. **Bridging**: Creates connections to formal methods and tools
5. **Clarification**: Reveals hidden assumptions in natural language formulations

## Conclusion

The Logic Document Creation Rule ensures that the precision marketing system maintains both accessible natural language descriptions and rigorous formal specifications of its principles. This dual approach combines the intuitive understanding provided by natural language with the precision and verifiability of formal logic, creating a more robust and well-defined system architecture.
