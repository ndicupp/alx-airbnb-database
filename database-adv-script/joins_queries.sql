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
Explanation: This returns ALL properties, and for properties that have reviews, it includes the review details. Properties without reviews will still appear with NULL values in the review columns 

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

Note: If database doesn't support FULL OUTER JOIN (like MySQL), you can simulate it with a UNION:

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
