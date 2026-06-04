USE crypto_portfolio_tracker;

SELECT * FROM cryptocurrencies;

SELECT u.full_name, c.symbol, t.transaction_type, t.quantity, t.price_per_coin, t.fee, t.transaction_date
FROM transactions t
JOIN users u ON u.user_id = t.user_id
JOIN cryptocurrencies c ON c.crypto_id = t.crypto_id
WHERE u.user_id = 1
ORDER BY t.transaction_date DESC;

SELECT * FROM v_user_crypto_holdings
WHERE total_quantity > 0;

SELECT * FROM v_portfolio_value;

SELECT * FROM v_user_total_portfolio_value;

SELECT * FROM v_latest_crypto_prices;

SELECT u.full_name,
       c.symbol,
       SUM(CASE WHEN t.transaction_type = 'BUY' THEN (t.quantity * t.price_per_coin + t.fee) ELSE 0 END) AS total_buy_cost,
       SUM(CASE WHEN t.transaction_type = 'SELL' THEN (t.quantity * t.price_per_coin - t.fee) ELSE 0 END) AS total_sell_revenue
FROM transactions t
JOIN users u ON u.user_id = t.user_id
JOIN cryptocurrencies c ON c.crypto_id = t.crypto_id
GROUP BY u.full_name, c.symbol;

SELECT c.symbol, c.name, COUNT(*) AS total_transactions
FROM transactions t
JOIN cryptocurrencies c ON c.crypto_id = t.crypto_id
GROUP BY c.symbol, c.name
ORDER BY total_transactions DESC;

SELECT *
FROM v_user_total_portfolio_value
ORDER BY total_portfolio_value_usd DESC
LIMIT 1;

SELECT * FROM v_active_alerts;

SELECT u.full_name, c.symbol, c.name, w.added_at
FROM watchlist w
JOIN users u ON u.user_id = w.user_id
JOIN cryptocurrencies c ON c.crypto_id = w.crypto_id
WHERE u.user_id = 1;

SELECT c.symbol, ph.price_usd, ph.recorded_at
FROM price_history ph
JOIN cryptocurrencies c ON c.crypto_id = ph.crypto_id
WHERE c.symbol = 'BTC'
ORDER BY ph.recorded_at;

SELECT w.wallet_name, c.symbol,
       SUM(CASE
           WHEN t.transaction_type IN ('BUY', 'TRANSFER_IN') THEN t.quantity
           WHEN t.transaction_type IN ('SELL', 'TRANSFER_OUT') THEN -t.quantity
       END) AS wallet_quantity
FROM transactions t
JOIN wallets w ON w.wallet_id = t.wallet_id
JOIN cryptocurrencies c ON c.crypto_id = t.crypto_id
GROUP BY w.wallet_name, c.symbol
HAVING wallet_quantity > 0;

SELECT DATE_FORMAT(transaction_date, '%Y-%m') AS month,
       COUNT(*) AS transaction_count,
       SUM(quantity * price_per_coin) AS total_volume_usd
FROM transactions
GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
ORDER BY month;

SELECT u.full_name,
       ROUND(SUM(CASE WHEN t.transaction_type = 'BUY'
                      THEN (t.quantity * t.price_per_coin + t.fee)
                      ELSE 0 END), 2) AS total_invested_usd
FROM transactions t
JOIN users u ON u.user_id = t.user_id
GROUP BY u.full_name;
