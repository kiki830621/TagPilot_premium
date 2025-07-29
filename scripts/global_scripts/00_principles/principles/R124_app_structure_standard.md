# R124: Application Structure Standard Rule (L1 Basic)

## 規則概述
L1 Basic 層級的應用程式必須遵循標準化的目錄結構，特別是必須包含 `scripts/global_scripts/` 作為共享程式碼庫的連接點。

## 適用範圍
- **適用於**: l1_basic 目錄下的所有應用程式
- **不適用於**: l2_pro 和 l3_enterprise（這些層級可能有不同的架構需求）

## 規則內容

### 1. 強制性結構要求（僅限 L1 Basic）
L1 Basic 層級的每個應用程式都必須包含：
```
app_name/
├── scripts/
│   └── global_scripts/     # [強制] global_scripts repository
├── app.R                   # [強制] 主應用程式
├── README.md              # [強制] 說明文件
└── .gitignore            # [強制] Git 忽略規則
```

### 2. Global Scripts 整合方式

#### 方式一：Git Submodule（推薦）
```bash
cd app_name
mkdir -p scripts
cd scripts
git submodule add git@github.com:kiki830621/precision_marketing_global_scripts.git global_scripts
```

#### 方式二：Git Subrepo
```bash
cd app_name
git subrepo clone git@github.com:kiki830621/precision_marketing_global_scripts.git scripts/global_scripts
```

#### 方式三：直接複製（僅開發階段）
```bash
cd app_name
mkdir -p scripts
cp -r ../global_scripts scripts/
```

### 3. 程式碼引用規範
```r
# 正確：使用相對於 app.R 的路徑
source("scripts/global_scripts/22_initializations/sc_initialization_app_mode.R")

# 錯誤：使用絕對路徑
source("/Users/xxx/global_scripts/...")

# 錯誤：假設 global_scripts 在上層目錄
source("../global_scripts/...")
```

## 違規後果
1. 應用程式無法獨立部署
2. 程式碼共享機制失效
3. 版本控制混亂
4. 團隊協作困難

## 豁免條件
無。這是強制性規則，所有應用程式都必須遵守。

## 驗證方法
```bash
# 自動檢查腳本
if [ ! -d "scripts/global_scripts" ]; then
  echo "ERROR: Missing required scripts/global_scripts directory"
  exit 1
fi
```

## 相關文件
- [應用程式結構標準詳細說明](../../docs/APP_STRUCTURE_STANDARD.md)
- [Global Scripts 使用指南](../README.md)

## 實施日期
2024-12-27

## 負責團隊
架構設計團隊 