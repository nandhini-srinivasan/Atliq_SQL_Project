### Module: Window Functions


-- find out customer wise net sales percentage contribution 
	with cte1 as (
		select 
                    customer, 
                    round(sum(net_sales)/1000000,2) as net_sales_mln
        	from net_sales s
        	join dim_customer c
                    on s.customer_code=c.customer_code
        	where s.fiscal_year=2021
        	group by customer)
	select 
            *,
            net_sales_mln*100/sum(net_sales_mln) over() as pct_net_sales
	from cte1
	order by net_sales_mln desc






# Module: Exercise: Window Functions: OVER Clause

-- Find customer wise net sales distibution per region for FY 2021
	with cte1 as (
		select 
        	    c.customer,
                    c.region,
                    round(sum(net_sales)/1000000,2) as net_sales_mln
                from gdb0041.net_sales n
                join dim_customer c
                    on n.customer_code=c.customer_code
		where fiscal_year=2021
		group by c.customer, c.region
        )
	select
             *,
             net_sales_mln*100/sum(net_sales_mln) over (partition by region) as pct_share_region
	from cte1
	order by region, pct_share_region desc;






-- Find out top 3 products from each division by total quantity sold in a given year
	with cte1 as 
		(select
                     p.division,
                     p.product,
                     sum(sold_quantity) as total_qty
                from fact_sales_monthly s
                join dim_product p
                      on p.product_code=s.product_code
                where fiscal_year=2021
                group by p.product, p.division),
           cte2 as 
	        (select 
                     *,
                     dense_rank() over (partition by division order by total_qty desc) as drnk
                from cte1)
	select * from cte2 where drnk<=3



-- Creating stored procedure for the above query
DELIMITER $$
	CREATE PROCEDURE `get_top_n_products_per_division_by_qty_sold`(
        	in_fiscal_year INT,
    		in_top_n INT
	)
	BEGIN
	     with cte1 as (
		   select
                       p.division,
                       p.product,
                       sum(sold_quantity) as total_qty
                   from fact_sales_monthly s
                   join dim_product p
                       on p.product_code=s.product_code
                   where fiscal_year=in_fiscal_year
                   group by p.product),            
             cte2 as (
		   select 
                        *,
                        dense_rank() over (partition by division order by total_qty desc) as drnk
                   from cte1)
	     select * from cte2 where drnk <= in_top_n;
	END $$
DELIMITER &&


SHOW CREATE PROCEDURE get_top_n_products_per_division_by_qty_sold;
USE gdb0041;
CALL get_top_n_products_per_division_by_qty_sold(2021, 3);