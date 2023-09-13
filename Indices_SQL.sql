SELECT *
  FROM [Project].[dbo].[Untitled spreadsheet - all_indices_data]
--------------------------------------------------------------------------------


  
--------------------------------------------------------------------- FINDING INDEX WITH GOOD PERFORMAMCE  AND RELATIVELY LOW RISK  OF INVESTMENT

--AVG close price of 7038 will be used as reference point for further analysis
SELECT AVG([close])
FROM [Untitled spreadsheet - all_indices_data(1)]
where year between 2022 and 2023


--Counting number of closing prices above 7038 for each index 
select ticker, count([close]) as count_prices_above_avg
into dbo.indices_price_count_above_avg
from [Untitled spreadsheet - all_indices_data]
where [close] > 19803 and year between 2022 and 2023
group by ticker
order by count_prices_above_avg desc
--MXX index has the highest count of closing price above avg btw 2022 -2023 
--DJI index  has highest avg closing price count after MXX
   --------------------------------------------------------------------------------------------------------------



     --------------------------------------------------------------------------------------------------------------
--Creating table  with AVG closing price of ( 2022 - 2023 )  for each index 
SELECT year, ticker, avg_price
into dbo.Above_avg_price_index 
from (
select year, ticker, avg([close]) as avg_price
from [Project].[dbo].[Untitled spreadsheet - all_indices_data]
where year between 2022 and 2023
group by year, ticker
) as subquery
order by avg_price desc


--Shows avg closing price between 2022 -2023 for all indices  ( table extracted from script above )
select *
from Above_avg_price_index
where year between 2022 and 2023
order by avg_price desc
-- MERV index shows the highest avg closing price
-- BVSP index is second afte the BVSP index

   --------------------------------------------------------------------------------------------------------------




 --------------------------------------------------------------------------------------------------------------
  --Evaluating the the risk of investment for indices with STDEV for closing price ( year 2023 ). Relatively High number suggest high index volatility and Low number is low volatility
  SELECT year,ticker, STDEV([close]) AS stdev_closing_price
  into dbo.indices_investment_risk -- NEW TABLE indices_investment_risk
  FROM [Project].[dbo].[Untitled spreadsheet - all_indices_data]
  where year = 2023
  GROUP BY year,ticker
  ORDER BY stdev_closing_price asc
  
  -- VIX  shows lowest volatility in ( 2023 )
  -- BUK100P index is second after VIX index ( 2023 )
  --In context of volatility indices with high STDEV is indices with high risk of investment while  indices with low STDEV has lower risk of investment 
   --------------------------------------------------------------------------------------------------------------




    -----------------------------------------------------------------JOINONG columns year, ticker, stdev_closing_price, avg_price, count_prices_above_avg to find Index


   select ir.year,ir.ticker, ir.stdev_closing_price, ai.avg_price, pc.count_prices_above_avg
   into dbo.indices_joined -- creating table with joined columns 
   from indices_investment_risk as ir
   join Above_avg_price_index as ai on ir.ticker = ai.ticker
   join indices_price_count_above_avg as pc on ir.ticker = pc.ticker
   order by stdev_closing_price asc,
   ai.avg_price desc,
   pc.count_prices_above_avg desc
--------------------------------------------------------------------------------------------

--  Creating table with STDEV, price above avg, price count above avg.
   select ticker, avg( stdev_closing_price) as stdev_,  avg(avg_price) as price_, avg(count_prices_above_avg) as count_
from indices_joined
where year between 2022 and 2023
 group by ticker
order by stdev_ asc, price_ desc, count_ desc -- BVSP Index ( stdev 6477  price 110202 count 411 )
--                                                MXX Index ( stdev 1018  price 51935  count 414 )
---------------------------------------------------------------------------------------------




---------------------- Using avg volume as reference for BVSP and MXX volume
select  avg(volume)                          --AVG volume
from [Untitled spreadsheet - all_indices_data]
where year between 2022  and 2023    -- show AVG as reference trandline in chart compared to BVSP and MXX volumes 


select  year, month, volume -- BVSP volume table
from [Untitled spreadsheet - all_indices_data] 
where ticker = 'BVSP'and  year between 2022 and 2023 


select year, month, volume  -- MXX volume table 
from [Untitled spreadsheet - all_indices_data]
where ticker = 'MXX'and  year between 2022 and 2023    -- Join volume tables in tableau before viz.
---------------------------------------------------------




-----------------------Running 10 and 30 MOVING AVERAGE (MA) for BSVP and MXX indices


SELECT -- MA 10,30 ( BVSP index ) 
year,
month,
'BVSP' AS ticker,
 cast(case when ROW_NUMBER() over (order by [Year]) > 9
then sum([Close]) over (order by [Year] rows between 9 preceding and current row)
end / 10 as INT ) as ma_10,
cast( case when ROW_NUMBER() over (order by [year ]) >29
then sum([Close]) over (order by [Year] rows between 29 preceding and current row)
end / 30 as int)  as ma_30
from 
(
select *
from [Untitled spreadsheet - all_indices_data]
where year = 2023 and
ticker = 'BVSP'
) as subquery;



SELECT -- MA 10,30 ( MXX index ) 
year,
month,
'MXX' AS ticker,
 cast(case when ROW_NUMBER() over (order by [Year]) > 9
then sum([Close]) over (order by [Year] rows between 9 preceding and current row)
end / 10 as INT ) as ma_10,
cast( case when ROW_NUMBER() over (order by [year ]) >29
then sum([Close]) over (order by [Year] rows between 29 preceding and current row)
end / 30 as int)  as ma_30
from 
(
select *
from [Untitled spreadsheet - all_indices_data]
where year = 2023 and
ticker = 'MXX'
) as subquery;    -- Join MA tables in tableau before viz.
---------------------------------------------------------------------------------------------

