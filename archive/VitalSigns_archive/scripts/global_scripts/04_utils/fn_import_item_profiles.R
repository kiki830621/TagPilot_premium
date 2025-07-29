#' Import Item Profiles from Google Sheets to Raw Data
#'
#' This function imports item profile data for active product lines
#' from a Google Sheet to the raw_data database. It supports the D03_00 step of the
#' Positioning Analysis derivation flow.
#'
#' @param db_connection A DBI connection to the database where data will be written
#' @param product_line_df A dataframe containing product line information (default: df_product_line)
#' @param google_sheet_id The ID of the Google Sheet containing item profile data (required)
#' @param sheet_name_prefix Prefix for sheet names (default: "item_profile"), will add "_" automatically
#'
#' @return A list of imported data frames, named by product line ID
#'
#' @examples
#' \dontrun{
#' # Connect to database
#' dbConnect_from_list("raw_data")
#' 
#' # Import item profiles for all active product lines
#' import_item_profiles(
#'   db_connection = raw_data,
#'   product_line_df = df_product_line,
#'   google_sheet_id = "16-k48xxFzSZm2p8j9SZf4V041fldcYnR8ectjsjuxZQ"
#' )
#' }
#'
#' @export
import_item_profiles <- function(db_connection = raw_data,
                               product_line_df = df_product_line,
                               google_sheet_id = NULL,
                               sheet_name_prefix = "item_profile") {
  
  # Validate parameters
  if (is.null(google_sheet_id)) {
    stop("google_sheet_id is required")
  }
  
  # Make sure required packages are loaded
  if (!requireNamespace("googlesheets4", quietly = TRUE)) {
    message("Loading package 'googlesheets4'")
    library(googlesheets4)
  }
  if (!requireNamespace("janitor", quietly = TRUE)) {
    message("Loading package 'janitor'")
    library(janitor)
  }
  
  # Ensure sheet_name_prefix ends with an underscore
  if (!endsWith(sheet_name_prefix, "_")) {
    sheet_name_prefix <- paste0(sheet_name_prefix, "_")
  }
  
  # Connect to the Google Sheet
  googlesheet_con <- googlesheets4::as_sheets_id(google_sheet_id)
  
  # Initialize results list
  results <- list()
  
  # Filter active product lines (exclude 'all')
  product_lines <- product_line_df %>%
    dplyr::filter(included == TRUE, product_line_id != "all") %>%
    dplyr::select(id = product_line_id, name = product_line_name_chinese)
  
  # Process each product line
  for (i in 1:nrow(product_lines)) {
    product_line_id <- product_lines$id[i]
    product_line_name <- product_lines$name[i]
    
    # Construct full sheet name - default is now "item_profile_[product_line_name]"
    sheet_name <- paste0(sheet_name_prefix, product_line_name)
    
    # Import data from Google Sheet
    tryCatch({
      message(paste("Importing data for product line:", product_line_name, "from sheet:", sheet_name))
      
      # Read and clean data
      df_item_profile <- googlesheets4::read_sheet(googlesheet_con, sheet = sheet_name) %>%
        janitor::clean_names(ascii = FALSE) %>%
        dplyr::mutate(dplyr::across(where(is.list), as.character))
      
      # Add product line information
      df_item_profile <- df_item_profile %>%
        dplyr::mutate(
          product_line_name = product_line_name,
          product_line_id = product_line_id
        )
      
      # Create table name
      table_name <- paste0("df_all_item_profile_", product_line_id)
      
      # Write to database
      DBI::dbWriteTable(db_connection, table_name, df_item_profile, overwrite = TRUE)
      
      # Store in results
      results[[product_line_id]] <- df_item_profile
      
      # Log success
      message(paste("Successfully imported", nrow(df_item_profile), "items for product line:", product_line_name))
      
    }, error = function(e) {
      warning(paste("Error importing data for product line", product_line_name, ":", e$message))
    })
  }
  
  return(results)
}
