# PostgreSQL Database Architecture & Data Dictionary

## 1. Overview & Strict Compliance Rules
- **Prefix Convention**: All tables prefixed with `tbl_` (e.g. `tbl_Users`, `tbl_Bills`, `tbl_BillItems`).
- **Function Convention**: All procedures/functions prefixed with `fn_` (e.g. `fn_UserLogin`, `fn_CreateBill`, `fn_GetBillDetails`).
- **Function Only Execution**: The Java backend calls these PostgreSQL functions exclusively for all data interactions.
- **Constraint Requirement**: No explicit database constraints (NO foreign key constraints, NO unique constraints, NO check constraints on `CREATE TABLE`). All validation and referential integrity is guaranteed logically by application services and stored functions.

---

## 2. Table Specifications (`tbl_*`)

### 1. `tbl_Users`
Stores system accounts, roles, and hashed credentials.
- `user_id` (VARCHAR(50), Primary Key)
- `username` (VARCHAR(100))
- `password_hash` (VARCHAR(255))
- `full_name` (VARCHAR(150))
- `email` (VARCHAR(150))
- `role` (VARCHAR(50)) -- `ADMIN`, `CASHIER`, `MANAGER`, `WAITER`
- `phone` (VARCHAR(50))
- `is_active` (BOOLEAN, Default: TRUE)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### 2. `tbl_Categories`
Food and beverage grouping.
- `category_id` (VARCHAR(50), Primary Key)
- `category_name` (VARCHAR(100))
- `description` (TEXT)
- `display_order` (INT)
- `is_active` (BOOLEAN, Default: TRUE)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### 3. `tbl_MenuItems`
Catalog of food & drinks with pricing and tax rate.
- `item_id` (VARCHAR(50), Primary Key)
- `category_id` (VARCHAR(50))
- `item_code` (VARCHAR(50))
- `item_name` (VARCHAR(150))
- `description` (TEXT)
- `price` (NUMERIC(12, 2))
- `food_type` (VARCHAR(50)) -- `VEG`, `NON_VEG`, `BEVERAGE`, `DESSERT`
- `tax_rate` (NUMERIC(5, 2))
- `is_available` (BOOLEAN, Default: TRUE)
- `is_active` (BOOLEAN, Default: TRUE)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### 4. `tbl_Tables`
Dining layout management.
- `table_id` (VARCHAR(50), Primary Key)
- `table_number` (VARCHAR(50))
- `seating_capacity` (INT)
- `location_area` (VARCHAR(100))
- `status` (VARCHAR(50)) -- `AVAILABLE`, `OCCUPIED`, `BILLED`, `RESERVED`
- `current_bill_id` (VARCHAR(50))
- `is_active` (BOOLEAN)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### 5. `tbl_Bills`
Master bill headers, arithmetic calculations, and settlement states.
- `bill_id` (VARCHAR(50), Primary Key)
- `bill_number` (VARCHAR(50))
- `order_type` (VARCHAR(50)) -- `DINE_IN`, `TAKEAWAY`, `DELIVERY`
- `table_id` (VARCHAR(50))
- `customer_name` (VARCHAR(150))
- `customer_phone` (VARCHAR(50))
- `sub_total` (NUMERIC(12, 2))
- `discount_type` (VARCHAR(20)) -- `PERCENT`, `FLAT`, `NONE`
- `discount_value` (NUMERIC(12, 2))
- `discount_amount` (NUMERIC(12, 2))
- `tax_rate` (NUMERIC(5, 2))
- `tax_amount` (NUMERIC(12, 2))
- `round_off` (NUMERIC(6, 2))
- `grand_total` (NUMERIC(12, 2))
- `payment_mode` (VARCHAR(50)) -- `CASH`, `CARD`, `UPI`, `SPLIT`, `UNPAID`
- `payment_status` (VARCHAR(50)) -- `PENDING`, `PAID`, `REFUNDED`
- `bill_status` (VARCHAR(50)) -- `ACTIVE`, `SETTLED`, `CANCELLED`
- `notes` (TEXT)
- `cashier_id` (VARCHAR(50))
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)
- `settled_at` (TIMESTAMP)
- `cancelled_at` (TIMESTAMP)
- `cancellation_reason` (TEXT)

### 6. `tbl_BillItems`
Line items associated with bills.
- `bill_item_id` (VARCHAR(50), Primary Key)
- `bill_id` (VARCHAR(50))
- `item_id` (VARCHAR(50))
- `item_name` (VARCHAR(150))
- `quantity` (NUMERIC(10, 2))
- `unit_price` (NUMERIC(12, 2))
- `tax_rate` (NUMERIC(5, 2))
- `tax_amount` (NUMERIC(12, 2))
- `total_price` (NUMERIC(12, 2))
- `notes` (TEXT)
- `is_cancelled` (BOOLEAN)
- `created_at` (TIMESTAMP)

### 7. `tbl_PaymentTransactions`
Financial payment records.
- `transaction_id` (VARCHAR(50), Primary Key)
- `bill_id` (VARCHAR(50))
- `payment_mode` (VARCHAR(50))
- `amount` (NUMERIC(12, 2))
- `reference_number` (VARCHAR(100))
- `transaction_status` (VARCHAR(50))
- `transaction_date` (TIMESTAMP)
- `notes` (TEXT)

### 8. `tbl_Settings`
Key-value business and receipt configurations.
- `setting_id` (VARCHAR(50), Primary Key)
- `setting_key` (VARCHAR(100))
- `setting_value` (TEXT)
- `description` (TEXT)
- `updated_at` (TIMESTAMP)

### 9. `tbl_ActivityHistory`
Centralized immutable audit trail.
- `activity_id` (VARCHAR(50), Primary Key)
- `user_id` (VARCHAR(50))
- `username` (VARCHAR(100))
- `activity_type` (VARCHAR(100))
- `module` (VARCHAR(100))
- `description` (TEXT)
- `record_id` (VARCHAR(100))
- `old_value` (JSONB)
- `new_value` (JSONB)
- `ip_address` (VARCHAR(50))
- `created_at` (TIMESTAMP)

---

## 3. PostgreSQL Functions Catalog (`fn_*`)
All functions return standard composite records:
`(is_successful BOOLEAN, res_code VARCHAR, res_msg VARCHAR, created_id VARCHAR, total_records INT, max_pages INT, result_data JSONB)`

1. `fn_LogActivity` - Records events to `tbl_ActivityHistory`.
2. `fn_GetActivityHistory` - Paginated fetch of audit trail.
3. `fn_UserLogin` - Validates credentials & logs attempts.
4. `fn_UserCreate` - Creates user account with uniqueness check.
5. `fn_UserUpdate` - Modifies staff account profile.
6. `fn_UserChangePassword` - Updates password hash.
7. `fn_UserGetAll` - Paginated user retrieval.
8. `fn_CategoryCreate` - Creates menu category.
9. `fn_CategoryUpdate` - Modifies category.
10. `fn_CategoryGetAll` - Fetches active categories.
11. `fn_MenuItemCreate` - Adds food item with pricing and taxes.
12. `fn_MenuItemUpdate` - Updates dish specifications.
13. `fn_MenuItemGetAll` - Filters by category, availability, search.
14. `fn_TableCreate` - Configures dining table.
15. `fn_TableUpdateStatus` - Sets table state (AVAILABLE, OCCUPIED).
16. `fn_TableGetAll` - Lists dining layout with active order links.
17. `fn_CreateBill` - Atomic transaction creating bill & line items.
18. `fn_SettleBill` - Settle bill, record payment, free dining table.
19. `fn_CancelBill` - Cancel bill with mandatory audit reason.
20. `fn_GetBillDetails` - Returns full receipt payload with line items.
21. `fn_GetBillList` - Paginated transaction search.
22. `fn_GetDashboardMetrics` - Real-time sales, occupancy, top dishes.
23. `fn_GetSalesReport` - Period financial revenue breakdown.
24. `fn_GetSettings` - Loads restaurant configuration.
25. `fn_UpdateSettings` - Persists restaurant profile and tax rates.
