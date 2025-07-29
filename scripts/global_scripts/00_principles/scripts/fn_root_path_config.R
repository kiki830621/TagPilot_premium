# Root Path Configuration for Precision Marketing Projects
# This script implements a two-tier directory structure for path configuration

# Function to detect paths using the two-tier structure:
# 1. APP_DIR = Current working directory
# 2. ROOT_DIR = Parent directory of APP_DIR
detect_paths <- function() {
  # Get the current working directory (app_dir)
  app_dir <- getwd()
  message("App directory (current working directory): ", app_dir)

  # Get the parent directory as root_dir
  root_dir <- dirname(app_dir)
  message("Root directory (parent directory): ", root_dir)
  
  # Return both paths in a list
  return(list(
    APP_DIR = app_dir,
    ROOT_DIR = root_dir
  ))
}

# Get the path structure
path_structure <- detect_paths()

# Set the global path variables
APP_DIR <- path_structure$APP_DIR
ROOT_DIR <- path_structure$ROOT_DIR

# For backward compatibility, set ROOT_PATH to APP_DIR
ROOT_PATH <- APP_DIR

# Create required app directories if they don't exist
app_data_dir <- file.path(APP_DIR, "app_data")
if (!dir.exists(app_data_dir)) {
  dir.create(app_data_dir, recursive = TRUE)
  message("Created app_data directory: ", app_data_dir)
}

update_scripts_dir <- file.path(APP_DIR, "update_scripts")
if (!dir.exists(update_scripts_dir)) {
  dir.create(update_scripts_dir, recursive = TRUE)
  message("Created update_scripts directory: ", update_scripts_dir)
}

# Function to get company path (updated for two-tier structure)
get_company_path <- function(company_name) {
  file.path(ROOT_DIR, paste0("precision_marketing_", company_name))
}

# Export the paths for cross-platform use
write_root_path_file <- function() {
  # Skip writing file if specified
  if (exists("SKIP_WRITE_ROOT_PATH") && SKIP_WRITE_ROOT_PATH) {
    message("Skipping root path file creation as requested")
    return(invisible(NULL))
  }
  
  # Create a platform-neutral R file with both paths
  r_path <- file.path(APP_DIR, "root_path.R")
  content <- paste0(
    "# Auto-generated path configuration\n",
    "# Created: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n",
    "APP_DIR <- \"", APP_DIR, "\"\n",
    "ROOT_DIR <- \"", ROOT_DIR, "\"\n",
    "ROOT_PATH <- APP_DIR  # For backward compatibility\n"
  )
  writeLines(content, r_path)
  message("Path configuration exported to R file: ", r_path)
}

# Call the function to write the path configuration file
if (!exists("SKIP_WRITE_ROOT_PATH") || !SKIP_WRITE_ROOT_PATH) {
  write_root_path_file()
}