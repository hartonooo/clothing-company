# clothing-company
analyzing clothing company business performance

using MS. SQL SERVER STUDIO

SQL project/case study from: https://8weeksqlchallenge.com/case-study-7/

steps:
  1. import all csv files into SQL SERVER
  2. data checking -> clean
      <details>
      <summary>table</summary>
      <img src="https://github.com/mas-tono/clothing-company/blob/main/image/1.%20table.jpg">
      </details>

  3. analysis:
  
      1. High Level Sales Analysis    
        
          1. What was the total quantity sold for all products?      
              <details>
              <summary>total quantity sold for all products</summary>
              <pre>select SUM(qty) as total_all_product_sold
              from clothing_sales;</pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/1.1%20total%20quantity%20sold%20for%20all%20products.jpg">
              </details>

          2. What is the total generated revenue for all products before discounts?
              <details>
              <summary>total revenue for all products before discounts</summary>
              <pre>sselect sum(qty*price) as total_revenue_before_discounts
              from clothing_sales;
              </pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/1.2.%20total%20revenue%20for%20all%20products%20before%20discounts.jpg">
              </details>
                            
          3. What was the total discount amount for all products?
              <details>
              <summary>total discount amount for all products</summary>
              <pre>
              select sum(qty*(discount/100.0 * price)) as total_discount_amount
              from clothing_sales;
              </pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/1.3%20total%20discount%20amount%20for%20all%20products.jpg">
              </details>
   
      2. Transaction Analysis
    
          1. How many unique transactions were there?
              <details>
              <summary>amount of unique transactions</summary>
              <pre>
              select count(distinct txn_id) as unique_trx
              from clothing_sales;
              </pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/2.1%20amount%20of%20unique%20transactions.jpg">
              </details>
             
          2. What is the average unique products purchased in each transaction?
              <details>
              <summary>average unique products purchased in each transaction</summary>
              <pre>
              with satu as (select txn_id, COUNT(distinct prod_id) as count_unique_product
              from clothing_sales
              group by txn_id)</br>
              select AVG(count_unique_product) as avg_count_unique_product
              from satu;
              </pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/2.2%20average%20unique%20products%20purchased%20in%20each%20transaction.jpg">
              </details>
          
          
          3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
              <details>
              <summary>25th, 50th and 75th percentile values for the revenue per transaction</summary>
              <pre>
              with satu as (select txn_id, sum(qty * (price-(discount*price/100.0))) as revenue_per_trx
              from clothing_sales
              group by txn_id)</br>
              select distinct PERCENTILE_disc(0.25) within group (order by revenue_per_trx) over() as percentile_25th,
              PERCENTILE_disc(0.5) within group (order by revenue_per_trx) over() as percentile_50th, 
              PERCENTILE_disc(0.75) within group (order by revenue_per_trx) over() as percentile_75th
              from satu;
              </pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/2.3%2025th%2C%2050th%20and%2075th%20percentile%20values%20for%20the%20revenue%20per%20transaction.jpg">
              </details>
         
         
          4. What is the average discount value per transaction?
              <details>
              <summary>average discount value per transaction</summary>
              <pre>
              select txn_id, 
                AVG(discount) as avg_discount_per_trx
              from clothing_sales
              group by txn_id
              order by AVG(discount) desc;
              </pre>
              <p>vary from 0 to 24 percent</p>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/2.4%20average%20discount%20value%20per%20transaction.jpg">
              </details>
          
         
          5. What is the percentage split of all transactions for members vs non-members? 
              <details>
              <summary>percentage split of all transactions for members vs non-members</summary>
              <pre>
              with member as (select COUNT(distinct txn_id) as member
                from clothing_sales
                where member = 't'),</br>
              non_member as (select COUNT(distinct txn_id) as non_member
                from clothing_sales
                where member = 'f'),</br>
              altogether as (select COUNT(distinct txn_id) as member
                from clothing_sales
              )</br>
              select (select * from member) * 100.0 / (select * from altogether) as pct_member, (select * from non_member) * 100.0 / (select * from altogether) as pct_non_member;
              </pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/2.5%20percentage%20split%20of%20all%20transactions%20for%20members%20vs%20non-members.jpg">
              </details>
         
         
          6. What is the average revenue for member transactions and non-member transactions?
              <details>
              <summary>average revenue for member transactions and non-member transactions</summary>
              <pre>
              with satu as (select *, qty * (price*(1-(discount/100.0))) as rev
                from clothing_sales),</br>
              member as (select member, AVG(rev) as avg_rev_member from satu where member = 't' group by member),</br>
              non_member as (select member, AVG(rev) as avg_rev_non_member from satu where member = 'f' group by member)</br>
              select avg_rev_member, avg_rev_non_member
              from member, non_member;
              </pre>
              <p>calculate after discount</p>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/2.6%20average%20revenue%20for%20member%20transactions%20and%20non-member%20transactions.jpg">
              </details>


      3. Product Analysis
    
          1. What are the top 3 products by total revenue before discount?          
              <details>
              <summary>top 3 products by total revenue before discount</summary>
              <pre>
              select top 3 s.prod_id, 
                pd.product_name, 
                sum(s.qty*s.price) as total_revenue_before_discount
              from clothing_sales s
              join clothing_product_details pd
              on s.prod_id = pd.product_id
              group by s.prod_id, pd.product_name
              order by sum(s.qty*s.price) desc;
              </pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/3.1%20top%203%20products%20by%20total%20revenue%20before%20discount.jpg">
              </details>             
          
          
          2. What is the total quantity, revenue and discount for each segment?
              <details>
              <summary>total quantity, revenue and discount for each segment</summary>
              <pre>
              with satu as (select pd.segment_name, 
                      s.qty, 
                      s.price, 
                      s.discount
              from clothing_sales s
              join clothing_product_details pd
              on s.prod_id = pd.product_id)</br>
              select segment_name, SUM(qty) as total_quantity, 
                  SUM(qty*price) as total_revenue_before_disc, -- before discount
                  SUM(qty*price*(1-(discount/100.0))) as total_revenue_after_disc,  -- after discount
                  SUM(qty*price*(discount/100.0)) as total_discount
              from satu
              group by segment_name;
              </pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/3.2%20total%20quantity%2C%20revenue%20and%20discount%20for%20each%20segment.jpg">
              </details>  
         
         
          3. What is the top selling product for each segment?
              <details>
              <summary>top selling product for each segment</summary>
              <pre>
              with satu as (select pd.segment_name, 
                  pd.product_name, 
                  sum(s.qty) as total_selling
              from clothing_sales s
              join clothing_product_details pd
              on s.prod_id = pd.product_id
              group by pd.segment_name, pd.product_name),</br>
              dua as (select *, RANK() over(partition by segment_name order by total_selling desc) as rn
              from satu)</br>
              select segment_name, product_name, total_selling
              from dua
              where rn = 1;
              </pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/3.3%20top%20selling%20product%20for%20each%20segment.jpg">
              </details>  
          
          
          4. What is the total quantity, revenue and discount for each category?
              <details>
              <summary>total quantity, revenue and discount for each category</summary>
              <pre>
              select pd.category_name, 
                  sum(s.qty) as total_quantity, 
                  sum(s.qty*s.price) as total_revenue_before_discount, 
                  SUM(s.qty*s.price*(1-(s.discount/100.0))) as total_revenue_after_disc,
                  SUM(s.qty*s.price*(s.discount/100.0)) as total_discount
              from clothing_sales s
              join clothing_product_details pd
              on s.prod_id = pd.product_id
              group by pd.category_name;
              </pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/3.4%20total%20quantity%2C%20revenue%20and%20discount%20for%20each%20category.jpg">
              </details>  
          
          
          5. What is the top selling product for each category?
              <details>
              <summary>top selling product for each category</summary>
              <pre>
              with satu as (select pd.category_name, 
                      pd.product_name, 
                      sum(s.qty) as total_selling
              from clothing_sales s
              join clothing_product_details pd
              on s.prod_id = pd.product_id
              group by pd.category_name, pd.product_name),</br>
              dua as (select *, RANK() over(partition by category_name order by total_selling desc) as rn
              from satu)</br>
              select category_name, product_name, total_selling
              from dua
              where rn = 1;
              </pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/3.5%20top%20selling%20product%20for%20each%20category.jpg">
              </details>  
          
          
          6. What is the percentage split of revenue by product for each segment?
              <details>
              <summary>percentage split of revenue by product for each segment</summary>
              <pre>
              with satu as (select pd.segment_name, 
                  pd.product_name, 
                  sum(s.qty*s.price) as total_revenue_before_discount, 
                  SUM(s.qty*s.price*(1-(s.discount/100.0))) as total_revenue_after_disc		
              from clothing_sales s
              join clothing_product_details pd
              on s.prod_id = pd.product_id
              group by pd.segment_name, pd.product_name)</br>
              select segment_name, 
                  product_name, 
                  total_revenue_before_discount, 
                  round(total_revenue_before_discount * 100.0 / SUM(total_revenue_before_discount) over(partition by segment_name), 0) as pct_before_disc,
                  total_revenue_after_disc,
                  round(total_revenue_after_disc * 100.0 / SUM(total_revenue_after_disc) over(partition by segment_name), 0) as pct_after_disc
              from satu;
              </pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/3.6%20percentage%20split%20of%20revenue%20by%20product%20for%20each%20segment.jpg">
              </details> 
          
          
          7. What is the percentage split of revenue by segment for each category?
              <details>
              <summary>percentage split of revenue by segment for each category</summary>
              <pre>
              with satu as (select pd.category_name,
                  pd.segment_name, 
                  sum(s.qty*s.price) as total_revenue_before_discount, 
                  SUM(s.qty*s.price*(1-(s.discount/100.0))) as total_revenue_after_disc		
              from clothing_sales s
              join clothing_product_details pd
              on s.prod_id = pd.product_id
              group by pd.category_name, pd.segment_name)</br>
              select category_name, 
                  segment_name, 
                  total_revenue_before_discount, 
                  round(total_revenue_before_discount * 100.0 / SUM(total_revenue_before_discount) over(partition by category_name), 0) as pct_before_disc,
                  total_revenue_after_disc,
                  round(total_revenue_after_disc * 100.0 / SUM(total_revenue_after_disc) over(partition by category_name), 0) as pct_after_disc
              from satu;
              </pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/3.7%20percentage%20split%20of%20revenue%20by%20segment%20for%20each%20category.jpg">
              </details> 
          
          
          8. What is the percentage split of total revenue by category?
              <details>
              <summary>percentage split of total revenue by category</summary>
              <pre>
              with satu as (select pd.category_name,
                  sum(s.qty*s.price) as total_revenue_before_discount, 
                  SUM(s.qty*s.price*(1-(s.discount/100.0))) as total_revenue_after_disc		
              from clothing_sales s
              join clothing_product_details pd
              on s.prod_id = pd.product_id
              group by pd.category_name),</br>
              dua as (select SUM(total_revenue_before_discount) as total_before
              from satu),</br>
              tiga as (select SUM(total_revenue_after_disc) as total_after
              from satu)</br>
              select category_name, 
                  total_revenue_before_discount, 
                  round(total_revenue_before_discount * 100.0/ (select total_before from dua), 0) as pct_revenue_before_disc,
                  total_revenue_after_disc,
                  round(total_revenue_after_disc * 100.0 / (select total_after from tiga), 0) as pct_revenue_after_disc
              from satu;
              </pre>
              <img src="https://github.com/mas-tono/clothing-company/blob/main/image/3.8%20percentage%20split%20of%20total%20revenue%20by%20category.jpg">
              </details> 
          
          
          9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
          
          
          
          10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
