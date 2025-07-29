# MP0029: No Fake Data

## Rule

**Never generate or use fake/mock data in production environments.**

## Explanation

The integrity of our data systems is paramount. Using fake or mock data in production environments can lead to:

1. **False insights**: Decisions made on synthetic data lack real-world validity
2. **Data contamination**: Fake data can mix with real data, compromising the entire dataset
3. **Loss of trust**: Stakeholders must have complete confidence in data authenticity
4. **Compliance risks**: May violate regulatory requirements for data accuracy

## Implementation

1. **Development Environment**: 
   - Synthetic data may ONLY be used in isolated development environments
   - Must be clearly labeled as synthetic/mock with timestamp and source
   - Should never be stored in production databases

2. **Testing Environment**:
   - Use anonymized but real data for testing when possible
   - When synthetic data is necessary for testing, it must never be exposed to production systems
   - Test databases must be segregated from production databases

3. **Production Environment**:
   - Only real, validated data should be ingested
   - Mock data generators must be disabled in production code
   - Fallback mechanisms must defer to reporting missing data rather than generating synthetic data

4. **Emergency Protocols**:
   - In case of data access issues, systems should report unavailability
   - Never substitute with generated data to fill gaps
   - Recovery should focus on restoring access to real data sources

5. **Documentation**:
   - All data sources must be documented with their origin and validation methods
   - Data lineage tracking must be implemented to ensure traceability

## Exception Handling

If real data is temporarily unavailable, systems should:

1. Log the unavailability with detailed error information
2. Leave affected data fields empty or NULL
3. Mark reports as "incomplete" or "pending data"
4. Retry accessing real data sources at appropriate intervals
5. Notify relevant stakeholders of the data gap

## Code Implementation

When implementing connections to external data sources:

```r
# CORRECT APPROACH - Handle missing data properly
fetch_data <- function() {
  tryCatch({
    # Attempt to get real data
    real_data <- connect_and_get_data()
    return(real_data)
  }, error = function(e) {
    # Log the error
    log_error("Failed to fetch data", e)
    
    # Return NULL or empty data frame - NEVER fake data
    return(NULL)
  })
}

# Report missing data appropriately
report_data <- function(data) {
  if(is.null(data) || nrow(data) == 0) {
    return("Data currently unavailable. Please check back later.")
  } else {
    return(generate_report(data))
  }
}
```

## Compliance Verification

Regular audits should be conducted to ensure:

1. No synthetic data generators exist in production code
2. All data has proper lineage documentation
3. Exception handling follows the established protocols
4. Testing environments are properly segregated

## Related Principles

This principle works in conjunction with:

- **MP0028 (Avoid Self-Reference)**: Both principles maintain system integrity
- **R21 (One Function One File)**: Helps isolate test data generation in separate files
- **P02 (Data Integrity)**: Reinforces data quality and provenance
- **R44 (Path Modification)**: Ensures proper separation of production and test data paths

By adhering to this principle, we maintain the highest standards of data integrity and ensure that all insights and decisions are based on authentic information.
