# R0094: Roxygen2 Function Examples Standard

## Summary
All functions in this project should include standardized Roxygen2 examples in their documentation that demonstrate practical, executable use cases.

## Description
The Roxygen2 Function Examples Standard ensures consistent, high-quality documentation across the codebase by requiring clear, runnable examples that demonstrate the various ways a function can be used. These examples serve both as documentation and as a form of specification for how the function should behave.

## Implementation Guidelines

### Example Structure
- Examples should be included in the `@examples` Roxygen2 tag
- Multiple examples should demonstrate different use cases or parameter combinations
- Each example should be preceded by a comment describing the scenario
- Complex or resource-intensive examples should be wrapped in `if (FALSE) { ... }` to prevent execution during package checking

### Example Content
- Examples should be concise and focused on demonstrating the function's usage
- Include examples that show the function with default parameters and with custom parameters
- For functions supporting multiple input types, provide examples for each major type
- Examples should compile and run without errors when copy-pasted from documentation
- When appropriate, show both the function call and its expected output

### Naming Conventions
- Use descriptive variable names in examples (e.g., `customer_data` instead of `x`)
- Follow consistent naming patterns across similar functions
- When creating example data structures, use names that clearly indicate their purpose

## Example

```r
#' @examples
#' # Use with a list containing data frames
#' data_list <- list(customer_profile = data.frame(id = 1:3, name = c("A", "B", "C")))
#' customers <- universal_data_accessor(data_list, "customer_profile")
#'
#' # Use with a DBI database connection
#' # db_conn <- DBI::dbConnect(duckdb::duckdb(), "app_data.duckdb")
#' # customers <- universal_data_accessor(db_conn, "customer_profile")
#'
#' # Use with function-based connection
#' # fn_conn <- list(get_customer_profile = function() data.frame(id = 1:3, name = c("A", "B", "C")))
#' # customers <- universal_data_accessor(fn_conn, "customer_profile")
```

## Benefits
- **Improved Learning**: Developers can quickly understand how to use functions correctly
- **Reduced Errors**: Clear examples reduce misuse of functions
- **Self-Documentation**: Examples serve as living documentation of intended usage
- **Testing Assistance**: Examples provide a basis for creating test cases
- **Consistent Style**: Unified example style creates cohesive documentation

## Related Principles
- MP0016 Modularity: Well-documented functions with examples promote modular code reuse
- MP0017 Separation of Concerns: Examples demonstrate proper function usage within their domain
- P0076 Error Handling Patterns: Examples should demonstrate proper error handling
- R0091 Universal Data Access Pattern: Examples should show different connection types
- R0092 Universal DBI Approach: Examples should demonstrate database access patterns
