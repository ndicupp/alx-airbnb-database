Let me create a comprehensive solution.

Step 1: Initial Query
First, let's create the initial complex query in performance.sql:
-- performance.sql
-- Initial complex query: Retrieve all bookings with user, property, and payment details

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_amount,
    b.status as booking_status,
    
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone,
    
    p.property_id,
    p.title as property_title,
    p.address,
    p.city,
    p.state,
    p.zip_code,
    p.daily_rate,
    
    pt.type_name as property_type,
    
    pm.payment_method_id,
    pm.method_type,
    pm.card_last_four,
    
    pay.payment_id,
    pay.amount as payment_amount,
    pay.status as payment_status,
    pay.payment_date
    
FROM bookings b
    INNER JOIN users u ON b.user_id = u.user_id
    INNER JOIN properties p ON b.property_id = p.property_id
    INNER JOIN property_types pt ON p.property_type_id = pt.type_id
    LEFT JOIN payments pay ON b.booking_id = pay.booking_id
    LEFT JOIN payment_methods pm ON pay.payment_method_id = pm.payment_method_id
    
WHERE b.start_date >= '2024-01-01'
ORDER BY b.start_date DESC;

Step 2: Analyze Performance
Now let's analyze the query performance using EXPLAIN:
-- Analyze query performance
EXPLAIN ANALYZE 
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_amount,
    b.status as booking_status,
    
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone,
    
    p.property_id,
    p.title as property_title,
    p.address,
    p.city,
    p.state,
    p.zip_code,
    p.daily_rate,
    
    pt.type_name as property_type,
    
    pm.payment_method_id,
    pm.method_type,
    pm.card_last_four,
    
    pay.payment_id,
    pay.amount as payment_amount,
    pay.status as payment_status,
    pay.payment_date
    
FROM bookings b
    INNER JOIN users u ON b.user_id = u.user_id
    INNER JOIN properties p ON b.property_id = p.property_id
    INNER JOIN property_types pt ON p.property_type_id = pt.type_id
    LEFT JOIN payments pay ON b.booking_id = pay.booking_id
    LEFT JOIN payment_methods pm ON pay.payment_method_id = pm.payment_method_id
    
WHERE b.start_date >= '2024-01-01'
ORDER BY b.start_date DESC;

Step 3: Identify Inefficiencies
Based on the EXPLAIN output, common inefficiencies might include:

Missing indexes on foreign keys and frequently filtered columns

Unnecessary columns being selected

Inefficient join conditions

No pagination for large datasets

Redundant data from multiple joins

Step 4: Create Indexes
-- Create performance indexes
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
CREATE INDEX idx_bookings_start_date ON bookings(start_date);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_properties_type_id ON properties(property_type_id);
CREATE INDEX idx_payments_booking_id ON payments(booking_id);
CREATE INDEX idx_payments_method_id ON payments(payment_method_id);
CREATE INDEX idx_payments_status ON payments(status);

-- Composite indexes for better performance
CREATE INDEX idx_bookings_dates_status ON bookings(start_date, status);
CREATE INDEX idx_properties_location ON properties(city, state);

Step 5: Refactored Query
Here's the optimized version of the query:
-- Refactored optimized query
SELECT 
    -- Booking details
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_amount,
    b.status as booking_status,
    
    -- Essential user details only
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    
    -- Property details with essential location info
    p.property_id,
    p.title as property_title,
    p.city,
    p.state,
    p.daily_rate,
    
    -- Property type
    pt.type_name as property_type,
    
    -- Payment summary (aggregated if multiple payments exist)
    COALESCE(MAX(pay.amount), 0) as total_paid_amount,
    COUNT(pay.payment_id) as payment_count,
    STRING_AGG(DISTINCT pay.status, ', ') as payment_statuses
    
FROM bookings b
    INNER JOIN users u ON b.user_id = u.user_id
    INNER JOIN properties p ON b.property_id = p.property_id
    INNER JOIN property_types pt ON p.property_type_id = pt.type_id
    LEFT JOIN payments pay ON b.booking_id = pay.booking_id
    
WHERE b.start_date >= '2024-01-01'
    AND b.status IN ('confirmed', 'completed') -- Filter specific statuses if possible
    
GROUP BY 
    b.booking_id, b.start_date, b.end_date, b.total_amount, b.status,
    u.user_id, u.first_name, u.last_name, u.email,
    p.property_id, p.title, p.city, p.state, p.daily_rate,
    pt.type_name
    
ORDER BY b.start_date DESC
LIMIT 100; -- Add pagination

Step 6: Alternative Optimized Queries
Option A: Separate Queries for Better Performance
-- Query 1: Get bookings with basic user and property info
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_amount,
    b.status,
    u.first_name,
    u.last_name,
    u.email,
    p.title as property_title,
    p.city,
    p.state,
    p.daily_rate,
    pt.type_name as property_type
FROM bookings b
    INNER JOIN users u USING (user_id)
    INNER JOIN properties p USING (property_id)
    INNER JOIN property_types pt ON p.property_type_id = pt.type_id
WHERE b.start_date >= '2024-01-01'
    AND b.status IN ('confirmed', 'completed')
ORDER BY b.start_date DESC
LIMIT 100;

-- Query 2: Get payment details for specific bookings (if needed)
SELECT 
    booking_id,
    JSON_AGG(
        JSON_BUILD_OBJECT(
            'payment_id', payment_id,
            'amount', amount,
            'status', status,
            'payment_date', payment_date
        )
    ) as payment_details
FROM payments 
WHERE booking_id IN (/* list of booking IDs from first query */)
GROUP BY booking_id;

Option B: Materialized View for Frequently Accessed Data
-- Create materialized view for reporting
CREATE MATERIALIZED VIEW booking_summary_mv AS
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_amount,
    b.status as booking_status,
    u.user_id,
    u.first_name || ' ' || u.last_name as guest_name,
    u.email,
    p.property_id,
    p.title as property_title,
    p.city,
    p.state,
    p.daily_rate,
    pt.type_name as property_type,
    COALESCE(SUM(pay.amount), 0) as total_paid,
    COUNT(pay.payment_id) as payment_count
FROM bookings b
    INNER JOIN users u USING (user_id)
    INNER JOIN properties p USING (property_id)
    INNER JOIN property_types pt ON p.property_type_id = pt.type_id
    LEFT JOIN payments pay USING (booking_id)
GROUP BY 
    b.booking_id, b.start_date, b.end_date, b.total_amount, b.status,
    u.user_id, u.first_name, u.last_name, u.email,
    p.property_id, p.title, p.city, p.state, p.daily_rate,
    pt.type_name;

-- Create index on materialized view
CREATE INDEX idx_booking_summary_date ON booking_summary_mv(start_date);
CREATE INDEX idx_booking_summary_status ON booking_summary_mv(booking_status);

-- Refresh materialized view periodically
REFRESH MATERIALIZED VIEW booking_summary_mv;

-- Query from materialized view
SELECT * FROM booking_summary_mv 
WHERE start_date >= '2024-01-01'
ORDER BY start_date DESC
LIMIT 100;

Step 7: Performance Comparison Script
-- Performance comparison script
-- Test original query
\timing on

-- Original query timing
SELECT /* Original Query */ 1;
-- Run original query here and note time

-- Refactored query timing  
SELECT /* Refactored Query */ 1;
-- Run refactored query here and note time

\timing off

-- Check query plan differences
EXPLAIN (ANALYZE, BUFFERS) /* original query */;
EXPLAIN (ANALYZE, BUFFERS) /* refactored query */;

