# Package Documentation Reference Rule

## Core Rule

When using functions from external packages, developers must follow the established usage patterns documented in both the project-specific package documentation (`20_R_packages/`) and the centralized cross-project reference repository (`/precision_marketing/R_package_references/`), and reference this documentation in file headers.

## Rationale

Ensuring consistent usage of external packages requires explicit knowledge of the established patterns and conventions for each package within our system. By requiring references to centralized documentation, we ensure that:

1. Developers are aware of the approved usage patterns
2. Code consistently implements package functions according to project standards
3. Updates to package usage patterns can be propagated throughout the codebase
4. New team members can easily find authoritative documentation for package implementation

## Implementation Requirements

### 1. Documentation References in File Headers

Files that use external packages must include references to the relevant package documentation in their headers:

**IMPORTANT**: The documentation in `/precision_marketing/R_package_references/` is a git clone from the central GitHub repository and should never be modified directly. All changes to cross-project documentation must be made through the proper git workflow.

```r
#' @file customer_analysis.R
#' @principle R95 Import Requirements Rule
#' @principle R103 Package Documentation Reference Rule
#' @uses_package dplyr See 20_R_packages/dplyr.md for usage patterns
#' @uses_package ggplot2 See 20_R_packages/ggplot2.md for visualization standards
#' @author Analytics Team
#' @date 2025-04-13
```

### 2. Implementation Consistency

Code must follow the usage patterns specified in the referenced documentation:

```r
# CORRECT: Follows the dplyr usage pattern documented in 20_R_packages/dplyr.md
customers %>%
  filter(segment == "high_value") %>%
  group_by(region) %>%
  summarize(
    avg_value = mean(customer_value, na.rm = TRUE),
    count = n()
  )

# INCORRECT: Does not follow documented usage pattern
subset(customers, segment == "high_value")  # Not using the pipe operator as specified
```

### 3. Function Documentation References

Function documentation should reference the package documentation when implementing package-specific patterns:

```r
#' Analyze Customer Segments
#'
#' @param data Customer data frame
#' @return Analysis results
#' @note Implements dplyr grouping pattern from 20_R_packages/dplyr.md
analyze_segments <- function(data) {
  # Implementation following documented pattern
}
```

### 4. New Package Integration

When introducing a new package to the project:

1. Create documentation in `20_R_packages/[package_name].md` before using the package
2. Define standard usage patterns specific to the project's needs
3. Reference this documentation in all files using the new package

## Application Scope

This rule applies to:

1. **Core Functionality Packages**: Packages used for data manipulation, visualization, and modeling
2. **UI Framework Packages**: Packages providing UI components and styling
3. **Integration Packages**: Packages used for external system integration
4. **Specialized Analysis Packages**: Domain-specific packages for specialized analyses

## Documentation Requirements

Package documentation referenced by this rule should include:

1. **Standard Usage Patterns**: Canonical ways to use the package within the project
2. **Configuration Standards**: Standard options and configurations
3. **Function Selection Guidelines**: Which functions to use in which scenarios
4. **Integration Examples**: How to combine with other project components
5. **Versioning Requirements**: Package version constraints and compatibility notes

## Code Review Checklist

During code review, verify:

- [ ] File headers reference relevant package documentation
- [ ] Code follows the usage patterns in the referenced documentation
- [ ] Any deviations from standard patterns are explicitly justified in comments
- [ ] New package uses have corresponding documentation in `20_R_packages/`

## Benefits

1. **Consistency**: Ensures consistent implementation of package features
2. **Knowledge Transfer**: Facilitates knowledge sharing among team members
3. **Quality Control**: Provides clear standards for code review
4. **Maintenance**: Makes codebase maintenance more efficient
5. **Onboarding**: Accelerates onboarding of new team members

## Relation to Other Rules and Principles

This rule implements and extends:

- **MP57 Package Documentation**: Provides mechanism to enforce usage of package documentation
- **MP19 Package Consistency**: Ensures consistent usage patterns across the codebase
- **R95 Import Requirements Rule**: Complements centralized import management
- **P72 UI Package Consistency**: Reinforces consistency in UI component usage
- **R104 Package Function Reference Rule**: Works in tandem with more detailed function-level references

## Exceptions

Exceptions are allowed in the following cases:

1. **Prototyping**: During initial exploration and prototyping phases
2. **One-off Scripts**: Scripts that are not part of the main application
3. **Legacy Code**: During migration periods for existing code
4. **Specialized Use Cases**: When standard patterns do not support a specific need, with explicit documentation

In all exception cases, developers must document why they are deviating from standard patterns and consider updating the package documentation if new patterns prove useful.