# ============================================================================
# InsightForge 資料庫連接模組
# ============================================================================

# ── 資料庫連接函數 ──────────────────────────────────────────────────────────
get_con <- function() {
  con <- NULL  # 先宣告在外層
  # 嘗試載入配置
  tryCatch({
    db_config <- get_config("db")
    
    # 檢查是否有 PostgreSQL 配置
    if (!is.null(db_config$host) && nzchar(db_config$host)) {
      cat("🔗 嘗試連接 PostgreSQL 資料庫...\n")
      
      con <<- dbConnect(
        RPostgres::Postgres(),
        host     = db_config$host,
        port     = db_config$port,
        user     = db_config$user,
        password = db_config$password,
        dbname   = db_config$dbname,
        sslmode  = db_config$sslmode
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
    con <<- dbConnect(RSQLite::SQLite(), "database/insightforge_test.db")
    cat("✅ SQLite 測試資料庫連接成功\n")
  })
  
  # ➊ 建表（若不存在）- 根據資料庫類型使用不同語法
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
    # 創建測試管理員用戶 (密碼: admin123)
    dbExecute(con, "
      INSERT INTO users (username, hash, role, login_count) 
      VALUES (?, ?, 'admin', 0)
    ", list("admin", bcrypt::hashpw("admin123")))
    
    # 創建測試一般用戶 (密碼: user123)
    dbExecute(con, "
      INSERT INTO users (username, hash, role, login_count) 
      VALUES (?, ?, 'user', 0)
    ", list("testuser", bcrypt::hashpw("user123")))
    
    cat("✅ 測試用戶創建完成\n")
    cat("   管理員: admin / admin123\n")
    cat("   一般用戶: testuser / user123\n")
  }
  
  return(con)
}

# ── 資料庫測試函數 ──────────────────────────────────────────────────────────
test_db_connection <- function() {
  tryCatch({
    con <- get_con()
    
    # 測試基本查詢
    result <- dbGetQuery(con, "SELECT 1 as test")
    
    # 檢查表格是否存在 (根據資料庫類型)
    if (inherits(con, "SQLiteConnection")) {
      tables <- dbGetQuery(con, "
        SELECT name as table_name 
        FROM sqlite_master 
        WHERE type='table' 
        AND name IN ('users', 'rawdata', 'processed_data', 'salesdata')
      ")
    } else {
      tables <- dbGetQuery(con, "
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name IN ('users', 'rawdata', 'processed_data', 'salesdata')
      ")
    }
    
    # 檢查用戶數量
    user_count <- dbGetQuery(con, "SELECT COUNT(*) as count FROM users")
    
    dbDisconnect(con)
    
    list(
      success = TRUE,
      message = paste("✅ 資料庫連接成功，找到", nrow(tables), "個表格，", user_count$count, "個用戶"),
      tables = tables$table_name
    )
  }, error = function(e) {
    list(
      success = FALSE,
      message = paste("❌ 資料庫連接失敗:", e$message)
    )
  })
}

# ── 檢查資料庫配置 ──────────────────────────────────────────────────────────
check_db_config <- function() {
  # 檢查是否能正常連接
  result <- test_db_connection()
  return(result)
} 