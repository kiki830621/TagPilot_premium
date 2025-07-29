#' Process Property Ratings for Multiple Product Lines
#'
#' Processes review property ratings for multiple product lines as part of D03_07 (Rate Reviews) step.
#' Creates tables, processes sampled data, and performs AI rating of reviews.
#' Timestamps are stored as TIMESTAMP WITH TIME ZONE to preserve timezone information.
#' 
#' The function includes robust connection error handling:
#' - Tests OpenAI API connectivity before processing
#' - Stops immediately on connection errors (network, timeout, SSL, etc.)
#' - Monitors database connection health during writes
#' - Provides clear error messages for debugging
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
#' @param input_database Character. Source database option: "results" (copy to results first) or "source" (read directly from comment_property_rating)
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
                                    platform = "amz",
                                    input_database = "results") {
  
  # Required packages
  if (!requireNamespace("dplyr", quietly = TRUE)) library(dplyr)
  if (!requireNamespace("furrr", quietly = TRUE)) library(furrr)
  if (!requireNamespace("future", quietly = TRUE)) library(future)
  if (!requireNamespace("purrr", quietly = TRUE)) library(purrr)
  if (!requireNamespace("cli", quietly = TRUE)) library(cli)
  if (!requireNamespace("lubridate", quietly = TRUE)) library(lubridate)
  if (!requireNamespace("httr", quietly = TRUE)) library(httr)
  
  
  # Test API connection before starting
  cli::cli_alert_info("Testing OpenAI API connection...")
  tryCatch({
    # Simple test call to verify API connectivity
    test_response <- httr::GET(
      "https://api.openai.com/v1/models",
      httr::add_headers(Authorization = paste0("Bearer ", gpt_key))
    )
    if (httr::status_code(test_response) != 200) {
      stop("OpenAI API connection failed. Status code: ", httr::status_code(test_response))
    }
    cli::cli_alert_success("OpenAI API connection verified")
  }, error = function(e) {
    cli::cli_alert_danger("Failed to connect to OpenAI API: {e$message}")
    stop("OpenAI API connection test failed: ", e$message, call. = FALSE)
  })

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
    
    # Determine input database
    if (input_database == "source") {
      cli::cli_alert_info("Reading data directly from source database")
      # Read directly from comment_property_rating database
      sampled_tbl <- dplyr::tbl(comment_property_rating, sampled_table_name)
    } else {
      # Original behavior: copy to results database
      cli::cli_alert_info("Copying sampled data to results database")
      dbCopyTable(
        comment_property_rating, 
        comment_property_rating_results, 
        sampled_table_name, 
        overwrite = TRUE
      )
      
      # Get sampled table
      sampled_tbl <- dplyr::tbl(comment_property_rating_results, sampled_table_name)
    }
    
    # Create append table with proper structure if it doesn't exist
    if (!DBI::dbExistsTable(comment_property_rating_results, append_table_name)) {
      cli::cli_alert_info("Creating append table: {append_table_name}")
      sampled_tbl %>% 
        dplyr::filter(FALSE) %>%
        dplyr::mutate(
          ai_rating_result = sql("CAST(NULL AS VARCHAR)"),
          ai_rating_gpt_model = sql("CAST(NULL AS VARCHAR)"),
          ai_rating_timestamp = sql("CAST(NULL AS TIMESTAMP WITH TIME ZONE)")
        ) %>%
        dplyr::select(
          product_line_id,
          product_id,
          reviewer_id,
          review_date,
          review_title,
          review_body,
          property_name,
          ai_rating_result,
          ai_rating_gpt_model,
          ai_rating_timestamp
        ) %>%
        dplyr::compute(
          name = append_table_name,
          temporary = FALSE,
          overwrite = FALSE
        )
    }
    
    # Get already processed data
    done_tbl <- dplyr::tbl(comment_property_rating_results, append_table_name)
    
    # Define key columns that uniquely identify a record
    # Use standardized field names for identifying unique records
    key_cols <- c("product_id", "reviewer_id", "property_name")
    
    # Verify all key columns exist
    sampled_cols <- colnames(sampled_tbl)
    missing_cols <- setdiff(key_cols, sampled_cols)
    if (length(missing_cols) > 0) {
      cli::cli_alert_warning("Missing key columns: {paste(missing_cols, collapse = ', ')}")
      key_cols <- intersect(key_cols, sampled_cols)
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
    # First collect both tables to avoid cross-database join issues
    sampled_data <- sampled_tbl %>% dplyr::collect()
    done_data <- done_tbl %>% dplyr::collect()
    
    # Perform anti-join in memory
    todo <- sampled_data %>% 
      dplyr::anti_join(done_data, by = cols)
    
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
      
      # Wrap entire chunk processing in a transaction for atomicity
      chunk_success <- FALSE
      tryCatch({
        # Start transaction for the entire chunk
        DBI::dbBegin(comment_property_rating_results)
        
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
        
        # Record start time for this chunk (with timezone)
        chunk_start_time <- Sys.time()
        
        # Process AI rating with connection error handling
        processed_batch <- tryCatch({
        chunk %>%
          dplyr::mutate(
            ai_rating_result = furrr::future_pmap_chr(
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
            ai_rating_gpt_model = model,
            # Use a more accurate timestamp with timezone - add a small offset for each record
            ai_rating_timestamp = chunk_start_time + lubridate::seconds(seq_len(nrow(chunk)) - 1)
          )
      }, error = function(e) {
        # Check if it's a connection error
        error_msg <- as.character(e$message)
        if (grepl("connection|network|timeout|curl|ssl|tls|socket", error_msg, ignore.case = TRUE)) {
          cli::cli_alert_danger("Connection error detected: {error_msg}")
          cli::cli_alert_danger("Stopping processing due to connection failure")
          stop("Connection error in AI rating process: ", error_msg, call. = FALSE)
        } else {
          cli::cli_alert_warning("Non-connection error in AI rating: {error_msg}")
          cli::cli_alert_warning("Continuing with error handling...")
          # Re-throw the error to let normal error handling proceed
          stop(e)
        }
      })
      
        # Check for connection errors and filter them out before saving
        # Note: "NaN,NaN" is NOT included as it represents valid "Not Applicable" ratings
        error_patterns <- c("Connection_error", "connectionerror", "HTTP_", "API_error", "Unknown_format", "No_comment_text")
        error_indices <- which(grepl(paste(error_patterns, collapse = "|"), 
                                   processed_batch$ai_rating_result, 
                                   ignore.case = TRUE))
        
        if (length(error_indices) > 0) {
          cli::cli_alert_warning(
            "Detected {length(error_indices)} error(s) in AI rating results - filtering out before saving"
          )
          
          # Log the error types for debugging
          error_results <- processed_batch$ai_rating_result[error_indices]
          error_summary <- table(error_results)
          cli::cli_alert_info("Error types found:")
          for (i in seq_along(error_summary)) {
            cli::cli_alert_info("  {names(error_summary)[i]}: {error_summary[i]} records")
          }
          
          # Filter out error records
          processed_batch <- processed_batch[-error_indices, ]
          cli::cli_alert_info("Filtered batch size: {nrow(processed_batch)} records (removed {length(error_indices)} errors)")
        }
        
        # Continue with the rest of the processing
        processed_batch <- processed_batch %>%
          dplyr::select(
            product_line_id,
            product_id,
            reviewer_id,
            review_date,
            review_title,
            review_body,
            property_name,
            ai_rating_result,
            ai_rating_gpt_model,
            ai_rating_timestamp
          )
      
        # Write results to database only if there are valid records (within transaction)
        if (nrow(processed_batch) > 0) {
          DBI::dbAppendTable(comment_property_rating_results, 
                             append_table_name, processed_batch)
          cli::cli_alert_success("Wrote {nrow(processed_batch)} valid records to database")
        } else {
          cli::cli_alert_warning("No valid records to write to database (all were errors)")
        }
        
        # Commit transaction - all operations successful
        DBI::dbCommit(comment_property_rating_results)
        chunk_success <- TRUE
        
        if (nrow(processed_batch) > 0) {
          cli::cli_alert_success(
            "{Sys.time()} - Successfully processed chunk {i}"
          )
        } else {
          cli::cli_alert_warning(
            "{Sys.time()} - Chunk {i} contained only errors, no records saved"
          )
        }
        
      }, error = function(e) {
        # Rollback transaction on any error
        tryCatch({
          DBI::dbRollback(comment_property_rating_results)
          cli::cli_alert_warning("Transaction rolled back for chunk {i}")
        }, error = function(rollback_error) {
          cli::cli_alert_danger(
            "Failed to rollback transaction: {rollback_error$message}"
          )
        })
        
        error_msg <- as.character(e$message)
        if (grepl("connection|network|timeout|database|lock|curl|ssl|tls|socket", 
                  error_msg, ignore.case = TRUE)) {
          cli::cli_alert_danger("Connection error in chunk {i}: {error_msg}")
          cli::cli_alert_danger("Stopping processing due to connection failure")
          stop("Connection error: ", error_msg, call. = FALSE)
        } else {
          cli::cli_alert_warning("Error in chunk {i}: {error_msg}")
          cli::cli_alert_warning("Skipping chunk {i} due to error")
          # Continue to next chunk instead of stopping
        }
      })
      
      # Only display results if chunk was successful
      if (!chunk_success) {
        cli::cli_alert_warning("Skipping result display for failed chunk {i}")
        next  # Skip to next chunk
      }
      
      # Display first few records of the processed batch
      if (nrow(processed_batch) > 0) {
        cli::cli_h3("Sample of processed results:")
        sample_records <- head(processed_batch, 3)
        for (j in seq_len(nrow(sample_records))) {
          record <- sample_records[j, ]
          # Format timestamp for display with timezone info
          record_time <- format(record$ai_rating_timestamp, "%H:%M:%S %Z")
          cli::cli_alert_info(
            "Record {j}: {record$product_id} | {record$property_name} | {record$ai_rating_result} | {record_time}"
          )
        }
      }
    }
    
    # Get final count and calculate newly processed
    final_count <- DBI::dbGetQuery(
      comment_property_rating_results,
      glue::glue("SELECT COUNT(*) FROM {append_table_name}")
    )[1, 1]
    
    records_added <- final_count - initial_count
    
    cli::cli_alert_success(
      "Completed processing for product line {product_line_id}"
    )
    cli::cli_alert_info("  Newly processed: {records_added} records")
    cli::cli_alert_info("  Total in database: {final_count} records")
  }
  
  # Return invisibly
  invisible(NULL)
}