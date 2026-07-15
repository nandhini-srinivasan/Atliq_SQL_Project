#atored procedures : monthly gross sales.
#monthly gross sales report for any customer using stored procedure

USE gdb0041;

DELIMITER $$

CREATE PROCEDURE get_monthly_gross_sales_for_customer(
    IN in_customer_codes TEXT
)
BEGIN
    SELECT
        s.date,
        SUM(ROUND(s.sold_quantity * g.gross_price, 2)) AS monthly_sales
    FROM fact_sales_monthly s
    JOIN fact_gross_price g
        ON g.fiscal_year = get_fiscal_year(s.date)
       AND g.product_code = s.product_code
    WHERE FIND_IN_SET(s.customer_code, in_customer_codes) > 0
    GROUP BY s.date
    ORDER BY s.date DESC;
END $$

DELIMITER ;

SHOW PROCEDURE STATUS
WHERE Db = 'gdb0041';



    
