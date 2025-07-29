#' loadAppConfig  -------------------------------------------------------------
#' 簡化版應用設定載入器。
#'
#' 1. 讀取 YAML 設定檔 → 回傳 list `cfg`。
#' 2. 遞迴掃描 `parameters_dir` 內所有 .csv 檔 → 讀成 `tibble` 嵌入 `cfg$parameters`。
#' 3. `attach = TRUE` 時，將 `cfg` 與每個參數表格賦值到 `.GlobalEnv`。
#'
#' 不再：
#' • 支援 readxl／rds／excel（如需可自行擴充）
#' • 動態安裝缺失套件 → 假設環境已安裝 yaml / readr / fs
#'
#' @param parameters_dir 參數目錄向量；預設 `c(GLOBAL_PARAMETER_DIR, APP_PARAMETER_DIR)`。
#' @param attach         Logical. 是否將結果附加至全域，預設 TRUE。
#' @param verbose        Logical. 是否列印載入訊息。
#'
#' @return List `cfg`，含 `$yaml` 與 `$parameters`。
#' @export
#' @importFrom yaml read_yaml
#' @importFrom readr read_csv
#' @importFrom fs dir_ls
load_app_configs <- function(parameters_dir = NULL,
                          attach = TRUE,
                          verbose = FALSE) {
  # ---- 路徑解析 -----------------------------------------------------------
  if (!exists("CONFIG_PATH", inherits = TRUE))
    stop("CONFIG_PATH constant is not defined in the environment")
  if (!file.exists(CONFIG_PATH)) stop("Config yaml not found: ", CONFIG_PATH)
  
  if (is.null(parameters_dir)) {
    parameters_dir <- c(
      get0("GLOBAL_PARAMETER_DIR", inherits = TRUE),
      get0("APP_PARAMETER_DIR",    inherits = TRUE)
    )
    parameters_dir <- parameters_dir[dir.exists(parameters_dir)]
  }
  
  # ---- 載入 YAML (含遞迴 overrides) --------------------------------------
  cfg <- yaml::read_yaml(CONFIG_PATH, eval.expr = FALSE)
  if (verbose) message("Loaded YAML: ", CONFIG_PATH)

  # 搜尋 parameters_dir 內 *.yaml / *.yml 作為覆寫檔
  yaml_overrides <- list()  # 收集檔名供 verbose 列印，不再存入 cfg
  if (length(parameters_dir)) {
    # Search for both .yaml and .yml files separately
    yaml_files <- c()
    for (dir in parameters_dir) {
      yaml_files <- c(yaml_files, 
                     fs::dir_ls(dir, recurse = TRUE, glob = "*.yaml", type = "file"),
                     fs::dir_ls(dir, recurse = TRUE, glob = "*.yml", type = "file"))
    }
    yaml_files <- yaml_files[!grepl("^~\\$", basename(yaml_files))]
    yaml_files <- yaml_files[!duplicated(basename(yaml_files), fromLast = TRUE)]

    # Helper  深度合併 list ------------------------------------------------
    deep_merge <- function(x, y) {
      for (nm in names(y)) {
        if (is.list(x[[nm]]) && is.list(y[[nm]])) {
          x[[nm]] <- Recall(x[[nm]], y[[nm]])
        } else {
          x[[nm]] <- y[[nm]]
        }
      }
      x
    }

    for (fp in yaml_files) {
      yml <- tryCatch(yaml::read_yaml(fp, eval.expr = FALSE),
                      error = function(e) { warning("Failed to read ", fp); NULL })
      if (!is.null(yml)) {
        yaml_name <- tools::file_path_sans_ext(basename(fp))
        yaml_overrides[[yaml_name]] <- yml
        cfg[[yaml_name]] <- yml  # Add directly to cfg first level
        cfg <- deep_merge(cfg, yml)  # Also merge for override behavior
        if (verbose) message("Merged YAML override: ", fp)
      }
    }
  }
  # 不再將 overrides 存入 cfg$yaml_overrides —— 已直接合併到 cfg 最外層
  
  # ---- 載入 CSV 參數 ------------------------------------------------------
  param_list <- list()
  if (length(parameters_dir)) {
    csv_files <- unlist(lapply(parameters_dir, fs::dir_ls, recurse = TRUE, glob = "*.csv", type = "file"))
    csv_files <- csv_files[!grepl("^~\\$", basename(csv_files))]  # skip temp files
    csv_files <- csv_files[!duplicated(basename(csv_files), fromLast = TRUE)]
    for (fp in csv_files) {
      nm <- tools::file_path_sans_ext(basename(fp))
      tbl <- tryCatch(readr::read_csv(fp, show_col_types = FALSE),
                      error = function(e) { warning("Failed to read ", fp); NULL })
      if (!is.null(tbl)) param_list[[nm]] <- tbl
    }

    # Also source any *.R scripts under parameters_dir ---------------------------------
    r_scripts <- unlist(lapply(parameters_dir, fs::dir_ls, recurse = TRUE, glob = "*.R", type = "file"))
    r_scripts <- r_scripts[!grepl("^~\\$", basename(r_scripts))]
    r_scripts <- r_scripts[!duplicated(basename(r_scripts), fromLast = TRUE)]
    for (fp in r_scripts) {
      if (verbose) message("Sourcing parameter script: ", fp)
      tryCatch(sys.source(fp, envir = .GlobalEnv),
               error = function(e) warning("Failed to source ", fp, ": ", e$message))
    }
 
    if (verbose) message("Loaded ", length(param_list), " parameter tables from ", length(parameters_dir), " dir(s)")
  }
  cfg$parameters <- param_list
  
  # ---- attach to global ---------------------------------------------------
  if (isTRUE(attach)) {
    assign("app_configs", cfg, envir = .GlobalEnv)
    
    # Attach CSV parameter tables to global environment
    for (nm in names(param_list)) assign(nm, param_list[[nm]], envir = .GlobalEnv)
    
    if (verbose && length(yaml_overrides)) {
      message("YAML files merged into app_configs: ", 
              paste(names(yaml_overrides), collapse = ", "))
    }
  }
  invisible(cfg)
}
