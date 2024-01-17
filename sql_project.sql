use sales;
-- Total revenue
SELECT SUM(transactions.sales_amount) as total_revenue
FROM transactions;

-- Total revenue for year 2020
SELECT SUM(transactions.sales_amount) as total_revenue
FROM transactions
where year(order_date)= 2020;

-- Total revenue for year 2020 and palce is Delhi NCR
SELECT SUM(transactions.sales_amount) as total_revenue
FROM transactions INNER JOIN markets ON transactions.market_code=markets.markets_code
where year(order_date)= 2020 and markets_name="Delhi NCR";

-- Total Orders
SELECT SUM(transactions.sales_qty) as total_orders
FROM transactions;

-- Total orders for year 2020
SELECT SUM(transactions.sales_qty) as total_orders
FROM transactions
where year(order_date)= 2020;

-- Total orders for year 2020 and palce is Delhi NCR
SELECT SUM(transactions.sales_qty) as total_orders
FROM transactions INNER JOIN markets ON transactions.market_code=markets.markets_code
where year(order_date)= 2020 and markets_name="Delhi NCR";

-- Total Profit
SELECT SUM(transactions.profit_margin) as total_Profit
FROM transactions;

-- Total Profit for year 2020
SELECT SUM(transactions.profit_margin) as total_profit
FROM transactions
where year(order_date)= 2020;

-- Total orders for year 2020 and palce is Delhi NCR
SELECT SUM(transactions.profit_margin) as total_profit
FROM transactions INNER JOIN markets ON transactions.market_code=markets.markets_code
where year(order_date)= 2020 and markets_name="Delhi NCR";

-- Top 5 Products
select products.product_code as product, sum(transactions.sales_amount) as Total_sales
from transactions INNER JOIN products ON transactions.product_code=products.product_code
group by products.product_code
order by Total_sales desc
limit 5;

-- Top 5 Products in year 2020
select products.product_code as product, sum(transactions.sales_amount) as Total_sales
from transactions INNER JOIN products ON transactions.product_code=products.product_code
where year(transactions.order_date)=2020
group by products.product_code
order by Total_sales desc
limit 5;

-- Top 5 Customers
select customers.custmer_name as customer, sum(transactions.sales_amount) as Total_sales
from transactions INNER JOIN customers ON transactions.customer_code=customers.customer_code
group by customers.custmer_name
order by Total_sales desc
limit 5;

-- profit percentage
select round((sum(profit_margin)/sum(sales_amount))*100,2) as profit_percentage
from transactions;

-- profit percentage for year 2020
select round((sum(profit_margin)/sum(sales_amount))*100,2) as profit_percentage
from transactions
where year(order_date)=2020;

-- total_sales and profit percentage with month
select monthname(order_date), sum(sales_amount) as total_sales,
round((sum(profit_margin)/sum(sales_amount))*100,2) as profit_percentage
from transactions
group by monthname(order_date);

-- Total Orders based on region and product type
select markets.zone as region, products.product_type, 
sum(transactions.sales_qty) as Total_orders
from transactions inner join markets on transactions.market_code= markets.markets_code
                  inner join products on transactions.product_code= products.product_code
group by region, products.product_type;

-- YOY Growth Analysis
SELECT 
  EXTRACT(YEAR FROM order_date) AS order_year,
  SUM(sales_amount) AS CY_sales,
  LAG(SUM(sales_amount), 1, 0) OVER (ORDER BY EXTRACT(YEAR FROM order_date)) AS PY_sales,
  round(((SUM(sales_amount)-LAG(SUM(sales_amount), 1, 0) OVER (ORDER BY EXTRACT(YEAR FROM order_date))
  )/LAG(SUM(sales_amount), 1, 0) OVER (ORDER BY EXTRACT(YEAR FROM order_date)))*100,2) as YOY,
  round((SUM(profit_margin) / SUM(sales_amount)) * 100, 2) AS profit_percentage
FROM transactions
GROUP BY order_year
ORDER BY order_year;

-- YoY sale analysis with Market City
WITH sales_by_year_and_market AS (
  SELECT
    markets.markets_name as market,
    YEAR(order_date) AS year,
    SUM(sales_amount) AS sales
  FROM transactions inner join markets on transactions.market_code= markets.markets_code
  WHERE YEAR(order_date) IN (2019, 2020)
  GROUP BY markets_name, YEAR(order_date)
)

SELECT
  m20.market,
  m20.sales AS sales_2020,
  m19.sales AS sales_2019,
  (m20.sales - m19.sales) / m19.sales * 100 AS yoy_growth_pct
FROM sales_by_year_and_market m20
JOIN sales_by_year_and_market m19
  ON m20.market = m19.market AND m19.year = 2019
WHERE m20.year = 2020
ORDER BY yoy_growth_pct DESC;

-- Since Electricalsara Store is the major customer and comprises around 45% on the total order 
-- we will analyse Electrical store 
-- Top Products Order by Electrical Store
SELECT
  transactions.product_code,  SUM(transactions.sales_amount)
FROM
  transactions
INNER JOIN
  customers ON transactions.customer_code = customers.customer_code
WHERE
  customers.custmer_name = "Electricalsara Stores" and year(order_date)=2020
GROUP BY
  transactions.product_code
ORDER BY
  SUM(transactions.sales_amount) DESC
LIMIT 5;

-- Top city with the maximum sales amount for Electrical Store.
SELECT
  markets.markets_name,  SUM(transactions.sales_amount)
FROM
  transactions
INNER JOIN
  markets ON transactions.market_code = markets.markets_code
INNER JOIN
  customers ON transactions.customer_code = customers.customer_code
WHERE
  customers.custmer_name = "Electricalsara Stores" and year(order_date)=2020
GROUP BY
   markets.markets_name
ORDER BY
  SUM(transactions.sales_amount) DESC
LIMIT 5;

-- Profit Analysis
-- Most Profitable Customer
Select customers.custmer_name, round((sum(profit_margin)/sum(sales_amount))*100,2) as Profit_Percentage
FROM
  transactions
INNER JOIN
  customers ON transactions.customer_code = customers.customer_code
GROUP BY customers.custmer_name
ORDER BY round((sum(profit_margin)/sum(sales_amount))*100,2) desc
Limit 5;

-- Leader is the most profitable customer
select sum(sales_amount)
FROM transactions
INNER JOIN
  customers ON transactions.customer_code = customers.customer_code
where customers.custmer_name="Leader" ;

select customers.custmer_name as Name, sum(profit_margin)
FROM transactions
INNER JOIN
  customers ON transactions.customer_code = customers.customer_code
group by  customers.custmer_name
order by sum(profit_margin) desc
limit 5;

-- Most Profitable Products
select product_code as Name, sum(profit_margin)
FROM transactions
group by product_code
order by sum(profit_margin) desc
limit 5;

-- Since Prod329, Prod324, Prod316 and Prod318 majorly contribute to the overall sales and profit and it is mostly ordered by Electricalsara store
-- Region with maximum order with the above product
 
 select markets.markets_name as market, sum(sales_qty) as total_orders
 FROM
  transactions
INNER JOIN
  markets ON transactions.market_code = markets.markets_code
where product_code in ("Prod329", "Prod324", "Prod316", "Prod318")
group by markets.markets_name
order by sum(sales_qty) desc
limit 5;
