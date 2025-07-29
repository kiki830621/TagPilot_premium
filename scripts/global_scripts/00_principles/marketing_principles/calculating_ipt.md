# **Calculating IPT (Inter-Purchase Time)**



This document explains how the function calculates the Inter-Purchase Time (IPT) when multiple orders occur in one day by aggregating to the earliest order time of that day.



**Aggregation Step**



For each customer and each day, the function groups all orders and calculates the **earliest time** on that day using the min() function on the specified time field. This aggregated time is stored as first_time_by_date. By doing so, multiple orders within the same day are reduced to a single representative timestamp — the earliest order time.



**IPT Calculation**



For each customer, after daily aggregation, IPT is calculated as the difference (in days) between the first_time_by_date of the current day and the first_time_by_date of the previous day. This is achieved using the shift() function.



**Example**



Consider the following orders for a single customer:



**January 1, 2021**

​	•	Order at 08:00

​	•	Order at 12:00



**Aggregated Record for January 1:**

​	•	first_time_by_date = 2021-01-01 08:00



------



**January 2, 2021**

​	•	Order at 09:30

​	•	Order at 14:00



**Aggregated Record for January 2:**

​	•	first_time_by_date = 2021-01-02 09:30



------



**January 3, 2021**

​	•	Order at 10:15



**Aggregated Record for January 3:**

​	•	first_time_by_date = 2021-01-03 10:15



------



**IPT Calculation**

​	•	**For January 2:**

IPT = (First order time on January 2) − (First order time on January 1)

= 2021-01-02 09:30 − 2021-01-01 08:00

= 25.5 hours ≈ **1.06 days**

​	•	**For January 3:**

IPT = (First order time on January 3) − (First order time on January 2)

= 2021-01-03 10:15 − 2021-01-02 09:30

= 24.75 hours ≈ **1.03 days**



**Summary**



By taking the **earliest** order time in each day (using min(get(time))), the function ensures that only one record per day is used to represent the customer’s order behavior. The IPT is then computed as the day difference between these earliest times on consecutive days, which effectively resolves the issue of having multiple orders in a single day.