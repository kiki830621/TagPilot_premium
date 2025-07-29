---
id: "R0040"
title: "Implementation Naming Convention for Derivations, Sequences, Modules, and Nodes"
type: "rule"
date_created: "2025-04-07"
date_modified: "2025-04-09"
author: "Claude"
implements:
  - "MP0001": "Primitive Terms and Definitions"
  - "P0005": "Naming Principles"
related_to:
  - "R0007": "Update Script Naming Convention"
  - "R0038": "Platform Numbering Convention"
  - "R0039": "Derivation Platform Independence"
  - "R0041": "Derivation Folder Structure"
---

# R0040: Implementation Naming Convention for Derivations, Sequences, Modules, and Nodes

This rule establishes the naming convention for files that implement platform-specific derivations, sequences, modules, and nodes, ensuring clear mapping between abstract definitions and their implementations.

## Core Requirement

Implementation files for derivations (D), sequences (S), modules (M), and nodes (N) must follow a unified naming pattern that clearly identifies the type, number, platform, and step - ensuring consistent and explicit identification while remaining compatible with the existing script naming convention (R0007).

## Naming Pattern for D/S/M Implementations

Files implementing derivations (D), sequences (S), and modules (M) must follow this standardized naming pattern:

```
{Type}{number}_P{platform}_{step}.R
```

Where:
- **{Type}**: The type identifier (D, S, or M)
- **{number}**: The two-digit type number (e.g., 01 for D01)
- **{platform}**: The two-digit platform number (e.g., 01 for Amazon) as defined in R38
- **{step}**: The two-digit step number (e.g., 00, 01, 02)

## Naming Pattern for Node (N) Implementations

Node files follow a simpler, sequential numbering system without platform or step designations:

```
N{four-digit-number}.R
```

Where:
- **{four-digit-number}**: A sequential four-digit number (e.g., 0001, 0002, ..., 9999)

### Node (N) Definition

Nodes represent individual utility scripts that serve as the fundamental building blocks of the system. Nodes are platform-agnostic and perform specific, reusable operations that can be leveraged by derivations and sequences. Examples include:

- Data export utilities
- Configuration setup scripts
- System maintenance tasks
- Data validation functions
- Ad-hoc analytical scripts
- Common transformation utilities

Nodes are designed to be atomic, reusable components that implement specific functionality used across multiple derivations and sequences.

### Rule for Multiple Number Systems in D/S/M Files

When D/S/M filenames contain multiple numeric identifiers:
1. The type prefix and platform prefix ('P') MUST always be included
2. Only the step suffix may be omitted in cases where no steps exist
3. All numeric identifiers must use two digits (01 not 1)

### Examples

- `D01_P0001_00.R`: Implementation of D01 step 00 for Amazon platform (01)
- `S00_P0007_00.R`: Implementation of S00 step 00 for Cyberbiz platform (07)
- `M01_P0002_00.R`: Implementation of M01 for Official Website platform (02)
- `D02_P0006_03.R`: Implementation of D02 step 03 for eBay platform (06)
- `N0001.R`: Node utility #0001 (Data Export Utility)
- `N0204.R`: Node utility #0204 (Configuration Validator)
- `N1024.R`: Node utility #1024 (Logging Framework)

## Relationship with Update Script Naming Convention (R0007)

This naming convention extends and complements R0007, which specifies the general pattern `AABB_C_DE_description.R`. For derivation implementations:

- The file type prefix (`D01_P0001_`) provides a direct link to derivation and platform
- R0007 naming can be maintained in git commits, logs, and documentation
- Both naming patterns can co-exist in the same repository

### AABB_C_DE Correspondence

When both naming conventions need to be referenced:
- `AA`: Maps to derivation number (`01` for D01)
- `BB`: Maps to step number (`00`, `01`, etc.)
- `C`: Can be used for sub-steps if needed
- `DE`: Maps to module reference as usual

## Implementation Guidelines

### 1. File Creation

When creating a new derivation implementation file:

1. Identify the derivation being implemented (e.g., D01)
2. Identify the platform (e.g., 06 for eBay) from R38
3. Identify the specific step being implemented (e.g., 00)
4. Create the file with the name `D{derivation}_P{platform}_{step}.R`
5. Include clear comments linking to both the derivation and platform

### 2. File Content Header

Each implementation file should have a standardized header that reflects its purpose:

```r
# For derivations:
# D01_P0006_00.R
# Implementation of D01 step 00 (Import External Raw Data) for eBay platform (06/EBY)
#
# This script implements the platform-specific version of the D01_00 derivation step
# as defined in D01/D01.md.
#
# Platform: eBay (06/EBY) per R0038 Platform Numbering Convention

# For sequences:
# S00_P0007_00.R
# Implementation of S00 step 00 (Pre-Process API Data) for Cyberbiz platform (07/CBZ)
#
# This script implements the platform-specific version of the S00_00 sequence step
# as defined in S00/S00.md.
#
# Platform: Cyberbiz (07/CBZ) per R0038 Platform Numbering Convention

# For modules:
# M01_P0001_00.R
# Implementation of M01 (Customer Analysis Module) for Amazon platform (01/AMZ)
#
# This script implements the platform-specific version of the M01 module
# as defined in M01/M01.md.
#
# Platform: Amazon (01/AMZ) per R0038 Platform Numbering Convention

# For nodes:
# N0001.R
# Data Export Utility Node
#
# This script implements a platform-agnostic utility for exporting data
# to various formats (CSV, Excel, JSON).
#
# Node utilities are designed to be atomic, reusable components that can be
# leveraged by multiple derivations and sequences.
```

### 3. Directory Structure

Implementation files MUST be organized in the 00_principles directory with the following specific hierarchical structure:

```
00_principles/
  |-- D01/                          # Derivation type directory
  |   |-- D01.md                    # Abstract derivation definition (NOT D01_dna_analysis.md)
  |   |-- platforms/                # Platform implementations directory
  |       |-- 01/                   # Amazon platform directory
  |       |   |-- D01_P0001_00.R      # Amazon implementation step 00
  |       |   |-- D01_P0001_01.R      # Amazon implementation step 01
  |       |   `-- ...
  |       |-- 07/                   # Cyberbiz platform directory
  |           |-- D01_P0007_00.R      # Cyberbiz implementation step 00
  |           `-- ...
  |
  |-- D02/                          # Another derivation directory
  |   |-- D02.md                    # Abstract definition for D02
  |   |-- platforms/                # And so on...
  |
  |-- S00/                          # Sequence type directory
  |   |-- S00.md                    # Abstract sequence definition 
  |   |-- platforms/                # Platform implementations directory
  |       |-- 07/                   # Cyberbiz platform directory
  |           |-- S00_P0007_00.R      # Cyberbiz implementation
  |           `-- ...
  |
  |-- M01/                          # Module type directory
  |   |-- M01.md                    # Abstract module definition
  |   |-- functions/                # Shared module functions
  |   |   |-- fn_xxx.R              # Function implementation
  |   |   `-- ...
  |   |-- platforms/                # Platform-specific implementations
  |       |-- 01/                   # Amazon platform directory
  |           |-- M01_P0001_00.R      # Amazon implementation
  |           `-- ...
  |
  |-- nodes/                        # Single directory for ALL nodes
      |-- N0001.R                   # Data Export Utility node
      |-- N0002.R                   # Configuration Validator node
      |-- N0003.R                   # Logging Framework node
      |-- ...                       # All nodes in flat structure
```

Note: The directory structure MUST use the exact naming pattern shown above. For example, derivation files MUST be stored in `D01/` directories (not in directories named `D01_dna_analysis/` or similar). The abstract definition file MUST be named exactly `D01.md` (not `D01_dna_analysis.md` or similar).

## Benefits

### Benefits for D/S/M Components

1. **Clear Traceability**: Direct mapping between abstract definitions and implementation files
2. **Platform Clarity**: Explicit identification of which platform an implementation serves through the 'P' prefix
3. **Step Identification**: Clear indication of which step is being implemented
4. **Disambiguation**: The 'P' prefix prevents confusion between platform numbers and other numerical identifiers
5. **Compatibility**: Works alongside existing naming conventions
6. **Extensibility**: Allows for future additions of other prefixed identifiers if needed

### Benefits for Node Components

1. **Simplicity**: Clean, sequential numbering without complex prefixes
2. **Platform Independence**: Encourages creation of reusable, platform-agnostic utilities
3. **Global Addressability**: Each node has a unique, global identifier
4. **Scalability**: Four-digit scheme provides capacity for 9999 unique utilities
5. **Composability**: Makes it easy to build derivations and sequences from reusable nodes

## Relationship to Other Rules

This rule is related to:

- **R0007 (Update Script Naming Convention)**: Complements the general naming pattern
- **R0038 (Platform Numbering Convention)**: Uses platform numbers to identify the target platform
- **R0039 (Derivation Platform Independence)**: Supports the implementation of platform-independent components
- **R0041 (Derivation Folder Structure)**: Complements the directory structure with consistent file naming

## Implementation Timeline

This implementation naming convention is effective immediately for all new M/D/S implementation files. Existing files should be renamed to conform to this standard as part of regular maintenance cycles.

## Special Remarks

### Remarks on the 'P' Prefix for D/S/M Components

The explicit 'P' prefix before platform numbers serves several critical purposes:

1. **Semantic Clarity**: Explicitly denotes the number as a platform identifier
2. **Future-proofing**: Prevents conflicts if additional numbered identifiers are added later
3. **Parsing Reliability**: Makes automated tools more reliable when processing filenames
4. **Consistency**: Follows the pattern of other prefixed identifiers in the system
5. **Error Prevention**: Reduces chance of misinterpreting the platform number as another component

The minimal additional length (one character) is outweighed by these significant benefits to clarity, maintainability, and system integrity.

### Remarks on Node Components

Node components adopt a different paradigm due to their fundamental nature:

1. **Atomic Utilities**: Nodes are the basic building blocks of the system
2. **Platform Agnosticism**: Nodes should work across all platforms whenever possible
3. **Simple Addressing**: Sequential global numbering emphasizes reusability
4. **Functional Composition**: Derivations and sequences should be built by composing nodes
5. **Flat Organization**: A flat structure encourages discovery and reuse

This approach reflects the conceptual model where nodes serve as foundational building blocks that derivations and sequences orchestrate in platform-specific ways.
