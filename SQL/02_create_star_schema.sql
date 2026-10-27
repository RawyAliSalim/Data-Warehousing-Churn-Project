-- Run on the SQL Server instance that will host Churn_DWH.
/* =====================================================================
   PART B - DATA WAREHOUSE / STAR SCHEMA  (connect SSMS to your Churn_DWH instance)
   Key columns copied from staging stay VARCHAR (used by the Lookups).
   Columns created by Derived Column transformations are NVARCHAR,
   because SSIS string functions output Unicode (DT_WSTR).
   ===================================================================== */
USE Churn_DWH;
GO

DROP TABLE IF EXISTS dbo.Fact_Churn;
DROP TABLE IF EXISTS dbo.Dim_Customer;
DROP TABLE IF EXISTS dbo.Dim_Contract;
DROP TABLE IF EXISTS dbo.Dim_Payment;
DROP TABLE IF EXISTS dbo.Dim_Subscription;
DROP TABLE IF EXISTS dbo.Dim_Source;          -- old design, no longer used
GO

-- Member 1
CREATE TABLE dbo.Dim_Customer (
    Customer_Key       INT IDENTITY(1,1) PRIMARY KEY,
    Customer_BK        INT NOT NULL,          -- = StagingID (lookup key)
    Customer_ID        VARCHAR(20),
    Customer_Number    NVARCHAR(20),          -- split from Customer_ID
    Customer_Suffix    NVARCHAR(20),          -- split from Customer_ID
    Gender             VARCHAR(20),
    Age                INT NULL,
    Age_Group          NVARCHAR(20),
    Senior_Citizen     VARCHAR(10),
    Partner            VARCHAR(10),
    Dependents         VARCHAR(10),
    Source_Dataset     VARCHAR(50),
    Source_File        VARCHAR(100)
);

-- Member 2
CREATE TABLE dbo.Dim_Contract (
    Contract_Key       INT IDENTITY(1,1) PRIMARY KEY,
    Contract_Type      VARCHAR(30),           -- lookup key
    Paperless_Billing  VARCHAR(10),           -- lookup key
    Contract_Name      NVARCHAR(30),          -- first letter upper-cased
    Contract_Code      NVARCHAR(30),          -- spaces -> underscores
    Contract_Months    INT                    -- harmonises both datasets
);

-- Member 3
CREATE TABLE dbo.Dim_Payment (
    Payment_Key        INT IDENTITY(1,1) PRIMARY KEY,
    Payment_Method     VARCHAR(50),           -- lookup key
    Payment_Name       NVARCHAR(50),          -- split: 'Bank transfer'
    Payment_Mode       NVARCHAR(20),          -- split: 'Automatic' / 'Manual'
    Payment_Code       NVARCHAR(50)           -- spaces -> underscores
);

-- Member 4
CREATE TABLE dbo.Dim_Subscription (
    Subscription_Key       INT IDENTITY(1,1) PRIMARY KEY,
    Subscription_Type      VARCHAR(30),       -- lookup keys (6 columns)
    Internet_Service       VARCHAR(30),
    Phone_Service          VARCHAR(30),
    Online_Security        VARCHAR(30),
    Tech_Support           VARCHAR(30),
    Streaming_TV           VARCHAR(30),
    Plan_Name              NVARCHAR(30),      -- one plan column for both datasets
    Plan_Code              NVARCHAR(30),      -- spaces -> underscores
    Online_Security_Code   NVARCHAR(30),      -- spaces -> underscores
    Tech_Support_Code      NVARCHAR(30)       -- spaces -> underscores
);

-- Group
CREATE TABLE dbo.Fact_Churn (
    Churn_Fact_Key     INT IDENTITY(1,1) PRIMARY KEY,
    Customer_Key       INT NOT NULL REFERENCES dbo.Dim_Customer(Customer_Key),
    Contract_Key       INT NOT NULL REFERENCES dbo.Dim_Contract(Contract_Key),
    Payment_Key        INT NOT NULL REFERENCES dbo.Dim_Payment(Payment_Key),
    Subscription_Key   INT NOT NULL REFERENCES dbo.Dim_Subscription(Subscription_Key),
    Tenure_Months      INT NULL,
    Usage_Frequency    INT NULL,
    Support_Calls      INT NULL,
    Payment_Delay      INT NULL,
    Last_Interaction   INT NULL,
    Monthly_Charges    DECIMAL(10,2) NULL,
    Total_Spend        DECIMAL(12,2) NULL,
    Churn              INT NULL
);
GO
