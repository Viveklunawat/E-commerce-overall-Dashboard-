create database retail --creating database
use retail
select * from OnlineRetail -- checking the table

select CustomerID from OnlineRetail where CustomerID is null -- finding thenull columns


select CustomerID,Quantity from OnlineRetail --finding what the neagtive is for , neagtive means return  
order by CustomerID

select * from OnlineRetail where UnitPrice is null;-- checking for null values

select * from OnlineRetail where Description = 'Adjust bad debt'-- saw the price of the product

update OnlineRetail -- added value on the null cell based on the readymention product 
set UnitPrice = 11062.0595703125
where Description = 'Adjust bad debt';

select * from OnlineRetail -- checking unit values are 0 where description are not null
where UnitPrice=0 and Description is not null
order by InvoiceNo;

with ag as --crwating a new table with include a extra row which i was use to replace the 0 value with averga unit price of the product 
(
select stockcode, AVG(UnitPrice) as ave from OnlineRetail group by StockCode 
),new as 
(
select o.*,a.ave
from OnlineRetail as o left join ag as a 
on o.StockCode=a.StockCode and o.UnitPrice=0
) select * into new_table from new

update new_table --updating the null value to 0
set ave=0
where ave is null

update new_table --updating the null value to unknow
set Description = 'unknown'
where Description is null

with online_retail as --creating a new table with the required columns 
(
select *,quantity*(UnitPrice+ave) as Total_price from new_table
) select InvoiceNo,
	cast(InvoiceDate as date) as invoice_date,
	StockCode,
	Description,
	Quantity,
	Country,
	Total_price,
	case when
	Quantity <0 then 'return'
	else 'not_return'
	end as returned
	into online_ret
from online_retail

select returned , sum(total_price) as true_value --value of purchased and return product 
from online_ret
group by returned;

select sum(total_price) from online_ret--real sales 

select returned , sum(Quantity) as true_value --value of purchased and return quantity product 
from online_ret
group by returned;

select sum(Quantity) from online_ret--real quantity sold


select Country,sum(Total_price) as sales from online_ret
where returned = 'not_return'
group by Country
order by sales desc


with retun as --which country have the lowest return_ratio in term of sales
(
select Country,sum(Total_price) as sales from online_ret
where returned = 'not_return'
group by Country
),returnes as 
(
select Country,sum(Total_price) as sales from online_ret
where returned = 'return'
group by Country
)select r.*,re.sales,(-(re.sales)/(r.sales)) as return_ratio
from  retun as r left join returnes as re 
on r.Country=re.Country
order by return_ratio


with retun as --which country have the lowest return_ratio in term of quantity
(
select Country,sum(Quantity) as sales from online_ret
where returned = 'not_return'
group by Country
),returnes as 
(
select Country,sum(Quantity) as sales from online_ret
where returned = 'return'
group by Country
)select r.*,re.sales,(-(re.sales)/(r.sales)) as return_ratio
from  retun as r left join returnes as re 
on r.Country=re.Country
order by return_ratio

select Country, count(Country) as num_of_order from online_ret --which country ordered the most
where returned='not_return'
group by Country
order by num_of_order desc

select year(invoice_date) as yea,month(invoice_date) as mon,sum(Total_price) as sales --sales by year and month
from online_ret
group by year(invoice_date),month(invoice_date)
order by yea ,mon ;


with rea as -- top 10 product from each country based on sales
(
select Country,StockCode,sum(Total_price) as total 
,RANK() over(partition by country order by sum(total_price) desc) as ran
from online_ret
group by Country,StockCode
) select * from rea 
where ran<=10

