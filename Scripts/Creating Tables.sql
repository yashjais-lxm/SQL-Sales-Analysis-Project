/*
=========================================================
                SALES DATABASE
=========================================================
Author      : Yash Jaiswal
Database    : Sales_Database
SQL Dialect : PostgreSQL
=========================================================

Description:
This script creates the Sales Database and all required
tables for performing SQL-based sales analysis.

Tables Included:
1. Customers
2. Employees
3. Products
4. Orders
5. OrdersArchive
=========================================================
*/


/*
=========================================================
                CREATE DATABASE
=========================================================
*/

-- Drop the database if it already exists.
-- Make sure you have a backup before running this command.

DROP DATABASE IF EXISTS Sales_Database;

CREATE DATABASE Sales_Database;



/*
=========================================================
        DDL (Data Definition Language)
=========================================================
*/


/*
=========================================================
                CUSTOMERS TABLE
=========================================================
*/

DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    CustomerID   INTEGER PRIMARY KEY,
    FirstName    VARCHAR(50) NOT NULL,
    LastName     VARCHAR(50),
    Country      VARCHAR(50),
    Score        INTEGER
);



/*
=========================================================
                EMPLOYEES TABLE
=========================================================
*/

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    EmployeeID   INTEGER PRIMARY KEY,
    FirstName    VARCHAR(50) NOT NULL,
    LastName     VARCHAR(50),
    Department   VARCHAR(50),
    BirthDate    DATE,
    Gender       CHAR(10),
    Salary       NUMERIC(10,2),
    ManagerID    INTEGER
);



/*
=========================================================
                PRODUCTS TABLE
=========================================================
*/

DROP TABLE IF EXISTS products;

CREATE TABLE products (
    ProductID    INTEGER PRIMARY KEY,
    Product      VARCHAR(50),
    Category     VARCHAR(50),
    Price        INTEGER
);



/*
=========================================================
                ORDERS TABLE
=========================================================
*/

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    OrderID         INTEGER PRIMARY KEY,
    ProductID       INTEGER REFERENCES products(ProductID),
    CustomerID      INTEGER REFERENCES customers(CustomerID),
    SalesPersonID   INTEGER REFERENCES employees(EmployeeID),
    OrderDate       DATE,
    ShipDate        DATE,
    OrderStatus     VARCHAR(50),
    ShipAddress     VARCHAR(250),
    BillAddress     VARCHAR(250),
    Quantity        INTEGER,
    Sales           INTEGER,
    CreationTime    TIMESTAMP
);



/*
=========================================================
            ORDERS ARCHIVE TABLE
=========================================================
*/

DROP TABLE IF EXISTS ordersarchive;

CREATE TABLE ordersarchive (
    OrderID         INTEGER,
    ProductID       INTEGER REFERENCES products(ProductID),
    CustomerID      INTEGER REFERENCES customers(CustomerID),
    SalesPersonID   INTEGER REFERENCES employees(EmployeeID),
    OrderDate       DATE,
    ShipDate        DATE,
    OrderStatus     VARCHAR(50),
    ShipAddress     VARCHAR(250),
    BillAddress     VARCHAR(250),
    Quantity        INTEGER,
    Sales           INTEGER,
    CreationTime    TIMESTAMP
);



/*
=========================================================
                IMPORT DATA
=========================================================
*/

-- Data for all tables was imported using the
-- PostgreSQL CSV Import feature.

-- Dataset files are available in the "Dataset"
-- folder of this GitHub repository.