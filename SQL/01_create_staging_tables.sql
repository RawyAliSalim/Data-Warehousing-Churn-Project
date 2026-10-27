-- Run on the SQL Server instance that will host Churn_Staging.
/* =====================================================================
   PART A - STAGING  (connect SSMS to your Churn_Staging instance)
   Raw tables: every column VARCHAR(50), names = CSV headers, so the
   Flat File sources map 1:1 with no conversion errors.
   ===================================================================== */
USE Churn_Staging;
GO

DROP TABLE IF EXISTS dbo.stg_Churn_Master;
DROP TABLE IF EXISTS dbo.stg_Churn_Complex;   -- old dataset, no longer used
DROP TABLE IF EXISTS dbo.stg_Churn_Telco;
DROP TABLE IF EXISTS dbo.stg_Customer_All;
GO

-- Dataset 1 (training + testing master)
CREATE TABLE dbo.stg_Churn_Master (
    [CustomerID]        VARCHAR(50),
    [Age]               VARCHAR(50),
    [Gender]            VARCHAR(50),
    [Tenure]            VARCHAR(50),
    [Usage Frequency]   VARCHAR(50),
    [Support Calls]     VARCHAR(50),
    [Payment Delay]     VARCHAR(50),
    [Subscription Type] VARCHAR(50),
    [Contract Length]   VARCHAR(50),
    [Total Spend]       VARCHAR(50),
    [Last Interaction]  VARCHAR(50),
    [Churn]             VARCHAR(50),
    [Source_File]       VARCHAR(100)          -- added in SSIS (Derived Column)
);

-- Dataset 2 (Telco)
CREATE TABLE dbo.stg_Churn_Telco (
    [customerID]       VARCHAR(50),
    [gender]           VARCHAR(50),
    [SeniorCitizen]    VARCHAR(50),
    [Partner]          VARCHAR(50),
    [Dependents]       VARCHAR(50),
    [tenure]           VARCHAR(50),
    [PhoneService]     VARCHAR(50),
    [MultipleLines]    VARCHAR(50),
    [InternetService]  VARCHAR(50),
    [OnlineSecurity]   VARCHAR(50),
    [OnlineBackup]     VARCHAR(50),
    [DeviceProtection] VARCHAR(50),
    [TechSupport]      VARCHAR(50),
    [StreamingTV]      VARCHAR(50),
    [StreamingMovies]  VARCHAR(50),
    [Contract]         VARCHAR(50),
    [PaperlessBilling] VARCHAR(50),
    [PaymentMethod]    VARCHAR(50),
    [MonthlyCharges]   VARCHAR(50),
    [TotalCharges]     VARCHAR(50),
    [Churn]            VARCHAR(50),
    [Source_File]      VARCHAR(100)
);

-- MERGED table: both datasets mapped to one common structure
CREATE TABLE dbo.stg_Customer_All (
    StagingID          INT IDENTITY(1,1) PRIMARY KEY,
    Source_Dataset     VARCHAR(50),
    Source_File        VARCHAR(100),
    Customer_ID        VARCHAR(20),     -- '12345' (Dataset 1) or '7590-VHVEG' (Telco)
    Gender             VARCHAR(20),
    Age                INT NULL,        -- Dataset 1 only
    Senior_Citizen     VARCHAR(10),     -- Telco flag; Dataset 1 derived from Age >= 65
    Partner            VARCHAR(10),
    Dependents         VARCHAR(10),
    Subscription_Type  VARCHAR(30),     -- Dataset 1: Basic/Standard/Premium
    Internet_Service   VARCHAR(30),     -- Telco: DSL/Fiber optic/No
    Phone_Service      VARCHAR(30),
    Online_Security    VARCHAR(30),
    Tech_Support       VARCHAR(30),
    Streaming_TV       VARCHAR(30),
    Contract_Type      VARCHAR(30),
    Paperless_Billing  VARCHAR(10),
    Payment_Method     VARCHAR(50),
    Tenure_Months      INT NULL,
    Usage_Frequency    INT NULL,
    Support_Calls      INT NULL,
    Payment_Delay      INT NULL,
    Last_Interaction   INT NULL,
    Monthly_Charges    DECIMAL(10,2) NULL,
    Total_Spend        DECIMAL(12,2) NULL,
    Churn              INT NULL         -- 1 = churned, 0 = stayed (Telco Yes/No converted)
);
GO

