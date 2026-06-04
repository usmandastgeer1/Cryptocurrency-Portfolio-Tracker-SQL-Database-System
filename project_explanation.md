# Complete Explanation

## Project Name
Cryptocurrency Portfolio Tracker

## Objective
The objective is to build a normalized SQL database that tracks cryptocurrency portfolios. The system records users, wallets, exchanges, crypto assets, transactions, price history, alerts, watchlists, and portfolio snapshots.

## Why This Project Is Good for GitHub
This project is modern and practical. It shows database design, business rules, constraints, views, procedures, triggers, and analytical queries. It can later be connected with Python, Java, a web app, or a live crypto API.

## Entity Explanation
- users: stores system users.
- cryptocurrencies: stores coins such as BTC, ETH, SOL.
- exchanges: stores exchange platforms.
- wallets: stores exchange, hot, cold, and paper wallets.
- transactions: stores buy, sell, transfer-in, and transfer-out records.
- price_history: stores historical coin prices.
- portfolio_snapshots: stores portfolio value at different times.
- alerts: stores price alert settings.
- watchlist: stores coins that users want to monitor.

## Relationships
- One user has many wallets.
- One user has many transactions.
- One wallet has many transactions.
- One cryptocurrency has many transactions.
- One cryptocurrency has many price history records.
- One user has many alerts.
- One cryptocurrency has many alerts.
- One user has many watchlist records.
- One user has many portfolio snapshots.

## Normalization
The design follows 3NF. Repeated data is separated into independent tables. Transactions reference users, wallets, and cryptocurrencies through foreign keys. Watchlist avoids duplicate user-crypto pairs using a unique constraint.

## Important Business Rules
- Quantity must always be greater than zero.
- Price and fee cannot be negative.
- User email must be unique.
- Crypto symbol must be unique.
- A user cannot add the same crypto twice in the watchlist.
- A sell or transfer-out transaction cannot exceed the available holding.
- Exchange wallets must have an exchange reference.
