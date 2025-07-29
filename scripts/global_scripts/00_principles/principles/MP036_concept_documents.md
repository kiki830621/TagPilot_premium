# MP0036: Concept Documents Structure

## Definition
Concept Documents ("C" documents) are a structured documentation type that connects multiple related principles, rules, and metaprinciples to provide practical guidance on specific topics or scenarios.

## Explanation
While individual principles (P), rules (R), and metaprinciples (MP) define specific guidelines, the concept document structure serves a unique role in the principles system by creating bridges between isolated principles and providing context-specific guidance.

Concept documents address a key challenge in applying principles: the need to understand how multiple principles interact in specific scenarios. They provide developers with practical decision frameworks that span multiple principle types and domains.

## Implementation Guidelines

### Document Structure
Concept documents must follow this standard structure:

1. **Overview**: Brief explanation of the concept and its importance
2. **Core Principle**: The fundamental guiding philosophy for this concept
3. **Decision Tree/Process**: Step-by-step guidance for making decisions
4. **Implementation Pattern**: Concrete examples and implementation guidance
5. **Anti-patterns**: Common mistakes to avoid
6. **Related Principles**: List of all connected principles, rules, and metaprinciples

### Naming Convention
Concept documents use the "C" prefix followed by a number and descriptive name:

```
C##_descriptive_name.md
```

For example:
- C00_when_to_source.md
- C01_error_handling_patterns.md
- C02_initialization_sequence.md

### Creation Criteria
Create a concept document when:
- Multiple principles need to be used together to solve a common problem
- Developers need guidance on "when" to apply specific principles
- There's a need to explain interactions between various principles
- A development scenario requires a defined decision process
- Common questions arise about how multiple principles work together

### Usage Standards
Concept documents should be referenced when:
- Documenting code that implements multiple related principles
- In code reviews to explain why a specific approach was chosen
- In training materials to demonstrate principled decision-making
- When planning implementation of new features that cross multiple domains

## Relationship to Other Principle Types
The concept document structure completes the principles system by addressing the relationships between principles:

- **Metaprinciples (MP)**: Define foundational philosophy and architecture
- **Principles (P)**: Define specific design approaches and patterns
- **Rules (R)**: Define concrete implementation requirements 
- **Concepts (C)**: Connect principles and provide practical guidance

## Examples of Application
Concept documents are particularly valuable for documenting approaches to:
- Project setup procedures
- Component lifecycle management
- Error handling frameworks
- State management approaches
- Configuration systems
- Testing strategies
- Data flow patterns

C00_when_to_source.md provides an example of a concept document that connects MP0031 (Initialization First), R56 (Folder-Based Sourcing), P55 (N-tuple Independent Loading), and other related principles to provide guidance on when, where, and how to source components.

## Related Principles
- MP0000: Axiomatization System
- MP0001: Primitive Terms and Definitions
- MP0007: Documentation Organization
- MP0013: Statute Law Analogy
- R02: Principle Documentation
