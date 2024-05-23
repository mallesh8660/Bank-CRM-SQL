use bank;
select * from activecustomer;
SET SQL_SAFE_UPDATES = 0;

-- handling empty rows in activecustomer
delete from activecustomer
where activeid='';

-- obj1
select c.geographyid,round(sum(balance),2) as amount ,geographylocation from bank_churn b
join 
customerinfo c on b.customerid=c.customerid
join geography d  on c.geographyid=d.geographyid
group  by geographyid,geographylocation
order by amount desc;

-- select * from customerinfo;
-- select year(`bank doj`) from customerinfo;
-- desc customerinfo
-- alter table customerinfo
-- modify column `bank doj` date;

-- obj 2
SELECT customerid,surname,estimatedsalary as maxSalary, 
year(`bank doj`) as year,
quarter(`bank doj`) as quarter 
FROM customerinfo
where quarter(`bank doj`)=4
order by estimatedsalary desc
limit 5;

-- obj 3
select CustomerId,round(avg(NumOfProducts),2) as avg_UseProducts from bank_churn
where HasCrCard=1
group by CustomerId;


-- select 
--        count(b.customerid),
-- 	   count(exited),
--        g.GenderID,
--        GenderCategory
--        from bank_churn b
-- join customerinfo a on b.customerid=a.customerid
-- join gender g on a.genderid=g.genderid 
-- where exited=1
-- group by GenderCategory,g.genderid


-- select customerid,
--        creditscore,
--        exited,
--        avg(creditscore) over(partition by exited) as avg_credit_score
--  from bank_churn ;

 -- obj 5
 select ExitCategory,avg(creditscore) as Avg_Credit_Score from bank_churn b
 join exitcustomer e on e.exitid=b.exited
 group by ExitCategory;
 
--  obj 6

select GenderCategory,round(avg(EstimatedSalary),2) as Avg_EstimatedSalary,
count(IsActiveMember) as_num_ActiveCust from customerinfo c
join gender g on c.genderid=g.genderid
join bank_churn b on c.customerid=b.customerid
where IsActiveMember=1
group by GenderCategory;

-- select gendercategory,round(avg(estimatedsalary),2) as Avg_EstimatedSalary ,count(IsActiveMember) as_num_ActiveCust,count(exited) from customerinfo c
-- join  bank_churn b on c.customerid=b.customerid
-- join gender g on c.genderid=g.genderid
-- group by gendercategory;



-- obj 7
select CustomerId,
       CreditScore,
       Exited,
       segment
       from(
select *,
       case
       when CreditScore between 800 and 850 then 'Excellent'
       when CreditScore between 740 and 799 then 'Very Good'
       when CreditScore between 670 and 739 then 'Good'
       when CreditScore between 580 and 669 then 'Fair'
       when CreditScore between 300 and 579 then 'Poor'
       end as segment
       from bank_churn
       where Exited=1
       ) as res;


select 
       sum(Exited) as Exited_customers,
       segment,sum(exited)/count(*) as exit_rate
       from(
select *,
       case
       when CreditScore between 800 and 850 then 'Excellent'
       when CreditScore between 740 and 799 then 'Very Good'
       when CreditScore between 670 and 739 then 'Good'
       when CreditScore between 580 and 669 then 'Fair'
       when CreditScore between 300 and 579 then 'Poor'
       end as segment
       from bank_churn
       ) as res
group by segment
order by exit_rate desc
limit 1;



-- obj 8
select GeographyLocation,count(IsActiveMember) as ActiveMembers from customerinfo c
join geography g on c.GeographyID=g.GeographyID
join  bank_churn b on c.customerid=b.customerid
where Tenure>5 and IsActiveMember=1
group by GeographyLocation
order by ActiveMembers desc
limit 1;


-- obj 9
select count(*) as exitedHavingCred,
(select count(*) from bank_churn
where exited=1 and HasCrCard=0 ) as exitewithoutCred
 from bank_churn b
join creditcard c on b.HasCrCard=c.CreditID
where exited=1 and HasCrCard=1;


-- obj 10
select NumOfProducts,count(customerid) as most_CommonProducts
from bank_churn
where exited=1 
group by NumOfProducts
order by most_Commonproducts desc
limit 1;

-- obj 11
select count(customerid) No_OfCustomers,year(`bank doj`) as year from customerinfo
group by year(`bank doj`)
order by year;

-- obj 12
select numofproducts,round(avg(balance),2) as AvgBalance from bank_churn
where exited=1
group  by numofproducts
order by AvgBalance desc;

-- obj 14
SELECT COUNT(*) as No_Of_Tables
FROM information_schema.tables
WHERE table_schema = 'bank';

-- obj 15
select 
         rank() over(partition by GeographyLocation order by income desc) as `rank`,
         income,
         GenderCategory,
         GeographyLocation
       from  (
select round(avg(estimatedsalary),2) as income ,GenderCategory,GeographyLocation from customerinfo c
join gender g on c.genderid=g.genderid 
join geography ge on c.GeographyID=ge.GeographyID
group by GenderCategory,GeographyLocation
order by GeographyLocation
) as res;

-- obj 16
with cte as(
select age,
       exited,
       tenure,
       case 
       when age between 18 and 30 then '18-30'
       when age between 30 and 50 then '30-50'
       else
       '50+'
       end as AgeSegment
from bank_churn b
join customerinfo c
on c.customerid=b.customerid
where exited=1
)
select AgeSegment,avg(tenure) as AvgTenure from cte
group by agesegment;

-- obj 19
with cte as(
select 
       sum(Exited) as Exited_customers,
       segment
       from(
select *,
       case
       when CreditScore between 800 and 850 then 'Excellent'
       when CreditScore between 740 and 799 then 'Very Good'
       when CreditScore between 670 and 739 then 'Good'
       when CreditScore between 580 and 669 then 'Fair'
       when CreditScore between 300 and 579 then 'Poor'
       end as segment
       from bank_churn
       ) as res
group by segment
)
select *,
rank() over(order by exited_customers desc) as `rank`
 from cte;
 
--  obj 20

with cte as(
select 
       count(HasCrCard) as no_of_creditcard,
       case 
       when age between 18 and 30 then '18-30'
       when age between 30 and 50 then '30-50'
       else
       '50+'
       end as AgeSegment
from bank_churn b
join customerinfo c
on c.customerid=b.customerid
where HasCrCard=1
group by agesegment
)
select * from cte
where no_of_creditcard<(select avg(no_of_creditcard) from cte);

-- obj 21
select round(avg(balance),2) as Avg_balance,
GeographyLocation,
count(exited) as no_OfChurn,
rank() over(order by count(exited) desc,avg(balance) desc) as `rank` 
from bank_churn b
join customerinfo c on b.CustomerId=c.CustomerId
join geography g on c.GeographyID=g.GeographyID
where exited=1
group by GeographyLocation;

-- obj 22
-- DDL
select * from customerinfo;
 alter table customerinfo
 add customerid_Surname varchar(50);
--  DML 
 update customerinfo
 set customerid_Surname=concat(CustomerId,'_',Surname);

-- obj 23

select *,
(select ExitCategory from exitcustomer
 where ExitID=b.Exited) as ExitCategory
 from bank_churn b;
 
 -- obj 25
 select c.customerid,
        surname as last_Name,
       ActiveCategory
 from customerinfo c
 join bank_churn b on c.customerid=b.customerid
 join activecustomer a on  b.IsActiveMember=a.ActiveID
 where surname like '%on';
 
--  subjective 9
select 
GeographyLocation,
GenderCategory,
case  
       when age between 18 and 30 then '18-30'
       when age between 30 and 50 then '30-50'
       else
       '50+'
       end as AgeSegment,
round(avg(estimatedsalary),2) AvgEstimatedSalary,
round(avg(balance),2) as AvgBalance,
avg(creditscore)as AvgcreditScore
       from customerinfo c
       join geography g on c.GeographyID=g.GeographyID
       join gender ge on c.genderid=ge.GenderID
       join bank_churn b on c.customerid=b.customerid
  group by Agesegment,GeographyLocation,GenderCategory
  order by AgeSegment;
  
--   subj 14
select hascrcard as Has_creditcard from (
select * from bank_churn) as res