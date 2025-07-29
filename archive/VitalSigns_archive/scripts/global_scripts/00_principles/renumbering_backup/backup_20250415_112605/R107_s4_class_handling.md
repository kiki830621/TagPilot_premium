# R107: S4 Class Safe Handling Rule

## Primary Statement
When interacting with S4 class objects (particularly database connections), always use standard access methods rather than direct slot access with the `$` operator, as the latter is undefined for S4 classes.

## Explanation
S4 is R's formal object-oriented class system that uses a different access mechanism compared to the more common S3 classes. This difference frequently causes issues when code attempts to use the `$` operator on S4 objects, resulting in the error "$ operator not defined for this S4 class". This rule ensures that all code handles S4 objects properly.

## Implementation

### Correct approaches:
1. Use standard accessor functions:
   ```r
   # Correct
   result <- dbGetQuery(conn, query)
   
   # Incorrect
   result <- conn$dbGetQuery(query)  # Will fail with S4 classes
   ```

2. Use the `@` operator for direct slot access (when necessary):
   ```r
   # Correct
   slot_value <- object@slot_name
   
   # Incorrect 
   slot_value <- object$slot_name  # Will fail with S4 classes
   ```

3. For DBI database connections, always use the standard DBI interface functions:
   ```r
   # Correct
   dbConnect()
   dbGetQuery()
   dbExecute()
   dbDisconnect()
   
   # Incorrect
   conn$query()
   conn$execute()
   ```

4. For filtering and query operations, use dbplyr and dplyr:
   ```r
   # Correct
   tbl_ref <- dplyr::tbl(conn, table_name)
   filtered <- tbl_ref %>% filter(condition)
   results <- dplyr::collect(filtered)
   
   # Also correct for SQL queries
   tbl_ref <- dplyr::tbl(conn, dbplyr::sql(query))
   results <- dplyr::collect(tbl_ref)
   ```

### Detection and Prevention:
1. Always check for inheritance with `inherits()` rather than class inspection:
   ```r
   # Correct
   if (inherits(conn, "DBIConnection")) {
     # Use DBI methods
   }
   
   # Avoid direct class check which can be fragile
   if (class(conn)[1] == "DBIConnection") {
     # Not recommended
   }
   ```

2. Wrap DBI operations in tryCatch to handle potential S4 class errors:
   ```r
   tryCatch({
     result <- dbGetQuery(conn, query)
   }, error = function(e) {
     if (grepl("S4 class", e$message)) {
       # Handle S4 class error appropriately
     }
     stop(e)  # Re-throw other errors
   })
   ```

## Benefits
- **Compatibility**: Code works consistently with all types of database connections
- **Robustness**: Avoids common runtime errors related to S4 classes
- **Maintainability**: Creates clearer code that follows standardized patterns
- **Extensibility**: Makes it easier to switch between database backends

## Related Rules
- R91: Universal Data Access Pattern
- R92: Universal DBI Approach
- R100: Database Access via tbl() Rule
- R101: Unified tbl-like Data Access Pattern

## Examples

### Problem Example
```r
# This will fail with S4 class objects like DuckDB connections
fetch_data <- function(conn, table_name) {
  # INCORRECT: Using $ operator on potentially S4 object
  result <- conn$query(paste("SELECT * FROM", table_name))
  return(result)
}
```

### Solution Example
```r
# This handles both S3 and S4 class objects properly
fetch_data <- function(conn, table_name) {
  # Check if this is a DBI connection
  if (inherits(conn, "DBIConnection")) {
    # Use standard DBI method
    return(dbReadTable(conn, table_name))
  } else if (is.function(conn$query)) {
    # Fall back to $ access only for objects that support it
    return(conn$query(paste("SELECT * FROM", table_name)))
  } else {
    stop("Unsupported connection type")
  }
}
```

## Background
The S4 class system was introduced to provide a more formal object-oriented framework in R, with stricter typing and validation compared to S3. While this provides benefits for complex systems like database interfaces, it requires different access patterns. This rule addresses one of the most common errors encountered when working with DBI database connections in R, particularly with backends like DuckDB, PostgreSQL, and SQLite that implement the DBI specification using S4 classes.