---
id: "MP0000"
title: "Axiomatization System"
type: "meta-meta-principle"
date_created: "2025-04-02"
author: "Claude"
influences:
  - "MP0001": "Primitive Terms and Definitions"
  - "MP0002": "Structural Blueprint"
  - "MP0013": "Principle of Analogy of Statute Law"
  - "MP0014": "Change Tracking Principle"
  - "MP0015": "Currency Principle"
  - "MP0022": "Instance vs. Principle"
  - "MP0028": "Documentation Organization"
extends:
  - "MP0028": "Documentation Organization Meta-Principle"
---

# Axiomatization System

This meta-principle establishes a formal axiomatic system for organizing principles, creating a consistent logical framework for the entire precision marketing system.

## Core Concept

Principles should form a coherent axiomatic system where foundational concepts are explicitly defined, relationships between concepts are formalized as axioms, and derived principles follow through logical inference. This enables verification of consistency, derivation of new principles, and rigorous reasoning about system design.

## Axiomatic Structure

### 1. Elements of the Axiomatic System

- **Primitive Terms**: Fundamental concepts that cannot be defined in terms of simpler concepts.
- **Axioms**: Self-evident or assumed statements about primitive terms.
- **Inference Rules**: Logical methods for deriving new statements from axioms.
- **Theorems**: Derived principles that follow logically from axioms and inference rules.
- **Corollaries**: Direct consequences of theorems that require minimal additional proof.

### 2. Multi-Level Conceptual Framework

The system is organized into multiple conceptual frameworks that serve different purposes:

#### 2.1 Principle Framework (How)

Principles are organized in a multi-level framework that categorizes them based on their role and scope:

| Level | Code | Purpose | Nature | Example |
|-------|------|---------|--------|---------|
| **Meta-Principles** | MP | Govern principles | Abstract, foundational | Axiomatization System, Primitive Terms |
| **Principles** | P | Guide implementation | Practical, broad | Project Principles, Data Integrity |
| **Rules** | R | Define specific implementations | Concrete, specific | Roxygen Guide, YAML Configuration |
| **Rule Composites** | RC | Aggregate multiple rules | Comprehensive templates | Function Template, Configuration Pattern |

The Rule Composite (RC) classification was added to accommodate templates and patterns that coherently integrate multiple atomic rules. This extension is philosophically aligned with John Locke's epistemology, which distinguishes between simple ideas (received directly through sensation) and complex ideas (formed by the mind through combination of simple ideas). In our framework, atomic Rules (R) function like Locke's simple ideas, while Rule Composites (RC) function like Locke's complex ideas - they're created by combining and integrating multiple atomic rules into coherent, sophisticated patterns.

#### 2.2 Organizational Framework (What)

Functional organization is managed through a separate framework:

| Level | Code | Purpose | Nature | Example |
|-------|------|---------|--------|---------|
| **Modules** | M | Organize minimal purpose functionality | Self-contained components | Testing Module, Configuration Module |
| **Sequences** | S | Organize multi-purpose processes | Step-by-step workflows | Customer DNA, Marketing Campaign |
| **Derivations** | D | Document complete transformation processes | Raw data to app flows | Full Analytics Pipeline |

This creates a clear separation between **how** to implement (MP/P/R) and **what** to implement (M/S/D).

#### 2.3 Company-Specific Implementation

The organizational framework is implemented in a company-specific manner:

1. Each company has its own directory within the `13_modules` folder
2. Within each company directory, the M/S/D organizational units are implemented as folders
3. Each module, sequence, or derivation folder may contain multiple related files
4. This structure allows for company-specific customizations while maintaining a consistent organizational pattern

Each level in the principle framework serves a distinct purpose:

#### Meta-Principles (MP)
- **Purpose**: Govern how principles themselves are structured and related
- **Nature**: Abstract, conceptual, foundational
- **Scope**: System-wide architecture and organizational concepts
- **Examples**: Axiomatization system, primitive terms, structural blueprint
- **Identification**: Prefix "MP" followed by number (e.g., MP0001)

#### Principles (P)
- **Purpose**: Provide core guidance for implementation
- **Nature**: Conceptual but practical, actionable guidelines
- **Scope**: Broad implementation patterns and approaches
- **Examples**: Project principles, script separation, data integrity
- **Identification**: Prefix "P" followed by number (e.g., P03) 

#### Rules (R)
- **Purpose**: Define specific implementation details
- **Nature**: Concrete, specific, directly applicable
- **Scope**: Narrow implementation techniques and specific patterns
- **Examples**: Bottom-up construction guide, roxygen documentation, YAML configuration
- **Identification**: Prefix "R" followed by number (e.g., R16)

#### Rule Composites (RC)
- **Purpose**: Provide comprehensive templates that integrate multiple rules
- **Nature**: Concrete, comprehensive, directly applicable
- **Scope**: Cross-cutting implementation patterns that address multiple concerns
- **Examples**: Function templates, module organization patterns, unified configuration schemas
- **Identification**: Prefix "RC" followed by number (e.g., RC01)
- **Philosophical Basis**: Analogous to Locke's complex ideas formed by combining simple ideas

### 3. Mapping MP/P/R/RC to Axiomatic Concepts

The MP/P/R/RC system maps to traditional axiomatic concepts in the following way:

| Classification | Axiomatic Role | Description | Example |
|----------------|----------------|-------------|---------|
| **MP** (Meta-Principles) | **Primitive Terms & Axioms** | Foundational definitions and principles | MP0001 (Primitive Terms), MP0023 (Data Source Hierarchy) |
| **MP** (Meta-Principles) | **Inference Rules** | Logic for deriving other principles | MP0019 (Mode Hierarchy) |
| **P** (Principles) | **Theorems** | Derived principles from axioms | P04 (Script Separation), P05 (Data Integrity) |
| **R** (Rules) | **Corollaries** | Specific implementation guidelines | R16 (Bottom-Up Construction), R27 (YAML Configuration) |
| **RC** (Rule Composites) | **Lemmas & Applied Theorems** | Complex patterns integrating multiple corollaries | RC01 (Function Template), RC02 (Configuration Schema) |

The Rule Composite (RC) classification corresponds to lemmas and applied theorems in traditional axiomatic systems - derived results that combine multiple corollaries into a coherent pattern with broader applicability than individual corollaries but more specificity than general theorems.

This mapping allows us to understand how our practical MP/P/R classification relates to the formal concepts in axiomatic systems while maintaining a simpler and more intuitive classification for everyday use.

### 4. Principle Dependencies

Every principle (except primitive terms and axioms) must explicitly document:
- **Derives From**: The principles this principle is based on
- **Influences**: The principles this principle affects
- **Implements**: For rules, which principles they implement
- **Extends**: Principles this principle refines or expands upon
- **Aggregates**: For rule composites, which atomic rules they combine

## Implementation Guidelines

### 1. Document Structure

Each principle document should follow a consistent structure that includes these elements:

```markdown
---
id: "MP0001"             # Principle identifier (MP, P, R, or RC with number)
title: "Short Title"   # Concise title
type: "meta-principle" # Classification (meta-principle, principle, rule, or rule-composite)
date_created: "2025-04-02"
author: "Claude"
derives_from:          # What this principle is based on
  - "MP0000": "Axiomatization System"
influences:            # What this principle affects
  - "MP0002": "Structural Blueprint"
implements:            # For Rules, which principles they implement
  - "P07": "App Construction Principles"
extends:               # What this principle expands upon
  - "MP0028": "Documentation Organization"
aggregates:            # For Rule Composites, which atomic rules they combine
  - "R16": "Bottom-Up Construction Guide"
  - "R27": "YAML Configuration"
---

# Principle Title

## Core Concept
[Brief explanation of the principle's central idea]

## [Main Content Sections]
[Detailed explanation, guidelines, examples]

## Relationship to Other Principles
[Explanation of how this principle relates to others]

## [Additional Sections as Needed]
[Implementation guidelines, best practices, etc.]
```

The YAML front matter at the beginning of each file is essential, as it formally documents the principle's classification and relationships in a machine-readable format.

### 2. Cross-Referencing System

Principles should be cross-referenced using the MP/P/R/RC notation:

- **MP<number>**: References a Meta-Principle (e.g., MP0023 refers to the Data Source Hierarchy Meta-Principle)
- **P<number>**: References a Principle (e.g., P04 refers to the Script Separation Principle)
- **R<number>**: References a Rule (e.g., R16 refers to the Bottom-Up Construction Guide Rule)
- **RC<number>**: References a Rule Composite (e.g., RC01 refers to the Function Template Rule Composite)

For more specific references within a principle, you can use section numbers:

- **MP0023.4**: References section 4 of Meta-Principle 23
- **P04.3.2**: References section 3.2 of Principle 04
- **RC01.3**: References section 3 of Rule Composite 01

### 3. Derivation and Interpretation Documentation

For Principles (P) and Rules (R), include a formal derivation section in the YAML front matter using the `derives_from` field:

```yaml
---
id: "P04"
title: "Script Separation"
type: "principle"
date_created: "2025-04-02"
author: "Claude"
derives_from:
  - "MP0002": "Structural Blueprint"
  - "P03": "Project Principles"
  - "MP0001": "Primitive Terms and Definitions"
influences:
  - "P07": "App Construction Principles"
  - "P17": "App Construction Function"
---
```

When documenting interpretations of principles for new or edge cases, follow the interpretation documentation format described in MP0013.2 to capture the reasoning process:

For Rules that implement specific Principles, use the `implements` field:

```yaml
---
id: "R16"
title: "Bottom-Up Construction Guide"
type: "rule"
date_created: "2025-04-02"
author: "Claude"
implements:
  - "P07": "App Construction Principles"
related_to:
  - "P17": "App Construction Function"
---
```

Within the body of the document, you can also include a more detailed derivation section:

```markdown
## Derivation

This principle derives from:
1. MP0023 (Data Source Hierarchy): Establishes the primary data source patterns
2. P07 (App Construction Principles): Defines core implementation approaches

Through application of:
1. Hierarchical composition (inference rule I1)
2. Scope limitation (inference rule I2)
```

For interpretations of principles in new contexts, document using the case law format from MP0013:

```markdown
## Interpretation for [New Context]

### Situation
[Description of the new context or edge case not explicitly covered]

### Interpretation Approach
1. Applied [interpretation method] per MP0013.[section]
2. Identified core purpose: [principle's core purpose]

### Determination
[New context] should be handled by:
- [Specific application or adaptation of the principle]
- [Reference to related principles or sections]
- [Any necessary modifications or limitations]

### Precedential Value
[Statement of how this interpretation applies to similar future cases]
```

## Inference Rules

The system establishes these fundamental inference rules, which operate analogously to legal interpretation principles as described in MP0013 (Principle of Analogy of Statute Law). These rules serve as the formal mechanisms for principle interpretation and conflict resolution:

### I1. Hierarchical Composition

If X applies to scope S, and Y is contained within S, then X applies to Y unless explicitly excluded. This functions similarly to how constitutional principles apply to all subordinate laws in a legal system, reflecting the hierarchy principle in MP0013.3.2.3.

### I2. Scope Limitation

A principle may restrict the scope of another principle if it explicitly states the limitation. This reflects how specific statutes can create exceptions to general legal principles and aligns with the gap filling and limitation mechanisms described in MP0013.3.1.

### I3. Specificity Precedence

When two principles conflict, the more specific principle takes precedence over the more general one. This mirrors the legal principle that specific provisions override general ones (lex specialis derogat legi generali), which is a core conflict resolution mechanism outlined in MP0013.3.2.1.

### I4. Explicit Override

A principle may explicitly override another principle if it states the override and provides rationale. This is similar to how newer laws can explicitly repeal or modify older ones (lex posterior derogat legi priori), and aligns with the recency principle in MP0013.3.2.2.

### I5. Purposive Interpretation

When literal application of a principle is unclear, interpret it according to its purpose and intent. This aligns with the purposive interpretation approach described in MP0013.2.2, which is especially relevant when dealing with new technologies or methodologies not explicitly covered in the original principle.

### I6. Systematic Coherence

Principles must be interpreted in a way that maintains overall system coherence. This reflects the legal principle that interpretations should harmonize with the broader legal framework, following the systematic interpretation approach described in MP0013.2.3.

### I7. Authorized Exception

A lower-level principle (Rule or Principle) may create a narrow exception to a higher-level principle (Meta-Principle) only when:
1. The higher-level principle explicitly allows for such exceptions
2. The exception is limited in scope and does not undermine the core purpose of the higher-level principle
3. The exception and its rationale are explicitly documented

This reflects how regulations in legal systems can create specific exceptions to constitutional principles when authorized by the constitution itself.

## Cross-Level Conflict Resolution

When principles at different levels (MP, P, R) appear to conflict, the following framework guides resolution:

### 1. MP vs P/R Conflicts

When a Meta-Principle conflicts with a Principle or Rule:

1. **Hierarchical Precedence**: The Meta-Principle generally takes precedence over the Principle or Rule.
2. **Authorized Exceptions**: A Principle or Rule may create a narrow exception to a Meta-Principle only when:
   - The Meta-Principle explicitly allows for such exceptions
   - The exception is limited in scope and doesn't undermine the Meta-Principle's core purpose
   - The exception is explicitly documented with clear rationale

3. **Implementation Gap**: Sometimes what appears as a conflict is actually an implementation gap, where the lower-level principle needs refinement to properly implement the higher-level concept.

### 2. P vs R Conflicts

When a Principle conflicts with a Rule:

1. **Hierarchical Precedence**: The Principle generally takes precedence over the Rule.
2. **Domain Specificity**: Rules may create context-specific implementations of Principles that appear to conflict but actually represent appropriate adaptations to particular domains.
3. **Evolution Signal**: Persistent conflicts between Principles and their implementing Rules may signal that the Principle needs to evolve to accommodate new understanding.

### 3. Same-Level Conflicts

When principles at the same level conflict (MP vs MP, P vs P, or R vs R):

1. **Apply the Conflict Resolution Hierarchy** from MP0013.3.2:
   - Specificity: More specific principles override more general ones within their domain
   - Recency: More recently established principles supersede older ones when addressing the same issue
   - Purpose Analysis: Determine which principle's purpose would be more fundamentally compromised

### 4. Documentation of Conflicts and Resolutions

All significant conflicts between principles and their resolutions should be documented as precedents:

1. **Conflict Description**: Clearly describe the apparent conflict between principles
2. **Resolution Approach**: Document which resolution mechanism was applied
3. **Reasoning**: Explain the reasoning process for the resolution
4. **Scope of Resolution**: Define whether the resolution applies narrowly or broadly
5. **Future Guidance**: Provide guidance for similar conflicts

These documented precedents form the system's "case law" and should be maintained in a searchable repository.

## Verification and Evolution Process

### 1. Consistency Checking

Periodically verify that the principle system is internally consistent:

1. No principle contradicts an axiom without explicit override
2. No two axioms contradict each other
3. All derived principles have valid derivation paths from axioms

### 2. Completeness Analysis

Identify gaps in the axiomatic system:

1. Concepts used without definition
2. Assumptions made without axiomatic foundation
3. Areas of the system not covered by principles

### 3. Precedent Documentation

Maintain a repository of principle interpretations that serve as precedents:

1. Document significant applications of principles to new contexts
2. Record the reasoning process and interpretation methods used
3. Organize interpretations to be searchable by principle and context

### 4. Principle Amendment Process

Follow the formal amendment process outlined in MP0013.4 when principles need to be updated:

1. Identify when existing principles are insufficient or outdated
2. Draft proposed amendments with clear rationale
3. Submit for review and critique
4. Adopt and integrate into the principle system
5. Update cross-references and document relationships

## Axiomatization Roadmap

### Phase 1: Classification

1. Review existing principles and classify as axioms, theorems, or corollaries
2. Identify and document primitive terms used across principles
3. Formalize implicit axioms that underlie existing principles

### Phase 2: Formalization

1. Update principle documentation to include axiomatic elements
2. Add cross-references between related principles
3. Document derivation chains for theorems and corollaries

### Phase 3: Verification

1. Check for consistency across the principle system
2. Resolve any contradictions or ambiguities
3. Identify and fill gaps in the axiomatic coverage

## Benefits of Axiomatization

1. **Logical Consistency**: Ensures all principles work together harmoniously
2. **Derivation Power**: Enables derivation of new principles when needed
3. **Formal Verification**: Provides mechanisms to prove design correctness
4. **Knowledge Transfer**: Creates clearer documentation for onboarding
5. **Completeness Assessment**: Identifies gaps in principle coverage
6. **Predictability**: Provides a structured framework for consistent application of principles, as noted in MP13
7. **Adaptability**: Enables systematic evolution and application to new contexts without requiring constant revision
8. **Institutional Memory**: Documents reasoning and precedents for knowledge continuity

## Relationship to Other Principles

This meta-principle builds upon:

1. **Documentation Organization Meta-Principle** (MP0028): Extends organizational guidelines to include axiomatic structure
2. **Terminology Axiomatization** (MP0029): Provides primitive terms and baseline axioms for the system
3. **Instance vs. Principle** (MP0022): Clarifies scope of axiomatic system (principles, not instances)
4. **Principle of Analogy of Statute Law** (MP0013): Establishes interpretation methodologies and evolution mechanisms based on legal system analogies

## Example Application

Let's consider how this applies to three existing principles:

1. **Data Source Hierarchy** (MP0023) is classified as a **Meta-Principle** because it:
   - Establishes fundamental relationships between data sources
   - Defines architectural concepts that govern other principles
   - Introduces primitive terms (App Layer, Processing Layer, etc.)

2. **Data Integrity** (P05) is classified as a **Principle** because it:
   - Provides broad implementation guidance
   - Defines practical approaches to handling data
   - Is conceptual but actionable

3. **Platform-Neutral Code** (R26) is classified as a **Rule** because it:
   - Follows directly from higher-level principles like Mode Hierarchy (MP0019)
   - Provides specific implementation techniques
   - Is concrete and directly applicable to coding

## Conclusion

By transforming the principles into a formal axiomatic system, we create a more rigorous foundation for system design and development. This meta-principle guides the evolution of the principle documentation toward greater precision, consistency, and derivation power, enabling formal reasoning about system properties and requirements.
