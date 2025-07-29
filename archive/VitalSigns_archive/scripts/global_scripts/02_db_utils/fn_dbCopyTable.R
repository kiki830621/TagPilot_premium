#' Copy Table Between Database Connections
#'
#' This function copies a table from one database connection to another by reading
#' the data into memory and writing it to the target database. It supports copying
#' with optional renaming and various write options.
#'
#' @param source_con A DBI connection object for the source database
#' @param target_con A DBI connection object for the target database
#' @param source_table Character string. Name of the table to copy from source database
#' @param target_table Character string. Name of the table to create in target database (default: same as source_table)
#' @param overwrite Logical. Whether to overwrite existing table in target database (default: FALSE)
#' @param temporary Logical. Whether to create a temporary table in target database (default: FALSE)
#'
#' @return Invisible NULL. The function creates a table as a side effect.
#'
#' @details
#' This function performs a complete copy of a table by:
#' 1. Reading all data from the source table into memory using dplyr::collect()
#' 2. Writing the data to the target database using DBI::dbWriteTable()
#' 
#' Note: For large tables, this operation may consume significant memory as all
#' data is loaded into R before being written to the target database.
#'
#' @examples
#' \dontrun{
#' # Copy table with same name
#' dbCopyTable(
#'   source_con = raw_data,
#'   target_con = processed_data,
#'   source_table = "df_sales_data"
#' )
#' 
#' # Copy table with different name and overwrite if exists
#' dbCopyTable(
#'   source_con = raw_data,
#'   target_con = comment_property_rating,
#'   source_table = "df_all_comment_property",
#'   target_table = "df_comment_property_backup",
#'   overwrite = TRUE
#' )
#' 
#' # Copy as temporary table
#' dbCopyTable(
#'   source_con = processed_data,
#'   target_con = temp_db,
#'   source_table = "df_eby_review",
#'   temporary = TRUE
#' )
#' }
#'
#' @export
dbCopyTable <- function(source_con, target_con, source_table, target_table = source_table, overwrite = FALSE, temporary = FALSE) {
  
  # Validate inputs
  if (!DBI::dbIsValid(source_con)) {
    stop("source_con is not a valid database connection")
  }
  
  if (!DBI::dbIsValid(target_con)) {
    stop("target_con is not a valid database connection")
  }
  
  if (!is.character(source_table) || length(source_table) != 1) {
    stop("source_table must be a single character string")
  }
  
  if (!is.character(target_table) || length(target_table) != 1) {
    stop("target_table must be a single character string")
  }
  
  # Check if source table exists
  if (!source_table %in% DBI::dbListTables(source_con)) {
    stop(paste("Table", source_table, "does not exist in source database"))
  }
  
  # Load required packages
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    library(dplyr)
  }
  
  # 從來源連線讀取資料表，並收集成 data frame
  message(paste("Reading table", source_table, "from source database..."))
  data <- dplyr::tbl(source_con, source_table) %>% dplyr::collect()
  
  message(paste("Read", nrow(data), "rows with", ncol(data), "columns"))
  
  # 將資料寫入目標連線，target_table 預設與 source_table 相同
  message(paste("Writing table", target_table, "to target database..."))
  DBI::dbWriteTable(target_con, target_table, data, overwrite = overwrite, temporary = temporary)
  
  message(paste("Successfully copied table", source_table, "to", target_table))
  
  # Return invisibly
  invisible(NULL)
}