-- =============================================================================
-- Restaurant Billing Software - Database Schema Creation
-- Target Engine: PostgreSQL 12+ (Compatible with pgAdmin 4)
-- Strict Conventions:
-- 1. All table names prefixed with tbl_
-- 2. No explicit database constraints (FK, UNIQUE, CHECK enforced via functions & application logic)
-- =============================================================================

-- Enable pgcrypto for UUID generation if available (optional fallback handled in code)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Drop existing tables if re-initializing (in reverse order)
DROP TABLE IF EXISTS tbl_PaymentTransactions;
DROP TABLE IF EXISTS tbl_BillItems;
DROP TABLE IF EXISTS tbl_Bills;
DROP TABLE IF EXISTS tbl_Tables;
DROP TABLE IF EXISTS tbl_MenuItems;
DROP TABLE IF EXISTS tbl_Categories;
DROP TABLE IF EXISTS tbl_Users;
DROP TABLE IF EXISTS tbl_Settings;
DROP TABLE IF EXISTS tbl_ActivityHistory;

-- 1. tbl_Users: System user accounts and authentication
CREATE TABLE tbl_Users (
    user_id VARCHAR(50) PRIMARY KEY,
    username VARCHAR(100),
    password_hash VARCHAR(255),
    full_name VARCHAR(150),
    email VARCHAR(150),
    role VARCHAR(50) DEFAULT 'CASHIER',
    phone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. tbl_Categories: Food and beverage categories
CREATE TABLE tbl_Categories (
    category_id VARCHAR(50) PRIMARY KEY,
    category_name VARCHAR(100),
    description TEXT,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. tbl_MenuItems: Menu item inventory, pricing, and tax details
CREATE TABLE tbl_MenuItems (
    item_id VARCHAR(50) PRIMARY KEY,
    category_id VARCHAR(50),
    item_code VARCHAR(50),
    item_name VARCHAR(150),
    description TEXT,
    price NUMERIC(12, 2) DEFAULT 0.00,
    food_type VARCHAR(50) DEFAULT 'VEG',
    tax_rate NUMERIC(5, 2) DEFAULT 5.00,
    is_available BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. tbl_Tables: Restaurant dining tables and seating capacity
CREATE TABLE tbl_Tables (
    table_id VARCHAR(50) PRIMARY KEY,
    table_number VARCHAR(50),
    seating_capacity INT DEFAULT 4,
    location_area VARCHAR(100) DEFAULT 'Main Dining',
    status VARCHAR(50) DEFAULT 'AVAILABLE',
    current_bill_id VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. tbl_Bills: Bill headers, totals, discounts, taxes, and settlement state
CREATE TABLE tbl_Bills (
    bill_id VARCHAR(50) PRIMARY KEY,
    bill_number VARCHAR(50),
    order_type VARCHAR(50) DEFAULT 'DINE_IN',
    table_id VARCHAR(50),
    customer_name VARCHAR(150),
    customer_phone VARCHAR(50),
    sub_total NUMERIC(12, 2) DEFAULT 0.00,
    discount_type VARCHAR(20) DEFAULT 'NONE',
    discount_value NUMERIC(12, 2) DEFAULT 0.00,
    discount_amount NUMERIC(12, 2) DEFAULT 0.00,
    tax_rate NUMERIC(5, 2) DEFAULT 5.00,
    tax_amount NUMERIC(12, 2) DEFAULT 0.00,
    round_off NUMERIC(6, 2) DEFAULT 0.00,
    grand_total NUMERIC(12, 2) DEFAULT 0.00,
    payment_mode VARCHAR(50) DEFAULT 'UNPAID',
    payment_status VARCHAR(50) DEFAULT 'PENDING',
    bill_status VARCHAR(50) DEFAULT 'ACTIVE',
    notes TEXT,
    cashier_id VARCHAR(50),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    settled_at TIMESTAMP WITHOUT TIME ZONE,
    cancelled_at TIMESTAMP WITHOUT TIME ZONE,
    cancellation_reason TEXT
);

-- 6. tbl_BillItems: Line items associated with bills
CREATE TABLE tbl_BillItems (
    bill_item_id VARCHAR(50) PRIMARY KEY,
    bill_id VARCHAR(50),
    item_id VARCHAR(50),
    item_name VARCHAR(150),
    quantity NUMERIC(10, 2) DEFAULT 1.00,
    unit_price NUMERIC(12, 2) DEFAULT 0.00,
    tax_rate NUMERIC(5, 2) DEFAULT 0.00,
    tax_amount NUMERIC(12, 2) DEFAULT 0.00,
    total_price NUMERIC(12, 2) DEFAULT 0.00,
    notes TEXT,
    is_cancelled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. tbl_PaymentTransactions: Financial payment receipts and split payments
CREATE TABLE tbl_PaymentTransactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    bill_id VARCHAR(50),
    payment_mode VARCHAR(50),
    amount NUMERIC(12, 2) DEFAULT 0.00,
    reference_number VARCHAR(100),
    transaction_status VARCHAR(50) DEFAULT 'SUCCESS',
    transaction_date TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- 8. tbl_Settings: Restaurant profile, taxation, printing, and configuration
CREATE TABLE tbl_Settings (
    setting_id VARCHAR(50) PRIMARY KEY,
    setting_key VARCHAR(100),
    setting_value TEXT,
    description TEXT,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. tbl_ActivityHistory: Centralized immutable system audit trail
CREATE TABLE tbl_ActivityHistory (
    activity_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    username VARCHAR(100),
    activity_type VARCHAR(100),
    module VARCHAR(100),
    description TEXT,
    record_id VARCHAR(100),
    old_value JSONB,
    new_value JSONB,
    ip_address VARCHAR(50),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Standard performance indexes on frequent lookup fields (non-constraint)
CREATE INDEX idx_users_username ON tbl_Users(username);
CREATE INDEX idx_menu_category ON tbl_MenuItems(category_id);
CREATE INDEX idx_menu_code ON tbl_MenuItems(item_code);
CREATE INDEX idx_tables_number ON tbl_Tables(table_number);
CREATE INDEX idx_bills_number ON tbl_Bills(bill_number);
CREATE INDEX idx_bills_created ON tbl_Bills(created_at);
CREATE INDEX idx_billitems_bill ON tbl_BillItems(bill_id);
CREATE INDEX idx_activity_created ON tbl_ActivityHistory(created_at);
CREATE INDEX idx_activity_module ON tbl_ActivityHistory(module);
