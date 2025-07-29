#' Execute Principle and Rule Three-Digit Indexing Conversion - April 15, 2025
#'
#' @description
#' This script converts all Principle (P) and Rule (R) index numbers to a three-digit format
#' by adding leading zeros. For example, P01 becomes P001, R99 becomes R099.
#'
#' @author Claude
#' @date 2025-04-15

# Set working directory to the 00_principles directory
principles_dir <- "/Users/che/Library/CloudStorage/Dropbox/precision_marketing/precision_marketing_WISER/precision_marketing_app/update_scripts/global_scripts/00_principles"
setwd(principles_dir)

# Create backup directory if it doesn't exist
backup_dir <- "renumbering_backup"
if (!dir.exists(backup_dir)) {
  dir.create(backup_dir)
}

# Backup the entire directory before starting
timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
backup_dir_path <- file.path(backup_dir, paste0("backup_", timestamp))
dir.create(backup_dir_path)
system(paste0("cp -r P*.md R*.md ", backup_dir_path))
cat("Created backup in:", backup_dir_path, "\n")

# Get all P and R files, excluding MP files
pr_files <- list.files(pattern = "^[PR]\\d+.*\\.md$")
pr_files <- pr_files[!grepl("^MP", pr_files)]
cat("Found", length(pr_files), "P and R files to convert.\n\n")

# Function to determine if a filename starts with P or R followed by numbers
determine_prefix <- function(filename) {
  if (grepl("^P\\d+", filename)) {
    return("P")
  } else if (grepl("^R\\d+", filename)) {
    return("R")
  } else if (grepl("^P_R\\d+", filename)) {
    return("P_R")  # Special case for combined P_R files
  } else {
    return(NA)
  }
}

# Special handling for P_R files
special_cases <- list()

# Manual rename process
for (file in pr_files) {
  # Skip files that already have a three-digit format (P###_ or R###_)
  if (grepl("^[PR]\\d{3}_", file)) {
    cat("Skipping (already in three-digit format):", file, "\n")
    next
  }
  
  # Handle special case for P_R files
  if (grepl("^P_R\\d+", file)) {
    # Extract numbers and name parts
    parts <- strsplit(file, "_")[[1]]
    num_part <- gsub("^R", "", parts[2])  # Extract "100" from "R100"
    
    # Create the new three-digit format
    new_num <- sprintf("%03d", as.numeric(num_part))
    
    # Create the new filename with the parts preserved
    new_file <- paste0("P_R", new_num, "_", paste(parts[3:length(parts)], collapse = "_"))
    
    special_cases[[file]] <- new_file
    cat("Special case - will convert:", file, "→", new_file, "\n")
    next
  }
  
  # Determine prefix (P or R)
  prefix <- determine_prefix(file)
  if (is.na(prefix)) {
    cat("Skipping (unknown format):", file, "\n")
    next
  }
  
  # Extract the number from filename (e.g., "01" from "P01_something.md")
  num_match <- regexpr(paste0("^", prefix, "\\d+"), file)
  if (num_match > 0) {
    full_match <- regmatches(file, num_match)
    num_part <- gsub(paste0("^", prefix), "", full_match)
    
    # Create the new three-digit format
    new_num <- sprintf("%03d", as.numeric(num_part))
    new_prefix_num <- paste0(prefix, new_num)
    
    # Create the new filename
    new_file <- gsub(full_match, new_prefix_num, file)
    
    # Report the change
    cat("Converting:", file, "→", new_file, "\n")
    
    # Read the file content
    content <- readLines(file)
    
    # Update references within the file content
    for (i in 1:length(content)) {
      # Update any references to P## or R##
      content[i] <- gsub("P(\\d{1,2})([^0-9])", "P00\\1\\2", content[i])
      content[i] <- gsub("P0(\\d{2})([^0-9])", "P0\\1\\2", content[i])
      content[i] <- gsub("R(\\d{1,2})([^0-9])", "R00\\1\\2", content[i])
      content[i] <- gsub("R0(\\d{2})([^0-9])", "R0\\1\\2", content[i])
      
      # Update ID in YAML frontmatter if present
      if (grepl("^id:", content[i])) {
        content[i] <- gsub("\"P(\\d{1,2})\"", "\"P00\\1\"", content[i])
        content[i] <- gsub("\"P0(\\d{2})\"", "\"P0\\1\"", content[i])
        content[i] <- gsub("\"R(\\d{1,2})\"", "\"R00\\1\"", content[i])
        content[i] <- gsub("\"R0(\\d{2})\"", "\"R0\\1\"", content[i])
      }
    }
    
    # Write the updated content to the new file
    writeLines(content, new_file)
    
    # Remove the old file (only after successfully creating the new one)
    if (file.exists(new_file)) {
      file.remove(file)
    }
  } else {
    cat("Skipping (could not extract number):", file, "\n")
  }
}

# Process special cases separately
for (old_file in names(special_cases)) {
  new_file <- special_cases[[old_file]]
  cat("Processing special case:", old_file, "→", new_file, "\n")
  
  # Read the file content
  content <- readLines(old_file)
  
  # Update references within the file content
  for (i in 1:length(content)) {
    # Update any references to P## or R##
    content[i] <- gsub("P(\\d{1,2})([^0-9])", "P00\\1\\2", content[i])
    content[i] <- gsub("P0(\\d{2})([^0-9])", "P0\\1\\2", content[i])
    content[i] <- gsub("R(\\d{1,2})([^0-9])", "R00\\1\\2", content[i])
    content[i] <- gsub("R0(\\d{2})([^0-9])", "R0\\1\\2", content[i])
    
    # Also update references to P_R##
    content[i] <- gsub("P_R(\\d{1,2})([^0-9])", "P_R00\\1\\2", content[i])
    content[i] <- gsub("P_R0(\\d{2})([^0-9])", "P_R0\\1\\2", content[i])
    
    # Update ID in YAML frontmatter if present
    if (grepl("^id:", content[i])) {
      content[i] <- gsub("\"P_R(\\d{1,2})\"", "\"P_R00\\1\"", content[i])
      content[i] <- gsub("\"P_R0(\\d{2})\"", "\"P_R0\\1\"", content[i])
    }
  }
  
  # Write the updated content to the new file
  writeLines(content, new_file)
  
  # Remove the old file (only after successfully creating the new one)
  if (file.exists(new_file)) {
    file.remove(old_file)
  }
}

cat("\nVerifying results...\n")
system("ls -la P*.md | wc -l")
system("ls -la P*.md | head -5")
system("ls -la R*.md | wc -l")
system("ls -la R*.md | head -5")

cat("\nThree-digit conversion for P and R files completed.\n")