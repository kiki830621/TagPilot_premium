# D01_01.R problem log
1. The temp data should be named with different name. Change data.frame cleansed data to df_amazon_sales___cleansed
2. check incorrect data.frame. The data.frame should be df_amazon_sales (if (dbExistsTable(raw_data, "df_amazon_sales"))).
3.  is.na check for amazon_order_id and purchase_date instead of customer_id and time.
4.  mutate time from purchase_date.
5.  cleanse_data.df_amazon_sales should always be overwritten in this step.
6.  NA with specified data type: mutate(across(where(is.character), ~na_if(., NA_character_))). 





「df_[platform]_sales」



Change naming cloumn: operation__columnname_by_at



Remind: first date is min(date); not first(date)

first_cols --->>> first_cols and min_cols
