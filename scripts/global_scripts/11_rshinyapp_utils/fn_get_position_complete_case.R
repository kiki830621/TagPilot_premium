#' Get Position Table Data for Complete Case Analysis
#' 
#' This function retrieves and processes Position Table data for complete case analysis.
#' It includes type filtering, product line filtering, and preserves special rows 
#' (Ideal, Rating, Revenue) for comprehensive analysis.
#' 
#' @param app_data_connection Database connection object
#' @param product_line_id Product line identifier to filter by
#' @param include_special_rows Logical, whether to include Ideal/Rating/Revenue rows
#' @param apply_type_filter Logical, whether to apply type = "屬性" filtering (default TRUE)
#' @param type_values Character vector of type values to include (default "屬性")
#' 
#' @return A tibble with position table data for complete case analysis
#' 
#' @examples
#' \dontrun{
#' data <- fn_get_position_complete_case(
#'   app_data_connection = conn,
#'   product_line_id = "tur",
#'   include_special_rows = TRUE,
#'   apply_type_filter = TRUE
#' )
#' }
#' 
#' @export
fn_get_position_complete_case <- function(
  app_data_connection,
  product_line_id,
  include_special_rows = TRUE,
  apply_type_filter = TRUE,
  type_values = "屬性"
) {
  
  # Validate inputs
  if (is.null(app_data_connection)) {
    stop("app_data_connection is required")
  }
  
  if (is.null(product_line_id) || is.na(product_line_id) || product_line_id == "") {
    stop("product_line_id is required and cannot be empty")
  }
  
  # Start with base query
  tbl <- tbl2(app_data_connection, "df_position")
  
  # Apply product line filter if not "all"
  if (!is.null(product_line_id) && !is.na(product_line_id) && product_line_id != "all") {
    message("🔍 Applying product_line filter: ", product_line_id)
    tbl <- tbl %>% dplyr::filter(product_line_id == !!product_line_id)
  }
  
  # Apply type filtering if requested
  if (apply_type_filter && length(type_values) > 0) {
    message("📋 Applying type filter for 屬性 columns...")
    
    # Get property type information to filter columns
    tryCatch({
      # Try to access property table safely
      property_tbl <- tryCatch({
        tbl2(app_data_connection, "df_all_comment_property")
      }, error = function(e) {
        message("⚠️ Cannot access df_all_comment_property table: ", e$message)
        return(NULL)
      })
      
      if (is.null(property_tbl)) {
        message("📥 Property table not available, using fallback: keep all attribute columns...")
        # Fallback: collect data and keep all numeric columns that look like attributes
        collected_data <- tbl %>% dplyr::collect()
        
        # Essential columns that should always be kept
        essential_cols <- c("product_id", "brand", "product_line_id", "rating", "sales")
        essential_cols <- intersect(essential_cols, colnames(collected_data))
        
        # Find all non-essential columns (treat as attributes)
        all_cols <- colnames(collected_data)
        attr_cols <- setdiff(all_cols, essential_cols)
        
        # Keep essential + all attribute columns
        cols_to_keep <- unique(c(essential_cols, attr_cols))
        
        message("✨ Fallback: Keeping ", length(attr_cols), " attribute columns")
        message("🔧 Essential columns: ", paste(essential_cols, collapse = ", "))
        message("📊 Attribute columns: ", paste(head(attr_cols, 10), collapse = ", "), 
                if(length(attr_cols) > 10) paste(" ... and", length(attr_cols) - 10, "more") else "")
        
        tbl <- collected_data %>% dplyr::select(dplyr::all_of(cols_to_keep))
      }
      
      if (!is.null(product_line_id) && !is.na(product_line_id) && product_line_id != "all") {
        property_tbl <- property_tbl %>% 
          dplyr::filter(product_line_id == !!product_line_id)
      }
      
      # Get attributes to keep (type = "屬性") - collect the property data first
      property_data <- property_tbl %>% dplyr::collect()
      
      attributes_to_keep <- property_data %>%
        dplyr::filter(type %in% !!type_values) %>%
        dplyr::pull(attributes) %>%
        unique()
      
      if (length(attributes_to_keep) > 0) {
        # Convert to clean names for column matching
        clean_attr_names <- make_names(attributes_to_keep)
        
        # Collect all data first for column inspection
        collected_data <- tbl %>% dplyr::collect()
        
        # Find columns that match our attributes
        all_cols <- colnames(collected_data)
        essential_cols <- c("product_id", "brand", "product_line_id", "rating", "sales")
        attr_cols <- intersect(clean_attr_names, all_cols)
        
        # Select essential columns + matched attribute columns
        cols_to_keep <- unique(c(essential_cols, attr_cols))
        cols_to_keep <- intersect(cols_to_keep, all_cols)  # Ensure all exist
        
        message("✨ Keeping ", length(attr_cols), " attribute columns out of ", 
                length(attributes_to_keep), " total attributes")
        message("🔧 Essential columns: ", paste(essential_cols, collapse = ", "))
        message("📊 Attribute columns: ", paste(attr_cols, collapse = ", "))
        
        # Apply column selection
        if (length(cols_to_keep) > 0) {
          collected_data <- collected_data %>% 
            dplyr::select(dplyr::all_of(cols_to_keep))
        }
        
        # Convert back to tbl for consistency
        tbl <- collected_data
        
      } else {
        message("⚠️ No attributes found with type = '屬性' for product line: ", product_line_id)
        # Still collect the data for further processing
        tbl <- tbl %>% dplyr::collect()
      }
      
    }, error = function(e) {
      warning("Error applying type filter: ", e$message)
      message("📥 Proceeding without type filtering...")
      tbl <- tbl %>% dplyr::collect()
    })
    
  } else {
    # Collect data without type filtering
    tbl <- tbl %>% dplyr::collect()
  }
  
  # Handle special rows
  if (!include_special_rows) {
    message("🚫 Excluding special rows: Ideal, Rating, Revenue")
    tbl <- tbl %>% 
      dplyr::filter(!product_id %in% c("Ideal", "Rating", "Revenue"))
  } else {
    message("✅ Including special rows for complete case analysis")
  }
  
  # Log final data dimensions with safe nrow/ncol calls
  tryCatch({
    n_rows <- nrow(tbl)
    n_cols <- ncol(tbl)
    
    # Handle potential NA values
    if (is.na(n_rows) || is.null(n_rows)) {
      message("📈 Final data dimensions: unknown rows (data may be a query object)")
      # If it's a query object, try to collect it
      if (inherits(tbl, "tbl_lazy")) {
        tbl <- tbl %>% dplyr::collect()
        n_rows <- nrow(tbl)
        n_cols <- ncol(tbl)
        message("📈 After collection: ", n_rows, " rows × ", n_cols, " columns")
      }
    } else {
      message("📈 Final data dimensions: ", n_rows, " rows × ", n_cols, " columns")
    }
  }, error = function(e) {
    message("📈 Error getting data dimensions: ", e$message)
    # Try to collect if it's a lazy table
    if (inherits(tbl, "tbl_lazy")) {
      tryCatch({
        tbl <- tbl %>% dplyr::collect()
        message("📈 Collected data: ", nrow(tbl), " rows × ", ncol(tbl), " columns")
      }, error = function(e2) {
        message("📈 Failed to collect data: ", e2$message)
      })
    }
  })
  
  return(tbl)
} 