\* find tx of wallet  by day*\
WITH target_transactions AS (
  SELECT
    block_time,
    token_pair
  FROM dex.trades
  WHERE block_date >= DATE '2024-03-07' 
    AND tx_from = FROM_HEX('0b1dd81b07b2b446973a8f6f2294653eb82d9bc7')
    AND blockchain = 'ethereum'
),
similar_transactions AS (
  SELECT
    t.block_time AS block_time,
    t.token_pair AS token_pair,
    COUNT(*) AS transaction_count
  FROM dex.trades t
  JOIN target_transactions tt ON t.token_pair = tt.token_pair
    AND t.block_time > tt.block_time
    AND t.block_time <= tt.block_time + INTERVAL '1' MINUTE
    AND t.tx_from <> FROM_HEX('0b1dd81b07b2b446973a8f6f2294653eb82d9bc7')
    AND t.blockchain = 'ethereum'
  WHERE t.token_pair NOT IN ('WETH-USDT', 'USDT-WETH')
  GROUP BY t.block_time, t.token_pair
)
SELECT 
  st.block_time,
  st.token_pair,
  FROM_HEX('0b1dd81b07b2b446973a8f6f2294653eb82d9bc7') AS wallet_address,
  st.transaction_count
FROM similar_transactions st;
