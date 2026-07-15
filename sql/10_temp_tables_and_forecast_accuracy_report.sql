-- Temporary Tables & Forecast Accuracy Report

-- Forecast accuracy report using cte (It exists at the scope of statements)

	WITH forecast_err_table AS (
    SELECT
        s.customer_code,
        c.customer AS customer_name,
        c.market,
        SUM(s.sold_quantity) AS total_sold_qty,
        SUM(s.forecast_quantity) AS total_forecast_qty,
        SUM(s.forecast_quantity - s.sold_quantity) AS net_error,
        ROUND(
            SUM(s.forecast_quantity - s.sold_quantity) * 100
            / SUM(s.forecast_quantity), 1
        ) AS net_error_pct,
        SUM(ABS(s.forecast_quantity - s.sold_quantity)) AS abs_error,
        ROUND(
            SUM(ABS(s.forecast_quantity - s.sold_quantity)) * 100
            / SUM(s.forecast_quantity), 2
        ) AS abs_error_pct
    FROM fact_act_est s
    JOIN dim_customer c
        ON s.customer_code = c.customer_code
    WHERE s.fiscal_year = 2021
    GROUP BY s.customer_code, c.customer, c.market
)

SELECT *
FROM forecast_err_table;



-- Write a stored proc for the same
	CREATE PROCEDURE `get_forecast_accuracy`(
        	in_fiscal_year INT
	)
	BEGIN
		with forecast_err_table as (
             	       select
                           s.customer_code as customer_code,
                           c.customer as customer_name,
                           c.market as market,
                           sum(s.sold_quantity) as total_sold_qty,
                           sum(s.forecast_quantity) as total_forecast_qty,
                           sum(s.forecast_quantity-s.sold_quantity) as net_error,
                           round(sum(s.forecast_quantity-s.sold_quantity)*100/sum(s.forecast_quantity),1) as net_error_pct,
                           sum(abs(s.forecast_quantity-s.sold_quantity)) as abs_error,
                           round(sum(abs(s.forecast_quantity-sold_quantity))*100/sum(s.forecast_quantity),2) as abs_error_pct
             	       from fact_act_est s
             	       join dim_customer c
                       on s.customer_code = c.customer_code
                       where s.fiscal_year=in_fiscal_year
                       group by customer_code
	        )
	        select 
                    *,
                    if (abs_error_pct > 100, 0, 100.0 - abs_error_pct) as forecast_accuracy
	        from forecast_err_table
                order by forecast_accuracy desc;
	END

-- Forecast accuracy report using temporary table (It exists for the entire session)
	drop table if exists forecast_err_table;
	create temporary table forecast_err_table
             select
                  s.customer_code as customer_code,
                  c.customer as customer_name,
                  c.market as market,
                  sum(s.sold_quantity) as total_sold_qty,
                  sum(s.forecast_quantity) as total_forecast_qty,
                  sum(s.forecast_quantity-s.sold_quantity) as net_error,
                  round(sum(s.forecast_quantity-s.sold_quantity)*100/sum(s.forecast_quantity),1) as net_error_pct,
                  sum(abs(s.forecast_quantity-s.sold_quantity)) as abs_error,
                  round(sum(abs(s.forecast_quantity-sold_quantity))*100/sum(s.forecast_quantity),2) as abs_error_pct
             from fact_act_est s
             join dim_customer c
             on s.customer_code = c.customer_code
             where s.fiscal_year=2021
             group by customer_code;

	select 
            *,
            if (abs_error_pct > 100, 0, 100.0 - abs_error_pct) as forecast_accuracy
	from forecast_err_table
        order by forecast_accuracy desc;
	
	
	

