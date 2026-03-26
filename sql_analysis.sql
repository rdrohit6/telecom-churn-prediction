-- Create Customers Table with Primary Key
CREATE TABLE customers (
customer_id INT PRIMARY KEY,
name VARCHAR(100),
city VARCHAR(50),
age INT,
customer_type VARCHAR(20),
signup_date DATE
);

-- Create Usage Table with Foreign Key
CREATE TABLE network_usage (
usage_id INT PRIMARY KEY,
customer_id INT,
data_used_gb FLOAT,
call_minutes FLOAT,
usage_date DATE,
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Create Issues Table with Foreign Key
CREATE TABLE network_issues (
issue_id INT PRIMARY KEY,
customer_id INT,
issue_type VARCHAR(50),
resolution_time INT,
issue_date DATE,
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Joining all 4 datasets to create a comprehensive customer profile
CREATE VIEW master_dataset AS
SELECT 
c.customer_id, c.city, c.age, c.customer_type,
u.data_used_gb, u.call_minutes,
i.issue_type, i.resolution,
b.bill_amount, b.payment_status
FROM customers c
LEFT JOIN network_usage u ON c.customer_id = u.customer_id
LEFT JOIN network_issues i ON c.customer_id = i.customer_id
LEFT JOIN billing b ON c.customer_id = b.customer_id;

-- Create Billing Table with Foreign Key
CREATE TABLE billing (
bill_id INT PRIMARY KEY,
customer_id INT,
bill_amount FLOAT,
payment_status VARCHAR(20),
bill_month INT,
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- City-wise Network Issues
SELECT c.city, COUNT(n.issue_id) AS total_issues
FROM customers c
JOIN network_issues n
ON c.customer_id = n.customer_id
GROUP BY c.city;

-- Complaint Rate per Customer
SELECT customer_id, COUNT(*) AS total_complaints
FROM network_issues
GROUP BY customer_id;

-- Avg Data Usage by Network Type
SELECT network_type, AVG(data_used_gb) AS avg_usage
FROM network_usage
GROUP BY network_type;

-- Payment Behavior
SELECT payment_status, COUNT(*) AS total
FROM billing
GROUP BY payment_status;

--Network Issues vs Payment
SELECT b.payment_status, COUNT(n.issue_id) AS total_issues
FROM billing b
JOIN network_issues n
ON b.customer_id = n.customer_id
GROUP BY b.payment_status;

-- Monthly Trend Analysis (Window Function)
SELECT  MONTH(issue_date) AS month, 
COUNT(*) AS monthly_issues,SUM(COUNT(*)) OVER (ORDER BY MONTH(issue_date)) AS running_total_issues
FROM network_issues
GROUP BY MONTH(issue_date)
ORDER BY month;
