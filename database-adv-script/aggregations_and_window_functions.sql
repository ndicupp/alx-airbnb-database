Let's work with our familiar table structure:

users (user_id, name, email)

properties (property_id, title, description)

bookings (booking_id, user_id, property_id, check_in, check_out)

reviews (review_id, property_id, user_id, rating, comment)

1. Aggregation with COUNT and GROUP BY - Bookings per User
  SELECT 
    u.user_id,
    u.name,
    u.email,
    COUNT(b.booking_id) AS total_bookings
FROM users u
LEFT JOIN bookings b ON u.user_id = b.user_id
GROUP BY u.user_id, u.name, u.email
ORDER BY total_bookings DESC;

  Alternative with only bookings table:
  SELECT 
    user_id,
    COUNT(booking_id) AS total_bookings
FROM bookings
GROUP BY user_id
ORDER BY total_bookings DESC;
  With additional aggregation functions:
  SELECT 
    u.user_id,
    u.name,
    u.email,
    COUNT(b.booking_id) AS total_bookings,
    MIN(b.check_in) AS first_booking_date,
    MAX(b.check_in) AS last_booking_date
FROM users u
LEFT JOIN bookings b ON u.user_id = b.user_id
GROUP BY u.user_id, u.name, u.email
ORDER BY total_bookings DESC;

  2. Window Functions - Ranking Properties by Bookings
Using ROW_NUMBER()
  SELECT 
    p.property_id,
    p.title,
    COUNT(b.booking_id) AS total_bookings,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank
FROM properties p
LEFT JOIN bookings b ON p.property_id = b.property_id
GROUP BY p.property_id, p.title
ORDER BY total_bookings DESC;
  SELECT 
    p.property_id,
    p.title,
    COUNT(b.booking_id) AS total_bookings,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank
FROM properties p
LEFT JOIN bookings b ON p.property_id = b.property_id
GROUP BY p.property_id, p.title
ORDER BY total_bookings DESC;

  Using RANK()
  SELECT 
    p.property_id,
    p.title,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank
FROM properties p
LEFT JOIN bookings b ON p.property_id = b.property_id
GROUP BY p.property_id, p.title
ORDER BY total_bookings DESC;

  Using DENSE_RANK()
  SELECT 
    p.property_id,
    p.title,
    COUNT(b.booking_id) AS total_bookings,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank
FROM properties p
LEFT JOIN bookings b ON p.property_id = b.property_id
GROUP BY p.property_id, p.title
ORDER BY total_bookings DESC;

  Key Differences Between Window Functions:
ROW_NUMBER()
Always produces consecutive numbers (1, 2, 3, 4...)

No ties - each row gets a unique number

Properties with same booking count get different ranks

RANK()
Allows ties and skips numbers after ties

Example: 1, 2, 2, 4, 5 (skips 3 after tie at rank 2)

DENSE_RANK()
Allows ties but doesn't skip numbers

Example: 1, 2, 2, 3, 4 (no skipping)

Advanced Window Function Examples:
Ranking within categories (using PARTITION BY):
SELECT 
    p.property_id,
    p.title,
    p.city,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (PARTITION BY p.city ORDER BY COUNT(b.booking_id) DESC) AS city_rank
FROM properties p
LEFT JOIN bookings b ON p.property_id = b.property_id
GROUP BY p.property_id, p.title, p.city
ORDER BY p.city, city_rank;

Cumulative bookings over time:
SELECT 
    DATE_TRUNC('month', check_in) AS month,
    COUNT(booking_id) AS monthly_bookings,
    SUM(COUNT(booking_id)) OVER (ORDER BY DATE_TRUNC('month', check_in)) AS cumulative_bookings
FROM bookings
GROUP BY DATE_TRUNC('month', check_in)
ORDER BY month;

Comparing each property to the average:
SELECT 
    p.property_id,
    p.title,
    COUNT(b.booking_id) AS total_bookings,
    AVG(COUNT(b.booking_id)) OVER () AS avg_bookings_all_properties,
    COUNT(b.booking_id) - AVG(COUNT(b.booking_id)) OVER () AS difference_from_avg
FROM properties p
LEFT JOIN bookings b ON p.property_id = b.property_id
GROUP BY p.property_id, p.title
ORDER BY total_bookings DESC;

Summary:
Aggregation + GROUP BY: Summarizes data into groups

Window Functions: Performs calculations across related rows without collapsing them

Use GROUP BY when you want summarized results

Use Window Functions when you want to add ranking/comparisons while keeping detail rows
