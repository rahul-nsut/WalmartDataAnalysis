CREATE DATABASE IF NOT EXISTS `salesDataWalmart`

-- Creating and filling the table with data from the csv file

CREATE TABLE IF NOT EXISTS sales{
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(50) NOT NULL,
    customer_type VARCHAR(10) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
};

-- putting the data from the csv file (taken from kaggle) into the table


-- Feature Engineering
SELECT 
    time,
    (CASE 
        WHEN `time` BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN `time` BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        WHEN `time` BETWEEN '18:00:00' AND '23:59:59' THEN 'Evening'
        ELSE 'Night'
    END
    )AS time_of_day

FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(15);

UPDATE sales
SET time_of_day = 
    (CASE 
        WHEN `time` BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN `time` BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        WHEN `time` BETWEEN '18:00:00' AND '23:59:59' THEN 'Evening'
        ELSE 'Night'
    END
    );

-- day name
SELECT date, DAYNAME(date)  as day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(15);

UPDATE sales
SET day_name = DAYNAME(date);

--month name
SELECT
    date,
    MONTHNAME(date) as month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name = MONTHNAME(date);

-- EDA Started (Product Related Queries)


-- How many unique cities & branches are there in the dataset?
SELECT
    DISTINCT city as unique_cities
    DISTINCT branch as unique_branches
FROM sales;


--Product analysis

-- Number of unique product lines in the dataset
SELECT
    COUNT(DISTINCT product_line) as unique_product_lines
FROM sales;

--Most Common Payment Method    
SELECT 
    payment as payment_method,
    COUNT(payment) as count
FROM sales
GROUP BY payment_method
ORDER BY count DESC;


-- Most selling product line

SELECT 
    product_line as product,
    COUNT(product_line) as count
FROM sales
GROUP BY product
ORDER BY count DESC;

--total revenue per month
SELECT
    month_name as month,
    SUM(total) as total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

--find month with largest COGS
SELECT
    month_name as month,
    SUM(cogs) as cogs,
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

--which product line has largest revenue

SELECT 
    product_line,
    SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

--what product line has largest VAT (Value Added Tax)

SELECT 
    product_line,
    avg(VAT) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- which branches sold more products than average products sold in branch
SELECT
    branch,
    SUM(quantity) as qty,
FROM sales
GROUP BY branch
HAVING qty > (SELECT AVG(quantity) FROM sales);

--Most Common product line according to gender

SELECT
    gender,
    product_line,
    COUNT(gender) as total_count
FROM sales
GROUP BY gender,product_line
GROUP BY total_count DESC;


--Average rating of products sold in each line
SELECT
    ROUND(AVG(rating),2) as avg_rating,
    product_line,
FROM sales
GROUP BY product_line;
ORDER BY avg_rating DESC;

------------------------------------------------

-- Sales related Queries

--Number of sales made in each time per weekday
SELECT
    time_of_day,
    day_name,
    COUNT(*) as total_sales

FROM sales
WHERE day_name = 'Monday' -- or any other day
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which customer types bring the most revenue
SELECT
    customer_type,
    SUM(total) as total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;


--Which city has the largest percentage of VAT (Value Added Tax)
SELECT
    city,
    SUM(VAT) as total_VAT
FROM sales
GROUP BY city
ORDER BY total_VAT DESC;

-- Which customer type pays most of VAT
SELECT
    customer_type,
    AVG(VAT) as total_VAT
FROM sales
GROUP BY customer_type
ORDER BY total_VAT DESC;


----------------------------------------------

-- Customer related Queries

-- How many unique customer types are there in the dataset?
SELECT
    DISTINCT customer_type as unique_customer_types
FROM sales;

-- How many Unique Payment Methods are there in the dataset?
SELECT
    DISTINCT payment_method as unique_payment_methods
FROM sales;

-- Which customer type buys most products in the dataset?
SELECT
    customer_type
    COUNT(*) as customer_count
FROM sales
GROUP BY customer_type

--What is gender of most of the customers
SELECT
    gender,
    COUNT(*) as gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;

-- What is the gender distribution per branch
SELECT
    gender,
    COUNT(*) as gender_count
FROM sales
WHERE branch = 'A'  -- or any other branch as per requirement
GROUP BY gender
ORDER BY gender_count DESC;


-- Which time of the day do customers give most rating
SELECT
    time_of_day,
    AVG(rating) as avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

--Which time of the day do customers give most ratings per branch
SELECT
    time_of_day,
    AVG(rating) as avg_rating
FROM sales
WHERE branch = 'A'  -- or any other branch as per requirement
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C" -- or any other branch as per requirement
GROUP BY day_name
ORDER BY total_sales DESC;
