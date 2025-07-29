#' Process Review Ratings
#'
#' Processes the review ratings obtained from OpenAI API and transforms them into
#' usable property ratings by product line. This is part of D03_08 (Process Reviews) step.
#'
#' @param raw_data A DBI connection to the raw data database.
#' @param processed_data A DBI connection to the processed data database.
#' @param comment_property_rating A DBI connection to the comment property rating database.
#' @param comment_property_rating_results A DBI connection to the comment property rating results database.
#' @param vec_product_line_id_noall A vector of product line IDs to process (excluding "all").
#'
#' @return Invisible NULL. The function writes the processed data to database tables.
#'
#' @examples
#' \dontrun{
#' # Connect to databases
#' dbConnect_from_list("raw_data", read_only = TRUE)
#' dbConnect_from_list("processed_data", read_only = FALSE)
#' dbConnect_from_list("comment_property_rating", read_only = FALSE)
#' dbConnect_from_list("comment_property_rating_results", read_only = FALSE)
#' 
#' # Process review ratings
#' process_review_ratings(
#'   raw_data = raw_data,
#'   processed_data = processed_data,
#'   comment_property_rating = comment_property_rating,
#'   comment_property_rating_results = comment_property_rating_results,
#'   vec_product_line_id_noall = vec_product_line_id_noall
#' )
#' }
#'
#' @export
process_review_ratings <- function(raw_data,
                                  processed_data,
                                  comment_property_rating,
                                  comment_property_rating_results,
                                  vec_product_line_id_noall) {
  
  # Required packages
  if (!requireNamespace("dplyr", quietly = TRUE)) library(dplyr)
  if (!requireNamespace("tidyr", quietly = TRUE)) library(tidyr)
  if (!requireNamespace("DBI", quietly = TRUE)) library(DBI)
  
  # Source the decode_rating function
  source(file.path("update_scripts", "global_scripts", "08_ai", "fn_decode_rating.R"))
  
  # Process each product line
  for (product_line_id_i in vec_product_line_id_noall) {
    # Log processing
    message("Processing ratings for product line: ", product_line_id_i)
    
    # Define table names
    source_table_name <- paste0("df_comment_property_rating_", product_line_id_i, "___append_long")
    target_table_name <- paste0("df_comment_property_ratingonly_", product_line_id_i)
    
    # Check if source table exists
    if (!DBI::dbExistsTable(comment_property_rating_results, source_table_name)) {
      warning("Source table not found: ", source_table_name, ". Skipping product line ", product_line_id_i)
      next
    }
    
    # Process the ratings
    tryCatch({
      # Read the data
      ratings_data <- dplyr::tbl(comment_property_rating_results, source_table_name) %>% 
        dplyr::collect()
      
      message("Processing ", nrow(ratings_data), " rating records for product line ", product_line_id_i)
      
      # Get comment property columns to exclude (keep only product_line_id and property_name)
      excluded_cols <- dplyr::tbl(raw_data, "df_all_comment_property") %>% 
        colnames() %>%
        setdiff(c("product_line_id", "property_name"))
      
      # Define system columns to exclude
      system_cols <- c(
        "buyer_rating_score", 
        "fb_buyer_rating_score", 
        "fb_item_id", 
        "createdAt", 
        "updatedAt",
        "deletedAt",
        "insertDate",
        "timestamp",
        "id"
      )
      
      # Process the data
      processed_data_df <- ratings_data %>% 
        # Decode the rating values
        dplyr::mutate(result = decode_rating(result)) %>% 
        # Remove unnecessary columns
        dplyr::select(-dplyr::any_of(excluded_cols)) %>%
        dplyr::select(-dplyr::any_of(dplyr::starts_with("include"))) %>% 
        # Remove system columns
        dplyr::select(-dplyr::any_of(system_cols)) %>%
        # Keep one record per review per property
        dplyr::distinct(dplyr::across(-result), .keep_all = TRUE) %>% 
        # Pivot to wide format with properties as columns
        tidyr::pivot_wider(
          names_from = property_name,
          values_from = result,
          values_fn = list(result = first),  # If multiple values, take first
          values_fill = NA_integer_
        )
      
      # Write to database
      DBI::dbWriteTable(
        processed_data,
        target_table_name,
        processed_data_df,
        append = FALSE,
        overwrite = TRUE
      )
      
      message("Successfully created table: ", target_table_name, " with ", nrow(processed_data_df), " rows")
      
    }, error = function(e) {
      warning("Error processing ratings for product line ", product_line_id_i, ": ", e$message)
    })
  }
  
  # Return invisibly
  invisible(NULL)
}