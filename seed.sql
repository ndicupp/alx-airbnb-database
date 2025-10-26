# database-script-0x02
-- Create the database
CREATE DATABASE property_booking_system;
\c property_booking_system; -- For PostgreSQL

-- Enable UUID extension if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

INSERT INTO Departments (department_id, department_name, department_manager) VALUES
(1, 'Sales', 'Sarah Johnson'),
(2, 'Customer Service', 'Mike Chen'),
(3, 'Operations', 'Lisa Rodriguez'),
(4, 'Management', 'David Thompson'),
(5, 'Housekeeping', 'Maria Garcia');

INSERT INTO Employees (employee_id, employee_name, department_id, email, hire_date, is_active) VALUES
(101, 'John Smith', 1, 'john.smith@property.com', '2022-01-15', TRUE),
(102, 'Emily Davis', 1, 'emily.davis@property.com', '2022-03-20', TRUE),
(103, 'Robert Brown', 2, 'robert.brown@property.com', '2021-11-10', TRUE),
(104, 'Jennifer Wilson', 2, 'jennifer.wilson@property.com', '2023-02-28', TRUE),
(105, 'Michael Taylor', 3, 'michael.taylor@property.com', '2020-08-12', TRUE),
(106, 'Amanda Lee', 5, 'amanda.lee@property.com', '2023-04-05', TRUE),
(107, 'Kevin Martinez', 4, 'kevin.martinez@property.com', '2019-05-22', TRUE);

INSERT INTO Product_Categories (category_id, category_name, category_description) VALUES
(1, 'Luxury Villa', 'High-end private villas with premium amenities'),
(2, 'Beach House', 'Properties located on or near beaches'),
(3, 'Mountain Cabin', 'Cozy cabins in mountainous regions'),
(4, 'City Apartment', 'Modern apartments in urban centers'),
(5, 'Countryside Retreat', 'Peaceful properties in rural areas');

INSERT INTO Customers (customer_id, customer_name, customer_email, customer_phone, customer_address, customer_city, customer_state, customer_zip, created_at) VALUES
(1001, 'Alice Johnson', 'alice.johnson@email.com', '+1-555-0101', '123 Main St', 'New York', 'NY', '10001', '2023-01-15 09:30:00'),
(1002, 'Bob Smith', 'bob.smith@email.com', '+1-555-0102', '456 Oak Ave', 'Los Angeles', 'CA', '90210', '2023-02-20 14:15:00'),
(1003, 'Carol Davis', 'carol.davis@email.com', '+1-555-0103', '789 Pine Rd', 'Chicago', 'IL', '60601', '2023-03-10 11:45:00'),
(1004, 'David Wilson', 'david.wilson@email.com', '+1-555-0104', '321 Elm St', 'Miami', 'FL', '33101', '2023-04-05 16:20:00'),
(1005, 'Eva Brown', 'eva.brown@email.com', '+1-555-0105', '654 Maple Dr', 'Seattle', 'WA', '98101', '2023-05-12 10:00:00'),
(1006, 'Frank Miller', 'frank.miller@email.com', '+1-555-0106', '987 Cedar Ln', 'Boston', 'MA', '02101', '2023-06-18 13:30:00'),
(1007, 'Grace Taylor', 'grace.taylor@email.com', '+1-555-0107', '159 Birch Ct', 'San Francisco', 'CA', '94102', '2023-07-22 08:45:00');

INSERT INTO Products (product_id, product_name, category_id, product_price, stock_quantity, is_active, created_at) VALUES
(2001, 'Oceanview Luxury Villa', 1, 450.00, 1, TRUE, '2023-01-01 00:00:00'),
(2002, 'Seaside Beach House', 2, 320.00, 1, TRUE, '2023-01-01 00:00:00'),
(2003, 'Mountain Peak Cabin', 3, 280.00, 1, TRUE, '2023-01-01 00:00:00'),
(2004, 'Downtown Modern Loft', 4, 190.00, 1, TRUE, '2023-01-01 00:00:00'),
(2005, 'Countryside Farmhouse', 5, 220.00, 1, TRUE, '2023-01-01 00:00:00'),
(2006, 'Ski Resort Chalet', 3, 380.00, 1, TRUE, '2023-01-01 00:00:00'),
(2007, 'City Center Penthouse', 4, 520.00, 1, TRUE, '2023-01-01 00:00:00'),
(2008, 'Lakefront Retreat', 5, 310.00, 1, TRUE, '2023-01-01 00:00:00');

INSERT INTO Orders (order_id, customer_id, employee_id, order_date, order_status, total_amount, created_at) VALUES
(3001, 1001, 101, '2024-01-15', 'Delivered', 1350.00, '2024-01-10 14:20:00'),
(3002, 1002, 102, '2024-02-20', 'Delivered', 640.00, '2024-02-15 09:45:00'),
(3003, 1003, 101, '2024-03-05', 'Shipped', 840.00, '2024-02-28 16:30:00'),
(3004, 1004, 103, '2024-03-12', 'Processing', 190.00, '2024-03-10 11:15:00'),
(3005, 1005, 102, '2024-03-18', 'Pending', 440.00, '2024-03-17 13:40:00'),
(3006, 1001, 101, '2024-04-01', 'Pending', 560.00, '2024-03-25 10:20:00'),
(3007, 1006, 103, '2024-04-05', 'Pending', 310.00, '2024-04-01 15:55:00'),
(3008, 1007, 102, '2024-04-10', 'Pending', 1040.00, '2024-04-08 08:30:00');

INSERT INTO Order_Details (order_detail_id, order_id, product_id, quantity, unit_price, created_at) VALUES
(4001, 3001, 2001, 3, 450.00, '2024-01-10 14:20:00'),
(4002, 3002, 2002, 2, 320.00, '2024-02-15 09:45:00'),
(4003, 3003, 2003, 3, 280.00, '2024-02-28 16:30:00'),
(4004, 3004, 2004, 1, 190.00, '2024-03-10 11:15:00'),
(4005, 3005, 2005, 2, 220.00, '2024-03-17 13:40:00'),
(4006, 3006, 2007, 1, 520.00, '2024-03-25 10:20:00'),
(4007, 3006, 2004, 1, 190.00, '2024-03-25 10:20:00'),
(4008, 3007, 2008, 1, 310.00, '2024-04-01 15:55:00'),
(4009, 3008, 2001, 2, 450.00, '2024-04-08 08:30:00'),
(4010, 3008, 2006, 1, 380.00, '2024-04-08 08:30:00');

-- Create Property_Details table for additional property information
CREATE TABLE Property_Details (
    property_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    bedrooms INT,
    bathrooms INT,
    max_guests INT,
    square_feet INT,
    has_pool BOOLEAN DEFAULT FALSE,
    has_gym BOOLEAN DEFAULT FALSE,
    has_wifi BOOLEAN DEFAULT TRUE,
    check_in_time TIME DEFAULT '15:00:00',
    check_out_time TIME DEFAULT '11:00:00',
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

INSERT INTO Property_Details (property_id, product_id, bedrooms, bathrooms, max_guests, square_feet, has_pool, has_gym, has_wifi) VALUES
(1, 2001, 4, 3, 8, 3200, TRUE, TRUE, TRUE),
(2, 2002, 3, 2, 6, 1800, FALSE, FALSE, TRUE),
(3, 2003, 2, 1, 4, 1200, FALSE, FALSE, TRUE),
(4, 2004, 1, 1, 2, 800, FALSE, TRUE, TRUE),
(5, 2005, 3, 2, 6, 1600, FALSE, FALSE, TRUE),
(6, 2006, 3, 2, 6, 1400, TRUE, TRUE, TRUE),
(7, 2007, 2, 2, 4, 1500, TRUE, TRUE, TRUE),
(8, 2008, 2, 1, 4, 1100, FALSE, FALSE, TRUE);

CREATE TABLE Reviews (
    review_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date DATE DEFAULT CURRENT_DATE,
    is_verified BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

INSERT INTO Reviews (order_id, customer_id, product_id, rating, review_text, review_date) VALUES
(3001, 1001, 2001, 5, 'Absolutely stunning villa with breathtaking ocean views. The service was exceptional!', '2024-01-20'),
(3002, 1002, 2002, 4, 'Lovely beach house, perfect location. Would definitely stay here again.', '2024-02-25'),
(3001, 1001, 2001, 5, 'Second time staying here and it was just as amazing as the first!', '2024-01-20'),
(3003, 1003, 2003, 3, 'Cozy cabin but the wifi was spotty. Great for a digital detox though!', '2024-03-10');

CREATE TABLE Payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    customer_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'Completed',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_id VARCHAR(100),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

INSERT INTO Payments (order_id, customer_id, amount, payment_method, payment_status, payment_date, transaction_id) VALUES
(3001, 1001, 1350.00, 'Credit Card', 'Completed', '2024-01-10 14:25:00', 'TXN00123456'),
(3002, 1002, 640.00, 'PayPal', 'Completed', '2024-02-15 09:50:00', 'TXN00123457'),
(3003, 1003, 840.00, 'Credit Card', 'Completed', '2024-02-28 16:35:00', 'TXN00123458'),
(3004, 1004, 190.00, 'Bank Transfer', 'Pending', '2024-03-10 11:20:00', 'TXN00123459'),
(3005, 1005, 440.00, 'Credit Card', 'Completed', '2024-03-17 13:45:00', 'TXN00123460'),
(3006, 1001, 560.00, 'Credit Card', 'Completed', '2024-03-25 10:25:00', 'TXN00123461');

-- Verify data insertion with summary queries
SELECT 'Departments' as table_name, COUNT(*) as record_count FROM Departments
UNION ALL
SELECT 'Employees', COUNT(*) FROM Employees
UNION ALL
SELECT 'Customers', COUNT(*) FROM Customers
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL
SELECT 'Order_Details', COUNT(*) FROM Order_Details
UNION ALL
SELECT 'Reviews', COUNT(*) FROM Reviews
UNION ALL
SELECT 'Payments', COUNT(*) FROM Payments;

-- Show recent orders with customer and product details
SELECT 
    o.order_id,
    c.customer_name,
    o.order_date,
    o.order_status,
    o.total_amount,
    STRING_AGG(p.product_name, ', ') as products
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Order_Details od ON o.order_id = od.order_id
JOIN Products p ON od.product_id = p.product_id
GROUP BY o.order_id, c.customer_name, o.order_date, o.order_status, o.total_amount
ORDER BY o.order_date DESC;

-- Show revenue by product category
SELECT 
    pc.category_name,
    COUNT(od.order_detail_id) as bookings,
    SUM(od.line_total) as total_revenue
FROM Order_Details od
JOIN Products p ON od.product_id = p.product_id
JOIN Product_Categories pc ON p.category_id = pc.category_id
GROUP BY pc.category_name
ORDER BY total_revenue DESC;
