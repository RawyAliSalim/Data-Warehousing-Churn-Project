# SSIS setup after cloning

This project keeps SQL Server names and the data folder in project parameters.
The connection managers and flat-file connections use those parameters, so
local setup should not require editing individual packages or connection
strings.

## Requirements

- Use a Visual Studio version with the SQL Server Integration Services Projects
  extension that supports this project. The project currently targets
  SQL Server 2025 and uses the `.slnx` solution format. Using the same Visual
  Studio and SSIS extension version across the team reduces project upgrade
  and serialization conflicts.
- Install the Microsoft OLE DB Driver for SQL Server (`MSOLEDBSQL`).
- Make sure the three CSV files are present in the repository's `Data` folder.

If Visual Studio asks to upgrade the project or package format, coordinate
with the team before accepting and committing that upgrade. Do not mix package
format upgrades with a routine data-server configuration change.

## Configure a clone

1. Clone the repository and open `ETL_Project/ETL_Project.slnx` in Visual
   Studio. Do not open `Project.params` as a separate project.
2. In SQL Server Management Studio, check the exact server and instance names
   and confirm Windows Authentication can connect to each instance.
3. If using the separate SQL Server instances described by the SQL scripts,
   run `SQL/01_create_staging_tables.sql` on the instance that will host
   `Churn_Staging`, and `SQL/02_create_star_schema.sql` on the instance that
   will host `Churn_DWH`. These scripts drop and recreate their project
   tables; only run them against databases you intend to use for this ETL.
4. Open `ETL_Project/ETL_Project/Project.params` in Visual Studio and set:
   - `ServerName_Staging`: the SQL Server instance containing `Churn_Staging`
   - `ServerName_DWH`: the SQL Server instance containing `Churn_DWH`
   - `DataFolder`: the full path to this clone's `Data` folder (do not include
     a trailing slash)
5. Save, build the solution, then run `Master.dtsx`. The master package resets
   its staging and warehouse ETL tables before loading; use databases reserved
   for this project.
6. Run `SQL/05_verification_queries.sql` against the appropriate instances and
   confirm the staging and warehouse tables contain rows.

The project's default values in `Project.params` are the maintainer's local
settings. They are examples, not portable server names or paths. Review the
parameter values before running the package on a new computer.

## Keep local settings out of shared commits

`Project.params` is tracked because it defines the shared project parameters.
Its values are machine-specific. Before committing, inspect
`git diff -- ETL_Project/ETL_Project/Project.params` and do not include
machine-only value changes in a code change. Keep the `.conmgr` files and
`.dtsx` packages tracked; they contain the shared parameter wiring.

The repository ignores Visual Studio user settings, SSIS build output, and
local `.database` metadata. Do not add broad ignore rules for `*.params`,
`*.conmgr`, `*.dtsx`, or `*.dtproj`; doing so would hide required project
source files from Git.
