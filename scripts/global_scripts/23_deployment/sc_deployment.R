#!/usr/bin/env Rscript
# ============================================================================
# 一鍵部署腳本 - Positioning App
# 執行此腳本即可完成所有部署步驟
# ============================================================================

cat("\n")
cat("🚀 Positioning App 一鍵部署\n")
cat("============================\n")
cat("開始時間:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")

# 設定基礎路徑
if (basename(getwd()) != "positioning_app") {
  stop("❌ 請在 positioning_app 目錄下執行此腳本！")
}

DEPLOY_BASE <- "scripts/global_scripts/23_deployment"

# 步驟 1：部署前檢查
cat("步驟 1/4：執行部署前檢查\n")
cat("---------------------------\n")
source(file.path(DEPLOY_BASE, "01_checks/check_deployment_improved.R"))
cat("\n")

# 詢問是否繼續
cat("是否繼續部署？(yes/no): ")
response <- tolower(readline())
if (response != "yes" && response != "y") {
  cat("❌ 部署已取消\n")
  quit(status = 0)
}

# 步驟 2：確認 app.R 是最新版本
cat("\n步驟 2/4：檢查 app.R 版本\n")
cat("---------------------------\n")

# 檢查 app.R 和 full_app_v17.R 是否同步
if (file.exists("app.R") && file.exists("full_app_v17.R")) {
  app_content <- readLines("app.R", warn = FALSE)
  v17_content <- readLines("full_app_v17.R", warn = FALSE)
  
  if (!identical(app_content, v17_content)) {
    cat("⚠️  app.R 與 full_app_v17.R 不同步\n")
    cat("是否更新 app.R 到最新版本 (v17)？(yes/no): ")
    update_response <- tolower(readline())
    
    if (update_response == "yes" || update_response == "y") {
      source(file.path(DEPLOY_BASE, "04_update/update_to_latest.R"))
      cat("✅ app.R 已更新到最新版本\n")
    }
  } else {
    cat("✅ app.R 已是最新版本 (v17)\n")
  }
} else {
  cat("❌ 找不到必要檔案\n")
  quit(status = 1)
}

# 步驟 3：更新 manifest.json
cat("\n步驟 3/4：更新依賴清單\n")
cat("---------------------------\n")
cat("正在更新 manifest.json...\n")

tryCatch({
  library(rsconnect)
  rsconnect::writeManifest()
  cat("✅ manifest.json 已更新\n")
}, error = function(e) {
  cat("❌ 更新 manifest.json 失敗:", e$message, "\n")
  cat("請手動執行: rsconnect::writeManifest()\n")
})

# 步驟 4：選擇部署目標
cat("\n步驟 4/4：選擇部署方式\n")
cat("---------------------------\n")
cat("請選擇部署目標：\n")
cat("1. Posit Connect Cloud (GitHub 整合)\n")
cat("2. ShinyApps.io (直接部署)\n")
cat("3. 只準備檔案，不部署\n")
cat("\n請輸入選項 (1-3): ")

choice <- as.integer(readline())

if (choice == 1) {
  # Posit Connect Cloud
  cat("\n📱 Posit Connect Cloud 部署步驟：\n")
  cat("--------------------------------\n")
  cat("1. 確認 Git 已提交所有變更：\n")
  cat("   git add .\n")
  cat("   git commit -m 'Ready for deployment'\n")
  cat("   git push\n\n")
  
  cat("2. 登入 Posit Connect Cloud:\n")
  cat("   https://connect.posit.cloud\n\n")
  
  cat("3. 在網頁介面填寫：\n")
  cat("   - Repository: kiki830621/ai_martech\n")
  cat("   - Application Path: l1_basic/positioning_app\n")
  cat("   - Primary File: app.R\n")
  cat("   - Branch: main\n\n")
  
  cat("4. 設定環境變數（參考 .env 檔案）\n\n")
  
  # 顯示文檔連結
  cat("📄 詳細說明請參考：\n")
  cat(file.path(DEPLOY_BASE, "05_docs/POSIT_CONNECT_CLOUD_GITHUB_DEPLOYMENT.md"), "\n")
  
} else if (choice == 2) {
  # ShinyApps.io
  cat("\n📱 準備部署到 ShinyApps.io...\n")
  
  # 檢查 rsconnect 設定
  if (nrow(rsconnect::accounts()) == 0) {
    cat("❌ 尚未設定 ShinyApps.io 帳號\n")
    cat("請先執行：rsconnect::setAccountInfo(...)\n")
  } else {
    cat("確認要部署到 ShinyApps.io？(yes/no): ")
    deploy_confirm <- tolower(readline())
    
    if (deploy_confirm == "yes" || deploy_confirm == "y") {
      source(file.path(DEPLOY_BASE, "03_deploy/deploy_app.R"))
    } else {
      cat("❌ 部署已取消\n")
    }
  }
  
} else if (choice == 3) {
  # 只準備檔案
  cat("\n✅ 檔案準備完成！\n")
  cat("- app.R 已同步\n")
  cat("- manifest.json 已更新\n")
  cat("- 可以手動進行部署\n")
  
} else {
  cat("❌ 無效的選項\n")
}

# 完成
cat("\n============================\n")
cat("部署流程完成！\n")
cat("結束時間:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("============================\n") 