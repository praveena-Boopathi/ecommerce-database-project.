# E-Commerce Database Management System

A comprehensive relational database for an E-Commerce platform built using **MySQL**. This project demonstrates database design, complex table relationships, and the use of advanced SQL features like Views, Triggers, and Stored Procedures.

## 📌 Project Overview
This database is designed to handle the core operations of an online store, including managing users, product inventory, order processing, and customer reviews.

### Key Features
*   **Structured Schema**: 6 interconnected tables with proper `PRIMARY KEY` and `FOREIGN KEY` constraints.
*   **Data Integrity**: Uses `CASCADE` and `RESTRICT` rules to maintain referential integrity.
*   **Business Logic**: Implements a stored procedure with a **Transaction** to securely process orders and manage inventory stock safely.
*   **Automation**: Uses a trigger to automatically calculate and update order totals in real-time.
*   **Data Analytics**: Includes views to quickly summarize sales data and track user purchase history.

## 🗄️ Database Schema
The database consists of the following tables:
1.  **`Users`**: Stores customer details and authentication data.
2.  **`Categories`**: Defines product categories.
3.  **`Products`**: Manages inventory details, pricing, and stock levels.
4.  **`Orders`**: Tracks customer orders and their current status (Pending, Shipped, etc.).
5.  **`Order_Items`**: Line items detailing the specific products and quantities in each order.
6.  **`Reviews`**: Customer ratings and feedback for products.

## 🚀 Advanced SQL Components

### 1. Stored Procedure: `sp_place_order`
A transactional procedure that handles the complex process of placing an order.
*   Checks if the requested product is in stock.
*   Creates a new record in the `Orders` table.
*   Adds the item to `Order_Items`.
*   Deducts the purchased quantity from the `Products` stock.
*   *Rolls back* the entire transaction if stock is insufficient, preventing data errors.

### 2. Trigger: `trg_after_order_item_insert`
An automation that listens for new inserts in the `Order_Items` table and automatically recalculates and updates the `total_amount` in the parent `Orders` table.

### 3. Views
*   **`vw_sales_summary`**: Aggregates data across multiple tables to show total items sold and revenue generated per product category.
*   **`vw_user_order_history`**: Provides a clean, readable history of a user's past orders.

## 🛠️ How to Run This Project
1. Install [MySQL Server](https://dev.mysql.com/downloads/mysql/) and [MySQL Workbench](https://dev.mysql.com/downloads/workbench/).
2. Open MySQL Workbench and connect to your local server.
3. Open the `ecommerce_database.sql` file.
4. Execute the entire script to create the database, build the tables, and insert the sample data.
5. Use the provided test queries to interact with the Views and Stored Procedures.

---
*Created as a demonstration of SQL database design and development skills.*
