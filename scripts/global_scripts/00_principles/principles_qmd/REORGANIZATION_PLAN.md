# Principles QMD 重組計畫

## 概述

基於憲法和民法的編制結構，將 `principles_qmd/` 重新組織為「基本法 + 專門法」的法典體系。

## 目標架構

### CH00: 基本法（憲法性質）
```
CH00_fundamental_principles/
├── INDEX.qmd                        # 基本原則總覽
├── meta_principles/
│   ├── MP000_axiomatization_system.qmd     # 已存在，需移動
│   ├── MP001_primitive_terms.qmd           # 已存在，需移動  
│   ├── MP002_default_deny.qmd              # 已存在，需移動
│   ├── MP003_operating_modes.qmd           # 已存在，需移動
│   └── ...                                # 其他基礎 MP（MP000-MP049）
├── principles/
│   ├── P000_project_principles.qmd         # 已存在，需移動
│   ├── P001_script_separation.qmd          # 已存在，需移動
│   └── ...                                # 其他基礎原則（P000-P099）
└── rules/
    ├── R000_directory_structure.qmd        # 已存在，需移動
    ├── R001_file_naming_convention.qmd     # 已存在，需移動
    └── ...                                # 其他基礎規則（R000-R099）
```

### CH01: 檔案管理專門法
```
CH01_file_management/
├── INDEX.qmd                             # 檔案管理索引
├── meta_principles/
│   ├── MP084_file_management_architecture.qmd
│   └── MP085_data_lifecycle_principles.qmd
├── principles/
│   ├── P115_naming_principles.qmd
│   ├── P116_directory_organization.qmd
│   └── P117_version_control_strategy.qmd
└── rules/
    ├── R127_file_naming_rules.qmd
    ├── R128_directory_structure_rules.qmd
    ├── R129_git_workflow_rules.qmd
    └── R130_backup_procedures.qmd
```

### 未來章節（預留）
```
CH02_database_management/              # 資料庫管理專門法
CH03_api_management/                   # API管理專門法  
CH04_deployment_management/            # 部署管理專門法
CH05_ui_component_management/          # UI組件管理專門法
```

## 編號原則

### 1. 層級系統
- **CH**: Chapter（編）- 主題領域分類
- **MP/P/R**: 原有編號系統保持不變
- **編號連續性**: 在各自類別內保持連續編號

### 2. 隸屬關係
```
CH00（基本法）
├── 適用範圍: 整個系統
└── 被引用: 所有其他章節

CH01-CHxx（專門法）  
├── 適用範圍: 特定領域
├── 依據: CH00 基本原則
└── 實施: 領域特定規則
```

### 3. Cross Reference 格式
```yaml
# 在檔案內容中的引用格式
依據:
  - CH00.MP002_default_deny        # 基本法引用
  - CH00.P000_project_principles   # 基本原則引用
實施: 
  - CH01.P115_naming_principles    # 本章具體原則
衍生:
  - CH01.R127_file_naming_rules    # 具體實施規則
```

## 實施步驟

### 階段一：建立基本架構
1. 創建 `CH00_fundamental_principles/` 目錄
2. 建立 meta_principles/, principles/, rules/ 子目錄
3. 創建 INDEX.qmd 模板

### 階段二：遷移現有檔案
1. **識別基本法檔案**: MP000-MP049, P000-P099, R000-R099
2. **遷移到 CH00**: 保持原檔名，更新內部 cross reference
3. **更新現有檔案**: 修改其他檔案中對被遷移檔案的引用

### 階段三：建立檔案管理專門法
1. 創建 `CH01_file_management/` 目錄結構
2. 開始編寫 file_management 相關的 MP/P/R 檔案
3. 建立與 CH00 的 cross reference 關係

### 階段四：完善索引系統
1. 完善各章節的 INDEX.qmd
2. 建立全域索引系統
3. 建立 cross reference 導航

## 遷移對照表

### 需要遷移到 CH00 的檔案（示例）
```
現在位置 → 新位置
principles/MP000_axiomatization_system.md → CH00_fundamental_principles/meta_principles/MP000_axiomatization_system.qmd
principles/P000_project_principles.md → CH00_fundamental_principles/principles/P000_project_principles.qmd  
principles/R000_directory_structure.md → CH00_fundamental_principles/rules/R000_directory_structure.qmd
```

### 編號區間分配
```
CH00 基本法:
- MP000-MP049: 基礎元原則
- P000-P099: 基礎原則  
- R000-R099: 基礎規則

CH01 檔案管理:
- MP084-MP089: 檔案管理元原則
- P115-P119: 檔案管理原則
- R127-R135: 檔案管理規則

CH02+ 未來章節:
- 依據實際需要分配編號區間
```

## 檔案格式標準

### INDEX.qmd 模板
```yaml
---
title: "CHxx: 章節名稱"
subtitle: "索引與導覽"
---

## 章節概述
（章節目的和適用範圍）

## 架構層次
### Meta-Principles (MPxxx)
- 列出本章所有 MP 及其用途

### Principles (Pxxx)  
- 列出本章所有 P 及其用途

### Rules (Rxxx)
- 列出本章所有 R 及其用途

## Cross Reference
### 依據的基本法
- CH00.MPxxx
- CH00.Pxxx

### 相關章節
- CHxx.xxx（相關聯的其他章節）
```

### 個別檔案的 Cross Reference 區塊
```yaml
---
title: "檔案標題"
chapter: "CHxx"
category: "MP/P/R"
number: "xxx"
dependencies:
  - CH00.MPxxx
  - CH00.Pxxx
related:
  - CHxx.Pxxx
  - CHxx.Rxxx
---
```

## 維護原則

1. **向下相容**: 確保現有引用不會失效
2. **漸進式實施**: 分階段實施，避免系統中斷
3. **文檔同步**: 每次移動都要更新相關的 cross reference
4. **編號保留**: 已分配的編號不得重複使用

## 預期效益

1. **系統性組織**: 清楚的基本法與專門法分層
2. **便於查找**: 主題導向的目錄結構
3. **易於維護**: 相關規則集中管理
4. **可擴展性**: 為未來新領域預留空間
5. **法典一致性**: 符合成熟的法典組織邏輯

---
**創建日期**: 2025-07-19  
**最後更新**: 2025-07-19  
**狀態**: 規劃階段