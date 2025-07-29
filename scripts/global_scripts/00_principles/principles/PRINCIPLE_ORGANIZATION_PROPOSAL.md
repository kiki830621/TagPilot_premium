# Principle Organization Proposal

## 現狀分析

目前 `00_principles/` 目錄有 100+ 個檔案在同一層，包含：
- MP (Meta-Principles)
- P (Principles)  
- R (Rules)
- SLN (Solutions)
- RC (Resource Codes)
- S (Sequences)
- 各種 .R 檔案

## 問題

1. **檔案過多**：單一目錄難以瀏覽
2. **混雜內容**：原則文件與程式碼混在一起
3. **難以找到相關內容**：相關原則分散在不同編號

## 建議方案：標籤系統 + 平面結構

### 目錄結構
```
00_principles/
├── principles/              # 所有 MP, P, R 文件（平面結構）
│   ├── MP0001_axiomatization_system.md
│   ├── P0076_error_handling_patterns.md
│   ├── R0092_universal_dbi_approach.md
│   └── ...
├── solutions/              # SLN 文件
├── templates/              # RC 模板文件
├── scripts/                # 執行腳本（.R 檔案）
├── records/                # 實作記錄
├── INDEX.md               # 主索引
├── TAGS.yaml              # 標籤定義
└── RELATIONSHIPS.yaml     # 關聯關係
```

### 標籤系統 (TAGS.yaml)
```yaml
tags:
  database:
    - MP0016_modularity
    - R0092_universal_dbi_approach
    - R0093_database_status_display
    
  ui_components:
    - R0110_explicit_namespace_in_shiny
    - R0106_selectize_input_usage
    
  testing:
    - R0074_shiny_test_data
    - R0075_test_script_initialization
    
  architecture:
    - MP0001_axiomatization_system
    - MP0017_separation_of_concerns
```

### 關聯關係 (RELATIONSHIPS.yaml)
```yaml
relationships:
  R0092_universal_dbi_approach:
    implements:
      - MP0016_modularity
      - MP0017_separation_of_concerns
    related_to:
      - R0093_database_status_display
      - P0076_error_handling_patterns
      
  R0093_database_status_display:
    extends: R0092_universal_dbi_approach
    implements:
      - MP0016_modularity
```

### 自動生成的索引 (INDEX.md)
```markdown
# Principles Index

## By Type
### Meta-Principles (MP)
- [MP0001 - Axiomatization System](principles/MP0001_axiomatization_system.md)
- [MP0016 - Modularity](principles/MP0016_modularity.md)

### Rules (R)
- [R0092 - Universal DBI Approach](principles/R0092_universal_dbi_approach.md)
- [R0093 - Database Status Display](principles/R0093_database_status_display.md)

## By Topic
### Database
- [MP0016 - Modularity](principles/MP0016_modularity.md)
- [R0092 - Universal DBI Approach](principles/R0092_universal_dbi_approach.md)
- [R0093 - Database Status Display](principles/R0093_database_status_display.md)

### UI Components
- [R0106 - Selectize Input Usage](principles/R0106_selectize_input_usage.md)
- [R0110 - Explicit Namespace in Shiny](principles/R0110_explicit_namespace_in_shiny.md)
```

## 實作步驟

1. **Phase 1: 清理和分類**
   - 將所有 .R 檔案移到 `scripts/`
   - 將 SLN 文件移到 `solutions/`
   - 將 RC 文件移到 `templates/`

2. **Phase 2: 建立標籤系統**
   - 創建 TAGS.yaml
   - 掃描所有原則文件的 metadata
   - 建立 RELATIONSHIPS.yaml

3. **Phase 3: 生成工具**
   - 創建 `generate_index.R` 自動生成 INDEX.md
   - 創建 `check_references.R` 檢查交互參照
   - 創建 `visualize_relationships.R` 生成關係圖

## 優點

1. **保持簡單的交互參照**：所有原則在同一目錄
2. **靈活的組織方式**：通過標籤可以多維度分類
3. **易於維護**：自動化工具減少手動維護
4. **可視化關係**：容易看到原則之間的關聯
5. **向後兼容**：現有的參照不需要修改

## 範例查詢

```r
# 找出所有資料庫相關的原則
find_principles_by_tag("database")

# 找出 R0092 的所有相關原則
find_related_principles("R0092")

# 檢查某個原則的實作狀態
check_implementation_status("R0093")
``` 