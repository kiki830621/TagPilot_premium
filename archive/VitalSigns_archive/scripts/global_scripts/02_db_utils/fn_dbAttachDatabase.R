#' @file fn_dbAttachDatabase.R
#' @use_package DBI
#' @use_package duckdb
#' @note Depends on fn_dbConnect_from_list.R from the same directory
#' 
#' @title Connect and Attach a Second Database
#'
#' @description
#' Establishes a connection to a main DuckDB database and attaches a second database,
#' enabling cross-database queries through a single connection.
#'
#' @param main_db_name Character. The name of the main database to connect to (must exist in path_list)
#' @param second_db_name Character. The name of the second database to attach (must exist in path_list)
#' @param second_db_alias Character. The alias to use for the attached database (defaults to "second_db")
#' @param read_only Logical. Whether to open the databases in read-only mode (defaults to FALSE)
#' @param path_list List. The list of database paths (defaults to db_path_list)
#' @param verbose Logical. Whether to display information about the connections (defaults to TRUE)
#'
#' @return List containing the connection object and tracking information
#'
#' @details
#' The function performs the following steps:
#' 1. Connects to the main database using dbConnect_from_list
#' 2. Uses SQL ATTACH DATABASE command to attach the second database with the specified alias
#' 3. Returns a tracking object with information needed for proper detachment and cleanup
#'
#' This approach allows querying both databases through a single connection,
#' which is more efficient than maintaining two separate connections.
#'
#' @note
#' - The main connection is stored in the global environment with the same name as main_db_name
#' - The second database is accessed through the main connection using the specified alias
#' - Use dbDetachDatabase() for proper cleanup
#'
#' @examples
#' # Connect to main database and attach second database
#' connection <- dbAttachDatabase("raw_data", "app_data")
#'
#' # Query the attached database
#' result <- dbGetQuery(connection$con, "SELECT * FROM second_db.some_table")
#'
#' # Join tables from both databases
#' joined_data <- dbGetQuery(connection$con, 
#'   "SELECT * FROM main_table JOIN second_db.other_table ON main_table.id = other_table.id")
#'
#' # Disconnect when done
#' dbDetachDatabase(connection)
#'
#' @export
dbAttachDatabase <- function(main_db_name, second_db_name,
                           second_db_alias = "second_db",
                           read_only = FALSE,
                           path_list = db_path_list,
                           verbose = TRUE) {
  # Initialize tracking variables
  connection_created <- FALSE
  database_attached <- FALSE
  
  # Initialize result list
  result <- list(
    con = NULL,
    main_db_name = main_db_name,
    second_db_name = second_db_name,
    second_db_alias = second_db_alias,
    connection_created = connection_created,
    database_attached = database_attached,
    read_only = read_only
  )
  
  # Helper function to clean up on error
  cleanup_on_error <- function() {
    if (database_attached) {
      if (verbose) message("Cleaning up: detaching second database")
      tryCatch({
        DBI::dbExecute(get(main_db_name, envir = .GlobalEnv), 
                      paste0("DETACH DATABASE ", second_db_alias))
      }, error = function(e) {
        warning("Error detaching database: ", e$message)
      })
    }
    
    if (connection_created) {
      if (verbose) message("Cleaning up: disconnecting from main database")
      tryCatch({
        DBI::dbDisconnect(get(main_db_name, envir = .GlobalEnv), shutdown = TRUE)
        if (exists(main_db_name, envir = .GlobalEnv)) {
          rm(list = main_db_name, envir = .GlobalEnv)
        }
      }, error = function(e) {
        warning("Error disconnecting: ", e$message)
      })
    }
  }
  
  # Try to connect to main database
  tryCatch({
    main_db_con <- dbConnect_from_list(main_db_name, path_list = path_list, 
                                     read_only = read_only, verbose = verbose)
    connection_created <- TRUE
    result$con <- main_db_con
    result$connection_created <- TRUE
    
    # Get path to second database
    if (!second_db_name %in% names(path_list)) {
      stop("Specified second database '", second_db_name, "' not found in path list")
    }
    second_db_path <- path_list[[second_db_name]]
    
    # Attach second database
    attach_query <- paste0("ATTACH DATABASE '", second_db_path, "' AS ", second_db_alias)
    if (read_only) {
      attach_query <- paste0(attach_query, " (READ_ONLY)")
    }
    
    if (verbose) message("Attaching second database with query: ", attach_query)
    
    DBI::dbExecute(main_db_con, attach_query)
    database_attached <- TRUE
    result$database_attached <- TRUE
    
    if (verbose) {
      # List tables in attached database
      tables_query <- paste0("SELECT * FROM ", second_db_alias, ".sqlite_master WHERE type='table'")
      tables <- tryCatch({
        DBI::dbGetQuery(main_db_con, tables_query)
      }, error = function(e) {
        message("Note: Could not list tables in attached database. This is normal for empty databases.")
        data.frame(name = character(0))
      })
      
      message("Successfully attached database '", second_db_name, "' as '", second_db_alias, "'")
      if (nrow(tables) > 0) {
        message("Tables in attached database: ", paste(tables$name, collapse = ", "))
      } else {
        message("No tables found in attached database or database is empty")
      }
    }
    
  }, error = function(e) {
    cleanup_on_error()
    stop("Failed to set up database connections: ", e$message)
  })
  
  return(result)
}

#' @title Detach Database and Disconnect
#'
#' @description
#' Detaches the second database and disconnects from the main database
#' that were connected using dbAttachDatabase()
#'
#' @param connection List. The connection tracking object returned by dbAttachDatabase()
#' @param verbose Logical. Whether to display information about disconnection (defaults to TRUE)
#'
#' @return Logical. TRUE if all operations succeeded, FALSE otherwise
#'
#' @examples
#' # Connect to main database and attach second database
#' connection <- dbAttachDatabase("raw_data", "app_data")
#' 
#' # ... perform operations ...
#' 
#' # Detach and disconnect when done
#' dbDetachDatabase(connection)
#'
#' @export
dbDetachDatabase <- function(connection, verbose = TRUE) {
  # Initialize success flag
  success <- TRUE
  
  # Extract tracking information
  main_db_name <- connection$main_db_name
  second_db_alias <- connection$second_db_alias
  database_attached <- connection$database_attached
  connection_created <- connection$connection_created
  
  # Get the connection from global environment
  if (connection_created && exists(main_db_name, envir = .GlobalEnv)) {
    main_con <- get(main_db_name, envir = .GlobalEnv)
    
    # Detach second database if it was attached
    if (database_attached) {
      tryCatch({
        detach_query <- paste0("DETACH DATABASE ", second_db_alias)
        DBI::dbExecute(main_con, detach_query)
        if (verbose) message("Successfully detached database '", second_db_alias, "'")
      }, error = function(e) {
        warning("Error detaching database '", second_db_alias, "': ", e$message)
        success <- FALSE
      })
    }
    
    # Disconnect from main database
    tryCatch({
      DBI::dbDisconnect(main_con, shutdown = TRUE)
      rm(list = main_db_name, envir = .GlobalEnv)
      if (verbose) message("Successfully disconnected from database '", main_db_name, "'")
    }, error = function(e) {
      warning("Error disconnecting from database '", main_db_name, "': ", e$message)
      success <- FALSE
    })
  } else if (verbose) {
    message("Main database connection not found in global environment")
    success <- FALSE
  }
  
  return(success)
}

#' @note
#' This function has the following dependencies:
#' - DBI package - Required for database interface functions
#' - duckdb package - Required for DuckDB connections
#' - fn_dbConnect_from_list.R - Required for establishing the main connection
#'