-- E-Commerce Database System
-- Creating the Database
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- 1. Create Tables
-- Users Table
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Categories Table
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Products Table
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL
);

-- Orders Table
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) DEFAULT 0.00,
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Order Items Table
CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE RESTRICT
);

-- Reviews Table
CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    user_id INT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 2. Insert Sample Data
INSERT INTO Users (first_name, last_name, email, password_hash) VALUES
('John', 'Doe', 'john.doe@example.com', 'hash123'),
('Jane', 'Smith', 'jane.smith@example.com', 'hash456'),
('Alice', 'Johnson', 'alice.j@example.com', 'hash789');

INSERT INTO Categories (name, description) VALUES
('Electronics', 'Gadgets and electronic devices'),
('Clothing', 'Apparel and accessories'),
('Books', 'Printed and electronic books');

INSERT INTO Products (category_id, name, description, price, stock_quantity) VALUES
(1, 'Smartphone X', 'Latest model with awesome features', 699.99, 50),
(1, 'Wireless Headphones', 'Noise-cancelling over-ear headphones', 199.99, 100),
(2, 'Cotton T-Shirt', '100% cotton casual t-shirt', 19.99, 200),
(3, 'SQL for Dummies', 'A great book to learn SQL', 29.99, 75);

INSERT INTO Orders (user_id, total_amount, status) VALUES
(1, 719.98, 'Shipped'),
(2, 19.99, 'Pending');

INSERT INTO Order_Items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 699.99),
(1, 3, 1, 19.99),
(2, 3, 1, 19.99);

INSERT INTO Reviews (product_id, user_id, rating, comment) VALUES
(1, 1, 5, 'Amazing phone! Highly recommend.'),
(3, 2, 4, 'Comfortable but shrinks a bit in the wash.');

-- 3. Create Views
-- View: Sales Summary by Category
CREATE VIEW vw_sales_summary AS
SELECT 
    c.name AS category_name,
    COUNT(oi.order_item_id) AS total_items_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM 
    Categories c
JOIN 
    Products p ON c.category_id = p.category_id
JOIN 
    Order_Items oi ON p.product_id = oi.product_id
JOIN 
    Orders o ON oi.order_id = o.order_id
WHERE 
    o.status != 'Cancelled'
GROUP BY 
    c.category_id;

-- View: User Order History
CREATE VIEW vw_user_order_history AS
SELECT 
    u.first_name,
    u.last_name,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.status
FROM 
    Users u
JOIN 
    Orders o ON u.user_id = o.user_id
ORDER BY 
    o.order_date DESC;

-- 4. Create Triggers
DELIMITER //

-- Trigger: Automatically update the total_amount in Orders when an item is added
CREATE TRIGGER trg_after_order_item_insert
AFTER INSERT ON Order_Items
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET total_amount = total_amount + (NEW.quantity * NEW.unit_price)
    WHERE order_id = NEW.order_id;
END //

DELIMITER ;

-- 5. Create Stored Procedures
DELIMITER //

-- Stored Procedure: Place an order
CREATE PROCEDURE sp_place_order(
    IN p_user_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_order_id INT
)
BEGIN
    DECLARE v_product_price DECIMAL(10, 2);
    DECLARE v_current_stock INT;
    
    -- Start a transaction
    START TRANSACTION;
    
    -- Check stock and get price
    SELECT price, stock_quantity INTO v_product_price, v_current_stock
    FROM Products 
    WHERE product_id = p_product_id;
    
    IF v_current_stock >= p_quantity THEN
        -- Create the main order record
        INSERT INTO Orders (user_id, total_amount, status)
        VALUES (p_user_id, 0, 'Pending'); -- total_amount will be updated by trigger
        
        -- Get the ID of the newly created order
        SET p_order_id = LAST_INSERT_ID();
        
        -- Insert the order item
        INSERT INTO Order_Items (order_id, product_id, quantity, unit_price)
        VALUES (p_order_id, p_product_id, p_quantity, v_product_price);
        
        -- Deduct stock
        UPDATE Products 
        SET stock_quantity = stock_quantity - p_quantity
        WHERE product_id = p_product_id;
        
        -- Commit transaction
        COMMIT;
    ELSE
        -- Not enough stock, rollback and signal error
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock for this product.';
    END IF;
END //

DELIMITER ;
