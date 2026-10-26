/* =====================================================================
   Customer Churn ETL - database setup  (Dataset 1 + Telco)
   PART A  -> run on  LAPTOP-5Q67MFKR\SQLEXPRESS01   (Churn_Staging)
   PART B  -> run on  LAPTOP-5Q67MFKR\CHUM           (Churn_DWH)
   PART C  -> SSIS source queries (paste into OLE DB Sources, don't run here)

   Dataset 1 : customer_churn_dataset-training-master.csv
               customer_churn_dataset-testing-master.csv
   Dataset 2 : WA_Fn-UseC_-Telco-Customer-Churn.csv
   ===================================================================== */


/* =====================================================================
   PART A - STAGING  (connect SSMS to SQLEXPRESS01)
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


/* =====================================================================
   PART B - DATA WAREHOUSE / STAR SCHEMA  (connect SSMS to CHUM)
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

/* Reset for re-running (Execute SQL Task at start of Master.dtsx, connection = DWH_DB):

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

   Staging reset (Execute SQL Task, connection = Staging_DB):

TRUNCATE TABLE dbo.stg_Churn_Master;
TRUNCATE TABLE dbo.stg_Churn_Telco;
TRUNCATE TABLE dbo.stg_Customer_All;
*/


/* =====================================================================
   PART C - SSIS SOURCE QUERIES (OLE DB Source -> Data access mode: SQL command)
   ===================================================================== */

/* ---- C1. Merge data flow, source 1: Dataset 1 ------------------------
   Note: the 1 completely empty row in the training file is NOT removed
   here on purpose - the Filter in Dim_Customer / Dim_Subscription removes it.

SELECT
    CAST('Customer Churn Master' AS VARCHAR(50))                        AS Source_Dataset,
    CAST(Source_File AS VARCHAR(100))                                   AS Source_File,
    CAST(ISNULL(CAST(TRY_CAST(TRY_CAST(NULLIF([CustomerID],'') AS FLOAT) AS INT) AS VARCHAR(20)),'') AS VARCHAR(20)) AS Customer_ID,
    CAST(ISNULL(NULLIF([Gender],''),'N/A') AS VARCHAR(20))              AS Gender,
    TRY_CAST(TRY_CAST(NULLIF([Age],'') AS FLOAT) AS INT)                AS Age,
    CAST(CASE WHEN TRY_CAST(TRY_CAST(NULLIF([Age],'') AS FLOAT) AS INT) >= 65 THEN 'Yes'
              WHEN NULLIF([Age],'') IS NULL THEN 'N/A' ELSE 'No' END AS VARCHAR(10)) AS Senior_Citizen,
    CAST('N/A' AS VARCHAR(10))                                          AS Partner,
    CAST('N/A' AS VARCHAR(10))                                          AS Dependents,
    CAST(ISNULL(NULLIF([Subscription Type],''),'N/A') AS VARCHAR(30))   AS Subscription_Type,
    CAST('N/A' AS VARCHAR(30))                                          AS Internet_Service,
    CAST('N/A' AS VARCHAR(30))                                          AS Phone_Service,
    CAST('N/A' AS VARCHAR(30))                                          AS Online_Security,
    CAST('N/A' AS VARCHAR(30))                                          AS Tech_Support,
    CAST('N/A' AS VARCHAR(30))                                          AS Streaming_TV,
    CAST(ISNULL(NULLIF([Contract Length],''),'N/A') AS VARCHAR(30))     AS Contract_Type,
    CAST('N/A' AS VARCHAR(10))                                          AS Paperless_Billing,
    CAST('N/A' AS VARCHAR(50))                                          AS Payment_Method,
    TRY_CAST(TRY_CAST(NULLIF([Tenure],'') AS FLOAT) AS INT)             AS Tenure_Months,
    TRY_CAST(TRY_CAST(NULLIF([Usage Frequency],'') AS FLOAT) AS INT)    AS Usage_Frequency,
    TRY_CAST(TRY_CAST(NULLIF([Support Calls],'') AS FLOAT) AS INT)      AS Support_Calls,
    TRY_CAST(TRY_CAST(NULLIF([Payment Delay],'') AS FLOAT) AS INT)      AS Payment_Delay,
    TRY_CAST(TRY_CAST(NULLIF([Last Interaction],'') AS FLOAT) AS INT)   AS Last_Interaction,
    CAST(NULL AS DECIMAL(10,2))                                         AS Monthly_Charges,
    TRY_CAST(NULLIF([Total Spend],'') AS DECIMAL(12,2))                 AS Total_Spend,
    TRY_CAST(TRY_CAST(NULLIF([Churn],'') AS FLOAT) AS INT)              AS Churn
FROM dbo.stg_Churn_Master;
*/

/* ---- C2. Merge data flow, source 2: Telco ---------------------------
SELECT
    CAST('Telco Customer Churn' AS VARCHAR(50))                         AS Source_Dataset,
    CAST(Source_File AS VARCHAR(100))                                   AS Source_File,
    CAST([customerID] AS VARCHAR(20))                                   AS Customer_ID,
    CAST([gender] AS VARCHAR(20))                                       AS Gender,
    CAST(NULL AS INT)                                                   AS Age,
    CAST(CASE [SeniorCitizen] WHEN '1' THEN 'Yes' ELSE 'No' END AS VARCHAR(10)) AS Senior_Citizen,
    CAST([Partner] AS VARCHAR(10))                                      AS Partner,
    CAST([Dependents] AS VARCHAR(10))                                   AS Dependents,
    CAST('N/A' AS VARCHAR(30))                                          AS Subscription_Type,
    CAST([InternetService] AS VARCHAR(30))                              AS Internet_Service,
    CAST([PhoneService] AS VARCHAR(30))                                 AS Phone_Service,
    CAST([OnlineSecurity] AS VARCHAR(30))                               AS Online_Security,
    CAST([TechSupport] AS VARCHAR(30))                                  AS Tech_Support,
    CAST([StreamingTV] AS VARCHAR(30))                                  AS Streaming_TV,
    CAST([Contract] AS VARCHAR(30))                                     AS Contract_Type,
    CAST([PaperlessBilling] AS VARCHAR(10))                             AS Paperless_Billing,
    CAST([PaymentMethod] AS VARCHAR(50))                                AS Payment_Method,
    TRY_CAST([tenure] AS INT)                                           AS Tenure_Months,
    CAST(NULL AS INT)                                                   AS Usage_Frequency,
    CAST(NULL AS INT)                                                   AS Support_Calls,
    CAST(NULL AS INT)                                                   AS Payment_Delay,
    CAST(NULL AS INT)                                                   AS Last_Interaction,
    TRY_CAST([MonthlyCharges] AS DECIMAL(10,2))                         AS Monthly_Charges,
    TRY_CAST(NULLIF(LTRIM(RTRIM([TotalCharges])),'') AS DECIMAL(12,2))  AS Total_Spend,  -- 11 blanks -> NULL
    CAST(CASE [Churn] WHEN 'Yes' THEN 1 WHEN 'No' THEN 0 END AS INT)    AS Churn
FROM dbo.stg_Churn_Telco;
*/

/* ---- C3. Dimension / fact source queries (connection = Staging_DB) ---
Dim_Customer     : SELECT StagingID, Customer_ID, Gender, Age, Senior_Citizen, Partner,
                          Dependents, Source_Dataset, Source_File
                   FROM dbo.stg_Customer_All;

Dim_Contract     : SELECT DISTINCT Contract_Type, Paperless_Billing FROM dbo.stg_Customer_All;

Dim_Payment      : SELECT DISTINCT Payment_Method FROM dbo.stg_Customer_All;

Dim_Subscription : SELECT DISTINCT Subscription_Type, Internet_Service, Phone_Service,
                          Online_Security, Tech_Support, Streaming_TV
                   FROM dbo.stg_Customer_All;

Load_Fact        : SELECT StagingID, Contract_Type, Paperless_Billing, Payment_Method,
                          Subscription_Type, Internet_Service, Phone_Service,
                          Online_Security, Tech_Support, Streaming_TV,
                          Tenure_Months, Usage_Frequency, Support_Calls, Payment_Delay,
                          Last_Interaction, Monthly_Charges, Total_Spend, Churn
                   FROM dbo.stg_Customer_All;
*/
