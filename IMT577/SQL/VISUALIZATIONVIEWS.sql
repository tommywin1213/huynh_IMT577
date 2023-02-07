--Create PROD View for Tableau Visualization
--Roll Count - 187k without filter - PASS
--No Duplicate - add Distinct - PASS
create or replace secure view View_FinalVisualization as
select distinct
    sa.salesheaderid
    ,sa.salesdetailid
    ,d.date_pkey
    ,s.storeid
    ,s.storenumber
    ,d.year
    ,d.day_name
    ,p.product_id
    ,p.product_type
    ,p.product_category
    ,p.product_name
    ,l.stateprovince
    ,p.product_retail_price
    ,p.product_cost
    ,p.product_wholesale_price
    ,sa.salesamount
    ,sa.salesquantity
    ,pt.producttargetsalesquantity
    ,st.SALESTARGETAMOUNT
from
    fact_salesactual sa
    left join dim_product p
    on sa.dimproductid = p.product_id
    left join dim_store s
    on s.dimstoreid = sa.dimstoreid
    left join dim_location l
    on l.dimlocationid = s.locationid
    left join dim_date d
    on d.date_pkey = sa.dimsalesdateid
    left join dim_channel c
    on c.dimchannelid = sa.dimchannelid
    left join fact_productsalestarget pt
    on pt.dimproductid = p.product_id and pt.target_dateid = d.date_pkey
    left join fact_srcsalestarget st
    on st.dimstoreid = s.dimstoreid and st.target_dateid = d.date_pkey and st.dimchannelid = c.dimchannelid
    where storeid is not null
;
--Validation: 
--Daily Sales - PASS
use warehouse IMT577_DW_TOMMY_HUYNH

select distinct day_name,product_category,  sum(salesamount)
from
IMT577_DW_TOMMY_HUYNH.PUBLIC.VIEW_FINALVISUALIZATION
group by 1,2;

--# of Stores by Provinces - PASS
select distinct stateprovince, count(distinct storenumber), sum(salesamount)
from
IMT577_DW_TOMMY_HUYNH.PUBLIC.VIEW_FINALVISUALIZATION
group by 1;

--Target Sales by store by year - Mismatch
select storeid,storenumber, year, max(SALESTARGETAMOUNT)
from
IMT577_DW_TOMMY_HUYNH.PUBLIC.VIEW_FINALVISUALIZATION
group by 1,2,3
;