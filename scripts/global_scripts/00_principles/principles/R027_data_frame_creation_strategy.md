---
id: "R0027"
title: "Data Frame Creation Strategy Pattern"
type: "rule"
date_created: "2025-04-04"
date_modified: "2025-04-04"
author: "Claude"
implements:
  - "MP0017": "Separation of Concerns"
  - "MP0018": "Don't Repeat Yourself"
related_to:
  - "R0023": "Object Naming Convention" 
  - "R0028": "Type-Token Distinction in Naming"
  - "P0002": "Data Integrity"
---

# Data Frame Creation Strategy Pattern

## Core Requirement

Data frame creation functions must implement the Strategy Pattern to ensure consistent table creation, validation, and storage while supporting different types of data frames, storage options, and database configurations.

## Design Pattern Selection

The Strategy Pattern has been selected as the most appropriate design pattern for data frame creation because:

1. **Varying Implementation Requirements**: Different data frames need specialized creation logic (standard, indexed, partitioned, time-series)
2. **Runtime Selection**: The exact creation strategy is often determined at runtime
3. **Separation of Concerns**: Cleanly separates data frame creation mechanics from business logic
4. **Extensibility**: New strategies can be added without modifying existing code
5. **Configuration-Driven**: Creation strategies can be specified in configuration rather than code

## Implementation Guidelines

### 1. Strategy Registry

A central registry should be maintained for data frame creation strategies:

```r
# Central registry for data frame creation strategies
df_creators <- list()

# Registration function
register_df_creator <- function(df_type, creator_fn) {
  df_creators[[df_type]] <- creator_fn
}

# Dispatch function
create_or_replace_df <- function(object_name, data, df_type = "standard", ...) {
  # Get the correct strategy
  creator <- df_creators[[df_type]]
  
  if (is.null(creator)) {
    stop("No data frame creator registered for type: ", df_type)
  }
  
  # Execute the strategy
  return(creator(object_name, data, ...))
}
```

### 2. Standard Strategy Implementations

The following standard strategies should be implemented:

#### 2.1 Standard Data Frame

```r
# Register standard data frame creator
register_df_creator("standard", function(object_name, data) {
  # Validate data structure
  validate_df_structure(data, object_name)
  
  # Store the data frame (implementation depends on storage system)
  if (is_db_storage_enabled()) {
    # Convert object name to table name for database storage
    table_name <- object_name_to_table_name(object_name)
    
    # Connect to the database
    con <- dbConnect(duckdb::duckdb(), get_db_path())
    on.exit(dbDisconnect(con), add = TRUE)
    
    # Create or replace the table
    if (dbExistsTable(con, table_name)) {
      dbRemoveTable(con, table_name)
    }
    
    # Write the table
    dbWriteTable(con, table_name, data)
  }
  
  # Return the data frame with appropriate class attributes
  class(data) <- c(object_name, "data.frame")
  
  # Assign to the global environment
  assign(gsub("\\.", "_", object_name), data, envir = .GlobalEnv)
  
  return(data)
})
```

#### 2.2 Indexed Data Frame

```r
# Register indexed data frame creator
register_df_creator("indexed", function(object_name, data, index_columns) {
  # Validate data structure
  validate_df_structure(data, object_name)
  
  # Validate index columns
  if (!all(index_columns %in% names(data))) {
    missing <- setdiff(index_columns, names(data))
    stop("Index columns not found in data: ", paste(missing, collapse = ", "))
  }
  
  # Store the data frame
  if (is_db_storage_enabled()) {
    # Convert object name to table name for database storage
    table_name <- object_name_to_table_name(object_name)
    
    # Connect to the database
    con <- dbConnect(duckdb::duckdb(), get_db_path())
    on.exit(dbDisconnect(con), add = TRUE)
    
    # Create or replace the table
    if (dbExistsTable(con, table_name)) {
      dbRemoveTable(con, table_name)
    }
    
    # Write the table
    dbWriteTable(con, table_name, data)
    
    # Create indexes
    for (col in index_columns) {
      index_name <- paste0(table_name, "_", col, "_idx")
      dbExecute(con, sprintf(
        "CREATE INDEX %s ON %s(%s)",
        index_name, table_name, col
      ))
    }
  }
  
  # Add metadata about indexes
  attr(data, "index_columns") <- index_columns
  
  # Set class
  class(data) <- c(object_name, "indexed_df", "data.frame")
  
  # Assign to the global environment
  assign(gsub("\\.", "_", object_name), data, envir = .GlobalEnv)
  
  return(data)
})
```

#### 2.3 Time-Series Data Frame

```r
# Register time-series data frame creator
register_df_creator("time_series", function(object_name, data, time_column = "date") {
  # Validate data structure
  validate_df_structure(data, object_name)
  
  # Validate time column
  if (!time_column %in% names(data)) {
    stop("Time column not found in data: ", time_column)
  }
  
  # Ensure time column is properly formatted
  if (is.character(data[[time_column]])) {
    data[[time_column]] <- as.Date(data[[time_column]])
  }
  
  # Store the data frame
  if (is_db_storage_enabled()) {
    # Convert object name to table name for database storage
    table_name <- object_name_to_table_name(object_name)
    
    # Connect to the database
    con <- dbConnect(duckdb::duckdb(), get_db_path())
    on.exit(dbDisconnect(con), add = TRUE)
    
    # Create or replace the table
    if (dbExistsTable(con, table_name)) {
      dbRemoveTable(con, table_name)
    }
    
    # Write the table
    dbWriteTable(con, table_name, data)
    
    # Create time-based index
    index_name <- paste0(table_name, "_", time_column, "_idx")
    dbExecute(con, sprintf(
      "CREATE INDEX %s ON %s(%s)",
      index_name, table_name, time_column
    ))
  }
  
  # Add time series metadata
  attr(data, "time_column") <- time_column
  
  # Set class for time series methods
  class(data) <- c(object_name, "ts_df", "data.frame")
  
  # Assign to the global environment
  assign(gsub("\\.", "_", object_name), data, envir = .GlobalEnv)
  
  return(data)
})
```

### 3. Helper Functions

Implement these helper functions to support the strategy pattern:

```r
# Validate data frame structure
validate_df_structure <- function(data, object_name) {
  if (!is.data.frame(data)) {
    stop("Data must be a data frame")
  }
  
  # Additional validation based on the object name
  # For example, check required columns based on naming convention
  
  return(TRUE)
}

# Check if database storage is enabled
is_db_storage_enabled <- function() {
  # Read from config or environment
  getOption("df_db_storage", TRUE)
}

# Get database path
get_db_path <- function() {
  # Read from config or environment
  getOption("df_db_path", "app_data.duckdb")
}

# Convert object name to table name
object_name_to_table_name <- function(object_name) {
  # Extract the main part (before any triple underscore)
  main_part <- strsplit(object_name, "___")[[1]][1]
  
  # Replace dots with underscores
  table_name <- gsub("\\.", "_", main_part)
  
  return(table_name)
}
```

## Usage Examples

### Example 1: Standard Data Frame

```r
# Prepare data
customer_data <- read_csv("customer_data.csv")

# Create standard data frame
df.amazon.customer <- create_or_replace_df("df.amazon.customer", customer_data)

# Use the data frame
head(df.amazon.customer)
```

### Example 2: Indexed Data Frame

```r
# Prepare data
product_data <- read_csv("product_data.csv")

# Create indexed data frame
df.amazon.product <- create_or_replace_df(
  "df.amazon.product", 
  product_data, 
  "indexed",
  index_columns = c("product_id", "category")
)

# Use the data frame with knowledge of indexes
products_in_category <- df.amazon.product[df.amazon.product$category == "Electronics", ]
```

### Example 3: Time-Series Data Frame

```r
# Prepare data
sales_data <- read_csv("sales_data.csv")

# Create time-series data frame
df.amazon.sales_daily <- create_or_replace_df(
  "df.amazon.sales_daily", 
  sales_data, 
  "time_series",
  time_column = "sale_date"
)

# Use with time-series methods
monthly_summary <- aggregate(df.amazon.sales_daily$revenue, 
                            by = list(month = format(df.amazon.sales_daily$sale_date, "%Y-%m")), 
                            FUN = sum)
```

### Example 4: Custom Strategy Registration

```r
# Register a custom strategy for partitioned data frames
register_df_creator("partitioned", function(object_name, data, partition_column) {
  # Validation
  validate_df_structure(data, object_name)
  
  if (!partition_column %in% names(data)) {
    stop("Partition column not found in data: ", partition_column)
  }
  
  # Database storage implementation
  if (is_db_storage_enabled()) {
    # Implementation details...
  }
  
  # Add metadata
  attr(data, "partition_column") <- partition_column
  
  # Set class
  class(data) <- c(object_name, "partitioned_df", "data.frame")
  
  # Assign to the global environment
  assign(gsub("\\.", "_", object_name), data, envir = .GlobalEnv)
  
  return(data)
})

# Use the custom strategy
df.amazon.sales_by_region <- create_or_replace_df(
  "df.amazon.sales_by_region", 
  sales_data, 
  "partitioned",
  partition_column = "region"
)
```

## Benefits

1. **Consistency**: Ensures all data frames are created with consistent validation and storage
2. **Extensibility**: New data frame types can be added without modifying existing code
3. **Separation of Concerns**: Separates data frame creation logic from business logic
4. **Centralized Configuration**: Storage options can be changed in one place
5. **Type Safety**: Enforces specific structures for different types of data frames
6. **Metadata Preservation**: Maintains important metadata about data frames
7. **Storage Flexibility**: Abstracts storage details, making it easier to change storage backends

## Relationship to Other Rules

### Relation to Object Naming Convention (R0023)

This rule complements R0023 by:
1. Ensuring proper handling of dot notation in object names
2. Supporting the storage of data frames while preserving their naming convention
3. Converting between object names and storage names consistently

### Relation to Type-Token Distinction (R0028)

This rule supports R0028 by:
1. Treating data frames as tokens of specific types
2. Maintaining type information in class attributes
3. Implementing specialized behavior for different data frame types

### Relation to Data Integrity (P0002)

This rule implements P0002 by:
1. Validating data frame structures during creation
2. Ensuring consistent database storage and retrieval
3. Maintaining metadata that describes the data's properties

## Conclusion

The Data Frame Creation Strategy Pattern rule establishes a flexible, extensible approach to creating and managing data frames in the precision marketing system. By implementing the Strategy Pattern, this rule ensures that data frames are created consistently, with appropriate validation, storage, and metadata assignment. The pattern allows for easy extension to support new types of data frames while maintaining backward compatibility with existing code.
