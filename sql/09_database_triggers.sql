
### Module: Database Triggers

-- create the trigger to automatically insert record in fact_act_est table whenever insertion happens in fact_sales_monthly 
DELIMITER $$
	CREATE DEFINER=CURRENT_USER TRIGGER `fact_sales_monthly_AFTER_INSERT` AFTER INSERT ON `fact_sales_monthly` FOR EACH ROW 
	BEGIN
        	insert into fact_act_est 
                        (date, product_code, customer_code, sold_quantity)
    		values (
                	NEW.date, 
        		NEW.product_code, 
        		NEW.customer_code, 
        		NEW.sold_quantity
    		 )
    		on duplicate key update
                         sold_quantity = values(sold_quantity);
	END$$
    

-- create the trigger to automatically insert record in fact_act_est table whenever insertion happens in fact_forecast_monthly 
DELIMITER $$
	CREATE DEFINER=CURRENT_USER TRIGGER `fact_forecast_monthly_AFTER_INSERT` AFTER INSERT ON `fact_forecast_monthly` FOR EACH ROW 
	BEGIN
        	insert into fact_act_est 
                        (date, product_code, customer_code, forecast_quantity)
    		values (
                	NEW.date, 
        		NEW.product_code, 
        		NEW.customer_code, 
        		NEW.forecast_quantity
    		 )
    		on duplicate key update
                         forecast_quantity = values(forecast_quantity);
	END$$


-- To see all the Triggers
        show triggers;



-- Insert the records in the fact_sales_monthly and fact_forecast_monthly tables and check whether records inserted in fact_act_est table
	insert into fact_sales_monthly
              (date, product_code, customer_code, sold_quantity)
	values 
	      ("2030-09-01", "HAHA", 99, 89);

	insert into fact_forecast_monthly
             (date, product_code, customer_code, forecast_quantity)
	values 
	      ("2030-09-01", "HAHA", 99, 43);

	select * from fact_act_est where customer_code = 99;
