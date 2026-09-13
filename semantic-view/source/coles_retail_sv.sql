create or replace semantic view COLES_RETAIL_DB.AI_ANALYTICS.COLES_RETAIL_SEMANTIC_MODEL
tables (
TIME_DIM as COLES_RETAIL_DB.AI_ANALYTICS.V_TIME_DIM primary key (DATE_KEY) with synonyms=('date','calendar','time'),
STORES as COLES_RETAIL_DB.AI_ANALYTICS.V_STORES primary key (LOC_ID) with synonyms=('store','location','branch'),
PRODUCTS as COLES_RETAIL_DB.AI_ANALYTICS.V_PRODUCT_MASTER primary key (MERCH_ID) with synonyms=('product','item'),
SUPPLIERS as COLES_RETAIL_DB.SUPPLY_CHAIN.DIM_SUPPLIERS primary key (SUPPLIER_ID) with synonyms=('supplier','vendor'),
SALES as COLES_RETAIL_DB.AI_ANALYTICS.V_SALES_ENRICHED primary key (TXN_ID) with synonyms=('transactions','orders'),
STORE_PERFORMANCE as COLES_RETAIL_DB.RETAIL.FACT_DAILY_STORE_PERFORMANCE primary key (PERFORMANCE_ID),
REVIEWS as COLES_RETAIL_DB.RETAIL.FACT_CUSTOMER_REVIEWS primary key (REVIEW_ID) with synonyms=('feedback','ratings'),
REVIEW_SENTIMENT as COLES_RETAIL_DB.RETAIL.REVIEWS_SENTIMENT_CATEGORIES primary key (REVIEW_ID,SENTIMENT_CATEGORY) with synonyms=('sentiment','customer sentiment','review sentiment'),
INVENTORY_ALERTS as COLES_RETAIL_DB.SUPPLY_CHAIN.FACT_INVENTORY_ALERTS primary key (ALERT_ID),
SUPPORT_TICKETS as COLES_RETAIL_DB.MARKETING.FACT_SUPPORT_TICKETS primary key (TICKET_ID) with synonyms=('complaints','tickets')
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
SALES.TOTAL_SALES as NET_AMT with synonyms=('revenue','sales amount'),
SALES.QUANTITY as UNIT_CNT with synonyms=('units sold','qty'),
SALES.DISCOUNT_AMOUNT as DISC_AMT with synonyms=('discount'),
SALES.GROSS_PROFIT as MARGIN_AMT with synonyms=('profit'),
SALES.BASE_PRICE as BASE_PRC with synonyms=('list price','shelf price'),
STORE_PERFORMANCE.TOTAL_REVENUE as TOTAL_REVENUE with synonyms=('daily sales','store revenue'),
STORE_PERFORMANCE.FOOT_TRAFFIC as FOOT_TRAFFIC with synonyms=('visitors','traffic'),
STORE_PERFORMANCE.TOTAL_TRANSACTIONS as TOTAL_TRANSACTIONS with synonyms=('transaction count'),
REVIEWS.RATING as RATING with synonyms=('star rating','score'),
INVENTORY_ALERTS.CURRENT_STOCK as CURRENT_STOCK with synonyms=('stock level','inventory')
)
dimensions (
TIME_DIM.DATE_KEY as DATE_KEY with synonyms=('date','day'),
TIME_DIM.YEAR_MONTH as YEAR_MONTH with synonyms=('month year','period','year month'),
TIME_DIM.MONTH_NAME as MONTH_NAME with synonyms=('month'),
TIME_DIM.QUARTER_NAME as QUARTER_NAME with synonyms=('quarter'),
TIME_DIM.YEAR_NUMBER as YEAR_NUMBER with synonyms=('year'),
TIME_DIM.WEEK_OF_YEAR as WEEK_OF_YEAR with synonyms=('week number','week'),
STORES.LOC_NM as LOC_NM with synonyms=('store name','store','location'),
STORES.ST_CDE as ST_CDE with synonyms=('state','region'),
STORES.CITY_NM as CITY_NM with synonyms=('city'),
STORES.FMT_CDE as FMT_CDE with synonyms=('store type','format'),
PRODUCTS.PRODUCT_CATEGORY as PRODUCT_CATEGORY with synonyms=('category','product category','department'),
PRODUCTS.BRAND as BRAND with synonyms=('brand'),
PRODUCTS.ITEM_DESC as ITEM_DESC with synonyms=('product name','product','item'),
SUPPLIERS.SUPPLIER_NAME as SUPPLIER_NAME with synonyms=('supplier'),
SUPPLIERS.COUNTRY as COUNTRY,
SALES.INV_DT as INV_DT with synonyms=('transaction date','sale date'),
SALES.CUSTOMER_SEGMENT as CUSTOMER_SEGMENT with synonyms=('customer type','customer segment'),
SALES.CHANNEL as CHANNEL with synonyms=('online vs in-store'),
SALES.FULFILMENT_TYPE as FULFILMENT_TYPE with synonyms=('fulfilment','delivery type'),
SALES.TENDER_CDE as TENDER_CDE with synonyms=('payment method'),
REVIEWS.PRODUCT_CATEGORY as PRODUCT_CATEGORY with synonyms=('reviewed category'),
REVIEWS.REVIEW_TEXT as REVIEW_TEXT with synonyms=('feedback text','customer feedback','review comment'),
REVIEWS.STORE_LOCATION as STORE_LOCATION with synonyms=('review location','review store location'),
REVIEW_SENTIMENT.SENTIMENT_CATEGORY as SENTIMENT_CATEGORY with synonyms=('aspect','sentiment aspect'),
REVIEW_SENTIMENT.SENTIMENT as SENTIMENT with synonyms=('sentiment type','sentiment value'),
INVENTORY_ALERTS.ALERT_TYPE as ALERT_TYPE,
SUPPORT_TICKETS.STATUS as STATUS with synonyms=('ticket status'),
SUPPORT_TICKETS.PRIORITY as PRIORITY with synonyms=('urgency'),
SUPPORT_TICKETS.AI_CATEGORY as AI_CATEGORY with synonyms=('complaint category','issue category')
)
metrics (
SALES.REVENUE as SUM(sales.total_sales) with synonyms=('total revenue','net sales') comment='DAX equivalent: Total Revenue = SUM(Sales[NET_AMT])',
SALES.UNITS_SOLD as SUM(sales.quantity) with synonyms=('total units','volume') comment='DAX equivalent: Total Units = SUM(Sales[UNIT_CNT])',
SALES.TOTAL_PROFIT as SUM(sales.gross_profit) with synonyms=('gross profit','margin dollars') comment='DAX equivalent: Total Profit = SUM(Sales[MARGIN_AMT])',
SALES.TOTAL_DISCOUNT as SUM(sales.discount_amount) with synonyms=('total markdowns','promo spend') comment='DAX equivalent: Total Discount = SUM(Sales[DISC_AMT])',
SALES.AVG_SELLING_PRICE as SUM(sales.total_sales) / NULLIF(SUM(sales.quantity), 0) with synonyms=('ASP','average price per unit','unit price') comment='DAX equivalent: ASP = DIVIDE(SUM(Sales[NET_AMT]), SUM(Sales[UNIT_CNT]))',
SALES.GROSS_MARGIN_PCT as SUM(sales.gross_profit) / NULLIF(SUM(sales.total_sales), 0) * 100 with synonyms=('gross margin','margin percent','GM%') comment='DAX equivalent: GM% = DIVIDE(SUM(Sales[MARGIN_AMT]), SUM(Sales[NET_AMT])) * 100',
SALES.MARKDOWN_RATE as SUM(sales.discount_amount) / NULLIF(SUM(sales.total_sales) + SUM(sales.discount_amount), 0) * 100 with synonyms=('discount rate','promo intensity','markdown %') comment='DAX equivalent: Markdown% = DIVIDE(SUM(DISC_AMT), SUM(NET_AMT)+SUM(DISC_AMT)) * 100',
STORE_PERFORMANCE.TOTAL_VISITORS as SUM(store_performance.foot_traffic) with synonyms=('visitors','footfall'),
STORE_PERFORMANCE.CONVERSION_RATE as SUM(store_performance.total_transactions) / NULLIF(SUM(store_performance.foot_traffic), 0) * 100 with synonyms=('conversion rate','conversion %','shoppers to buyers') comment='DAX equivalent: Conversion% = DIVIDE(Transactions, FootTraffic) * 100',
STORE_PERFORMANCE.AVG_TRANSACTION_VALUE as SUM(store_performance.total_revenue) / NULLIF(SUM(store_performance.total_transactions), 0) with synonyms=('ATV','basket size','average basket') comment='DAX equivalent: ATV = DIVIDE(Revenue, Transactions)',
STORE_PERFORMANCE.REVENUE_PER_VISITOR as SUM(store_performance.total_revenue) / NULLIF(SUM(store_performance.foot_traffic), 0) with synonyms=('sales per visitor','RPV','spend per head') comment='DAX equivalent: RPV = DIVIDE(Revenue, FootTraffic)',
REVIEWS.AVG_RATING as AVG(reviews.rating) with synonyms=('average rating','customer score'),
REVIEWS.REVIEW_COUNT as COUNT(reviews.REVIEW_ID) with synonyms=('number of reviews'),
REVIEW_SENTIMENT.POSITIVE_COUNT as COUNT(CASE WHEN review_sentiment.SENTIMENT = 'positive' THEN 1 END) with synonyms=('positive reviews','positive sentiment count'),
REVIEW_SENTIMENT.NEGATIVE_COUNT as COUNT(CASE WHEN review_sentiment.SENTIMENT = 'negative' THEN 1 END) with synonyms=('negative reviews','negative sentiment count'),
REVIEW_SENTIMENT.NEUTRAL_COUNT as COUNT(CASE WHEN review_sentiment.SENTIMENT = 'neutral' THEN 1 END) with synonyms=('neutral reviews'),
REVIEW_SENTIMENT.MIXED_COUNT as COUNT(CASE WHEN review_sentiment.SENTIMENT = 'mixed' THEN 1 END) with synonyms=('mixed reviews'),
REVIEW_SENTIMENT.SENTIMENT_COUNT as COUNT(review_sentiment.REVIEW_ID) with synonyms=('total sentiment reviews'),
PROFIT_PER_UNIT as sales.total_profit / NULLIF(sales.units_sold, 0) with synonyms=('profit per unit','unit margin','PPU') comment='DAX equivalent: PPU = DIVIDE([Total Profit], [Total Units])',
NET_PROMOTER_IMPACT as review_sentiment.positive_count - review_sentiment.negative_count with synonyms=('NPS proxy','net sentiment','sentiment balance') comment='DAX equivalent: Net Sentiment = [Positive Count] - [Negative Count]',
PROMO_EFFECTIVENESS as sales.total_profit / NULLIF(sales.total_discount, 0) with synonyms=('ROI on promotions','promo ROI','promotion effectiveness') comment='DAX equivalent: Promo ROI = DIVIDE([Total Profit], [Total Markdowns])',
SALES_DENSITY as sales.revenue / NULLIF(store_performance.total_visitors, 0) with synonyms=('sales density','revenue per footfall','yield per visitor') comment='DAX equivalent: Sales Density = DIVIDE([Revenue], [Total Visitors])'
)
comment='Coles Retail semantic view with sentiment analysis for Cortex Analyst'
ai_sql_generation 'IMPORTANT - Revenue Definitions: - "sales", "revenue", "net sales", "total sales" -> always use the revenue metric which maps to SUM(total_sales) i.e. SUM(NET_AMT) - NET_AMT is the final net amount AFTER all discounts are applied. Do NOT subtract DISC_AMT from NET_AMT. - DISC_AMT is a breakdown field showing how much discount was included in computing NET_AMT. It is NOT an additional deduction. - For gross revenue before discounts, use SUM(NET_AMT + DISC_AMT) - NEVER generate SUM(NET_AMT - DISC_AMT) as this double-counts the discount deduction and produces incorrect results.  IMPORTANT - Store Naming Convention: - Sales data uses: stores.loc_nm (e.g., "Coles Melbourne CBD") - Review data uses: reviews.store_location OR review_sentiment.STORE_LOCATION (e.g., "Melbourne CBD") - When user asks about "Melbourne CBD" for reviews/sentiment, use STORE_LOCATION dimension - When user asks about "Coles Melbourne CBD" or sales, use loc_nm dimension - To join sales with reviews by location, match on STORE_ID  When asked about monthly sales trends or sales by month: - Always use year_month dimension for grouping - Order by year_month ascending for chronological display  When asked about dairy sales or dairy trends: - Filter by product_category = ''Dairy''  When asked about sales by store: - Use loc_nm dimension from stores table  When asked about sentiment or customer feedback: - Use review_sentiment table for sentiment analysis - sentiment_category dimension includes: product_quality, value, freshness, service, store_cleanliness, parking - sentiment dimension includes: positive, negative, neutral, mixed, unknown - Use positive_count, negative_count, neutral_count metrics for counts  When asked about negative sentiment or problems: - Filter by sentiment = ''negative'' - Group by sentiment_category to identify problem areas  When asked about sentiment trends over time: - Group by year_month from time_dim - Show positive_count and negative_count to track changes - Order by year_month ascending'
ai_verified_queries (
MONTHLY_SALES_BY_CATEGORY_2026 AS (
QUESTION 'What is the monthly sales trend by product category for 2026?'
VERIFIED_BY '(STEWARD = Demo Builder)'
ONBOARDING_QUESTION true
SQL 'SELECT __time_dim.year_month, __products.product_category, SUM(__sales.total_sales) AS revenue, SUM(__sales.quantity) AS units_sold FROM __sales JOIN __products ON __sales.merch_id = __products.merch_id JOIN __time_dim ON __sales.inv_dt = __time_dim.date_key WHERE __time_dim.year_number = 2026 GROUP BY __time_dim.year_month, __products.product_category ORDER BY __products.product_category, __time_dim.year_month'),
MONTHLY_DAIRY_SALES_BY_STORE_2026 AS (
QUESTION 'Show me monthly dairy sales by store for 2026'
VERIFIED_BY '(STEWARD = Demo Builder)'
ONBOARDING_QUESTION true
SQL 'SELECT __stores.loc_nm, __time_dim.year_month, SUM(__sales.total_sales) AS revenue, SUM(__sales.quantity) AS units_sold FROM __sales JOIN __stores ON __sales.loc_id = __stores.loc_id JOIN __products ON __sales.merch_id = __products.merch_id JOIN __time_dim ON __sales.inv_dt = __time_dim.date_key WHERE __products.product_category = ''Dairy'' AND __time_dim.year_number = 2026 GROUP BY __stores.loc_nm, __time_dim.year_month ORDER BY __stores.loc_nm, __time_dim.year_month'),
AVG_DAIRY_RATING_BY_STORE AS (
QUESTION 'What is the average customer rating for dairy at Melbourne CBD compared to other stores?'
VERIFIED_BY '(STEWARD = Demo Builder)'
ONBOARDING_QUESTION true
SQL 'SELECT __reviews.store_location, AVG(__reviews.rating) AS avg_rating, COUNT(__reviews.review_id) AS review_count FROM __reviews WHERE __reviews.product_category = ''Dairy'' GROUP BY __reviews.store_location ORDER BY avg_rating ASC'),
BAKERY_BRAND_PERFORMANCE_LAST_MONTH AS (
QUESTION 'As a category manager for bakery, show me how my categories performed last month by brand'
VERIFIED_BY '(STEWARD = Demo Builder)'
ONBOARDING_QUESTION true
SQL 'SELECT __products.brand, __time_dim.year_month, SUM(__sales.total_sales) AS total_sales, SUM(__sales.quantity) AS total_units, ROUND(SUM(__sales.total_sales) / NULLIF(SUM(__sales.quantity), 0), 2) AS avg_selling_price, SUM(__sales.gross_profit) AS total_margin, ROUND(SUM(__sales.gross_profit) / NULLIF(SUM(__sales.total_sales), 0) * 100, 1) AS margin_pct FROM __sales JOIN __products ON __sales.merch_id = __products.merch_id JOIN __time_dim ON __sales.inv_dt = __time_dim.date_key WHERE __products.product_category = ''Bakery'' AND __time_dim.year_month = TO_CHAR(DATEADD(MONTH, -1, CURRENT_DATE()), ''YYYY-MM'') GROUP BY __products.brand, __time_dim.year_month ORDER BY total_sales DESC')
);
