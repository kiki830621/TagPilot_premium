# IN_PROGRESS - 進行中的改進

此目錄追蹤**正在進行中**但尚未完成的改進任務。

## 📁 目錄用途

- **追蹤進度**：記錄改進任務的當前狀態
- **問題分析**：詳細描述需要解決的問題
- **解決方案設計**：規劃改進方案
- **實作記錄**：記錄改進過程

## 🔄 工作流程

1. **建立 ISSUE**：在此目錄建立 `ISSUE_XXX_description.md`
2. **實作改進**：依照 ISSUE 中的方案進行修改
3. **完成後**：
   - 如需要，使用 `principle-revisor` 建立新 Principle
   - 將 ISSUE 移至 `CHANGELOG/improvements/` (已完成)
   - 或移至 `CHANGELOG/issues/` (問題報告)

## 📝 命名規範

```
ISSUE_{NUMBER}_{short_description}.md
```

範例：
- `ISSUE_118_env_loading_standardization.md`
- `ISSUE_119_database_connection_pattern.md`

## 🏷️ ISSUE 檔案結構

```markdown
# ISSUE {NUMBER}: {Title}

**狀態**: 🔄 進行中 / ✅ 已完成 / ⏸️ 暫停
**建立日期**: YYYY-MM-DD
**預計完成**: YYYY-MM-DD
**負責人**: 姓名/AI Agent

## 問題描述
[描述需要解決的問題]

## 影響範圍
[列出受影響的檔案/專案]

## 解決方案
[詳細的解決方案設計]

## 實作步驟
- [ ] 步驟 1
- [ ] 步驟 2
- [ ] 步驟 3

## 驗證方式
[如何確認改進已正確實作]

## 相關 Principles
[如果完成後會建立新 Principle，在此說明]
```

---

**建立日期**: 2025-10-03
**用途**: 追蹤進行中的改進任務
