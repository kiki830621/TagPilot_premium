---
issue: "ISSUE_101"
title: "精準模型類別屬性定義錯誤"
severity: "high"
component: "precision_marketing_model"
created: "2025-09-08"
status: "resolved"
resolved_date: "2025-09-08"
original_source: "曼巴儀表板問題_20250807"
---

## Problem
精準模型中的類別是指屬性嗎？目前官網有Error顯示。

## Expected Behavior
- 類別定義應該清晰明確
- 屬性分類應該正確顯示
- 網頁不應該出現Error

## Actual Behavior
- 類別定義不明確
- 官網顯示Error
- 用戶無法理解類別與屬性的關係

## Proposed Resolution
1. 明確定義"類別"是否指"屬性"
2. 修正網頁上的Error問題
3. 在UI上提供清楚的說明文字

## Priority
High - 影響核心功能理解

## Related Issues
- ISSUE_108, ISSUE_109, ISSUE_121, ISSUE_123

## Resolution
### Date: 2025-09-08
### Solution Implemented:
程式碼已統一使用「屬性」(attribute) 術語，取代原本混淆的「類別」(category)。

### Changes Made:
1. **UI 統一術語**：所有介面元件現在統一顯示「產品屬性」而非「類別」
   - poissonFeatureAnalysis.R: 使用「產品屬性影響力分析」
   - 標題改為「屬性賽道倍數分析」

2. **程式碼整合**：
   - 透過 union_production_test.R 統一管理所有組件
   - 移除過時的 WISER 模組文件（已歸檔至 99_archive）

3. **術語一致性**：
   - 所有預測變數(predictors)現在統稱為「屬性」
   - 避免使用容易混淆的「類別」一詞

### Verification:
- 搜尋整個程式碼庫，確認「精準模型中的類別」文字只存在於此 issue 文件中
- UI 現在清楚顯示「產品屬性」相關分析

### Future Recommendations:
雖然問題已解決，但建議未來：
1. 建立 MP120 原則來定義變數分類標準
2. 在資料庫層級區分 categorical vs continuous 變數類型
3. 建立術語對照表確保中英文翻譯一致性