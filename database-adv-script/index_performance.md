Analysis of High-Usage Columns
Based on common query patterns, here are the high-usage columns:

Users Table:
user_id (primary key, JOINs, WHERE clauses)

email (login, WHERE clauses)

name (search queries)

Properties Table:
property_id (primary key, JOINs)

title (search queries)

city, price (filtering, sorting)

Bookings Table:
booking_id (primary key)

user_id (JOINs with users, WHERE clauses)

property_id (JOINs with properties, WHERE clauses)

check_in, check_out (date range queries, sorting)

Reviews Table:
review_id (primary key)

property_id (JOINs with properties, WHERE clauses)

user_id (JOINs with users, WHERE clauses)

rating (filtering, sorting)

database_index.sql
-- Indexes for Users table
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_name ON users(name);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Indexes for Properties table
CREATE INDEX idx_properties_title ON properties(title);
CREATE INDEX idx_properties_city ON properties(city);
CREATE INDEX idx_properties_price ON properties(price);
CREATE INDEX idx_properties_city_price ON properties(city, price);
CREATE INDEX idx_properties_created_at ON properties(created_at);

-- Indexes for Bookings table
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
CREATE INDEX idx_bookings_check_in ON bookings(check_in);
CREATE INDEX idx_bookings_check_out ON bookings(check_out);
CREATE INDEX idx_bookings_user_check_in ON bookings(user_id, check_in);
CREATE INDEX idx_bookings_property_check_in ON bookings(property_id, check_in);
CREATE INDEX idx_bookings_status ON bookings(status);

-- Indexes for Reviews table
CREATE INDEX idx_reviews_property_id ON reviews(property_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_property_rating ON reviews(property_id, rating);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);

-- Composite indexes for common query patterns
CREATE INDEX idx_bookings_dates_status ON bookings(check_in, check_out, status);
CREATE INDEX idx_properties_location_price ON properties(city, price, property_id);
CREATE INDEX idx_users_activity ON users(created_at, user_id);

Performance Measurement Examples
Before Index Creation - Measure Performance

-- Example 1: Find bookings for a specific user
EXPLAIN ANALYZE
SELECT * FROM bookings WHERE user_id = 123;

-- Example 2: Find properties in a city with price range
EXPLAIN ANALYZE
SELECT * FROM properties 
WHERE city = 'New York' AND price BETWEEN 100 AND 300;

-- Example 3: Find reviews for a property with high rating
EXPLAIN ANALYZE
SELECT * FROM reviews 
WHERE property_id = 456 AND rating >= 4;

-- Example 4: Complex join query
EXPLAIN ANALYZE
SELECT u.name, p.title, b.check_in, b.check_out
FROM users u
JOIN bookings b ON u.user_id = b.user_id
JOIN properties p ON b.property_id = p.property_id
WHERE u.email = 'user@example.com'
ORDER BY b.check_in DESC;

After Index Creation - Measure Performance Again
Run the same EXPLAIN ANALYZE queries after creating indexes to compare performance.

Advanced Indexing Strategies
Partial Indexes (for frequently filtered data)
-- Index only active bookings
CREATE INDEX idx_bookings_active ON bookings(booking_id) 
WHERE status = 'confirmed';

-- Index only high-rated reviews
CREATE INDEX idx_reviews_high_rating ON reviews(review_id) 
WHERE rating >= 4;

Expression Indexes
-- Index for case-insensitive email search
CREATE INDEX idx_users_email_lower ON users(LOWER(email));

-- Index for search on title
CREATE INDEX idx_properties_title_search ON properties(LOWER(title));

Covering Indexes (include frequently selected columns)
-- Covering index for common booking queries
CREATE INDEX idx_bookings_covering ON bookings(user_id, check_in, check_out, status)
INCLUDE (property_id, total_amount);

-- Covering index for property searches
CREATE INDEX idx_properties_covering ON properties(city, price)
INCLUDE (title, bedrooms, bathrooms);

Monitoring and Maintenance
Check Index Usage
-- Check which indexes are being used
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Check index size and usage
SELECT 
    indexname,
    tablename,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY pg_relation_size(indexname::regclass) DESC;

-- Check which indexes are being used
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Check index size and usage
SELECT 
    indexname,
    tablename,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY pg_relation_size(indexname::regclass) DESC;

Index Maintenance
-- Update table statistics for query planner
ANALYZE users;
ANALYZE properties;
ANALYZE bookings;
ANALYZE reviews;

-- Reindex if needed
REINDEX INDEX idx_bookings_user_id;

Expected Performance Improvements
WHERE clause queries: 10-100x faster with appropriate indexes

JOIN operations: Significant improvement with indexed foreign keys

ORDER BY operations: Much faster with indexed sort columns

Range queries: Dramatic improvement with B-tree indexes on date/numeric columns

Key Indexing Best Practices
Index foreign keys and columns used in JOINs

Index columns in WHERE, ORDER BY, and GROUP BY clauses

Use composite indexes for multi-column queries

Consider partial indexes for filtered data

Monitor index usage and remove unused indexes

Balance read vs write performance (more indexes = slower writes)
