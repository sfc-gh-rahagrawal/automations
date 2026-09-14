-- Semantic View: AI_ANALYTICS.COLES_RETAIL_SEMANTIC_MODEL
-- Executed via: EXECUTE IMMEDIATE FROM @AUTOMATIONS_REPO/branches/main/...

create or replace semantic view COLES_RETAIL_DB.AI_ANALYTICS.COLES_RETAIL_SEMANTIC_MODEL
tables (
TIME_DIM as COLES_RETAIL_DB.CORE.DIM_TIME primary key (DATE_KEY) comment='Calendar dimension with daily grain, 5 years (2023-2027). Use for date filtering, fiscal periods, and seasonal trends.',
STORES as COLES_RETAIL_DB.AI_ANALYTICS.V_STORES primary key (LOC_ID) comment='Store dimension with 10 Coles locations. LOC_NM = full store name (e.g. Coles Melbourne CBD). FMT_CDE = format: Metro, Mall, Suburban.',
PRODUCTS as COLES_RETAIL_DB.AI_ANALYTICS.V_PRODUCT_MASTER primary key (MERCH_ID) comment='Product master. PRODUCT_CATEGORY = Dairy, Bakery, Beverages, Cereals, Frozen, Household, Meat, Pantry, Produce. BRAND = supplier/brand.',
SUPPLIERS as COLES_RETAIL_DB.SUPPLY_CHAIN.DIM_SUPPLIERS primary key (SUPPLIER_ID) comment='Supplier dimension with vendor details, country, reliability scores, and organic certification.',
SALES as COLES_RETAIL_DB.RETAIL.FACT_SALES_TRANSACTIONS primary key (TXN_ID) comment='Sales transactions. NET_AMT is AFTER discounts — do NOT subtract DISC_AMT. MARGIN_AMT is gross profit.',
STORE_PERFORMANCE as COLES_RETAIL_DB.RETAIL.FACT_DAILY_STORE_PERFORMANCE primary key (PERFORMANCE_ID) comment='Daily store performance: revenue, transactions, basket size, foot traffic, conversion rate.',
REVIEWS as COLES_RETAIL_DB.MARKETING.FACT_CUSTOMER_REVIEWS primary key (REVIEW_ID) comment='Customer reviews with 1-5 star ratings and free-text feedback. store_location has short names like Melbourne CBD.',
REVIEW_SENTIMENT as COLES_RETAIL_DB.MARKETING.REVIEWS_SENTIMENT_CATEGORIES primary key (REVIEW_ID,SENTIMENT_CATEGORY) comment='AI sentiment per review aspect (product_quality, value, freshness, service, store_cleanliness, parking). Values: positive, negative, neutral, mixed, unknown.',
INVENTORY_ALERTS as COLES_RETAIL_DB.SUPPLY_CHAIN.FACT_INVENTORY_ALERTS primary key (ALERT_ID) comment='Inventory alerts for stock issues across stores.',
SUPPORT_TICKETS as COLES_RETAIL_DB.MARKETING.FACT_SUPPORT_TICKETS primary key (TICKET_ID) comment='Support tickets with AI-classified categories. Priority: CRITICAL, HIGH, MEDIUM, LOW.'
)
relationships (
SALES(MERCH_ID) references PRODUCTS(MERCH_ID),
SALES(LOC_ID) references STORES(LOC_ID),
SALES(INV_DT) references TIME_DIM(DATE_KEY),
STORE_PERFORMANCE(STORE_ID) references STORES(LOC_ID),
STORE_PERFORMANCE(PERFORMANCE_DATE) references TIME_DIM(DATE_KEY),
REVIEWS(PRODUCT_ID) references PRODUCTS(MERCH_ID),
REVIEWS(STORE_ID) references STORES(LOC_ID),
REVIEWS(REVIEW_DATE) references TIME_DIM(DATE_KEY),
REVIEW_SENTIMENT(PRODUCT_ID) references PRODUCTS(MERCH_ID),
REVIEW_SENTIMENT(REVIEW_ID) references REVIEWS(REVIEW_ID),
REVIEW_SENTIMENT(STORE_ID) references STORES(LOC_ID),
INVENTORY_ALERTS(STORE_ID) references STORES(LOC_ID),
SUPPORT_TICKETS(STORE_ID) references STORES(LOC_ID)
)
facts (
SALES.TOTAL_SALES as NET_AMT comment='Net sales after discounts. Do NOT subtract DISC_AMT.',
SALES.QUANTITY as UNIT_CNT comment='Units sold in the transaction.',
SALES.DISCOUNT_AMOUNT as DISC_AMT comment='Discount already applied to NET_AMT. Breakdown field, not additional deduction.',
SALES.GROSS_PROFIT as MARGIN_AMT comment='Gross profit margin (revenue minus COGS).',
STORE_PERFORMANCE.TOTAL_REVENUE as total_revenue comment='Total daily revenue for a store.',
STORE_PERFORMANCE.FOOT_TRAFFIC as foot_traffic comment='Customer visit count for a store on a given day.',
STORE_PERFORMANCE.TOTAL_TRANSACTIONS as total_transactions comment='Total transactions at a store on a given day.',
REVIEWS.RATING as rating comment='Customer review rating 1-5 stars.',
INVENTORY_ALERTS.CURRENT_STOCK as current_stock comment='Current stock quantity on hand.'
)
dimensions (
TIME_DIM.DATE_KEY as date_key comment='Calendar date.',
TIME_DIM.DAY_NAME as day_name comment='Day name: Monday, Tuesday, etc.',
TIME_DIM.IS_WEEKEND as is_weekend comment='TRUE if Saturday or Sunday.',
TIME_DIM.WEEK_OF_YEAR as week_of_year comment='ISO week number 1-52.',
TIME_DIM.MONTH_NAME as month_name comment='Abbreviated month: Jan, Feb, Mar, etc.',
TIME_DIM.YEAR_MONTH as PRD_CDE comment='Period code P[YYYY][MM]. Use sale_period for user-facing month grouping.',
TIME_DIM.QUARTER_NAME as quarter_name comment='Quarter: Q1, Q2, Q3, Q4.',
TIME_DIM.YEAR_QUARTER as year_quarter comment='Year-quarter, e.g. 2026-Q1.',
TIME_DIM.YEAR_NUMBER as year_number comment='Four-digit calendar year.',
TIME_DIM.FISCAL_YEAR as fiscal_year comment='Coles fiscal year (starts July 1).',
TIME_DIM.FISCAL_QUARTER as fiscal_quarter comment='Coles fiscal quarter 1-4.',
TIME_DIM.IS_HOLIDAY as is_holiday comment='TRUE if Australian public holiday.',
TIME_DIM.SEASON as season comment='Southern hemisphere: Summer, Autumn, Winter, Spring.',
TIME_DIM.IS_BUSINESS_DAY as is_business_day comment='TRUE if weekday and not a holiday.',
STORES.STORE_NAME as LOC_NM comment='Full store name, e.g. Coles Melbourne CBD.',
STORES.STATE as ST_CDE comment='Australian state: VIC, NSW, QLD, WA, SA, TAS.',
STORES.STORE_TYPE as FMT_CDE comment='Store format: Metro, Mall, or Suburban.' sample_values ('Metro', 'Mall', 'Suburban') is_enum,
STORES.CITY_NAME as CITY_NM comment='City of the store.',
PRODUCTS.PRODUCT_NAME as ITEM_DESC comment='Full product name, e.g. Full Cream Milk 2L.',
PRODUCTS.CATEGORY as PRODUCT_CATEGORY comment='Product category: Dairy, Bakery, Beverages, Cereals, Frozen, Household, Meat, Pantry, Produce.' sample_values ('Dairy', 'Bakery', 'Beverages', 'Cereals', 'Frozen', 'Household', 'Meat', 'Pantry', 'Produce') is_enum,
PRODUCTS.BRAND as BRAND comment='Brand or supplier name.',
SUPPLIERS.SUPPLIER_NAME as supplier_name comment='Supplier company name.',
SUPPLIERS.COUNTRY as country comment='Supplier country of origin.',
SALES.TRANSACTION_DATE as INV_DT comment='Date of the sales transaction.',
SALES.SALE_PERIOD as TO_CHAR(INV_DT, 'YYYY-MM') comment='Sales month YYYY-MM for monthly trends.',
SALES.CUSTOMER_SEGMENT as SEG_CDE comment='Customer segment.' sample_values ('Budget', 'Convenience', 'Families', 'Health Conscious', 'Premium', 'Regular') is_enum,
SALES.PAYMENT_METHOD as TENDER_CDE comment='Payment method.' sample_values ('Card', 'Cash', 'Mobile') is_enum,
REVIEWS.PRODUCT_CATEGORY as product_category comment='Product category of the reviewed item.',
REVIEWS.REVIEW_PERIOD as TO_CHAR(review_date, 'YYYY-MM') comment='Review month YYYY-MM.',
REVIEWS.REVIEW_TEXT as review_text comment='Free-text customer review content.',
REVIEWS.STORE_LOCATION as store_location comment='Short store name in reviews, e.g. Melbourne CBD (no Coles prefix).',
REVIEW_SENTIMENT.SENTIMENT_CATEGORY as sentiment_category comment='Aspect: product_quality, value, freshness, service, store_cleanliness, parking.' sample_values ('product_quality', 'value', 'freshness', 'service', 'store_cleanliness', 'parking') is_enum,
REVIEW_SENTIMENT.SENTIMENT as sentiment comment='Sentiment: positive, negative, neutral, mixed, unknown.' sample_values ('positive', 'negative', 'neutral', 'mixed', 'unknown') is_enum,
REVIEW_SENTIMENT.REVIEW_MONTH as TO_CHAR(review_sentiment.REVIEW_DATE, 'YYYY-MM') comment='Sentiment review month YYYY-MM.',
INVENTORY_ALERTS.ALERT_TYPE as alert_type comment='Alert type: Low Stock, Out of Stock, Overstock, Expiring Soon.',
SUPPORT_TICKETS.TICKET_STATUS as "STATUS" comment='Ticket status: Open, In Progress, Resolved, Closed.',
SUPPORT_TICKETS.PRIORITY as priority comment='Ticket priority: CRITICAL, HIGH, MEDIUM, LOW.' sample_values ('CRITICAL', 'HIGH', 'MEDIUM', 'LOW') is_enum,
SUPPORT_TICKETS.AI_CATEGORY as ai_category comment='AI-classified complaint category.'
)
metrics (
SALES.REVENUE as SUM(sales.total_sales) comment='Total net revenue after discounts.',
SALES.UNITS_SOLD as SUM(sales.quantity) comment='Total units sold.',
SALES.TOTAL_PROFIT as SUM(sales.gross_profit) comment='Total gross profit.',
REVIEWS.AVG_RATING as AVG(reviews.rating) comment='Average review rating 1-5.',
REVIEWS.REVIEW_COUNT as COUNT(reviews.REVIEW_ID) comment='Total number of reviews.',
REVIEW_SENTIMENT.POSITIVE_COUNT as COUNT(CASE WHEN review_sentiment.sentiment = 'positive' THEN 1 END) comment='Positive sentiment count.',
REVIEW_SENTIMENT.NEGATIVE_COUNT as COUNT(CASE WHEN review_sentiment.sentiment = 'negative' THEN 1 END) comment='Negative sentiment count.',
REVIEW_SENTIMENT.NEUTRAL_COUNT as COUNT(CASE WHEN review_sentiment.sentiment = 'neutral' THEN 1 END) comment='Neutral sentiment count.',
REVIEW_SENTIMENT.MIXED_COUNT as COUNT(CASE WHEN review_sentiment.sentiment = 'mixed' THEN 1 END) comment='Mixed sentiment count.',
REVIEW_SENTIMENT.SENTIMENT_COUNT as COUNT(review_sentiment.REVIEW_ID) comment='Total sentiment entries.',
STORE_PERFORMANCE.TOTAL_VISITORS as SUM(store_performance.foot_traffic) comment='Total foot traffic.'
)
comment='Coles Retail Analytics - sales, reviews, sentiment, store operations, and supply chain alerts.'
ai_sql_generation 'Revenue = SUM(NET_AMT). NET_AMT is AFTER discounts. Do NOT subtract DISC_AMT. For gross revenue use SUM(NET_AMT + DISC_AMT). NEVER generate SUM(NET_AMT - DISC_AMT). If no date filter specified, default to last 3 months. Always order time-series by sale_period ascending. Sales use store_name (LOC_NM) e.g. "Coles Melbourne CBD". Reviews use store_location e.g. "Melbourne CBD". Join on LOC_ID = STORE_ID. Always group sentiment by sentiment_category for per-aspect breakdown.'
ai_question_categorization 'This covers Coles retail analytics: sales, store performance, reviews, sentiment, inventory, support tickets. Reject questions about employee data, salaries, or PII. Review text questions are answerable via the review_text dimension.'
ai_verified_queries (
MONTHLY_SALES_TREND AS (
QUESTION 'Show me monthly sales trend for the last 6 months'
VERIFIED_AT 1726185600
VERIFIED_BY '(STEWARD = admin)'
SQL 'SELECT sale_period, month_name, revenue, units_sold FROM sales WHERE transaction_date >= DATEADD(month, -6, CURRENT_DATE()) ORDER BY sale_period'),
TOP_STORES AS (
QUESTION 'Which stores have the highest sales?'
VERIFIED_AT 1726185600
VERIFIED_BY '(STEWARD = admin)'
SQL 'SELECT store_name, city_name, state, revenue, units_sold, total_profit FROM sales JOIN stores ON sales.LOC_ID = stores.LOC_ID WHERE transaction_date >= DATEADD(month, -3, CURRENT_DATE()) GROUP BY store_name, city_name, state ORDER BY revenue DESC LIMIT 10'),
BEST_PRODUCTS AS (
QUESTION 'What are the best selling products?'
VERIFIED_AT 1726185600
VERIFIED_BY '(STEWARD = admin)'
SQL 'SELECT product_name, category, revenue, units_sold FROM sales JOIN products ON sales.MERCH_ID = products.MERCH_ID WHERE transaction_date >= DATEADD(month, -1, CURRENT_DATE()) GROUP BY product_name, category ORDER BY revenue DESC LIMIT 10'),
DAIRY_BY_STORE AS (
QUESTION 'What are dairy sales by store for the last 3 months?'
VERIFIED_AT 1726185600
VERIFIED_BY '(STEWARD = admin)'
SQL 'SELECT store_name, sale_period, revenue, units_sold FROM sales JOIN stores ON sales.LOC_ID = stores.LOC_ID JOIN products ON sales.MERCH_ID = products.MERCH_ID WHERE category = ''Dairy'' AND transaction_date >= DATEADD(month, -3, CURRENT_DATE()) GROUP BY store_name, sale_period ORDER BY store_name, sale_period'),
DAIRY_SENTIMENT AS (
QUESTION 'What is the sentiment breakdown for dairy products?'
VERIFIED_AT 1726185600
VERIFIED_BY '(STEWARD = admin)'
SQL 'SELECT sentiment_category, positive_count, negative_count, neutral_count FROM review_sentiment WHERE product_category = ''Dairy'' GROUP BY sentiment_category ORDER BY negative_count DESC'),
NEGATIVE_STORES AS (
QUESTION 'Which stores have the most negative reviews?'
VERIFIED_AT 1726185600
VERIFIED_BY '(STEWARD = admin)'
SQL 'SELECT store_location, product_category, negative_count FROM review_sentiment WHERE sentiment = ''negative'' GROUP BY store_location, product_category ORDER BY negative_count DESC LIMIT 10'),
SEGMENT_COMPARISON AS (
QUESTION 'Compare sales across customer segments'
VERIFIED_AT 1726185600
VERIFIED_BY '(STEWARD = admin)'
SQL 'SELECT customer_segment, revenue, units_sold FROM sales WHERE transaction_date >= DATEADD(month, -3, CURRENT_DATE()) GROUP BY customer_segment ORDER BY revenue DESC'),
STORE_FORMAT AS (
QUESTION 'Compare Metro vs Regional store performance'
VERIFIED_AT 1726185600
VERIFIED_BY '(STEWARD = admin)'
SQL 'SELECT store_type, state, revenue, units_sold, total_profit FROM sales JOIN stores ON sales.LOC_ID = stores.LOC_ID WHERE transaction_date >= DATEADD(month, -3, CURRENT_DATE()) GROUP BY store_type, state ORDER BY revenue DESC')
)
COPY GRANTS;
