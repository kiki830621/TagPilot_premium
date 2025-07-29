# Meta-Principle 32: Principle-Guided Modifications

## Core Concept
Every code modification must follow at least one Meta-Principle (MP), Principle (P), or Rule (R), and the implementation must explicitly state which principles are being followed.

## Rationale
Requiring explicit linkage between code changes and governing principles ensures:

1. **Intentional Design**: Every change has clear purpose aligned with system architecture 
2. **Consistent Evolution**: Code changes maintain conceptual integrity over time
3. **Knowledge Transfer**: New team members can understand rationale behind implementations
4. **Drift Prevention**: Protects against gradual deviation from established best practices
5. **Traceability**: Creates auditable relationship between principles and code

## Implementation Requirements

### For Human Developers
1. Before implementing changes, identify relevant principles
2. Document which principles you're following in commit messages
3. Include principle references in code comments for significant changes
4. When proposing new features, explain which principles support the approach

### For AI Assistants
1. For every code modification, identify and state which principles are being followed
2. When multiple implementation approaches exist, compare them against principles to determine best option
3. If no existing principles seem to apply, suggest the creation of a new principle
4. Include principle identifiers (e.g., "MP16", "P05", "R54") when describing changes

### Required Documentation
When making changes, reference principles using the following format:

```
Following:
- MP16 (Modularity): By organizing related components
- P05 (Case Sensitivity): By ensuring consistent lowercase naming
- R54 (Data Storage Organization): By placing database files in app_data folder
```

## Implementation Example
When fixing a function:

```r
# Following R33 (Recursive Sourcing), enhanced to support inclusion/exclusion patterns
# and to properly handle directory traversal with maximum depth control
get_r_files_recursive <- function(dir_path, 
                                include_pattern = "\\.R$", 
                                exclude_pattern = NULL,
                                max_depth = Inf) {
  # Implementation...
}
```

When updating documentation:

```
# Commit Message
Updated fn_get_r_files_recursive.R to support inclusion/exclusion patterns

Following:
- R33 (Recursive Sourcing): Enhanced directory traversal with pattern support
- MP17 (Separation of Concerns): Improved filtering capability for different file types
- P13 (Language Standard Adherence): Updated roxygen documentation
```

## When No Principle Exists
If no existing principle directly applies to a needed change:

1. Implement based on closest related principles
2. Document why existing principles don't fully address the need
3. Propose a new principle to fill the gap
4. Once approved, update documentation to reference the new principle

## Benefits
1. Makes architectural intent visible in the code
2. Reduces arbitrary decisions and inconsistencies
3. Facilitates knowledge sharing and onboarding
4. Creates transparent reasoning for design choices
5. Builds shared vocabulary among team members

## Related Principles
- MP00 (Axiomatization System)
- MP05 (Instance vs Principle)
- MP13 (Statute Law Analogy)