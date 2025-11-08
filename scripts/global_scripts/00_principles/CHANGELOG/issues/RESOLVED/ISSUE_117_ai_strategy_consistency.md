---
issue: "ISSUE_117"
title: "AI策略名稱不一致"
severity: "medium"
component: "brand_positioning"
created: "2025-09-08"
status: "resolved"
resolved_date: "2025-09-22"
resolution_notes: "Documented prompt and naming inconsistencies - requires standardization"
original_source: "曼巴儀表板問題_20250807"
---

## Problem
AI策略：訴求、改善、改變、劣勢要有四個策略訴求，名稱要一致。

## Expected Behavior
- 四個明確的策略維度：訴求、改善、劣勢、改變
- 統一的命名規範
- 一致的策略框架

## Actual Behavior
發現四處命名不一致問題：

1. **內部變數**（第 269-278 行）：
   - `argument_factors`（應為 `appeal_factors`）
   - `improvement_factors` ✓
   - `weakness_factors` ✓
   - `changing_factors`（應為 `change_factors`）

2. **AI Prompt 標題**（第 790-801 行）：
   - 訴求策略（與象限標籤「訴求」不一致）
   - 改善策略（與象限標籤「改善」不一致）
   - 劣勢應對（與象限標籤「劣勢」不一致）
   - 關鍵調整（與象限標籤「改變」不一致）

3. **視覺化標籤**（第 883-885 行）：
   - 中文：「訴求」、「改善」、「劣勢」、「改變」✓
   - 英文：「Argument」、「Improvement」、「Weakness」、「Change」（Argument 應為 Appeal）

## Resolution (找到的 AI Prompt)

### 完整 OpenAI Prompt（positionStrategy.R 第 790-801 行）
```markdown
根據四象限策略分析結果，為該產品提供具體的行銷策略建議。請使用以下 markdown 架構，但**只顯示該產品實際有因素的部分**：

## 產品策略分析

### 訴求策略
（僅當 argument_factors 有內容時顯示此部分）
基於該產品的優勢因素，建議如何在行銷中突出這些優勢。

### 改善策略
（僅當 improvement_factors 有內容時顯示此部分）
基於可改善因素，提出產品優化方向。

### 劣勢應對
（僅當 weakness_factors 有內容時顯示此部分）
基於弱勢因素，建議如何在行銷中減少負面影響。

### 關鍵調整
（僅當 changing_factors 有內容時顯示此部分）
基於需要改變的因素，提出重點改進建議。
```

### 建議修正方案

#### 1. 統一四個策略維度名稱
**標準化名稱**：
- 訴求 (Appeal) - 強調優勢
- 改善 (Improvement) - 需要改進的領域
- 劣勢 (Weakness) - 需要處理的弱點
- 改變 (Change) - 需要改變的策略

#### 2. 需要修改的程式碼
```r
# 變數名稱修改
argument_factors → appeal_factors
argument_text → appeal_text
changing_factors → change_factors
changing_text → change_text

# 英文標籤修改（第 885 行）
c("Appeal", "Improvement", "Weakness", "Change")

# AI Prompt 標題修改
### 訴求策略 → ### 訴求
### 改善策略 → ### 改善
### 劣勢應對 → ### 劣勢
### 關鍵調整 → ### 改變
```

## Priority
Medium - 一致性問題

## Related Issues
- ISSUE_116