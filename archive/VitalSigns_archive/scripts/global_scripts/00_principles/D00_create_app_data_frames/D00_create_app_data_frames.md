---
id: "D00"
title: "Application Data Tables Definition"
type: "derivation"
date_created: "2025-04-16"
date_modified: "2025-04-16"
author: "Claude"
related_to:
  - "MP058": "Database Table Creation Strategy"
  - "R080": "Database Naming Conventions"
  - "R092": "Universal DBI Approach"
---

# D00: CREATE APP DATA TABLES

This derivation document defines the core data tables used by the Precision Marketing application. Each table is presented in both NSQL (Natural SQL Language) for human readability and RSQL (R SQL) for programmatic execution.

## Derivation Steps

### D00_01_P00: Customer Profile Table

```NSQL
CREATE df_customer_profile AT app_data
=== CREATE TABLE df_customer_profile ===
CREATE OR REPLACE TABLE df_customer_profile (
  customer_id INTEGER,
  buyer_name VARCHAR,
  email VARCHAR,
  platform_id INTEGER NOT NULL,
  display_name VARCHAR GENERATED ALWAYS AS (buyer_name || ' (' || email || ')') VIRTUAL,
  PRIMARY KEY (customer_id, platform_id)
);

CREATE INDEX IF NOT EXISTS idx_df_customer_profile_platform_id_df_customer_profile ON df_customer_profile(platform_id);
```



The code can be translated to RSQL:

```RSQL
generate_create_table_query(
  con = app_data,
  or_replace = TRUE,
  target_table = "df_customer_profile",
  source_table = NULL,
  column_defs = list(
    list(name = "customer_id", type = "INTEGER"),
    list(name = "buyer_name", type = "VARCHAR"),
    list(name = "email", type = "VARCHAR"),
    list(name = "platform_id", type = "INTEGER", not_null = TRUE), 
    list(name = "display_name", type = "VARCHAR",
         generated_as = "buyer_name || ' (' || email || ')'")
  ),
  primary_key = c("customer_id","platform_id"),
  indexes = list(
    list(columns = "platform_id")
  )
)
```

## D00_02_P00: df_dna_by_customer

```NSQL
CREATE df_dna_by_customer AT app_data
=== CREATE TABLE df_dna_by_customer ===
CREATE TABLE df_dna_by_customer (
  customer_id INTEGER NOT NULL,
  ipt DOUBLE,
  total_spent DOUBLE,
  times INTEGER,
  zipcode BOOLEAN,
  state BOOLEAN,
  lat BOOLEAN,
  lng BOOLEAN,
  ipt_mean DOUBLE,
  m_value DOUBLE,
  sigma_hnorm_mle DOUBLE,
  sigma_hnorm_bcmle DOUBLE,
  m_ecdf DOUBLE,
  m_label ENUM('Low Value', 'Medium Value', 'High Value'),
  ni INTEGER,
  date TIMESTAMP,
  sum_spent_by_date DOUBLE,
  count_transactions_by_date INTEGER,
  min_time_by_date TIMESTAMP,
  ni_2 INTEGER,
  min_time TIMESTAMP,
  payment_time TIMESTAMP,
  difftime INTERVAL,
  nes_ratio DOUBLE,
  nes_status ENUM('N', 'E0', 'S1', 'S2', 'S3') DEFAULT 'N',
  f_value INTEGER,
  f_ecdf DOUBLE,
  f_label ENUM('Low Frequency', 'Medium Frequency', 'High Frequency'),
  r_value DOUBLE,
  r_ecdf DOUBLE,
  r_label ENUM('Long Inactive', 'Medium Inactive', 'Recent Buyer'),
  mle DOUBLE,
  wmle DOUBLE,
  cai DOUBLE,
  cai_ecdf DOUBLE,
  cai_label ENUM('Gradually Inactive', 'Stable', 'Increasingly Active'),
  pcv DOUBLE,
  total_sum DOUBLE,
  clv DOUBLE,
  time_first TIMESTAMP,
  nt DOUBLE,
  time_first_to_now DOUBLE,
  e0t DOUBLE,
  ge DOUBLE,
  ie DOUBLE,
  be DOUBLE,
  cri DOUBLE,
  cri_ecdf DOUBLE,
  be2 DOUBLE,
  nrec ENUM('nrec', 'rec'),
  nrec_prob DOUBLE,
  platform_id INTEGER NOT NULL
);
```

```RSQL
sqltest<- generate_create_table_query(
  con = conn,
  target_table = "df_dna_by_customer",
  source_table = NULL,
  column_defs = list(
    list(name = "customer_id", type = "INTEGER", not_null = TRUE),
    list(name = "ipt", type = "DOUBLE"),
    list(name = "total_spent", type = "DOUBLE"),
    list(name = "times", type = "INTEGER"),
    list(name = "zipcode", type = "BOOLEAN"),
    list(name = "state", type = "BOOLEAN"),
    list(name = "lat", type = "BOOLEAN"),
    list(name = "lng", type = "BOOLEAN"),
    list(name = "ipt_mean", type = "DOUBLE"),
    list(name = "m_value", type = "DOUBLE"),
    list(name = "sigma_hnorm_mle", type = "DOUBLE"),
    list(name = "sigma_hnorm_bcmle", type = "DOUBLE"),
    list(name = "m_ecdf", type = "DOUBLE"),
    list(name = "m_label", type = "ENUM('Low Value', 'Medium Value', 'High Value')"),
    list(name = "ni", type = "INTEGER"),
    list(name = "date", type = "TIMESTAMP"),
    list(name = "sum_spent_by_date", type = "DOUBLE"),
    list(name = "count_transactions_by_date", type = "INTEGER"),
    list(name = "min_time_by_date", type = "TIMESTAMP"),
    list(name = "ni_2", type = "INTEGER"),
    list(name = "min_time", type = "TIMESTAMP"),
    list(name = "payment_time", type = "TIMESTAMP"),
    list(name = "difftime", type = "INTERVAL"),
    list(name = "nes_ratio", type = "DOUBLE"),
    list(name = "nes_status", type = "ENUM('N', 'E0', 'S1', 'S2', 'S3')", default="'N'"),
    list(name = "f_value", type = "INTEGER"),
    list(name = "f_ecdf", type = "DOUBLE"),
    list(name = "f_label", type = "ENUM('Low Frequency', 'Medium Frequency', 'High Frequency')"),
    list(name = "r_value", type = "DOUBLE"),
    list(name = "r_ecdf", type = "DOUBLE"),
    list(name = "r_label", type = "ENUM('Long Inactive', 'Medium Inactive', 'Recent Buyer')"),
    list(name = "mle", type = "DOUBLE"),
    list(name = "wmle", type = "DOUBLE"),
    list(name = "cai", type = "DOUBLE"),
    list(name = "cai_ecdf", type = "DOUBLE"),
    list(name = "cai_label", type = "ENUM('Gradually Inactive', 'Stable', 'Increasingly Active')"),
    list(name = "pcv", type = "DOUBLE"),
    list(name = "total_sum", type = "DOUBLE"),
    list(name = "clv", type = "DOUBLE"),
    list(name = "time_first", type = "TIMESTAMP"),
    list(name = "nt", type = "DOUBLE"),
    list(name = "time_first_to_now", type = "DOUBLE"),
    list(name = "e0t", type = "DOUBLE"),
    list(name = "ge", type = "DOUBLE"),
    list(name = "ie", type = "DOUBLE"),
    list(name = "be", type = "DOUBLE"),
    list(name = "cri", type = "DOUBLE"),
    list(name = "cri_ecdf", type = "DOUBLE"),
    list(name = "be2", type = "DOUBLE"),
    list(name = "nrec", type = "ENUM('nrec', 'rec')"),
    list(name = "nrec_prob", type = "DOUBLE"),
    list(name = "platform_id", type = "INTEGER", not_null = TRUE)
  ),
)
```