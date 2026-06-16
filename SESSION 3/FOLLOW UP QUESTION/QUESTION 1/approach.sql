SELECT 
    cust_id AS customer_id,
    SUM(total_order_cost) AS revenue
FROM orders
WHERE order_date >= '2019-03-01' 
    AND order_date < '2019-04-01'
GROUP BY cust_id
HAVING SUM(total_order_cost) > 0
ORDER BY revenue DESC;