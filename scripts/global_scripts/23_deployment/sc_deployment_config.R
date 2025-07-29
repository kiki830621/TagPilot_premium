#!/usr/bin/env Rscript
# ============================================================================
# 配置驅動的一鍵部署腳本
# 使用 app_config.yaml 進行配置
# ============================================================================

# 載入配置檔案
load_deployment_config <- function(config_file = "app_config.yaml") {
  if (!file.exists(config_file)) {
    # 如果沒有配置檔案，使用預設值
    cat("⚠️  找不到", config_file, "，使用預設配置\n")
    
    config <- list(
      app_info = list(
        name = basename(getwd()),
        description = "Shiny Application"
      ),
      deployment = list(
        github_repo = "kiki830621/ai_martech",
        app_path = paste("unknown", basename(getwd()), sep = "/"),
        main_file = "app.R",
        branch = "main",
        required_files = c("app.R", "manifest.json"),
        required_dirs = character(0),
        version_files = character(0),
        env_vars = character(0),
        special_instructions = ""
      )
    )
  } else {
    # 載入 YAML 配置
    if (!requireNamespace("yaml", quietly = TRUE)) {
      stop("需要安裝 yaml 套件: install.packages('yaml')")
    }
    
    config <- yaml::read_yaml(config_file)
    cat("✅ 載入配置檔案:", config_file, "\n")
  }
  
  return(config)
}

# 主部署函數
deploy_with_config <- function(config_file = "app_config.yaml", interactive = TRUE) {
  # 載入配置
  config <- load_deployment_config(config_file)
  
  cat("\n")
  cat("🚀", config$app_info$name, "一鍵部署\n")
  cat("============================\n")
  cat("描述:", config$app_info$description, "\n")
  cat("開始時間:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")
  
  # 步驟 1：顯示配置資訊
  cat("步驟 1：確認部署配置\n")
  cat("---------------------------\n")
  cat("📁 Repository:", config$deployment$github_repo, "\n")
  cat("📍 App Path:", config$deployment$app_path, "\n")
  cat("📄 Main File:", config$deployment$main_file, "\n")
  cat("🌿 Branch:", config$deployment$branch, "\n\n")
  
  if (interactive) {
    cat("配置正確嗎？(yes/no): ")
    response <- tolower(readline())
    if (response != "yes" && response != "y") {
      cat("❌ 部署已取消\n")
      cat("💡 提示：修改 app_config.yaml 來更新配置\n")
      return(invisible(FALSE))
    }
  }
  
  # 步驟 2：檢查並更新主檔案
  cat("\n步驟 2：檢查主應用程式檔案\n")
  cat("---------------------------\n")
  
  main_file <- config$deployment$main_file
  
  # 檢查主檔案是否存在
  if (!file.exists(main_file)) {
    cat("❌ 找不到", main_file, "\n")
    
    # 嘗試使用版本檔案
    if (length(config$deployment$version_files) > 0) {
      for (vf in config$deployment$version_files) {
        if (file.exists(vf)) {
          cat("找到", vf, "，複製為", main_file, "\n")
          file.copy(vf, main_file, overwrite = TRUE)
          cat("✅", main_file, "已創建\n")
          break
        }
      }
    }
  } else {
    cat("✅", main_file, "存在\n")
    
    # 檢查是否需要更新
    if (length(config$deployment$version_files) > 0 && interactive) {
      latest_version <- NULL
      for (vf in config$deployment$version_files) {
        if (file.exists(vf)) {
          latest_version <- vf
          break
        }
      }
      
      if (!is.null(latest_version)) {
        current_content <- readLines(main_file, warn = FALSE)
        latest_content <- readLines(latest_version, warn = FALSE)
        
        if (!identical(current_content, latest_content)) {
          cat("⚠️ ", main_file, "與", latest_version, "內容不同\n")
          cat("是否更新到最新版本？(yes/no): ")
          if (tolower(readline()) %in% c("yes", "y")) {
            file.copy(latest_version, main_file, overwrite = TRUE)
            cat("✅", main_file, "已更新\n")
          }
        } else {
          cat("✅", main_file, "已是最新版本\n")
        }
      }
    }
  }
  
  # 特殊處理：如果 main_file 不是 app.R，但 Posit Connect 需要 app.R
  if (main_file != "app.R" && file.exists(main_file)) {
    cat("\n📝 注意：主檔案是", main_file, "而非 app.R\n")
    
    # 檢查是否需要創建 app.R
    if (!file.exists("app.R")) {
      cat("⚠️  Posit Connect Cloud 通常需要 app.R\n")
      if (interactive) {
        cat("是否將", main_file, "複製為 app.R？(yes/no): ")
        if (tolower(readline()) %in% c("yes", "y")) {
          file.copy(main_file, "app.R", overwrite = TRUE)
          cat("✅ app.R 已創建（從", main_file, "複製）\n")
        }
      } else {
        # 自動模式：直接複製
        file.copy(main_file, "app.R", overwrite = TRUE)
        cat("✅ app.R 已自動創建（從", main_file, "複製）\n")
      }
    } else {
      # app.R 已存在，檢查是否需要更新
      app_content <- readLines("app.R", warn = FALSE)
      main_content <- readLines(main_file, warn = FALSE)
      
      if (!identical(app_content, main_content)) {
        cat("⚠️  app.R 與", main_file, "內容不同\n")
        if (interactive) {
          cat("是否用", main_file, "更新 app.R？(yes/no): ")
          if (tolower(readline()) %in% c("yes", "y")) {
            file.copy(main_file, "app.R", overwrite = TRUE)
            cat("✅ app.R 已更新（從", main_file, "）\n")
          }
        } else {
          # 自動模式：直接更新
          file.copy(main_file, "app.R", overwrite = TRUE)
          cat("✅ app.R 已自動更新（從", main_file, "）\n")
        }
      } else {
        cat("✅ app.R 與", main_file, "內容相同\n")
      }
    }
  }
  
  # 步驟 3：更新 manifest.json
  cat("\n步驟 3：更新依賴清單\n")
  cat("---------------------------\n")
  
  tryCatch({
    library(rsconnect)
    
    # 設定 renv 忽略規則
    if (requireNamespace("renv", quietly = TRUE)) {
      # 確保 .renvignore 被讀取
      renv::settings$ignored.packages(c("tbl2", "logger", "odbc", "gridlayout"))
    }
    
    # 靜默執行，避免互動提示
    options(renv.verbose = FALSE)
    
    # 寫入 manifest.json
    suppressWarnings({
      rsconnect::writeManifest(
        appDir = ".",
        appFiles = list.files(
          ".", 
          recursive = TRUE,
          all.files = FALSE,
          pattern = "\\.(R|Rmd|html|css|js|png|jpg|jpeg|gif|yaml|yml|json)$",
          ignore.case = TRUE
        )
      )
    })
    
    cat("✅ manifest.json 已更新\n")
  }, error = function(e) {
    cat("⚠️  更新 manifest.json 失敗：", e$message, "\n")
    cat("💡 您可以手動執行：rsconnect::writeManifest()\n")
  })
  
  # 步驟 4：檢查必要檔案和目錄
  cat("\n步驟 4：檢查必要檔案和目錄\n")
  cat("---------------------------\n")
  
  all_good <- TRUE
  
  # 檢查檔案
  if (length(config$deployment$required_files) > 0) {
    cat("\n檔案檢查：\n")
    for (f in config$deployment$required_files) {
      if (file.exists(f)) {
        cat("  ✅", f, "\n")
      } else {
        cat("  ❌", f, "- 缺失\n")
        all_good <- FALSE
      }
    }
  }
  
  # 檢查目錄
  if (length(config$deployment$required_dirs) > 0) {
    cat("\n目錄檢查：\n")
    for (d in config$deployment$required_dirs) {
      if (dir.exists(d)) {
        cat("  📁", d, "/\n")
      } else {
        cat("  ❌", d, "/ - 缺失\n")
        all_good <- FALSE
      }
    }
  }
  
  # 步驟 5：環境變數提醒
  if (length(config$deployment$env_vars) > 0) {
    cat("\n步驟 5：環境變數檢查\n")
    cat("---------------------------\n")
    cat("需要在 Posit Connect Cloud 設定以下環境變數：\n")
    for (var in config$deployment$env_vars) {
      # 檢查本地是否有 .env 檔案
      if (file.exists(".env")) {
        env_content <- readLines(".env", warn = FALSE)
        if (any(grepl(paste0("^", var, "="), env_content))) {
          cat("  ✅", var, "（在 .env 中找到）\n")
        } else {
          cat("  ⚠️ ", var, "（未在 .env 中找到）\n")
        }
      } else {
        cat("  ℹ️ ", var, "\n")
      }
    }
  }
  
  # 特殊說明
  if (!is.null(config$deployment$special_instructions) && nchar(config$deployment$special_instructions) > 0) {
    cat("\n📌 特殊說明：\n")
    cat(config$deployment$special_instructions, "\n")
  }
  
  # 部署指示
  cat("\n============================\n")
  cat("📋 部署步驟\n")
  cat("============================\n\n")
  
  if (all_good) {
    cat("✅ 檔案檢查通過！\n\n")
    
    # 檢查部署目標
    deploy_target <- config$deployment$target
    if (is.null(deploy_target)) {
      # 向後相容：檢查 .env
      if (file.exists(".env")) {
        deploy_target <- Sys.getenv("DEPLOY_TARGET", "connect")
      } else {
        deploy_target <- "connect"
      }
    }
    
    cat("🎯 部署目標:", deploy_target, "\n\n")
    
    cat("1️⃣ 提交並推送變更：\n")
    cat("   git add -A\n")
    cat("   git commit -m 'Deploy", config$app_info$name, "'\n")
    cat("   git push\n\n")
    
    if (deploy_target == "connect") {
      cat("2️⃣ 登入 Posit Connect Cloud：\n")
      cat("   https://connect.posit.cloud\n\n")
      
      cat("3️⃣ 部署設定：\n")
      cat("   - Repository:", config$deployment$github_repo, "\n")
      cat("   - Application Path:", config$deployment$app_path, "\n")
      cat("   - Primary File:", config$deployment$main_file, "\n")
      cat("   - Branch:", config$deployment$branch, "\n")
    } else if (deploy_target == "shinyapps") {
      cat("2️⃣ 部署到 ShinyApps.io：\n")
      cat("   rsconnect::deployApp(\n")
      cat("     appName = '", config$deployment$shinyapps$app_name, "',\n", sep = "")
      cat("     account = '", config$deployment$shinyapps$account, "'\n", sep = "")
      cat("   )\n")
    }
    
    if (length(config$deployment$env_vars) > 0) {
      cat("\n4️⃣ 設定環境變數（參考 .env 檔案）\n")
    }
  } else {
    cat("❌ 請先修復缺失的檔案或目錄\n")
  }
  
  cat("\n結束時間:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
  return(invisible(all_good))
}

# 如果直接執行
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  
  # 支援自訂配置檔案
  config_file <- "app_config.yaml"
  if (length(args) > 0 && !startsWith(args[1], "--")) {
    config_file <- args[1]
  }
  
  # 檢查是否為自動模式
  if ("--auto" %in% args) {
    deploy_with_config(config_file, interactive = FALSE)
  } else {
    deploy_with_config(config_file, interactive = TRUE)
  }
} 