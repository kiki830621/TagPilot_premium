# Main Precision Marketing Application
# Configuration loaded from YAML file in app_configs directory
# Following Platform-Neutral Code, Data Source Hierarchy, and YAML Configuration Principles

# 檢查是否已經初始化，避免重複載入
if (exists("INITIALIZATION_COMPLETED") && INITIALIZATION_COMPLETED) {
  message("Initialization already completed. Skipping.")
  return(invisible(NULL))
}

# Initialize environment - reset if needed
if(exists("INITIALIZATION_COMPLETED")) {
  # Reset initialization flags to allow re-initialization
  rm(INITIALIZATION_COMPLETED, envir = .GlobalEnv)
}

# *** IMPORTANT: Set operation mode explicitly and ensure it isn't overridden ***
OPERATION_MODE <- "UPDATE_MODE"
ACCELERATION_LEVEL <- 0
assign("OPERATION_MODE", "UPDATE_MODE", envir = .GlobalEnv)
message("Running in UPDATE_MODE - Development Environment")

# 設定初始化標誌
INITIALIZATION_IN_PROGRESS <- TRUE

# lock on
# Constants 
ROOT_DIR<- getwd()
COMPANY_DIR<- dirname(ROOT_DIR)
APP_DIR<- file.path(ROOT_DIR, "precision_marketing_app")
GLOBAL_DIR <- file.path(APP_DIR, "update_scripts", "global_scripts")

# 設定是否顯示詳細載入信息
if(!exists("VERBOSE_INITIALIZATION")) {
  VERBOSE_INITIALIZATION <- FALSE # 默認為不詳細顯示
}


source(file.path("update_scripts", "global_scripts", "04_utils", "fn_source_with_verbose.R"))
source_with_verbose(file.path("update_scripts", "global_scripts", "04_utils", "fn_library2.R"))
source_with_verbose(file.path("update_scripts", "global_scripts", "04_utils", "fn_initialize_packages.R"))

# Initialize all required packages
initialize_packages(
  mode = OPERATION_MODE,
  verbose = VERBOSE_INITIALIZATION,
  force_update = FALSE
)


# lock off



#------------------------------
# 直接載入根路徑配置
SKIP_WRITE_ROOT_PATH <- TRUE
source_with_verbose(file.path("update_scripts", "global_scripts", "00_principles", "fn_root_path_config.R"))

# 載入 bslib 命名空間並確保其所有功能可用
page_navbar <- bslib::page_navbar
bs_theme <- bslib::bs_theme
layout_column_wrap <- bslib::layout_column_wrap
layout_columns <- bslib::layout_columns
nav_panel <- bslib::nav_panel
card <- bslib::card
card_body <- bslib::card_body
value_box <- bslib::value_box
navbar_options <- bslib::navbar_options
bs_icon <- function(name) { 
  shiny::icon(name)
}





##################################################
# 1. 載入全域腳本 (Global Scripts)
##################################################

# 設定全域腳本所在的資料夾路徑 (存放於 "update_scripts/global_scripts")
Func_dir <- file.path("update_scripts", "global_scripts")

# 定義有序的目錄列表，按照載入順序排列
ordered_directories <- c(
  "14_sql_utils",   # 首先載入 SQL 工具函數
  "02_db_utils",    # 然後載入資料庫連接工具
  "04_utils",       # 接著載入通用工具函數
  "03_config",      # 載入配置文件
  "01_db",          # 載入數據庫表定義
  "06_queries",     # 載入查詢功能
  "05_data_processing", # 載入數據處理功能
  "07_models",      # 載入模型
  "08_ai",          # 載入 AI 組件
  "09_python_scripts", # 載入 Python 腳本接口
  "10_rshinyapp_components", # 載入 Shiny 應用組件
  "11_rshinyapp_utils",   # 載入 Shiny 工具函數
  "17_transform"    # 載入轉換函數
)

# 跟踪已加載的文件，以避免重複加載
loaded_files <- c()
failed_files <- c()

source(file.path("update_scripts", "global_scripts", "04_utils","fn_get_r_files_recursive.R"))

# 依序載入每個目錄中的腳本
for (dir_name in ordered_directories) {
  dir_path <- file.path(Func_dir, dir_name)
  
  # 檢查目錄是否存在
  if (dir.exists(dir_path)) {
    # 獲取目錄及其子目錄中所有 .R 文件
    r_files <- get_r_files_recursive(dir_path)
    
    # 如果目錄不為空，輸出載入信息
    if (length(r_files) > 0) {
      message(paste("Loading scripts from", dir_name, "..."))
      
      # 排序文件以確保按照數字順序載入
      r_files <- sort(r_files)
      
      # 依序載入每個文件
      for (file in r_files) {
        # 只載入未載入過的文件
        if (!file %in% loaded_files) {
          success <- source_with_verbose(file)
          if (success) {
            loaded_files <- c(loaded_files, file)
          } else {
            failed_files <- c(failed_files, file)
          }
        }
      }
    }
  }
}

# Create the mandatory db_path_list global variable
db_path_list <<- get_default_db_paths()
message("Database paths initialized")


# Verify database functions are ready
if (exists("db_path_list") && exists("dbConnect_from_list")) {
  message("*** Database connection system initialized successfully ***")
  message("Available databases: ", paste(names(db_path_list), collapse=", "))
  message("You can now use: dbConnect_from_list(\"raw_data\")")
} else {
  message("!!! WARNING: Database initialization incomplete !!!")
}

# List available transform functions
transform_functions <- ls(pattern = "^transform_")
if (length(transform_functions) > 0) {
  message("*** Transform functions available: ***")
  for (fn in transform_functions) {
    message("- ", fn)
  }
} else {
  message("No transform functions found")
}

# 標記初始化完成
DB_INITIALIZATION_COMPLETED <- TRUE
INITIALIZATION_COMPLETED <- TRUE

# 顯示載入統計
message(paste("Initialization completed. Successfully loaded", 
              length(loaded_files), "files."))

# 如果有失敗的文件，顯示這些文件
if (length(failed_files) > 0) {
  message(paste("WARNING:", length(failed_files), "files failed to load."))
  if (VERBOSE_INITIALIZATION) {
    message("Failed files:")
    for (file in failed_files) {
      message(paste(" -", file))
    }
  } else {
    message("Set VERBOSE_INITIALIZATION <- TRUE for detailed loading information.")
  }
}

# Final confirmation
message("Initialization completed - database functions ready for use")

