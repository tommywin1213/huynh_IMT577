CREATE OR REPLACE TABLE Fact_ProductSalestarget (
    DimProductID INTEGER CONSTRAINT FK_DimProductlD FOREIGN KEY REFERENCES Dim_Product(DIMPRODUCTID), 
	Target_DATEID NUMBER(9) CONSTRAINT FK_DATE_PKEY FOREIGN KEY REFERENCES Dim_Date(DATE_PKEY),
    ProductTargetSalesQuantity FLOAT
);

INSERT INTO Fact_ProductSalestarget
	(
		DimProductID,
		Target_DATEID,
		ProductTargetSalesQuantity
	)
	SELECT DISTINCT   
		 p.dimproductid as DimProductID,
         d.date_pkey as Target_DATEID,
         td.SALESQUANTITYTARGET as ProductTargetSalesQuantity
	FROM dim_product p
    inner join TAGETDATA_PRODUCT td
    on td.productid = p.dimproductid
    inner join dim_date d
    on d.year = td.year;

SELECT * from Fact_ProductSalestarget;

--Fact_SRCSalesTarget
CREATE OR REPLACE TABLE Fact_SRCSalesTarget (
    DimStoreID INTEGER CONSTRAINT FK_DimStoreID FOREIGN KEY REFERENCES Dim_Store(DimStoreID), 
    DimChannelID INTEGER CONSTRAINT FK_DimChannelID FOREIGN KEY REFERENCES Dim_Channel(DimChannelID),
	Target_DATEID NUMBER(9) CONSTRAINT FK_DATE_PKEY FOREIGN KEY REFERENCES Dim_Date(DATE_PKEY) ,
    DimResellerID Varchar(255) CONSTRAINT FK_DimResellerID FOREIGN KEY REFERENCES Dim_Reseller(DimResellerID),
    SalesTargetAmount Float
);

--Load Data
INSERT INTO Fact_SRCSalesTarget
	(
		DimStoreID,
		DimChannelID,
        DimRESELLERID,
		Target_DATEID,
        SalesTargetAmount
	)
	SELECT DISTINCT    
        DIMSTOREID,
        dimchannelid,
        NVL(sh.resellerid, -1) as ResellerID,
        d.Date_pkey,
        rs.targetsalesamount
    from tagetdata_channel_reseller_store rs
    INNER JOIN Dim_Channel dimChannel
    ON dimChannel.ChannelName = CASE WHEN rs.ChannelName = 'Online' THEN 'On-line' ELSE    rs.ChannelName END
    inner join dim_date d
    on d.year = rs.year
    inner join dim_store s

    on s.storenumber = case WHEN rs.targetname  = 'Store Number 5' THEN 5
    when rs.targetName = 'Store Number 8' then 8 else null END
    
    left join sales_header sh
    on sh.channelid = dimchannel.dimchannelid and sh.storeid = s.storeid
    ;
    
--Fact_SalesActual
CREATE OR REPLACE TABLE Fact_SalesActual (
    DimProductID INTEGER CONSTRAINT FK_DimProductlD FOREIGN KEY REFERENCES Dim_Product(DIMPRODUCTID),
    DimStoreID INTEGER CONSTRAINT FK_DimStoreID FOREIGN KEY REFERENCES Dim_Store(DimStoreID),
    DimResellerID Varchar(255) CONSTRAINT FK_DimResellerID FOREIGN KEY REFERENCES Dim_Reseller(DimResellerID),
    DimCustomerID Varchar(255) CONSTRAINT FK_DimCustomerID FOREIGN KEY REFERENCES Dim_Customer(DimCustomerID),
    DimChannelID INTEGER CONSTRAINT FK_DimChannelID FOREIGN KEY REFERENCES Dim_Channel(DimChannelID),
	DimSalesDateID NUMBER(9) CONSTRAINT FK_DimSalesDateID FOREIGN KEY REFERENCES Dim_Date(DATE_PKEY),
    DimLocationID INTEGER CONSTRAINT FK_DimLocationID FOREIGN KEY REFERENCES Dim_Location(DimLocationID),
    SalesHeaderID INTEGER,
    SalesDetailID INTEGER,
    SalesAmount Float,
    SalesQuantity Integer
);

INSERT INTO Fact_SalesActual
	(
		DimProductID,
        DIMSTOREID,
        DIMRESELLERID,
        DIMCUSTOMERID,
        DIMCHANNELID,
        DIMSALESDATEID,
        DIMLOCATIONID,
        SALESHEADERID,
        SALESDETAILID,
        SALESAMOUNT,
        SALESQUANTITY
	)
    
SELECT DISTINCT    
       sd.PRODUCTID as DimProductID,
       sh.storeid as DIMSTOREID,
       NVL(sh.resellerid,'Unknown') as DIMRESELLERID,
       NVL(sh.customerid, 'Unknown') as DIMCUSTOMERID,
       sh.channelid as DIMCHANNELID,
       d.Date_pkey as DIMSALESDATEID,
       sd.SALESHEADERID as SALESHEADERID,
       sd.SALESDETAILID as SALESDETAILID,
       l.dimlocationid as DIMLOCATIONID,
       sd.salesamount as SALESAMOUNT,
       sd.SALESQUANTITY as SALESQUANTITY   
    from sales_details sd
    inner join sales_header sh
    on sh.salesheaderid = sd.salesheaderid
    inner join dim_date d 
    on d.date = replace(sh.DATE,'00','20')
    inner join store s
    on s.storeid = sh.storeid
    inner join dim_location l
    on l.address = s.address
    where sh.storeid is not null
    ;
    
SELECT * FROM FACT_SALESACTUAL
