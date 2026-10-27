-- Queries used inside SSIS OLE DB Sources (reference only)
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
