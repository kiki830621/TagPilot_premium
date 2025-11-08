---
issue: "ISSUE_115"
title: "時間標籤系統需重構為三層架構"
severity: "medium"
component: "ui_ux"
created: "2025-09-08"
status: "in_progress"
progress_date: "2025-09-22"
progress_notes: "Complete solution designed with data structure modifications"
original_source: "曼巴儀表板問題_20250807"
---

## Problem (更新需求)
原問題：右下角圖缺少日期標籤

**用戶更新需求**：需要完全重構時間標籤系統為三層架構：
1. **年度**：按年份順序排列
2. **月份**：按月份順序排列
3. **日期**：按日期順序排列

目前顯示 "month_4 (3.1×)" 無法看出是哪一年的4月。

## Expected Behavior
- 三層時間架構：年度、月份、日期
- 每層按時間順序排列
- 清楚顯示完整時間資訊（如：2025年4月）
- 層級關係明確

## Actual Behavior
- 顯示 "月份4 (3.1×)" 缺少年份資訊
- 無法判斷具體時間段
- 沒有層級結構
- 排序混亂

## Resolution (完整解決方案)

### 1. 資料結構修改

#### 增強 Poisson 分析表結構
```sql
-- 新增時間上下文欄位
ALTER TABLE df_cbz_poisson_analysis_all
ADD COLUMN analysis_year INTEGER,
ADD COLUMN analysis_month INTEGER,
ADD COLUMN analysis_day INTEGER,
ADD COLUMN date_start DATE,
ADD COLUMN date_end DATE,
ADD COLUMN time_hierarchy VARCHAR(10), -- 'year', 'month', 'day'
ADD COLUMN hierarchical_label VARCHAR(100);
```

### 2. ETL Derivation Script

創建 `cbz_DER_poisson_time_labels.R` 實現：
- 從原始訂單資料提取時間資訊
- 豐富 Poisson 分析表的時間標籤
- 建立三層時間架構

關鍵邏輯：
```r
# 提取時間範圍
time_ranges <- orders_data %>%
  summarise(
    earliest_date = min(created_at, na.rm = TRUE),
    latest_date = max(created_at, na.rm = TRUE)
  )

# 豐富時間標籤
enriched_data <- poisson_data %>%
  mutate(
    analysis_year = case_when(
      predictor == "year" ~ year(time_ranges$latest_date),
      grepl("^month_", predictor) ~ year(time_ranges$latest_date),
      TRUE ~ NA_integer_
    ),
    analysis_month = case_when(
      grepl("^month_(\\d+)$", predictor) ~
        as.integer(sub("month_(\\d+)", "\\1", predictor)),
      TRUE ~ NA_integer_
    ),
    hierarchical_label = case_when(
      predictor == "year" ~ paste0(analysis_year, "年全年"),
      grepl("^month_", predictor) ~
        paste0(analysis_year, "年", analysis_month, "月"),
      predictor %in% weekdays ~ paste0("週", weekday_chinese),
      TRUE ~ predictor
    )
  )
```

### 3. UI 組件更新

修改 `poissonTimeAnalysis.R`：

```r
# 建立三層時間分組
time_groups <- list(
  year_data = data %>% filter(time_hierarchy == "year"),
  month_data = data %>% filter(time_hierarchy == "month") %>%
    arrange(analysis_year, analysis_month),
  day_data = data %>% filter(time_hierarchy == "day") %>%
    arrange(analysis_year, analysis_month, analysis_day)
)

# 分層顯示
output$timeAnalysisOutput <- renderUI({
  tagList(
    h4("═══ 年度趨勢 ═══"),
    renderYearAnalysis(time_groups$year_data),

    h4("═══ 月份分析 ═══"),
    renderMonthAnalysis(time_groups$month_data),

    h4("═══ 日期詳情 ═══"),
    renderDayAnalysis(time_groups$day_data)
  )
})
```

### 4. 預期結果展示

**修改前**：
```
月份4 (3.1×)    [不知道哪一年]
月份5 (3.3×)    [時間不明確]
年度 (2.1×)     [哪個年度？]
```

**修改後**：
```
═══ 2025年趨勢 ═══
2025年全年 (2.1×)

═══ 2025年月份分析 ═══
2025年4月 (3.1×)
2025年5月 (3.3×)
2025年6月 (2.8×)

═══ 星期效應 ═══
週一 (0.8×)
週五 (1.5×)
週六 (1.8×)
```

### 5. 實施步驟

1. **Phase 1**: 執行 `cbz_DER_poisson_time_labels.R` 豐富現有資料
2. **Phase 2**: 更新 UI 組件使用新標籤
3. **Phase 3**: 修改 ETL 流程永久保存時間資訊
4. **Phase 4**: 測試並部署

## Priority
Medium - 資料結構重構與UI改進

## Related Issues
None