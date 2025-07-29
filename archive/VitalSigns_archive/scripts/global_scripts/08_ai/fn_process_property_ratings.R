#' Process Property Ratings for Multiple Product Lines
#'
#' Processes review property ratings for multiple product lines as part of D03_07 (Rate Reviews) step.
#' Creates tables, processes sampled data, and performs AI rating of reviews.
#'
#' @param comment_property_rating A DBI connection to the comment property rating database
#' @param comment_property_rating_results A DBI connection to the comment property rating results database
#' @param vec_product_line_id_noall A vector of product line IDs to process (excluding "all")
#' @param chunk_size Integer. Number of records to process in each batch (default: 20)
#' @param workers Integer. Number of parallel workers to use (default: 4)
#' @param gpt_key Character. OpenAI API key.
#' @param model Character. The model to use (default: "o4-mini").
#' @param title Character. Column name for title/comment field (default: "title")
#' @param body Character. Column name for body/content field (default: "body")
#' @param platform Character. Platform identifier ("amz" or "eby") (default: "amz")
#'
#' @return Invisible NULL. The function creates database tables as a side effect.
#'
#' @examples
#' \dontrun{
#' # Connect to databases
#' dbConnect_from_list("comment_property_rating", read_only = FALSE)
#' dbConnect_from_list("comment_property_rating_results", read_only = FALSE)
#' 
#' # Process property ratings
#' process_property_ratings(
#'   comment_property_rating = comment_property_rating,
#'   comment_property_rating_results = comment_property_rating_results,
#'   vec_product_line_id_noall = vec_product_line_id_noall,
#'   chunk_size = 20,
#'   workers = 8,
#'   gpt_key = Sys.getenv("OPENAI_API_KEY"),
#'   model = "o4-mini",
#'   title = "title",
#'   body = "body"
#' )
#' 
#' # For eBay data where comment is in fb_comment field
#' process_property_ratings(
#'   comment_property_rating = comment_property_rating,
#'   comment_property_rating_results = comment_property_rating_results,
#'   vec_product_line_id_noall = vec_product_line_id_noall,
#'   gpt_key = gpt_key,
#'   title = "fb_comment",
#'   body = "fb_comment",  # Use same column for both if only one text field
#'   platform = "eby"
#' )
#' }
#'
#' @export
process_property_ratings <- function(comment_property_rating,
                                    comment_property_rating_results,
                                    vec_product_line_id_noall,
                                    chunk_size = 20,
                                    workers = 4,
                                    gpt_key,
                                    model = "o4-mini",
                                    title = "title",
                                    body = "body",
                                    platform = "amz") {
  
  # Required packages
  if (!requireNamespace("dplyr", quietly = TRUE)) library(dplyr)
  if (!requireNamespace("furrr", quietly = TRUE)) library(furrr)
  if (!requireNamespace("future", quietly = TRUE)) library(future)
  if (!requireNamespace("purrr", quietly = TRUE)) library(purrr)
  if (!requireNamespace("cli", quietly = TRUE)) library(cli)
  
  # Source the rating function
  source_path <- file.path("update_scripts", "global_scripts", "08_ai", "fn_rate_comments.R")
  source(source_path)
  
  # Set up parallel processing
  cores <- parallel::detectCores()
  actual_workers <- min(workers, cores - 1)
  future::plan(future::multisession, workers = actual_workers)
  cli::cli_alert_info("Using {actual_workers} workers for parallel processing")
  
  # Process each product line
  for (product_line_id in vec_product_line_id_noall) {
    
    # Log processing status
    cli::cli_h2("Processing product line: {product_line_id}")
    
    # Define table names
    sampled_table_name <- paste0("df_comment_property_rating_", product_line_id, "___sampled_long")
    append_table_name <- paste0("df_comment_property_rating_", product_line_id, "___append_long")
    
    # Copy sampled data to results database
    cli::cli_alert_info("Copying sampled data to results database")
    dbCopyTable(
      comment_property_rating, 
      comment_property_rating_results, 
      sampled_table_name, 
      overwrite = TRUE
    )
    
    # Get sampled table
    sampled_tbl <- dplyr::tbl(comment_property_rating_results, sampled_table_name)
    
    # Create append table with proper structure if it doesn't exist
    if (!DBI::dbExistsTable(comment_property_rating_results, append_table_name)) {
      cli::cli_alert_info("Creating append table: {append_table_name}")
      dplyr::tbl(comment_property_rating_results, sampled_table_name) %>% 
        dplyr::filter(FALSE) %>%
        dplyr::mutate(gpt_model = sql("CAST(NULL AS VARCHAR)")) %>%
        dplyr::compute(
          name = append_table_name,
          temporary = FALSE,
          overwrite = FALSE
        )
    }
    
    # Get already processed data
    done_tbl <- dplyr::tbl(comment_property_rating_results, append_table_name)
    
    # Define key columns that uniquely identify a record
    # Get item column name based on platform
    item_col <- switch(platform,
      "amz" = "asin",
      "eby" = "ebay_item_number",
      # Default fallback
      stop(paste("Unknown platform:", platform))
    )
    
    # Build key columns list
    key_cols <- c(item_col, "property_id")
    
    # Add title column if it exists and is not NA
    if (!is.null(title) && !is.na(title) && title %in% colnames(sampled_tbl)) {
      key_cols <- c(key_cols, title)
    }
    
    # Add body column if it exists, is not NA, and is different from title
    if (!is.null(body) && !is.na(body) && body %in% colnames(sampled_tbl)) {
      # Only add if different from title (or title is NA/NULL)
      if (is.null(title) || is.na(title) || body != title) {
        key_cols <- c(key_cols, body)
      }
    }
    
    # Verify all key columns exist
    missing_cols <- setdiff(key_cols, colnames(sampled_tbl))
    if (length(missing_cols) > 0) {
      cli::cli_alert_warning("Missing key columns: {paste(missing_cols, collapse = ', ')}")
      key_cols <- intersect(key_cols, colnames(sampled_tbl))
    }
    
    cols <- key_cols
    
    cli::cli_alert_info("Join columns: {paste(cols, collapse = ', ')}")
    
    # Get counts before processing
    initial_count <- DBI::dbGetQuery(
      comment_property_rating_results,
      glue::glue("SELECT COUNT(*) FROM {append_table_name}")
    )[1, 1]
    
    # Get total sampled count
    total_sampled <- sampled_tbl %>% dplyr::count() %>% dplyr::pull(n)
    cli::cli_alert_info("Total records in sampled table: {total_sampled}")
    cli::cli_alert_info("Already processed records in append table: {initial_count}")
    
    # Find records that need processing
    todo <- sampled_tbl %>% 
      dplyr::anti_join(done_tbl, by = cols) %>%
      dplyr::collect()
    
    # Skip if no records need processing
    if (nrow(todo) == 0) {
      cli::cli_alert_success("No new records to process for product line {product_line_id} (Total existing: {initial_count})")
      next
    }
    
    # Log processing information
    cli::cli_alert_info("Processing {nrow(todo)} new records for product line {product_line_id} (Already processed: {initial_count})")
    
    # Split into chunks for batch processing
    todo_chunks <- split(todo, (seq_len(nrow(todo)) - 1) %/% chunk_size)
    total_chunks <- length(todo_chunks)
    
    # Process each chunk
    for (i in seq_along(todo_chunks)) {
      chunk <- todo_chunks[[i]]
      cli::cli_alert_info("Processing chunk {i}/{total_chunks} ({nrow(chunk)} records)")
      
      # Process batch with parallel computation
      # Get title and body vectors using the specified column names
      title_vec <- if (!is.null(title) && !is.na(title) && title %in% names(chunk)) {
        chunk[[title]]
      } else {
        rep(NA_character_, nrow(chunk))
      }
      
      body_vec <- if (!is.null(body) && !is.na(body) && body %in% names(chunk)) {
        chunk[[body]]
      } else {
        rep(NA_character_, nrow(chunk))
      }
      
      processed_batch <- chunk %>%
        dplyr::mutate(
          result = furrr::future_pmap_chr(
            list(title_vec,
                 body_vec,
                 property_name_english,
                 property_name,
                 type),
            rate_comments,
            gpt_key = gpt_key,
            model = model,
            .options = furrr::furrr_options(seed = TRUE)
          ),
          gpt_model = model
        )
      
      # Write results to database
      DBI::dbAppendTable(comment_property_rating_results, append_table_name, processed_batch)
      cli::cli_alert_success("{Sys.time()} - Wrote {nrow(processed_batch)} records to database")
    }
    
    # Get final count and calculate newly processed
    final_count <- DBI::dbGetQuery(
      comment_property_rating_results,
      glue::glue("SELECT COUNT(*) FROM {append_table_name}")
    )[1, 1]
    
    newly_processed <- final_count - initial_count
    
    cli::cli_alert_success("Completed processing for product line {product_line_id}")
    cli::cli_alert_info("  Newly processed: {newly_processed} records")
    cli::cli_alert_info("  Total in database: {final_count} records")
  }
  
  # Return invisibly
  invisible(NULL)
}