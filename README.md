# 1. BUSINESS PERFORMANCE ANALYSIS
  This project attempts to analyze ZT business performance. The staging dataset contains information about customers demographics, geographic locations (including town, city and state where customers resides), order trends, payment methods, revenue and cost, and order status.
  
  # 2. Business Problems
  1. Limited understanding of customer demographics
  2. Uneven geographic distribution of customers
  3. Limited visibility of geographic revenue, cost and profitability
  4. Inadequate understanding of order performance
  5. Limited insights about payment preference
  6. Lack of integrated and reliable business performance reporting
  7. Inadequate information about sales trends

  # 3. Aim and Objectives 
  The main aim of this project is analyze customer demographics, purchasing patterns, customer geographic distribution and business performance using SQL and Power BI to generate actionable insights that support customer focused marketing, revenue growth and to improve business decision-making at ZT company. The specific objectives are to:
  1. Asses the company's overall financial performance
  2. Evaluate the geographic distribution of customers
  3. Examine the customer demographics characteristics and their purchasing pattern
  4. Evaluate business revenue and profitability across geographic locations
  5. Analyze customers payment preference
  6. Examine order performance
  7. Analyze sales performance over time
  8. Identify geographic areas with high customer concentrations but relatively low revenue or profit per customer
  9. Develop an interactive Power BI dashboard

# 4. Analysis Workflow
CSV file
     ↓
Staging dataset table
     ↓
Initial data inspection profiling / cleaning (Excel)
     ↓
Identify entities + dependencies
     ↓
Create surrogate PKs (Microsoft SQL server)
     ↓
Populate normalized tables (Microsoft SQL server)
     ↓
Add PK/FK constraints (Microsoft SQL server)
     ↓
Validate 1NF → 2NF → 3NF (Microsoft SQL server)
     ↓
Create ERD (Microsoft SQL server)
     ↓
Power BI connects to normalized database
     ↓
Power BI dashboard (Power BI)

# 5. Findings 
1. Overall Business Performance: ZT company has a total of 9,430 customers, with Total revenue of $1.5m, total cost of $229,200.00, and total profit of $1.2m.
2. Relationship between Customers Count and Profit per Customer: The observation on the scattered plot chart follows an upward pattern suggesting that geographic areas with larger customers bases tend to have higher profit per customers values. This reveal that geographic customers count has positive relationship with profit per customer. However there some noticeable variations around customers count with 300-400 values. customers count around this area recorded substantial different of profit per customer values. These variation explain that customers concentration alone may not define geographic profitability. Management should investigate the contributing factors to this variations which could be operating cost, customer purchasing behavior and transaction values.
3. Customer Distribution: Washington has the highest customers concentration with 66 customers, followed by El paso, Louisville, Houston, New York city, Miami, Dallas,and Phoenix, with 39, 36, 33, 31, 28, 26, and 26 customers respectively.
4. Revenue Performance by Cities: The revenue performance by cities is positively related to customers concentration, as Washington record the highest revenue of $10,964 followed by El paso ($6,350), Louisville ($5,359), Houston ($4,787) and New York city with $4,469
5. Geographic distribution of customers: The geographic map provides management with an opportunity to identify areas with substantial customer concentration and locations that may offer opportunities for market expansion. The map illustrates that the business has customers distributed across several locations in the United States. The visible distribution suggests relatively concentrated customer activity in parts of the eastern and central United States, with additional customer presence across western states.
6. State level customer distribution: California has the highest customer count among the displayed states, followed by Florida and Georgia. This indicates that California represents a significant customer market and may deserve particular attention when assessing geographic sales strategies.

# 6. Recommendations to the ZT Management
1. Customer retention: Prioritize customer retention strategies in Washington, which leads the displayed cities in customer count and revenue.
2. Market development: Investigate cities such as Richmond, where revenue appears relatively strong compared with the size of the customer base.
3. Geographic expansion: Examine states and cities with relatively low customer representation to identify potential market-development opportunities.
4. Profitability investigation: Investigate geographic areas where customer concentration is high but profit per customer is relatively low.
5. Resource allocation: Use state-level and city-level performance comparisons to guide marketing activities and customer acquisition investments.
