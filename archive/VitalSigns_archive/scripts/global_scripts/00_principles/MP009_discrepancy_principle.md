---
id: "MP0009"
title: "Discrepancy Principle"
type: "meta-principle"
date_created: "2025-04-02"
date_modified: "2025-04-02"
author: "Claude"
derives_from:
  - "MP0000": "Axiomatization System"
  - "MP0001": "Primitive Terms and Definitions"
influences:
  - "P05": "Naming Principles"
  - "R05": "Renaming Methods"
---

# Discrepancy Principle

## Core Concept

When users and the system (Claude) have discrepancies in understanding, implementation, or expectations, this indicates a gap in the principle system that requires the creation of a new principle (MP, P, or R).

## Rationale

Discrepancies between user understanding and system behavior represent implicit principles that have not yet been formalized. By converting these implicit principles into explicit ones, we incrementally improve the system's axiomatization and reduce future discrepancies.

## Identification Process

### 1. Discrepancy Recognition

Discrepancies manifest in several ways:

- **Implementation Confusion**: User implements something differently than Claude expects
- **Terminology Misalignment**: User and Claude use different terms for the same concept
- **Expectation Mismatch**: User expects one behavior while Claude delivers another
- **Configuration Inconsistency**: User configures system differently than standard patterns

### 2. Principle Level Determination

The appropriate level for the new principle is determined by its scope and nature:

- **Meta-Principle (MP)**: For discrepancies about how principles themselves work or relate to each other
- **Principle (P)**: For discrepancies about general implementation approaches or patterns
- **Rule (R)**: For discrepancies about specific implementation details or techniques

### 3. Principle Formulation

To transform a discrepancy into a principle:

1. **Define the discrepancy**: Clearly articulate the difference in understanding
2. **Extract the underlying principle**: Identify the implicit rule being differently understood
3. **Generalize appropriately**: Ensure the principle applies beyond the specific instance
4. **Link to existing principles**: Connect to the axiomatization system
5. **Provide clear examples**: Show both adherence and violation of the principle

## Example Cases

### Case 1: Configuration Location Discrepancy

**Discrepancy**: User placed brand-specific parameters in an R script while system expected them in YAML configuration.

**Resolution**: Enhanced R04 (App YAML Configuration) to explicitly specify that brand-specific settings should be in YAML configuration.

**Pattern**: This represents a specific implementation detail discrepancy, resolved by enhancing an existing Rule.

### Case 2: Naming Collision Discrepancy

**Discrepancy**: Multiple files were assigned the same identifier (P07, etc.), causing reference inconsistencies.

**Resolution**: Created R05 (Renaming Methods) as a new rule for how to safely rename resources and resolve collisions.

**Pattern**: This represents a specific technique discrepancy, resolved by creating a new Rule.

## Implementation Guidelines

### 1. Proactive Discrepancy Monitoring

Actively watch for signs of discrepancy:

- Questions about "where should I put X?"
- Confusion about how to implement a feature
- Inconsistent implementations of similar features
- Repeated corrections of the same issue

### 2. Discrepancy Documentation

When a discrepancy is identified:

1. Document both user and system understanding
2. Identify which principles (if any) address the area
3. Determine if the discrepancy indicates:
   - Need for a new principle
   - Enhancement to an existing principle
   - Better communication of an existing principle

### 3. Principle Enhancement Process

To address discrepancies through principle enhancement:

1. Draft the new or enhanced principle
2. Review for consistency with existing principles
3. Implement the principle in the appropriate location
4. Update all references to maintain consistency
5. Document the resolution in changelog

## Relationship to Axiomatization

This meta-principle directly implements the Axiomatization System (MP0000) by providing a mechanism for growing the principle system organically based on actual usage patterns and friction points. It aligns with the evolutionary nature of axiomatization, where principles emerge from practice rather than being imposed arbitrarily.

## Benefits

1. **Organic Evolution**: The principle system evolves based on actual usage, not theoretical concerns
2. **Knowledge Preservation**: Converts implicit knowledge to explicit documentation
3. **Reduced Friction**: Systematic elimination of common confusion points
4. **Increased Consistency**: Standardized approaches to common problems
5. **Learning Acceleration**: New team members benefit from previously resolved discrepancies

## Limitations

1. **Risk of Over-Specification**: Not every discrepancy warrants a new principle
2. **Principle Inflation**: Too many principles can be difficult to learn and apply
3. **Contradictory Principles**: New principles might conflict with existing ones
4. **Implementation Burden**: Each new principle creates implementation work

## Conclusion

The Discrepancy Principle transforms friction points between users and the system into opportunities for improvement. By formalizing the implicit expectations that cause these discrepancies, we continuously enhance the system's clarity, usability, and consistency. This meta-principle ensures the axiomatization system remains practical, relevant, and aligned with actual usage patterns.
