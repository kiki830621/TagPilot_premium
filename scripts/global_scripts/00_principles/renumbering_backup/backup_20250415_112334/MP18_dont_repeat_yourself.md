---
id: "MP18"
title: "Don't Repeat Yourself Principle"
type: "meta-principle"
date_created: "2025-04-02"
author: "Claude"
derives_from:
  - "MP00": "Axiomatization System"
  - "MP02": "Structural Blueprint"
influences:
  - "MP07": "Documentation Organization"
  - "P01": "Script Separation"
  - "P04": "App Construction Principles"
  - "P10": "Documentation Update Principle"
---

# Don't Repeat Yourself (DRY) Principle

This meta-principle establishes that each piece of knowledge or logic should have a single, authoritative representation within the system, eliminating duplication and enabling more maintainable, consistent, and evolvable code.

## Core Concept

Every piece of knowledge, logic, or functionality should have a single, unambiguous, authoritative representation within the system. When the same information is expressed in multiple places, it creates maintenance challenges, increases the risk of inconsistency, and complicates evolution.

## DRY Fundamentals

### 1. Knowledge Representation

The DRY principle applies to all forms of knowledge representation:

#### 1.1 Code Duplication
- Functions and algorithms should not be duplicated
- Business logic should be defined once, then reused
- Utility operations should be centralized
- Common patterns should be abstracted into reusable components

#### 1.2 Data Duplication
- Data structures should be defined once
- Constants and configuration values should have single sources
- Lookup tables should be normalized
- Reference data should be maintained in one location

#### 1.3 Documentation Duplication
- Each concept should be documented in one authoritative location
- Cross-references should be used instead of duplication
- Derived documentation should be generated from source when possible
- Principles should be defined once, then applied consistently

#### 1.4 Process Duplication
- Procedures should be documented once
- Automated processes should be defined as reusable workflows
- Setup steps should be captured in scripts
- Build and deployment processes should be standardized

### 2. Types of Duplication

Different types of duplication require different strategies:

#### 2.1 Literal Duplication
- Identical code copied across multiple locations
- Verbatim documentation repeated in different places
- Same configuration values defined multiple times

#### 2.2 Semantic Duplication
- Same concept implemented in different ways
- Different code performing identical functions
- Multiple implementations of the same business rule

#### 2.3 Temporal Duplication
- Knowledge that becomes duplicated over time
- Implementations that diverge as they evolve
- Documentation that gets out of sync with code

## Implementation Guidelines

### 1. Code Reuse Patterns

Apply these patterns to eliminate code duplication:

#### 1.1 Function Extraction
- Extract repeated code into named functions
- Parameterize functions to handle variations
- Place functions in appropriate utility modules

```r
# Instead of duplicating this logic:
if (is.null(data) || nrow(data) == 0) {
  return(NULL)
}

# Extract it into a function:
is_empty_data <- function(data) {
  return(is.null(data) || nrow(data) == 0)
}
```

#### 1.2 Abstraction
- Identify common patterns across specific implementations
- Create abstract functions that capture the common pattern
- Allow specific behavior to be passed as parameters

```r
# Instead of multiple similar functions:
process_sales_data <- function(data) { ... }
process_customer_data <- function(data) { ... }
process_product_data <- function(data) { ... }

# Create an abstraction:
process_data <- function(data, entity_type, processor_fn) {
  # Common processing steps
  validated_data <- validate_data(data, entity_type)
  processed <- processor_fn(validated_data)
  return(log_and_return(processed, entity_type))
}
```

#### 1.3 Inheritance and Composition
- Use inheritance to share behavior across related classes
- Use composition to build complex functionality from simpler parts
- Create mixins or traits for cross-cutting concerns

```r
# Using R6 for inheritance
BaseProcessor <- R6Class("BaseProcessor",
  public = list(
    process = function(data) {
      validated_data <- private$.validate(data)
      return(private$.process_impl(validated_data))
    }
  ),
  private = list(
    .validate = function(data) { ... },
    .process_impl = function(data) { stop("Must be implemented by subclass") }
  )
)

SalesProcessor <- R6Class("SalesProcessor",
  inherit = BaseProcessor,
  private = list(
    .process_impl = function(data) { ... }
  )
)
```

#### 1.4 Configuration Over Code
- Use configuration to drive behavior variations
- Extract variable elements to configuration files
- Allow customization without code duplication

```r
# Configuration-driven approach
entity_processors <- list(
  "sales" = list(
    validate_fn = validate_sales,
    transform_fn = transform_sales,
    required_fields = c("date", "amount", "customer_id")
  ),
  "customer" = list(
    validate_fn = validate_customer,
    transform_fn = transform_customer,
    required_fields = c("name", "customer_id", "segment")
  )
)

process_entity <- function(data, entity_type) {
  config <- entity_processors[[entity_type]]
  if (is.null(config)) stop("Unknown entity type")
  
  validated <- config$validate_fn(data, config$required_fields)
  return(config$transform_fn(validated))
}
```

### 2. Data Reuse Patterns

Apply these patterns to eliminate data duplication:

#### 2.1 Single Source of Truth
- Define constants and configuration values in one location
- Use central repositories for reference data
- Implement data access layers to provide consistent views

```r
# Instead of duplicating configuration:
MAX_ITEMS <- 1000
DEFAULT_TIMEOUT <- 30
LOG_LEVEL <- "INFO"

# Create a central configuration source:
config <- list(
  max_items = 1000,
  default_timeout = 30,
  log_level = "INFO"
)

# Then reference it:
if (length(items) > config$max_items) { ... }
```

#### 2.2 Normalization
- Apply database normalization principles to reduce redundancy
- Extract repeated data into reference tables
- Use foreign keys to maintain relationships

```r
# Instead of duplicating customer information:
orders <- data.frame(
  order_id = c(1, 2, 3),
  customer_name = c("Alice", "Bob", "Alice"),
  customer_email = c("alice@example.com", "bob@example.com", "alice@example.com"),
  amount = c(100, 150, 200)
)

# Normalize into separate tables:
customers <- data.frame(
  customer_id = c(1, 2),
  name = c("Alice", "Bob"),
  email = c("alice@example.com", "bob@example.com")
)

orders <- data.frame(
  order_id = c(1, 2, 3),
  customer_id = c(1, 2, 1),
  amount = c(100, 150, 200)
)
```

#### 2.3 Caching
- Cache computed results to avoid recalculation
- Implement memoization for expensive functions
- Use reactive expressions in Shiny to avoid redundant computation

```r
# Memoization to avoid redundant computation
compute_customer_metrics <- memoise::memoise(function(customer_id) {
  # Expensive computation
  return(metrics)
})
```

#### 2.4 Generated Data
- Generate derived data from source data
- Implement data transformation pipelines
- Use code generation for repetitive data structures

```r
# Generate validation functions from schema
generate_validator <- function(schema) {
  field_validators <- lapply(names(schema), function(field) {
    field_schema <- schema[[field]]
    validate_fn <- get_validator_for_type(field_schema$type)
    
    function(data) {
      validate_fn(data[[field]], field_schema)
    }
  })
  
  function(data) {
    lapply(field_validators, function(validator) validator(data))
    return(data)
  }
}
```

### 3. Documentation Reuse Patterns

Apply these patterns to eliminate documentation duplication:

#### 3.1 Single Source Documentation
- Document each concept in one authoritative location
- Use cross-references to link related documentation
- Follow the P10 Documentation Update Principle

```markdown
# Customer Segmentation

For details on the segmentation algorithm, see [Segmentation Algorithm](./segmentation_algorithm.md).

For implementation details, see the `calculate_segment` function in `07_models/customer_segmentation.R`.
```

#### 3.2 Generated Documentation
- Generate documentation from code when possible
- Use roxygen2 for R function documentation
- Implement automated document generation scripts

```r
#' Calculate customer segment based on purchase history
#'
#' @param customer_id The unique identifier for the customer
#' @param transactions The customer's transaction history
#' @return A character string indicating the customer segment
#' @examples
#' calculate_segment("C123", transactions_df)
calculate_segment <- function(customer_id, transactions) {
  # Implementation
}
```

#### 3.3 Documentation Templates
- Use standardized templates for similar documentation
- Ensure consistent structure across related documents
- Define required sections for different document types

```markdown
---
id: "MP18"
title: "Don't Repeat Yourself Principle"
type: "meta-principle"
---

# Don't Repeat Yourself Principle

## Core Concept

...

## Implementation Guidelines

...
```

### 4. Process Reuse Patterns

Apply these patterns to eliminate process duplication:

#### 4.1 Standardized Workflows
- Define standard workflows for common operations
- Implement workflow automation
- Create reusable templates for recurring processes

```r
# Standardized data processing workflow
process_data_workflow <- function(data_source, entity_type) {
  # 1. Extract data
  raw_data <- extract_data(data_source)
  
  # 2. Validate data
  validated_data <- validate_data(raw_data, entity_type)
  
  # 3. Transform data
  transformed_data <- transform_data(validated_data, entity_type)
  
  # 4. Load data
  load_data(transformed_data, entity_type)
  
  # 5. Log completion
  log_completion(entity_type)
}
```

#### 4.2 Script Automation
- Automate recurring tasks with scripts
- Create setup and initialization scripts
- Implement build and deployment automation

```r
# Initialization script
source("00_principles/sc_initialization_update_mode.R")
```

## DRY Boundaries and Exceptions

The DRY principle has important boundaries and exceptions:

### 1. Appropriate Duplication

Some forms of duplication may be acceptable:

1. **Performance Optimization**: When duplication significantly improves performance
2. **Decoupling**: When duplication reduces harmful coupling between components
3. **Readability**: When duplication improves code readability and comprehension
4. **Stability**: When duplication isolates components from changes in dependencies

### 2. Over-Abstraction Risks

Overzealous application of DRY can lead to problems:

1. **Premature Abstraction**: Creating abstractions before fully understanding commonalities
2. **Inappropriate Coupling**: Forcing unrelated components to share code
3. **Excessive Indirection**: Creating complex layers of abstraction that obscure intent
4. **Inflexible Abstractions**: Creating abstractions that don't accommodate future variations

### 3. Balancing DRY with Other Principles

DRY must be balanced with other principles:

1. **KISS (Keep It Simple, Stupid)**: Simple duplication may be better than complex abstraction
2. **YAGNI (You Aren't Gonna Need It)**: Don't create abstractions for anticipated future needs
3. **SRP (Single Responsibility Principle)**: Don't combine unrelated functionality just to reduce duplication
4. **Open/Closed Principle**: Abstractions should be open for extension but closed for modification

## Benefits of DRY

Applying the DRY principle provides these benefits:

1. **Reduced Maintenance Burden**: Changes need to be made in only one place
2. **Improved Consistency**: Behavior is consistent across the system
3. **Enhanced Readability**: Code intent is clearer with less redundancy
4. **Better Testability**: Centralized functionality is easier to test thoroughly
5. **Easier Evolution**: Changes can be made more confidently
6. **Reduced Bugs**: Fewer opportunities for inconsistencies to creep in
7. **Improved Performance**: Less code to execute and maintain
8. **Knowledge Preservation**: Knowledge is captured in a single, authoritative location

## Relationship to Other Principles

This meta-principle:

1. **Derives from MP00 (Axiomatization System)**: Establishes DRY as a foundational axiom
2. **Builds upon MP02 (Structural Blueprint)**: Provides guidance for reducing duplication in the system structure
3. **Influences MP07 (Documentation Organization)**: Shapes how documentation is organized to minimize duplication
4. **Affects P01 (Script Separation)**: Guides how functions are organized to avoid duplication
5. **Informs P04 (App Construction Principles)**: Directs how components should be reused rather than duplicated
6. **Supports P10 (Documentation Update Principle)**: Ensures that documentation changes maintain consistency

## Conclusion

The Don't Repeat Yourself (DRY) Principle establishes that each piece of knowledge should have a single, authoritative representation within the system. By eliminating duplication across code, data, documentation, and processes, we create a more maintainable, consistent, and evolvable system. While DRY must be balanced with other principles to avoid over-abstraction, its judicious application is essential for managing complexity and ensuring system integrity over time.
