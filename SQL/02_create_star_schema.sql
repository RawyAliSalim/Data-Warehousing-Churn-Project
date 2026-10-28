IF DB_ID(N'Churn_DWH') IS NULL
    EXEC(N'CREATE DATABASE [Churn_DWH]');
GO

USE Churn_DWH;
GO

DROP TABLE IF EXISTS dbo.Fact_Churn;
DROP TABLE IF EXISTS dbo.Dim_Customer;
DROP TABLE IF EXISTS dbo.Dim_Contract;
DROP TABLE IF EXISTS dbo.Dim_Payment;
DROP TABLE IF EXISTS dbo.Dim_Subscription;
DROP TABLE IF EXISTS dbo.Dim_Source;
GO

CREATE TABLE dbo.Dim_Customer (
    Customer_Key       INT IDENTITY(1,1) PRIMARY KEY,
    Customer_BK        INT NOT NULL,
    Customer_ID        VARCHAR(20),
    Customer_Number    NVARCHAR(20),
    Customer_Suffix    NVARCHAR(20),
    Gender             VARCHAR(20),
    Age                INT NULL,
    Age_Group          NVARCHAR(20),
    Senior_Citizen     VARCHAR(10),
    Partner            VARCHAR(10),
    Dependents         VARCHAR(10),
    Source_Dataset     VARCHAR(50),
    Source_File        VARCHAR(100)
);

CREATE TABLE dbo.Dim_Contract (
    Contract_Key       INT IDENTITY(1,1) PRIMARY KEY,
    Contract_Type      VARCHAR(30),
    Paperless_Billing  VARCHAR(10),
    Contract_Name      NVARCHAR(30),
    Contract_Code      NVARCHAR(30),
    Contract_Months    INT
);

CREATE TABLE dbo.Dim_Payment (
    Payment_Key        INT IDENTITY(1,1) PRIMARY KEY,
    Payment_Method     VARCHAR(50),
    Payment_Name       NVARCHAR(50),
    Payment_Mode       NVARCHAR(20),
    Payment_Code       NVARCHAR(50)
);

CREATE TABLE dbo.Dim_Subscription (
    Subscription_Key       INT IDENTITY(1,1) PRIMARY KEY,
    Subscription_Type      VARCHAR(30),
    Internet_Service       VARCHAR(30),
    Phone_Service          VARCHAR(30),
    Online_Security        VARCHAR(30),
    Tech_Support           VARCHAR(30),
    Streaming_TV           VARCHAR(30),
    Plan_Name              NVARCHAR(30),
    Plan_Code              NVARCHAR(30),
    Online_Security_Code   NVARCHAR(30),
    Tech_Support_Code      NVARCHAR(30)
);


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
