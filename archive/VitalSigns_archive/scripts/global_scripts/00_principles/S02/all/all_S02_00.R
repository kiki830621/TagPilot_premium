autoinit()

dbConnect_from_list("processed_data")
export_duckdb_dataframes(con=processed_data,overwrite = TRUE)

dbConnect_from_list("app_data")
export_duckdb_dataframes(con=app_data,overwrite = TRUE)

dbConnect_from_list("raw_data")
export_duckdb_dataframes(con=raw_data,overwrite = TRUE)

autodeinit()
