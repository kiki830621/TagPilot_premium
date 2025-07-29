# P71: Row-Aligned Tables Principle

**Principle**: When database tables maintain the same row order and share a common key, they should be marked as row-aligned to enable optimized operations.

## Description

Row-aligned tables have identical row counts and maintain the same ordering of records based on a common key. This structure permits the use of highly optimized row-wise operations like `bind_cols()` instead of more expensive join operations. Such tables should be clearly documented and maintained to preserve their alignment property.

## Rationale

In the MAMBA application, tables like `df_customer_profile` and `df_dna_by_customer`:
1. Share the same primary key (`customer_id`)
2. Maintain the same row ordering
3. Have corresponding rows at the same positions

This specialized structure enables:
- Significantly faster data merging using `bind_cols()` instead of `left_join()`
- Reduced memory usage during analytics operations
- Simplified data processing code

## Implementation

1. **Explicit Documentation**: Row-aligned tables should be clearly marked in database documentation:
   ```
   Tables df_customer_profile and df_dna_by_customer are row-aligned by customer_id
   ```

2. **Structural Verification**: Add validation routines that verify row alignment is maintained:
   ```r
   verify_row_alignment <- function(table1, table2, key_column) {
     identical(table1[[key_column]], table2[[key_column]])
   }
   ```

3. **Schema Enforcement**: When modifying row-aligned tables, operations must maintain alignment:
   - Insertions must be made at the same positions in both tables
   - Deletions must affect the same rows across tables
   - Sorting operations must be applied identically

4. **Data Access Patterns**: Prefer column binding over joins when working with row-aligned tables:
   ```r
   # Preferred for row-aligned tables
   combined_data <- bind_cols(df_customer_profile, df_dna_by_customer[, -1])
   
   # Less efficient for row-aligned tables
   combined_data <- left_join(df_customer_profile, df_dna_by_customer, by="customer_id")
   ```

5. **Consistency Checks**: Periodically verify that row alignment remains intact after data modifications

## Violation Scenarios

1. Records added to one table but not the corresponding row-aligned table
2. Tables sorted independently, breaking row-order correspondence
3. Records deleted from one table without removing the corresponding rows in aligned tables
4. Row alignment not verified after import/export operations

## Related Principles

- MP43 (Database Documentation Principle)
- SLN01 (Type Safety)
- MP45 (Automatic Data Availability Detection)