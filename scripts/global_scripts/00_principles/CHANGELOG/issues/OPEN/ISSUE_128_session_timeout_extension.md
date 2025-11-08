---
issue: "ISSUE_128"
title: "網頁停留時間延長到1小時"
severity: "medium"
component: "ui_ux"
created: "2025-09-08"
status: "open"
original_source: "曼巴儀表板問題_20250807"
---

## Problem
曼巴網頁停留時間需要拉長到1小時。

## Expected Behavior
- Session timeout設為1小時
- 自動保存進度
- 超時前提醒

## Actual Behavior
- 目前超時時間過短
- 用戶需要重新登入

## Proposed Resolution
1. 調整session timeout到60分鐘
2. 實作自動保存機制
3. 加入超時預警
4. 提供延長選項

## Priority
Medium - 用戶體驗

## Related Issues
None