# db_paths.R --- auto-generated database path definitions
# 透過 APP_DIR 常數組合完整路徑。
# 載入後將建立：
#   • db_path_list (list)
#   • 同名個別常數 (app_data, raw_data, ...)
# 可由 sc_Rprofile.R 自動 source。

# 確保 APP_DIR 已定義
if (!exists("APP_DIR")) stop("APP_DIR is not defined when sourcing db_paths.R")

db_path_list <- list(
  app_data        = file.path(APP_DIR, "data", "app_data", "app_data.duckdb"),
  raw_data        = file.path(APP_DIR, "data", "local_data", "raw_data.duckdb"),
  staged_data      = file.path(APP_DIR, "data", "local_data", "staged_data.duckdb"),
  cleansed_data   = file.path(APP_DIR, "data", "local_data", "cleansed_data.duckdb"),
  transformed_data = file.path(APP_DIR, "data", "local_data", "transformed_data.duckdb"),
  processed_data = file.path(APP_DIR, "data", "local_data", "processed_data.duckdb"),
  meta_data = file.path(APP_DIR, "data", "local_data", "meta_data.duckdb"),
  comment_property_rating = file.path(APP_DIR, "data", "local_data","scd_type1", "comment_property_rating.duckdb"),
  comment_property_rating_temp = file.path(APP_DIR, "data", "local_data","scd_type1", "comment_property_rating_temp.duckdb"),
  comment_property_rating_results = file.path(APP_DIR, "data", "local_data","scd_type2", "comment_property_rating_results.duckdb")
)

# 同步整份清單到 .GlobalEnv 方便後續使用
assign("db_path_list", db_path_list, envir = .GlobalEnv) 