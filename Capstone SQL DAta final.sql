create database	Capstone;
Use Capstone;
select * from  customerdata;
select * from bank_churn;

Alter table customerdata
alter column Bank DOJ date;

#Q1	What is the distribution of account balances across different regions?
SELECT cd.GeographyID, ROUND(SUM(bc.Balance), 2) AS Balance
FROM customerdata cd
JOIN bank_churn bc ON cd.CustomerId = bc.CustomerId
GROUP BY cd.GeographyID;


Create Table customer_info 
( 
CustomerID int primary key,
Surname varchar(255),
Age int8,
GenderID varchar(155),
EstimatedSalary decimal(12,2),
GeographyID varchar(255),
Bank_DOJ date
);
select * from  customerdata;

Alter Table customer_data
modify Bank_DOJ varchar(255);


#Q2 Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)
SELECT CustomerId,Surname, EstimatedSalary
FROM customerdata
WHERE YEAR(Bank_DOJ) = 2019
  AND MONTH(Bank_DOJ) IN (10, 11, 12) 
ORDER BY EstimatedSalary Desc
LIMIT 5;

ALTER TABLE customer_data
ADD Quarter VARCHAR(2);

ALTER TABLE customerdata
ADD Quarter VARCHAR(2);

-- Update the Quarter column based on the month from the Bank_DOJ column
UPDATE customerdata
SET Quarter =
    CASE
        WHEN MONTH(Bank_DOJ) IN (1, 2, 3) THEN 'Q1'
        WHEN MONTH(Bank_DOJ) IN (4, 5, 6) THEN 'Q2'
        WHEN MONTH(Bank_DOJ) IN (7, 8, 9) THEN 'Q3'
        WHEN MONTH(Bank_DOJ) IN (10, 11, 12) THEN 'Q4'
        ELSE NULL  -- handle unexpected cases
    END;

#Q3 Calculate the average number of products used by customers who have a credit card. 
Select * from  bank_churn; 
Select Avg(NumOfProducts) as avg_products_cc
from bank_churn where HasCrCard = "credit card holder";


#Q5Compare the average credit score of customers who have exited and those who remain. (SQL)
SELECT
    CASE WHEN Exited = 'Exit' THEN 'Exited'
         WHEN Exited = 'Retain' THEN 'Retained'
    END AS Customer_Status,
    AVG(CreditScore) AS Avg_CreditScore
FROM
    bank_churn
WHERE
    Exited IN ('Exit', 'Retain')
GROUP BY
    Customer_Status;


    

#Q6Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
SELECT
    GenderID,
    AVG(EstimatedSalary) AS avg_salary,
    COUNT(*) AS active_accounts
FROM
    customerdata
GROUP BY
    GenderID;
# Q7 Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)
select CreditScore, count(CustomerId) customer_count from bank_churn
		where exited= 'Exit'
		group by CreditScore
		order by customer_count desc limit 1;

    
    #Q8Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)
SELECT cd.GeographyID, COUNT(*) AS Num_Active_Customers
FROM customerdata AS cd
INNER JOIN bank_churn AS bc ON cd.CustomerId = bc.CustomerId
WHERE bc.Tenure > 5 AND bc.IsActiveMember = 'Active Member'
GROUP BY cd.GeographyID
ORDER BY Num_Active_Customers DESC;

#9 For customers who have exited, what is the most common number of products they have used?
SELECT NumOfProducts, COUNT(*) AS Num_Customers
FROM bank_churn
WHERE Exited = 'Exit'
GROUP BY NumOfProducts
ORDER BY Num_Customers DESC
LIMIT 1;

#11 Examine the trend of customer joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.
select year(Bank_DOJ) as year, count(c.CustomerId) as count_customer_churn
       	 from bank_churn b 
		inner join customerdata c ON b.CustomerId= c.CustomerId
		where Exited= 'Exit'
		group by year(Bank_DOJ);
#Q15 Using SQL, write a query to find out the gender wise average income of male and female in each geography id. Also rank the gender according to the average value. (SQL)
	SELECT 
		GeographyID,
		GenderID,
		AVG(EstimatedSalary) AS average_income,
		RANK() OVER ( ORDER BY AVG(EstimatedSalary) DESC) AS gender_rank
	FROM 
		customerdata
	GROUP BY 
		GeographyID, GenderID;   
  # 16Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+). 
		SELECT
		CASE
			WHEN Age BETWEEN 18 AND 30 THEN '18-30'
			WHEN Age BETWEEN 31 AND 50 THEN '31-50'
			ELSE '50+'
		END AS AgeBracket,
		Round(AVG(Tenure),2) AS AvgTenure
	FROM
		bank_churn bc
	JOIN
		customerdata cd ON bc.CustomerId = cd.CustomerId
	WHERE
		bc.Exited = 'Exit'
	GROUP BY
		CASE
			WHEN Age BETWEEN 18 AND 30 THEN '18-30'
			WHEN Age BETWEEN 31 AND 50 THEN '31-50'
			ELSE '50+'
		END;
#19. Rank each bucket of credit score as per the number of customers who have churned the bank.
with creditbucket as
		  (
		  select *,
		  case when creditscore between 0 and 579 then 'Poor'
			   when creditscore between 580 and 669 then 'Fair'
			   when creditscore between 670 and 739 then 'Good'
			   when creditscore between 740 and 800 then 'Very Good'
			   else 'Excellent'
			   end as creditBucket
		  from bank_churn
		  where exited = 'Exit')
		  select creditbucket, count(CustomerID) as total_count,
		  dense_rank() over(order by count(CustomerID) desc) as 'Rank' 
		  from creditbucket
		  group by creditbucket;
          
         # According to the age buckets find the number of customers who have a credit card. Also retrieve those buckets who have lesser than average number of credit cards per bucket.
WITH AgeBuckets AS (
    SELECT
        CASE
            WHEN c.Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN c.Age BETWEEN 31 AND 50 THEN '31-50'
            ELSE '50+'
        END AS age_bucket,
        CASE
            WHEN b.HasCrCard = 'Credit card holder' THEN 1
            ELSE 0
        END AS has_credit_card
    FROM
        bank_churn AS b
    INNER JOIN
        customerdata AS c ON b.CustomerId = c.CustomerId
),
AgeBucketSummary AS (
    SELECT
        age_bucket,
        COUNT(*) AS total_customers,
        SUM(has_credit_card) AS credit_card_customers,
        AVG(has_credit_card) AS avg_customers_with_credit
    FROM
        AgeBuckets
    GROUP BY
        age_bucket
)

SELECT
    age_bucket,
    total_customers,
    credit_card_customers,
    avg_customers_with_credit
FROM
    AgeBucketSummary;


#19 Rank the Locations as per the number of people who have churned the bank and average balance of the learners.	
WITH ChurnStats AS (
    SELECT
        c.GeographyID,
        COUNT(DISTINCT c.CustomerId) AS count_churn
    FROM
        customerdata c
    JOIN
        bank_churn b ON c.CustomerId = b.CustomerId
    WHERE
        b.Exited = 'Exit'
    GROUP BY
        c.GeographyID
)
SELECT
    GeographyID,
    count_churn,
    RANK() OVER (ORDER BY count_churn DESC) AS churn_rank
FROM
    ChurnStats;
select avg(balance) from bank_churn;

 #As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.
SELECT CONCAT(CustomerId, '_', Surname) AS CustomerID_Surname
FROM Customerdata;
    
#23 Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.
    SELECT *, 'Exit' AS ExitCategory
FROM bank_churn
WHERE Exited = 'Exit';

#Write the query to get the customer ids, their last name and whether they are active or not for the customers whose surname  ends with “on”. 
select * from bank_churn;
  SELECT *
FROM bank_churn AS b
INNER JOIN customerdata AS c ON b.CustomerId = c.CustomerId;
SELECT c.CustomerId, c.Surname, b.IsActiveMember
FROM customerdata AS c
INNER JOIN bank_churn AS b ON c.CustomerId = b.CustomerId
WHERE c.Surname LIKE '%on';
  
    #6.	Utilize SQL queries to segment customers based on demographics, account details, and transaction behaviors.
 -- Segment customers based on demographics (e.g., age and gender)



-- Segment customers based on account details (e.g., number of products and credit card status)


-- Segment customers based on transaction behaviors (e.g., balance and tenure)
SELECT
    CASE
        WHEN Balance > 100000 THEN 'High Balance'
        WHEN Balance > 50000 THEN 'Medium Balance'
        ELSE 'Low Balance'
    END AS Balance_Level,
    CASE
        WHEN Tenure > 5 THEN 'Long Tenure'
        WHEN Tenure > 2 THEN 'Medium Tenure'
        ELSE 'Short Tenure'
    END AS Tenure_Group,
    COUNT(*) AS Customer_Count
FROM
    Transactions
GROUP BY
    Balance_Level,
    Tenure_Group
ORDER BY
    Balance_Level,
    Tenure_Group;   
ALTER TABLE customerdata
Drop column CustomerID_Surname;   

