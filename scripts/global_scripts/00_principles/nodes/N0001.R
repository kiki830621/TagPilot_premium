# N0001.R
# Data Export Utility Node
#
# This script implements a platform-agnostic utility for exporting data
# to various formats (CSV, Excel, JSON).
#
# Node utilities are designed to be atomic, reusable components that can be
# leveraged by multiple derivations and sequences.

#' Export data to CSV format
#'
#' @param data Data frame to export
#' @param export_path Path to save the exported file
#' @param include_headers Logical, whether to include headers in export
#' @param date_format Format string for date columns
#' @param verbose Logical, whether to print progress messages
#'
#' @return Path to the exported file if successful, otherwise FALSE
#'
export_data_to_csv <- function(data, export_path, include_headers = TRUE, 
                              date_format = "%Y-%m-%d", verbose = TRUE) {
  if(verbose) message("Exporting data to CSV...")
  
  tryCatch({
    # Process date columns
    date_cols <- sapply(data, function(x) inherits(x, "Date") || inherits(x, "POSIXt"))
    if(any(date_cols)) {
      for(col in names(data)[date_cols]) {
        data[[col]] <- format(data[[col]], format = date_format)
      }
    }
    
    # Create directory if it doesn't exist
    dir.create(dirname(export_path), recursive = TRUE, showWarnings = FALSE)
    
    # Write to file
    if(include_headers) {
      write.csv(data, export_path, row.names = FALSE, quote = TRUE)
    } else {
      write.table(data, export_path, sep = ",", row.names = FALSE, 
                 col.names = FALSE, quote = TRUE)
    }
    
    if(verbose) message(paste0("Export complete: ", nrow(data), " records written to ", export_path))
    
    return(export_path)
  }, error = function(e) {
    message("Error exporting data to CSV: ", e$message)
    return(FALSE)
  })
}

#' Export data to Excel format
#'
#' @param data Data frame to export
#' @param export_path Path to save the exported file
#' @param sheet_name Name of the worksheet
#' @param verbose Logical, whether to print progress messages
#'
#' @return Path to the exported file if successful, otherwise FALSE
#'
export_data_to_excel <- function(data, export_path, sheet_name = "Data", verbose = TRUE) {
  if(verbose) message("Exporting data to Excel...")
  
  tryCatch({
    # Check if openxlsx package is available
    if(!requireNamespace("openxlsx", quietly = TRUE)) {
      stop("Package 'openxlsx' needed for Excel export. Please install it.")
    }
    
    # Create directory if it doesn't exist
    dir.create(dirname(export_path), recursive = TRUE, showWarnings = FALSE)
    
    # Create workbook and add data
    wb <- openxlsx::createWorkbook()
    openxlsx::addWorksheet(wb, sheet_name)
    openxlsx::writeData(wb, sheet_name, data)
    
    # Apply formatting to date columns
    date_cols <- sapply(data, function(x) inherits(x, "Date") || inherits(x, "POSIXt"))
    if(any(date_cols)) {
      date_style <- openxlsx::createStyle(numFmt = "yyyy-mm-dd")
      col_indices <- which(date_cols)
      for(col in col_indices) {
        openxlsx::addStyle(wb, sheet_name, date_style, rows = 2:(nrow(data)+1), cols = col)
      }
    }
    
    # Save workbook
    openxlsx::saveWorkbook(wb, export_path, overwrite = TRUE)
    
    if(verbose) message(paste0("Export complete: ", nrow(data), " records written to ", export_path))
    
    return(export_path)
  }, error = function(e) {
    message("Error exporting data to Excel: ", e$message)
    return(FALSE)
  })
}

#' Export data to JSON format
#'
#' @param data Data frame to export
#' @param export_path Path to save the exported file
#' @param pretty Logical, whether to format JSON with indentation
#' @param verbose Logical, whether to print progress messages
#'
#' @return Path to the exported file if successful, otherwise FALSE
#'
export_data_to_json <- function(data, export_path, pretty = TRUE, verbose = TRUE) {
  if(verbose) message("Exporting data to JSON...")
  
  tryCatch({
    # Check if jsonlite package is available
    if(!requireNamespace("jsonlite", quietly = TRUE)) {
      stop("Package 'jsonlite' needed for JSON export. Please install it.")
    }
    
    # Create directory if it doesn't exist
    dir.create(dirname(export_path), recursive = TRUE, showWarnings = FALSE)
    
    # Process date columns
    date_cols <- sapply(data, function(x) inherits(x, "Date") || inherits(x, "POSIXt"))
    if(any(date_cols)) {
      for(col in names(data)[date_cols]) {
        data[[col]] <- format(data[[col]])
      }
    }
    
    # Convert to JSON and write to file
    json_data <- jsonlite::toJSON(data, pretty = pretty, auto_unbox = TRUE)
    writeLines(json_data, export_path)
    
    if(verbose) message(paste0("Export complete: ", nrow(data), " records written to ", export_path))
    
    return(export_path)
  }, error = function(e) {
    message("Error exporting data to JSON: ", e$message)
    return(FALSE)
  })
}

#' Export query results to a file
#'
#' @param conn DBI connection object
#' @param query SQL query string to execute
#' @param export_path Path to save the exported file
#' @param format Export format ("csv", "excel", or "json")
#' @param verbose Logical, whether to print progress messages
#'
#' @return Path to the exported file if successful, otherwise FALSE
#'
export_query_results <- function(conn, query, export_path, format = "csv", verbose = TRUE) {
  if(verbose) message("Executing query and exporting results...")
  
  tryCatch({
    # Execute query
    data <- DBI::dbGetQuery(conn, query)
    
    if(nrow(data) == 0) {
      warning("Query returned no results")
      return(FALSE)
    }
    
    # Export based on format
    if(format == "csv") {
      return(export_data_to_csv(data, export_path, verbose = verbose))
    } else if(format == "excel") {
      return(export_data_to_excel(data, export_path, verbose = verbose))
    } else if(format == "json") {
      return(export_data_to_json(data, export_path, verbose = verbose))
    } else {
      stop("Unsupported export format: ", format)
    }
  }, error = function(e) {
    message("Error exporting query results: ", e$message)
    return(FALSE)
  })
}