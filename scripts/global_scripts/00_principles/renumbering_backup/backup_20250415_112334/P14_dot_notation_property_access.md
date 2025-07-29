---
id: "P14"
title: "Dot Notation Property Access Principle"
type: "principle"
date_created: "2025-04-04"
date_modified: "2025-04-04"
author: "Claude"
implements:
  - "MP16": "Modularity"
  - "MP17": "Separation of Concerns"
  - "MP20": "Principle Language Versions"
related_to:
  - "MP24": "Natural SQL Language"
  - "R23": "Object Naming Convention"
  - "MP01": "Primitive Terms and Definitions"
---

# Dot Notation Property Access Principle

## Core Principle

All property access and hierarchical references within the precision marketing system should use consistent dot notation, following a hierarchical pattern from general to specific. This principle establishes dot notation as the standard access pattern for object properties and hierarchical references across all system components.

## Conceptual Framework

The Dot Notation Property Access Principle unifies reference patterns across code, data structures, and query languages. By establishing a consistent pattern where dots separate hierarchical levels from general to specific, this principle creates intuitive, predictable access patterns that align with natural hierarchical thinking.

This principle manifests in multiple contexts:
1. **Code Access Patterns**: How components access properties in code
2. **Naming Conventions**: How objects are named and referenced
3. **Query Languages**: How data sources and properties are referenced in queries
4. **Configuration Structures**: How settings are organized and accessed

## Implementation Guidelines

### 1. Object Property Access

When accessing object properties in code:

```r
# Preferred
customer.profile.contact.email

# Not preferred
customer$profile$contact$email
customer[["profile"]][["contact"]][["email"]]
```

### 2. Hierarchical Naming

When naming components that have hierarchical relationships:

```r
# Preferred
authentication.service.validate
ui.sidebar.navigation.controls

# Not preferred
authentication_service_validate
ui_sidebar_navigation_controls
```

### 3. Table and Schema References

When referencing database tables and schemas:

```r
# Preferred
Sales.Orders
Analytics.Reports.Performance

# Not preferred
Sales_Orders
Analytics_Reports_Performance
```

### 4. Configuration Access

When accessing configuration settings:

```r
# Preferred
config.database.connection.timeout
config.ui.theme.colors.primary

# Not preferred
config$database$connection$timeout
config[["ui"]][["theme"]][["colors"]][["primary"]]
```

### 5. Object Naming

When naming objects that have hierarchical classifications:

```r
# Preferred
df.amazon.sales.now.001
mdl.regression.sales.price_seasonality

# Not preferred
df_amazon_sales_now_001
mdl_regression_sales_price_seasonality
```

## Alignment with NSQL

This principle aligns with the Natural SQL Language (MP24) by using the same reference pattern:

NSQL:
```
transform Sales.Orders to OrderSummary
```

Object names:
```
df.Sales.Orders
```

Code access:
```r
result <- process_data(df.Sales.Orders)
```

This creates a cohesive system where the same pattern is used across all contexts.

## Benefits

1. **Consistency**: Creates a unified reference pattern across the system
2. **Readability**: Makes code more readable with clear property paths
3. **Discoverability**: Enables better IDE auto-completion and discovery
4. **Natural Hierarchy**: Matches human mental models of categorization
5. **Alignment**: Aligns with standard practices in many programming languages
6. **Query Integration**: Creates natural mapping between code and query languages

## Implementation Considerations

1. **R Language Context**: In R, both `$` and `[[]]` are common for accessing list elements, but this principle establishes dot notation as the preferred pattern for hierarchical naming and references, even if the underlying implementation uses different operators.

2. **Implementation Bridge**: Utility functions or operator overloading may be needed to bridge between dot notation in names/references and actual implementation in various languages and systems.

3. **Performance**: Consider caching or optimizing dot notation resolution in performance-critical paths if needed.

4. **Integration**: This principle should be integrated with naming conventions (R23) to create a cohesive reference system.

## Examples

### Example 1: Data Object Naming and Access

```r
# Object naming
df.customer.profile.active

# Data access
active_customers <- df.customer.profile.active[df.customer.profile.active$status == "active", ]
summary_stats <- calculate_statistics(df.customer.profile.active.purchases)
```

### Example 2: Service Component Organization

```r
# Service organization
services.authentication.validate_credentials <- function(username, password) { ... }
services.authentication.generate_token <- function(user_id) { ... }
services.users.get_profile <- function(user_id) { ... }

# Service usage
token <- services.authentication.generate_token(user_id)
profile <- services.users.get_profile(user_id)
```

### Example 3: Configuration Structure

```r
# Configuration structure
app.config.database.host <- "db.example.com"
app.config.database.port <- 5432
app.config.ui.theme <- "light"

# Configuration access
db_conn <- connect_db(app.config.database.host, app.config.database.port)
apply_theme(app.config.ui.theme)
```

## Conclusion

The Dot Notation Property Access Principle establishes a consistent pattern for hierarchical references across all aspects of the precision marketing system. By using dots to separate hierarchical levels from general to specific, this principle creates intuitive access patterns that align with natural thinking and create cohesion across code, naming conventions, and query languages.

This principle simplifies mental models, improves code readability, and creates natural alignment with the Natural SQL Language, enhancing overall system cohesion and developer productivity.
