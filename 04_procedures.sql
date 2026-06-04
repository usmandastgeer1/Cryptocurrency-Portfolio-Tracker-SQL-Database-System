USE crypto_portfolio_tracker;

DELIMITER $$

CREATE PROCEDURE sp_add_buy_transaction (
    IN p_user_id INT,
    IN p_wallet_id INT,
    IN p_crypto_id INT,
    IN p_quantity DECIMAL(24,8),
    IN p_price_per_coin DECIMAL(18,2),
    IN p_fee DECIMAL(18,2),
    IN p_notes VARCHAR(255)
)
BEGIN
    INSERT INTO transactions
    (user_id, wallet_id, crypto_id, transaction_type, quantity, price_per_coin, fee, transaction_date, notes)
    VALUES
    (p_user_id, p_wallet_id, p_crypto_id, 'BUY', p_quantity, p_price_per_coin, p_fee, NOW(), p_notes);
END$$

CREATE PROCEDURE sp_add_sell_transaction (
    IN p_user_id INT,
    IN p_wallet_id INT,
    IN p_crypto_id INT,
    IN p_quantity DECIMAL(24,8),
    IN p_price_per_coin DECIMAL(18,2),
    IN p_fee DECIMAL(18,2),
    IN p_notes VARCHAR(255)
)
BEGIN
    DECLARE available_qty DECIMAL(24,8);

    SELECT COALESCE(SUM(
        CASE
            WHEN transaction_type IN ('BUY', 'TRANSFER_IN') THEN quantity
            WHEN transaction_type IN ('SELL', 'TRANSFER_OUT') THEN -quantity
        END
    ), 0)
    INTO available_qty
    FROM transactions
    WHERE user_id = p_user_id AND crypto_id = p_crypto_id;

    IF available_qty < p_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient crypto balance for sell transaction';
    ELSE
        INSERT INTO transactions
        (user_id, wallet_id, crypto_id, transaction_type, quantity, price_per_coin, fee, transaction_date, notes)
        VALUES
        (p_user_id, p_wallet_id, p_crypto_id, 'SELL', p_quantity, p_price_per_coin, p_fee, NOW(), p_notes);
    END IF;
END$$

CREATE PROCEDURE sp_create_portfolio_snapshot (
    IN p_user_id INT
)
BEGIN
    DECLARE total_value DECIMAL(18,2);

    SELECT COALESCE(total_portfolio_value_usd, 0)
    INTO total_value
    FROM v_user_total_portfolio_value
    WHERE user_id = p_user_id;

    INSERT INTO portfolio_snapshots (user_id, total_value_usd, snapshot_date)
    VALUES (p_user_id, total_value, NOW());
END$$

CREATE PROCEDURE sp_add_price_record (
    IN p_crypto_id INT,
    IN p_price_usd DECIMAL(18,2)
)
BEGIN
    INSERT INTO price_history (crypto_id, price_usd, recorded_at)
    VALUES (p_crypto_id, p_price_usd, NOW());
END$$

DELIMITER ;
