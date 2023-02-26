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
      <pre>
      select SUM(qty) as total_all_product_sold
      from clothing_sales;
      </pre>
      <img src="https://github.com/mas-tono/clothing-company/blob/main/image/1.%20total%20quantity%20sold%20for%20all%20products.jpg">
      </details>
      
      2. What is the total generated revenue for all products before discounts?
      3. What was the total discount amount for all products?


    2. Transaction Analysis
      1. How many unique transactions were there?
      2. What is the average unique products purchased in each transaction?
      3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
      4. What is the average discount value per transaction?
      5. What is the percentage split of all transactions for members vs non-members? 
      6. What is the average revenue for member transactions and non-member transactions?


    3. Product Analysis
      1. What are the top 3 products by total revenue before discount?
      2. What is the total quantity, revenue and discount for each segment?
      3. What is the top selling product for each segment?
      4. What is the total quantity, revenue and discount for each category?
      5. What is the top selling product for each category?
      6. What is the percentage split of revenue by product for each segment?
      7. What is the percentage split of revenue by segment for each category?
      8. What is the percentage split of total revenue by category?
      9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
      10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
