Here’s how to implement table partitioning on the Booking table and test query performance, along with a sample report structure.

 Step 1: Create the SQL Script (partitioning.sql)

Save the following SQL commands in a file named partitioning.sql.
  -- partitioning.sql
-- Objective: Implement range partitioning on the Booking table based on start_date

-- Step 1: Create a partitioned version of the Booking table
CREATE TABLE Booking_Partitioned (
    booking_id SERIAL PRIMARY KEY,
    customer_id INT,
    start_date DATE,
    end_date DATE,
    total_amount DECIMAL(10,2)
)
PARTITION BY RANGE (start_date);

-- Step 2: Create partitions by year (you can adjust ranges as needed)
CREATE TABLE booking_2022 PARTITION OF Booking_Partitioned
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');

CREATE TABLE booking_2023 PARTITION OF Booking_Partitioned
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE booking_2024 PARTITION OF Booking_Partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE booking_future PARTITION OF Booking_Partitioned
    FOR VALUES FROM ('2025-01-01') TO (MAXVALUE);

-- Step 3: Copy data from the old Booking table
INSERT INTO Booking_Partitioned (booking_id, customer_id, start_date, end_date, total_amount)
SELECT booking_id, customer_id, start_date, end_date, total_amount FROM Booking;

-- Step 4: Optional — Rename tables if you want to replace the original
-- ALTER TABLE Booking RENAME TO Booking_old;
-- ALTER TABLE Booking_Partitioned RENAME TO Booking;
Step 2: Test Query Performance

Run sample queries before and after partitioning to compare execution times.

Example Queries:
-- Query 1: Fetch bookings within a specific date range
EXPLAIN ANALYZE
SELECT * FROM Booking WHERE start_date BETWEEN '2023-06-01' AND '2023-06-30';

-- Query 2: Count bookings by month
EXPLAIN ANALYZE
SELECT DATE_TRUNC('month', start_date) AS month, COUNT(*)
FROM Booking
GROUP BY month;

Step 3: Sample Brief Report
**Report: Table Partitioning Performance Optimization**

**Objective:**
To improve query performance on the large `Booking` table by implementing range partitioning based on the `start_date` column.

**Implementation Summary:**
A new table `Booking_Partitioned` was created using PostgreSQL range partitioning. Partitions were defined by year (2022–2025+). Data from the original `Booking` table was migrated into the partitioned structure.

**Testing Approach:**
Performance tests were conducted using two common query patterns:

1. Fetching bookings within a specific date range.
2. Counting bookings grouped by month.

Each query was executed using `EXPLAIN ANALYZE` before and after partitioning.

**Results:**

| Query Description            | Before Partitioning | After Partitioning | Improvement |
| ---------------------------- | ------------------- | ------------------ | ----------- |
| Date range query (June 2023) | ~450 ms             | ~75 ms             | ~83% faster |
| Monthly aggregation          | ~900 ms             | ~300 ms            | ~67% faster |

**Observations:**

* Partition pruning reduced the amount of data scanned for date-range queries.
* Index lookups were more efficient due to smaller partition sizes.
* Maintenance operations (e.g., vacuum, analyze) can now be done per partition.

**Conclusion:**
Implementing table partitioning significantly optimized query performance on the `Booking` dataset, especially for time-based queries. Future improvements could include automated partition creation for new years and indexing each partition separately for further performance gains.

