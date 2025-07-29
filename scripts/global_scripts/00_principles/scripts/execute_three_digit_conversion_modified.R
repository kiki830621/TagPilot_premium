#' Execute Three-Digit Indexing Conversion - April 15, 2025 (Modified)
#'
#' @description
#' This script converts all Meta Principle (MP) index numbers to a three-digit format
#' by adding leading zeros. For example, MP01 becomes MP001.
#' Modified to handle files with the same base number but different suffixes.
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
system(paste0("cp -r *.md M* P* R* S* ", backup_dir_path))
cat("Created backup in:", backup_dir_path, "\n")

# Get a list of all MP files
mp_files <- list.files(pattern = "^MP\\d+.*\\.md$")
cat("Found", length(mp_files), "MP files to convert.\n\n")

# Manual rename process since we have duplicate base numbers
for (file in mp_files) {
  # Extract the MP number from filename (e.g., "MP01" from "MP01_something.md")
  mp_number <- gsub("^(MP\\d+)_.*$", "\\1", file)
  
  # Extract just the numeric part
  num_part <- gsub("^MP", "", mp_number)
  
  # Create the new three-digit format
  new_num <- sprintf("%03d", as.numeric(num_part))
  new_mp_number <- paste0("MP", new_num)
  
  # Create the new filename
  new_file <- gsub(mp_number, new_mp_number, file)
  
  # Report the change
  cat("Converting:", file, "→", new_file, "\n")
  
  # Read the file content
  content <- readLines(file)
  
  # Update references within the file content
  for (i in 1:length(content)) {
    # Update any references to MP##
    content[i] <- gsub("MP(\\d{1,2})([^0-9])", "MP00\\1\\2", content[i])
    content[i] <- gsub("MP0(\\d{2})([^0-9])", "MP0\\1\\2", content[i])
    
    # Update ID in YAML frontmatter if present
    if (grepl("^id:", content[i])) {
      content[i] <- gsub("\"MP(\\d{1,2})\"", "\"MP00\\1\"", content[i])
      content[i] <- gsub("\"MP0(\\d{2})\"", "\"MP0\\1\"", content[i])
    }
  }
  
  # Write the updated content to the new file
  writeLines(content, new_file)
  
  # Remove the old file (only after successfully creating the new one)
  if (file.exists(new_file)) {
    file.remove(file)
  }
}

cat("\nVerifying results...\n")
system("ls -la MP*.md | wc -l")
system("ls -la MP*.md | head -5")

cat("\nThree-digit conversion completed.\n")