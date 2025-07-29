---
id: "MP0022"
title: "Pseudocode Conventions Meta-Principle"
type: "meta-principle"
date_created: "2025-04-03"
date_modified: "2025-04-03"
author: "Claude"
derives_from:
  - "MP0000": "Axiomatization System"
  - "MP0020": "Principle Language Versions"
influences:
  - "MP0023": "Documentation Language Preferences"
  - "P03": "Project Principles"
---

# Pseudocode Conventions Meta-Principle

## Core Principle

Pseudocode in the precision marketing system follows standardized conventions that balance readability, precision, and language-neutral expression of algorithms and procedures. This meta-principle establishes the syntax, style, and organization of pseudocode to ensure consistent, clear algorithmic expression across all documentation.

## Pseudocode Definition and Purpose

Pseudocode is a structured, high-level description of an algorithm or procedure using a language-agnostic syntax that emphasizes logical flow and operations rather than language-specific implementation details. In the precision marketing system, pseudocode serves to:

1. **Express Algorithms**: Document algorithmic solutions independent of programming language
2. **Communicate Procedures**: Describe step-by-step procedures for data processing and analysis
3. **Bridge Gaps**: Create an intermediate representation between natural language and code
4. **Support Implementation**: Guide implementation across different programming languages
5. **Document Logic**: Capture business and computational logic precisely

## Syntax Conventions

### 1. Basic Structure

Pseudocode follows a structured format with clear indentation and organizational elements:

```
ALGORITHM AlgorithmName(parameter1, parameter2, ...)
    # Description or purpose
    # Preconditions
    # Postconditions
    
    # Main procedure
    statements
    
    RETURN result
END ALGORITHM
```

### 2. Control Structures

#### 2.1 Conditional Statements

```
IF condition THEN
    statements
ELSE IF another_condition THEN
    statements
ELSE
    statements
END IF
```

#### 2.2 Loops

```
# Count-controlled loop
FOR variable FROM start TO end [STEP step_size]
    statements
END FOR

# Condition-controlled loop
WHILE condition
    statements
END WHILE

# Post-test loop
DO
    statements
UNTIL condition

# Iteration
FOR EACH item IN collection
    statements
END FOR EACH
```

#### 2.3 Early Exits

```
IF exit_condition THEN
    RETURN early_result
END IF

WHILE condition
    IF break_condition THEN
        BREAK
    END IF
    
    IF skip_condition THEN
        CONTINUE
    END IF
    
    statements
END WHILE
```

### 3. Data Structures

#### 3.1 Variables and Assignment

```
# Variable declaration
LET variable = value

# Multiple assignments
LET x, y, z = 1, 2, 3

# Constant declaration
CONSTANT MAX_VALUE = 100
```

#### 3.2 Arrays and Lists

```
# Array declaration
LET array = [value1, value2, ...]

# Array access
LET item = array[index]

# Array modification
SET array[index] = new_value

# Array operations
LET length = LENGTH(array)
LET subarray = array[start:end]
APPEND value TO array
```

#### 3.3 Dictionaries and Maps

```
# Dictionary declaration
LET dict = {key1: value1, key2: value2, ...}

# Dictionary access
LET value = dict[key]

# Dictionary modification
SET dict[key] = new_value

# Dictionary operations
LET keys = KEYS(dict)
LET values = VALUES(dict)
```

#### 3.4 Sets

```
# Set declaration
LET set = {value1, value2, ...}

# Set operations
LET union = set1 UNION set2
LET intersection = set1 INTERSECT set2
LET difference = set1 DIFFERENCE set2
```

### 4. Functions and Procedures

#### 4.1 Function Definition

```
FUNCTION FunctionName(parameter1, parameter2, ...)
    # Function body
    statements
    
    RETURN result
END FUNCTION
```

#### 4.2 Procedure Definition

```
PROCEDURE ProcedureName(parameter1, parameter2, ...)
    # Procedure body
    statements
    
    # Optional return for procedures with output
    RETURN result
END PROCEDURE
```

#### 4.3 Function/Procedure Call

```
# Function call with result assignment
LET result = FunctionName(arg1, arg2, ...)

# Procedure call
ProcedureName(arg1, arg2, ...)
```

### 5. Objects and Classes

#### 5.1 Class Definition

```
CLASS ClassName
    # Properties
    PROPERTY property1 = default_value
    PROPERTY property2 = default_value
    
    # Constructor
    CONSTRUCTOR(parameter1, parameter2, ...)
        SET this.property1 = parameter1
        SET this.property2 = parameter2
    END CONSTRUCTOR
    
    # Methods
    METHOD MethodName(parameter1, parameter2, ...)
        statements
        RETURN result
    END METHOD
END CLASS
```

#### 5.2 Object Creation and Use

```
# Object creation
LET object = NEW ClassName(arg1, arg2, ...)

# Property access
LET value = object.property

# Property modification
SET object.property = new_value

# Method call
LET result = object.MethodName(arg1, arg2, ...)
```

### 6. Error Handling

```
TRY
    statements
CATCH ErrorType
    error_handling_statements
FINALLY
    cleanup_statements
END TRY
```

### 7. Comments and Documentation

```
# Single-line comment

###
Multi-line comment
that spans several lines
###

# Input parameters:
#   param1: description (type) - constraints
#   param2: description (type) - constraints

# Returns:
#   description (type) - constraints

# Throws:
#   ErrorType: condition that causes this error
```

## Style Guidelines

### 1. Naming Conventions

1. **Variables and Parameters**: 
   - Use camelCase for variables and parameters
   - Use descriptive names that indicate purpose

2. **Functions and Procedures**:
   - Use PascalCase for function and procedure names
   - Use verb phrases that describe the action

3. **Constants**:
   - Use UPPER_SNAKE_CASE for constants
   - Choose names that indicate the fixed value's purpose

4. **Classes**:
   - Use PascalCase for class names
   - Use noun phrases that describe the entity

### 2. Indentation and Formatting

1. **Indentation**: Use 4 spaces for each level of indentation
2. **Line Length**: Limit lines to 80 characters when possible
3. **Block Structure**: Always use explicit block endings (END IF, END FOR, etc.)
4. **Spacing**: Insert blank lines between logical sections

### 3. Comments and Documentation

1. **Header Comments**: Include purpose, inputs, outputs, and constraints
2. **Section Comments**: Describe the purpose of logical sections
3. **Complex Logic**: Comment complex or non-obvious logic
4. **Assumptions**: Document any assumptions or preconditions

### 4. Modularity

1. **Single Responsibility**: Each algorithm should have a single responsibility
2. **Abstraction Levels**: Use functions and procedures to encapsulate logic at appropriate levels
3. **Reusability**: Design for reuse where appropriate

## Specialized Extensions

### 1. Data Processing Extensions

For algorithms focused on data processing, additional constructs are provided:

```
# Data source operations
LET data = LOAD_DATA(source, options)
STORE_DATA(data, destination, options)

# Data transformation
LET transformed = TRANSFORM(data, transformation_type, parameters)

# Data filtering
LET filtered = FILTER(data, condition)

# Grouping and aggregation
LET grouped = GROUP(data, by_columns)
LET aggregated = AGGREGATE(grouped, aggregation_function, parameters)

# Joining
LET joined = JOIN(left_data, right_data, join_type, join_condition)
```

### 2. Machine Learning Extensions

For machine learning algorithms, additional constructs are provided:

```
# Model training
LET model = TRAIN(algorithm, training_data, parameters)

# Model evaluation
LET metrics = EVALUATE(model, test_data, metrics_list)

# Prediction
LET predictions = PREDICT(model, new_data)

# Feature engineering
LET features = EXTRACT_FEATURES(data, feature_definitions)

# Hyperparameter tuning
LET tuned_model = TUNE(algorithm, data, parameter_grid, evaluation_method)
```

### 3. UI Workflow Extensions

For describing UI and user workflows, additional constructs are provided:

```
# User interaction
DISPLAY(component, data)
LET input = GET_INPUT(component, validation_rules)

# Navigation
NAVIGATE_TO(screen, parameters)

# UI state management
SET_STATE(state_variable, new_value)
LET current_value = GET_STATE(state_variable)

# Event handling
ON_EVENT(event_type, component)
    handler_statements
END ON_EVENT
```

## Examples

### Example 1: Customer Segmentation Algorithm

```
ALGORITHM SegmentCustomers(customers, criteria)
    # Segments customers based on specified criteria
    # Inputs:
    #   customers: List of customer records (List<Customer>)
    #   criteria: Segmentation criteria (SegmentationCriteria)
    # Returns:
    #   Dictionary mapping segment names to customer lists (Dict<String, List<Customer>>)
    
    LET segments = {} # Empty dictionary
    
    # Initialize segments based on criteria
    FOR EACH segment_name IN criteria.segment_names
        SET segments[segment_name] = [] # Empty list
    END FOR EACH
    
    # Process each customer
    FOR EACH customer IN customers
        LET segment = DetermineSegment(customer, criteria)
        APPEND customer TO segments[segment]
    END FOR EACH
    
    # Add metadata to each segment
    FOR EACH segment_name IN KEYS(segments)
        LET segment_customers = segments[segment_name]
        SET segments[segment_name] = {
            "customers": segment_customers,
            "count": LENGTH(segment_customers),
            "criteria_used": criteria
        }
    END FOR EACH
    
    RETURN segments
END ALGORITHM

FUNCTION DetermineSegment(customer, criteria)
    # Determine which segment a customer belongs to
    # Implementation depends on specific criteria
    
    IF criteria.type == "RFM" THEN
        RETURN DetermineRFMSegment(customer, criteria.rfm_thresholds)
    ELSE IF criteria.type == "CLV" THEN
        RETURN DetermineCLVSegment(customer, criteria.clv_thresholds)
    ELSE
        THROW InvalidCriteriaError("Unsupported segmentation criteria type")
    END IF
END FUNCTION
```

### Example 2: Hybrid Sidebar Component

```
PROCEDURE RenderHybridSidebar(id, active_module, data_source)
    # Renders a hybrid sidebar with global and module-specific sections
    # Inputs:
    #   id: Component ID (String)
    #   active_module: Current active module (String)
    #   data_source: Data source for populating sidebar (DataSource)
    
    # Get defaults for fallback values
    LET defaults = GetSidebarDefaults()
    
    # Global controls section
    DISPLAY(Section("Global Controls"))
    
    # Distribution channel selection
    LET channels = data_source.GetChannels() OR defaults.channels
    DISPLAY(RadioButtons(
        id: id + "_distribution_channel",
        label: "行銷通路",
        choices: channels,
        selected: channels[0]
    ))
    
    # Product category selection
    LET categories = data_source.GetCategories() OR defaults.categories
    DISPLAY(SelectInput(
        id: id + "_product_category",
        label: "商品種類",
        choices: categories,
        selected: categories[0]
    ))
    
    # Visual separator
    DISPLAY(Separator())
    
    # Module-specific controls
    DISPLAY(Section("Module-Specific Controls"))
    
    # Render controls based on active module
    IF active_module == "micro" THEN
        RenderMicroControls(id, data_source)
    ELSE IF active_module == "macro" THEN
        RenderMacroControls(id, data_source)
    ELSE IF active_module == "target" THEN
        RenderTargetControls(id, data_source)
    END IF
    
    # Apply filters button
    DISPLAY(Button(
        id: id + "_apply_filters",
        label: "套用篩選條件",
        primary: TRUE
    ))
END PROCEDURE
```

## Usage Guidelines

### 1. When to Use Pseudocode

Use pseudocode in these situations:

1. **Algorithm Documentation**: When documenting complex algorithms
2. **Process Description**: When describing multi-step processes
3. **Implementation Guidance**: When providing guidance for implementation
4. **Cross-Language Reference**: When creating reference implementations for multiple languages
5. **Principle Illustration**: When illustrating principles with procedural examples

### 2. How to Create Effective Pseudocode

Follow these steps to create effective pseudocode:

1. **Start High-Level**: Begin with high-level steps and refine incrementally
2. **Focus on Logic**: Emphasize the logical flow, not implementation details
3. **Use Consistent Style**: Apply the conventions consistently
4. **Include Context**: Provide input/output descriptions and constraints
5. **Validate**: Mentally trace through the pseudocode to verify correctness

### 3. Relationship with Actual Code

The pseudocode should:

1. **Abstract Details**: Hide language-specific details while preserving core logic
2. **Maintain Structure**: Preserve the structural elements of the algorithm
3. **Simplify**: Remove boilerplate and focus on the essential operations
4. **Clarify Intent**: Make the intent clearer than it might be in actual code

## Relationship to Other Principles

### Relation to Principle Language Versions (MP0020)

This principle complements MP0020 by:
1. **Offering Pseudocode Formalism**: Providing a specific formalism for algorithmic expression
2. **Bridging Languages**: Creating a bridge between natural language and code implementations
3. **Extending Expression Options**: Adding another way to express principles and procedures

### Relation to Formal Logic Language (MP0021)

This principle complements MP0021 by:
1. **Procedural vs. Declarative**: Offering procedural expression compared to declarative logical formulas
2. **Implementation Focus**: Focusing on implementation aspects rather than logical definitions
3. **Algorithm Expression**: Providing constructs specifically designed for algorithm expression

### Relation to Project Principles (P03)

This principle supports P03 by:
1. **Documentation Standards**: Establishing standards for algorithmic documentation
2. **Code Consistency**: Promoting consistency in algorithm expression
3. **Implementation Guidance**: Providing clear guidance for implementation

## Benefits

1. **Clarity**: Expresses algorithms clearly and concisely
2. **Consistency**: Ensures consistent expression of algorithms across documentation
3. **Accessibility**: Makes algorithms accessible to both technical and non-technical audiences
4. **Language Neutrality**: Avoids bias toward specific programming languages
5. **Implementation Guidance**: Provides clear guidance for implementation
6. **Documentation Value**: Enhances documentation with precise algorithmic descriptions
7. **Knowledge Transfer**: Facilitates knowledge transfer between team members

## Conclusion

The Pseudocode Conventions Meta-Principle establishes a standardized approach to expressing algorithms and procedures in the precision marketing system. By providing consistent syntax, style, and organizational conventions, it ensures that pseudocode serves as an effective bridge between conceptual descriptions and concrete implementations.

This standardized approach enhances documentation, facilitates communication, and provides clear implementation guidance while maintaining language neutrality. By following these conventions, the system achieves consistent, clear algorithmic expression that supports both understanding and implementation.
