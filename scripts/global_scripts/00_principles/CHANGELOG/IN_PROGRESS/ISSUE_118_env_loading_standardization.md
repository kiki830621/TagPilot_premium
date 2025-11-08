# ISSUE 118: Environment Variables (.env) Loading Standardization

**狀態**: 🔄 進行中
**建立日期**: 2025-10-03
**預計完成**: 2025-10-03
**負責人**: Claude Code (principle-explorer + principle-coder)

---

## 問題描述

### 當前問題
Wonderful Food 專案群（l3_premium/wonderful_food/）中的三個應用程式使用了**不正確的 .env 載入方式**：

```r
# ❌ 錯誤方式 (wonderful_food 當前使用)
if (file.exists(".env")) {
  dotenv::load_dot_env(file = ".env")
  cat("📁 已載入 .env 配置檔\n")
} else if (file.exists("config/.env")) {
  dotenv::load_dot_env(file = "config/.env")
  cat("📁 已載入 config/.env 配置檔\n")
}
```

**問題點**：
1. ❌ 直接呼叫 `dotenv::load_dot_env()`，若套件未安裝會報錯
2. ❌ 沒有 fallback 機制（無法使用內建 `readRenviron`）
3. ❌ 沒有驗證關鍵環境變數
4. ❌ .env 位置不明確（兩個可能位置）
5. ❌ 錯誤訊息不清楚

### 正確方式（MAMBA 標準模式）

```r
# ✅ 正確方式 (MAMBA 標準模式)
env_file <- file.path(APP_DIR, ".env")
if (file.exists(env_file)) {
  # 優先使用 dotenv 套件
  if (requireNamespace("dotenv", quietly = TRUE)) {
    dotenv::load_dot_env(file = env_file)
    message("Environment variables loaded from .env using dotenv package")
  } else {
    # 備用方案：使用內建 readRenviron
    readRenviron(env_file)
    message("Environment variables loaded from .env using readRenviron")
  }

  # 驗證關鍵環境變數
  if (nzchar(Sys.getenv("OPENAI_API_KEY"))) {
    message("✓ OPENAI_API_KEY is set")
  } else {
    warning("⚠ OPENAI_API_KEY is not set - AI features will be disabled")
  }
} else {
  message("No .env file found in ", APP_DIR)
}
```

**優點**：
- ✅ 自動偵測 dotenv 是否可用
- ✅ 有備用方案（readRenviron）
- ✅ 驗證關鍵環境變數
- ✅ 清楚的訊息回饋
- ✅ 標準化位置（專案根目錄）

---

## 影響範圍

### 需要修改的檔案

1. **wonderful_food_BrandEdge_premium**
   - `config/config.R` (第 6-12 行)

2. **wonderful_food_InsightForge_premium**
   - `config/config.R` (第 6-12 行)

3. **wonderful_food_TagPilot_premium**
   - `config/config.R` (第 6-12 行)

### 不受影響的專案

所有使用 MAMBA 標準初始化的專案（l1_basic, l4_enterprise 等）已採用正確方式。

---

## 解決方案

### 方案設計

由於 wonderful_food 專案使用**簡單初始化**（直接在 app.R 載入，不使用 autoinit() + sc_initialization_app_mode.R），需要：

1. **建立通用函數**：`fn_load_env_file.R`
2. **放置位置**：`global_scripts/04_utils/fn_load_env_file.R`
3. **在 config.R 中呼叫**：替換現有的 .env 載入邏輯

### 函數設計

```r
# fn_load_env_file.R
#' Load Environment Variables from .env File
#'
#' @description
#' Loads environment variables from .env file with fallback mechanism.
#' Follows MAMBA standard pattern with dotenv package preference.
#'
#' @param app_dir Character. Project root directory. Default: current working directory
#' @param env_filename Character. Name of .env file. Default: ".env"
#' @param required_vars Character vector. Variables to verify. Default: c("OPENAI_API_KEY")
#' @param silent Logical. Suppress messages. Default: FALSE
#'
#' @return Invisible list with status and loaded variables
#'
#' @examples
#' # Basic usage
#' load_env_file()
#'
#' # Custom location
#' load_env_file(app_dir = "/path/to/project")
#'
#' # Verify multiple variables
#' load_env_file(required_vars = c("OPENAI_API_KEY", "PGHOST", "PGPASSWORD"))
#'
#' @export
load_env_file <- function(app_dir = getwd(),
                          env_filename = ".env",
                          required_vars = c("OPENAI_API_KEY"),
                          silent = FALSE) {

  env_file <- file.path(app_dir, env_filename)
  result <- list(success = FALSE, method = NULL, loaded_vars = character(0))

  if (!file.exists(env_file)) {
    if (!silent) message("ℹ No .env file found in ", app_dir)
    return(invisible(result))
  }

  # Try dotenv first, fallback to readRenviron
  if (requireNamespace("dotenv", quietly = TRUE)) {
    tryCatch({
      dotenv::load_dot_env(file = env_file)
      result$method <- "dotenv"
      result$success <- TRUE
      if (!silent) message("✅ Environment variables loaded from .env using dotenv package")
    }, error = function(e) {
      if (!silent) warning("Failed to load .env with dotenv: ", e$message)
    })
  }

  if (!result$success) {
    tryCatch({
      readRenviron(env_file)
      result$method <- "readRenviron"
      result$success <- TRUE
      if (!silent) message("✅ Environment variables loaded from .env using readRenviron")
    }, error = function(e) {
      if (!silent) warning("Failed to load .env with readRenviron: ", e$message)
    })
  }

  # Verify required variables
  if (result$success && length(required_vars) > 0) {
    for (var in required_vars) {
      value <- Sys.getenv(var)
      if (nzchar(value)) {
        result$loaded_vars <- c(result$loaded_vars, var)
        if (!silent) message("  ✓ ", var, " is set")
      } else {
        if (!silent) warning("  ⚠ ", var, " is not set")
      }
    }
  }

  return(invisible(result))
}
```

### 在 config.R 中使用

```r
# ============================================================================
# BrandEdge 旗艦版配置檔
# ============================================================================

# 載入環境變數（使用標準函數）
if (exists("load_env_file")) {
  load_env_file(
    app_dir = getwd(),
    required_vars = c("OPENAI_API_KEY", "PGHOST", "PGPASSWORD")
  )
} else {
  # Fallback: 如果函數未載入，使用簡化版本
  env_file <- file.path(getwd(), ".env")
  if (file.exists(env_file)) {
    if (requireNamespace("dotenv", quietly = TRUE)) {
      dotenv::load_dot_env(file = env_file)
      message("✅ Environment variables loaded from .env")
    } else {
      readRenviron(env_file)
      message("✅ Environment variables loaded from .env")
    }
  }
}

# ... 其餘配置 ...
```

---

## 實作步驟

### Phase 1: 建立通用函數
- [x] 建立 `global_scripts/04_utils/fn_load_env_file.R`
- [ ] 測試函數在 MAMBA 環境

### Phase 2: 修改 wonderful_food 專案
- [ ] 修改 `wonderful_food_BrandEdge_premium/config/config.R`
- [ ] 修改 `wonderful_food_InsightForge_premium/config/config.R`
- [ ] 修改 `wonderful_food_TagPilot_premium/config/config.R`

### Phase 3: 測試驗證
- [ ] 測試 BrandEdge 載入 .env
- [ ] 測試 InsightForge 載入 .env
- [ ] 測試 TagPilot 載入 .env
- [ ] 驗證環境變數正確讀取

### Phase 4: 建立 Principle
- [ ] 使用 `principle-revisor` 建立新 Principle
- [ ] 記錄 .env 載入標準模式
- [ ] 更新相關文檔

---

## 驗證方式

### 測試腳本

```r
# test_env_loading.R
source("scripts/global_scripts/04_utils/fn_load_env_file.R")

# Test 1: Basic loading
cat("\n=== Test 1: Basic Loading ===\n")
result <- load_env_file()
print(result)

# Test 2: Verify specific variables
cat("\n=== Test 2: Verify Variables ===\n")
result <- load_env_file(
  required_vars = c("OPENAI_API_KEY", "PGHOST", "PGPASSWORD")
)
print(result)

# Test 3: Silent mode
cat("\n=== Test 3: Silent Mode ===\n")
result <- load_env_file(silent = TRUE)
print(result)

# Verify actual values
cat("\n=== Verify Environment Variables ===\n")
cat("OPENAI_API_KEY:", nzchar(Sys.getenv("OPENAI_API_KEY")), "\n")
cat("PGHOST:", Sys.getenv("PGHOST"), "\n")
```

### 預期結果

```
=== Test 1: Basic Loading ===
✅ Environment variables loaded from .env using dotenv package
  ✓ OPENAI_API_KEY is set
$success
[1] TRUE

$method
[1] "dotenv"

$loaded_vars
[1] "OPENAI_API_KEY"

=== Test 2: Verify Variables ===
✅ Environment variables loaded from .env using dotenv package
  ✓ OPENAI_API_KEY is set
  ✓ PGHOST is set
  ✓ PGPASSWORD is set
...

=== Verify Environment Variables ===
OPENAI_API_KEY: TRUE
PGHOST: your_host
```

---

## 相關 Principles

完成此改進後，將建立以下 Principle：

### 候選編號

- **MP105**: Environment Variables Loading Standard
- **R118**: .env File Loading Pattern
- **DEV_P030**: Environment Configuration Management

### Principle 草稿

```markdown
# R118: .env File Loading Pattern

## Principle Statement

All applications MUST use the standardized `.env` file loading pattern with:
1. dotenv package as primary method
2. readRenviron as fallback
3. Required variables verification
4. Clear status messages

## Rationale

Ensures consistent and robust environment variable loading across all company projects.

## Implementation

Use `load_env_file()` function from `global_scripts/04_utils/fn_load_env_file.R`

## Examples

```r
# In config.R or app.R initialization
load_env_file(
  app_dir = getwd(),
  required_vars = c("OPENAI_API_KEY", "PGHOST")
)
```

## Related Principles

- MP011: Discrepancy Principle (ensure .env is loaded correctly)
- R092: Universal DBI Approach (database credentials from .env)
- Security principles (protect sensitive credentials)
```

---

## 備註

### 為何不統一使用 sc_initialization_app_mode.R？

**理由**：
1. **wonderful_food 使用簡單初始化**：不需要 autoinit() 的完整初始化流程
2. **保持靈活性**：l3_premium 層可能有客製化需求
3. **減少依賴**：不強制所有專案使用相同初始化模式

**解決方案**：
- 提供 `fn_load_env_file()` 通用函數
- 可在任何初始化模式中使用
- MAMBA 的 sc_initialization_app_mode.R 也可改用此函數（未來優化）

### .env 檔案位置標準

**統一規範**：.env 檔案**必須**放在專案根目錄

```
{tier}/{companyname}/
├── .env              ← 這裡！
├── .env.template     ← 範本
├── .gitignore        ← 確保 .env 被忽略
├── app.R
└── config/
    └── config.R      ← 在這裡呼叫 load_env_file()
```

**禁止**：
- ❌ `config/.env`
- ❌ `scripts/.env`
- ❌ 多個 .env 檔案

---

**最後更新**: 2025-10-03
**追蹤編號**: ISSUE-118
**下一步**: 建立 fn_load_env_file.R 函數
