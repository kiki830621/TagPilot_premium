---
id: "P0015"
title: "Dual ID Format Principle"
type: "principle"
date_created: "2025-04-06"
author: "Claude"
derives_from:
  - "MP0017": "Separation of Concerns"
  - "MP0030": "Vectorization Principle"
related_to:
  - "R0019": "Object Naming Convention"
  - "P0005": "Naming Principles"
---

# Dual ID Format Principle

## Core Principle

Identifiers (IDs) within the system must follow a dual format approach:

1. **Processing Context**: Use integer IDs for internal processing and data storage
2. **Display Context**: Use formatted string IDs for UI presentation and object naming

## Rationale

This principle optimizes for both computational efficiency and human usability:

- Integer IDs provide better performance for data operations
- Formatted string IDs provide better readability and context for humans
- Each representation is optimized for its specific context
- Separation eliminates the compromises required by a single format

## Implementation Guidelines

### Internal ID Format (Processing Context)

When IDs are used in databases, dataframes, or computational processes:

- **Use simple integers** as primary keys
- **Start from 1** for each entity type (customers, products, etc.)
- **Maintain sequential ordering** whenever possible
- **Avoid business logic in ID structure**
- **For compound keys, use separate integer columns** rather than encoded strings

```r
# Good: Simple integer IDs in dataframes
customer_data <- data.frame(
  id = 1:100,
  name = customer_names,
  revenue = revenue_values
)

# Good: Integer IDs in database schemas
customers_table <- "
CREATE TABLE customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT
);
"

# Good: Compound keys using multiple integer columns
sales_data <- data.frame(
  platform_id = rep(1:3, each = 5),
  customer_id = rep(1:5, times = 3),
  revenue = rnorm(15, 1000, 250)
)
```

### Display ID Format (UI Context)

When IDs are displayed to users or used in object naming:

- **Add type prefix** (e.g., "C" for customer, "P" for product)
- **Use consistent width** with leading zeros
- **Standard format**: [Type Prefix][Padded Number]
- **Recommended width**: 3 digits minimum (e.g., "C001")

```r
# Convert integer IDs to display format
customer_data$display_id <- sprintf("C%03d", customer_data$id)
product_data$display_id <- sprintf("P%03d", product_data$id)

# Use in UI elements
output$customer_table <- renderDataTable({
  datatable(customer_data[, c("display_id", "name", "revenue")])
})
```

### Object Naming

When creating named objects in code:

- **Use the formatted string ID** in the object name
- **Follow with descriptive text** when appropriate
- **Maintain standard prefixes** across the codebase

```r
# Good: Object names with formatted IDs
customer_C001 <- get_customer_data(1)
product_P042_details <- fetch_product_details(42)
report_R007_Q2 <- generate_report(7, quarter = 2)

# Bad: No type indication or inconsistent formatting
cust1 <- get_customer_data(1)
product_42_details <- fetch_product_details(42)
q2_report_7 <- generate_report(7, quarter = 2)
```

### Conversion Between Formats

Provide utility functions for converting between formats:

```r
# Integer ID to display ID
format_customer_id <- function(id) {
  sprintf("C%03d", id)
}

# Display ID to integer ID
parse_customer_id <- function(display_id) {
  as.integer(gsub("^C0*", "", display_id))
}
```

## Benefits

1. **Computational Efficiency**: Integer IDs optimize storage and processing
2. **Human Readability**: Formatted IDs provide context and improve recognition
3. **Error Reduction**: Type prefixes prevent mixing different entity IDs
4. **Consistent Appearance**: Fixed-width formatting improves visual scanning
5. **Separation of Concerns**: Each format serves its specific purpose

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Using string IDs in database joins | Convert to integers before joining |
| Inconsistent padding width | Use standard formatting functions |
| Missing type prefixes | Add entity-type indicators consistently |
| Exposing internal IDs to users | Always convert to display format for UI |
| Hard-coding format conversion | Use utility functions for all conversions |

## Integration with Other Principles

This principle complements:

- **R0019 (Object Naming Convention)**: Adds specific ID formatting to object names
- **P0005 (Naming Principles)**: Extends naming standards to include ID formatting
- **MP0017 (Separation of Concerns)**: Separates processing IDs from display IDs
- **MP0030 (Vectorization Principle)**: Supports efficient data operations with integer IDs
- **R117 (Dynamic Combined ID Pattern)**: Provides rules for generating combined IDs dynamically

## Examples

### Database Schema

```sql
CREATE TABLE customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  display_id TEXT GENERATED ALWAYS AS ('C' || SUBSTR('000' || id, -3, 3)) STORED,
  name TEXT,
  email TEXT
);
```

### Data Retrieval and Display

```r
# Retrieve using efficient integer ID
customer_data <- db_get_customer(id = 42)

# Display using formatted ID
ui_customer_profile <- function(id) {
  data <- db_get_customer(id)
  display_id <- sprintf("C%03d", id)
  
  div(
    h2(paste("Customer Profile:", display_id)),
    # Additional UI elements...
  )
}
```

### Object Creation Pattern

```r
create_customer_object <- function(id, data) {
  display_id <- sprintf("C%03d", id)
  obj_name <- paste0("customer_", display_id)
  
  # Create object with well-formatted name
  assign(obj_name, data, envir = .GlobalEnv)
  
  # Return the object name for reference
  return(obj_name)
}
```

By implementing this dual approach consistently, we optimize both system performance and human interaction with identifiers.
