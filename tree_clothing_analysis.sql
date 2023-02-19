--High Level Sales Analysis

--1. What was the total quantity sold for all products?

select SUM(qty) as total_all_product_sold
from clothing_sales;
--> 45.216


--2. What is the total generated revenue for all products before discounts?

select sum(qty*price) as total_revenue_before_discounts
from clothing_sales;
-->1.289.453


--3. What was the total discount amount for all products?

select sum(qty*(discount/100.0 * price)) as total_discount_amount
from clothing_sales;
--> 156.229,14


--Transaction Analysis

--1. How many unique transactions were there?
-- choose one between this two:

	--1. display each trx and its count
select distinct txn_id, COUNT(txn_id) as unique_trx
from clothing_sales
group by txn_id
order by COUNT(txn_id) desc;

	--2. display only total 
select count(distinct txn_id) as unique_trx
from clothing_sales;
--> 2.500 unique trx


--2. What is the average unique products purchased in each transaction?

with satu as (select txn_id, COUNT(distinct prod_id) as count_unique_product
from clothing_sales
group by txn_id)

select AVG(count_unique_product) as avg_count_unique_product
from satu;
--> 6


--3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

with satu as (select txn_id, sum(qty * (price-(discount*price/100.0))) as revenue_per_trx
from clothing_sales
group by txn_id)

select distinct PERCENTILE_disc(0.25) within group (order by revenue_per_trx) over() as percentile_25th,
PERCENTILE_disc(0.5) within group (order by revenue_per_trx) over() as percentile_50th, 
PERCENTILE_disc(0.75) within group (order by revenue_per_trx) over() as percentile_75th
from satu;
--> 25th: 326,18
--> 50th: 441,00
--> 75th: 572,75


--4. What is the average discount value per transaction?

select txn_id, AVG(discount) as avg_discount_per_trx
from clothing_sales
group by txn_id
order by AVG(discount) desc;


--5. What is the percentage split of all transactions for members vs non-members?

with member as (select COUNT(distinct txn_id) as member
from clothing_sales
where member = 't'),

non_member as (select COUNT(distinct txn_id) as non_member
from clothing_sales
where member = 'f'),

altogether as (select COUNT(distinct txn_id) as member
from clothing_sales
)

select (select * from member) * 100.0 / (select * from altogether) as pct_member, (select * from non_member) * 100.0 / (select * from altogether) as pct_non_member;

--> member 60,2%
--> non_member 39,8%


--6. What is the average revenue for member transactions and non-member transactions?

with satu as (select *, qty * (price*(1-(discount/100.0))) as rev
from clothing_sales),

member as (select member, AVG(rev) as avg_rev_member from satu where member = 't' group by member), 

non_member as (select member, AVG(rev) as avg_rev_non_member from satu where member = 'f' group by member)

select avg_rev_member, avg_rev_non_member
from member, non_member;



--Product Analysis

--1. What are the top 3 products by total revenue before discount?

select top 3 s.prod_id, 
				pd.product_name, 
				sum(s.qty*s.price) as total_revenue_before_discount
from clothing_sales s
join clothing_product_details pd
on s.prod_id = pd.product_id
group by s.prod_id, pd.product_name
order by sum(s.qty*s.price) desc;


--2. What is the total quantity, revenue and discount for each segment?

with satu as (select pd.segment_name, 
				s.qty, 
				s.price, 
				s.discount
from clothing_sales s
join clothing_product_details pd
on s.prod_id = pd.product_id)

select segment_name, SUM(qty) as total_quantity, 
		SUM(qty*price) as total_revenue_before_disc, -- before discount
		SUM(qty*price*(1-(discount/100.0))) as total_revenue_after_disc,  -- after discount
		SUM(qty*price*(discount/100.0)) as total_discount
from satu
group by segment_name;



--3. What is the top selling product for each segment?

with satu as (select pd.segment_name, 
				pd.product_name, 
				sum(s.qty) as total_selling
from clothing_sales s
join clothing_product_details pd
on s.prod_id = pd.product_id
group by pd.segment_name, pd.product_name),

dua as (select *, RANK() over(partition by segment_name order by total_selling desc) as rn
from satu)

select segment_name, product_name, total_selling
from dua
where rn = 1;


--4. What is the total quantity, revenue and discount for each category?

select pd.category_name, 
		sum(s.qty) as total_quantity, 
		sum(s.qty*s.price) as total_revenue_before_discount, 
		SUM(s.qty*s.price*(1-(s.discount/100.0))) as total_revenue_after_disc,
		SUM(s.qty*s.price*(s.discount/100.0)) as total_discount
from clothing_sales s
join clothing_product_details pd
on s.prod_id = pd.product_id
group by pd.category_name;



--5. What is the top selling product for each category?

with satu as (select pd.category_name, 
				pd.product_name, 
				sum(s.qty) as total_selling
from clothing_sales s
join clothing_product_details pd
on s.prod_id = pd.product_id
group by pd.category_name, pd.product_name),

dua as (select *, RANK() over(partition by category_name order by total_selling desc) as rn
from satu)

select category_name, product_name, total_selling
from dua
where rn = 1;



--6. What is the percentage split of revenue by product for each segment?

with satu as (select pd.segment_name, 
		pd.product_name, 
		sum(s.qty*s.price) as total_revenue_before_discount, 
		SUM(s.qty*s.price*(1-(s.discount/100.0))) as total_revenue_after_disc		
from clothing_sales s
join clothing_product_details pd
on s.prod_id = pd.product_id
group by pd.segment_name, pd.product_name)

select segment_name, 
		product_name, 
		total_revenue_before_discount, 
		round(total_revenue_before_discount * 100.0 / SUM(total_revenue_before_discount) over(partition by segment_name), 0) as pct_before_disc,
		total_revenue_after_disc,
		round(total_revenue_after_disc * 100.0 / SUM(total_revenue_after_disc) over(partition by segment_name), 0) as pct_after_disc
from satu;


--7. What is the percentage split of revenue by segment for each category?

with satu as (select pd.category_name,
		pd.segment_name, 
		sum(s.qty*s.price) as total_revenue_before_discount, 
		SUM(s.qty*s.price*(1-(s.discount/100.0))) as total_revenue_after_disc		
from clothing_sales s
join clothing_product_details pd
on s.prod_id = pd.product_id
group by pd.category_name, pd.segment_name)

select category_name, 
		segment_name, 
		total_revenue_before_discount, 
		round(total_revenue_before_discount * 100.0 / SUM(total_revenue_before_discount) over(partition by category_name), 0) as pct_before_disc,
		total_revenue_after_disc,
		round(total_revenue_after_disc * 100.0 / SUM(total_revenue_after_disc) over(partition by category_name), 0) as pct_after_disc
from satu;


--8. What is the percentage split of total revenue by category?

with satu as (select pd.category_name,
		sum(s.qty*s.price) as total_revenue_before_discount, 
		SUM(s.qty*s.price*(1-(s.discount/100.0))) as total_revenue_after_disc		
from clothing_sales s
join clothing_product_details pd
on s.prod_id = pd.product_id
group by pd.category_name), 

dua as (select SUM(total_revenue_before_discount) as total_before
from satu), 

tiga as (select SUM(total_revenue_after_disc) as total_after
from satu)

select category_name, 
		total_revenue_before_discount, 
		round(total_revenue_before_discount * 100.0/ (select total_before from dua), 0) as pct_revenue_before_disc,
		total_revenue_after_disc,
		round(total_revenue_after_disc * 100.0 / (select total_after from tiga), 0) as pct_revenue_after_disc
from satu;
		


-- 9. What is the total transaction “penetration” for each product? 
-- (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

with satu as (select txn_id, prod_id, qty		
from clothing_sales),

dua as (select prod_id, COUNT(distinct txn_id) as number_of_trx
from satu
group by prod_id),

tiga as (select prod_id, COUNT(distinct txn_id) as number_of_1_qty
from satu
where qty = 1
group by prod_id)

select t.prod_id, 
		t.number_of_1_qty, 
		d.number_of_trx,
		round(t.number_of_1_qty * 1.0 / d.number_of_trx, 2) as penetration
from tiga t
join dua d
on t.prod_id = d.prod_id;



--10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

with satu as (select prod_id, qty, txn_id
from clothing_sales
where txn_id in (select distinct txn_id from clothing_sales where qty = 1)),

dua as (select s1.prod_id as prod_id_1, 
		s2.prod_id as prod_id_2, 
		s3.prod_id as prod_id_3, 
		CONCAT(s1.prod_id, ' - ', s2.prod_id, ' - ', s3.prod_id) as mix
from satu s1
join satu s2 on s1.prod_id < s2.prod_id and s1.txn_id = s2.txn_id
join satu s3 on s2.prod_id < s3.prod_id and s2.txn_id = s3.txn_id
where s1.qty = 1 and s2.qty > 1 and s3.qty > 1)


select prod_id_1, 
		prod_id_2, 
		prod_id_3, 
		mix, 
		COUNT(mix) as cnt_common
from dua
group by prod_id_1,	prod_id_2, prod_id_3, mix
order by COUNT(mix) desc;




