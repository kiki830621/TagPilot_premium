# Database Utilities

This directory contains database utility functions used throughout the Precision Marketing application.

## Key Components

### Enhanced Data Access with tbl2 (R116)

The `tbl2` function (`fn_tbl2.R`) extends `dplyr::tbl()` to provide a unified interface for working with various data types while maintaining full compatibility with the dplyr ecosystem:

- Full support for all DBI database connections
- Enhanced handling for lists and nested structures
- Support for file paths (CSV, Excel, JSON)
- Function-based data access
- Automatic conversion of vectors and simple objects
- Integration with Shiny reactive expressions
- Consistent pipe operator (`%>%`) compatibility

This enhanced interface is the preferred way to access data throughout the application following R116.

### Safe Row Count with nrow2 (R116)

The `nrow2` function (`fn_nrow2.R`) provides a safe way to get row counts from any data source:

- Returns 0 instead of errors for NULL or invalid inputs
- Handles error cases gracefully without crashing
- Works with any object type that might have rows
- Special handling for tbl/tbl_sql objects to efficiently count rows using database-side count queries
- Avoids materializing full datasets when counting rows in database references
- Useful for defensive programming and error-resistant code

### Universal Data Accessor Pattern (R91, R114, R116)

The `universal_data_accessor` function (`fn_universal_data_accessor.R`) provides a consistent interface for accessing data from various sources, including:

- DBI database connections (DuckDB, SQLite, PostgreSQL)
- List-based data sources (direct data access)
- Function-based connections (get_* function patterns)
- Mixed connections (combination of direct and function-based)
- Reactive expressions (for Shiny integration)
- Multiple SQL queries using the query_objects parameter
- Integration with the Standard Mock Database (R114)
- Uses tbl2 internally for enhanced data access (R116)

This pattern enables components to be agnostic about the underlying data source, allowing for flexible deployment and testing.

### Testing Framework (R99)

The comprehensive testing framework (`universal_data_accessor_comprehensive_test.R`) demonstrates the implementation of R99 Test App Building Principles:

- Tests all connection types with multiple data scenarios
- Supports both automated and interactive testing
- Validates error handling and edge cases
- Provides clear test reporting and metrics

### Other Utilities

This directory also includes other database utilities for:

- Connection management (connect, disconnect)
- Table operations (copy, read, delete)
- Mock connection creation for testing
- Path configuration

## Usage Examples

### Universal Data Accessor

```r
# Using with a DBI connection (now uses tbl() internally per R100)
db_conn <- dbConnect(duckdb::duckdb(), dbdir = "app_data.duckdb")
customer_data <- universal_data_accessor(db_conn, "customer_profile")

# Using with a custom SQL query (also uses tbl() with sql() internally)
customer_orders <- universal_data_accessor(
  db_conn, 
  "ignored", 
  query_template = "SELECT c.*, o.order_id FROM customer_profile c JOIN orders o ON c.id = o.customer_id"
)

# Using with a list of data
data_list <- list(
  customer_profile = data.frame(id = 1:3, name = c("A", "B", "C"))
)
customer_data <- universal_data_accessor(data_list, "customer_profile")

# Using with a function-based connection
fn_conn <- list(
  get_customer_profile = function() {
    # Retrieve data from any source
    return(data.frame(id = 1:3, name = c("A", "B", "C")))
  }
)
customer_data <- universal_data_accessor(fn_conn, "customer_profile")

# Using with a reactive expression in Shiny
data_conn <- reactive({ app_connection })
customer_data <- universal_data_accessor(data_conn, "customer_profile")
```

### Enhanced Data Access with tbl2 (R116)

```r
# Use tbl2 for consistent access to any data source
# Load the function
source("update_scripts/global_scripts/02_db_utils/fn_tbl2.R")

# With database connections (same as dplyr::tbl but more robust)
db_conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = "app_data.duckdb")
customers_ref <- tbl2(db_conn, "customer_profile")

# Apply dplyr operations just like normal
active_customers_ref <- customers_ref %>%
  filter(status == "active") %>%
  select(id, name, email)

# Only collect the data when needed
active_customers <- collect(active_customers_ref)

# With file sources
excel_data <- tbl2("data/sales.xlsx", "Q1_2023") %>%
  filter(amount > 1000) %>%
  collect()

# With lists and other data types
data_list <- list(customers = data.frame(id = 1:5, name = c("A", "B", "C", "D", "E")))
customers <- tbl2(data_list, "customers") %>%
  filter(id > 2) %>%
  collect()

# With vectors (automatically converts to tibble)
numbers <- c(1, 2, 3, 4, 5)
stats <- tbl2(numbers) %>%
  summarize(mean = mean(.), sd = sd(.)) %>%
  collect()
```

### Safe Row Count with nrow2 (R116)

```r
# Load the function
source("update_scripts/global_scripts/02_db_utils/fn_nrow2.R")

# With standard data frame - just like normal nrow
df <- data.frame(a = 1:3, b = 4:6)
count <- nrow2(df)  # Returns 3

# With NULL input - returns 0 instead of error
count <- nrow2(NULL)  # Returns 0

# With invalid object type - returns 0 instead of error
count <- nrow2(1:10)  # Returns 0 

# With database tbl reference - uses optimized COUNT query
db_conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = "app_data.duckdb")
customers_ref <- tbl2(db_conn, "customers") %>%
  filter(status == "active")

# Count rows without materializing the entire dataset
active_count <- nrow2(customers_ref)  # Translates to efficient COUNT(*) query

# Safe usage in conditional statements
if (nrow2(my_data) > 0) {
  # Process data safely even if my_data might be NULL
  # or an object that doesn't support nrow()
}

# For data access pipelines with conditional logic
result <- tbl2(conn, "customers") %>%
  filter(status == "active") %>%
  collect()

if (nrow2(result) == 0) {
  # Handle empty result case
} else {
  # Process data
}
```

### Advanced Database Usage with tbl() (R100)

```r
# The universal_data_accessor automatically applies these patterns internally
# but for direct database work without tbl2, you can use these patterns:

# Get a table reference without immediately fetching the data
db_conn <- dbConnect(duckdb::duckdb(), dbdir = "app_data.duckdb")
customers_ref <- dplyr::tbl(db_conn, "customer_profile")

# Apply filters at the database level
active_customers_ref <- customers_ref %>%
  dplyr::filter(status == "active") %>%
  dplyr::select(id, name, email)

# Only collect the data when you need it
active_customers <- dplyr::collect(active_customers_ref)

# See the SQL that will be generated
dplyr::show_query(active_customers_ref)
```

### Unified tbl-like Data Access (R101)

The universal_data_accessor now creates a consistent tbl-like interface for all data sources:

```r
# Create a function to access data in a tbl-like way
access_data <- function(conn, data_name) {
  # This function wraps universal_data_accessor to give unified access
  # It handles all data types (database, list, function-based) consistently
  
  # For demonstration purposes only (the actual implementation is inside universal_data_accessor)
  if (inherits(conn, "DBIConnection")) {
    # Use dplyr::tbl for databases
    ref <- dplyr::tbl(conn, data_name)
  } else if (is.list(conn)) {
    # Create a reference object for non-database sources
    ref <- list(
      data = function() {
        # Access data based on pattern (simplified for example)
        if (!is.null(conn[[data_name]])) {
          return(conn[[data_name]])
        } else {
          get_fn <- paste0("get_", data_name)
          if (is.function(conn[[get_fn]])) {
            return(conn[[get_fn]]())
          }
        }
        return(NULL)
      },
      filter = function(expr) {
        # Store the filter for later application
        # Will be applied during collect()
        return(ref)
      },
      select = function(...) {
        # Store the columns for later selection
        # Will be applied during collect()
        return(ref)
      },
      collect = function() {
        # Get the data and apply filters and select
        data <- ref$data()
        # Apply filters and select here
        return(data)
      }
    )
  }
  
  return(ref)
}

# Example usage (conceptual - universal_data_accessor handles this internally)

# Database connection
db_conn <- dbConnect(duckdb::duckdb(), dbdir = "app_data.duckdb")
customers <- access_data(db_conn, "customers") %>%
  filter(region == "East") %>%
  select(id, name, email) %>%
  collect()

# List connection
list_conn <- list(customers = data.frame(...))
customers <- access_data(list_conn, "customers") %>%
  filter(region == "East") %>%
  select(id, name, email) %>%
  collect()

# Function-based connection
fn_conn <- list(get_customers = function() { ... })
customers <- access_data(fn_conn, "customers") %>%
  filter(region == "East") %>%
  select(id, name, email) %>%
  collect()
```

### Running Tests

To run the comprehensive test suite:

```r
source("update_scripts/global_scripts/02_db_utils/universal_data_accessor_comprehensive_test.R")
```

To run the interactive test app:

```r
# After sourcing the test file
create_interactive_test_app()
```

## Implemented Principles

- **MP16 Modularity**: Functions are modular and focused on a single responsibility
- **MP17 Separation of Concerns**: Data access is separated from business logic
- **MP81 Explicit Parameter Specification**: Clear and explicit parameter documentation
- **P74 Test Data Design Patterns**: Test data fixtures with multiple scenarios
- **P76 Error Handling Patterns**: Consistent error handling and reporting
- **P77 Performance Optimization**: Efficient data access patterns
- **R76 Module Data Connection**: Standard for how modules connect to data sources
- **R91 Universal Data Access Pattern**: Consistent data access interface
- **R92 Universal DBI Approach**: Standard approach to database interactions
- **R99 Test App Building Principles**: Comprehensive testing strategy
- **R100 Database Access via tbl() Rule**: Using dplyr::tbl() for optimized database access
- **R101 Unified tbl-like Data Access Pattern**: Consistent tbl-like interface for all data sources
  (See [tbl pattern rationale](../00_principles/P_R100_R101_tbl_pattern_rationale.md) for why this approach is used for all data types)
- **R114 Standard Mock Database Rule**: Using standardized mock_data.duckdb for consistent testing
- **R116 Enhanced Data Access with tbl2**: Extended data access through tbl2 function and related utilities (nrow2)