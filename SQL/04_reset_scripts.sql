-- Used by the Execute SQL Tasks at the start of Master.dtsx

-- Reset DWH  (connection DWH_DB -> CHUM / Churn_DWH)
DELETE FROM dbo.Fact_Churn;
DELETE FROM dbo.Dim_Customer;
DELETE FROM dbo.Dim_Contract;
DELETE FROM dbo.Dim_Payment;
DELETE FROM dbo.Dim_Subscription;
DBCC CHECKIDENT ('dbo.Fact_Churn',       RESEED, 0);
DBCC CHECKIDENT ('dbo.Dim_Customer',     RESEED, 0);
DBCC CHECKIDENT ('dbo.Dim_Contract',     RESEED, 0);
DBCC CHECKIDENT ('dbo.Dim_Payment',      RESEED, 0);
DBCC CHECKIDENT ('dbo.Dim_Subscription', RESEED, 0);

-- Reset Staging  (connection SQLEXPRESS01 / Churn_Staging)
TRUNCATE TABLE dbo.stg_Churn_Master;
TRUNCATE TABLE dbo.stg_Churn_Telco;
TRUNCATE TABLE dbo.stg_Customer_All;
