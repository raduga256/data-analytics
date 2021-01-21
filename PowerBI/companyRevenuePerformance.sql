-- Raw Data Tables Description

-- 1. select *from [dbo].[Revenue_Raw_Data]
-- This table has the Revenue by Account ID, By Product  $ by Month ID

-- 2. select *from [dbo].[Marketing_Raw_Data]
-- This Table has information about Marketing Spend per Account ID, Product and Month ID

-- 3. select *from [dbo].[Targets_Raw_Data]
-- This table has information about the targets per  Account ID, Product and Month ID

-- 4. select *from [dbo].[yt_Opportunities_Data]
-- This table has information about the Opportunities per  Account ID, Product and Month ID

-- 5. select *from [dbo].[yt_account_lookup]  DATA NOT YET IMPORTED DUE TO ERROR
-- This table has additional information about the Accounts(Name, Segments, Managers, etc)

-- 6. select *from [dbo].[yt_Calendar_lookup]
-- This table has information about the Calendar information

-- Visualizing the tables
select *from [dbo].[Revenue_Raw_Data]
select *from [dbo].[Marketing_Raw_Data]
select *from [dbo].[Targets_Raw_Data]
select *from [dbo].[yt_Opportunities_Data]
select *from [dbo].[yt_Calendar_lookup]

---1 - What is the total Revenue of the company this year? fy21 but we don't have that column 
---    in the Revenue Table. we shall use data from the calender table and pickout month IDs that
---    correspond to the fiscal year of our interest

select *from [dbo].[Revenue_Raw_Data]
--- We selecting dinstict month IDs within the fiscal year of interest
select DISTINCT(Month_ID) from [dbo].[yt_Calendar_lookup] where Fiscal_Year  = 'fy21'

select --Month_ID, 
sum(Revenue) as Total_Revenue_FY21 from [dbo].[Revenue_Raw_Data]
where Month_ID in (select DISTINCT(Month_ID) from [dbo].[yt_Calendar_lookup] where Fiscal_Year  = 'fy21')
-- group by Month_ID

--- 2 - What is the total Revenue Performance YoY?

-- FY21  it has was a data for half year and it won't be fair to compare it with full[12 month] years

select a.Total_Revenue_FY21 , b.Total_Revenue_FY20, a.Total_Revenue_FY21 - b.Total_Revenue_FY20 as Dollar_Dif_YoY,
	a.Total_Revenue_FY21 / b.Total_Revenue_FY20 - 1 as Per_Diff_YoY
from
	(
	-- FY21
	select --Month_ID, 
	sum(Revenue) as Total_Revenue_FY21 from [dbo].[Revenue_Raw_Data]
	where Month_ID in (select DISTINCT(Month_ID) from [dbo].[yt_Calendar_lookup] where Fiscal_Year  = 'fy21')
	-- group by Month_ID
	) a,

	(-- FY20  has full 12months data so we have to choose common months
	select 
	sum(Revenue) as Total_Revenue_FY20 from [dbo].[Revenue_Raw_Data]
	where Month_ID in (select DISTINCT Month_ID - 12 from [dbo].[Revenue_Raw_Data] where Month_ID in      
	(select DISTINCT(Month_ID) from [dbo].[yt_Calendar_lookup] where Fiscal_Year  = 'fy21'))
	) b

--- for the above to select matching months in two different fiscal years for comparison.
select DISTINCT Month_ID - 12 from [dbo].[Revenue_Raw_Data] where Month_ID in      -- minus 12 takes us at the beginning of a fiscal year
(select DISTINCT(Month_ID) from [dbo].[yt_Calendar_lookup] where Fiscal_Year  = 'fy21')

---3 - What is the MoM Revenue Performance? comparison between the latest two months

select a.Total_Revenue_TM, b.Total_Revenue_LM, a.Total_Revenue_TM - b.Total_Revenue_LM as MoM_Dollar_Diff,
	a.Total_Revenue_TM / b.Total_Revenue_LM - 1 as MoM_Per_Diff	
from
	(
	-- This Month  -TM
	select Month_ID, 
	sum(Revenue) as Total_Revenue_TM from [dbo].[Revenue_Raw_Data]
	where Month_ID in (select max(Month_ID) from [dbo].[Revenue_Raw_Data])
	group by Month_ID
	) a,

	(-- Last/previous Month -LM
	select Month_ID,
	sum(Revenue) as Total_Revenue_LM from [dbo].[Revenue_Raw_Data]
	where Month_ID in (select max(Month_ID)-1 from [dbo].[Revenue_Raw_Data])   
	group by Month_ID
	) b

---4 - What is the Total Revenue Vs Target performance for the Year?
---5 - What is the Revenue Vs Target performance Per Month?
