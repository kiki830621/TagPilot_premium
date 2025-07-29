# Database Setup Script
# This script initializes database connections without requiring full initialization
# Add this to your initialization logic to ensure db_path_list is properly initialized

# Function to initialize database paths and connections
initialize_database_connections <- function(verbose = TRUE) {
  # Basic check for DBI and duckdb packages
  if(!requireNamespace("DBI", quietly = TRUE)) install.packages("DBI")
  if(!requireNamespace("duckdb", quietly = TRUE)) install.packages("duckdb")
  
  # Load packages if not already loaded
  if (!exists("dbConnect", mode = "function")) library(DBI)
  if (!exists("duckdb", mode = "function")) library(duckdb)
  
  # Directly source required functions
  db_utils_dir <- file.path("update_scripts", "global_scripts", "02_db_utils")
  
  # Source get_default_db_paths
  paths_function_path <- file.path(db_utils_dir, "fn_get_default_db_paths.R")
  if(file.exists(paths_function_path)) {
    source(paths_function_path)
    if(verbose) message("Sourced database paths function from: ", paths_function_path)
  } else {
    stop("Unable to find database paths function at: ", paths_function_path)
  }
  
  # Source dbConnect_from_list
  connect_function_path <- file.path(db_utils_dir, "fn_dbConnect_from_list.R")
  if(file.exists(connect_function_path)) {
    source(connect_function_path)
    if(verbose) message("Sourced database connection function from: ", connect_function_path)
  } else {
    stop("Unable to find database connection function at: ", connect_function_path)
  }
  
  # Initialize database paths if not already done
  if(!exists("db_path_list") && exists("get_default_db_paths")) {
    db_path_list <<- get_default_db_paths()
    if(verbose) {
      message("Database paths initialized to:")
      for(db_name in names(db_path_list)) {
        message(" - ", db_name, ": ", db_path_list[[db_name]])
      }
    }
  }
  
  # Create alias if not exists
  if(exists("fn_dbConnect_from_list") && !exists("dbConnect_from_list")) {
    dbConnect_from_list <<- fn_dbConnect_from_list
    if(verbose) message("Created alias: dbConnect_from_list -> fn_dbConnect_from_list")
  }
  
  # Return TRUE if successfully initialized
  return(exists("db_path_list") && exists("dbConnect_from_list"))
}

# Initialize database connections when this script is sourced
initialize_database_connections()

# Usage Example:
# source("update_scripts/global_scripts/db_setup.R")
# raw_data <- dbConnect_from_list("raw_data")
# processed_data <- dbConnect_from_list("processed_data")