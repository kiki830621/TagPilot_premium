# Posit Connect Cloud 部署指南

## 🚀 快速開始

### 步驟 1：獲取 API Key

1. 前往 https://connect.posit.cloud
2. 登入您的帳戶（如果沒有帳戶，需要先註冊）
3. 點擊右上角的用戶圖標
4. 選擇 **API Keys**
5. 點擊 **New API Key**
6. 給 API Key 一個描述性名稱（例如："positioning_app deployment"）
7. 複製生成的 API Key

### 步驟 2：更新 API Key

使用以下任一方法：

#### 方法 A：命令行（推薦）
```bash
# 將 YOUR_ACTUAL_KEY 替換為您的實際 API Key
sed -i "" "s/CONNECT_API_KEY=YOUR_API_KEY_HERE/CONNECT_API_KEY=YOUR_ACTUAL_KEY/" .env
```

#### 方法 B：手動編輯
編輯 `.env` 檔案，找到這行：
```
CONNECT_API_KEY=YOUR_API_KEY_HERE
```
替換為：
```
CONNECT_API_KEY=你的實際API_Key
```

### 步驟 3：執行部署

```bash
# 使用簡化的部署腳本
Rscript deploy_app.R

# 或在 R 中執行
source("deploy_app.R")
```

## 📋 當前設定

您的 `.env` 檔案已配置為：
- **部署目標**: Posit Connect Cloud (`DEPLOY_TARGET=connect`)
- **伺服器**: https://connect.posit.cloud
- **應用名稱**: positioning_app

## 🔧 疑難排解

### 問題 1：API Key 無效
如果出現認證錯誤，請確認：
- API Key 已正確複製（沒有多餘的空格）
- API Key 沒有過期
- 您的 Posit Connect Cloud 帳戶是活躍的

### 問題 2：首次部署
如果是首次部署到 Posit Connect Cloud，您可能需要：
```r
# 在 R 中設定連線
rsconnect::connectApiUser(
  server = "https://connect.posit.cloud",
  apiKey = "您的API_KEY"
)
```

### 問題 3：檔案大小限制
Posit Connect Cloud 有檔案大小限制。如果部署失敗，檢查：
- 移除不必要的大檔案
- 使用 `.gitignore` 排除測試資料

## 📊 部署後管理

部署成功後，您可以：
1. 在 https://connect.posit.cloud 查看應用狀態
2. 設定存取權限
3. 查看應用日誌
4. 調整資源配置

## 🔐 安全提醒

- **不要**將包含實際 API Key 的 `.env` 檔案提交到 Git
- 定期更新 API Key
- 使用環境特定的 API Key（開發/生產）

## 📞 需要幫助？

- [Posit Connect Cloud 文檔](https://docs.posit.co/connect-cloud/)
- [rsconnect 套件文檔](https://rstudio.github.io/rsconnect/)
- [Posit Community](https://community.rstudio.com/)

---
最後更新：2024-01-15 