	#join to pull product information
    
    SELECT s.date, s.product_code, p.product, p.variant, s.sold_quantity 
	FROM fact_sales_monthly s
	JOIN dim_product p
        ON s.product_code=p.product_code
	WHERE 
            customer_code=90002002 AND 
    	    get_fiscal_year(date)=2021     
	LIMIT 1000000;





#Performing join with 'fact_gross_price' table with the above query and generating required fields
	SELECT 
    	    s.date, 
            s.product_code, 
            p.product, 
            p.variant, 
            s.sold_quantity, 
            g.gross_price,
            ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total
	FROM fact_sales_monthly s
	JOIN dim_product p
            ON s.product_code=p.product_code
	JOIN fact_gross_price g
            ON g.fiscal_year=get_fiscal_year(s.date)
    	AND g.product_code=s.product_code
	WHERE 
    	    customer_code=90002002 AND 
            get_fiscal_year(s.date)=2021     
	LIMIT 1000000;




#gross sales report - total sales amount
#monthly gross sales report for croma india for all the years
	SELECT 
            s.date, 
    	    SUM(ROUND(s.sold_quantity*g.gross_price,2)) as monthly_sales
	FROM fact_sales_monthly s
	JOIN fact_gross_price g
        ON g.fiscal_year=get_fiscal_year(s.date) AND g.product_code=s.product_code
	WHERE 
             customer_code=90002002
	GROUP BY date;



