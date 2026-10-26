-- Run after Master.dtsx to verify the load (screenshots for the report)

-- Staging (SQLEXPRESS01)
SELECT Source_Dataset, COUNT(*) AS Rows
FROM Churn_Staging.dbo.stg_Customer_All
GROUP BY Source_Dataset;                 -- Master 505,207 | Telco 7,043

-- Warehouse (CHUM)
USE Churn_DWH;
SELECT 'Dim_Customer' AS TableName, COUNT(*) AS Rows FROM Dim_Customer UNION ALL
SELECT 'Dim_Contract',     COUNT(*) FROM Dim_Contract     UNION ALL
SELECT 'Dim_Payment',      COUNT(*) FROM Dim_Payment      UNION ALL
SELECT 'Dim_Subscription', COUNT(*) FROM Dim_Subscription UNION ALL
SELECT 'Fact_Churn',       COUNT(*) FROM Fact_Churn;
-- Expected: 512,249 | 10 | 5 | 28 | 512,249

-- Sample of each dimension (one screenshot per member)
SELECT TOP 10 * FROM Dim_Customer;
SELECT * FROM Dim_Contract;
SELECT * FROM Dim_Payment;
SELECT * FROM Dim_Subscription;

-- Star schema working end to end: churn rate per plan
SELECT s.Plan_Name, COUNT(*) AS Customers,
       AVG(CAST(f.Churn AS FLOAT)) AS Churn_Rate
FROM Fact_Churn f
JOIN Dim_Subscription s ON f.Subscription_Key = s.Subscription_Key
GROUP BY s.Plan_Name
ORDER BY Churn_Rate DESC;

-- Churn rate per contract length
SELECT c.Contract_Name, c.Contract_Months, COUNT(*) AS Customers,
       AVG(CAST(f.Churn AS FLOAT)) AS Churn_Rate
FROM Fact_Churn f
JOIN Dim_Contract c ON f.Contract_Key = c.Contract_Key
GROUP BY c.Contract_Name, c.Contract_Months
ORDER BY c.Contract_Months;
