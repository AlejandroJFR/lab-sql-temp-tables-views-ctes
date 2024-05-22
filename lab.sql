-- Setting the working database
USE sakila;

-- Creating a Customer Summary Report

-- In this exercise, you will create a customer summary report that summarizes key information about customers in the 
-- 	Sakila database, including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, 
-- 	name, email address, and total number of rentals (rental_count).
	CREATE VIEW rental_count AS 
    WITH cte_rental_count AS (
		SELECT c.customer_id AS customer_id, 
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
        c.email AS email, COUNT(r.rental_id) AS number_of_rentals 
		FROM sakila.customer AS c
		JOIN sakila.rental AS r
        ON c.customer_id = r.customer_id
        GROUP BY c.customer_id, c.first_name, c.last_name, c.email
	)
    SELECT *
    FROM cte_rental_count;
    
    SELECT * 
    FROM sakila.rental_count;
    
-- Step 2: Create a Temporary Table

-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table 
-- 	should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

	CREATE TEMPORARY TABLE total_payments_by_customer
    SELECT rc.customer_id, 
       rc.customer_name, 
       rc.email, 
       rc.number_of_rentals, 
       SUM(p.amount) AS total_paid
    FROM sakila.rental_count AS rc
    LEFT JOIN sakila.payment AS p
    ON rc.customer_id = p.customer_id
    GROUP BY rc.customer_id, rc.customer_name, rc.email, rc.number_of_rentals;

-- Step 3: Create a CTE and the Customer Summary Report

-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- 	The CTE should include the customer's name, email address, rental count, and total amount paid.
	WITH cte_customer_summary AS (
    SELECT rc.customer_name,
           rc.email,
           rc.number_of_rentals,
           tpc.total_paid
    FROM rental_count AS rc
    JOIN total_payments_by_customer AS tpc
    ON rc.customer_id = tpc.customer_id
	)
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, 
-- 	email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
	SELECT cte.customer_name,
       cte.email,
       cte.number_of_rentals AS rental_count,
       cte.total_paid,
       cte.total_paid / cte.number_of_rentals AS average_payment_per_rental
	FROM cte_customer_summary AS cte;

-- Assuming the rental_count view and total_payments_by_customer temporary table have been created as previously described



