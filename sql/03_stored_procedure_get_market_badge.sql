DELIMITER $$

CREATE PROCEDURE get_market_badge(
    IN in_market VARCHAR(45),
    IN in_fiscal_year YEAR,
    OUT out_level VARCHAR(45)
)
BEGIN
    DECLARE qty INT DEFAULT 0;

    IF in_market = '' THEN
        SET in_market = 'India';
    END IF;

    SELECT SUM(s.sold_quantity)
    INTO qty
    FROM fact_sales_monthly s
    JOIN dim_customer c
        ON s.customer_code = c.customer_code
    WHERE get_fiscal_year(s.date) = in_fiscal_year
      AND c.market = in_market;

    IF qty > 5000000 THEN
        SET out_level = 'Gold';
    ELSE
        SET out_level = 'Silver';
    END IF;
END $$

DELIMITER ;

CALL get_market_badge('India', 2021, @badge);
SELECT @badge;