---
id: "MP21"
title: "Formal Logic Language Meta-Principle"
type: "meta-principle"
date_created: "2025-04-03"
date_modified: "2025-04-03"
author: "Claude"
derives_from:
  - "MP00": "Axiomatization System"
  - "MP20": "Principle Language Versions"
influences:
  - "MP01_LOGIC": "Primitive Terms and Definitions - Logical Formulation"
  - "MP08": "Terminology Axiomatization"
---

# Formal Logic Language Meta-Principle

## Core Principle

The formal logic language used for logical formulations of principles is a combined system of first-order predicate logic and set theory, enriched with class notation and specialized predicates. This language provides the formal foundation for precise expression, rigorous analysis, and logical verification of principles and their relationships.

## Language Definition

### 1. Core Logical System

The formal logic language is based on classical first-order predicate logic with identity:

#### 1.1 Logical Symbols

- **Logical Connectives**:
  - Conjunction: ∧ (AND)
  - Disjunction: ∨ (OR)
  - Negation: ¬ (NOT)
  - Implication: → (IF-THEN)
  - Biconditional: ↔ (IF AND ONLY IF)

- **Quantifiers**:
  - Universal Quantifier: ∀ (FOR ALL)
  - Existential Quantifier: ∃ (THERE EXISTS)

- **Identity**:
  - Equality: =
  - Inequality: ≠

- **Parentheses and Brackets**:
  - Parentheses: ( )
  - Square Brackets: [ ]
  - Curly Braces: { }

#### 1.2 Non-Logical Symbols

- **Variables**: Lowercase letters (x, y, z, ...)
- **Constants**: Named entities (c1, component1, ...)
- **Predicates**: Named relations (implements, contains, ...)
- **Functions**: Named mappings (parent_of, value_of, ...)

### 2. Set Theory Components

The language incorporates set theory notation:

#### 2.1 Set Symbols

- **Set Membership**: ∈ (IS ELEMENT OF)
- **Set Non-membership**: ∉ (IS NOT ELEMENT OF)
- **Subset**: ⊂ (IS SUBSET OF)
- **Proper Subset**: ⊊ (IS PROPER SUBSET OF)
- **Superset**: ⊃ (IS SUPERSET OF)
- **Set Union**: ∪
- **Set Intersection**: ∩
- **Set Difference**: \
- **Empty Set**: ∅
- **Power Set**: 𝒫(X)

#### 2.2 Set Definition

- **Set Builder Notation**: {x | P(x)} (the set of all x such that P(x) holds)
- **Enumeration Notation**: {a, b, c, ...}

### 3. Class Notation

For higher-level organization, the language includes class notation:

#### 3.1 Class Definition

```
Class ClassName {
  Properties:
    property1: Type1
    property2: Type2
    ...
  
  Methods:
    method1(param1, ...)
    method2(param1, ...)
    ...
  
  Constraints:
    [logical formula expressing constraints]
}
```

#### 3.2 Class Relationships

- **Inheritance**: ClassName1 extends ClassName2
- **Implementation**: ClassName implements InterfaceName
- **Association**: associations between classes

### 4. Domain-Specific Extensions

The language includes domain-specific extensions for the precision marketing system:

#### 4.1 Core Sets

Predefined sets representing fundamental categories:
- Code: The set of all executable elements
- Data: The set of all information units
- Guidance: The set of all guidance elements
- Organization: The set of all organizational elements

#### 4.2 Specialized Predicates

Predefined predicates for common relationships:
- implements(x, y): x implements functionality y
- contains(x, y): x contains y as a part or element
- configures(x, y): x configures or parameterizes y
- governs(x, y): x provides guidance or rules for y
- has_attribute(x, a, v): x has attribute a with value v
- depends_on(x, y): x depends on y
- extends(x, y): x extends or inherits from y

### 5. Truth Semantics

The language uses classical two-valued logic:
- Every well-formed formula has exactly one truth value: true or false
- The law of the excluded middle applies
- The law of non-contradiction applies

## Syntax Rules

### 1. Well-Formed Formulas

A well-formed formula (WFF) must conform to these rules:

1. **Atomic Formulas**:
   - A predicate symbol followed by the appropriate number of terms is a WFF
   - Terms can be variables, constants, or functions applied to terms
   - If t1 and t2 are terms, then t1 = t2 is a WFF

2. **Compound Formulas**:
   - If φ is a WFF, then ¬φ is a WFF
   - If φ and ψ are WFFs, then (φ ∧ ψ), (φ ∨ ψ), (φ → ψ), and (φ ↔ ψ) are WFFs
   - If φ is a WFF and x is a variable, then ∀x[φ] and ∃x[φ] are WFFs

3. **Set Formulas**:
   - If X is a set and t is a term, then t ∈ X and t ∉ X are WFFs
   - If X and Y are sets, then X ⊂ Y, X ⊃ Y, X = Y, and X ≠ Y are WFFs

4. **Class Formulas**:
   - Class definitions must include a name
   - Property declarations must include a name and type
   - Constraints must be expressed as WFFs

### 2. Precedence Rules

When parentheses are omitted, the precedence of operators is:
1. Functions and predicates (highest)
2. ¬ (negation)
3. ∧ (conjunction)
4. ∨ (disjunction)
5. →, ↔ (implication, biconditional)
6. ∀, ∃ (quantifiers) (lowest)

### 3. Scope of Quantifiers

The scope of a quantifier extends to the end of the formula or until the closing bracket that matches the bracket immediately following the quantifier.

## Axiom Schema

The logic language is based on the following axiom schema:

### 1. Logical Axioms

1. **Law of Excluded Middle**: φ ∨ ¬φ
2. **Law of Non-Contradiction**: ¬(φ ∧ ¬φ)
3. **Double Negation**: ¬¬φ ↔ φ
4. **Quantifier Negation**:
   - ¬∀x[φ(x)] ↔ ∃x[¬φ(x)]
   - ¬∃x[φ(x)] ↔ ∀x[¬φ(x)]

### 2. Set Theory Axioms

1. **Extensionality**: Two sets are equal if and only if they have the same elements
2. **Specification**: For any property P and set A, there exists a set containing exactly the elements of A that satisfy P
3. **Pairing**: For any two sets, there exists a set containing exactly those two sets as elements
4. **Union**: For any set of sets, there exists a set containing all elements that belong to at least one of those sets
5. **Power Set**: For any set, there exists a set containing all its subsets

### 3. Domain-Specific Axioms

1. **Type Disjointness**: ∀x, ¬(x ∈ A ∧ x ∈ B) where A and B are disjoint types
2. **Type Hierarchy**: If x ∈ A and A ⊂ B, then x ∈ B
3. **Property Consistency**: If has_attribute(x, a, v1) and has_attribute(x, a, v2), then v1 = v2

## Inference Rules

The logic language supports these inference rules:

### 1. Basic Inference Rules

1. **Modus Ponens**: From φ and φ → ψ, infer ψ
2. **Universal Instantiation**: From ∀x[φ(x)], infer φ(t) for any term t
3. **Existential Generalization**: From φ(t), infer ∃x[φ(x)]
4. **Universal Generalization**: From φ(y) where y is arbitrary, infer ∀x[φ(x)]

### 2. Derived Inference Rules

1. **Disjunctive Syllogism**: From φ ∨ ψ and ¬φ, infer ψ
2. **Hypothetical Syllogism**: From φ → ψ and ψ → χ, infer φ → χ
3. **Conjunction Introduction**: From φ and ψ, infer φ ∧ ψ
4. **Conjunction Elimination**: From φ ∧ ψ, infer φ and infer ψ

## Examples

### Example 1: Parameter and Default Value Relationship

```
// Definition: Parameter and DefaultValue are disjoint
∀x, ¬(x ∈ Parameter ∧ x ∈ DefaultValue)

// Definition: Parameters come from YAML configuration
∀p ∈ Parameter, has_attribute(p, "source", "YAML")

// Definition: Default values are defined in components
∀d ∈ DefaultValue, ∃c ∈ Component [has_attribute(d, "component", c)]

// Component value resolution rule
∀c ∈ Component, ∀n [
  value_of(c, n) = 
    if ∃p ∈ Parameter [
      has_attribute(p, "name", n) ∧ 
      configures(p, c)
    ] then
      value_of(p)
    else if ∃d ∈ DefaultValue [
      has_attribute(d, "name", n) ∧ 
      has_attribute(d, "component", c)
    ] then
      value_of(d)
    else
      undefined
]
```

### Example 2: Component Triple Structure

```
// Definition: Every component has UI, Server, and Defaults parts
∀c ∈ Component [
  ∃ui, server, defaults [
    has_attribute(c, "ui_part", ui) ∧
    has_attribute(c, "server_part", server) ∧
    has_attribute(c, "defaults_part", defaults) ∧
    ui ∈ Code ∧ server ∈ Code ∧ defaults ∈ Code
  ]
]

// Component class definition
Class Component {
  Properties:
    id: String
    ui_part: Code
    server_part: Code
    defaults_part: Code
    
  Constraints:
    ∀c ∈ Component, ∃ui, server, defaults [
      has_attribute(c, "ui_part", ui) ∧
      has_attribute(c, "server_part", server) ∧
      has_attribute(c, "defaults_part", defaults)
    ]
}
```

### Example 3: Principle Hierarchy

```
// Meta-principles govern principles
∀mp ∈ MetaPrinciple, ∃p ∈ Principle [governs(mp, p)]

// Principles govern rules
∀p ∈ Principle, ∃r ∈ Rule [governs(p, r)]

// Rules govern instances
∀r ∈ Rule, ∃i ∈ Instance [governs(r, i)]

// Hierarchical relationship
∀x, y, z [governs(x, y) ∧ governs(y, z) → governs(x, z)]
```

## Usage Guidelines

### 1. When to Use Logical Formulation

Use logical formulation when:
1. **Precise Definition**: A concept requires precise, unambiguous definition
2. **Complex Relationships**: Relationships between concepts are complex
3. **Formal Verification**: Principles need formal verification or consistency checking
4. **Derivation**: New principles or rules are derived from existing ones
5. **Classification**: Concepts need formal taxonomy or classification

### 2. How to Create Logical Formulations

Follow these steps to create logical formulations:
1. **Identify Core Concepts**: Determine the main concepts to formalize
2. **Define Set Membership**: Place concepts in appropriate type hierarchies
3. **Specify Relationships**: Define relationships between concepts using predicates
4. **Add Constraints**: Add logical constraints and axioms
5. **Verify Consistency**: Check for logical consistency and completeness

### 3. Relationship with Natural Language

The logical formulation should:
1. **Complement**: Add precision to natural language, not replace it
2. **Clarify**: Resolve ambiguities in natural language formulations
3. **Extend**: Provide formal implications that may not be obvious
4. **Reference**: Include references to the natural language version

## Relationship to Other Principles

### Relation to Principle Language Versions (MP20)

This principle implements MP20 by:
1. **Defining LOGIC Formalism**: Providing the specific formal system for logical versions
2. **Establishing Syntax**: Defining the syntax and semantics of the formal language
3. **Setting Standards**: Creating standards for logical formulations

### Relation to Primitive Terms and Definitions (MP01)

This principle supports MP01 by:
1. **Formal Foundation**: Providing a formal foundation for primitive terms
2. **Relationship Precision**: Adding precision to term relationships
3. **Logical Structure**: Supporting logical structure in definitions

### Relation to Terminology Axiomatization (MP08)

This principle extends MP08 by:
1. **Formal Semantics**: Adding formal semantics to terminology
2. **Logical Relationships**: Enabling precise expression of term relationships
3. **Inference Support**: Supporting logical inference about terminology

## Benefits

1. **Precision**: Eliminates ambiguity in principle expressions
2. **Verifiability**: Supports formal verification of principles
3. **Consistency**: Enables checking consistency between principles
4. **Derivation**: Facilitates derivation of new principles
5. **Formalization**: Provides a path to more formal system specifications
6. **Reasoning**: Supports automated reasoning about principles
7. **Documentation**: Enhances documentation with formal specifications

## Conclusion

The Formal Logic Language Meta-Principle establishes the specific formal system used for logical formulations of principles in the precision marketing system. By combining first-order predicate logic, set theory, and class notation with domain-specific extensions, it provides a powerful language for precise expression, rigorous analysis, and formal verification of principles and their relationships.

This formal foundation complements natural language expressions, adding depth, precision, and analytical capabilities to our axiomatization system while maintaining accessibility through the corresponding natural language versions.
