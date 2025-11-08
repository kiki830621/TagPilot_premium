# Principles Index

> **Updated: 2025-10-03**
>
> This index reflects the current principles structure after reorganization.
>
> **Important**: This principles system is **company-agnostic**. It applies to ALL company projects
> across all tiers (l1_basic, l2_pro, l3_premium, l4_enterprise), including but not limited to:
> VitalSigns, BrandEdge, InsightForge, MAMBA, WISER, kitchenMAMA, etc.
>
> The principles are distributed via git subrepo to each company's `scripts/global_scripts/00_principles/` directory.

## Current Structure

**Total Meta-Principles**: 30 (MP001-MP030)
**Total Principles**: 257+ (organized in natural/en/part1_principles/)
**Total Implementations**: Multiple (organized in natural/en/part2_implementations/)

**Note**: The actual principle files are located in `natural/en/part1_principles/` organized by chapters,
not as individual MP*.md files in the root directory.

## Quick Links
- [Actual Principles Location](#actual-principles-location)
- [Archive Notice](#archive-notice)
- [Search Tips](#search-tips)

## Actual Principles Location

All principles are organized in Quarto (.qmd) format under:
```
natural/en/part1_principles/
├── CH00_fundamental_meta_principles/
├── CH01_structure_organization/
├── CH02_data_management/
├── CH03_development_methodology/
├── CH04_ui_components/
├── CH05_testing_deployment/
└── CH06_integration_collaboration/
```

### Legacy Meta-Principles Reference (Historical)

The following MP001-MP030 listing is for historical reference.
**For actual current principles, see `natural/en/part1_principles/` directory.**

### Foundation & System Architecture (Historical Reference)

- [MP001 - Axiomatization System](natural/en/part1_principles/CH00_fundamental_meta_principles/)
- [MP002 - Primitive Terms and Definitions](natural/en/part1_principles/CH00_fundamental_meta_principles/)
- [MP003 - Default Deny](MP003_default_deny.md)
- [MP004 - Structural Blueprint](MP004_structural_blueprint.md)
- [MP005 - Operating Modes](MP005_operating_modes.md)
- [MP006 - Mode Hierarchy](MP006_mode_hierarchy.md)
- [MP007 - Instance vs Principle](MP007_instance_vs_principle.md)
- [MP008 - Data Source Hierarchy](MP008_data_source_hierarchy.md)
- [MP009 - Documentation Organization](MP009_documentation_organization.md)
- [MP010 - Terminology Axiomatization](MP010_terminology_axiomatization.md)

### System Principles

- [MP011 - Discrepancy Principle](MP011_discrepancy_principle.md)
- [MP012 - Information Flow Transparency](MP012_information_flow_transparency.md)
- [MP013 - Sensible Defaults](MP013_sensible_defaults.md)
- [MP014 - Company Centered Design](MP014_company_centered_design.md)
- [MP015 - Statute Law Analogy](MP015_statute_law_analogy.md)
- [MP016 - Change Tracking](MP016_change_tracking.md)
- [MP017 - Currency Principle](MP017_currency_principle.md)

### Development Methodology

- [MP018 - Modularity](MP018_modularity.md)
- [MP019 - Separation of Concerns](MP019_separation_of_concerns.md)
- [MP020 - Don't Repeat Yourself](MP020_dont_repeat_yourself.md)
- [MP021 - Package Consistency](MP021_package_consistency.md)

### Language & Standards

- [MP022 - Principle Language Versions](MP022_principle_language_versions.md)
- [MP023 - Formal Logic Language](MP023_formal_logic_language.md)
- [MP024 - Pseudocode Conventions](MP024_pseudocode_conventions.md)
- [MP025 - Language Preferences](MP025_language_preferences.md)
- [MP026 - Natural SQL Language](MP026_natural_sql_language.md)
- [MP027 - AI Communication Meta Language](MP027_ai_communication_meta_language.md)
- [MP028 - R Statistical Query Language](MP028_r_statistical_query_language.md)
- [MP029 - Integrated Natural SQL Language](MP029_integrated_natural_sql_language.md)

### Archive Management

- [MP030 - Archive Immutability](MP030_archive_immutability.md)

## Archive Notice

All legacy Principles (P*.md) and Rules (R*.md) have been archived as part of the system reorganization on 2025-08-25. These files can be found in `CHANGELOG/archive/principles_processed/` for historical reference.

Per MP030 (Archive Immutability), archived files are preserved for historical reference and audit trails but should not be modified.


## Search Tips

### Finding Meta-Principles
```bash
# Search by ID
grep -l 'MP001' *.md

# Search by topic
grep -l 'archive' MP*.md

# List all Meta-Principles
ls -1 MP*.md | sort
```

### Quick Navigation
- Use Ctrl+F (Cmd+F on Mac) to search this page
- Click on any Meta-Principle link to view details
- Check README.md for the overall documentation structure
