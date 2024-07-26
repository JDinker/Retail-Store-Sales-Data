

SELECT TOP 1 * FROM Customer
SELECT TOP 1 * FROM prod_cat_info
SELECT TOP 1 * FROM Transactions

--   DATA PREPARATION AND UNDERSTANDING

--Q1--BEGIN 
	   SELECT * FROM 
             ( SELECT 'customer' AS table_name,count(*) AS TOTALROWS FROM Customer
                UNION ALL 
                SELECT ' product_cat_info' AS table_name, COUNT(*) AS TOTALROWS FROM prod_cat_info
                UNION ALL
                SELECT ' Transcation' AS table_name, COUNT(*) AS TOTALROWS  FROM Transactions
				)TBL;
--Q1--END

--Q2--BEGIN 

SELECT COUNT (DISTINCT(transaction_id)) AS TOTAL_RETURNS
FROM Transactions as T
WHERE total_amt < 0;

--Q2--END

--Q3--BEGIN 

SELECT * FROM Transactions AS T 
UPDATE Transactions
SET tran_date = CONVERT(datetime, tran_date, 101)

SELECT * FROM Customer
UPDATE Customer
SET DOB = CONVERT(datetime, DOB, 101) 

--Q3--END

--Q4--BEGIN 

SELECT 
DATEDIFF (DAY, MIN(tran_date), MAX(tran_date)) AS DAY ,
DATEDIFF (MONTH, MIN(tran_date), MAX(tran_date)) AS MONTH,
DATEDIFF (YEAR, MIN(tran_date), MAX(tran_date)) AS YEAR FROM Transactions; 

--Q4--END

--Q5--BEGIN 

SELECT * FROM prod_cat_info
WHERE PROD_SUBCAT = 'DIY';

--Q5--END


--   DATA ANALYSIS

--Q1--BEGIN 

SELECT TOP 1 Store_type, count(*) AS Trans_freq 
FROM Transactions
GROUP BY Store_type
ORDER BY Trans_freq DESC;

--Q1--END

--Q2--BEGIN 

SELECT Gender, count(*)  AS Gender_count
FROM Customer AS C 
GROUP BY C.Gender 
HAVING C.Gender='M' OR C.Gender= 'F'

--Q2--END

--Q3--BEGIN 

SELECT City_code, COUNT(*) AS CustomerCount
FROM Customer
GROUP BY City_code
HAVING COUNT(*) = (
    SELECT MAX(CustomerCount)
    FROM (
        SELECT COUNT(*) AS CustomerCount
        FROM Customer
        GROUP BY City_code
    ) AS MaxCustomerCount
);
--Q3--END

--Q4--BEGIN 

SELECT COUNT(DISTINCT P.prod_sub_cat_code) AS SUB_CAT_BOOKS
FROM prod_cat_info AS P
WHERE P.prod_cat = 'Books';

--Q4--END

--Q5--BEGIN 

SELECT TOP 1 T.prod_cat_code,MAX(T.QTY) AS COUNT_PROD FROM Transactions AS T 
GROUP BY T.prod_cat_code

--Q5--END

--Q6--BEGIN 

SELECT SUM(T.TOTAL_AMT) AS TOTAL_REVENUE FROM Transactions AS T 
INNER JOIN  prod_cat_info AS P 
ON T.prod_subcat_code = P.prod_sub_cat_code
WHERE P.PROD_CAT = 'Electronics' OR P.PROD_CAT = 'Books'

--Q6--END

--Q7--BEGIN 

SELECT COUNT(*) AS customer_count
FROM (
    SELECT cust_id AS customer_id, COUNT(transaction_id) AS transaction_count
    FROM Transactions AS T
    WHERE T.total_amt > 0
    GROUP BY cust_id
    HAVING COUNT(transaction_id) > 10
) AS customer_transactions;

--Q7--END

--Q8--BEGIN 

 SELECT SUM(T.total_amt ) AS COMBINED_REVENUE FROM Transactions AS T 
 INNER JOIN prod_cat_info AS P
 ON T.prod_subcat_code = P.prod_sub_cat_code and t.prod_cat_code = P.prod_cat_code
WHERE P.prod_cat = 'Electronics'  OR P.prod_cat = 'Clothing'
AND T.store_type = 'Flagship store'

--Q8--END

--Q9--BEGIN 

SELECT P.prod_subcat, P.prod_sub_cat_code, SUM(T.total_amt) AS TotalRevenue
FROM Transactions  AS T 
INNER JOIN Customer AS C 
ON T.cust_id = C.customer_Id
INNER JOIN prod_cat_info AS P
ON T.prod_subcat_code = P.prod_sub_cat_code
WHERE C.Gender = 'M' OR P.prod_cat = 'Electronics'
GROUP BY P.prod_subcat, P.prod_sub_cat_code;

--Q9--END

--Q10--BEGIN 

SELECT TOP 5 P.PROD_SUBCAT,
    (SUM(T.total_amt)/ (SELECT SUM(T.total_amt) FROM Transactions AS T )) * 100 AS Percent_sales,
    (COUNT(CASE WHEN T.QTY < 0 THEN T.QTY ELSE NULL END)/SUM(T.QTY))*100 AS Percent_Return FROM Transactions AS T
    INNER JOIN prod_cat_info AS P 
	ON T.prod_cat_code = P.prod_cat_code
	AND T.prod_subcat_code = P.prod_sub_cat_code
GROUP BY P.prod_subcat
ORDER BY SUM(T.TOTAL_AMT) DESC;

--Q10--END

--Q11--BEGIN 
 
 SELECT 
    SUM(T.total_amt) AS net_total_revenue
FROM Customer AS C
INNER JOIN Transactions AS T  
ON T.cust_id = C.customer_Id
WHERE T.tran_date >= (SELECT DATEADD(DAY, -30, MAX(TRAN_DATE)) FROM Transactions AS T) AND
	( DATEDIFF(YEAR, C.DOB, GETDATE()) >= '25' AND DATEDIFF(YEAR, C.DOB, GETDATE()) <= ' 35');

--Q11--END

--Q12--BEGIN 

SELECT P.PROD_CAT, T.QTY, T.TOTAL_AMT, MAX(T.TRAN_DATE) AS MAX_DATE FROM Transactions AS T 
INNER JOIN prod_cat_info AS P 
ON T.prod_cat_code = P.prod_cat_code
AND 
T.prod_subcat_code = P.prod_sub_cat_code
WHERE 
TRAN_DATE>=( SELECT DATEADD(MONTH,-3,MAX(T.TRAN_DATE)) FROM Transactions AS T )
GROUP BY 
P.prod_cat,T.Qty,T.total_amt;

--Q12--END

--Q13--BEGIN 

SELECT T.Store_type, SUM(T.total_amt) AS TOTAL_SALES, SUM(T.Qty) AS TOTAL_QTY
FROM Transactions AS T 
GROUP BY T.Store_type
HAVING SUM(T.total_amt) >= ALL(SELECT SUM(T.total_amt)  AS TOTAL_SALES FROM Transactions AS T 
                               GROUP BY T.Store_type) AND
							   SUM(T.Qty) >= ALL( SELECT SUM(T.Qty) AS TOTAL_QTY FROM Transactions AS T 
                               GROUP BY T.Store_type);

--Q13--END

--Q14--BEGIN 

SELECT P.prod_cat, AVG(T.total_amt) AS AVG_
FROM Transactions AS T 
INNER JOIN prod_cat_info AS P 
ON T.prod_cat_code = P.prod_cat_code
GROUP BY P.prod_cat
HAVING AVG(T.total_amt) > (SELECT AVG(T.total_amt)
FROM Transactions AS T);

--Q14--END

--Q15--BEGIN 

SELECT P.prod_cat, P.prod_subcat, SUM(T.Qty) AS SUM_QTY, AVG(T.total_amt) AS AVG_REVENUE, SUM(T.total_amt) AS SUM_REVENUE
FROM Transactions AS T
INNER JOIN prod_cat_info AS P
ON T.prod_cat_code = P.prod_cat_code
AND T.prod_subcat_code = P.prod_sub_cat_code
WHERE P.prod_cat IN (SELECT TOP 5 P.prod_cat FROM Transactions AS T
                    INNER JOIN prod_cat_info AS P 
					ON T.prod_cat_code = P.prod_cat_code
					AND T.prod_subcat_code = P.prod_sub_cat_code
					GROUP BY P.prod_cat
					ORDER BY SUM(T.Qty) DESC)
GROUP BY P.prod_cat, P.prod_subcat;

--Q15--END