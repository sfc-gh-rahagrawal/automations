-- VIEW: MARKETING.REVIEWS_SENTIMENT_CATEGORIES

DEFINE view COLES_RETAIL_DB{{env_suffix}}.MARKETING.REVIEWS_SENTIMENT_CATEGORIES(
  REVIEW_ID,
  CUSTOMER_ID,
  PRODUCT_NAME,
  PRODUCT_CATEGORY,
  STORE_LOCATION,
  STORE_ID,
  PRODUCT_ID,
  RATING,
  REVIEW_DATE,
  REVIEW_TEXT,
  SENTIMENT_CATEGORY,
  SENTIMENT
) COMMENT='Customer review sentiment analysis by category using Cortex AI'
 as
WITH SENTIMENT_DATA AS (
    SELECT 
        REVIEW_ID,
        CUSTOMER_ID,
        PRODUCT_NAME,
        PRODUCT_CATEGORY,
        STORE_LOCATION,
        STORE_ID,
        PRODUCT_ID,
        RATING,
        REVIEW_DATE,
        REVIEW_TEXT,
        AI_SENTIMENT(
            REVIEW_TEXT, 
            ['product_quality', 'value', 'freshness', 'service', 'store_cleanliness', 'parking']
        ) AS sentiment_result
    FROM COLES_RETAIL_DB{{env_suffix}}.MARKETING.FACT_CUSTOMER_REVIEWS
    WHERE REVIEW_TEXT IS NOT NULL
)
SELECT 
    s.REVIEW_ID,
    s.CUSTOMER_ID,
    s.PRODUCT_NAME,
    s.PRODUCT_CATEGORY,
    s.STORE_LOCATION,
    s.STORE_ID,
    s.PRODUCT_ID,
    s.RATING,
    s.REVIEW_DATE,
    s.REVIEW_TEXT,
    cat.VALUE:name::VARCHAR AS sentiment_category,
    cat.VALUE:sentiment::VARCHAR AS sentiment
FROM SENTIMENT_DATA s,
LATERAL FLATTEN(input => s.sentiment_result:categories) cat;
