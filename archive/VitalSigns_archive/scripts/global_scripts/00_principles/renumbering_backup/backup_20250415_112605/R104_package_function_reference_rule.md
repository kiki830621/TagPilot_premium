# Package Function Reference Rule

## Core Rule

All package documentation must include a comprehensive reference section detailing individual function usage with minimal working examples. These references must be stored in the centralized `R_package_references` folder at the precision_marketing root directory.

## Rationale

While high-level usage patterns are essential, developers often need quick reference to specific function signatures, parameter descriptions, and working examples. By requiring comprehensive function references with minimal examples:

1. Developers can quickly understand how to use specific functions correctly
2. Knowledge sharing becomes more precise and actionable
3. Code consistency improves through standardized function usage
4. Onboarding time is reduced for new team members
5. Centralization ensures all projects access the same reference materials

## Implementation Requirements

### 1. Central Reference Location

All package references must be stored in the centralized repository:

```
/precision_marketing/R_package_references/
├── dplyr/
│   ├── filter.md
│   ├── select.md
│   └── ...
├── bs4Dash/
│   ├── valueBox.md
│   ├── box.md
│   └── ...
└── ...
```

### 2. Function Reference Structure

Each function reference must follow this structure:

```markdown
# function_name

## Description
Brief description of the function's purpose.

## Usage
```r
function_name(param1, param2, ...)
```

## Arguments
| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| param1 | Type | Description of param1 | Default value |
| param2 | Type | Description of param2 | Default value |
| ... | ... | ... | ... |

## Return Value
Description of what the function returns.

## Minimal Example
```r
# Simplest possible working example
library(package_name)
result <- function_name(minimal_params)
print(result)
```

## Common Usage Pattern
```r
# Example of how the function is typically used in our codebase
library(package_name)
# More realistic example with typical parameters
```

## Notes
Additional information about edge cases, performance considerations, etc.

## Related Functions
- `related_function1`: Brief description of relationship
- `related_function2`: Brief description of relationship
```

### 3. Package-Level Index

Each package must have an index file that lists all documented functions:

```markdown
# Package Name Reference Index

## Core Functions
- [`function1`](function1.md): Brief description
- [`function2`](function2.md): Brief description

## Helper Functions
- [`helper1`](helper1.md): Brief description

## Advanced Functions
- [`advanced1`](advanced1.md): Brief description
```

### 4. Documentation References 

Files using functions from external packages must reference both:

1. The high-level package documentation from `20_R_packages/`
2. The specific function references from the central repository

```r
#' @file customer_analysis.R
#' @principle R95 Import Requirements Rule
#' @principle R103 Package Documentation Reference Rule
#' @principle R104 Package Function Reference Rule
#' @uses_package dplyr See 20_R_packages/dplyr.md for usage patterns
#' @uses_function dplyr::filter See /precision_marketing/R_package_references/dplyr/filter.md
#' @uses_function dplyr::select See /precision_marketing/R_package_references/dplyr/select.md
```

## Integration Process

### Updating Function References

1. **New Functions**: When using a function for the first time:
   - Create a function reference if it doesn't exist
   - Add minimal examples based on your implementation
   - Update the package index

2. **Existing References**: When implementing a function with an existing reference:
   - Follow the documented patterns
   - If finding a better approach, update the reference with approval

### Git Workflow for Reference Updates

References should be maintained through a standardized git workflow:

1. Clone the central reference repository
2. Create a branch for your updates
3. Add or update function references
4. Submit a pull request for review
5. After approval, merge changes

**IMPORTANT**: Never directly modify files in the cloned repository within the `/precision_marketing/R_package_references/` directory. This directory is a git clone from the central GitHub repository and should only be updated through proper git workflow (pull, branch, commit, push, PR). All changes must be made through the GitHub process to maintain consistency and version control.

## Example Implementation

### Example Function Reference: dplyr::filter

```markdown
# filter

## Description
Subset rows in a data frame using logical conditions.

## Usage
```r
filter(.data, ...)
```

## Arguments
| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| .data | data.frame/tibble | Input data frame | Required |
| ... | expressions | Logical conditions to filter by | Required |

## Return Value
A data frame with rows matching the conditions.

## Minimal Example
```r
library(dplyr)
mtcars %>% filter(cyl == 6)
```

## Common Usage Pattern
```r
# Standard usage in our codebase
customer_data %>%
  filter(
    segment == "high_value",
    transaction_date >= start_date,
    transaction_date <= end_date
  )
```

## Notes
- Multiple conditions are combined with AND logic
- Use filter(condition1 | condition2) for OR logic
- Prefers piped syntax with the %>% operator
- NA values will be excluded - use `is.na()` explicitly to include them

## Related Functions
- `slice()`: Filter rows by position
- `distinct()`: Filter for unique rows
- `arrange()`: Sort rows but don't filter
```

## Benefits

1. **Precision**: Specific guidance on exactly how to use each function
2. **Standardization**: Consistent function usage across teams
3. **Learning**: Minimal examples facilitate rapid learning
4. **Discoverability**: Related functions help developers find better tools
5. **Onboarding**: New developers can quickly learn correct usage patterns

## Relation to Other Rules and Principles

This rule extends and complements:

- **R103 Package Documentation Reference Rule**: Adds function-level detail to package-level documentation
- **MP57 Package Documentation Meta-Principle**: Provides structure for detailed function documentation
- **MP19 Package Consistency Principle**: Ensures consistent function usage across projects

## Exception Cases

1. **Internal Functions**: Documentation not required for unexported package functions
2. **Rarely Used Functions**: For one-off usage in scripts, full documentation may be simplified
3. **Rapidly Evolving Packages**: For packages in active development, documentation may be maintained in a separate branch until APIs stabilize