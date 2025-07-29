---
id: "MP0015"
title: "Currency Principle"
type: "meta-principle"
date_created: "2025-04-02"
author: "Claude"
derives_from:
  - "MP0000": "Axiomatization System"
  - "MP0014": "Change Tracking Principle"
influences:
  - "MP0009": "Discrepancy Principle"
  - "P10": "Documentation Update Principle"
  - "R09": "Global Scripts Synchronization"
---

# Currency Principle

This meta-principle establishes that all system components, including code, documentation, principles, and configurations, must be maintained in a current state that accurately reflects the system's actual implementation.

## Core Concept

All aspects of the precision marketing system must remain current, synchronized, and up-to-date with the actual implementation at all times. Documentation must reflect code, principles must reflect practice, and all components must evolve together to maintain a coherent, accurate, and trustworthy system.

## Currency Requirements

### 1. Documentation Currency

#### 1.1 Principle Documentation

All principles (MP, P, R) must:
- Reflect current architectural decisions and patterns
- Be updated simultaneously with related code changes
- Be reviewed periodically for accuracy
- Include the date of last verification/update
- Reference current versions of related principles

#### 1.2 Code Documentation

Code documentation (comments, function descriptions, READMEs) must:
- Accurately describe the current behavior of the code
- Be updated with every code change
- Match the actual parameters, return values, and behavior
- Include examples that work with the current implementation
- Use current terminology from the principles

#### 1.3 User-Facing Documentation

User-facing documentation (guides, manuals) must:
- Reflect the current features and capabilities
- Show current screenshots and UI elements
- Describe current workflows and processes
- Provide accurate troubleshooting guidance
- Be versioned to match software releases

### 2. Code Currency

#### 2.1 Repository Currency

Code repositories must:
- Contain the most current version of all files
- Have all changes committed, pulled, and pushed per R09
- Maintain branch currency relative to the main branch
- Keep dependencies and package references current
- Remove deprecated or unused code

#### 2.2 Implementation Currency

Implementations must:
- Comply with current principles and rules
- Use current libraries and dependencies
- Follow current coding standards and patterns
- Implement current security practices
- Leverage current language features appropriately

#### 2.3 Test Currency

Tests must:
- Verify current requirements and features
- Cover current code paths and edge cases
- Use current testing frameworks and patterns
- Match current expected behaviors
- Be updated with every functional change

### 3. Configuration Currency

#### 3.1 YAML Configuration

YAML configuration files must:
- Use current configuration patterns per R04
- Reference current data sources and components
- Include current parameters and settings
- Remove obsolete or unused settings
- Follow current naming conventions

#### 3.2 Environment Configuration

Environment configurations must:
- Reflect current deployment environments
- Include current paths and connections
- Use current security credentials
- Specify current resource requirements
- Implement current logging settings

### 4. Data Model Currency

#### 4.1 Schema Currency

Database schemas must:
- Represent current entity relationships
- Include all current fields and data types
- Use current naming conventions
- Implement current indexing strategies
- Enforce current data integrity rules

#### 4.2 Data Dictionary Currency

Data dictionaries must:
- Define all current fields and entities
- Document current business meanings
- Reflect current data sources
- Show current relationships
- Include current usage patterns

## Currency Mechanisms

### 1. Change Synchronization

Multiple components that must change together should be synchronized using:

1. **Atomic Updates**: Update all related components in a single commit
2. **Cross-References**: Include explicit references between related components
3. **Dependency Tracking**: Document dependencies between components
4. **Change Propagation**: Define how changes in one component affect others
5. **Version Alignment**: Ensure version numbers stay in sync across components

### 2. Currency Verification

Regularly verify currency through:

1. **Automated Tests**: Verify documentation examples match code behavior
2. **Consistency Checks**: Compare principles to implementations
3. **Dependency Analysis**: Check for outdated dependencies
4. **Documentation Review**: Periodically review all documentation
5. **Cross-Component Validation**: Ensure related components remain synchronized

### 3. Currency Attribution

Track currency status through:

1. **Currency Metadata**: Include last_updated fields in all artifacts
2. **Author Attribution**: Track who last verified/updated each component
3. **Change Reason**: Document why each update was made
4. **Verification Status**: Record when each component was last verified
5. **Currency Measurement**: Define what "current" means for each component type

## Implementation Guidelines

### 1. Immediate Updates

Updates to maintain currency must be made:

1. **Without Delay**: Immediately upon recognizing a discrepancy
2. **Before New Development**: Currency debt should be addressed before new features
3. **As Part of Code Reviews**: Currency should be verified in review processes
4. **After External Changes**: When dependencies or environments change
5. **During Regular Audits**: As part of scheduled maintenance activities

### 2. Currency Debt

Identify and track "currency debt" using:

1. **Currency Backlog**: Track known currency issues
2. **Currency Metrics**: Measure how current each component is
3. **Currency Debt Ratio**: Calculate the percentage of outdated components
4. **Priority System**: Prioritize currency updates based on impact
5. **Technical Debt Tracking**: Include currency debt in technical debt management

### 3. Currency Enforcement

Enforce currency through:

1. **Automated Checks**: Use tools to verify documentation currency
2. **Review Checklists**: Include currency checks in review processes
3. **Continuous Integration**: Build currency verification into CI/CD pipelines
4. **Currency Gates**: Require currency verification before releases
5. **Currency Audits**: Conduct periodic currency audits

## Relationships to Other Principles

This meta-principle:

1. **Extends MP0014 (Change Tracking Principle)**: Focuses not just on tracking changes but ensuring they're propagated to maintain currency
2. **Supports MP0009 (Discrepancy Principle)**: Provides a foundation for addressing discrepancies between documentation and implementation
3. **Strengthens R09 (Global Scripts Synchronization)**: Extends synchronization beyond just code to all system components
4. **Complements MP0000 (Axiomatization System)**: Ensures the axiomatic system remains current and accurate
5. **Reinforces MP0013 (Statute Law Analogy)**: Ensures the "legislative history" is current and accessible

## Benefits of Currency

1. **Trust**: Users can trust that documentation accurately reflects reality
2. **Efficiency**: Developers spend less time navigating outdated information
3. **Reduced Errors**: Fewer mistakes from following obsolete guidance
4. **Accelerated Onboarding**: New team members can rely on current documentation
5. **Improved Maintenance**: Maintenance based on current information is more effective
6. **Better Decision-Making**: Decisions based on current information are more sound
7. **Reduced Technical Debt**: Currency prevents accumulation of technical debt
8. **Greater Agility**: Current systems are easier to modify and extend

## Currency Examples

### Documentation Update Example

When changing a function signature:

```r
# Before: 
# fn_process_data(data, filter_type)
# After:
# fn_process_data(data, filter_type, include_outliers = FALSE)

# The following MUST be updated simultaneously:
# 1. Function implementation
# 2. Function documentation/roxygen comments
# 3. README examples
# 4. Unit tests
# 5. Any principles referencing this function
# 6. Any calling code affected by the change
```

### Principle Update Example

When a principle is updated:

```markdown
# MP0006: Data Source Hierarchy updated to include streaming data sources

The following MUST be updated simultaneously:
1. The MP0006 document itself
2. Any principles that reference MP06
3. Implementation code that follows MP06
4. Documentation that references the data source hierarchy
5. Examples in READMEs and guides
6. Verification tests for MP0006 compliance
```

## Conclusion

The Currency Principle establishes that all system components must remain synchronized and up-to-date with each other and with actual implementation. This creates a trustworthy, efficient, and maintainable system where documentation, code, and principles align at all times. By enforcing currency across all aspects of the system, we reduce technical debt, improve developer efficiency, and ensure the system can evolve coherently over time.
