-- ============================================================
-- Cryptocurrency Portfolio Tracker Database
-- DBMS: MySQL 8+
-- ============================================================

DROP DATABASE IF EXISTS crypto_portfolio_tracker;
CREATE DATABASE crypto_portfolio_tracker;
USE crypto_portfolio_tracker;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    base_currency VARCHAR(10) DEFAULT 'USD',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cryptocurrencies (
    crypto_id INT AUTO_INCREMENT PRIMARY KEY,
    symbol VARCHAR(15) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    blockchain VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE exchanges (
    exchange_id INT AUTO_INCREMENT PRIMARY KEY,
    exchange_name VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(80),
    website VARCHAR(150)
);

CREATE TABLE wallets (
    wallet_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    wallet_name VARCHAR(100) NOT NULL,
    wallet_type ENUM('Exchange', 'Hot Wallet', 'Cold Wallet', 'Paper Wallet') NOT NULL,
    exchange_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_wallet_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_wallet_exchange
        FOREIGN KEY (exchange_id) REFERENCES exchanges(exchange_id)
        ON DELETE SET NULL
);

CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    wallet_id INT NOT NULL,
    crypto_id INT NOT NULL,
    transaction_type ENUM('BUY', 'SELL', 'TRANSFER_IN', 'TRANSFER_OUT') NOT NULL,
    quantity DECIMAL(24, 8) NOT NULL,
    price_per_coin DECIMAL(18, 2) NOT NULL DEFAULT 0,
    fee DECIMAL(18, 2) NOT NULL DEFAULT 0,
    transaction_date DATETIME NOT NULL,
    notes VARCHAR(255),

    CONSTRAINT chk_transaction_quantity CHECK (quantity > 0),
    CONSTRAINT chk_transaction_price CHECK (price_per_coin >= 0),
    CONSTRAINT chk_transaction_fee CHECK (fee >= 0),

    CONSTRAINT fk_transaction_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_transaction_wallet
        FOREIGN KEY (wallet_id) REFERENCES wallets(wallet_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_transaction_crypto
        FOREIGN KEY (crypto_id) REFERENCES cryptocurrencies(crypto_id)
        ON DELETE CASCADE
);

CREATE TABLE price_history (
    price_id INT AUTO_INCREMENT PRIMARY KEY,
    crypto_id INT NOT NULL,
    price_usd DECIMAL(18, 2) NOT NULL,
    recorded_at DATETIME NOT NULL,

    CONSTRAINT chk_price_usd CHECK (price_usd > 0),

    CONSTRAINT fk_price_crypto
        FOREIGN KEY (crypto_id) REFERENCES cryptocurrencies(crypto_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_crypto_recorded_time UNIQUE (crypto_id, recorded_at)
);

CREATE TABLE portfolio_snapshots (
    snapshot_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_value_usd DECIMAL(18, 2) NOT NULL DEFAULT 0,
    snapshot_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_snapshot_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    crypto_id INT NOT NULL,
    target_price DECIMAL(18, 2) NOT NULL,
    condition_type ENUM('ABOVE', 'BELOW') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_target_price CHECK (target_price > 0),

    CONSTRAINT fk_alert_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_alert_crypto
        FOREIGN KEY (crypto_id) REFERENCES cryptocurrencies(crypto_id)
        ON DELETE CASCADE
);

CREATE TABLE watchlist (
    watchlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    crypto_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_watchlist_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_watchlist_crypto
        FOREIGN KEY (crypto_id) REFERENCES cryptocurrencies(crypto_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_user_crypto_watchlist UNIQUE (user_id, crypto_id)
);

CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_transactions_crypto ON transactions(crypto_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_price_history_crypto_date ON price_history(crypto_id, recorded_at);
CREATE INDEX idx_wallets_user ON wallets(user_id);
