-- 1.Merging the 6 datasets
CREATE TABLE public."Sales Data" as
select * from public."Sales Canada"
UNION ALL
SELECT * FROM public."Sales China"
Union all
SELECT * FROM public."Sales India"
Union all
SELECT * FROM public."Sales Nigeria"
Union all
SELECT * FROM public."Sales UK"
Union all
SELECT * FROM public."Sales US"

-- 2.Checking for missing values
select * 
from public."Sales Data"
where
    "Country" is null
	or "Price Per Unit" is null
	or "Quantity Purchased" is null
	or "Cost Price" is null
	or "Discount Applied" is null;

-- 3.Updating “Quantity Purchased”
update public."Sales Data"
set "Quantity Purchased" = 3
where "Transaction ID" = '00a30472-89a0-4688-9d33-67ea8ccf7aea'

-- 4.Updating “Price Per Unit”
update public."Sales Data"
set "Price Per Unit" = (
    SELECT AVG("Price Per Unit")
	from public."Sales Data"
	where "Price Per Unit" is not null
)
where "Transaction ID" = '001898f7-b696-4356-91dc-8f2b73d09c63';


-- 5.Checking for duplicate values and removing dupliactes values
select "Transaction ID", Count(*)
from public."Sales Data"
group by "Transaction ID"
having count(*)>1;

WITH RemovedDuplicates AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY "Transaction ID" ORDER BY "Transaction ID") AS rn
    FROM public."Sales Data"
)
SELECT *
FROM RemovedDuplicates
WHERE rn = 1;


-- 6.Adding “Total Amount” column
Alter table public."Sales Data" add
column"Total Amount" Numeric(10,2);

update public."Sales Data"
set "Total Amount"=("Price Per Unit" * "Quantity Purchased") - "Discount Applied";


-- 7.Adding “Profit” column
alter table public."Sales Data" add
column "Profit" Numeric(10,2);

update public."Sales Data"
set "Profit"="Total Amount" - ("Cost Price" + "Quantity Purchased");


-- 8.Sales Revenue & Profit by Country (Combined Query)
SELECT 
    "Country", 
    SUM("Total Amount") AS "Total Revenue",
    SUM("Profit") AS "Total Profit"
FROM public."Sales Data"
WHERE "Date" BETWEEN '2025-02-10' AND '2025-02-14'
GROUP BY "Country"
ORDER BY "Total Revenue" DESC;

-- 9.Top 5 Best-Selling Products (During the Period)
SELECT 
    "Product Name", 
    SUM("Quantity Purchased") AS "Total Units Sold"
FROM public."Sales Data"
WHERE "Date" BETWEEN '2025-02-10' AND '2025-02-14'
GROUP BY "Product Name"
ORDER BY "Total Units Sold" DESC
LIMIT 5;


-- 10.Best Sales Representatives (During the Period)
SELECT 
    "Sales Representative", 
    SUM("Total Amount") AS "Total Sales"
FROM public."Sales Data"
WHERE "Date" BETWEEN '2025-02-10' AND '2025-02-14'
GROUP BY "Sales Representative"
ORDER BY "Total Sales" DESC
LIMIT 5;

-- 11.Which store locations generated the highest sales?
SELECT 
    "Store Location", 
    SUM("Total Amount") AS "Total Sales",
    SUM("Profit") AS "Total Profit"
FROM public."Sales Data"
WHERE "Date" BETWEEN '2025-02-10' AND '2025-02-14'
GROUP BY "Store Location"
ORDER BY "Total Sales" DESC
limit 5;

-- 12.What are the key sales and profit insights for the selected period?
SELECT 
    MIN("Total Amount") AS "Min Sales Value",
    MAX("Total Amount") AS "Max Sales Value",
    AVG("Total Amount") AS "Avg Sales Value",
    SUM("Total Amount") AS "Total Sales Value",
    MIN("Profit") AS "Min Profit",
    MAX("Profit") AS "Max Profit",
    AVG("Profit") AS "Avg Profit",
    SUM("Profit") AS "Total Profit"
FROM public."Sales Data"
WHERE "Date" BETWEEN '2025-02-10' AND '2025-02-14';
