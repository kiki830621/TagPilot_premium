#' Connect to the application database
#'
#' @description
#' Establishes a connection to the DuckDB database used by the application.
#'
#' @param db_path Path to the DuckDB database file
#' @return A database connection object
#' @export
#' @implements MP45 Automatic Data Availability Detection
connect_to_app_database <- function(db_path = "app_data/app_data.duckdb") {
  tryCatch({
    if (!requireNamespace("DBI", quietly = TRUE)) {
      message("Installing DBI package...")
      install.packages("DBI")
    }
    
    if (!requireNamespace("duckdb", quietly = TRUE)) {
      message("Installing duckdb package...")
      install.packages("duckdb")
    }
    
    # Check if file exists
    if (!file.exists(db_path)) {
      stop("Database file does not exist at path: ", db_path)
    }
    
    # Connect to database
    conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = db_path)
    message("Successfully connected to database: ", db_path)
    
    return(conn)
  }, error = function(e) {
    message("Error connecting to database: ", e$message)
    return(NULL)
  })
}
