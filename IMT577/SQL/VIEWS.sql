--overall assessment of stores number 5 and 8’s sales
--Q1:* How are they performing compared to target? Will they meet their 2021 target?
create or replace secure view IMT577_DW_TOMMY_HUYNH.PUBLIC.VIEW_ANNUALSTORETARGET as 
select distinct a.storeid
    ,a.storenumber
    ,c.year
    ,ch.channelname
    ,sum(b.salestargetamount) target_amount
from dim_store a
left join fact_srcsalestarget b
on a.dimstoreid=b.dimstoreid
--join DimDate to get the Year info
 left join dim_date c
 on c.date_pkey = b.target_dateid
 left join dim_channel ch
 on ch.dimchannelid = b.dimchannelid
 --Select only Store 5 and Store 8 info
 where storenumber = 5 or storenumber = 8
 --Group by Year
 group by 1,2,3,4
 order by c.year
 ;

 --Q2:* Recommend separate 2020 and 2021 bonus amounts for each store if the total bonus pool for 2020 is $500,000 and the total bonus pool for 2021 is $400,000. 
create or replace secure view View_TargetvsActualSales comment='total sales amount vs total target sales' as 
 select distinct
    S.STORENUMBER
    ,S.DIMSTOREID
    ,D.YEAR
    ,sum(sa.salesamount) sales_amount
    ,sum(ST.SALESTARGETAMOUNT) sales_target
 from DIM_STORE S
 left join FACT_SALESACTUAL SA
 on S.DIMSTOREID = SA.DIMSTOREID
 left join FACT_SRCSALESTARGET ST
 on S.DIMSTOREID = ST.DIMSTOREID
 left join DIM_DATE D 
 on D.DATE_PKEY = ST.TARGET_DATEID
group by
D.year
    ,S.STORENUMBER
    ,S.DIMSTOREID
 ;
 
 --Q3:*  Assess product sales by day of the week at stores 5 and 8. dim_date day name of week, dim_product productID productname, fact_salesactual salesamount salesquantity, 

create or replace secure view View_DayNumProductSalesTrend comment='Product Sales Trend by Week' as 
select distinct 
d.day_num_in_week
,p.product_id
,p.product_type
,p.product_name
,sum(sa.salesamount) sales_amount
,sum(sa.salesquantity) sales_quantity
from dim_product p 
left join fact_salesactual sa
on p.dimproductid = sa.dimproductid
left join dim_date d
on d.date_pkey = sa.dimsalesdateid
group by
d.day_num_in_week
,p.product_id
,p.product_name
,p.product_type
;

 --Q4:*  Compare the performance of all stores located in states that have more than one store to all stores that are the only store in the state. 
create or replace secure view View_Product_Target_Sales comment='Product Target Sales by Store by Channel' as 
 select distinct 
     s.storeid
    ,s.storenumber
    ,p.product_id
    ,p.product_type
    ,p.product_category
    ,l.stateprovince
    ,l.country
    ,d.year
    ,sum(sa.salesamount) product_sales_amount
    ,sum(sa.salesquantity) product_sales_quantity
from dim_store s
    left join FACT_SALESACTUAL sa
    on sa.dimstoreid = s.dimstoreid
    left join DIM_PRODUCT P
    on p.dimproductid = sa.dimproductid 
    left join dim_date d
    on d.date_pkey = sa.dimsalesdateid
    left join dim_location l
    on l.dimlocationid = s.locationid
    left join fact_srcsalestarget st
    on st.dimstoreid = s.storeid
group by 1,2,3,4,5,6,7,8
;
 
 