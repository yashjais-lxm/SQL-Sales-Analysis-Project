/*
==============================================================
SQL SALES ANALYSIS PROJECT
Database    : Sales Database
SQL Dialect : PostgreSQL

Topics Covered:
- SELECT, WHERE, GROUP BY, HAVING, ORDER BY
- JOINS
- CASE Expressions
- Aggregate Functions
- Window Functions
- Common Table Expressions (CTEs)
- Recursive CTEs
- Ranking Functions
- Date Functions
==============================================================
*/

-- SQL Project  on salesdatabase

--Find the numbers of days between each order and previous order

SELECT orderid,
orderdate ,
LAG(orderdate) OVER(ORDER BY orderdate) AS pre_ord_date,
 AGE(orderdate,LAG(orderdate) OVER(ORDER BY orderdate)) AS day_diff,
orderdate - LAG(orderdate) OVER(ORDER BY orderdate) AS days_diff
FROM orders


SELECT orderid,
orderdate ,
LAG(orderdate) OVER(ORDER BY orderdate) AS pre_ord_date,
orderdate - LAG(orderdate) OVER(ORDER BY orderdate) AS days_diff
FROM orders



--Adding category(Using Case Function)

SELECT category,
SUM(sales) AS total_sales
FROM ( SELECT orderid,
sales,
CASE WHEN sales > 50 THEN 'High'
 WHEN sales > 20 THEN 'Medium'
 ELSE 'Low'
 END AS category
FROM orders 
ORDER BY sales ) t
GROUP BY category
ORDER BY total_sales DESC




--USE BOTH CASE AND COALESCE FUNCTION TO HANDLE THE NULL VALUE

SELECT customerid,
firstname,
score,
CASE 
   WHEN score IS NULL THEN 0
   ELSE score
   END AS cleaned_score,
 AVG(CASE 
   WHEN score IS NULL THEN 0
   ELSE score
   END)  OVER() average_score,
 ROUND(AVG(COALESCE(score,0)) OVER(),2) AS average_score2  
FROM customers




--Count the Number of Orders Each Customer Has Made with Sales Greater Than 30


SELECT customerid,
SUM(CASE
    WHEN sales > 30 THEN 1
	ELSE 0
END) AS orders_greater_than_30,
COUNT(*) AS total_orders
FROM orders
GROUP BY customerid
ORDER BY customerid



--ANALYZE THE SALES OF EACH CUSTOMER


SELECT customerid,
COUNT(*) AS total_orders,
SUM(sales) AS total_sales,
ROUND(AVG(COALESCE(sales,0)),2) AS average_sales,
MAX(sales) AS highest_sales,
MIN(sales) AS minimum_sales
FROM orders
GROUP BY customerid
ORDER BY customerid



--Analyze the Score of Each Customer


SELECT customerid,
	COUNT(*) AS total_customer,
	SUM(COALESCE(score,0)) AS total_score,
	ROUND(AVG(COALESCE(score,0)),2) AS average_score,
	MAX(COALESCE(score,0)) AS maximum_score,
	MIN(COALESCE(score,0)) AS minimum_score
FROM customers
GROUP BY customerid
ORDER BY customerid


--Find the Total Sales Across All Orders
--Find the total sales for each product
--Find the total sales for each combination of product and order status
--additionally provide details such as orderid, order date

SELECT orderid,
orderdate,
productid,
orderstatus,
sales,
SUM(sales) OVER() AS total_sales,
SUM(sales) OVER(PARTITION BY productid) AS product_wise_sales,
SUM(sales) OVER(PARTITION BY productid,orderstatus) AS combination_wise_sales
FROM orders



--Rank each order based on their sales from highest to lowest
--Additionally provide details such as orderid, order date

SELECT orderid,
orderdate,
sales,
RANK() OVER(ORDER BY sales DESC) AS "Rank"
FROM orders


--Rank customers based on their total sales

SELECT Customerid,
SUM(sales) AS total_sales,
RANK() OVER(ORDER BY SUM(sales) DESC) AS rank
FROM orders
GROUP BY customerid


--Find the total numbers of orders
--Find the total numbers of orders for each customers
--Additionally provide details such as order id, order date

SELECT orderid,
orderdate,
customerid,
COUNT(*) OVER() AS "Total Orders",
COUNT(*) OVER(PARTITION BY customerid) "Orders by customers"
FROM orders


--Check whether the table 'ordersarchive' have any duplicate values

SELECT *
FROM (
SELECT orderid,
COUNT(*) OVER(PARTITION BY orderid) AS "Count"
FROM ordersarchive
) t
WHERE "Count" > 1



SELECT orderid,
COUNT(*) AS "Count"
FROM ordersarchive
GROUP BY orderid
HAVING COUNT(*) > 1



--Find the total sales across all orders
--And total sales for each products
--Additionally provide details such as order id, order date


SELECT orderid,
orderdate,
productid,
sales,
SUM(sales) OVER() AS "Total Sales",
SUM(sales) OVER(PARTITION BY productid) AS "Product Wise Sales"
FROM orders


--Find the percentage contribution for each product's sale to the total sales

SELECT orderid,
productid,
sales,
SUM(sales) OVER(PARTITION BY productid) AS "Product wise sales",
SUM(sales) OVER() AS "Total Sales",
ROUND(CAST(SUM(sales) OVER(PARTITION BY productid) AS Numeric)
/ SUM(sales) OVER() * 100,2) AS "Percentage Contribution"
FROM orders


--Find the percentage contribution for each order's sale to the total sales


SELECT orderid,
productid,
sales,
SUM(sales) OVER() AS "Total Sales",
ROUND(CAST(sales AS Numeric) / SUM(sales)  OVER() * 100 ,2)AS "Percentage of Total Sales"
FROM orders



--Find the average sales across all orders
--Find the average sales for each products
--Additionally provide details such as order id, order date


SELECT orderid,
	orderdate,
	productid,
	sales,
	ROUND(AVG(sales) OVER(),2) AS "Average",
	ROUND(AVG(sales) OVER(PARTITION BY productid),2) AS "Average by products"
FROM orders


--Find all orders where sales are higher than the average sales across all orders

SELECT orderid,
	productid,
	sales,
	"Average Sales"
FROM (
	SELECT *,
	ROUND(AVG(COALESCE(sales,0)) OVER(),2) AS "Average Sales"
	FROM orders
	) t
WHERE sales > "Average Sales"


--Find the highest and lowest sales across all orders
--Find the highest and lowest sales for each products
--Additionally provide details such as order id, order date


SELECT 
	orderid,
	orderdate,
	sales,
	productid,
	MAX(sales) OVER() AS "Highest Sales",
	MIN(sales) OVER() AS "Lowest Sales",
	MAX(sales) OVER(PARTITION BY productid) AS "Highest sales by product",
	MIN(sales) OVER(PARTITION BY productid) AS "Lowest sales by product"
FROM orders


--Show the employees who have the highest salary (without window function)

SELECT 
	employeeid,
	firstname,
	lastname,
	salary
FROM employees
WHERE salary = (SELECT
				MAX(salary)
				FROM employees)



--Show the employees who have the highest salary (with window function)

SELECT 
	employeeid,
	firstname,
	lastname,
	salary
FROM (	SELECT *,
		MAX(salary) OVER() AS highestsalary
		FROM employees
		) t
WHERE salary = highestsalary



--Find the deviation of each sales from the minimun and maximum sales amount

SELECT
orderid,
orderdate,
productid,
sales,
MAX(sales) OVER() AS "Highest Sales",
MIN(sales) OVER() AS "Lowest Sales",
sales - MIN(sales) OVER() AS DevationFromMin,
MAX(sales) OVER() - sales AS  DevationFromMax
FROM orders


--Calculate moving average of sales for each product over time
--Calculate moving average of sales for each product over time, including only the next order

SELECT orderid,
orderdate,
productid,
sales,
ROUND(AVG(sales) OVER (PARTITION BY productid),2) AS "Average by Products",
ROUND(AVG(sales) OVER(PARTITION BY productid ORDER BY orderdate),2) AS "Running Average",
ROUND(AVG(sales) OVER(PARTITION BY productid ORDER BY orderdate ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING),2) AS "MovingAvg"
FROM orders



--Rank the orders based on their sales from highest to lowest

SELECT orderid,
orderdate,
sales,
ROW_NUMBER() OVER (ORDER BY sales DESC) AS "SalesRank_Row",
Rank() OVER (ORDER BY sales DESC) AS "SalesRank_Rank",
DENSE_RANK() OVER (ORDER BY sales DESC) AS "SalesRank_Dense"
FROM orders


--Find the top highest sales for each products

SELECT orderid,
orderdate,
productid,
sales
FROM (
SELECT orderid,
orderdate,
productid,
sales,
ROW_NUMBER() OVER(PARTITION BY productid ORDER BY sales DESC ) AS rn
FROM orders
) t
WHERE rn = 1


--Find the lowest 2 customers based on their total sales 

SELECT *
FROM (
	SELECT customerid,
	SUM(sales) AS total_sales,
	ROW_NUMBER() OVER(ORDER BY SUM(sales)) AS rn
	FROM orders
	GROUP BY customerid
	) t
WHERE rn <= 2



--Assign unique IDs to the rows of 'ordersarchive' table

SELECT ROW_NUMBER() OVER(ORDER BY orderid,orderdate) AS "UniqueID",
*
FROM ordersarchive


--Identify duplicate rows in table 'ordersarchive'
--and return a clean result without any duplicate 


SELECT *
FROM (
SELECT ROW_NUMBER() OVER(PARTITION BY orderid ORDER BY creationtime DESC) AS rn, 
*
FROM ordersarchive
) t
WHERE rn = 1


--Segment all orders into  categories: High,Medium and Low sales
	
SELECT orderid,
	orderdate,
	sales,
	CASE bucket
	WHEN 1 THEN 'High'
	WHEN 2 THEN 'Medium'
	ELSE 'Low'
	END AS category
FROM (
	SELECT orderid,
	orderdate,
	sales,
	NTILE(3) OVER(ORDER BY sales DESC) AS bucket
	FROM orders
	) t

--In order to export the data, divide the orders into two groups

SELECT *
FROM (
SELECT 
NTILE(2) OVER(ORDER BY orderid) AS bucket,
*
FROM orders
) t
WHERE bucket = 1


--Find the products that fall within the highest 40% of the price

SELECT product,
price,
distrank * 100 || '%' AS distrankperc
FROM (
SELECT product,
price,
CUME_DIST() OVER(ORDER BY price DESC) AS Distrank
FROM products
) t
WHERE distrank <= 0.4



                      -- Time series analysis --   
					  

--Analyze the month-over-month(MOM) performance
--by finding the percentage change in sales between the current and previous months

SELECT *,
ROUND(CAST(change_in_months AS NUMERIC) / pre_mon_sale * 100,2) || '%' AS per_change
FROM (
	SELECT 
		EXTRACT(MONTH FROM orderdate) AS ordermonth,
		SUM(sales) AS total_sales,
		LAG(SUM(sales)) OVER(ORDER BY EXTRACT(MONTH FROM orderdate)) AS pre_mon_sale,
		SUM(sales) - LAG(SUM(sales)) OVER(ORDER BY EXTRACT(MONTH FROM orderdate)) AS change_in_months
	FROM orders
	GROUP BY EXTRACT(MONTH FROM orderdate)
	) t



WITH cte AS (SELECT 
EXTRACT(MONTH FROM orderdate) AS months,
SUM(sales) AS total_sales,
LAG(SUM(sales)) OVER(ORDER BY EXTRACT(MONTH FROM orderdate)) AS previous_month
FROM orders
GROUP BY EXTRACT(MONTH FROM orderdate))

SELECT *,
total_sales - previous_month AS diff,
ROUND(CAST(total_sales - previous_month AS NUMERIC)/  previous_month * 100,2) || '%' AS per_change
FROM cte




                        --Time Gap Analysis--
						

--In order to analyze customer's loyalty,
--rank customers based on the average days between their orders


SELECT
customerid,
ROUND(AVG(daysdiff),2) AS avg_days,
RANK() OVER(ORDER BY AVG(daysdiff)) AS RANK
FROM (
SELECT
customerid,
orderdate AS curr_order,
LEAD(orderdate) OVER(PARTITION BY customerid ORDER BY orderdate) AS nxt_order,
LEAD(orderdate) OVER(PARTITION BY customerid ORDER BY orderdate) - orderdate AS daysdiff
FROM orders
ORDER BY customerid, orderdate
) t
GROUP BY customerid



WITH cte AS (SELECT 
customerid,
orderdate,
LEAD(orderdate) OVER(PARTITION BY customerid ORDER BY orderdate) AS nxt_month,
LEAD(orderdate) OVER(PARTITION BY customerid ORDER BY orderdate) - orderdate AS days_diff
FROM orders
ORDER BY customerid,orderdate)

SELECT customerid,
ROUND(AVG(days_diff),2) AS avg_days,
RANK() OVER(ORDER BY ROUND(AVG(days_diff),2)) AS rank
FROM cte
GROUP BY customerid



--Find the lowest and highest sales for each products


SELECT orderid,
productid,
sales,
FIRST_VALUE(sales) OVER(PARTITION BY productid ORDER BY sales) AS lowest_sales,
FIRST_VALUE(sales) OVER(PARTITION BY productid ORDER BY sales DESC) AS highest_sales,
LAST_VALUE(sales) OVER(PARTITION  BY productid ORDER BY sales ROWS BETWEEN CURRENT ROW 
AND UNBOUNDED FOLLOWING ) AS highest_sales2
FROM orders



SELECT orderid,
productid,
sales,
MIN(sales) OVER(PARTITION BY productid ) AS lowest_sales,
MAX(sales) OVER(PARTITION BY productid ) AS highest_sales
FROM orders




--Find the lowest and highest sales for each products
--Find the difference in sales between the current and the lowest sales
--Find the difference in sales between the current and the highest sales


SELECT 
orderid,
productid,
sales,
MIN(sales) OVER(PARTITION BY productid) AS lowest_sales,
MAX(sales) OVER(PARTITION BY productid) AS highest_sales,
sales - MIN(sales) OVER(PARTITION BY productid) AS "Difference from lowest",
MAX(sales) OVER(PARTITION BY productid) - sales AS "Difference from highest"
FROM orders


/*  Find the products that have a price higher than the average price of all products  */


SELECT *
FROM (
SELECT productid,
product,
price,
ROUND(AVG(price) OVER(),2) AS avg_price
FROM products) t
WHERE price > avg_price



SELECT *,
(SELECT ROUND(AVG(price),2) FROM products) AS average_price
FROM products
WHERE price > (SELECT AVG(price) FROM products) 



--Rank the customer based on their total sales

SELECT customerid,
SUM(sales) AS total_sales,
RANK() OVER(ORDER BY SUM(sales) DESC) AS rank
FROM orders
GROUP BY customerid



SELECT *,
RANK() OVER(ORDER BY total_sales DESC)  AS rank
FROM (
SELECT customerid,
SUM(sales) AS total_sales
FROM orders
GROUP BY customerid) t



--Show the product Id, product Name, price and total number of orders

SELECT productid,
product AS product_name,
price,
(SELECT COUNT(*) FROM orders) AS total_orders
FROM products



--Show all customer details and find the total orders for each customers

SELECT c.*,
o.total_orders
FROM customers C
LEFT JOIN (
SELECT customerid,
COUNT(*) AS total_orders
FROM orders
GROUP BY customerid) AS O
ON c.customerid = o.customerid




WITH cust_details AS (SELECT customerid,
COUNT(*) AS total_orders
FROM orders
GROUP BY customerid)

SELECT c.*,
cs.total_orders
FROM customers c
LEFT JOIN cust_details cs
ON c.customerid = cs.customerid



SELECT *,
(SELECT COUNT(*) FROM orders o WHERE o.customerid = c.customerid) AS total_orders
FROM customers c



-- Show the details of orders made by customers in Germany --

SELECT *
FROM orders
WHERE customerid IN ( SELECT customerid
					FROM customers
					WHERE country = 'Germany')
		

SELECT *
FROM orders o
WHERE EXISTS (SELECT 1
			FROM customers c
			WHERE country = 'Germany' AND
			c.customerid = o.customerid)



-- Show the details of orders for customers who are not from USA --


SELECT *
FROM orders
WHERE customerid NOT IN ( SELECT customerid
						FROM customers
						WHERE country = 'USA')



-- Find female employees whose salaries are greater than the salaries of any male employees --


SELECT *
FROM employees
WHERE gender = 'F'
AND salary > ANY  ( SELECT salary
					FROM employees
					WHERE gender = 'M')
					




-- Find the total sales per customer (Use Standalon CTE)
-- Find the last order date for each customer (Use Standalon CTE)
-- Rnak customer based on total sales per customer (Use Nested CTE)
-- Segment customers based on their total sales (Use Nested CTE)


WITH cte_sales AS (SELECT customerid,
SUM(sales) AS total_sales
FROM orders
GROUP BY customerid)

,cte_last_order AS (SELECT customerid,
MAX(orderdate) AS last_order
FROM orders
GROUP BY customerid)

,cte_customer_rank AS (SELECT *,
RANK() OVER(ORDER BY total_sales DESC) AS rank
FROM cte_sales )

,cte_customer_segment AS (SELECT *,
CASE WHEN total_sales > 100 THEN 'High'
     WHEN total_sales > 80 THEN 'Medium'
	 ELSE 'Low'
END AS category	 
FROM cte_sales)


SELECT c.*,
cs.total_sales,
clo.last_order,
ccr.rank,
ccs.category
FROM customers c
LEFT JOIN cte_sales cs
ON cs.customerid = c.customerid
LEFT JOIN cte_last_order clo
ON clo.customerid = c.customerid
LEFT JOIN cte_customer_rank ccr
ON ccr.customerid = c.customerid
LEFT JOIN cte_customer_segment ccs
ON ccs.customerid = c.customerid




--Generate a sequence of number from 1 to 20 (Using Recursive CTE)

WITH RECURSIVE series AS (
	SELECT 1 AS mynumber
	
	UNION ALL

	SELECT  mynumber + 1
	FROM series
	WHERE mynumber < 20 )

	SELECT *
	FROM series




-- Show the employee hierarchy by displaying each employee's level within the organization


WITH RECURSIVE cte_employee_hierarchy AS 
(SELECT employeeid,
firstname,
managerid,
1 AS level
FROM employees
WHERE managerid IS NULL

UNION ALL

SELECT 
e.employeeid,
e.firstname,
e.managerid,
level +1
FROM employees AS e
INNER JOIN cte_employee_hierarchy AS ceh
ON e.managerid = ceh.employeeid
)

SELECT *
FROM cte_employee_hierarchy




--Generate monthly summary of orders from orders table (By Creating a VIEW)


CREATE VIEW MONTHLY_SUMMARY AS (
SELECT 
DATE_TRUNC('MONTH', orderdate) AS order_month,
SUM(sales) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(orderid) AS total_orders
FROM orders
GROUP BY DATE_TRUNC('MONTH', orderdate))


SELECT *,
SUM(total_sales) OVER(ORDER BY order_month) AS running_total
FROM monthly_summary
ORDER BY order_month



 
--Provide views that combines details from orders, products, customers and employees table


CREATE VIEW ORDERS_DETAILS AS (SELECT o.orderid,
o.orderdate,
p.product AS "Product Name",
p.category,
c.firstname || ' ' || COALESCE(c.lastname,'') AS "Customer Name",
c.country AS "Customer Country",
e.firstname || ' ' || COALESCE(e.lastname,'') AS "Employees Name",
e.department AS "Employees Department",
o.quantity,
o.sales
FROM orders o
LEFT JOIN products p
ON p.productid = o.productid
LEFT JOIN customers c
ON c.customerid = o.customerid
LEFT JOIN employees e
ON e.employeeid = o.salespersonid)


SELECT *
FROM orders_details



--Provide a view for EU sales team that combine details from all tables 
-- and exclude data related to the USA



CREATE VIEW ORDERS_DETAILS_EU AS (SELECT o.orderid,
o.orderdate,
p.product AS "Product Name",
p.category,
c.firstname || ' ' || COALESCE(c.lastname,'') AS "Customer Name",
c.country AS "Customer Country",
e.firstname || ' ' || COALESCE(e.lastname,'') AS "Employees Name",
e.department AS "Employees Department",
o.quantity,
o.sales
FROM orders o
LEFT JOIN products p
ON p.productid = o.producti
LEFT JOIN customers c
ON c.customerid = o.customerid
LEFT JOIN employees e
ON e.employeeid = o.salespersonid
WHERE c.country <> 'USA')


SELECT *
FROM orders_details_eu




--Create a table that contains monthly orders summary (Using CTAS)


DROP TABLE IF EXISTS MONTHLY_ORDERS;

CREATE TABLE MONTHLY_ORDERS AS (SELECT 
TO_CHAR(orderdate,'Month') AS month,
COUNT(orderid) AS total_orders,
SUM(sales) AS total_sales,
SUM(quantity) AS total_quantity
FROM orders
GROUP BY TO_CHAR(orderdate,'Month'));


SELECT *
FROM monthly_orders;




-- Show the employeeID, Employee Name and also Manager Name of that particular employee 

SELECT e.employeeid,
e.firstname || ' ' || COALESCE(e.lastname,'') AS "Employee's Name",
m.firstname || ' ' || COALESCE(m.lastname,'') AS "Manager's Name"
FROM employees e
JOIN employees m
ON e.managerid = m.employeeid






