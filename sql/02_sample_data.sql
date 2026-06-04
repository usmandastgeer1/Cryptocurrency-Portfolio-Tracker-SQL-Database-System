USE crypto_portfolio_tracker;

INSERT INTO users (full_name, email, password_hash, base_currency) VALUES
('Usman Dastgeer', 'usman@example.com', 'hashed_password_1', 'USD'),
('Ali Khan', 'ali@example.com', 'hashed_password_2', 'USD'),
('Sara Ahmed', 'sara@example.com', 'hashed_password_3', 'USD');

INSERT INTO cryptocurrencies (symbol, name, blockchain) VALUES
('BTC', 'Bitcoin', 'Bitcoin'),
('ETH', 'Ethereum', 'Ethereum'),
('BNB', 'BNB', 'BNB Chain'),
('SOL', 'Solana', 'Solana'),
('ADA', 'Cardano', 'Cardano');

INSERT INTO exchanges (exchange_name, country, website) VALUES
('Binance', 'Global', 'https://www.binance.com'),
('Coinbase', 'USA', 'https://www.coinbase.com'),
('Kraken', 'USA', 'https://www.kraken.com');

INSERT INTO wallets (user_id, wallet_name, wallet_type, exchange_id) VALUES
(1, 'Binance Spot Wallet', 'Exchange', 1),
(1, 'Ledger Cold Wallet', 'Cold Wallet', NULL),
(2, 'Coinbase Main Wallet', 'Exchange', 2),
(3, 'Kraken Wallet', 'Exchange', 3);

INSERT INTO transactions
(user_id, wallet_id, crypto_id, transaction_type, quantity, price_per_coin, fee, transaction_date, notes)
VALUES
(1, 1, 1, 'BUY', 0.05000000, 43000.00, 5.00, '2025-01-10 10:30:00', 'Bought BTC'),
(1, 1, 2, 'BUY', 1.50000000, 2200.00, 3.00, '2025-01-15 12:15:00', 'Bought ETH'),
(1, 1, 4, 'BUY', 20.00000000, 95.00, 2.00, '2025-01-20 15:00:00', 'Bought SOL'),
(1, 1, 2, 'SELL', 0.40000000, 2600.00, 2.50, '2025-02-12 09:45:00', 'Sold some ETH'),
(1, 2, 1, 'TRANSFER_IN', 0.02000000, 0.00, 0.00, '2025-02-20 11:00:00', 'Moved BTC to cold wallet'),
(2, 3, 3, 'BUY', 5.00000000, 310.00, 2.00, '2025-01-22 14:00:00', 'Bought BNB'),
(3, 4, 5, 'BUY', 100.00000000, 0.55, 1.00, '2025-01-25 16:20:00', 'Bought ADA');

INSERT INTO price_history (crypto_id, price_usd, recorded_at) VALUES
(1, 43000.00, '2025-01-10 00:00:00'),
(1, 48000.00, '2025-02-01 00:00:00'),
(1, 52000.00, '2025-03-01 00:00:00'),
(2, 2200.00, '2025-01-15 00:00:00'),
(2, 2600.00, '2025-02-12 00:00:00'),
(2, 3100.00, '2025-03-01 00:00:00'),
(3, 310.00, '2025-01-22 00:00:00'),
(3, 360.00, '2025-03-01 00:00:00'),
(4, 95.00, '2025-01-20 00:00:00'),
(4, 140.00, '2025-03-01 00:00:00'),
(5, 0.55, '2025-01-25 00:00:00'),
(5, 0.72, '2025-03-01 00:00:00');

INSERT INTO alerts (user_id, crypto_id, target_price, condition_type) VALUES
(1, 1, 60000.00, 'ABOVE'),
(1, 2, 2000.00, 'BELOW'),
(2, 3, 400.00, 'ABOVE');

INSERT INTO watchlist (user_id, crypto_id) VALUES
(1, 1),
(1, 2),
(1, 4),
(2, 3),
(3, 5);
