/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
SELECT 
	   state, 
       COUNT(DISTINCT customer_id) AS customer_distribution
FROM
     customer_t
GROUP BY state
ORDER BY customer_distribution DESC;

# Observations: 
               -- California and Texas have highest of customer distribution as 97 followed by Florida and so on.
               -- Top 5 states are California, Texas, Florida, New york and District of Columbia.
               -- Mississipi, Maine, Vermont and Wyoming have lowest number of customer distribution.
               
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 
*/

WITH Rating as            # Creating CTE Result set named as Rating
( 
    SELECT  
            quarter_number, customer_feedback,
            case
                when customer_feedback = 'Very Bad' then '1'
			    when customer_feedback = 'Bad' then '2'
			    when customer_feedback = 'Okay' then '3'
			    when customer_feedback = 'Good' then '4'
			    when customer_feedback = 'Very Good' then '5'
                end as Rating_count
	 from 
          order_t
)
SELECT 
       quarter_number,
       round(avg(Rating_count),2) as Average_Rating
from Rating 
group by 1
order by 1;

# Observations:
               -- Average Rating in Quarter 1 and 2 are 3.55
               -- Average Rating in Quarter 3 is 2.96
               -- Average Rating in Quarter 4 is 2.4
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
*/

WITH cust_satisfaction as             # creating CTE Table named cust_satisfaction
(  
     SELECT 
            quarter_number, 
            count(customer_feedback) as cust_feedback_count,
	        round((sum(customer_feedback='Very Bad')/count(customer_feedback))*100,2) as perc_VeryBad,
	        round((sum(customer_feedback='Bad')/count(customer_feedback))*100,2) as perc_Bad,
	        round((sum(customer_feedback='Okay')/count(customer_feedback))*100,2) as perc_Okay,
	        round((sum(customer_feedback='Good')/count(customer_feedback))*100,2) as perc_Good,
	        round((sum(customer_feedback='Very Good')/count(customer_feedback))*100,2) as perc_VeryGood
	 from 
          order_t
     group by 1
     order by 1
)
SELECT * from cust_satisfaction;

# Observations: 
               -- As we can see '% of Very_Bad' customer feedback is increasing with quarters and '% of Very_Good' feedback is decreasing with Quarters
               -- This shows that customer is getting dissatisfied over time.
               
-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/
SELECT 
    p.vehicle_maker, COUNT(c.customer_id) AS customer_count
FROM
    customer_t c
        JOIN
    order_t o ON c.customer_id = o.customer_id
        JOIN
    product_t p ON p.product_id = o.product_id
GROUP BY p.vehicle_maker
ORDER BY customer_count DESC
LIMIT 5;

# Observations:
               -- Top 5 Vehicle Makers preferred by the customers are Chervolet, Ford, Toyota, Pontiac and Dodge.
               
               -- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

with vehicle_maker_by_state as
(
    SELECT 
           p.vehicle_maker, c.state ,count(c.customer_id) as customer_count,
           RANK() OVER(PARTITION BY state ORDER BY count(vehicle_maker) desc) as rnk
    FROM customer_t c
          join 
               order_t o on c.customer_id = o.customer_id
          join
               product_t p on o.product_id = p.product_id
	GROUP BY c.state, p.vehicle_maker
    ORDER BY 3 desc
    )
SELECT * FROM vehicle_maker_by_state
WHERE rnk =1;

# Observations: 
               -- Texas is the most preferred state for vehicle Chervolet
               -- Florida is the most preferred state for vehicle Toyota
               -- Callifornia is the most preferred state for vehicles Ford,Dodge,Audi,Nissan,Chervolet
               -- And so on..
                   
-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

SELECT 
     quarter_number, COUNT(*) as Number_of_orders
FROM
    order_t
GROUP BY 1
ORDER BY 2 desc;

# Observations: 
               -- Number of orders are decreasing with increasing quarters.
               -- Trends of Number_of_orders is decling by quarters.
               

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
      
WITH quarter_change_in_Revenue as
(
    SELECT 
           quarter_number,
           SUM(vehicle_price*quantity) as Revenue
    FROM order_t
    GROUP BY 1
)
SELECT 
        quarter_number, Revenue,
		LAG(Revenue) OVER(ORDER BY quarter_number) as previous_quarter_revenue,
        round(((Revenue - LAG(Revenue) over(order by quarter_number))/LAG(Revenue) OVER(ORDER BY quarter_number)*100),2) as quarter_perc_changeIn_Revenue
from quarter_change_in_Revenue;

# Observations: 
				-- quarter change in revenue is declining by (-16.96),(-10.57) and (-20.18) with quarters.
                
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

SELECT 
    quarter_number,
    SUM(vehicle_price * quantity) AS Revenue,
    COUNT(order_id) AS Number_of_orders
FROM
    order_t
GROUP BY 1
ORDER BY 2 DESC;

# Observations: 
			-- We observed a decreasing Trend in both Revenue and Number_of_orders quarter by quarter.
            -- orders in quarter 4 is not generating much revenue.
            
-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

SELECT DISTINCT
    c.credit_card_type, AVG(o.discount) as Average_discount
FROM
    customer_t c
        JOIN
    order_t o USING (customer_id)
GROUP BY 1
ORDER BY 2 DESC;

# Observations: 
               -- Average discount for different Credit cards Ranges from 0.58 to 0.64
               -- Laser credit card offer higher discount of 0.64
               
-- ----------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

SELECT 
    quarter_number,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 2) AS Avg_Days_To_Ship    # calculating avg time taken to ship using Datediff function and avg function
FROM
    order_t
GROUP BY 1
ORDER BY 1;

# Observations: 
               -- Average Time taken to ship the order is increasing from quarter to quarter.
               -- We can say shipping is getting Delayed with time.
               

-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------