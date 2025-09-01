# EFSonic_Sales

📌 Query: Sales & Returns Transactions Report

Description
This query generates a detailed sales and returns report for customers and outlets within a given date range. It provides transaction-level details including customer, outlet, employee (sales rep), item details, quantities, discounts, taxes, and net totals.

Parameters

@Language → Retrieves multilingual descriptions (customer, outlet, brand, model, item, etc.).

@ParFromDate → Start date for filtering transactions.

@ParToDate → End date for filtering transactions.

Key Features

Joins multiple entities:

Organization & Languages

Customers & Outlets

Employees (Sales Reps)

Items, Brands, Models, Categories

Transaction & Transaction Details

Sales vs Returns → Handles both TransactionTypeID = 1 (sales) and TransactionTypeID = 2 (returns) with proper sign adjustments (negative values for returns).

Aggregations:

Quantity (normalized using pack factor).

Price (sum per item).

Discounts → item-level & invoice-level.

Total amount before tax.

Tax amount.

Net total per line.

Group By ensures unique combination of customer, outlet, transaction, item.

Supports multilingual output via LanguageID.

Output Columns

Organization code & name.

Customer & outlet details (IDs, codes, names).

Sales rep name & code.

Transaction ID & date.

Brand, model, item category, item code, and description.

Quantity (positive for sales, negative for returns).

Price before discounts.

Item discount & invoice discount.

Total (gross).

Tax value.

Net total (per item after tax and discounts).

Use Case
✅ Useful for sales performance analysis, customer invoicing, and auditing returns vs sales.
✅ Helps track net revenue, discounts impact, and tax calculations at transaction level.
