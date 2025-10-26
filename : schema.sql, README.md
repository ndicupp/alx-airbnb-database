# database-script-0x01
-- Create Departments table (referenced by Employees)
CREATE TABLE Departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) UNIQUE NOT NULL,
    department_manager VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Customers table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) UNIQUE NOT NULL,
    customer_phone VARCHAR(20),
    customer_address VARCHAR(200),
    customer_city VARCHAR(50),
    customer_state VARCHAR(50),
    customer_zip VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Products table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    product_category VARCHAR(50),
    product_price DECIMAL(10,2) NOT NULL CHECK (product_price >= 0),
    stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Employees table
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT,
    email VARCHAR(100) UNIQUE,
    hire_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
        ON UPDATE CASCADE
);

-- Create Orders table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT,
    order_date DATE NOT NULL,
    order_status VARCHAR(20) DEFAULT 'Pending' 
        CHECK (order_status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')),
    total_amount DECIMAL(10,2) DEFAULT 0 CHECK (total_amount >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
        ON UPDATE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
        ON UPDATE CASCADE
);

-- Create Order_Details table
CREATE TABLE Order_Details (
    order_detail_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    line_total DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
        ON UPDATE CASCADE,
    UNIQUE (order_id, product_id)
);

-- Create a table for product categories to further normalize
CREATE TABLE Product_Categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    category_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Update Products table to use the new categories table
ALTER TABLE Products 
ADD COLUMN category_id INT,
ADD FOREIGN KEY (category_id) REFERENCES Product_Categories(category_id)
    ON UPDATE CASCADE;

-- Remove the old product_category column after data migration
-- ALTER TABLE Products DROP COLUMN product_category;

-- Indexes for Customers table
CREATE INDEX idx_customers_email ON Customers(customer_email);
CREATE INDEX idx_customers_city ON Customers(customer_city);
CREATE INDEX idx_customers_state ON Customers(customer_state);
CREATE INDEX idx_customers_created ON Customers(created_at);

-- Indexes for Products table
CREATE INDEX idx_products_category ON Products(category_id);
CREATE INDEX idx_products_price ON Products(product_price);
CREATE INDEX idx_products_active ON Products(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_products_name ON Products(product_name);

-- Indexes for Orders table
CREATE INDEX idx_orders_customer ON Orders(customer_id);
CREATE INDEX idx_orders_employee ON Orders(employee_id);
CREATE INDEX idx_orders_date ON Orders(order_date);
CREATE INDEX idx_orders_status ON Orders(order_status);
CREATE INDEX idx_orders_created ON Orders(created_at);

-- Indexes for Order_Details table
CREATE INDEX idx_order_details_order ON Order_Details(order_id);
CREATE INDEX idx_order_details_product ON Order_Details(product_id);
CREATE INDEX idx_order_details_composite ON Order_Details(order_id, product_id);

-- Indexes for Employees table
CREATE INDEX idx_employees_department ON Employees(department_id);
CREATE INDEX idx_employees_active ON Employees(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_employees_hire_date ON Employees(hire_date);

-- Indexes for Departments table
CREATE INDEX idx_departments_name ON Departments(department_name);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at columns
CREATE TRIGGER update_customers_updated_at 
    BEFORE UPDATE ON Customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at 
    BEFORE UPDATE ON Products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger to update order total amount
CREATE OR REPLACE FUNCTION update_order_total()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Orders 
    SET total_amount = (
        SELECT COALESCE(SUM(line_total), 0)
        FROM Order_Details 
        WHERE order_id = COALESCE(NEW.order_id, OLD.order_id)
    )
    WHERE order_id = COALESCE(NEW.order_id, OLD.order_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

CREATE TRIGGER update_order_total_trigger
    AFTER INSERT OR UPDATE OR DELETE ON Order_Details
    FOR EACH ROW EXECUTE FUNCTION update_order_total();

    -- View for customer order summary
CREATE VIEW Customer_Order_Summary AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_email,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    MAX(o.order_date) as last_order_date
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_email;

-- View for product sales performance
CREATE VIEW Product_Sales_Performance AS
SELECT 
    p.product_id,
    p.product_name,
    pc.category_name,
    SUM(od.quantity) as total_quantity_sold,
    SUM(od.line_total) as total_revenue,
    COUNT(DISTINCT od.order_id) as order_count
FROM Products p
LEFT JOIN Order_Details od ON p.product_id = od.product_id
LEFT JOIN Product_Categories pc ON p.category_id = pc.category_id
GROUP BY p.product_id, p.product_name, pc.category_name;

-- View for employee sales performance
CREATE VIEW Employee_Sales_Performance AS
SELECT 
    e.employee_id,
    e.employee_name,
    d.department_name,
    COUNT(o.order_id) as orders_processed,
    SUM(o.total_amount) as total_sales_amount
FROM Employees e
LEFT JOIN Orders o ON e.employee_id = o.employee_id
LEFT JOIN Departments d ON e.department_id = d.department_id
WHERE e.is_active = TRUE
GROUP BY e.employee_id, e.employee_name, d.department_name;

-- View for customer order summary
CREATE VIEW Customer_Order_Summary AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_email,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    MAX(o.order_date) as last_order_date
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_email;

-- View for product sales performance
CREATE VIEW Product_Sales_Performance AS
SELECT 
    p.product_id,
    p.product_name,
    pc.category_name,
    SUM(od.quantity) as total_quantity_sold,
    SUM(od.line_total) as total_revenue,
    COUNT(DISTINCT od.order_id) as order_count
FROM Products p
LEFT JOIN Order_Details od ON p.product_id = od.product_id
LEFT JOIN Product_Categories pc ON p.category_id = pc.category_id
GROUP BY p.product_id, p.product_name, pc.category_name;

-- View for employee sales performance
CREATE VIEW Employee_Sales_Performance AS
SELECT 
    e.employee_id,
    e.employee_name,
    d.department_name,
    COUNT(o.order_id) as orders_processed,
    SUM(o.total_amount) as total_sales_amount
FROM Employees e
LEFT JOIN Orders o ON e.employee_id = o.employee_id
LEFT JOIN Departments d ON e.department_id = d.department_id
WHERE e.is_active = TRUE
GROUP BY e.employee_id, e.employee_name, d.department_name;
-- Enable necessary extensions (PostgreSQL example)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create ENUM types for better data integrity
CREATE TYPE order_status_type AS ENUM ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled');

-- Now recreate Orders table with ENUM type
DROP TABLE IF EXISTS Orders CASCADE;
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT,
    order_date DATE NOT NULL,
    order_status order_status_type DEFAULT 'Pending',
    total_amount DECIMAL(10,2) DEFAULT 0 CHECK (total_amount >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
        ON UPDATE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
        ON UPDATE CASCADE
);
