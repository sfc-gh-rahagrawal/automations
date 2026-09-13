-- DCM Project: Coles Retail Semantic View
-- Uses Jinja variable {{env_suffix}} for multi-environment deployment
-- Deploy: snow dcm deploy --target dev|prod

DEFINE SEMANTIC VIEW COLES_RETAIL_DB{{env_suffix}}.AI_ANALYTICS.COLES_RETAIL_SEMANTIC_MODEL
tables (
TIME_DIM as COLES_RETAIL_DB{{env_suffix}}.CORE.DIM_TIME primary key (DATE_KEY) with synonyms=('date','calendar','time'),
STORES as COLES_RETAIL_DB{{env_suffix}}.AI_ANALYTICS.V_STORES primary key (LOC_ID) with synonyms=('store','location','branch'),
PRODUCTS as COLES_RETAIL_DB{{env_suffix}}.AI_ANALYTICS.V_PRODUCT_MASTER primary key (MERCH_ID) with synonyms=('product','item'),
SUPPLIERS as COLES_RETAIL_DB{{env_suffix}}.SUPPLY_CHAIN.DIM_SUPPLIERS primary key (SUPPLIER_ID) with synonyms=('supplier','vendor'),
SALES as COLES_RETAIL_DB{{env_suffix}}.RETAIL.FACT_SALES_TRANSACTIONS primary key (TXN_ID) with synonyms=('transactions','orders'),
STORE_PERFORMANCE as COLES_RETAIL_DB{{env_suffix}}.RETAIL.FACT_DAILY_STORE_PERFORMANCE primary key (PERFORMANCE_ID),
REVIEWS as COLES_RETAIL_DB{{env_suffix}}.MARKETING.FACT_CUSTOMER_REVIEWS primary key (REVIEW_ID) with synonyms=('feedback','ratings'),
REVIEW_SENTIMENT as COLES_RETAIL_DB{{env_suffix}}.MARKETING.REVIEWS_SENTIMENT_CATEGORIES primary key (REVIEW_ID,SENTIMENT_CATEGORY) with synonyms=('sentiment','customer sentiment','review sentiment'),
INVENTORY_ALERTS as COLES_RETAIL_DB{{env_suffix}}.SUPPLY_CHAIN.FACT_INVENTORY_ALERTS primary key (ALERT_ID),
SUPPORT_TICKETS as COLES_RETAIL_DB{{env_suffix}}.MARKETING.FACT_SUPPORT_TICKETS primary key (TICKET_ID) with synonyms=('complaints','tickets')
)
relationships (
SALES_TO_PRODUCTS AS SALES(MERCH_ID) references PRODUCTS(MERCH_ID),
SALES_TO_STORES AS SALES(LOC_ID) references STORES(LOC_ID),
SALES_TO_TIME AS SALES(INV_DT) references TIME_DIM(DATE_KEY),
PERF_TO_STORES AS STORE_PERFORMANCE(STORE_ID) references STORES(LOC_ID),
PERF_TO_TIME AS STORE_PERFORMANCE(PERFORMANCE_DATE) references TIME_DIM(DATE_KEY),
REVIEWS_TO_PRODUCTS AS REVIEWS(PRODUCT_ID) references PRODUCTS(MERCH_ID),
REVIEWS_TO_STORES AS REVIEWS(STORE_ID) references STORES(LOC_ID),
REVIEWS_TO_TIME AS REVIEWS(REVIEW_DATE) references TIME_DIM(DATE_KEY),
SENTIMENT_TO_PRODUCTS AS REVIEW_SENTIMENT(PRODUCT_ID) references PRODUCTS(MERCH_ID),
SENTIMENT_TO_REVIEWS AS REVIEW_SENTIMENT(REVIEW_ID) references REVIEWS(REVIEW_ID),
SENTIMENT_TO_STORES AS REVIEW_SENTIMENT(STORE_ID) references STORES(LOC_ID),
ALERTS_TO_STORES AS INVENTORY_ALERTS(STORE_ID) references STORES(LOC_ID),
TICKETS_TO_STORES AS SUPPORT_TICKETS(STORE_ID) references STORES(LOC_ID)
)
facts (
SALES.TOTAL_SALES as NET_AMT with synonyms=('revenue','sales amount'),
SALES.QUANTITY as UNIT_CNT with synonyms=('units sold','qty'),
SALES.DISCOUNT_AMOUNT as DISC_AMT with synonyms=('discount'),
SALES.GROSS_PROFIT as MARGIN_AMT with synonyms=('profit'),
STORE_PERFORMANCE.TOTAL_REVENUE as total_revenue with synonyms=('daily sales','store revenue'),
STORE_PERFORMANCE.FOOT_TRAFFIC as foot_traffic with synonyms=('visitors','traffic'),
STORE_PERFORMANCE.TOTAL_TRANSACTIONS as total_transactions with synonyms=('transaction count'),
REVIEWS.RATING as rating with synonyms=('star rating','score'),
INVENTORY_ALERTS.CURRENT_STOCK as current_stock with synonyms=('stock level','inventory')
)
dimensions (
TIME_DIM.DATE_KEY as date_key with synonyms=('date','day'),
TIME_DIM.DAY_NAME as day_name with synonyms=('weekday','day of week'),
TIME_DIM.IS_WEEKEND as is_weekend with synonyms=('weekend'),
TIME_DIM.WEEK_OF_YEAR as week_of_year with synonyms=('week number','week'),
TIME_DIM.MONTH_NAME as month_name with synonyms=('month'),
TIME_DIM.YEAR_MONTH as PRD_CDE with synonyms=('month year','period','year month'),
TIME_DIM.QUARTER_NAME as quarter_name with synonyms=('quarter'),
TIME_DIM.YEAR_QUARTER as year_quarter with synonyms=('quarter year'),
TIME_DIM.YEAR_NUMBER as year_number with synonyms=('year'),
TIME_DIM.FISCAL_YEAR as fiscal_year with synonyms=('fy','financial year'),
TIME_DIM.FISCAL_QUARTER as fiscal_quarter with synonyms=('fq'),
TIME_DIM.IS_HOLIDAY as is_holiday with synonyms=('holiday','public holiday'),
TIME_DIM.SEASON as season,
TIME_DIM.IS_BUSINESS_DAY as is_business_day with synonyms=('business day','working day'),
STORES.STORE_NAME as LOC_NM with synonyms=('store','location'),
STORES.STATE as ST_CDE with synonyms=('region'),
STORES.STORE_TYPE as FMT_CDE with synonyms=('format'),
STORES.CITY_NAME as CITY_NM,
PRODUCTS.PRODUCT_NAME as ITEM_DESC with synonyms=('product','item'),
PRODUCTS.CATEGORY as PRODUCT_CATEGORY with synonyms=('product category','department'),
PRODUCTS.BRAND as BRAND,
SUPPLIERS.SUPPLIER_NAME as supplier_name with synonyms=('supplier'),
SUPPLIERS.COUNTRY as country,
SALES.TRANSACTION_DATE as INV_DT with synonyms=('sale date'),
SALES.SALE_PERIOD as TO_CHAR(INV_DT, 'YYYY-MM') with synonyms=('sale period'),
SALES.CUSTOMER_SEGMENT as SEG_CDE with synonyms=('customer type'),
SALES.PAYMENT_METHOD as TENDER_CDE with synonyms=('payment type'),
REVIEWS.PRODUCT_CATEGORY as product_category with synonyms=('reviewed category'),
REVIEWS.REVIEW_PERIOD as TO_CHAR(review_date, 'YYYY-MM') with synonyms=('review month','review period'),
REVIEWS.REVIEW_TEXT as review_text with synonyms=('feedback text','customer feedback','review comment'),
REVIEWS.STORE_LOCATION as store_location with synonyms=('review location','review store location'),
REVIEW_SENTIMENT.SENTIMENT_CATEGORY as sentiment_category with synonyms=('aspect','sentiment aspect'),
REVIEW_SENTIMENT.SENTIMENT as sentiment with synonyms=('sentiment type','sentiment value'),
REVIEW_SENTIMENT.REVIEW_MONTH as TO_CHAR(review_sentiment.REVIEW_DATE, 'YYYY-MM') with synonyms=('sentiment month'),
INVENTORY_ALERTS.ALERT_TYPE as alert_type,
SUPPORT_TICKETS.TICKET_STATUS as "STATUS" with synonyms=('ticket status'),
SUPPORT_TICKETS.PRIORITY as priority with synonyms=('urgency'),
SUPPORT_TICKETS.AI_CATEGORY as ai_category with synonyms=('complaint category','issue category')
)
metrics (
SALES.REVENUE as SUM(sales.total_sales) with synonyms=('total revenue'),
SALES.UNITS_SOLD as SUM(sales.quantity) with synonyms=('total units'),
SALES.TOTAL_PROFIT as SUM(sales.gross_profit) with synonyms=('profit'),
REVIEWS.AVG_RATING as AVG(reviews.rating) with synonyms=('average rating'),
REVIEWS.REVIEW_COUNT as COUNT(reviews.REVIEW_ID) with synonyms=('number of reviews'),
REVIEW_SENTIMENT.POSITIVE_COUNT as COUNT(CASE WHEN review_sentiment.sentiment = 'positive' THEN 1 END) with synonyms=('positive reviews','positive sentiment count'),
REVIEW_SENTIMENT.NEGATIVE_COUNT as COUNT(CASE WHEN review_sentiment.sentiment = 'negative' THEN 1 END) with synonyms=('negative reviews','negative sentiment count'),
REVIEW_SENTIMENT.NEUTRAL_COUNT as COUNT(CASE WHEN review_sentiment.sentiment = 'neutral' THEN 1 END) with synonyms=('neutral reviews'),
REVIEW_SENTIMENT.MIXED_COUNT as COUNT(CASE WHEN review_sentiment.sentiment = 'mixed' THEN 1 END) with synonyms=('mixed reviews'),
REVIEW_SENTIMENT.SENTIMENT_COUNT as COUNT(review_sentiment.REVIEW_ID) with synonyms=('total sentiment reviews'),
STORE_PERFORMANCE.TOTAL_VISITORS as SUM(store_performance.foot_traffic) with synonyms=('visitors')
)
comment='Coles Retail semantic view with sentiment analysis for Cortex Analyst'
COPY GRANTS;
