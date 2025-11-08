# Global Principles Documentation Structure

## 🌐 Company-Agnostic Design

**This principles system applies to ALL company projects**, not just MAMBA or any specific company.

When distributed via git subrepo, this directory appears in each company's project as:
```
{tier}/{companyname}/scripts/global_scripts/00_principles/
```

Examples:
- `l1_basic/VitalSigns/scripts/global_scripts/00_principles/`
- `l4_enterprise/MAMBA/scripts/global_scripts/00_principles/`
- `l4_enterprise/kitchenMAMA/scripts/global_scripts/00_principles/`
- `l3_premium/BrandEdge_premium/scripts/global_scripts/00_principles/`

## 📁 Directory Organization

```
00_principles/
├── natural/                    # Natural language versions
│   ├── en/                    # English version
│   │   ├── part1_principles/  # 257+ principles organized by chapters
│   │   ├── part2_implementations/  # Implementation guides
│   │   └── part3_domain_knowledge/ # Domain-specific knowledge
│   └── zh/                    # Chinese version (same structure)
├── CHANGELOG/                  # Issue tracking and change history
│   └── archive/               # Historical principles (protected by MP030)
├── REFERENCES/                 # Bibliography
├── CLAUDE/                     # AI assistant guidelines
├── MIGRATION_GUIDES/          # Migration and reorganization guides
├── INDEX.md                    # Principles index (historical reference)
└── README.md                   # This file
```

## 📚 Current Structure

### Principles Organization

**Note**: Principles are now organized in `natural/en/part1_principles/` by chapters, not as individual files in the root.

**Chapter Structure**:
- **CH00**: Fundamental Meta-Principles
- **CH01**: Structure & Organization
- **CH02**: Data Management
- **CH03**: Development Methodology
- **CH04**: UI Components
- **CH05**: Testing & Deployment
- **CH06**: Integration & Collaboration
- **CH07**: Language Standards
- **CH08**: Data Processing
- **CH09**: ETL Pipelines
- **CH10**: NSQL Language
- **CH11**: AI Communication

### Archived Content
All legacy reorganization documents have been archived in `CHANGELOG/archive/`. Per MP030 (Archive Immutability), these files are preserved for historical reference but should not be modified.

## 🔍 Finding Principles

### Current Principles (2025+)
All principles are in Quarto format under `natural/en/part1_principles/`:
- Navigate to: `natural/en/part1_principles/{chapter}/`
- Example: `natural/en/part1_principles/CH03_development_methodology/`
- Index: Each chapter has its own `index.qmd`

### Browsing by Topic
```bash
# Find principles about database
grep -r "database" natural/en/part1_principles/

# List all principles in a chapter
ls natural/en/part1_principles/CH02_data_management/

# Search for specific principle ID
find natural/en/part1_principles/ -name "*MP064*"
```

## 📝 Naming Convention

- Meta-Principles: `MP{number}_{principle_name}.md` (e.g., `MP001_axiomatization_system.md`)
- Sequential numbering: MP001 through MP030
- No gaps in numbering sequence

## 🎯 Key Meta-Principles

### Foundation
- **MP001**: Axiomatization System - Establishes the formal foundation
- **MP002**: Primitive Terms and Definitions - Core terminology
- **MP003**: Default Deny - Security-first approach

### Critical Operations
- **MP030**: Archive Immutability - Protects historical records from modification

## 🚀 Usage

### For Readers
1. Start with [INDEX.md](INDEX.md) for a categorized overview
2. Read individual MP*.md files for detailed specifications
3. Respect MP030 - do not modify archived content

### For Contributors
1. New principles should extend the MP sequence (MP031, MP032, etc.)
2. Update INDEX.md when adding new Meta-Principles
3. Archive old content following MP030 guidelines
4. Maintain sequential numbering without gaps

## 📊 Current Status

- **Active Meta-Principles**: 30 (MP001-MP030)
- **Archived Principles**: 47 P*.md files
- **Archived Rules**: 117 R*.md files
- **Total Historical Items**: 164 archived documents

## 🔒 Important Notice

**MP030 - Archive Immutability** is now in effect. All files in `CHANGELOG/archive/` are protected historical records and must not be modified. This ensures audit trails and historical reference integrity.

---

*Last updated: 2025-08-25*