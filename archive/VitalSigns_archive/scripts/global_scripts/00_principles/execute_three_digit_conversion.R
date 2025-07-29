#' Execute Three-Digit Indexing Conversion - April 15, 2025
#'
#' @description
#' This script converts all Meta Principle (MP) index numbers to a three-digit format
#' by adding leading zeros. For example, MP01 becomes MP001.
#'
#' @author Claude
#' @date 2025-04-15

# Set working directory to the 00_principles directory
principles_dir <- "/Users/che/Library/CloudStorage/Dropbox/precision_marketing/precision_marketing_WISER/precision_marketing_app/update_scripts/global_scripts/00_principles"
setwd(principles_dir)

# Load the renumbering module
source("M00_renumbering_principles/M00_fn_renumber_principles.R")

# Create backup directory if it doesn't exist
backup_dir <- "renumbering_backup"
if (!dir.exists(backup_dir)) {
  dir.create(backup_dir)
}

# Backup the entire directory before starting
timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
backup_cmd <- paste0("cp -r * ", backup_dir, "/backup_", timestamp)
system(backup_cmd)
cat("Created backup in:", paste0(backup_dir, "/backup_", timestamp), "\n")

# Get a list of all MP files
mp_files <- list.files(pattern = "^MP\\d+.*\\.md$")
cat("Found", length(mp_files), "MP files to convert.\n")

# Create mapping table
mappings <- list()
for (file in mp_files) {
  # Extract the MP number and name
  parts <- strsplit(file, "_")[[1]]
  mp_id <- parts[1]  # e.g., "MP01"
  
  # Extract just the number part
  num_part <- gsub("^MP", "", mp_id)  # e.g., "01"
  
  # Create the new three-digit ID
  new_num <- sprintf("%03d", as.numeric(num_part))  # e.g., "001"
  new_id <- paste0("MP", new_num)  # e.g., "MP001"
  
  # Get the rest of the filename (the name part)
  name_part <- paste(parts[-1], collapse = "_")  # e.g., "primitive_terms_and_definitions.md"
  name_part <- sub("\\.md$", "", name_part)  # Remove .md extension
  
  # Add to mappings
  mappings[[length(mappings) + 1]] <- list(
    old_id = mp_id,
    new_id = new_id,
    name = name_part
  )
}

# Convert the list to a data frame
mapping_table <- do.call(rbind.data.frame, lapply(mappings, function(x) {
  data.frame(old_id = x$old_id, new_id = x$new_id, name = x$name, stringsAsFactors = FALSE)
}))

# Display the mapping table
cat("\nMapping table created with", nrow(mapping_table), "entries:\n")
print(head(mapping_table, 10))
cat("...\n")

# Execute the batch renumbering
cat("\nExecuting batch renumbering...\n")
batch_results <- M00_renumbering_principles$batch_renumber(mapping_table)

if (!is.null(batch_results$success) && !batch_results$success) {
  cat("Error in batch renumbering:\n")
  print(batch_results$error)
  if (!is.null(batch_results$details)) {
    print(batch_results$details)
  }
  cat("Renumbering aborted. Check the error messages.\n")
  quit(status = 1)
}

# Verify the results
cat("\nVerifying system consistency...\n")
issues <- M00_renumbering_principles$verify()
if (is.null(issues)) {
  cat("System is consistent!\n")
} else {
  cat("Issues found in system consistency check:\n")
  print(issues)
  cat("Consider addressing these issues manually.\n")
}

cat("\nThree-digit conversion completed.\n")
cat("Results:\n")
system("ls -la MP*.md | sort")