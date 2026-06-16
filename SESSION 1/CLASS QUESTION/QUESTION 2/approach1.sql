 -- Create Table
  CREATE TABLE employee (
      eid INT,
      dept VARCHAR(10),
      scores DECIMAL(5,2)
  );

  -- Insert Data	
  INSERT INTO employee (eid, dept, scores) VALUES
  (1, 'D1', 1),
  (2, 'D1', 5.28),
  (3, 'D1', 4),
  (4, 'D2', 8),
  (5, 'D1', 2.5),
  (6, 'D2', 7),
  (7, 'D3', 9),
  (8, 'D4', 10.2);

  SELECT 
    transaction_date,
    SUM(daily_net_revenue) AS daily_net_revenue
FROM (
    -- Purchases: positive revenue
    SELECT 
        transaction_date,
        amount AS daily_net_revenue
    FROM product_sales
    WHERE product_id = 'PROD-2891'
        AND country = 'US'
        AND type = 'purchase'
        AND status = 'completed'
        AND transaction_date BETWEEN '2025-04-15' AND '2025-04-28'
    
    UNION ALL
    
    -- Refunds: negative revenue
    SELECT 
        ps.transaction_date,
        -ps.amount AS daily_net_revenue
    FROM product_sales ps
    INNER JOIN product_sales refunds ON refunds.original_transaction_id = ps.transaction_id
    WHERE ps.product_id = 'PROD-2891'
        AND ps.country = 'US'
        AND ps.type = 'purchase'
        AND ps.status = 'completed'
        AND ps.transaction_date BETWEEN '2025-04-15' AND '2025-04-28'
        AND refunds.type = 'refund'
        AND refunds.status = 'completed'
) combined
GROUP BY transaction_date
ORDER BY transaction_date;