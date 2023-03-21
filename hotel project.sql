/* first step is to combine all the data into one table as it is spread across multiple tabs of an excel file. */


with hotels as (
select * 
from dbo.['2018$']
union
select * 
from dbo.['2019$']
union
select * 
from dbo.['2020$'])

/* second step is to run a query using the raw data and output what is usable to determine if the hotels revenue is growing */

/* select 
arrival_date_year,
hotel,
round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),2) as revenue
from hotels
group by arrival_date_year, hotel 
*/


select *
from hotels
left join dbo.market_segment$ on hotels.market_segment = market_segment$.market_segment
left join dbo.meal_cost$ on meal_cost$.meal = hotels.meal
