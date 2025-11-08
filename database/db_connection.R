# ============================================================================
# InsightForge 資料庫連接模組
# ============================================================================

# ── 資料庫連接函數 ──────────────────────────────────────────────────────────
get_con <- function() {
  con <- NULL
  db_type <- NULL
  db_info <- NULL

  tryCatch({
    db_config <- get_config("db")

    # 檢查是否有 PostgreSQL 配置
    if (!is.null(db_config$host) && nzchar(db_config$host)) {
      cat("🔗 嘗試連接 PostgreSQL 資料庫...\n")

      con <- dbConnect(
        RPostgres::Postgres(),
        host     = db_config$host,
        port     = db_config$port,
        user     = db_config$user,
        password = db_config$password,
        dbname   = db_config$dbname,
        sslmode  = db_config$sslmode
      )

      db_type <- "PostgreSQL"
      db_info <- list(
        type = "PostgreSQL",
        host = db_config$host,
        port = db_config$port,
        dbname = db_config$dbname,
        icon = "🐘",
        color = "#336791",
        status = "正式環境"
      )

      cat("✅ PostgreSQL 連接成功\n")
    } else {
      stop("無 PostgreSQL 配置，切換到 SQLite")
    }
  }, error = function(e) {
    cat("⚠️ PostgreSQL 連接失敗，切換到 SQLite 本地測試模式\n")
    cat("錯誤訊息:", e$message, "\n")

    # 確保 database 目錄存在
    if (!dir.exists("database")) {
      dir.create("database", recursive = TRUE)
    }

    # 使用 SQLite 作為後備
    con <- dbConnect(RSQLite::SQLite(), "database/tagpilot_test.db")

    db_type <- "SQLite"
    db_info <- list(
      type = "SQLite",
      path = "database/tagpilot_test.db",
      icon = "📁",
      color = "#FF8C00",
      status = "本地測試"
    )

    cat("✅ SQLite 測試資料庫連接成功\n")
  })

  # 檢查連接是否成功
  if (is.null(con)) {
    stop("資料庫連接失敗")
  }

  # 儲存資料庫資訊
  attr(con, "db_info") <- db_info
  return(con)
}

# ── 初始化資料表（登入後執行）────────────────────────────────────────────
init_tables <- function(con) {
  # 根據資料庫類型使用不同語法
  if (inherits(con, "SQLiteConnection")) {
    # SQLite 語法
    dbExecute(con, "
      CREATE TABLE IF NOT EXISTS users (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        username     TEXT UNIQUE,
        hash         TEXT,
        role         TEXT DEFAULT 'user',
        login_count  INTEGER DEFAULT 0
      );
    ")

    dbExecute(con, "
      CREATE TABLE IF NOT EXISTS rawdata (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id      INTEGER,
        uploaded_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
        json         TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      );
    ")

    dbExecute(con, "
      CREATE TABLE IF NOT EXISTS processed_data (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id       INTEGER,
        processed_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
        json          TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      );
    ")

    # 銷售資料表
    dbExecute(con, "CREATE TABLE IF NOT EXISTS salesdata (
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      uploaded_at TEXT,
      json TEXT
    )")
  } else {
    # PostgreSQL 語法
    dbExecute(con, "
      CREATE TABLE IF NOT EXISTS users (
        id           SERIAL PRIMARY KEY,
        username     TEXT UNIQUE,
        hash         TEXT,
        role         TEXT DEFAULT 'user',
        login_count  INTEGER DEFAULT 0
      );
    ")

    dbExecute(con, "
      CREATE TABLE IF NOT EXISTS rawdata (
        id           SERIAL PRIMARY KEY,
        user_id      INTEGER REFERENCES users(id),
        uploaded_at  TIMESTAMPTZ DEFAULT now(),
        json         JSONB
      );
    ")

    dbExecute(con, "
      CREATE TABLE IF NOT EXISTS processed_data (
        id            SERIAL PRIMARY KEY,
        user_id       INTEGER REFERENCES users(id),
        processed_at  TIMESTAMPTZ DEFAULT now(),
        json          JSONB
      );
    ")

    # 銷售資料表
    dbExecute(con, "CREATE TABLE IF NOT EXISTS salesdata (
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      uploaded_at TIMESTAMPTZ DEFAULT now(),
      json JSONB
    )")
  }

  # 檢查是否有測試用戶，沒有則創建
  existing_users <- dbGetQuery(con, "SELECT COUNT(*) as count FROM users")
  if (existing_users$count == 0) {
    cat("📝 創建測試用戶...\n")
    # 創建測試管理員用戶 (密碼: 12345)
    if (inherits(con, "SQLiteConnection")) {
      dbExecute(con, "
        INSERT INTO users (username, hash, role, login_count)
        VALUES ('admin', ?, 'admin', 0)
      ", list(bcrypt::hashpw("12345")))

      dbExecute(con, "
        INSERT INTO users (username, hash, role, login_count)
        VALUES ('testuser', ?, 'user', 0)
      ", list(bcrypt::hashpw("user123")))
    } else {
      dbExecute(con, "
        INSERT INTO users (username, hash, role, login_count)
        VALUES ($1, $2, 'admin', 0)
      ", list("admin", bcrypt::hashpw("12345")))

      dbExecute(con, "
        INSERT INTO users (username, hash, role, login_count)
        VALUES ($1, $2, 'user', 0)
      ", list("testuser", bcrypt::hashpw("user123")))
    }

    cat("✅ 測試用戶創建完成\n")
    cat("   管理員: admin / 12345\n")
    cat("   一般用戶: testuser / user123\n")
  }

  cat("✅ 資料表初始化完成\n")
  return(TRUE)
}

# ── 取得資料庫資訊 ────────────────────────────────────────────────────────
get_db_info <- function(con) {
  attr(con, "db_info")
}

# ── 資料庫查詢函數 ────────────────────────────────────────────────────────
db_query <- function(query, params = NULL, con = NULL) {
  need_disconnect <- FALSE
  if (is.null(con)) {
    con <- get_con()
    need_disconnect <- TRUE
  }

  tryCatch({
    # 如果是PostgreSQL且查詢包含?參數，需要轉換
    if (inherits(con, "PqConnection") && !is.null(params) && grepl("\\?", query)) {
      # 使用正則表達式逐個替換?為$1, $2, $3...
      param_count <- 1
      while (grepl("\\?", query)) {
        query <- sub("\\?", paste0("$", param_count), query)
        param_count <- param_count + 1
      }
    }

    if (is.null(params)) {
      result <- dbGetQuery(con, query)
    } else {
      result <- dbGetQuery(con, query, params)
    }

    return(result)
  }, error = function(e) {
    stop("資料庫查詢錯誤: ", e$message)
  }, finally = {
    if (need_disconnect && dbIsValid(con)) {
      dbDisconnect(con)
    }
  })
}

# ── 資料庫執行函數 ────────────────────────────────────────────────────────
db_execute <- function(statement, params = NULL, con = NULL) {
  need_disconnect <- FALSE
  if (is.null(con)) {
    con <- get_con()
    need_disconnect <- TRUE
  }

  tryCatch({
    # 如果是PostgreSQL且語句包含?參數，需要轉換
    if (inherits(con, "PqConnection") && !is.null(params) && grepl("\\?", statement)) {
      # 使用正則表達式逐個替換?為$1, $2, $3...
      param_count <- 1
      while (grepl("\\?", statement)) {
        statement <- sub("\\?", paste0("$", param_count), statement)
        param_count <- param_count + 1
      }
    }

    if (is.null(params)) {
      result <- dbExecute(con, statement)
    } else {
      result <- dbExecute(con, statement, params)
    }

    return(result)
  }, error = function(e) {
    stop("資料庫執行錯誤: ", e$message)
  }, finally = {
    if (need_disconnect && dbIsValid(con)) {
      dbDisconnect(con)
    }
  })
}

# ── NULL 合併運算子 ───────────────────────────────────────────────────────
`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0 || (is.character(x) && !nzchar(x))) y else x
} 