USE crypto_portfolio_tracker;

CREATE OR REPLACE VIEW v_latest_crypto_prices AS
SELECT ph.crypto_id, c.symbol, c.name, ph.price_usd, ph.recorded_at
FROM price_history ph
JOIN cryptocurrencies c ON c.crypto_id = ph.crypto_id
JOIN (
    SELECT crypto_id, MAX(recorded_at) AS latest_time
    FROM price_history
    GROUP BY crypto_id
) latest
ON latest.crypto_id = ph.crypto_id
AND latest.latest_time = ph.recorded_at;

CREATE OR REPLACE VIEW v_user_crypto_holdings AS
SELECT u.user_id, u.full_name, c.crypto_id, c.symbol, c.name,
       SUM(CASE
           WHEN t.transaction_type IN ('BUY', 'TRANSFER_IN') THEN t.quantity
           WHEN t.transaction_type IN ('SELL', 'TRANSFER_OUT') THEN -t.quantity
       END) AS total_quantity
FROM transactions t
JOIN users u ON u.user_id = t.user_id
JOIN cryptocurrencies c ON c.crypto_id = t.crypto_id
GROUP BY u.user_id, u.full_name, c.crypto_id, c.symbol, c.name;

CREATE OR REPLACE VIEW v_portfolio_value AS
SELECT h.user_id, h.full_name, h.crypto_id, h.symbol, h.name,
       h.total_quantity,
       lp.price_usd AS current_price,
       ROUND(h.total_quantity * lp.price_usd, 2) AS current_value_usd
FROM v_user_crypto_holdings h
JOIN v_latest_crypto_prices lp ON lp.crypto_id = h.crypto_id
WHERE h.total_quantity > 0;

CREATE OR REPLACE VIEW v_user_total_portfolio_value AS
SELECT user_id, full_name,
       ROUND(SUM(current_value_usd), 2) AS total_portfolio_value_usd
FROM v_portfolio_value
GROUP BY user_id, full_name;

CREATE OR REPLACE VIEW v_active_alerts AS
SELECT a.alert_id, u.full_name, c.symbol, a.target_price, a.condition_type,
       lp.price_usd AS current_price,
       CASE
           WHEN a.condition_type = 'ABOVE' AND lp.price_usd >= a.target_price THEN 'TRIGGERED'
           WHEN a.condition_type = 'BELOW' AND lp.price_usd <= a.target_price THEN 'TRIGGERED'
           ELSE 'NOT_TRIGGERED'
       END AS alert_status
FROM alerts a
JOIN users u ON u.user_id = a.user_id
JOIN cryptocurrencies c ON c.crypto_id = a.crypto_id
JOIN v_latest_crypto_prices lp ON lp.crypto_id = a.crypto_id
WHERE a.is_active = TRUE;
