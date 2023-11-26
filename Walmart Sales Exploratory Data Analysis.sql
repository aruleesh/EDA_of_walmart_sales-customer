-- to know the datatype of the table
DESCRIBE walmart;


-- Q1.CHANGE THE DATE DATA TYPE INTO THE TABLE
ALTER TABLE walmart ADD COLUMN ndate DATE;

SET SQL_SAFE_UPDATES = 0;

UPDATE walmart
SET ndate = STR_TO_DATE(Date, '%c/%e/%y');

ALTER TABLE walmart
DROP COLUMN Date;

-- Q2.THE TOTAL NUMBER OF RECORDS IN THE DATASET
-- A2. TOTAL NUMBER OF RECORDS ARE 1000
SELECT COUNT(*)
FROM walmart;


-- Q3.ADD THE CUSTOM CATEGORY OF THE TIME INTO THE TABLE(LIKE MORNING,AFTERNOON,EVENING)
ALTER TABLE walmart
ADD COLUMN cat_of_time VARCHAR(512);

SET SQL_SAFE_UPDATES = 0;

UPDATE walmart
SET cat_of_time = 
(CASE WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
WHEN time BETWEEN '12:00:01' AND '16:00:00' THEN 'Afternoon'
WHEN time BETWEEN '16:00:01' AND '24:00:00' THEN 'Evening'
END );


-- Q4.ADD THE DATE NAME INTO THE TABLE(LIKE MONDAY, TUESDAY....)
ALTER TABLE walmart
ADD COLUMN day_of_date VARCHAR(512);

UPDATE walmart
SET day_of_date = DAYNAME(ndate);


-- Q5. ADD THE MONTH NAME INTO THE TABLE(JANUARY,FEBURARY,....)
ALTER TABLE walmart
ADD COLUMN month_name VARCHAR(512);

UPDATE walmart
SET month_name = MONTHNAME(ndate);


-- Q6. HOW MANY THE UNIQUE CITY DOES THE DATA HAVE?
-- A6.THE UNIQUE CITY IN THE DATA ARE Yangon,Naypyitaw,Mandalay
SELECT DISTINCT city
FROM walmart;


-- Q7. WHAT ARE THE BRANCHES IN EACH CITIES?
-- Q8. THE BRANCHES ARE A,B,C IN CITY Yangon,Mandalay,Naypyitaw RESPECTIEVELY
SELECT city, GROUP_CONCAT(DISTINCT(branch))
FROM walmart
GROUP BY city;


-- Q8. WHAT ARE THE UNIQUE PRODUCTS THAT THE DATA SET HAVE?
-- A8. THE UNIQUE PRODUCT LINES WERE Health and beauty,Electronic accessories,Home and lifestyle,Sports and travel,Food and beverages,Fashion accessories
SELECT DISTINCT(product_line)
FROM walmart;


-- Q10. WHAT IS THE MOST SELLING PRODUCT LINE?
-- A10. THE MOST SELLING PRODUCT LINE IS Electronic accessories WITH 971 QUANTITY
WITH sales AS (
SELECT product_line, SUM(quantity) AS quantity
FROM walmart
GROUP BY Product_line)

SELECT *
FROM sales
ORDER BY quantity DESC
LIMIT 1;

-- Q11. WHAT IS THE MOST COMMON PAYMENT METHOD?
-- A11.THE MOST COMMON PAYMENT METHOD IS Ewallet WITH 345 TIMES
WITH com_pay AS (
SELECT payment, COUNT(payment) AS payment_times
FROM walmart
GROUP BY payment)

SELECT *
FROM com_pay
ORDER BY payment_times DESC
LIMIT 1;

-- Q12. WHAT IS THE TOTALL REVENUE BY MONTH?
-- A12. THE TOTAL REVENUE FOR January IS 116292,March IS 109456,February IS 97219
SELECT month_name , ROUND(SUM(total)) AS revenue
FROM walmart
GROUP BY month_name;

-- Q13. WHAT MONTH HAD THE LARGEST COGS?
-- A13. January	WITH 110754 COG'S
SELECT month_name , ROUND(SUM(cogs)) AS total_cogs
FROM walmart
GROUP BY month_name
ORDER BY total_cogs DESC
LIMIT 1;


-- Q14. WHAT PRODUCT LINE HAD THE LARGEST REVENUE?
-- A14. Food and beverages WITH REVENUE OF 56145 
SELECT product_line , ROUND(SUM(total)) AS revenue
FROM walmart 
GROUP BY Product_line
ORDER BY  revenue DESC
LIMIT 1;


-- Q15. WHICH CITY WITH LARGEST REVENUE?
-- A15. Naypyitaw WITH REVENUE OF 110569
SELECT city, ROUND(SUM(TOTAL)) AS revenue
FROM walmart
GROUP BY city
ORDER BY revenue DESC
LIMIT 1;

-- Q16. WHAT PRODUC LINE HAVE THE HIGHEST TAX?
-- A16. Home and lifestyle WITH HIGHEST TAX OF	16%
SELECT product_line, ROUND(AVG(tax_5_percent)) AS tax
FROM walmart
GROUP BY Product_line
ORDER BY tax DESC
LIMIT 1;


-- Q17. FETCH EACH PRODUCT LINE AND ADD A COLUMN TO THOSE PRODUCT LINE SHOWING "GOOD" AND "BAD". GOOD IF ITS GREATER THAN AVERAGE SALES
ALTER TABLE walmart
ADD COLUMN sales_char VARCHAR(512); 

WITH avg_sales AS (
    SELECT product_line, ROUND(AVG(total)) AS sales
    FROM walmart
    GROUP BY product_line
)

UPDATE walmart AS w
LEFT JOIN avg_sales AS a
ON w.Product_line = a.Product_line
SET w.sales_char = CASE 
    WHEN w.total > a.sales THEN 'GOOD'
    ELSE 'BAD'
END;


-- Q18. WHICH BRANCH SOLD MORE PRODUCTS THAN THE AVERAGE PRODUCT SOLD?
-- Q18. ALL THREE BRANCHES SOLD MORE THAN AVERAGE
SELECT DISTINCT(branch), SUM(quantity) AS product_sold
FROM walmart
WHERE Quantity > (SELECT AVG(Quantity) FROM walmart)
GROUP BY branch;

-- Q19. WHAT IS THE MOST COMMON PRODUCT LINE BY GENDER?
-- A19. Female BUY Health and beauty WITH TOTAL PURCHASE OF 343, Male BUY Fashion accessories WITH TOTAL PURCHASE OF 372
WITH gp AS (
SELECT gender, product_line, SUM(quantity) AS total_purchase , RANK() OVER(PARTITION BY gender ORDER BY SUM(quantity)) AS rnk
FROM walmart
GROUP BY gender,Product_line)

SELECT gp.gender, gp.product_line, gp.total_purchase
FROM gp
WHERE gp.rnk = 1;


-- Q20. WHAT IS THE AVERAGE RATING IN EACH PRODUCT LINE?
SELECT product_line , ROUND(AVG(rating))
FROM walmart
GROUP BY Product_line;


-- Q21. NUMBER OF SALES MADE IN EACH TIME OF THE DAY PER WEEKDAY
/* A21. 
Friday	Afternoon	319
Friday	Evening	299
Friday	Morning	140
Monday	Afternoon	248
Monday	Evening	274
Monday	Morning	116
Saturday	Afternoon	320
Saturday	Evening	438
Saturday	Morning	161
Sunday	Afternoon	305
Sunday	Evening	329
Sunday	Morning	144
Thursday	Afternoon	257
Thursday	Evening	319
Thursday	Morning	179
Tuesday	Afternoon	303
Tuesday	Evening	386
Tuesday	Morning	173
Wednesday	Afternoon	359
Wednesday	Evening	316
Wednesday	Morning	125*/

SELECT day_of_date,cat_of_time,SUM(Quantity)
FROM walmart
GROUP BY day_of_date,cat_of_time
ORDER BY day_of_date,cat_of_time;

-- Q22. WHICH OF THE CUSTOMER TYPES BRINGS THE MOST REVENUE?
-- A22. Normal WITH REVENUE OF 158743
SELECT Customer_type,ROUND(SUM(Total)) AS revenue
FROM walmart
GROUP BY Customer_type
ORDER BY revenue
LIMIT 1;

-- Q23. WHICH PRODUCT LINE HAS HIGH TAX PERCENT  / VAT IN EACH CITY ?
/* A23.
Mandalay	Fashion accessories	13
Naypyitaw	Home and lifestyle	15
Yangon	Health and beauty	13 */

WITH tax AS (
SELECT city, product_line, ROUND(AVG(Tax_5_percent)) AS avg_tax ,RANK() OVER(PARTITION BY city ORDER BY AVG(Tax_5_percent)) AS rnk
FROM walmart
GROUP BY city,Product_line)

SELECT tax.*
FROM tax
WHERE tax.rnk = 1;

-- Q24. WHICH CONSUMER TYPE PAY THE MOST IN VAT?
-- A24. Member WITH AVERAGE TAX OF	16%
SELECT customer_type , ROUND(AVG(tax_5_percent)) AS vat
FROM walmart
GROUP BY Customer_type
ORDER BY vat DESC
LIMIT 1;

-- Q25. HOW MANY UNIQUE CUSTOMER TYPES DOES THE DATA HAVE?
-- A25. THE UNIQUE CUSTOMER TYPE IS Member, Normal
SELECT DISTINCT(customer_type) AS unique_costomer
FROM walmart;


-- Q26. WHAT IS THE MOST COMMON CUSTOMER TYPE?
-- A26. Member WITH TOTAL PURCHASE OF 	501
SELECT customer_type, COUNT(customer_type)  AS purchase_time
FROM walmart
GROUP BY customer_type
ORDER BY purchase_time DESC
LIMIT 1;

-- Q27. HOW MANY UNIQUE PAYMENT METHODS DOES THE DATA HAVE?
/* A27 
Ewallet
Cash
Credit card */
SELECT DISTINCT payment
FROM walmart;

-- Q28. WHICH CUSTOMER TYPE BUYS THE MOST?
-- A28. Member WITH	SPENDING OF 164223
SELECT Customer_type, ROUND(SUM(Total)) AS spending
FROM walmart
GROUP BY Customer_type
ORDER BY spending DESC
LIMIT 1;

-- Q29. WHAT IS THE GENDER OF THE MOST OF THE CUSTOMERS?
-- A29. Female WITH 501 PURCHASE
SELECT gender , COUNT(gender) AS count
FROM walmart
GROUP BY gender
ORDER BY count DESC
LIMIT 1;


-- Q30. WHAT IS THE GENDER DISTRIBUTION PER BRANCH?
/* A30. 
A	Female	161
A	Male	179
B	Female	162
B	Male	170
C	Female	178
C	Male	150 */ 

SELECT branch,gender, COUNT(gender)
FROM walmart
GROUP BY branch, gender
ORDER BY branch ;

-- Q31. WHICH TIME OF THE DAY DO CUSTOMERS GIVE MOST RATING?
-- A31. Evening	432 RATING WITH 7 AVERAGE RATING
SELECT cat_of_time, COUNT(Rating) AS rating_count, ROUND(AVG(Rating)) AS avg_rating
FROM walmart
GROUP BY cat_of_time
ORDER BY rating_count DESC
LIMIT 1;

-- Q32. WHICH DAY OF THE WEEK HAS THE BEST AVERAGE SALES
-- A32. Saturday WITH AVERAGE SALES OF 342
SELECT day_of_date , ROUND(AVG(total)) AS sales
FROM walmart
GROUP BY day_of_date
ORDER BY sales DESC
LIMIT 1;

-- Q33. WHICH MONTH OF THE YEAR HAS THE BEST AVERAGE SALES
-- A33. January	WITH AVERAGE SALES OF 330
SELECT month_name, ROUND(AVG(total)) AS sales
FROM walmart
GROUP BY month_name
ORDER BY sales DESC
LIMIT 1;