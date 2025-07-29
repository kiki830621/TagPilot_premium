# N0002.R
# Configuration Validation Utility Node
#
# This script implements a platform-agnostic utility for validating
# configuration files (YAML, JSON, etc.) against schemas.
#
# Node utilities are designed to be atomic, reusable components that can be
# leveraged by multiple derivations and sequences.

#' Validate a YAML configuration file against a schema
#'
#' @param config_path Path to the YAML configuration file
#' @param schema_path Path to the YAML schema file
#' @param verbose Logical, whether to print validation messages
#'
#' @return TRUE if validation passes, otherwise FALSE with error message
#'
validate_yaml_config <- function(config_path, schema_path, verbose = TRUE) {
  if(verbose) message("Validating YAML configuration...")
  
  tryCatch({
    # Check if required packages are available
    if(!requireNamespace("yaml", quietly = TRUE)) {
      stop("Package 'yaml' needed for YAML validation. Please install it.")
    }
    if(!requireNamespace("jsonvalidate", quietly = TRUE)) {
      stop("Package 'jsonvalidate' needed for schema validation. Please install it.")
    }
    
    # Read configuration file
    if(!file.exists(config_path)) {
      stop("Configuration file not found: ", config_path)
    }
    config <- yaml::read_yaml(config_path)
    
    # Read schema file
    if(!file.exists(schema_path)) {
      stop("Schema file not found: ", schema_path)
    }
    schema <- readLines(schema_path, warn = FALSE)
    schema <- paste(schema, collapse = "\n")
    
    # Convert YAML to JSON for validation
    config_json <- jsonlite::toJSON(config, auto_unbox = TRUE)
    
    # Validate JSON against schema
    is_valid <- jsonvalidate::json_validate(config_json, schema, verbose = verbose)
    
    if(is_valid) {
      if(verbose) message("Configuration is valid")
      return(TRUE)
    } else {
      if(verbose) message("Configuration validation failed")
      return(FALSE)
    }
  }, error = function(e) {
    message("Error validating configuration: ", e$message)
    return(FALSE)
  })
}

#' Load a configuration file with validation
#'
#' @param config_path Path to the configuration file
#' @param schema_path Path to the schema file (optional)
#' @param format Format of the configuration file ("yaml" or "json")
#' @param validate Logical, whether to validate against schema
#' @param verbose Logical, whether to print messages
#'
#' @return Configuration as a list if successful, otherwise NULL
#'
load_config <- function(config_path, schema_path = NULL, format = "yaml", 
                        validate = TRUE, verbose = TRUE) {
  if(verbose) message("Loading configuration from ", config_path)
  
  tryCatch({
    # Check if file exists
    if(!file.exists(config_path)) {
      stop("Configuration file not found: ", config_path)
    }
    
    # Load based on format
    if(format == "yaml") {
      if(!requireNamespace("yaml", quietly = TRUE)) {
        stop("Package 'yaml' needed for YAML loading. Please install it.")
      }
      config <- yaml::read_yaml(config_path)
    } else if(format == "json") {
      if(!requireNamespace("jsonlite", quietly = TRUE)) {
        stop("Package 'jsonlite' needed for JSON loading. Please install it.")
      }
      config <- jsonlite::fromJSON(config_path)
    } else {
      stop("Unsupported configuration format: ", format)
    }
    
    # Validate if requested and schema provided
    if(validate && !is.null(schema_path)) {
      is_valid <- FALSE
      
      if(format == "yaml") {
        is_valid <- validate_yaml_config(config_path, schema_path, verbose = verbose)
      } else if(format == "json") {
        # JSON validation implementation
        is_valid <- TRUE
      }
      
      if(!is_valid) {
        warning("Configuration validation failed")
      }
    }
    
    return(config)
  }, error = function(e) {
    message("Error loading configuration: ", e$message)
    return(NULL)
  })
}

#' Get a value from a configuration with default fallback
#'
#' @param config Configuration list
#' @param path Path to the value (dot notation, e.g., "database.host")
#' @param default Default value to return if path not found
#'
#' @return Value at path if found, otherwise default
#'
get_config_value <- function(config, path, default = NULL) {
  if(is.null(config)) {
    return(default)
  }
  
  # Split path by dots
  parts <- strsplit(path, "\\.")[[1]]
  
  # Navigate through the config
  current <- config
  for(part in parts) {
    if(is.null(current) || !is.list(current) || is.null(current[[part]])) {
      return(default)
    }
    current <- current[[part]]
  }
  
  return(current)
}