-- =============================================================================
-- Restaurant Billing Software - Asset & Vendor Management Schema
-- Target Engine: PostgreSQL 12+ (Compatible with pgAdmin 4)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Vendors Table
CREATE TABLE IF NOT EXISTS tbl_vendors (
    vendor_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(150),
    address TEXT,
    gstin VARCHAR(50),
    category VARCHAR(100) DEFAULT 'General',
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Assets Table
CREATE TABLE IF NOT EXISTS tbl_assets (
    asset_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_code VARCHAR(50),
    asset_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) DEFAULT 'Equipment',
    vendor_id UUID,
    vendor_name VARCHAR(150),
    purchase_date DATE DEFAULT CURRENT_DATE,
    cost_price NUMERIC(12, 2) DEFAULT 0.00,
    quantity INT DEFAULT 1,
    location_area VARCHAR(100) DEFAULT 'Kitchen',
    condition_status VARCHAR(50) DEFAULT 'OPERATIONAL',
    warranty_expiry DATE,
    notes TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Purchases Table
CREATE TABLE IF NOT EXISTS tbl_purchases (
    purchase_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_number VARCHAR(100),
    vendor_id UUID,
    vendor_name VARCHAR(150),
    purchase_date DATE DEFAULT CURRENT_DATE,
    total_amount NUMERIC(12, 2) DEFAULT 0.00,
    tax_amount NUMERIC(12, 2) DEFAULT 0.00,
    payment_status VARCHAR(50) DEFAULT 'PAID',
    payment_mode VARCHAR(50) DEFAULT 'CASH',
    items_description TEXT,
    notes TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for fast query performance
CREATE INDEX IF NOT EXISTS idx_vendors_name ON tbl_vendors(vendor_name);
CREATE INDEX IF NOT EXISTS idx_assets_code ON tbl_assets(asset_code);
CREATE INDEX IF NOT EXISTS idx_assets_category ON tbl_assets(category);
CREATE INDEX IF NOT EXISTS idx_purchases_date ON tbl_purchases(purchase_date);
CREATE INDEX IF NOT EXISTS idx_purchases_vendor ON tbl_purchases(vendor_id);

-- Seed Data: Sample Vendors
INSERT INTO tbl_vendors (vendor_id, vendor_name, contact_person, phone, email, address, gstin, category, status)
VALUES
  ('a1b2c3d4-0001-4000-8000-000000000001', 'Metro Cash & Carry Supplies', 'Ramesh Sharma', '+91 98410 11223', 'orders@metrocash.in', 'Plot 45, Industrial Estate, Chennai', '33AABCM1234D1Z2', 'Raw Materials & Provisions', 'ACTIVE'),
  ('a1b2c3d4-0001-4000-8000-000000000002', 'Apex Kitchen Technologies', 'Suresh Kumar', '+91 98401 55667', 'sales@apexkitchen.com', '12/4, Guindy Industrial Area, Chennai', '33AAAPL9876E1Z5', 'Kitchen Equipment & Machinery', 'ACTIVE'),
  ('a1b2c3d4-0001-4000-8000-000000000003', 'Modern POS & Thermal Paper Systems', 'Priya Menon', '+91 97900 88990', 'support@modernpos.in', '88, Mount Road, Thousand Lights, Chennai', '33BBMPP4455F1Z8', 'POS Hardware & Billing Electronics', 'ACTIVE'),
  ('a1b2c3d4-0001-4000-8000-000000000004', 'Royal Teak & Steel Furnitures', 'Abdul Rahman', '+91 99620 33445', 'info@royalteak.com', '5, Wood Market Street, Chennai', '33CCRTF7788G1Z1', 'Dining & Hall Furniture', 'ACTIVE')
ON CONFLICT (vendor_id) DO NOTHING;

-- Seed Data: Sample Assets
INSERT INTO tbl_assets (asset_id, asset_code, asset_name, category, vendor_id, vendor_name, purchase_date, cost_price, quantity, location_area, condition_status, warranty_expiry, notes)
VALUES
  ('b1c2d3e4-0002-4000-8000-000000000001', 'AST-101', 'Commercial Heavy-Duty 3-Burner Range', 'Kitchen Equipment', 'a1b2c3d4-0001-4000-8000-000000000002', 'Apex Kitchen Technologies', '2026-01-15', 45000.00, 2, 'Main Kitchen', 'OPERATIONAL', '2028-01-15', 'High-pressure burner range with SS body'),
  ('b1c2d3e4-0002-4000-8000-000000000002', 'AST-102', 'Double-Door Deep Freezer 400L', 'Refrigeration', 'a1b2c3d4-0001-4000-8000-000000000002', 'Apex Kitchen Technologies', '2026-02-10', 38500.00, 1, 'Cold Storage', 'OPERATIONAL', '2027-02-10', 'Temperature range -18C to -22C'),
  ('b1c2d3e4-0002-4000-8000-000000000003', 'AST-103', 'Epson 80mm High-Speed Thermal Receipt Printer', 'Electronics & POS', 'a1b2c3d4-0001-4000-8000-000000000003', 'Modern POS & Thermal Paper Systems', '2026-03-01', 12500.00, 3, 'Billing Counter', 'OPERATIONAL', '2027-03-01', 'USB + Ethernet LAN auto-cutter printer'),
  ('b1c2d3e4-0002-4000-8000-000000000004', 'AST-104', 'Commercial Wet Grinder 10L Tilting', 'Kitchen Equipment', 'a1b2c3d4-0001-4000-8000-000000000002', 'Apex Kitchen Technologies', '2026-02-20', 22000.00, 1, 'Prep Kitchen', 'OPERATIONAL', '2027-02-20', 'Stainless steel tilting drum with heavy motor'),
  ('b1c2d3e4-0002-4000-8000-000000000005', 'AST-105', 'Teak Wood Dining Table with Glass Top 4-Seater', 'Furniture', 'a1b2c3d4-0001-4000-8000-000000000004', 'Royal Teak & Steel Furnitures', '2026-01-20', 14000.00, 10, 'Main Dining Hall', 'OPERATIONAL', '2030-01-20', 'Includes 4 matching upholstered chairs')
ON CONFLICT (asset_id) DO NOTHING;

-- Seed Data: Sample Purchases
INSERT INTO tbl_purchases (purchase_id, invoice_number, vendor_id, vendor_name, purchase_date, total_amount, tax_amount, payment_status, payment_mode, items_description, notes)
VALUES
  ('c1d2e3f4-0003-4000-8000-000000000001', 'INV-2026-0042', 'a1b2c3d4-0001-4000-8000-000000000002', 'Apex Kitchen Technologies', '2026-01-15', 90000.00, 16200.00, 'PAID', 'BANK_TRANSFER', '2x Commercial Heavy-Duty 3-Burner Range', 'Delivered and installed in main kitchen'),
  ('c1d2e3f4-0003-4000-8000-000000000002', 'INV-2026-0118', 'a1b2c3d4-0001-4000-8000-000000000003', 'Modern POS & Thermal Paper Systems', '2026-03-01', 37500.00, 6750.00, 'PAID', 'UPI', '3x Epson 80mm Thermal Receipt Printers + 50 Thermal Paper Rolls', 'Billing counter setup'),
  ('c1d2e3f4-0003-4000-8000-000000000003', 'INV-2026-0294', 'a1b2c3d4-0001-4000-8000-000000000001', 'Metro Cash & Carry Supplies', '2026-10-20', 28400.00, 1420.00, 'PAID', 'CASH', 'Monthly Cooking Oils, Basmati Rice (100kg), Whole Spices, Ghee', 'Monthly pantry replenishment')
ON CONFLICT (purchase_id) DO NOTHING;

-- =============================================================================
-- STORED FUNCTIONS FOR ASSET MANAGEMENT
-- =============================================================================

-- 1. Vendors Functions
CREATE OR REPLACE FUNCTION fn_VendorGetAll()
RETURNS TABLE (
    is_successful BOOLEAN,
    res_code VARCHAR,
    res_msg VARCHAR,
    created_id VARCHAR,
    total_records INT,
    max_pages INT,
    result_data JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
    v_total INT;
BEGIN
    SELECT jsonb_agg(
        jsonb_build_object(
            'vendorId', v.vendor_id::text,
            'vendorName', v.vendor_name,
            'contactPerson', v.contact_person,
            'phone', v.phone,
            'email', v.email,
            'address', v.address,
            'gstin', v.gstin,
            'category', v.category,
            'status', v.status,
            'createdAt', to_char(v.created_at, 'YYYY-MM-DD"T"HH24:MI:SS'),
            'updatedAt', to_char(v.updated_at, 'YYYY-MM-DD"T"HH24:MI:SS')
        ) ORDER BY v.created_at DESC
    ) INTO v_result
    FROM tbl_vendors v;

    SELECT COUNT(*) INTO v_total FROM tbl_vendors;

    RETURN QUERY
    SELECT 
        TRUE, 
        'SUCCESS'::VARCHAR, 
        'Vendors fetched successfully'::VARCHAR, 
        NULL::VARCHAR, 
        COALESCE(v_total, 0), 
        1, 
        COALESCE(v_result, '[]'::jsonb);
END;
$$;

CREATE OR REPLACE FUNCTION fn_VendorSave(
    p_vendor_id VARCHAR,
    p_vendor_name VARCHAR,
    p_contact_person VARCHAR,
    p_phone VARCHAR,
    p_email VARCHAR,
    p_address TEXT,
    p_gstin VARCHAR,
    p_category VARCHAR,
    p_status VARCHAR,
    p_actor_id VARCHAR
)
RETURNS TABLE (
    is_successful BOOLEAN,
    res_code VARCHAR,
    res_msg VARCHAR,
    created_id VARCHAR,
    total_records INT,
    max_pages INT,
    result_data JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id UUID;
    v_result JSONB;
BEGIN
    IF p_vendor_id IS NULL OR trim(p_vendor_id) = '' THEN
        v_id := gen_random_uuid();
        INSERT INTO tbl_vendors (
            vendor_id, vendor_name, contact_person, phone, email, address, gstin, category, status, created_at, updated_at
        ) VALUES (
            v_id, p_vendor_name, p_contact_person, p_phone, p_email, p_address, p_gstin, COALESCE(p_category, 'General'), COALESCE(p_status, 'ACTIVE'), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        );
    ELSE
        v_id := p_vendor_id::uuid;
        UPDATE tbl_vendors
        SET vendor_name = p_vendor_name,
            contact_person = p_contact_person,
            phone = p_phone,
            email = p_email,
            address = p_address,
            gstin = p_gstin,
            category = COALESCE(p_category, category),
            status = COALESCE(p_status, status),
            updated_at = CURRENT_TIMESTAMP
        WHERE vendor_id = v_id;
    END IF;

    SELECT jsonb_build_object(
        'vendorId', v.vendor_id::text,
        'vendorName', v.vendor_name,
        'contactPerson', v.contact_person,
        'phone', v.phone,
        'email', v.email,
        'address', v.address,
        'gstin', v.gstin,
        'category', v.category,
        'status', v.status
    ) INTO v_result
    FROM tbl_vendors v WHERE v.vendor_id = v_id;

    RETURN QUERY
    SELECT TRUE, 'SUCCESS'::VARCHAR, 'Vendor saved successfully'::VARCHAR, v_id::VARCHAR, 1, 1, v_result;
END;
$$;

CREATE OR REPLACE FUNCTION fn_VendorDelete(
    p_vendor_id VARCHAR,
    p_actor_id VARCHAR
)
RETURNS TABLE (
    is_successful BOOLEAN,
    res_code VARCHAR,
    res_msg VARCHAR,
    created_id VARCHAR,
    total_records INT,
    max_pages INT,
    result_data JSONB
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM tbl_vendors WHERE vendor_id = p_vendor_id::uuid;
    RETURN QUERY
    SELECT TRUE, 'SUCCESS'::VARCHAR, 'Vendor deleted successfully'::VARCHAR, p_vendor_id, 1, 1, '{}'::jsonb;
END;
$$;

-- 2. Assets Functions
CREATE OR REPLACE FUNCTION fn_AssetGetAll()
RETURNS TABLE (
    is_successful BOOLEAN,
    res_code VARCHAR,
    res_msg VARCHAR,
    created_id VARCHAR,
    total_records INT,
    max_pages INT,
    result_data JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
    v_total INT;
BEGIN
    SELECT jsonb_agg(
        jsonb_build_object(
            'assetId', a.asset_id::text,
            'assetCode', a.asset_code,
            'assetName', a.asset_name,
            'category', a.category,
            'vendorId', a.vendor_id::text,
            'vendorName', a.vendor_name,
            'purchaseDate', a.purchase_date::text,
            'costPrice', a.cost_price,
            'quantity', a.quantity,
            'locationArea', a.location_area,
            'conditionStatus', a.condition_status,
            'warrantyExpiry', a.warranty_expiry::text,
            'notes', a.notes,
            'createdAt', to_char(a.created_at, 'YYYY-MM-DD"T"HH24:MI:SS'),
            'updatedAt', to_char(a.updated_at, 'YYYY-MM-DD"T"HH24:MI:SS')
        ) ORDER BY a.created_at DESC
    ) INTO v_result
    FROM tbl_assets a;

    SELECT COUNT(*) INTO v_total FROM tbl_assets;

    RETURN QUERY
    SELECT 
        TRUE, 
        'SUCCESS'::VARCHAR, 
        'Assets fetched successfully'::VARCHAR, 
        NULL::VARCHAR, 
        COALESCE(v_total, 0), 
        1, 
        COALESCE(v_result, '[]'::jsonb);
END;
$$;

CREATE OR REPLACE FUNCTION fn_AssetSave(
    p_asset_id VARCHAR,
    p_asset_code VARCHAR,
    p_asset_name VARCHAR,
    p_category VARCHAR,
    p_vendor_id VARCHAR,
    p_vendor_name VARCHAR,
    p_purchase_date VARCHAR,
    p_cost_price NUMERIC,
    p_quantity INT,
    p_location_area VARCHAR,
    p_condition_status VARCHAR,
    p_warranty_expiry VARCHAR,
    p_notes TEXT,
    p_actor_id VARCHAR
)
RETURNS TABLE (
    is_successful BOOLEAN,
    res_code VARCHAR,
    res_msg VARCHAR,
    created_id VARCHAR,
    total_records INT,
    max_pages INT,
    result_data JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id UUID;
    v_vendor_uuid UUID;
    v_p_date DATE;
    v_w_date DATE;
    v_result JSONB;
BEGIN
    v_vendor_uuid := CASE WHEN p_vendor_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN p_vendor_id::uuid ELSE NULL END;
    v_p_date := CASE WHEN p_purchase_date IS NOT NULL AND trim(p_purchase_date) != '' THEN p_purchase_date::date ELSE CURRENT_DATE END;
    v_w_date := CASE WHEN p_warranty_expiry IS NOT NULL AND trim(p_warranty_expiry) != '' THEN p_warranty_expiry::date ELSE NULL END;

    IF p_asset_id IS NULL OR trim(p_asset_id) = '' THEN
        v_id := gen_random_uuid();
        INSERT INTO tbl_assets (
            asset_id, asset_code, asset_name, category, vendor_id, vendor_name, purchase_date, cost_price, quantity, location_area, condition_status, warranty_expiry, notes, created_at, updated_at
        ) VALUES (
            v_id, p_asset_code, p_asset_name, COALESCE(p_category, 'Equipment'), v_vendor_uuid, p_vendor_name, v_p_date, COALESCE(p_cost_price, 0.00), COALESCE(p_quantity, 1), COALESCE(p_location_area, 'Kitchen'), COALESCE(p_condition_status, 'OPERATIONAL'), v_w_date, p_notes, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        );
    ELSE
        v_id := p_asset_id::uuid;
        UPDATE tbl_assets
        SET asset_code = p_asset_code,
            asset_name = p_asset_name,
            category = COALESCE(p_category, category),
            vendor_id = v_vendor_uuid,
            vendor_name = p_vendor_name,
            purchase_date = v_p_date,
            cost_price = COALESCE(p_cost_price, cost_price),
            quantity = COALESCE(p_quantity, quantity),
            location_area = COALESCE(p_location_area, location_area),
            condition_status = COALESCE(p_condition_status, condition_status),
            warranty_expiry = v_w_date,
            notes = p_notes,
            updated_at = CURRENT_TIMESTAMP
        WHERE asset_id = v_id;
    END IF;

    SELECT jsonb_build_object(
        'assetId', a.asset_id::text,
        'assetCode', a.asset_code,
        'assetName', a.asset_name,
        'category', a.category,
        'vendorId', a.vendor_id::text,
        'vendorName', a.vendor_name,
        'purchaseDate', a.purchase_date::text,
        'costPrice', a.cost_price,
        'quantity', a.quantity,
        'locationArea', a.location_area,
        'conditionStatus', a.condition_status,
        'warrantyExpiry', a.warranty_expiry::text,
        'notes', a.notes
    ) INTO v_result
    FROM tbl_assets a WHERE a.asset_id = v_id;

    RETURN QUERY
    SELECT TRUE, 'SUCCESS'::VARCHAR, 'Asset saved successfully'::VARCHAR, v_id::VARCHAR, 1, 1, v_result;
END;
$$;

CREATE OR REPLACE FUNCTION fn_AssetDelete(
    p_asset_id VARCHAR,
    p_actor_id VARCHAR
)
RETURNS TABLE (
    is_successful BOOLEAN,
    res_code VARCHAR,
    res_msg VARCHAR,
    created_id VARCHAR,
    total_records INT,
    max_pages INT,
    result_data JSONB
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM tbl_assets WHERE asset_id = p_asset_id::uuid;
    RETURN QUERY
    SELECT TRUE, 'SUCCESS'::VARCHAR, 'Asset deleted successfully'::VARCHAR, p_asset_id, 1, 1, '{}'::jsonb;
END;
$$;

-- 3. Purchases Functions
CREATE OR REPLACE FUNCTION fn_PurchaseGetAll()
RETURNS TABLE (
    is_successful BOOLEAN,
    res_code VARCHAR,
    res_msg VARCHAR,
    created_id VARCHAR,
    total_records INT,
    max_pages INT,
    result_data JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
    v_total INT;
BEGIN
    SELECT jsonb_agg(
        jsonb_build_object(
            'purchaseId', p.purchase_id::text,
            'invoiceNumber', p.invoice_number,
            'vendorId', p.vendor_id::text,
            'vendorName', p.vendor_name,
            'purchaseDate', p.purchase_date::text,
            'totalAmount', p.total_amount,
            'taxAmount', p.tax_amount,
            'paymentStatus', p.payment_status,
            'paymentMode', p.payment_mode,
            'itemsDescription', p.items_description,
            'notes', p.notes,
            'createdAt', to_char(p.created_at, 'YYYY-MM-DD"T"HH24:MI:SS'),
            'updatedAt', to_char(p.updated_at, 'YYYY-MM-DD"T"HH24:MI:SS')
        ) ORDER BY p.purchase_date DESC, p.created_at DESC
    ) INTO v_result
    FROM tbl_purchases p;

    SELECT COUNT(*) INTO v_total FROM tbl_purchases;

    RETURN QUERY
    SELECT 
        TRUE, 
        'SUCCESS'::VARCHAR, 
        'Purchases fetched successfully'::VARCHAR, 
        NULL::VARCHAR, 
        COALESCE(v_total, 0), 
        1, 
        COALESCE(v_result, '[]'::jsonb);
END;
$$;

CREATE OR REPLACE FUNCTION fn_PurchaseSave(
    p_purchase_id VARCHAR,
    p_invoice_number VARCHAR,
    p_vendor_id VARCHAR,
    p_vendor_name VARCHAR,
    p_purchase_date VARCHAR,
    p_total_amount NUMERIC,
    p_tax_amount NUMERIC,
    p_payment_status VARCHAR,
    p_payment_mode VARCHAR,
    p_items_description TEXT,
    p_notes TEXT,
    p_actor_id VARCHAR
)
RETURNS TABLE (
    is_successful BOOLEAN,
    res_code VARCHAR,
    res_msg VARCHAR,
    created_id VARCHAR,
    total_records INT,
    max_pages INT,
    result_data JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id UUID;
    v_vendor_uuid UUID;
    v_p_date DATE;
    v_result JSONB;
BEGIN
    v_vendor_uuid := CASE WHEN p_vendor_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN p_vendor_id::uuid ELSE NULL END;
    v_p_date := CASE WHEN p_purchase_date IS NOT NULL AND trim(p_purchase_date) != '' THEN p_purchase_date::date ELSE CURRENT_DATE END;

    IF p_purchase_id IS NULL OR trim(p_purchase_id) = '' THEN
        v_id := gen_random_uuid();
        INSERT INTO tbl_purchases (
            purchase_id, invoice_number, vendor_id, vendor_name, purchase_date, total_amount, tax_amount, payment_status, payment_mode, items_description, notes, created_at, updated_at
        ) VALUES (
            v_id, p_invoice_number, v_vendor_uuid, p_vendor_name, v_p_date, COALESCE(p_total_amount, 0.00), COALESCE(p_tax_amount, 0.00), COALESCE(p_payment_status, 'PAID'), COALESCE(p_payment_mode, 'CASH'), p_items_description, p_notes, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        );
    ELSE
        v_id := p_purchase_id::uuid;
        UPDATE tbl_purchases
        SET invoice_number = p_invoice_number,
            vendor_id = v_vendor_uuid,
            vendor_name = p_vendor_name,
            purchase_date = v_p_date,
            total_amount = COALESCE(p_total_amount, total_amount),
            tax_amount = COALESCE(p_tax_amount, tax_amount),
            payment_status = COALESCE(p_payment_status, payment_status),
            payment_mode = COALESCE(p_payment_mode, payment_mode),
            items_description = p_items_description,
            notes = p_notes,
            updated_at = CURRENT_TIMESTAMP
        WHERE purchase_id = v_id;
    END IF;

    SELECT jsonb_build_object(
        'purchaseId', p.purchase_id::text,
        'invoiceNumber', p.invoice_number,
        'vendorId', p.vendor_id::text,
        'vendorName', p.vendor_name,
        'purchaseDate', p.purchase_date::text,
        'totalAmount', p.total_amount,
        'taxAmount', p.tax_amount,
        'paymentStatus', p.payment_status,
        'paymentMode', p.payment_mode,
        'itemsDescription', p.items_description,
        'notes', p.notes
    ) INTO v_result
    FROM tbl_purchases p WHERE p.purchase_id = v_id;

    RETURN QUERY
    SELECT TRUE, 'SUCCESS'::VARCHAR, 'Purchase saved successfully'::VARCHAR, v_id::VARCHAR, 1, 1, v_result;
END;
$$;

CREATE OR REPLACE FUNCTION fn_PurchaseDelete(
    p_purchase_id VARCHAR,
    p_actor_id VARCHAR
)
RETURNS TABLE (
    is_successful BOOLEAN,
    res_code VARCHAR,
    res_msg VARCHAR,
    created_id VARCHAR,
    total_records INT,
    max_pages INT,
    result_data JSONB
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM tbl_purchases WHERE purchase_id = p_purchase_id::uuid;
    RETURN QUERY
    SELECT TRUE, 'SUCCESS'::VARCHAR, 'Purchase deleted successfully'::VARCHAR, p_purchase_id, 1, 1, '{}'::jsonb;
END;
$$;

-- 4. Asset Summary Metrics
CREATE OR REPLACE FUNCTION fn_AssetGetSummary()
RETURNS TABLE (
    is_successful BOOLEAN,
    res_code VARCHAR,
    res_msg VARCHAR,
    created_id VARCHAR,
    total_records INT,
    max_pages INT,
    result_data JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_value NUMERIC;
    v_total_assets INT;
    v_total_vendors INT;
    v_total_purchases NUMERIC;
    v_operational_count INT;
    v_maintenance_count INT;
    v_result JSONB;
BEGIN
    SELECT COALESCE(SUM(cost_price * quantity), 0), COALESCE(SUM(quantity), 0)
    INTO v_total_value, v_total_assets
    FROM tbl_assets;

    SELECT COUNT(*) INTO v_total_vendors FROM tbl_vendors;

    SELECT COALESCE(SUM(total_amount), 0) INTO v_total_purchases FROM tbl_purchases;

    SELECT COALESCE(SUM(quantity), 0) INTO v_operational_count
    FROM tbl_assets WHERE condition_status IN ('OPERATIONAL', 'GOOD', 'In Use', 'Good');

    SELECT COALESCE(SUM(quantity), 0) INTO v_maintenance_count
    FROM tbl_assets WHERE condition_status IN ('MAINTENANCE', 'REPAIR_NEEDED', 'Under Maintenance', 'Needs Repair');

    v_result := jsonb_build_object(
        'totalAssetValue', v_total_value,
        'totalAssetsCount', v_total_assets,
        'totalVendorsCount', v_total_vendors,
        'totalPurchasesAmount', v_total_purchases,
        'operationalAssetsCount', v_operational_count,
        'maintenanceAssetsCount', v_maintenance_count
    );

    RETURN QUERY
    SELECT TRUE, 'SUCCESS'::VARCHAR, 'Asset summary fetched'::VARCHAR, NULL::VARCHAR, 1, 1, v_result;
END;
$$;

