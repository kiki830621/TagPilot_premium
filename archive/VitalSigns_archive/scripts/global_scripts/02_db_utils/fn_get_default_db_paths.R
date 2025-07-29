#' Get Default Database Paths
#'
#' A function for determining default database paths based on the current directory structure.
#' Each database serves a specific purpose:
#' - raw_data: Original unprocessed data
#' - cleansed_data: Data after basic cleaning (deduplication, type conversion, missing values)
#' - processed_data: Fully transformed data ready for analysis
#' - sales_by_customer_date_data: Sales data aggregated by customer and date
#' - app_data: Data used by the Shiny application
#' - slowly_changing_data: Data that changes slowly over time (dimensions)
#' - comment_property_rating: Product ratings and comments
#' - global_scd_type1: Global slowly changing dimensions (type 1)
#'
#' @param base_dir Optional. Base directory to use instead of auto-detection
#' @return A list containing paths to all databases used in the project
#' @examples
#' db_paths <- get_default_db_paths()
#' db_paths <- get_default_db_paths("/custom/base/dir")
#'
get_default_db_paths <- function() {
  return(list(
    # Application data databases in app_data directory
    raw_data = file.path(COMPANY_DIR, "raw_data.duckdb"),
    cleansed_data = file.path(COMPANY_DIR, "cleansed_data.duckdb"),
    processed_data = file.path(COMPANY_DIR, "processed_data.duckdb"),
    sales_by_customer_date_data = file.path(APP_DATA_DIR, "sales_by_customer_date_data.duckdb"),
    app_data = file.path(APP_DATA_DIR,"app_data.duckdb"),
    slowly_changing_data = file.path(APP_DATA_DIR, "slowly_changing_data.duckdb"),
    comment_property_rating = file.path(APP_DATA_DIR, "scd_type2", "comment_property_rating.duckdb"),
    comment_property_rating_results = file.path(APP_DATA_DIR, "scd_type2", "comment_property_rating_results.duckdb"),
    
    # Global data in the global_scripts directory
    global_scd_type1 = file.path(GLOBAL_DIR, "global_data", "global_scd_type1.duckdb")
  ))
}
