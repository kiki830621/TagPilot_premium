#' @file fn_dbDisconnect_all.R
#' @use_package DBI
#' @note Depends 02_db_utils/fn_dbConnect_from_list.R
#' @note Implements MP080 (Database Synchronization)
#'
#' @title Disconnect All Database Connections — Export-Replace (No-Extension, v3.2)
#'
#' @description
#' 關閉全域 DBI 連線。對 DuckDB 連線：
#' 1. 先嘗試 `EXPORT DATABASE … (FORMAT duckdb)`（若版本支援且 build 內含 copy-function）。
#' 2. 若失敗或 DuckDB < 0.9，改用
#'    `ATTACH <tmp> AS <alias>; COPY FROM DATABASE <src> TO <alias>; DETACH <alias>;`。
#'    - `src` 由 `PRAGMA database_list;` 取得，`alias` 為隨機 `db_XXXXXXXX`。
#'
#' 匯出成功後，以 `file.rename()` 取代舊檔；可選擇是否保留備份及舊 `.wal`。
#' 若連線為唯讀模式，將僅斷線而不進行匯出/複製。
#'
#' @param verbose        顯示進度 (TRUE)
#' @param remove_vars    斷線後移除變數 (TRUE)
#' @param create_backups 建立備份 (TRUE)
#' @param keep_backups   覆蓋成功後保留備份？(FALSE)
#' @param cleanup_wal    刪除舊 `.wal`？(TRUE)
#' @param backup_suffix  備份後綴字串 ("_bak")
#' @param export_dir     暫存匯出資料夾 (`tempdir()`)
#' @return Integer — 成功斷開的連線數。
#'
#' @export

.duckdb_supports_export <- function() {
  ver <- tryCatch(numeric_version(duckdb::duckdb_version()), error = function(e) "0.0.0")
  ver >= "0.9.0"
}

.get_catalog_name <- function(con) {
  res <- DBI::dbGetQuery(con, "PRAGMA database_list;")
  if (nrow(res)) res$name[1] else "memory"
}

.random_alias <- function() paste0("db_", substr(gsub("-", "", uuid::UUIDgenerate()), 1, 8))

# Define null-coalescing operator if not already available
if (!exists("%||%")) {
  `%||%` <- function(a, b) if (is.null(a)) b else a
}

# main -------------------------------------------------------------------------
dbDisconnect_all <- function(verbose        = TRUE,
                             remove_vars    = TRUE,
                             create_backups = TRUE,
                             keep_backups   = FALSE,
                             cleanup_wal    = TRUE,
                             backup_suffix  = "_bak",
                             export_dir     = tempdir()) {
  dir.create(export_dir, showWarnings = FALSE, recursive = TRUE)
  objs <- ls(envir = .GlobalEnv)
  ok_n <- fail_n <- 0L
  export_supported <- .duckdb_supports_export()
  
  for (nm in objs) {
    if (nm == "db_path_list" || startsWith(nm, ".")) next
    
    con <- tryCatch(get(nm, .GlobalEnv), error = function(e) NULL)
    if (is.null(con) || !inherits(con, "DBIConnection") || !DBI::dbIsValid(con)) next
    
    is_duck <- inherits(con, "duckdb_connection")
    db_path <- if (is_duck) DBI::dbGetInfo(con)$dbname else NA_character_
    export_success <- !is_duck
    bak <- NULL
    read_only <- FALSE
    if (is_duck) {
      read_only <- tryCatch({
        isTRUE(con@driver@read_only)
      }, error = function(e) FALSE)
    }

    if (is_duck && !is.na(db_path) && !read_only) {
      tmp <- file.path(export_dir, paste0(tools::file_path_sans_ext(basename(db_path)), "_export.duckdb"))
      if (file.exists(tmp)) file.remove(tmp)
      
      # 1️⃣ EXPORT DATABASE
      if (export_supported) {
        sql <- sprintf("EXPORT DATABASE '%s' (FORMAT duckdb);", tmp)
        export_success <- tryCatch({DBI::dbExecute(con, sql); TRUE}, error = function(e) {
          if (verbose) message("EXPORT DATABASE 失敗: ", e$message)
          FALSE
        })
      }
      # 2️⃣ fallback COPY
      if (!export_success) {
        alias <- .random_alias()
        src   <- DBI::dbQuoteIdentifier(con, .get_catalog_name(con))
        sql <- sprintf(
          "DETACH DATABASE IF EXISTS %s; ATTACH '%s' AS %s; COPY FROM DATABASE %s TO %s; DETACH DATABASE %s;",
          alias, tmp, alias, src, alias, alias)
        export_success <- tryCatch({DBI::dbExecute(con, sql); TRUE}, error = function(e) {
          if (verbose) message("COPY FROM DATABASE 失敗: ", e$message)
          FALSE
        })
      }
      if (!export_success && verbose) warning("無法匯出 '", nm, "'，已跳過取代流程")
    } else if (is_duck && read_only) {
      export_success <- TRUE
      if (verbose) message("'", nm, "' 為唯讀連線，略過匯出/複製程序")
    }
    
    # 斷線 --------------------------------------------------------------------
    tryCatch(DBI::dbDisconnect(con), error = function(e) NULL)
    
    # 取代 & 清理 -------------------------------------------------------------
    if (is_duck && export_success && !read_only && !is.null(tmp) && file.exists(tmp)) {
      if (create_backups) {
        bak <- paste0(db_path, backup_suffix, format(Sys.time(), "%Y%m%d_%H%M%S"))
        file.copy(db_path, bak, overwrite = FALSE)
        if (verbose) message("備份至 ", bak)
      }
      file.rename(tmp, db_path)
      if (verbose) message("已以匯出檔取代: ", basename(db_path))
      
      # 刪備份
      if (!keep_backups && !is.null(bak) && file.exists(bak)) {
        file.remove(bak)
        if (verbose) message("已刪除備份檔: ", basename(bak))
      }
      # 刪舊 WAL
      if (cleanup_wal) {
        old_wal <- sub("\\.duckdb$", ".duckdb.wal", bak %||% db_path)
        if (file.exists(old_wal)) {
          file.remove(old_wal)
          if (verbose) message("已刪除舊 WAL: ", basename(old_wal))
        }
      }
    }
    
    # tally -------------------------------------------------------------------
    if (export_success) {
      ok_n <- ok_n + 1L
      if (remove_vars) rm(list = nm, envir = .GlobalEnv)
    } else {
      fail_n <- fail_n + 1L
    }
  }
  
  if (verbose) message("成功斷開 ", ok_n, " 個；失敗 ", fail_n, " 個。")
  invisible(ok_n)
}
