CREATE DATABASE ZTDATAS;
GO

USE ZTDATAS;
GO


CREATE TABLE Staging_table 
(
	 order_id INT,
	 order_date VARCHAR(20),
	 order_type VARCHAR(50),
	 name_prefix VARCHAR(10),
	 Firstname VARCHAR(100),
	 lastname VARCHAR(100),
	 Gender VARCHAR(1),
	 Age_in_YRS VARCHAR(3),
	 Email VARCHAR(100),
	 TotalRevenue VARCHAR(20),
	  TotalCocst VARCHAR(20),
	 PaymentType VARCHAR(50),
	 OrderStatus VARCHAR(50),
	 Town NVARCHAR(100),
	 City NVARCHAR(100),
	 State NCHAR(2),
	 Region VARCHAR(20)
);
 GO

---Populating Staging_table by bulk insert method

BULK INSERT Staging_table
FROM 'C:\Users\NEW USER\Analytics\Order_Log csv 3.csv'
WITH 
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a',
	CODEPAGE = '1252'
);
GO

SELECT *
FROM Staging_table;

SELECT COUNT(*) AS tottal_records
FROM Staging_table;
GO

CREATE TABLE staging_order_proper_datatype
(
	order_id INT,
	order_date DATE,
	order_type VARCHAR(20),
	name_prefix VARCHAR(10),
	firstname NVARCHAR(50),
	lastname NVARCHAR(50),
	gender CHAR(1),
	Age_in_yrs INT,
	Email NVARCHAR(100),
	TotalRevenue DECIMAL(10,2),
	TotalCost DECIMAL(10,2),
	payment_type VARCHAR(20),
	orderstatus VARCHAR(20),
	town NVARCHAR(50),
	city NVARCHAR(50),
	state CHAR(2),
	Region VARCHAR(20)
);


INSERT INTO staging_ordeer_proper_datatype
(
	order_id,
	order_date,
	order_type,
	name_prefix,
	firstname,
	lastname,
	gender,
	Age_in_yrs,
	Email,
	TotalRevenue,
	TotalCost,
	payment_type,
	orderstatus,
	town,
	city,
	state,
	Region
)
SELECT DISTINCT
	order_id,
	TRY_CONVERT(DATE, order_date, 103),
	order_type,
	name_prefix,
	Firstname,
	lastname,
	Gender,
	TRY_CONVERT(INT, Age_in_YRS),
	Email,
	TRY_CONVERT(DECIMAL, TotalRevenue),
	TRY_CONVERT(DECIMAL, TotalCocst),
	PaymentType,
	Orderstatus,
	TRY_CONVERT(NVARCHAR, Town),
	TRY_CONVERT(NVARCHAR, city),
	State,
	REgion
FROM Staging_table;
GO

SELECT *
FROM staging_ordeer_proper_datatype;
GO

SELECT COUNT(*) AS total_reocrds
FROM staging_ordeer_proper_datatype;
GO


SELECT 
COLUMN_NAME,
DATA_TYPE,
CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY ORDINAL_POSITION;
GO

---NORMALIZATION
---Region Table
CREATE TABLE Regions
(
	Region_id INT IDENTITY(1,1) PRIMARY KEY,
	Region_name VARCHAR(20)
);
GO

INSERT INTO Regions (Region_name)
SELECT DISTINCT
 Region
FROM staging_ordeer_proper_datatype;

SELECT *
FROM Regions;
GO

SELECT COUNT(*)	total_records
FROM Regions;
GO

---States Table
CREATE TABLE States
(
	state_id INT IDENTITY(1,1) PRIMARY KEY,
	Region_id INT FOREIGN KEY REFERENCES Regions(Region_id),
	state_name NCHAR(2)
);
GO

INSERT INTO States
(
	Region_id,
	state_name
)
SELECT DISTINCT
	r. Region_id,
	s. State

FROM staging_ordeer_proper_datatype s
JOIN Regions r
	ON r. Region_name = s. Region;

SELECT *
FROM States;
GO

SELECT COUNT(*) AS total_record
FROM States;
GO

---Address Table
CREATE TABLE address
(
	address_id INT IDENTITY(1,1) PRIMARY KEY,
	state_id INT FOREIGN KEY REFERENCES States(state_id),
	town NVARCHAR(50),
	city NVARCHAR(50)
);
GO

INSERT INTO address
(
	state_id,
	town,
	city
)
SELECT DISTINCT	
	st. state_id,
	s. town,
	s. city
FROM staging_ordeer_proper_datatype s
JOIN States st
	ON st. state_name = s. State;
GO

SELECT *
FROM address;
GO

SELECT COUNT(*) AS total_records_address
FROM address;
GO


   ---CHECKING THE UNIQUENESS OF CITY
SELECT 
   city,
COUNT(*) AS ocurencies 
FROM address
GROUP BY city
HAVING COUNT(*) > 1;
GO

---Customer Table
CREATE TABLE customers
(
	customer_id INT IDENTITY(1,1) PRIMARY KEY,
	address_id INT FOREIGN KEY REFERENCES address(address_id),
	name_prefix VARCHAR(5),
	firstname VARCHAR(50),
	lastname VARCHAR(50),
	Gender CHAR(1),
	Age_in_yrs INT,
	Email NVARCHAR(100)
);
GO


INSERT INTO customers 
(
	address_id,
	name_prefix,
	firstname,
	lastname,
	Gender,
	Age_in_yrs,
	Email
)
SELECT DISTINCT
	 a. address_id,
	 s. name_prefix,
	 s. firstname,
	 s. lastname,
	 s. gender,
	 Age_in_YRS,
	 Email
FROM  staging_ordeer_proper_datatype s
JOIN Regions r
	ON r. Region_name = s. Region
JOIN States st
	ON st. state_name = s. State
JOIN address a
	ON a. city = s. city
	AND a. town = s. town;
GO




---Orders Table
CREATE TABLE Orders
(
	orderkey INT IDENTITY(1,1) PRIMARY KEY,
	customer_id INT FOREIGN KEY REFERENCES customers,
	order_id INT,
	order_date DATE,
	order_type VARCHAR(20),
	order_status VARCHAR(20)
);
GO

INSERT INTO Orders
(
	customer_id,
	order_id,
	order_date,
	order_type,
	order_status
)
SELECT DISTINCT
	c. customer_id,
	s. order_id,
	s. order_date,
	s. order_type,
	s. orderstatus
FROM staging_ordeer_proper_datatype s
JOIN customers c
	ON c. email = s. Email;
GO

---Transactions Table
CREATE TABLE transactions 
(
	transaction_id INT IDENTITY(1,1) PRIMARY KEY,
	orderkey INT FOREIGN KEY REFERENCES Orders,
	totalrevenue DECIMAL(10,2),
	totalcost DECIMAL(10,2),
	Payment_type VARCHAR(20)
);
GO

INSERT INTO transactions 
(
	orderkey,
	totalrevenue,
	totalcost,
	Payment_type
)
SELECT DISTINCT
	o. orderkey,
	s. TotalRevenue,
	TotalCost,
	payment_type
FROM staging_ordeer_proper_datatype s
JOIN orders o
	ON o. order_id = s. order_id
	AND o. order_date = s. order_date
	AND o. order_type = s. order_type
	AND o. order_status = s. orderstatus;
GO





---ANALYSIS

---1. What is the total revenue, cost and profit of the business?

SELECT
	ROUND(SUM(totalrevenue), 2) AS totalrevenue,
	ROUND(SUM(totalcost), 2) AS total_cost,
	ROUND(SUM(totalrevenue - totalcost), 2) AS profit
FROM transactions;
GO




---2. what is the region with the highest total profit, revenue and cost?
SELECT
	 r. region_name,
	 ROUND(SUM(t. totalrevenue), 2) AS Total_revenue,
	 ROUND(SUM(t. totalcost), 2) AS Totalcost,
	 ROUND(SUM(t. totalrevenue - t. totalcost), 2) AS profit
 FROM Regions r
 JOIN States st
	ON st. region_id = r. region_id
JOIN address a
	ON a. state_id = st. state_id
JOIN customers c
	ON c. address_id = a. address_id
JOIN orders o
	ON o. customer_id = c. customer_id
JOIN transactions t
	ON t. orderkey = o. orderkey
 GROUP BY region_name
 ORDER BY profit DESC;
 GO








---3. Which states and cities are the most profitable?

SELECT TOP 10
	s. state_name,
	a. city,
	SUM(t. totalrevenue - t. totalcost) AS profit
FROM States s
JOIN address a
	ON a. state_id = s. state_id
JOIN customers c
	ON c. address_id = a. address_id
JOIN orders o
	ON o. customer_id = c. customer_id
JOIN transactions t
	ON t. orderkey = o. orderkey
GROUP BY 
s. state_name,
	a. city
ORDER BY profit DESC;
GO




---4. which customers generate the highest revenue?

SELECT
	c. customer_id,
	CONCAT(c.firstname, ' ', c. lastname) AS full_name,
	c. email,
	a. city,
	FORMAT(SUM(t. totalrevenue), 'C', 'en-US') AS Total_revenue
FROM customers c
JOIN address a
	ON a. address_id = c. address_id
JOIN orders o
	ON o. customer_id = c.customer_id
JOIN transactions t
	ON t. orderkey = o. orderkey
GROUP BY
	c. customer_id,
	CONCAT(c. firstname, ' ', c. lastname),
	c. email,
	a. city
ORDER BY SUM(t. totalrevenue) DESC;
GO




---5. which customer have the highest order?
SELECT TOP 20
	CONCAT(c.firstname, ' ', c. lastname) AS full_name,
COUNT(DISTINCT(o.orderkey)) AS toal_orders
FROM customers c
JOIN address a
	ON a. address_id = c. address_id
JOIN orders o
	ON o. customer_id = c.customer_id
JOIN transactions t
	ON t. orderkey = o. orderkey
GROUP BY
	CONCAT(c. firstname, ' ', c. lastname)
ORDER BY COUNT(DISTINCT o. orderkey) DESC;
GO




---6. What percentage of customers have placed more than one order?
WITH CustomerOrders AS
(
    SELECT
        c.customer_id,
        COUNT(DISTINCT o.orderkey) AS Number_of_Orders
    FROM customers c
    JOIN Orders o
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_id
)
SELECT
    COUNT(CASE WHEN Number_of_Orders > 1 THEN 1 END) 
        AS Repeat_Customers,

    COUNT(*) AS Customers_With_Orders,

    ROUND(
        COUNT(CASE WHEN Number_of_Orders > 1 THEN 1 END) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS Repeat_Customer_Percentage
FROM CustomerOrders;
GO




---7. What percentage of orders are completed, cancelled, and pending?

WITH orderstatus_cat AS 
(
SELECT 
	orderkey,
	CASE
		WHEN(order_status) = ('Shipped') THEN 'Shipped'
		WHEN(order_status) = ('Returned') THEN 'Returned'
		WHEN(order_status) = ('Pending') THEN 'Pending'
		ELSE 'others'
		END AS statuscategory
FROM orders
),
Statuscount AS
(
SELECT
	COUNT (*) AS totalorders,
	SUM(CASE WHEN statuscategory = 'Shipped' THEN 1 ELSE 0 END) AS ordercompleted,
	SUM(CASE WHEN statuscategory = 'Returned' THEN 1 ELSE 0 END) AS orderreturned,
	SUM(CASE WHEN statuscategory = 'Pending' THEN 1 ELSE 0 END) AS Pending_orders
FROM orderstatus_cat
)
SELECT
v. statuscategory,
v. ordercount,
CAST(
	100 * ordercount/ NULLIF(s. totalorders, 0) AS DECIMAL(6,2)
	)
	AS percentage_of_orders
FROM Statuscount s
CROSS APPLY 
(
	VALUES
	('Shipped', s. ordercompleted),
	('Returned', s. orderreturned),
	('Pending', s. Pending_orders)
) v(statuscategory, ordercount)
ORDER BY percentage_of_orders DESC; 



---8. How does monthly revenue and order volume change over time?
SELECT
		YEAR(o. order_date) AS YEAR,
		MONTH(o. order_date) AS MONTH,
	COUNT(DISTINCT o. orderkey) AS order_volume, 
	SUM(COALESCE(t. totalrevenue, 0)) AS total_revenue
FROM Orders o 
LEFT JOIN transactions t
	ON t. orderkey = o. orderkey
WHERE order_date IS NOT NULL 
GROUP BY 
	YEAR(order_date),
	MONTH(order_date)
ORDER BY
	YEAR,
	MONTH;

---ALTERNATIVE QUERY:
SELECT
	DATEFROMPARTS
	(
		YEAR(o. order_date),
		 MONTH(o. order_date), 1
	) AS ordermonth,
	COUNT(DISTINCT o. orderkey) AS OrderValume,
	SUM(COALESCE(t. totalrevenue, 0)) AS TotalRevenue
FROM orders o
LEFT JOIN transactions t
	ON t. orderkey = o. orderkey
GROUP BY 
	YEAR(o. order_date),
    MONTH(o. order_date)
ORDER BY 
	ordermonth;





---9. Which payment methods are most popular, and how much revenue does each generate?
SELECT
	COALESCE(t. Payment_type, 'unknown') AS paymentMethod,
	COUNT(DISTINCT t. transaction_id) AS pop_score,
	SUM(t. totalrevenue) AS revenue
FROM transactions t
GROUP BY COALESCE(t. Payment_type, 'unknown')
ORDER BY 
	revenue DESC,
	pop_score;
GO




---10. Which geographic areas have many customers but relatively low revenue?
WITH GeographicPerformance AS
(
    SELECT
        s.state_name AS StateName,
        a.city AS City,

        COUNT(DISTINCT c.customer_id) AS CustomerCount,

        COUNT(DISTINCT o.orderkey) AS OrderCount,

        SUM(COALESCE(t.totalrevenue, 0)) AS TotalRevenue,

        SUM(COALESCE(t.totalcost, 0)) AS TotalCost,

        SUM(COALESCE(t.totalrevenue, 0))
            - SUM(COALESCE(t.totalcost, 0)) AS TotalProfit

    FROM States s

    JOIN Address a
        ON a.state_id = s.state_id

    JOIN Customers c
        ON c.address_id = a.address_id

    LEFT JOIN Orders o
        ON o.customer_id = c.customer_id

    LEFT JOIN transactions t
        ON t.orderkey = o.orderkey

    GROUP BY
        s.state_name,
        a.city
),
GeographicMetrics AS
(
    SELECT
        StateName,
        City,
        CustomerCount,
        OrderCount,
        TotalRevenue,
        TotalCost,
        TotalProfit,

        CAST(
            TotalRevenue * 1.0 / NULLIF(CustomerCount, 0)
            AS DECIMAL(18,2)
        ) AS RevenuePerCustomer,

        CAST(
            TotalProfit * 1.0 / NULLIF(CustomerCount, 0)
            AS DECIMAL(18,2)
        ) AS ProfitPerCustomer

    FROM GeographicPerformance
),
Benchmarks AS
(
    SELECT
        AVG(CAST(CustomerCount AS DECIMAL(18,2)))
            AS AverageCustomerCount,

        AVG(RevenuePerCustomer)
            AS AverageRevenuePerCustomer,

        AVG(ProfitPerCustomer)
            AS AverageProfitPerCustomer

    FROM GeographicMetrics
)
SELECT
    g.StateName,
    g.City,
    g.CustomerCount,
    g.OrderCount,
    g.TotalRevenue,
    g.TotalProfit,
    g.RevenuePerCustomer,
    g.ProfitPerCustomer

FROM GeographicMetrics g

CROSS JOIN Benchmarks b

WHERE
    g.CustomerCount > b.AverageCustomerCount
    AND
    (
        g.RevenuePerCustomer < b.AverageRevenuePerCustomer
        OR
        g.ProfitPerCustomer < b.AverageProfitPerCustomer
    )
ORDER BY
    g.ProfitPerCustomer ASC,
    g.CustomerCount DESC;

---	Geographic performance metrics view
GO
CREATE OR ALTER VIEW vw_geographicPerformance AS
	WITH Geographicperformance AS 
	(
		SELECT
			s. state_name AS StateName,
			a. city AS City,
			COUNT(DISTINCT C. customer_id) AS customerCount,
			COUNT(DISTINCT O. orderkey) AS orderCount,
			SUM(COALESCE(t. totalrevenue, 0)) AS TotalRevenue,
			SUM(COALESCE(t. totalcost, 0)) AS TotalCost,
			SUM(COALESCE(t. totalrevenue, 0)) - SUM(COALESCE(t. totalcost, 0)) AS TotalProfit
		FROM States s
		JOIN  address a
			ON a. state_id	= s. state_id
		JOIN customers c
			ON c. address_id = a. address_id
		LEFT JOIN orders o
			ON c. customer_id = o. customer_id
		LEFT JOIN transactions t
			ON t. orderkey = o. orderkey
	    GROUP BY 
			s. state_name,
			a. city
	),
	GeographicMetrics AS
	(
		SELECT
			StateName,
			City,
			customerCount,
			orderCount,
			TotalRevenue,
			TotalCost,
			TotalProfit,
			CAST(TotalRevenue *1.0 / NULLIF(customerCount, 0) AS DECIMAL(18,2)) AS RevenueperCustomer,
			CAST(TotalProfit * 1.0 / NULLIF(customerCount, 0) AS DECIMAL(18,2)) AS profitPerCustomer
		FROM GeographicPerformance
	)
		SELECT
			StateName,
			City,
			customerCount,
			orderCount,
			TotalRevenue,
			TotalProfit,
			RevenueperCustomer,
			profitPerCustomer
		FROM GeographicMetrics;
GO

SELECT *
FROM vw_geographicPerformance;
GO


