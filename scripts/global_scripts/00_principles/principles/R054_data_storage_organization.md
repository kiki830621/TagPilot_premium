# Rule 54: Data Storage Organization

## Core Rule
Data files must be organized by type and purpose in designated directories, with database files specifically stored in the `app_data` folder rather than in the application root directory.

## Implementation Guidelines

### Directory Structure
1. **Database Files**
   - All database files (including .db, .sqlite, .duckdb) MUST be stored in the `app_data` directory
   - Example: `app_data/app_data.duckdb` instead of `app_data.duckdb` in the root

2. **Data Type Separation**
   - Raw input data files → `app_data/raw/`
   - Processed intermediate files → `app_data/processed/`
   - Exported output files → `app_data/exports/`
   - Temporary working files → `app_data/temp/`
   - Cached results → `app_data/cache/`

3. **Backup Organization**
   - Database backups → `app_data/backups/db/`
   - Configuration backups → `app_data/backups/config/`
   - Use date-based naming: `app_data.duckdb.YYYY-MM-DD.bak`

### Naming Conventions
1. **Database Files**
   - Primary application database: `app_data.duckdb`
   - Test database: `test_data.duckdb`
   - Development database: `dev_data.duckdb`

2. **Data Files**
   - Use the format: `[purpose]_[source]_[date].[extension]`
   - Example: `customers_platform07_20250406.csv`

## Rationale
This organization provides several advantages:

1. **Logical Separation**: Keeps data files separate from application code
2. **Backup Simplicity**: Makes it easier to backup and restore data files
3. **Enhanced Security**: Simplifies access control for sensitive data
4. **Reduced Clutter**: Prevents root directory pollution
5. **Consistency**: Ensures all team members follow the same structure

## Practical Application

### Directory Creation
When initializing the application, ensure proper directory structure exists:

```r
create_data_directories <- function() {
  dirs <- c(
    "app_data",
    "app_data/raw", 
    "app_data/processed",
    "app_data/exports",
    "app_data/temp",
    "app_data/cache",
    "app_data/backups/db",
    "app_data/backups/config"
  )
  
  for (dir in dirs) {
    if (!dir.exists(dir)) {
      dir.create(dir, recursive = TRUE)
    }
  }
}
```

### Database Connection
Always use the correct paths when connecting to databases:

```r
connect_to_app_db <- function() {
  require(duckdb)
  # Correct: database in app_data directory
  con <- dbConnect(duckdb(), "app_data/app_data.duckdb")
  return(con)
}
```

### Data Import/Export
Reference the correct locations for input and output files:

```r
import_raw_data <- function(file_name) {
  # Correct: raw data stored in app_data/raw directory
  file_path <- file.path("app_data/raw", file_name)
  data <- read.csv(file_path)
  return(data)
}

export_processed_data <- function(data, file_name) {
  # Correct: exports stored in app_data/exports directory
  file_path <- file.path("app_data/exports", file_name)
  write.csv(data, file_path, row.names = FALSE)
}
```

## Enforcement
All scripts must adhere to this organization rule. During code reviews, check specifically for:

1. Database files in the root directory
2. Data files outside their appropriate directories
3. Inconsistent naming patterns

## Related Rules and Principles
- R0028_archiving_standard.md
- MP0016_modularity.md
- MP0017_separation_of_concerns.md
