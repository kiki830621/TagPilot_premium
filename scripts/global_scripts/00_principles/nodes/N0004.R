# N0004.R
# eBay Connection Test Node
#
# This script demonstrates how to connect to the eBay database
# using the M01 (External Raw Data Connection) module.
#
# Node utilities are designed to be atomic, reusable components that can be
# leveraged by multiple derivations and sequences.

#' Get APP_DIR (main application directory)
#'
#' @return Path to the main application directory
#'
get_app_dir <- function() {
  # Start with current directory
  current_path <- getwd()
  
  # Check if we're in update_scripts or some subdirectory
  if(grepl("update_scripts", current_path)) {
    # Extract path up to precision_marketing_app
    app_dir <- sub("(.*precision_marketing_app).*", "\\1", current_path)
    if(app_dir != current_path) {
      return(app_dir)
    }
  }
  
  # If we're already in precision_marketing_app directory
  if(basename(current_path) == "precision_marketing_app") {
    return(current_path)
  }
  
  # If we couldn't determine APP_DIR, check parent directories
  parent_dir <- dirname(current_path)
  if(basename(parent_dir) == "precision_marketing_app") {
    return(parent_dir)
  }
  
  # If all else fails, make an educated guess based on typical structure
  if(grepl("precision_marketing", current_path)) {
    # Try to find app directory based on standard pattern
    app_pattern <- "(.*/precision_marketing[^/]*/precision_marketing_app)"
    app_match <- regmatches(current_path, regexec(app_pattern, current_path))[[1]]
    if(length(app_match) > 1) {
      return(app_match[2])
    }
  }
  
  # No suitable directory found, return current directory with warning
  warning("Could not determine APP_DIR, using current directory")
  return(current_path)
}

#' Source required module files
#'
#' @param module_path Path to the M01 module directory
#' @param platform Platform code (e.g., "06" for eBay)
#' @param verbose Logical, whether to print progress messages
#'
#' @return TRUE if successful, FALSE otherwise

source_module_files <- function(module_path = NULL, platform = "06", verbose = TRUE) {
  if(verbose) message("Sourcing module files...")
  
  # Determine module path if not provided
  if(is.null(module_path)) {
    # Try to get the APP_DIR
    app_dir <- get_app_dir()
    if(verbose) message("APP_DIR determined as: ", app_dir)
    
    # Try standard module locations relative to APP_DIR
    potential_paths <- c(
      file.path(app_dir, "update_scripts", "global_scripts", "00_principles", "M01"),
      file.path(app_dir, "global_scripts", "00_principles", "M01")
    )
    
    # Check each path
    found_module <- FALSE
    for(path in potential_paths) {
      if(verbose) message("Checking path: ", path)
      if(dir.exists(path)) {
        module_path <- path
        found_module <- TRUE
        if(verbose) message("Found module at: ", module_path)
        break
      }
    }
    
    # If not found in standard locations, try current working directory context
    if(!found_module) {
      if(verbose) message("Module not found in standard locations, trying based on working directory...")
      
      # Get current working directory
      script_path <- getwd()
      if(verbose) message("Current working directory: ", script_path)
      
      # Check based on directory context
      if(basename(script_path) == "nodes") {
        # We're in the nodes directory, go up to 00_principles
        module_path <- file.path(dirname(script_path), "M01")
        if(dir.exists(module_path)) {
          found_module <- TRUE
        }
      } else if(grepl("update_scripts", script_path)) {
        # We're somewhere in update_scripts, navigate relative to it
        base_path <- sub("(.*update_scripts).*", "\\1", script_path)
        module_path <- file.path(base_path, "global_scripts", "00_principles", "M01")
        if(dir.exists(module_path)) {
          found_module <- TRUE
        }
      }
    }
    
    if(!found_module) {
      stop("Cannot find module directory. Please provide module_path explicitly.")
    }
    
    if(verbose) message("Using module path: ", module_path)
  }
  
  # Check if path exists
  if(!dir.exists(module_path)) {
    stop("Module path not found: ", module_path)
  }
  
  # Source helper files
  helpers_path <- file.path(module_path, "connection_helpers.R")
  if(file.exists(helpers_path)) {
    if(verbose) message("Sourcing connection helpers: ", helpers_path)
    source(helpers_path)
  } else {
    warning("Connection helpers file not found: ", helpers_path)
  }
  
  # Source platform-specific implementation
  platform_path <- file.path(module_path, "platforms", platform, 
                           paste0("M01_P", platform, "_00.R"))
  if(file.exists(platform_path)) {
    if(verbose) message("Sourcing platform implementation: ", platform_path)
    source(platform_path)
    return(TRUE)
  } else {
    stop("Platform implementation not found: ", platform_path)
  }
}

#' Test connection to eBay database
#'
#' @param config_path Path to configuration file
#' @param use_tunnel Whether to use SSH tunneling
#' @param verbose Logical, whether to print progress messages
#'
#' @return Connection object if successful, otherwise NULL
#'
test_ebay_connection <- function(config_path = NULL, use_tunnel = TRUE, verbose = TRUE) {
  if(verbose) message("Testing connection to eBay database...")
  
  # Create credentials or use config file
  credentials <- list(
    use_tunnel = use_tunnel
  )
  
  # Test connection
  conn <- connect_to_external_source(credentials, config_path, verbose = verbose)
  
  if(is.null(conn)) {
    message("Failed to connect to eBay database")
    return(NULL)
  }
  
  # Run connection test
  test_result <- test_external_connection(conn, verbose = verbose)
  
  if(test_result) {
    return(conn)
  } else {
    disconnect_from_external_source(conn, verbose = verbose)
    return(NULL)
  }
}

#' Fetch recent orders from eBay
#'
#' @param conn Connection object
#' @param days Number of days to look back
#' @param limit Maximum number of records to retrieve
#' @param export_path Path to export results (optional)
#' @param export_format Format for export (csv, excel, json)
#' @param verbose Logical, whether to print progress messages
#'
#' @return Data frame with results, or FALSE if failed
#'
fetch_recent_orders <- function(conn = NULL, days = 30, limit = 100, 
                               export_path = NULL, export_format = "csv",
                               verbose = TRUE) {
  if(verbose) message("Fetching recent orders...")
  
  # Create connection if not provided
  close_after <- FALSE
  if(is.null(conn)) {
    if(verbose) message("No connection provided, creating new connection...")
    conn <- test_ebay_connection(verbose = verbose)
    close_after <- TRUE
    
    if(is.null(conn)) {
      message("Failed to create connection for query")
      return(FALSE)
    }
  }
  
  # Create query
  query <- paste0("
    SELECT TOP ", limit, "
      OrderID AS order_id,
      CustomerID AS customer_id,
      OrderDate AS order_date,
      TotalAmount AS total_amount,
      OrderStatus AS status
    FROM 
      eBay_Sales.dbo.Orders
    WHERE 
      OrderDate >= DATEADD(day, -", days, ", GETDATE())
    ORDER BY 
      OrderDate DESC
  ")
  
  # Execute query
  tryCatch({
    results <- execute_query(query, conn, verbose = verbose)
    
    if(is.null(results) || nrow(results) == 0) {
      message("No order data found")
      if(close_after) disconnect_from_external_source(conn, verbose = verbose)
      return(FALSE)
    }
    
    if(verbose) message("Retrieved ", nrow(results), " orders")
    
    # Export if path is provided
    if(!is.null(export_path)) {
      if(exists("export_data_to_csv") && export_format == "csv") {
        export_data_to_csv(results, export_path, verbose = verbose)
      } else if(exists("export_data_to_excel") && export_format == "excel") {
        export_data_to_excel(results, export_path, verbose = verbose)
      } else if(exists("export_data_to_json") && export_format == "json") {
        export_data_to_json(results, export_path, verbose = verbose)
      } else {
        # Basic export if N0001.R functions are not available
        write.csv(results, export_path, row.names = FALSE)
        if(verbose) message("Data exported to ", export_path)
      }
    }
    
    # Close connection if we created it
    if(close_after) {
      disconnect_from_external_source(conn, verbose = verbose)
    }
    
    return(results)
  }, error = function(e) {
    message("Error fetching order data: ", e$message)
    
    # Close connection if we created it
    if(close_after) {
      disconnect_from_external_source(conn, verbose = verbose)
    }
    
    return(FALSE)
  })
}

#' Main function to run the node
#'
#' @param days Number of days to look back for orders
#' @param limit Maximum number of orders to retrieve
#' @param export_path Path to export results (NULL for no export)
#' @param export_format Format for export (csv, excel, json)
#' @param verbose Logical, whether to print progress messages
#'
#' @return Results data frame if successful, otherwise FALSE
#'
run_ebay_connection_node <- function(days = 30, limit = 50, 
                                    export_path = "recent_ebay_orders.csv", 
                                    export_format = "csv",
                                    verbose = TRUE) {
  if(verbose) {
    message("====================================================")
    message("N0004: eBay Connection Test Node")
    message("====================================================")
  }
  
  # Source required module files
  success <- tryCatch({
    source_module_files(verbose = verbose)
  }, error = function(e) {
    message("Error sourcing module files: ", e$message)
    return(FALSE)
  })
  
  if(!success) {
    message("Failed to source required module files")
    return(FALSE)
  }
  
  # Also try to source the Export Node for export functionality
  tryCatch({
    export_node_path <- file.path(dirname(getwd()), "00_principles", "nodes", "N0001.R")
    if(file.exists(export_node_path)) {
      source(export_node_path)
      if(verbose) message("Successfully loaded export utilities from N0001.R")
    }
  }, error = function(e) {
    warning("Could not load export utilities: ", e$message)
  })
  
  # Test connection and fetch orders
  results <- fetch_recent_orders(
    days = days,
    limit = limit,
    export_path = export_path,
    export_format = export_format,
    verbose = verbose
  )
  
  if(is.data.frame(results)) {
    if(verbose) {
      message("====================================================")
      message("Connection test completed successfully.")
      message("Retrieved ", nrow(results), " orders from eBay database.")
      if(!is.null(export_path)) {
        message("Results exported to: ", export_path)
      }
      message("====================================================")
    }
    return(results)
  } else {
    if(verbose) {
      message("====================================================")
      message("Connection test failed.")
      message("====================================================")
    }
    return(FALSE)
  }
}

# Example usage
if(FALSE) {
  # Run the node with default parameters
  results <- run_ebay_connection_node()
  
  # Examine the first few rows
  head(results)
}