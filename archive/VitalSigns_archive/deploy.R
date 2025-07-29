#!/usr/bin/env Rscript

# ============================================================================
# InsightForge 部署腳本
# 用途：將指定版本的應用程式複製到根目錄作為 app.R
# 使用方法：Rscript deploy.R [版本號]
# 範例：Rscript deploy.R v17
# ============================================================================

# 獲取命令列參數
args <- commandArgs(trailingOnly = TRUE)

# 預設使用最新版本
version <- if (length(args) > 0) args[1] else "v17"

# 檢查版本檔案是否存在
app_file <- paste0("app/app_", version, ".R")

if (!file.exists(app_file)) {
  cat("❌ 錯誤：找不到版本", version, "\n")
  cat("📁 可用版本：\n")
  app_files <- list.files("app", pattern = "^app_v.*\\.R$", full.names = FALSE)
  for (file in app_files) {
    cat("   -", gsub("app_|\\.R", "", file), "\n")
  }
  quit(status = 1)
}

# 備份現有的 app.R（如果存在）
if (file.exists("app.R")) {
  backup_name <- paste0("app_backup_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".R")
  file.copy("app.R", backup_name)
  cat("💾 已備份現有 app.R 為：", backup_name, "\n")
}

# 複製指定版本到根目錄
file.copy(app_file, "app.R", overwrite = TRUE)

cat("✅ 部署完成！\n")
cat("📦 已部署版本：", version, "\n")
cat("📄 源檔案：", app_file, "\n")
cat("🎯 目標檔案：app.R\n")
cat("\n")
cat("🚀 現在可以執行以下命令啟動應用：\n")
cat("   R -e \"shiny::runApp()\"\n")
cat("   或\n")
cat("   Rscript app.R\n")
cat("\n")
cat("🧪 建議先執行配置測試：\n")
cat("   Rscript tests/test_config.R\n") 