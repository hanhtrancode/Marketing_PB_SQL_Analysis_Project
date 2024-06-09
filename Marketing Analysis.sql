--DATA CLEANING--

--STEP1: Find duplicate data
select * from
--Using row_number to find duplicated date
(select *, row_number() over (partition by ID, Year_Birth, Education, Income, Kidhome order by Id) as [count]
from dbo.Buying) as TBS
--condition if [count]>1 means that there are rows which have same ID, Year_Birth, Education, Income, Kidhome
where [count] >1
--Result: This case does not have duplicate data

--Case 2: i also check whether have duplicate ID
select * from
(select *, row_number() over (partition by ID order by Id) as [count]
from dbo.Buying) as TBS
where [count] >1
--Result: No duplicate Id

--STEP2: Find blank data
--To be safe, we just need to check whether there are black data in ID

select * 
from dbo.Buying
where Id is null --(Should be null not 0);

--BASIC DATE EXPLORATION

--1.Which campaign will attract customer most 

--Print the number customer accept the offer from campaign
declare @count1 int
select @count1= count(id) from dbo.buying where AcceptedCmp1=1 
print ('Accepted1:' +cast(@count1 as varchar(10)));

declare @count2 int
select @count2= count(id) from dbo.buying where AcceptedCmp2=1 
print ('Accepted2:' +cast(@count2 as varchar(10)));

declare @count3 int
select @count3= count(id) from dbo.buying where AcceptedCmp3=1 
print ('Accepted3:' +cast(@count3 as varchar(10)));

declare @count4 int
select @count4= count(id) from dbo.buying where AcceptedCmp4=1 
print ('Accepted4:' +cast(@count4 as varchar(10)));

declare @count5 int
select @count5= count(id) from dbo.buying where AcceptedCmp5=1 
print ('Accepted5:' +cast(@count5 as varchar(10)));

--In here, we have highest number of customers accept the offer in campaign is the 4th, 
--but we recommned it should be 3th or even 1st because we need to spend our money, effort to attract customers. 
--The less campaign we need, the less cost we spend. 
--There are a small change between 1st, 3rd, 4nd campaign

--2.BETWEEN DISCOUNT AND CATALOUGE, WHICH ONE IS BETTER

--BOTH DISCOUNT AND CATALOUGE ARE FORMS OF PROMOTION

select sum(NumDealsPurchases) as[Deals_Purchases], 
	sum(NumCatalogPurchases) as [CatalogPurchases]
from dbo.Buying

--This figure show that Catalouge is more effective in total for 2 years

--3.WHICH KIND OF PRODUCTS ARE MORE PREFERABLE

select sum(MntWines) as [Wines], sum(MntFruits) as [Fruits], sum(MntSweetProducts) as [Sweet], sum(MntGoldProds) as [Gold], sum(MntMeatProducts) as [Meat], sum(MntFishProducts) as [Fish]
from dbo.Buying

--Wines and Meat are the most preferable

--4. WHICH DISTRIBUTION PLACE ARE MORE PREDERABLE
SELECT  SUM(NumWebPurchases) 
from dbo.Buying
Union all
Select sum(NumStorePurchases) 
from dbo.Buying

--Store is more preferable

--5. HARD_CUSTOMER
--Do store succeed in attract customers back throughout the year

select year(Dt_customer) as [Year], sum(recency) as [Total_recency]
from dbo.Buying
group by year(Dt_customer)
order by  year(Dt_customer)

--It shows that company recently fail to attract customers to comeback

--6. FINDING PEAK PERIOD

--Let see the number of buying according to month
select month(Dt_customer) as [Month], count(id) as [Total_buy]
from dbo.Buying
group by month(Dt_customer)
order by  count(id) desc
--Let see the number of buying according to quarter

select [Quarter], sum(Recency) as [Total_Buying]
from(
select datepart(quarter, Dt_Customer) as [Quarter], Recency
from dbo.Buying
) as PVT
group by [Quarter]
order by sum(Recency) desc

--Result: Customer likely to buy in the winter

--7. EACH TYPE OF PRODUCT IS CONSUMED MOST BY WHICH TYPE OF CONSUMERS

--Wines
select * from
(select distinct Marital_Status, sum(MntWines) over(partition by Marital_Status ) as [Consumption]
from dbo.Buying) as PVT 
order by [Consumption] desc

--Fruits
select * from
(select distinct Marital_Status, sum(MntFruits) over(partition by Marital_Status ) as [Consumption]
from dbo.Buying) as PVT 
order by [Consumption] desc

--MeatProducts
select * from
(select distinct Marital_Status, sum(MntMeatProducts) over(partition by Marital_Status ) as [Consumption]
from dbo.Buying) as PVT 
order by [Consumption] desc

--MntFishProducts
select * from
(select distinct Marital_Status, sum(MntFishProducts) over(partition by Marital_Status ) as [Consumption]
from dbo.Buying) as PVT 
order by [Consumption] desc

--MntSweetProducts
select * from
(select distinct Marital_Status, sum(MntSweetProducts) over(partition by Marital_Status ) as [Consumption]
from dbo.Buying) as PVT 
order by [Consumption] desc

--MntGoldProducts
select * from
(select distinct Marital_Status, sum(MntGoldProds) over(partition by Marital_Status ) as [Consumption]
from dbo.Buying) as PVT 
order by [Consumption] desc


---8. AVERAGE CONSUMTION 

--Crate table to store consumption information

create table dbo.consumption
(Marital_Status varchar(20), Product_Consumption int)

insert into dbo.consumption
select distinct Marital_Status, sum(MntWines) over(partition by Marital_Status ) as [Consumption]
from dbo.Buying
--Adding Fruits data
select distinct Marital_Status, sum(MntFruits) over(partition by Marital_Status ) as [Consumption]
from dbo.Buying
--Adding Meat data
select distinct Marital_Status, sum(MntMeatProducts) over(partition by Marital_Status ) as [Consumption]
from dbo.Buying
--Adding Fish data
select distinct Marital_Status, sum(MntFishProducts) over(partition by Marital_Status ) as [Consumption]
from dbo.Buying
--Adding Sweet data
select distinct Marital_Status, sum(MntSweetProducts) over(partition by Marital_Status ) as [Consumption]
from dbo.Buying
--Adding Gold data
select distinct Marital_Status, sum(MntGoldProds) over(partition by Marital_Status ) as [Consumption]
from dbo.Buying

--Calculating Average Consumption
select AVG(Product_Consumption) as [Average Consumption Figure]
from dbo.consumption


