#' Import Competitor Item IDs from Google Sheets
#'
#' This function imports competitor item data from a Google Sheet and transforms it
#' into a standardized format with product_line_id, brand, and asin columns.
#' It supports the D03_01 step of the Positioning Analysis derivation flow.
#'
#' @param db_connection A DBI connection to the database where data will be written
#' @param google_sheet_id The ID of the Google Sheet containing competitor items or
#'        a Google Sheets URL that can be converted to an ID
#' @param sheet_name The name of the sheet containing competitor data (default: "競爭者")
#' @param product_line_df A dataframe containing product line information (default: df_product_line)
#' @param skip Number of rows to skip when reading the sheet (default: 0). Useful when 
#'        data starts from row n+1 due to additional header rows or metadata.
#' @param column_names Character vector of column base names to extract for each product line.
#'        Default is c("brand", "asin"). For eBay, use c("seller", "brand", "ebay_item_number", "country").
#'        The function will look for columns named as "columnname_productline" (e.g., "brand_電開罐器").
#' @param brand_imputed Character string specifying which column to use when brand is "UNKNOWN" (default: NULL).
#'        For example, set to "seller" to use seller name as brand when brand is unknown.
#' @param platform Character string specifying the platform (default: NULL). When specified, the table name
#'        will be "df_{platform}_competitor_item_id" (e.g., "df_eby_competitor_item_id" for eBay).
#'        If NULL, uses the default table name "df_competitor_item_id".
#' @param item_id Character string specifying which column to use as the item identifier (default: "asin").
#'        For eBay, use "ebay_item_number". This column will be checked for duplicates.
#'
#' @return A data frame of competitor items with product_line_id and the specified columns
#'
#' @examples
#' \dontrun{
#' # Connect to database
#' dbConnect_from_list("raw_data")
#' 
#' # Import competitor items using app_configs
#' import_competitor_items(
#'   db_connection = raw_data,
#'   google_sheet_id = app_configs$googlesheet$item_profile
#' )
#' 
#' # Or using a direct sheet ID with skipping first 2 rows
#' import_competitor_items(
#'   db_connection = raw_data,
#'   google_sheet_id = "16-k48xxFzSZm2p8j9SZf4V041fldcYnR8ectjsjuxZQ",
#'   skip = 2
#' )
#' 
#' # For eBay data with custom columns
#' import_competitor_items(
#'   db_connection = raw_data,
#'   google_sheet_id = "your-ebay-sheet-id",
#'   column_names = c("seller", "brand", "ebay_item_number", "country")
#' )
#' 
#' # For eBay data with brand imputation from seller
#' import_competitor_items(
#'   db_connection = raw_data,
#'   google_sheet_id = "your-ebay-sheet-id",
#'   column_names = c("seller", "brand", "ebay_item_number", "country"),
#'   brand_imputed = "seller",  # Use seller as brand when brand is "UNKNOWN"
#'   platform = "eby",  # Creates table df_eby_competitor_item_id
#'   item_id = "ebay_item_number"  # Check duplicates on eBay item number
#' )
#' }
#'
#' @export
import_competitor_items <- function(db_connection = raw_data,
                                   google_sheet_id = NULL,
                                   sheet_name = "競爭者",
                                   product_line_df = df_product_line,
                                   skip = 0,
                                   column_names = c("brand", "asin"),
                                   brand_imputed = NULL,
                                   platform = NULL,
                                   item_id = "asin") {
  
  # Validate parameters
  if (is.null(google_sheet_id)) {
    stop("google_sheet_id is required")
  }
  
  # Make sure required packages are loaded
  if (!requireNamespace("googlesheets4", quietly = TRUE)) {
    message("Loading package 'googlesheets4'")
    library(googlesheets4)
  }
  
  # =====================================================================
  # STEP 1: Pre-import Analysis - Check for Duplicates in Google Sheet
  # =====================================================================
  message("\n", paste(rep("=", 70), collapse = ""))
  message("🔍 STEP 1: Pre-import Analysis - Checking for Duplicates")
  message(paste(rep("=", 70), collapse = ""))
  
  # Read competitor data from Google Sheet
  message(paste("📊 Reading competitor data from sheet:", sheet_name))
  if (skip > 0) {
    message(paste("⏭️  Skipping first", skip, "rows"))
  }
  df_competitor_items <- googlesheets4::as_sheets_id(google_sheet_id) %>% 
    googlesheets4::read_sheet(sheet = sheet_name, skip = skip, col_types = "c")
  
  message(paste("📋 Raw Google Sheet data loaded:", nrow(df_competitor_items), "rows"))
  
  # Filter active product lines (exclude 'all')
  active_product_lines <- product_line_df %>%
    dplyr::filter(included == TRUE, product_line_id != "all")
  
  # =====================================================================
  # Pre-analysis: Check for duplicates BEFORE processing
  # =====================================================================
  message(paste("🎯 Analyzing", length(active_product_lines$product_line_id), "active product lines for duplicate", item_id, "values..."))
  
  # Collect all item_id columns and their corresponding product lines
  all_items_pre_analysis <- data.frame()
  
  for (i in 1:nrow(active_product_lines)) {
    product_line_name <- active_product_lines$product_line_name_chinese[i]
    product_line_id <- active_product_lines$product_line_id[i]
    
    # Look for item_id column for this product line
    item_col_name <- paste_(item_id, product_line_name)
    
    if (item_col_name %in% names(df_competitor_items)) {
      # Extract non-empty values
      item_values <- df_competitor_items[[item_col_name]]
      item_values <- item_values[!is.na(item_values) & item_values != ""]
      
      if (length(item_values) > 0) {
        temp_df <- data.frame(
          item_value = item_values,
          product_line_id = product_line_id,
          product_line_name = product_line_name,
          stringsAsFactors = FALSE
        )
        names(temp_df)[1] <- item_id  # Rename to actual item_id name
        all_items_pre_analysis <- rbind(all_items_pre_analysis, temp_df)
      }
    }
  }
  
  # Check for duplicates BEFORE import
  has_pre_duplicates <- FALSE
  if (nrow(all_items_pre_analysis) > 0) {
    duplicate_analysis <- all_items_pre_analysis %>%
      dplyr::group_by(!!rlang::sym(item_id)) %>%
      dplyr::summarise(
        count = n(),
        product_lines = paste(unique(product_line_id), collapse = ", "),
        product_line_names = paste(unique(product_line_name), collapse = ", "),
        .groups = "drop"
      ) %>%
      dplyr::filter(count > 1) %>%
      dplyr::arrange(dplyr::desc(count))
    
    if (nrow(duplicate_analysis) > 0) {
      has_pre_duplicates <- TRUE
      message("\n⚠️  WARNING: DUPLICATE", toupper(item_id), "VALUES DETECTED IN GOOGLE SHEET")
      message(paste(rep("=", 70), collapse = ""))
      message(paste("Found", nrow(duplicate_analysis), item_id, "values assigned to multiple product lines:"))
      message("")
      
      for (i in 1:nrow(duplicate_analysis)) {
        item_value <- duplicate_analysis[[item_id]][i]
        count <- duplicate_analysis$count[i]
        lines <- duplicate_analysis$product_lines[i]
        names <- duplicate_analysis$product_line_names[i]
        
        message(sprintf("  %d. %s: %s", i, toupper(item_id), item_value))
        message(sprintf("     Assigned to %d product lines: %s", count, lines))
        message(sprintf("     Product line names: %s", names))
        message("")
      }
      
      message("❌ RECOMMENDATION: Please clean the Google Sheet before proceeding.")
      message(paste("   Each", item_id, "should only appear in ONE product line column."))
      message("")
      message("⚡ The import will continue and keep only the FIRST occurrence of each item,")
      message("   but this may cause inconsistent ratings across product lines.")
      message(paste(rep("=", 70), collapse = ""))
      message("")
      
      # Store for later reference
      assign("pre_import_duplicates", duplicate_analysis, envir = parent.frame())
      
      # Interactive check if available
      if (interactive()) {
        continue <- readline(paste("Do you want to continue with the import? (y/N): "))
        if (tolower(continue) != "y") {
          message("Import cancelled. Please clean the Google Sheet and try again.")
          stop("Import cancelled by user due to duplicate items.")
        }
      }
    } else {
      message("✅ No duplicate", item_id, "values found in Google Sheet - proceeding with import")
    }
  } else {
    message("⚠️  No", item_id, "values found in Google Sheet")
  }
  
  message("\n", paste(rep("=", 70), collapse = ""))
  message("🔧 STEP 2: Processing and Importing Data")
  message(paste(rep("=", 70), collapse = ""))
  
  # Initialize result data frame
  result_data <- data.frame()
  
  # For each product line, extract and transform its data
  for (i in 1:nrow(active_product_lines)) {
    product_line_id <- active_product_lines$product_line_id[i]
    product_line_name <- active_product_lines$product_line_name_chinese[i]
    
    # Define column names for this product line
    expected_cols <- setNames(
      paste_(column_names, product_line_name),
      column_names
    )
    
    # Check which columns exist
    missing_cols <- expected_cols[!expected_cols %in% names(df_competitor_items)]
    existing_cols <- expected_cols[expected_cols %in% names(df_competitor_items)]
    
    # Warn about missing columns
    if (length(missing_cols) > 0) {
      warning(paste("Missing columns for", product_line_name, ":",
                    paste(missing_cols, collapse = ", "),
                    "\nExpected format:", paste(names(missing_cols), "_", product_line_name, sep = "", collapse = ", ")))
    }
    
    # Skip if no columns found
    if (length(existing_cols) == 0) {
      warning(paste("No valid columns found for", product_line_name, "- skipping"))
      next
    }
    
    # Extract data with existing columns
    product_data <- df_competitor_items[existing_cols]
    
    # Add product_line_id
    product_data$product_line_id <- product_line_id
    
    # Rename columns to base names
    names(product_data)[names(product_data) %in% existing_cols] <- names(existing_cols)
    
    # Reorder with product_line_id first
    product_data <- dplyr::relocate(product_data, product_line_id)
    
    # Apply brand imputation if specified
    if (!is.null(brand_imputed) && "brand" %in% names(product_data) && brand_imputed %in% names(product_data)) {
      # Count UNKNOWN brands before imputation
      unknown_count <- sum(product_data$brand == "UNKNOWN", na.rm = TRUE)
      
      if (unknown_count > 0) {
        # Replace UNKNOWN brands with the value from the imputed column
        product_data$brand <- ifelse(
          product_data$brand == "UNKNOWN", 
          product_data[[brand_imputed]], 
          product_data$brand
        )
        message(paste("  Imputed", unknown_count, "UNKNOWN brands with", brand_imputed, "values"))
      }
    } else if (!is.null(brand_imputed) && !brand_imputed %in% names(product_data)) {
      warning(paste("Brand imputation requested but column", brand_imputed, "not found for", product_line_name))
    }
    
    # Drop rows with all NA values in data columns (excluding product_line_id)
    data_cols <- setdiff(names(product_data), "product_line_id")
    product_data <- product_data[rowSums(!is.na(product_data[data_cols])) > 0, ]
    
    message(paste("📦 Found", nrow(product_data), "competitor items for", product_line_name,
                  "with columns:", paste(names(existing_cols), collapse = ", ")))
    
    # Append to result
    result_data <- rbind(result_data, product_data)
  }
  
  # =====================================================================
  # STEP 3: Post-processing Duplicate Check and Cleanup
  # =====================================================================
  message("\n", paste(rep("=", 70), collapse = ""))
  message("🔍 STEP 3: Post-processing Validation")
  message(paste(rep("=", 70), collapse = ""))
  
  # Check for duplicates in the processed data
  if (nrow(result_data) > 0 && item_id %in% names(result_data)) {
    # Find duplicates
    duplicate_check <- result_data %>%
      dplyr::count(!!rlang::sym(item_id)) %>%
      dplyr::filter(n > 1) %>%
      dplyr::arrange(dplyr::desc(n))
    
    if (nrow(duplicate_check) > 0) {
      message(paste("⚠️  Found", nrow(duplicate_check), "duplicate", item_id, "values in processed data:"))
      
      # Show details of first 10 duplicates
      for (i in 1:min(10, nrow(duplicate_check))) {
        item_value <- duplicate_check[[item_id]][i]
        count <- duplicate_check$n[i]
        
        # Get details of this duplicate
        dup_details <- result_data %>%
          dplyr::filter(!!rlang::sym(item_id) == item_value) %>%
          dplyr::select(product_line_id, dplyr::all_of(item_id), dplyr::everything())
        
        message(sprintf("\n  %s: %s (%d occurrences)", toupper(item_id), item_value, count))
        print(dup_details)
      }
      
      if (nrow(duplicate_check) > 10) {
        message(paste("\n  ... and", nrow(duplicate_check) - 10, "more duplicate items"))
      }
      
      # Remove duplicates - keep first occurrence
      message(paste("\n🔧 Removing duplicates - keeping first occurrence of each", item_id))
      original_count <- nrow(result_data)
      result_data <- result_data %>%
        dplyr::distinct(!!rlang::sym(item_id), .keep_all = TRUE)
      removed_count <- original_count - nrow(result_data)
      message(sprintf("✅ Removed %d duplicates. %d items remain", removed_count, nrow(result_data)))
    } else {
      message(paste("✅ No duplicate", item_id, "values found in processed data - validation passed"))
    }
  }
  
  # =====================================================================
  # STEP 4: Database Writing and Final Analysis
  # =====================================================================
  message("\n", paste(rep("=", 70), collapse = ""))
  message("💾 STEP 4: Writing to Database and Final Analysis")
  message(paste(rep("=", 70), collapse = ""))
  
  if (nrow(result_data) > 0) {
    # Determine table name based on platform
    table_name <- if (!is.null(platform)) {
      paste_("df", platform, "competitor_item_id")
    } else {
      "df_competitor_item_id"
    }
    
    # Write to database
    DBI::dbWriteTable(db_connection, table_name, result_data, overwrite = TRUE)
    message(paste("💾 Successfully imported", nrow(result_data), "competitor items to table:", table_name))
    
    # ===================================================================
    # Final Comprehensive Analysis Report
    # ===================================================================
    message("\n", paste(rep("=", 70), collapse = ""))
    message("📊 COMPREHENSIVE IMPORT ANALYSIS REPORT")
    message(paste(rep("=", 70), collapse = ""))
    
    # Final duplicate validation
    final_duplicate_check <- result_data %>%
      dplyr::count(!!rlang::sym(item_id)) %>%
      dplyr::filter(n > 1)
    
    if (nrow(final_duplicate_check) > 0) {
      message(sprintf("⚠️  WARNING: %d duplicate %s values still exist in final dataset:", 
                      nrow(final_duplicate_check), item_id))
      print(final_duplicate_check)
    } else {
      message(sprintf("✅ VALIDATION PASSED: No duplicate %s values in final dataset", item_id))
    }
    
    # Product line distribution
    message(sprintf("\n📈 Items per product line:"))
    product_line_summary <- table(result_data$product_line_id)
    print(product_line_summary)
    
    # Calculate total items
    total_items <- sum(product_line_summary)
    message(sprintf("\n📋 Total unique %s imported: %d", item_id, total_items))
    
    # Column information
    message(sprintf("\n📄 Columns in final dataset (%d): %s", 
                    length(names(result_data)), paste(names(result_data), collapse = ", ")))
    
    # Country distribution if available
    if ("country" %in% names(result_data)) {
      message("\n🌍 Items per country:")
      country_summary <- table(result_data$country, useNA = "ifany")
      print(country_summary)
    }
    
    # Brand analysis if available
    if ("brand" %in% names(result_data)) {
      unique_brands <- sort(unique(result_data$brand[!is.na(result_data$brand)]))
      message(sprintf("\n🏷️  Unique brands found (%d):", length(unique_brands)))
      if (length(unique_brands) <= 20) {
        message(paste("   ", paste(unique_brands, collapse = ", ")))
      } else {
        message(paste("   ", paste(unique_brands[1:20], collapse = ", ")))
        message(sprintf("   ... and %d more", length(unique_brands) - 20))
      }
    }
    
    # Data quality checks
    message("\n🔍 Data Quality Summary:")
    
    # Check for missing item IDs
    missing_items <- sum(is.na(result_data[[item_id]]) | result_data[[item_id]] == "")
    if (missing_items > 0) {
      message(sprintf("   ❌ %d items have missing %s values", missing_items, item_id))
    } else {
      message(sprintf("   ✅ All items have valid %s values", item_id))
    }
    
    # Check for missing product line IDs
    missing_product_line <- sum(is.na(result_data$product_line_id))
    if (missing_product_line > 0) {
      message(sprintf("   ❌ %d items have missing product_line_id values", missing_product_line))
    } else {
      message("   ✅ All items have valid product_line_id values")
    }
    
    # Completeness check for other columns
    for (col in names(result_data)) {
      if (col %in% c(item_id, "product_line_id")) next
      missing_count <- sum(is.na(result_data[[col]]) | result_data[[col]] == "")
      completeness <- round((1 - missing_count / nrow(result_data)) * 100, 1)
      status <- if (completeness >= 90) "✅" else if (completeness >= 70) "⚠️ " else "❌"
      message(sprintf("   %s %s: %s%% complete (%d missing)", 
                      status, col, completeness, missing_count))
    }
    
    # ===================================================================
    # Final Recommendations and Next Steps
    # ===================================================================
    message("\n", paste(rep("=", 70), collapse = ""))
    message("📋 NEXT STEPS AND RECOMMENDATIONS:")
    message(paste(rep("=", 70), collapse = ""))
    
    if (has_pre_duplicates || nrow(final_duplicate_check) > 0) {
      message("⚠️  DUPLICATES DETECTED - Action Required:")
      message("   1. 🧹 Review and clean the Google Sheet to remove duplicate", item_id, "values")
      message("   2. 📝 Ensure each item appears in only ONE product line column")
      message("   3. 🔄 Re-run this import after cleaning the sheet")
      message("   4. 🗑️  Clear existing rating data to avoid cross-contamination:")
      message("      - Clear comment_property_rating tables")
      message("      - Clear comment_property_rating_results tables")
      message("   5. 🚀 Re-run the rating pipeline after cleaning")
    } else {
      message("✅ NO DUPLICATES DETECTED - Safe to proceed:")
      message("   1. ▶️  Continue with review processing")
      message("   2. 🏷️  Process comment properties")
      message("   3. 🤖 Run AI rating analysis")
      message("   4. 📊 Generate final rating tables")
    }
    
    message("\n💡 TIPS FOR MAINTAINING DATA QUALITY:")
    message("   • 🔍 Always run import with validation before rating analysis")
    message("   • 📋 Keep Google Sheet organized with clear column naming")
    message("   • 🚫 Regularly check for and resolve duplicate assignments")
    message("   • 📝 Document any manual changes to competitor items")
    message("   • 🔄 Use version control for Google Sheet changes")
    
    message(paste(rep("=", 70), collapse = ""))
    
  } else {
    message("\n❌ ERROR: No competitor items were imported!")
    message("📋 Please check:")
    message("   • Google Sheet structure and column names")
    message("   • Product line configuration")
    message("   • Sheet name and skip parameters")
    message("   • Data quality in the source sheet")
  }
  
  return(result_data)
}