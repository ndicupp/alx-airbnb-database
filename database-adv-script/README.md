Let's assume we have the following tables:

users (user_id, name, email)

properties (property_id, title, description)

bookings (booking_id, user_id, property_id, check_in, check_out)

reviews (review_id, property_id, user_id, rating, comment)

Here are the queries for each scenario:

1. INNER JOIN - Bookings with Users
   SELECT 
    b.booking_id,
    b.check_in,
    b.check_out,
    u.user_id,
    u.name,
    u.email
FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id;
Explanation: This returns only bookings that have matching users in the users table. If a booking has no associated user, it won't appear in the results.

2. LEFT JOIN - Properties with Reviews
   SELECT 
    p.property_id,
    p.title,
    p.description,
    r.review_id,
    r.rating,
    r.comment,
    r.user_id as reviewer_id
FROM properties p
LEFT JOIN reviews r ON p.property_id = r.property_id;
Explanation: This returns ALL properties, and for properties that have reviews, it includes the review details. Properties without reviews will still appear with NULL values in the review columns.

3. FULL OUTER JOIN - Users and Bookings
   SELECT 
    u.user_id,
    u.name,
    u.email,
    b.booking_id,
    b.property_id,
    b.check_in,
    b.check_out
FROM users u
FULL OUTER JOIN bookings b ON u.user_id = b.user_id;
Explanation: This returns:

Users with their bookings (matched records)

Users without any bookings (user data with NULL booking columns)

Bookings not linked to any user (booking data with NULL user columns)

Note: If your database doesn't support FULL OUTER JOIN (like MySQL), you can simulate it with a UNION:
-- For MySQL or databases without FULL OUTER JOIN support
SELECT 
    u.user_id,
    u.name,
    u.email,
    b.booking_id,
    b.property_id,
    b.check_in,
    b.check_out
FROM users u
LEFT JOIN bookings b ON u.user_id = b.user_id

UNION

SELECT 
    u.user_id,
    u.name,
    u.email,
    b.booking_id,
    b.property_id,
    b.check_in,
    b.check_out
FROM users u
RIGHT JOIN bookings b ON u.user_id = b.user_id;



Let's use the same table structure:

users (user_id, name, email)

properties (property_id, title, description)

bookings (booking_id, user_id, property_id, check_in, check_out)

reviews (review_id, property_id, user_id, rating, comment)

1. Non-Correlated Subquery - Properties with Average Rating > 4.0
SELECT 
    p.property_id,
    p.title,
    p.description
FROM properties p
WHERE p.property_id IN (
    SELECT r.property_id
    FROM reviews r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
);

  How it works:

The inner subquery runs first and independently

It finds all property_ids where the average rating is greater than 4.0

The outer query then filters properties based on this list

This is non-correlated because the inner query doesn't reference the outer query

Alternative with JOIN approach:
SELECT 
    p.property_id,
    p.title,
    p.description,
    avg_ratings.average_rating
FROM properties p
JOIN (
    SELECT 
        property_id,
        AVG(rating) as average_rating
    FROM reviews
    GROUP BY property_id
    HAVING AVG(rating) > 4.0
) avg_ratings ON p.property_id = avg_ratings.property_id;

2. Correlated Subquery - Users with More Than 3 Bookings
SELECT 
    u.user_id,
    u.name,
    u.email
FROM users u
WHERE (
    SELECT COUNT(*) 
    FROM bookings b 
    WHERE b.user_id = u.user_id  -- This makes it correlated
) > 3;

How it works:

The outer query starts processing each user row

For each user, the inner subquery executes and counts their bookings

The inner query references u.user_id from the outer query

This is correlated because the inner query depends on the outer query's current row

Alternative correlated version using EXISTS:
  SELECT 
    u.user_id,
    u.name,
    u.email
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM bookings b
    WHERE b.user_id = u.user_id
    GROUP BY b.user_id
    HAVING COUNT(*) > 3
);

  Non-Correlated vs Correlated - Key Differences:
Non-Correlated Subquery (Example 1):
. Inner query executes once at the beginning

.Independent of outer query

. Better performance typically

. Uses IN, NOT IN, or JOIN with derived table

Correlated Subquery (Example 2):
.Inner query executes for each row of outer query

. References columns from outer query

. Can be slower but more flexible

. Uses WHERE clause with outer table reference

Performance Comparison:
For the bookings query, here's a non-correlated alternative:

SELECT 
    u.user_id,
    u.name,
    u.email
FROM users u
WHERE u.user_id IN (
    SELECT user_id
    FROM bookings
    GROUP BY user_id
    HAVING COUNT(*) > 3
);

Which approach to choose?

Use non-correlated when you can (better performance)

Use correlated when you need to reference outer query values

Use correlated with EXISTS for "exists/not exists" type checks
