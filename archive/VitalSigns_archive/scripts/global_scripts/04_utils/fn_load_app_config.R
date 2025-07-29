#' Load App configsuration from YAML File and Parameter Directory
#'
#' This function loads application configsuration from a YAML file and 
#' sets up brand-specific parameters in the global environment.
#' It also dynamically loads all .xlsx files from the app_data/parameters directory
#' and makes them available as global variables.
#'
#' @param config_path Character string. Path to the YAML configsuration file.
#' @param parameters_dir Character string. Path to the parameters directory.
#' @param verbose Logical. Whether to display verbose loading messages.
#' @param configs List. Optional pre-loaded configsuration (to avoid reading from file).
#' @param load_parameters Logical. Whether to load parameter files. Default: TRUE.
#'
#' @return List containing the loaded configsuration.
#'
#' @examples
#' configs <- load_app_configs("app_configs.yaml")

load_app_configs <- function(
    config_path     = NULL,
    parameters_dir  = NULL,          # ← 改成 NULL
    verbose         = FALSE,
    configs          = NULL,
    load_parameters = TRUE
) {
  ## 0) 依賴 ------------------------------------------------------------
  for (pkg in c("yaml", "readxl", "dplyr", "rlang", "fs"))
    if (!requireNamespace(pkg, quietly = TRUE))
      stop("Please install \"", pkg, "\".", call. = FALSE)
  
  ## 1) 解析 config_path -----------------------------------------------
  if (is.null(config_path)) {
    if (exists("CONFIG_PATH", inherits = TRUE)) {
      config_path <- get("CONFIG_PATH", inherits = TRUE)
      if (verbose) message("Using config_path = ", config_path)
    } else {
      rlang::abort("config_path is not defined and `config_path` is NULL.",
                   class = "missing_config_path")
    }
  }
  
  ## 2) 讀 YAML ---------------------------------------------------------
  if (is.null(configs)) {
    if (!file.exists(config_path))
      stop("configs file not found: ", config_path, call. = FALSE)
    assign("app_configs", yaml::read_yaml(config_path, eval.expr = FALSE), envir = .GlobalEnv)
  }
  
  #### 路徑設定
  assign("RAW_DATA_DIR", app_configs$RAW_DATA_DIR, envir = .GlobalEnv)
  
  ## 3) 解析 parameters_dir --------------------------------------------
  if (is.null(parameters_dir)) {
    #   ─→ 組預設向量：GLOBAL_PARAMETER_DIR + APP_PARAMETER_DIR
    parameters_dir <- c(
      get0("GLOBAL_PARAMETER_DIR", ifnotfound = NA_character_, inherits = TRUE),
      get0("APP_PARAMETER_DIR",    ifnotfound = NA_character_, inherits = TRUE)
    )
    parameters_dir <- parameters_dir[!is.na(parameters_dir)]
    if (verbose)
      message("Default parameters_dir = ",
              paste(parameters_dir, collapse = ", "))
    if (!length(parameters_dir))
      warning("No parameter directories defined.")
  }
  
  # brand 設定可覆蓋預設
  # if (!is.null(configs$brand$parameters_folder)&!configs$brand$parameters_folder=="default"){
  #   parameters_dir <- configs$brand$parameters_folder
  # }
  
  if (!is.character(parameters_dir)){
    stop("`parameters_dir` must be character vector.", call. = FALSE)
  }
  
  # 移除不存在
  ok <- dir.exists(parameters_dir)
  if (any(!ok)) {
    warning("Skipped non-existent dir(s): ",
            paste(parameters_dir[!ok], collapse = ", "))
  }
  parameters_dir <- parameters_dir[ok]
  
  # 4. 載入 .csv 參數檔 ----------------------------------------------
  if (load_parameters && length(parameters_dir)) {
    
    # (1) 遞迴收集所有 .csv
    param_files <- unlist(lapply(parameters_dir, fs::dir_ls,
                                 recurse = TRUE,
                                 glob    = "*.csv",      # ★ 改這裡
                                 type    = "file"))
    # 忽略暫存檔
    param_files <- param_files[!grepl("^~\\$", basename(param_files))]
    
    # (2) 重名檔：後覆蓋前
    param_files <- param_files[!duplicated(basename(param_files), fromLast = TRUE)]
    
    # (3) 逐檔讀取
    for (fp in param_files) {
      nm <- tools::file_path_sans_ext(basename(fp))
      tryCatch({
        tbl <- readr::read_csv(fp, show_col_types = FALSE)   # ★ 改這裡
        print(tbl)
        assign(paste0(nm), tbl, envir = .GlobalEnv)
        
      }, error = function(e) {
        warning("Failed to load ", nm, ": ", e$message)
      })
    }
  }
  
  invisible(configs)
}
