 --Question 1: Which Products Should We Order More of or Less of?

 WITH restocking AS (
SELECT ROUND(SUM(CAST(quantityOrdered AS float)) /CAST(quantityInStock AS float),2) AS low_stock,
(quantityOrdered*priceEach)  AS product_performance, productName, productLine
  FROM (SELECT quantityOrdered, quantityInStock,priceEach, orderdetails.productCode, productName, productLine
  FROM orderdetails 
  JOIN products
    ON products.productCode = orderdetails.productCode)
 GROUP BY productCode
 ORDER BY product_performance DESC, low_stock DESC
 LIMIT 10
)

SELECT *
  FROM restocking

--The highest performance products are classic cars. It' s priority for restocking.



--Question 2: How Should We Match Marketing and Communication Strategies to Customer Behavior? 

 WITH profits AS(
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit, contactLastName, contactFirstName, city,  country
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber

 JOIN customers c
 ON c.customerNumber = o.customerNumber
 

  GROUP BY o.customerNumber
 )
 
 SELECT  profit, customerNumber, contactLastName, contactFirstName, city,  country
 FROM profits
ORDER BY profit DESC
LIMIT 5

--Now, we have information about VIP customers. We can look at what these people have in common and use that in the marketing narrative



--Question 3: How Much Can We Spend on Acquiring New Customers? 

 WITH profits AS(
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit, contactLastName, contactFirstName, city,  country
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber

 JOIN customers c
 ON c.customerNumber = o.customerNumber
 

  GROUP BY o.customerNumber
 )
 
 SELECT    AVG(profit) AS LTV
 FROM profits
ORDER BY profit DESC

LIMIT 5

--We compute LTV( Life time value). LTV tells us how much profit an average customer generates during their lifetime
-- We could compute CAC indicator
