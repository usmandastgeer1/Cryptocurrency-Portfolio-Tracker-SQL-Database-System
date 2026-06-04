USE crypto_portfolio_tracker;

DELIMITER $$

CREATE TRIGGER trg_before_transaction_insert_check_balance
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE available_qty DECIMAL(24,8);

    IF NEW.transaction_type IN ('SELL', 'TRANSFER_OUT') THEN
        SELECT COALESCE(SUM(
            CASE
                WHEN transaction_type IN ('BUY', 'TRANSFER_IN') THEN quantity
                WHEN transaction_type IN ('SELL', 'TRANSFER_OUT') THEN -quantity
            END
        ), 0)
        INTO available_qty
        FROM transactions
        WHERE user_id = NEW.user_id AND crypto_id = NEW.crypto_id;

        IF available_qty < NEW.quantity THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient crypto balance';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_before_wallet_insert_exchange_check
BEFORE INSERT ON wallets
FOR EACH ROW
BEGIN
    IF NEW.wallet_type = 'Exchange' AND NEW.exchange_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Exchange wallet must have an exchange_id';
    END IF;
END$$

CREATE TRIGGER trg_after_price_insert_check_alerts
AFTER INSERT ON price_history
FOR EACH ROW
BEGIN
    UPDATE alerts
    SET is_active = FALSE
    WHERE crypto_id = NEW.crypto_id
      AND is_active = TRUE
      AND (
          (condition_type = 'ABOVE' AND NEW.price_usd >= target_price)
          OR
          (condition_type = 'BELOW' AND NEW.price_usd <= target_price)
      );
END$$

DELIMITER ;
