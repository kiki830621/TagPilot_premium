#' Example Usage of Mock DBI Utilities
#' 
#' This file demonstrates how to use the mock DBI utilities for testing
#' and development without requiring a real database connection.
#'
#' @principle R91 Universal Data Access Pattern

library(dplyr)

# Source the mock DBI utilities
source("update_scripts/global_scripts/00_principles/02_db_utils/fn_list_to_mock_dbi.R")

# Example 1: Create a basic mock DBI connection from a list of dataframes
example_basic_connection <- function() {
  # Create sample data frames
  customers <- data.frame(
    customer_id = 1:5,
    buyer_name = c("Zhang San", "Li Si", "Wang Wu", "Zhao Liu", "Chen Qi"),
    email = c("zhang@example.com", "li@example.com", "wang@example.com", 
              "zhao@example.com", "chen@example.com"),
    stringsAsFactors = FALSE
  )
  
  orders <- data.frame(
    order_id = 101:107,
    customer_id = c(1, 2, 1, 3, 2, 1, 4),
    amount = c(100, 200, 150, 300, 250, 175, 400),
    order_date = as.Date(c("2024-01-15", "2024-01-20", "2024-02-10", 
                            "2024-02-15", "2024-03-05", "2024-03-20", "2024-04-01")),
    stringsAsFactors = FALSE
  )
  
  # Create a list of data frames
  data_list <- list(
    customer_profile = customers,
    order_history = orders
  )
  
  # Convert to mock DBI connection
  mock_conn <- list_to_mock_dbi(data_list)
  
  # Query the mock connection using DBI-style interface
  customers_result <- mock_conn$dbGetQuery("SELECT * FROM customer_profile")
  orders_result <- mock_conn$dbGetQuery("SELECT * FROM order_history")
  
  # More complex query with WHERE clause (basic implementation)
  customer1_result <- mock_conn$dbGetQuery("SELECT * FROM customer_profile WHERE customer_id = 1")
  
  # Print results
  cat("All customers:\n")
  print(customers_result)
  
  cat("\nAll orders:\n")
  print(orders_result)
  
  cat("\nCustomer 1:\n")
  print(customer1_result)
  
  # Return the connection for further use
  return(mock_conn)
}

# Example 2: Create a connection with table name mapping
example_with_mapping <- function() {
  # Create sample data frames
  customers <- data.frame(
    customer_id = 1:3,
    buyer_name = c("Zhang San", "Li Si", "Wang Wu"),
    email = c("zhang@example.com", "li@example.com", "wang@example.com"),
    stringsAsFactors = FALSE
  )
  
  orders <- data.frame(
    order_id = 101:105,
    customer_id = c(1, 2, 1, 3, 2),
    amount = c(100, 200, 150, 300, 250),
    stringsAsFactors = FALSE
  )
  
  # Create a list of data frames with original names
  data_list <- list(
    customers = customers,
    orders = orders
  )
  
  # Create mapping to database table names
  mapping <- list(
    customers = "customer_profile",
    orders = "order_history"
  )
  
  # Convert to mock DBI connection with mapping
  mock_conn <- list_to_mock_dbi(data_list, mapping = mapping)
  
  # Query using mapped table names
  customers_result <- mock_conn$dbGetQuery("SELECT * FROM customer_profile")
  
  # Print results
  cat("Customers (using mapped table name):\n")
  print(customers_result)
  
  # Verify available tables
  cat("\nAvailable tables:\n")
  print(mock_conn$dbListTables())
  
  return(mock_conn)
}

# Example 3: Dynamic mock DBI connection
example_dynamic_connection <- function() {
  # Create a dynamic mock connection with inline data
  mock_conn <- create_dynamic_mock_dbi(
    customers = data.frame(
      customer_id = 1:3,
      buyer_name = c("Zhang San", "Li Si", "Wang Wu"),
      stringsAsFactors = FALSE
    ),
    orders = data.frame(
      order_id = 101:103,
      customer_id = c(1, 2, 1),
      amount = c(100, 200, 150),
      stringsAsFactors = FALSE
    )
  )
  
  # Extend the connection with additional data
  mock_conn <- extend_mock_dbi(
    mock_conn,
    list(
      products = data.frame(
        product_id = 1:2,
        product_name = c("Product A", "Product B"),
        price = c(50, 75),
        stringsAsFactors = FALSE
      )
    )
  )
  
  # Query the extended connection
  cat("Products:\n")
  print(query_mock_dbi(mock_conn, "SELECT * FROM products"))
  
  return(mock_conn)
}

# Example 4: Using with the universal_data_accessor
example_with_universal_data_accessor <- function() {
  # Source the universal data accessor
  source("update_scripts/global_scripts/00_principles/02_db_utils/fn_universal_data_accessor.R")
  
  # Create a mock DBI connection
  mock_conn <- list_to_mock_dbi(list(
    customer_profile = data.frame(
      customer_id = 1:3,
      buyer_name = c("Zhang San", "Li Si", "Wang Wu"),
      email = c("zhang@example.com", "li@example.com", "wang@example.com"),
      stringsAsFactors = FALSE
    ),
    dna_by_customer = data.frame(
      customer_id = 1:2,
      time_first = as.Date(c("2022-01-15", "2021-03-20")),
      time_first_to_now = c(450, 780),
      r_label = c("極近", "一般"),
      r_value = c(5, 45),
      f_label = c("非常高", "一般"),
      f_value = c(12, 4),
      stringsAsFactors = FALSE
    )
  ))
  
  # Use the universal data accessor with the mock connection
  customer_data <- universal_data_accessor(
    mock_conn,
    "customer_profile",
    log_level = 1
  )
  
  dna_data <- universal_data_accessor(
    mock_conn,
    "dna_by_customer",
    log_level = 1
  )
  
  # Print results
  cat("Customer data retrieved through universal_data_accessor:\n")
  print(customer_data)
  
  cat("\nDNA data retrieved through universal_data_accessor:\n")
  print(dna_data)
  
  return(mock_conn)
}

# Example 5: Using with Shiny
example_use_in_shiny <- function() {
  # This would be inside a Shiny app
  cat("Example Shiny server function using mock DBI:\n\n")
  cat("```r\n")
  cat("server <- function(input, output, session) {\n")
  cat("  # Create a reactive mock DBI connection\n")
  cat("  db_conn <- reactive({\n")
  cat("    # In a real app, you might use an actual database\n")
  cat("    # For testing, use a mock connection\n")
  cat("    list_to_mock_dbi(list(\n")
  cat("      customer_profile = data.frame(\n")
  cat("        customer_id = 1:3,\n")
  cat("        buyer_name = c(\"Zhang San\", \"Li Si\", \"Wang Wu\"),\n")
  cat("        email = c(\"zhang@example.com\", \"li@example.com\", \"wang@example.com\")\n")
  cat("      ),\n")
  cat("      dna_by_customer = data.frame(\n")
  cat("        customer_id = 1:2,\n")
  cat("        time_first = as.Date(c(\"2022-01-15\", \"2021-03-20\")),\n")
  cat("        r_label = c(\"極近\", \"一般\"),\n")
  cat("        f_value = c(12, 4)\n")
  cat("      )\n")
  cat("    ))\n")
  cat("  })\n")
  cat("\n")
  cat("  # Initialize the module with mock connection\n")
  cat("  microCustomerServer(\"customer_module\", db_conn)\n")
  cat("}\n")
  cat("```\n")
}

# Run examples
if (interactive()) {
  # Choose which example to run by uncommenting one of the following:
  # example_basic_connection()
  # example_with_mapping()
  # example_dynamic_connection()
  # example_with_universal_data_accessor()
  # example_use_in_shiny()
}