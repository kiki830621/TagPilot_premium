# N01_P01_00.R
# Implementation of N01 (Data Export Utility) for Amazon platform (01/AMZ)
#
# This script implements the platform-specific version of the N01 node
# as defined in N01/N01.md.
#
# Platform: Amazon (01/AMZ) per R38 Platform Numbering Convention

#' Export Amazon sales data to CSV format
#'
#' @param start_date Start date for data export (YYYY-MM-DD)
#' @param end_date End date for data export (YYYY-MM-DD)
#' @param export_path Path to save the exported file
#' @param include_headers Logical, whether to include headers in export
#' @param verbose Logical, whether to print progress messages
#'
#' @return Path to the exported file if successful, otherwise FALSE
#'
export_amazon_sales_data <- function(start_date, end_date, export_path = NULL, include_headers = TRUE, verbose = TRUE) {
  if(verbose) message("Starting Amazon sales data export...")
  
  # Source utility functions
  source(file.path(get_root_path(), "update_scripts", "global_scripts", "00_principles", "fn_root_path_config.R"))
  
  # Set default export path if not provided
  if(is.null(export_path)) {
    export_dir <- file.path(get_root_path(), "exports")
    if(!dir.exists(export_dir)) dir.create(export_dir, recursive = TRUE)
    export_path <- file.path(export_dir, paste0("amazon_sales_", format(Sys.Date(), "%Y%m%d"), ".csv"))
  }
  
  tryCatch({
    # Connect to the raw_data database
    db_path <- file.path(get_root_path(), "raw_data.duckdb")
    conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = db_path, read_only = TRUE)
    on.exit(DBI::dbDisconnect(conn, shutdown = TRUE))
    
    if(verbose) message("Connected to raw_data database")
    
    # Define export query with Amazon-specific fields and formatting
    query <- sprintf("
    SELECT
      order_id,
      customer_id,
      customer_email,
      order_time,
      order_total,
      order_status,
      'amazon' AS marketplace,
      'FBA' AS fulfillment_type,
      shipping_method,
      'USD' AS currency_code  -- Amazon US uses USD
    FROM
      df_amazon_sales
    WHERE
      order_time >= '%s' AND order_time <= '%s'
    ORDER BY
      order_time DESC
    ", start_date, end_date)
    
    # Execute query
    if(verbose) message("Executing export query...")
    data <- DBI::dbGetQuery(conn, query)
    
    if(nrow(data) == 0) {
      warning("No data found for the specified date range")
      return(FALSE)
    }
    
    # Apply Amazon-specific formatting
    # - Convert order_time to Amazon-friendly format (MM/DD/YYYY HH:MM:SS)
    data$order_time <- format(as.POSIXct(data$order_time), "%m/%d/%Y %H:%M:%S")
    
    # Add Amazon-specific headers
    if(include_headers) {
      # Add Amazon branding and export information
      headers <- c(
        paste0("# Amazon Sales Data Export"),
        paste0("# Date Range: ", start_date, " to ", end_date),
        paste0("# Export Date: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
        paste0("# Records: ", nrow(data)),
        ""  # Empty line before data
      )
      
      # Write headers to file
      writeLines(headers, export_path)
      
      # Append data
      write.table(data, export_path, append = TRUE, sep = ",", 
                  col.names = TRUE, row.names = FALSE, quote = TRUE)
    } else {
      # Write data without headers
      write.csv(data, export_path, row.names = FALSE)
    }
    
    if(verbose) message(paste0("Export complete: ", nrow(data), " records written to ", export_path))
    
    return(export_path)
    
  }, error = function(e) {
    message("Error exporting Amazon data: ", e$message)
    return(FALSE)
  })
}

#' Main function to execute the node
#'
#' @param start_date Start date for data export (YYYY-MM-DD)
#' @param end_date End date for data export (YYYY-MM-DD)
#' @param export_path Path to save the exported file
#' @param verbose Logical, whether to print progress messages
#'
#' @return Path to the exported file if successful, otherwise FALSE
#'
execute_N01_P01_00 <- function(start_date = NULL, end_date = NULL, export_path = NULL, verbose = TRUE) {
  # Default to last 30 days if dates not provided
  if(is.null(end_date)) end_date <- format(Sys.Date(), "%Y-%m-%d")
  if(is.null(start_date)) start_date <- format(Sys.Date() - 30, "%Y-%m-%d")
  
  if(verbose) {
    message("Executing Amazon data export node")
    message(paste("Date range:", start_date, "to", end_date))
  }
  
  # Execute the export
  result <- export_amazon_sales_data(start_date, end_date, export_path, verbose = verbose)
  
  if(is.character(result)) {
    if(verbose) message("N01_P01_00 executed successfully!")
    return(result)
  } else {
    if(verbose) message("N01_P01_00 execution failed.")
    return(FALSE)
  }
}

# Execute the node if running the script directly
if(!interactive()) {
  execute_N01_P01_00()
}