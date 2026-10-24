-- =============================================================================
-- Restaurant Billing Software - PostgreSQL Stored Functions
-- Target Engine: PostgreSQL 12+ (Compatible with pgAdmin 4)
-- Strict Conventions:
-- 1. All functions prefixed with fn_
-- 2. Returns standardized composite structure mirroring C# DbExecutionResult:
--    (is_successful, res_code, res_msg, created_id, total_records, max_pages, result_data)
-- 3. All database operations executed exclusively via these functions
-- =============================================================================

-- =============================================================================
-- 1. AUDIT TRAIL LOGGING FUNCTION: fn_LogActivity
-- =============================================================================
CREATE OR REPLACE FUNCTION fn_LogActivity(
    p_user_id VARCHAR,
    p_username VARCHAR,
    p_activity_type VARCHAR,
    p_module VARCHAR,
    p_description TEXT,
    p_record_id VARCHAR,
    p_old_val JSONB DEFAULT NULL,
    p_new_val JSONB DEFAULT NULL,
    p_ip_address VARCHAR DEFAULT '127.0.0.1'
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
    v_act_id UUID;
    v_user_uuid UUID;
BEGIN
    v_act_id := gen_random_uuid();
    v_user_uuid := CASE WHEN p_user_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN p_user_id::uuid ELSE NULL END;

    INSERT INTO tbl_ActivityHistory (
        activity_id, user_id, username, activity_type, module,
        description, record_id, old_value, new_value, ip_address, created_at
    ) VALUES (
        v_act_id, v_user_uuid, p_username, p_activity_type, p_module,
        p_description, p_record_id, p_old_val, p_new_val, p_ip_address, CURRENT_TIMESTAMP
    );

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Activity logged successfully'::VARCHAR, v_act_id::VARCHAR, 1, 1, jsonb_build_object('activityId', v_act_id::text);
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'ACT_ERR'::VARCHAR, SQLERRM::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
END;
$$;

-- =============================================================================
-- 2. GET ACTIVITY HISTORY (PAGINATED): fn_GetActivityHistory
-- =============================================================================
CREATE OR REPLACE FUNCTION fn_GetActivityHistory(
    p_page_number INT DEFAULT 1,
    p_page_size INT DEFAULT 20,
    p_module VARCHAR DEFAULT NULL,
    p_activity_type VARCHAR DEFAULT NULL,
    p_from_date TIMESTAMP DEFAULT NULL,
    p_to_date TIMESTAMP DEFAULT NULL
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
    v_offset INT;
    v_total INT;
    v_pages INT;
    v_result JSONB;
BEGIN
    v_offset := (GREATEST(p_page_number, 1) - 1) * GREATEST(p_page_size, 1);

    SELECT COUNT(*) INTO v_total
    FROM tbl_ActivityHistory a
    WHERE (p_module IS NULL OR a.module = p_module)
      AND (p_activity_type IS NULL OR a.activity_type = p_activity_type)
      AND (p_from_date IS NULL OR a.created_at >= p_from_date)
      AND (p_to_date IS NULL OR a.created_at <= p_to_date);

    v_pages := CEIL(v_total::NUMERIC / GREATEST(p_page_size, 1))::INT;

    SELECT jsonb_agg(
        jsonb_build_object(
            'activityId', a.activity_id::text,
            'userId', a.user_id::text,
            'username', a.username,
            'activityType', a.activity_type,
            'module', a.module,
            'description', a.description,
            'recordId', a.record_id,
            'oldValue', a.old_value,
            'newValue', a.new_value,
            'ipAddress', a.ip_address,
            'createdAt', to_char(a.created_at, 'YYYY-MM-DD"T"HH24:MI:SS')
        )
    ) INTO v_result
    FROM (
        SELECT *
        FROM tbl_ActivityHistory a
        WHERE (p_module IS NULL OR a.module = p_module)
          AND (p_activity_type IS NULL OR a.activity_type = p_activity_type)
          AND (p_from_date IS NULL OR a.created_at >= p_from_date)
          AND (p_to_date IS NULL OR a.created_at <= p_to_date)
        ORDER BY a.created_at DESC
        LIMIT p_page_size OFFSET v_offset
    ) a;

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Activity history retrieved'::VARCHAR, NULL::VARCHAR, v_total, v_pages, COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- =============================================================================
-- 3. USER MANAGEMENT & AUTHENTICATION
-- =============================================================================

-- fn_UserLogin: Fetches user record for password verification in Java and logs attempt
CREATE OR REPLACE FUNCTION fn_UserLogin(
    p_username VARCHAR,
    p_ip_address VARCHAR DEFAULT '127.0.0.1'
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
    v_user tbl_Users%ROWTYPE;
BEGIN
    SELECT * INTO v_user
    FROM tbl_Users
    WHERE username = p_username AND is_active = TRUE;

    IF v_user.user_id IS NULL THEN
        -- Log failed login attempt
        PERFORM fn_LogActivity('SYSTEM', p_username, 'LOGIN_FAILED', 'AUTH', 'Failed login attempt for username: ' || p_username, NULL, NULL, NULL, p_ip_address);
        RETURN QUERY SELECT FALSE, 'AUTH_USER_NOT_FOUND'::VARCHAR, 'Invalid credentials'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
    ELSE
        RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'User profile found'::VARCHAR, v_user.user_id::VARCHAR, 1, 1,
            jsonb_build_object(
                'userId', v_user.user_id::text,
                'username', v_user.username,
                'passwordHash', v_user.password_hash,
                'fullName', v_user.full_name,
                'email', v_user.email,
                'role', v_user.role,
                'phone', v_user.phone,
                'isActive', v_user.is_active,
                'createdAt', to_char(v_user.created_at, 'YYYY-MM-DD"T"HH24:MI:SS')
            );
    END IF;
END;
$$;

-- fn_UserCreate: Creates a new user with programmatic uniqueness check
CREATE OR REPLACE FUNCTION fn_UserCreate(
    p_username VARCHAR,
    p_password_hash VARCHAR,
    p_full_name VARCHAR,
    p_email VARCHAR,
    p_role VARCHAR,
    p_phone VARCHAR,
    p_actor_id VARCHAR DEFAULT 'SYSTEM'
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
    v_exists INT;
    v_user_id UUID;
BEGIN
    -- Logical validation: username uniqueness
    SELECT COUNT(*) INTO v_exists FROM tbl_Users WHERE username = p_username;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'DUP_USERNAME'::VARCHAR, 'Username already exists'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    v_user_id := gen_random_uuid();

    INSERT INTO tbl_Users (
        user_id, username, password_hash, full_name, email, role, phone, is_active, created_at, updated_at
    ) VALUES (
        v_user_id, p_username, p_password_hash, p_full_name, p_email, COALESCE(p_role, 'CASHIER'), p_phone, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    );

    -- Log to activity history
    PERFORM fn_LogActivity(p_actor_id, p_actor_id, 'USER_CREATED', 'USER', 'Created user: ' || p_username || ' (' || p_role || ')', v_user_id::text, NULL, jsonb_build_object('username', p_username, 'role', p_role));

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'User created successfully'::VARCHAR, v_user_id::VARCHAR, 1, 1,
        jsonb_build_object('userId', v_user_id::text, 'username', p_username, 'role', p_role, 'fullName', p_full_name);
END;
$$;

-- fn_UserUpdate: Updates an existing user
CREATE OR REPLACE FUNCTION fn_UserUpdate(
    p_user_id VARCHAR,
    p_full_name VARCHAR,
    p_email VARCHAR,
    p_role VARCHAR,
    p_phone VARCHAR,
    p_is_active BOOLEAN,
    p_actor_id VARCHAR DEFAULT 'SYSTEM'
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
    v_old tbl_Users%ROWTYPE;
BEGIN
    SELECT * INTO v_old FROM tbl_Users WHERE user_id::text = p_user_id;
    IF v_old.user_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'USER_NOT_FOUND'::VARCHAR, 'User not found'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    UPDATE tbl_Users
    SET full_name = COALESCE(p_full_name, full_name),
        email = COALESCE(p_email, email),
        role = COALESCE(p_role, role),
        phone = COALESCE(p_phone, phone),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id::text = p_user_id;

    PERFORM fn_LogActivity(
        p_actor_id, p_actor_id, 'USER_UPDATED', 'USER', 'Updated user: ' || v_old.username,
        p_user_id,
        jsonb_build_object('fullName', v_old.full_name, 'role', v_old.role, 'isActive', v_old.is_active),
        jsonb_build_object('fullName', p_full_name, 'role', p_role, 'isActive', p_is_active)
    );

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'User updated successfully'::VARCHAR, p_user_id, 1, 1,
        jsonb_build_object('userId', p_user_id, 'username', v_old.username, 'fullName', p_full_name, 'role', p_role);
END;
$$;

-- fn_UserChangePassword: Changes user password hash
CREATE OR REPLACE FUNCTION fn_UserChangePassword(
    p_user_id VARCHAR,
    p_new_password_hash VARCHAR,
    p_actor_id VARCHAR DEFAULT 'SYSTEM'
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
    v_old tbl_Users%ROWTYPE;
BEGIN
    SELECT * INTO v_old FROM tbl_Users WHERE user_id::text = p_user_id;
    IF v_old.user_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'USER_NOT_FOUND'::VARCHAR, 'User not found'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    UPDATE tbl_Users
    SET password_hash = p_new_password_hash,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id::text = p_user_id;

    PERFORM fn_LogActivity(p_actor_id, p_actor_id, 'PASSWORD_CHANGED', 'AUTH', 'Password changed for user: ' || v_old.username, p_user_id, NULL, NULL);

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Password updated successfully'::VARCHAR, p_user_id, 1, 1, NULL::JSONB;
END;
$$;

-- fn_UserGetAll: Paginated user retrieval with search
CREATE OR REPLACE FUNCTION fn_UserGetAll(
    p_page_number INT DEFAULT 1,
    p_page_size INT DEFAULT 10,
    p_search VARCHAR DEFAULT NULL
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
    v_offset INT;
    v_total INT;
    v_pages INT;
    v_result JSONB;
BEGIN
    v_offset := (GREATEST(p_page_number, 1) - 1) * GREATEST(p_page_size, 1);

    SELECT COUNT(*) INTO v_total
    FROM tbl_Users u
    WHERE (p_search IS NULL OR u.username ILIKE '%' || p_search || '%' OR u.full_name ILIKE '%' || p_search || '%');

    v_pages := CEIL(v_total::NUMERIC / GREATEST(p_page_size, 1))::INT;

    SELECT jsonb_agg(
        jsonb_build_object(
            'userId', u.user_id::text,
            'username', u.username,
            'fullName', u.full_name,
            'email', u.email,
            'role', u.role,
            'phone', u.phone,
            'isActive', u.is_active,
            'createdAt', to_char(u.created_at, 'YYYY-MM-DD"T"HH24:MI:SS'),
            'updatedAt', to_char(u.updated_at, 'YYYY-MM-DD"T"HH24:MI:SS')
        )
    ) INTO v_result
    FROM (
        SELECT *
        FROM tbl_Users u
        WHERE (p_search IS NULL OR u.username ILIKE '%' || p_search || '%' OR u.full_name ILIKE '%' || p_search || '%')
        ORDER BY u.created_at DESC
        LIMIT p_page_size OFFSET v_offset
    ) u;

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Users retrieved successfully'::VARCHAR, NULL::VARCHAR, v_total, v_pages, COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- =============================================================================
-- 4. CATEGORY MANAGEMENT
-- =============================================================================

CREATE OR REPLACE FUNCTION fn_CategoryCreate(
    p_category_name VARCHAR,
    p_description TEXT,
    p_display_order INT DEFAULT 0,
    p_actor_id VARCHAR DEFAULT 'SYSTEM'
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
    v_cat_id UUID;
    v_exists INT;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM tbl_Categories WHERE category_name ILIKE p_category_name AND is_active = TRUE;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'DUP_CATEGORY'::VARCHAR, 'Category name already exists'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    v_cat_id := gen_random_uuid();

    INSERT INTO tbl_Categories (
        category_id, category_name, description, display_order, is_active, created_at, updated_at
    ) VALUES (
        v_cat_id, p_category_name, p_description, COALESCE(p_display_order, 0), TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    );

    PERFORM fn_LogActivity(p_actor_id, p_actor_id, 'CATEGORY_CREATED', 'MENU', 'Created category: ' || p_category_name, v_cat_id::text, NULL, jsonb_build_object('name', p_category_name));

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Category created'::VARCHAR, v_cat_id::VARCHAR, 1, 1,
        jsonb_build_object('categoryId', v_cat_id::text, 'categoryName', p_category_name, 'displayOrder', p_display_order);
END;
$$;

CREATE OR REPLACE FUNCTION fn_CategoryUpdate(
    p_category_id VARCHAR,
    p_category_name VARCHAR,
    p_description TEXT,
    p_display_order INT,
    p_is_active BOOLEAN,
    p_actor_id VARCHAR DEFAULT 'SYSTEM'
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
    v_old tbl_Categories%ROWTYPE;
BEGIN
    SELECT * INTO v_old FROM tbl_Categories WHERE category_id::text = p_category_id;
    IF v_old.category_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'CAT_NOT_FOUND'::VARCHAR, 'Category not found'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    UPDATE tbl_Categories
    SET category_name = COALESCE(p_category_name, category_name),
        description = COALESCE(p_description, description),
        display_order = COALESCE(p_display_order, display_order),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = CURRENT_TIMESTAMP
    WHERE category_id::text = p_category_id;

    PERFORM fn_LogActivity(p_actor_id, p_actor_id, 'CATEGORY_UPDATED', 'MENU', 'Updated category: ' || v_old.category_name, p_category_id, NULL, jsonb_build_object('name', p_category_name, 'isActive', p_is_active));

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Category updated'::VARCHAR, p_category_id, 1, 1,
        jsonb_build_object('categoryId', p_category_id, 'categoryName', p_category_name, 'isActive', p_is_active);
END;
$$;

CREATE OR REPLACE FUNCTION fn_CategoryGetAll(
    p_include_inactive BOOLEAN DEFAULT FALSE
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
    v_result JSONB;
    v_total INT;
BEGIN
    SELECT jsonb_agg(
        jsonb_build_object(
            'categoryId', c.category_id::text,
            'categoryName', c.category_name,
            'description', c.description,
            'displayOrder', c.display_order,
            'isActive', c.is_active,
            'itemCount', (SELECT COUNT(*) FROM tbl_MenuItems m WHERE m.category_id = c.category_id AND m.is_active = TRUE)
        )
    ) INTO v_result
    FROM (
        SELECT *
        FROM tbl_Categories c
        WHERE (p_include_inactive OR c.is_active = TRUE)
        ORDER BY c.display_order ASC, c.category_name ASC
    ) c;

    SELECT COUNT(*) INTO v_total FROM tbl_Categories WHERE (p_include_inactive OR is_active = TRUE);

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Categories retrieved'::VARCHAR, NULL::VARCHAR, v_total, 1, COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- =============================================================================
-- 5. MENU ITEMS MANAGEMENT
-- =============================================================================

CREATE OR REPLACE FUNCTION fn_MenuItemCreate(
    p_category_id VARCHAR,
    p_item_code VARCHAR,
    p_item_name VARCHAR,
    p_description TEXT,
    p_price NUMERIC,
    p_food_type VARCHAR DEFAULT 'VEG',
    p_tax_rate NUMERIC DEFAULT 5.00,
    p_is_available BOOLEAN DEFAULT TRUE,
    p_actor_id VARCHAR DEFAULT 'SYSTEM'
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
    v_item_id UUID;
    v_exists INT;
BEGIN
    -- Logical validation: item_code uniqueness if provided
    IF p_item_code IS NOT NULL AND length(p_item_code) > 0 THEN
        SELECT COUNT(*) INTO v_exists FROM tbl_MenuItems WHERE item_code = p_item_code AND is_active = TRUE;
        IF v_exists > 0 THEN
            RETURN QUERY SELECT FALSE, 'DUP_ITEM_CODE'::VARCHAR, 'Menu item code already exists'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
            RETURN;
        END IF;
    END IF;

    v_item_id := gen_random_uuid();

    INSERT INTO tbl_MenuItems (
        item_id, category_id, item_code, item_name, description, price, food_type, tax_rate, is_available, is_active, created_at, updated_at
    ) VALUES (
        v_item_id,
        CASE WHEN p_category_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN p_category_id::uuid ELSE NULL END,
        COALESCE(p_item_code, v_item_id::text), p_item_name, p_description, GREATEST(p_price, 0),
        COALESCE(p_food_type, 'VEG'), COALESCE(p_tax_rate, 5.00), COALESCE(p_is_available, TRUE), TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    );

    PERFORM fn_LogActivity(p_actor_id, p_actor_id, 'MENU_ITEM_CREATED', 'MENU', 'Created item: ' || p_item_name || ' (Rs. ' || p_price || ')', v_item_id::text, NULL, jsonb_build_object('name', p_item_name, 'price', p_price));

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Menu item created successfully'::VARCHAR, v_item_id::VARCHAR, 1, 1,
        jsonb_build_object('itemId', v_item_id::text, 'itemName', p_item_name, 'price', p_price);
END;
$$;

CREATE OR REPLACE FUNCTION fn_MenuItemUpdate(
    p_item_id VARCHAR,
    p_category_id VARCHAR,
    p_item_code VARCHAR,
    p_item_name VARCHAR,
    p_description TEXT,
    p_price NUMERIC,
    p_food_type VARCHAR,
    p_tax_rate NUMERIC,
    p_is_available BOOLEAN,
    p_is_active BOOLEAN,
    p_actor_id VARCHAR DEFAULT 'SYSTEM'
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
    v_old tbl_MenuItems%ROWTYPE;
BEGIN
    SELECT * INTO v_old FROM tbl_MenuItems WHERE item_id::text = p_item_id;
    IF v_old.item_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'ITEM_NOT_FOUND'::VARCHAR, 'Menu item not found'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    UPDATE tbl_MenuItems
    SET category_id = CASE WHEN p_category_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN p_category_id::uuid ELSE category_id END,
        item_code = COALESCE(p_item_code, item_code),
        item_name = COALESCE(p_item_name, item_name),
        description = COALESCE(p_description, description),
        price = COALESCE(p_price, price),
        food_type = COALESCE(p_food_type, food_type),
        tax_rate = COALESCE(p_tax_rate, tax_rate),
        is_available = COALESCE(p_is_available, is_available),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = CURRENT_TIMESTAMP
    WHERE item_id::text = p_item_id;

    PERFORM fn_LogActivity(
        p_actor_id, p_actor_id, 'MENU_ITEM_UPDATED', 'MENU', 'Updated item: ' || v_old.item_name,
        p_item_id,
        jsonb_build_object('price', v_old.price, 'isAvailable', v_old.is_available),
        jsonb_build_object('price', p_price, 'isAvailable', p_is_available)
    );

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Menu item updated'::VARCHAR, p_item_id, 1, 1,
        jsonb_build_object('itemId', p_item_id, 'itemName', p_item_name, 'price', p_price);
END;
$$;

CREATE OR REPLACE FUNCTION fn_MenuItemGetAll(
    p_page_number INT DEFAULT 1,
    p_page_size INT DEFAULT 50,
    p_category_id VARCHAR DEFAULT NULL,
    p_search VARCHAR DEFAULT NULL,
    p_food_type VARCHAR DEFAULT NULL,
    p_only_available BOOLEAN DEFAULT FALSE
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
    v_offset INT;
    v_total INT;
    v_pages INT;
    v_result JSONB;
BEGIN
    v_offset := (GREATEST(p_page_number, 1) - 1) * GREATEST(p_page_size, 1);

    SELECT COUNT(*) INTO v_total
    FROM tbl_MenuItems m
    WHERE m.is_active = TRUE
      AND (p_category_id IS NULL OR m.category_id::text = p_category_id)
      AND (p_food_type IS NULL OR m.food_type = p_food_type)
      AND (NOT p_only_available OR m.is_available = TRUE)
      AND (p_search IS NULL OR m.item_name ILIKE '%' || p_search || '%' OR m.item_code ILIKE '%' || p_search || '%');

    v_pages := CEIL(v_total::NUMERIC / GREATEST(p_page_size, 1))::INT;

    SELECT jsonb_agg(
        jsonb_build_object(
            'itemId', m.item_id::text,
            'categoryId', m.category_id::text,
            'categoryName', c.category_name,
            'itemCode', m.item_code,
            'itemName', m.item_name,
            'description', m.description,
            'price', m.price,
            'foodType', m.food_type,
            'taxRate', m.tax_rate,
            'isAvailable', m.is_available,
            'isActive', m.is_active
        )
    ) INTO v_result
    FROM (
        SELECT m.*, c.category_name
        FROM tbl_MenuItems m
        LEFT JOIN tbl_Categories c ON c.category_id = m.category_id
        WHERE m.is_active = TRUE
          AND (p_category_id IS NULL OR m.category_id::text = p_category_id)
          AND (p_food_type IS NULL OR m.food_type = p_food_type)
          AND (NOT p_only_available OR m.is_available = TRUE)
          AND (p_search IS NULL OR m.item_name ILIKE '%' || p_search || '%' OR m.item_code ILIKE '%' || p_search || '%')
        ORDER BY c.display_order ASC NULLS LAST, m.item_name ASC
        LIMIT p_page_size OFFSET v_offset
    ) m;

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Menu items retrieved'::VARCHAR, NULL::VARCHAR, v_total, v_pages, COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- =============================================================================
-- 6. TABLES & OCCUPANCY MANAGEMENT
-- =============================================================================

CREATE OR REPLACE FUNCTION fn_TableCreate(
    p_table_number VARCHAR,
    p_seating_capacity INT DEFAULT 4,
    p_location_area VARCHAR DEFAULT 'Main Dining',
    p_actor_id VARCHAR DEFAULT 'SYSTEM'
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
    v_table_id UUID;
    v_exists INT;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM tbl_Tables WHERE table_number = p_table_number AND is_active = TRUE;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'DUP_TABLE'::VARCHAR, 'Table number already exists'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    v_table_id := gen_random_uuid();

    INSERT INTO tbl_Tables (
        table_id, table_number, seating_capacity, location_area, status, is_active, created_at, updated_at
    ) VALUES (
        v_table_id, p_table_number, COALESCE(p_seating_capacity, 4), COALESCE(p_location_area, 'Main Dining'), 'AVAILABLE', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    );

    PERFORM fn_LogActivity(p_actor_id, p_actor_id, 'TABLE_CREATED', 'TABLE', 'Created Table: ' || p_table_number, v_table_id::text, NULL, jsonb_build_object('tableNumber', p_table_number));

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Table created successfully'::VARCHAR, v_table_id::VARCHAR, 1, 1,
        jsonb_build_object('tableId', v_table_id::text, 'tableNumber', p_table_number, 'status', 'AVAILABLE');
END;
$$;

CREATE OR REPLACE FUNCTION fn_TableUpdateStatus(
    p_table_id VARCHAR,
    p_status VARCHAR,
    p_current_bill_id VARCHAR DEFAULT NULL,
    p_actor_id VARCHAR DEFAULT 'SYSTEM'
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
    v_old tbl_Tables%ROWTYPE;
BEGIN
    SELECT * INTO v_old FROM tbl_Tables WHERE table_id::text = p_table_id;
    IF v_old.table_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'TABLE_NOT_FOUND'::VARCHAR, 'Table not found'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    UPDATE tbl_Tables
    SET status = p_status,
        current_bill_id = CASE WHEN p_status = 'AVAILABLE' THEN NULL WHEN p_current_bill_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN p_current_bill_id::uuid ELSE current_bill_id END,
        updated_at = CURRENT_TIMESTAMP
    WHERE table_id::text = p_table_id;

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Table status updated'::VARCHAR, p_table_id, 1, 1,
        jsonb_build_object('tableId', p_table_id, 'tableNumber', v_old.table_number, 'status', p_status);
END;
$$;

CREATE OR REPLACE FUNCTION fn_TableGetAll()
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
            'tableId', t.table_id::text,
            'tableNumber', t.table_number,
            'seatingCapacity', t.seating_capacity,
            'locationArea', t.location_area,
            'status', t.status,
            'currentBillId', t.current_bill_id::text,
            'billNumber', b.bill_number,
            'grandTotal', b.grand_total,
            'billCreatedAt', to_char(b.created_at, 'YYYY-MM-DD"T"HH24:MI:SS')
        )
    ) INTO v_result
    FROM (
        SELECT t.*, b.bill_number, b.grand_total
        FROM tbl_Tables t
        LEFT JOIN tbl_Bills b ON b.bill_id = t.current_bill_id AND b.bill_status = 'ACTIVE'
        WHERE t.is_active = TRUE
        ORDER BY t.location_area ASC, t.table_number ASC
    ) t;

    SELECT COUNT(*) INTO v_total FROM tbl_Tables WHERE is_active = TRUE;

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Tables retrieved'::VARCHAR, NULL::VARCHAR, v_total, 1, COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- =============================================================================
-- 7. BILLING CORE ENGINE & TRANSACTION MANAGEMENT
-- =============================================================================

-- fn_CreateBill: Generates bill, validates table & items, calculates financial line totals, writes audit
CREATE OR REPLACE FUNCTION fn_CreateBill(
    p_order_type VARCHAR,
    p_table_id VARCHAR,
    p_customer_name VARCHAR,
    p_customer_phone VARCHAR,
    p_items_json JSONB,
    p_discount_type VARCHAR DEFAULT 'NONE',
    p_discount_value NUMERIC DEFAULT 0.00,
    p_notes TEXT DEFAULT NULL,
    p_cashier_id VARCHAR DEFAULT 'CASHIER'
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
    v_bill_id UUID;
    v_bill_number VARCHAR(50);
    v_sub_total NUMERIC(12, 2) := 0.00;
    v_discount_amount NUMERIC(12, 2) := 0.00;
    v_tax_rate NUMERIC(5, 2) := 5.00;
    v_tax_amount NUMERIC(12, 2) := 0.00;
    v_grand_total NUMERIC(12, 2) := 0.00;
    v_round_off NUMERIC(6, 2) := 0.00;
    v_taxable_amount NUMERIC(12, 2) := 0.00;
    v_item RECORD;
    v_item_id VARCHAR(50);
    v_item_name VARCHAR(150);
    v_qty NUMERIC(10, 2);
    v_unit_price NUMERIC(12, 2);
    v_item_tax_rate NUMERIC(5, 2);
    v_item_tax_amt NUMERIC(12, 2);
    v_item_total NUMERIC(12, 2);
    v_table_status VARCHAR(50);
    v_seq_num INT;
BEGIN
    -- Logical check: items payload validation
    IF p_items_json IS NULL OR jsonb_array_length(p_items_json) = 0 THEN
        RETURN QUERY SELECT FALSE, 'EMPTY_BILL'::VARCHAR, 'Cannot create bill without items'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    -- If Dine-in, check table availability
    IF p_order_type = 'DINE_IN' AND p_table_id IS NOT NULL THEN
        SELECT status INTO v_table_status FROM tbl_Tables WHERE table_id::text = p_table_id AND is_active = TRUE;
        IF v_table_status IS NULL THEN
            RETURN QUERY SELECT FALSE, 'INVALID_TABLE'::VARCHAR, 'Selected table does not exist'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
            RETURN;
        END IF;
    END IF;

    -- Generate Unique Bill Number
    SELECT COUNT(*) + 1 INTO v_seq_num FROM tbl_Bills WHERE created_at::DATE = CURRENT_DATE;
    v_bill_number := 'INV-' || to_char(CURRENT_DATE, 'YYYYMMDD') || '-' || lpad(v_seq_num::text, 4, '0');
    v_bill_id := gen_random_uuid();

    -- Calculate subtotal from items array
    FOR v_item IN SELECT * FROM jsonb_to_recordset(p_items_json) AS x(
        itemId VARCHAR,
        itemName VARCHAR,
        quantity NUMERIC,
        unitPrice NUMERIC,
        taxRate NUMERIC,
        notes TEXT
    ) LOOP
        v_qty := GREATEST(v_item.quantity, 1);
        v_unit_price := GREATEST(v_item.unitPrice, 0);
        v_item_tax_rate := COALESCE(v_item.taxRate, 5.00);
        
        -- Line item calculation
        v_item_total := ROUND((v_qty * v_unit_price)::NUMERIC, 2);
        v_item_tax_amt := ROUND(((v_item_total * v_item_tax_rate) / 100.00)::NUMERIC, 2);

        v_sub_total := v_sub_total + v_item_total;
        v_tax_amount := v_tax_amount + v_item_tax_amt;

        -- Insert Line Item into tbl_BillItems
        INSERT INTO tbl_BillItems (
            bill_item_id, bill_id, item_id, item_name, quantity,
            unit_price, tax_rate, tax_amount, total_price, notes, is_cancelled, created_at
        ) VALUES (
            gen_random_uuid(),
            v_bill_id,
            CASE WHEN v_item.itemId ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN v_item.itemId::uuid ELSE NULL END,
            v_item.itemName, v_qty,
            v_unit_price, v_item_tax_rate, v_item_tax_amt, v_item_total, v_item.notes, FALSE, CURRENT_TIMESTAMP
        );
    END LOOP;

    -- Process Discounts
    IF p_discount_type = 'PERCENT' THEN
        v_discount_amount := ROUND(((v_sub_total * LEAST(GREATEST(p_discount_value, 0), 100)) / 100.00)::NUMERIC, 2);
    ELSIF p_discount_type = 'FLAT' THEN
        v_discount_amount := LEAST(GREATEST(p_discount_value, 0), v_sub_total);
    ELSE
        v_discount_amount := 0.00;
    END IF;

    -- Recalculate tax on discounted subtotal if discount applied
    v_taxable_amount := GREATEST(v_sub_total - v_discount_amount, 0);
    IF v_sub_total > 0 THEN
        v_tax_amount := ROUND(((v_taxable_amount * v_tax_rate) / 100.00)::NUMERIC, 2);
    END IF;

    -- Grand Total & Standard Rounding (50 paise rule)
    v_grand_total := v_taxable_amount + v_tax_amount;
    v_round_off := ROUND(ROUND(v_grand_total) - v_grand_total, 2);
    v_grand_total := ROUND(v_grand_total);

    -- Insert Master Bill Header
    INSERT INTO tbl_Bills (
        bill_id, bill_number, order_type, table_id, customer_name, customer_phone,
        sub_total, discount_type, discount_value, discount_amount,
        tax_rate, tax_amount, round_off, grand_total,
        payment_mode, payment_status, bill_status, notes, cashier_id,
        created_at, updated_at
    ) VALUES (
        v_bill_id, v_bill_number, COALESCE(p_order_type, 'DINE_IN'),
        CASE WHEN p_table_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN p_table_id::uuid ELSE NULL END,
        p_customer_name, p_customer_phone,
        v_sub_total, COALESCE(p_discount_type, 'NONE'), COALESCE(p_discount_value, 0.00), v_discount_amount,
        v_tax_rate, v_tax_amount, v_round_off, v_grand_total,
        'UNPAID', 'PENDING', 'ACTIVE', p_notes,
        CASE WHEN p_cashier_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN p_cashier_id::uuid ELSE NULL END,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    );

    -- Update table status if Dine-In
    IF p_order_type = 'DINE_IN' AND p_table_id IS NOT NULL THEN
        UPDATE tbl_Tables
        SET status = 'OCCUPIED', current_bill_id = v_bill_id, updated_at = CURRENT_TIMESTAMP
        WHERE table_id::text = p_table_id;
    END IF;

    -- Log to Activity History
    PERFORM fn_LogActivity(
        p_cashier_id, p_cashier_id, 'BILL_CREATED', 'BILLING',
        'Created bill #' || v_bill_number || ' for Rs. ' || v_grand_total || ' (' || p_order_type || ')',
        v_bill_id::text, NULL,
        jsonb_build_object('billNumber', v_bill_number, 'grandTotal', v_grand_total, 'tableId', p_table_id)
    );

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Bill created successfully'::VARCHAR, v_bill_id::VARCHAR, 1, 1,
        jsonb_build_object(
            'billId', v_bill_id::text,
            'billNumber', v_bill_number,
            'orderType', p_order_type,
            'subTotal', v_sub_total,
            'discountAmount', v_discount_amount,
            'taxAmount', v_tax_amount,
            'roundOff', v_round_off,
            'grandTotal', v_grand_total,
            'billStatus', 'ACTIVE'
        );
END;
$$;

-- fn_SettleBill: Finalizes payment, records transaction, updates table to AVAILABLE
CREATE OR REPLACE FUNCTION fn_SettleBill(
    p_bill_id VARCHAR,
    p_payment_mode VARCHAR,
    p_amount_paid NUMERIC,
    p_notes TEXT DEFAULT NULL,
    p_cashier_id VARCHAR DEFAULT 'CASHIER'
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
    v_bill tbl_Bills%ROWTYPE;
    v_txn_id UUID;
BEGIN
    SELECT * INTO v_bill FROM tbl_Bills WHERE bill_id::text = p_bill_id;
    IF v_bill.bill_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'BILL_NOT_FOUND'::VARCHAR, 'Bill not found'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    IF v_bill.bill_status = 'SETTLED' THEN
        RETURN QUERY SELECT FALSE, 'ALREADY_SETTLED'::VARCHAR, 'Bill is already settled'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    IF v_bill.bill_status = 'CANCELLED' THEN
        RETURN QUERY SELECT FALSE, 'BILL_CANCELLED'::VARCHAR, 'Cannot settle a cancelled bill'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    -- Record Payment Transaction
    v_txn_id := gen_random_uuid();

    INSERT INTO tbl_PaymentTransactions (
        transaction_id, bill_id, payment_mode, amount, reference_number, transaction_status, transaction_date, notes
    ) VALUES (
        v_txn_id,
        CASE WHEN p_bill_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN p_bill_id::uuid ELSE NULL END,
        COALESCE(p_payment_mode, 'CASH'), COALESCE(p_amount_paid, v_bill.grand_total),
        'REF-' || substr(md5(random()::text), 1, 8), 'SUCCESS', CURRENT_TIMESTAMP, p_notes
    );

    -- Update Bill Status
    UPDATE tbl_Bills
    SET payment_mode = COALESCE(p_payment_mode, 'CASH'),
        payment_status = 'PAID',
        bill_status = 'SETTLED',
        settled_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE bill_id::text = p_bill_id;

    -- Free Associated Dining Table
    IF v_bill.table_id IS NOT NULL THEN
        UPDATE tbl_Tables
        SET status = 'AVAILABLE', current_bill_id = NULL, updated_at = CURRENT_TIMESTAMP
        WHERE table_id = v_bill.table_id;
    END IF;

    -- Log Settlement to Activity History
    PERFORM fn_LogActivity(
        p_cashier_id, p_cashier_id, 'BILL_SETTLED', 'BILLING',
        'Settled bill #' || v_bill.bill_number || ' (' || p_payment_mode || ' - Rs. ' || v_bill.grand_total || ')',
        p_bill_id,
        jsonb_build_object('paymentStatus', 'PENDING', 'billStatus', 'ACTIVE'),
        jsonb_build_object('paymentStatus', 'PAID', 'billStatus', 'SETTLED', 'paymentMode', p_payment_mode)
    );

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Bill settled successfully'::VARCHAR, p_bill_id, 1, 1,
        jsonb_build_object('billId', p_bill_id, 'billNumber', v_bill.bill_number, 'grandTotal', v_bill.grand_total, 'paymentMode', p_payment_mode, 'settledAt', to_char(CURRENT_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS'));
END;
$$;

-- fn_CancelBill: Cancels bill with mandatory reason and releases table
CREATE OR REPLACE FUNCTION fn_CancelBill(
    p_bill_id VARCHAR,
    p_cancellation_reason TEXT,
    p_actor_id VARCHAR DEFAULT 'SYSTEM'
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
    v_bill tbl_Bills%ROWTYPE;
BEGIN
    SELECT * INTO v_bill FROM tbl_Bills WHERE bill_id::text = p_bill_id;
    IF v_bill.bill_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'BILL_NOT_FOUND'::VARCHAR, 'Bill not found'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    IF v_bill.bill_status = 'CANCELLED' THEN
        RETURN QUERY SELECT FALSE, 'ALREADY_CANCELLED'::VARCHAR, 'Bill is already cancelled'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    UPDATE tbl_Bills
    SET bill_status = 'CANCELLED',
        cancelled_at = CURRENT_TIMESTAMP,
        cancellation_reason = COALESCE(p_cancellation_reason, 'No reason specified'),
        updated_at = CURRENT_TIMESTAMP
    WHERE bill_id::text = p_bill_id;

    -- Release table
    IF v_bill.table_id IS NOT NULL THEN
        UPDATE tbl_Tables
        SET status = 'AVAILABLE', current_bill_id = NULL, updated_at = CURRENT_TIMESTAMP
        WHERE table_id = v_bill.table_id;
    END IF;

    PERFORM fn_LogActivity(
        p_actor_id, p_actor_id, 'BILL_CANCELLED', 'BILLING',
        'Cancelled bill #' || v_bill.bill_number || '. Reason: ' || p_cancellation_reason,
        p_bill_id,
        jsonb_build_object('billStatus', v_bill.bill_status),
        jsonb_build_object('billStatus', 'CANCELLED', 'reason', p_cancellation_reason)
    );

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Bill cancelled successfully'::VARCHAR, p_bill_id, 1, 1,
        jsonb_build_object('billId', p_bill_id, 'billNumber', v_bill.bill_number, 'billStatus', 'CANCELLED');
END;
$$;

-- fn_GetBillDetails: Returns full header, items, and audit info for receipt printing
CREATE OR REPLACE FUNCTION fn_GetBillDetails(
    p_bill_id VARCHAR
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
    v_bill tbl_Bills%ROWTYPE;
    v_items JSONB;
    v_table_num VARCHAR(50);
BEGIN
    SELECT * INTO v_bill FROM tbl_Bills WHERE bill_id::text = p_bill_id;
    IF v_bill.bill_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'BILL_NOT_FOUND'::VARCHAR, 'Bill not found'::VARCHAR, NULL::VARCHAR, 0, 0, NULL::JSONB;
        RETURN;
    END IF;

    SELECT table_number INTO v_table_num FROM tbl_Tables WHERE table_id = v_bill.table_id;

    SELECT jsonb_agg(
        jsonb_build_object(
            'billItemId', bi.bill_item_id::text,
            'itemId', bi.item_id::text,
            'itemName', bi.item_name,
            'quantity', bi.quantity,
            'unitPrice', bi.unit_price,
            'taxRate', bi.tax_rate,
            'taxAmount', bi.tax_amount,
            'totalPrice', bi.total_price,
            'notes', bi.notes
        )
    ) INTO v_items
    FROM tbl_BillItems bi
    WHERE bi.bill_id = v_bill.bill_id AND bi.is_cancelled = FALSE;

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Bill details retrieved'::VARCHAR, p_bill_id, 1, 1,
        jsonb_build_object(
            'billId', v_bill.bill_id::text,
            'billNumber', v_bill.bill_number,
            'orderType', v_bill.order_type,
            'tableId', v_bill.table_id::text,
            'tableNumber', COALESCE(v_table_num, 'N/A'),
            'customerName', v_bill.customer_name,
            'customerPhone', v_bill.customer_phone,
            'subTotal', v_bill.sub_total,
            'discountType', v_bill.discount_type,
            'discountValue', v_bill.discount_value,
            'discountAmount', v_bill.discount_amount,
            'taxRate', v_bill.tax_rate,
            'taxAmount', v_bill.tax_amount,
            'roundOff', v_bill.round_off,
            'grandTotal', v_bill.grand_total,
            'paymentMode', v_bill.payment_mode,
            'paymentStatus', v_bill.payment_status,
            'billStatus', v_bill.bill_status,
            'notes', v_bill.notes,
            'cashierId', v_bill.cashier_id::text,
            'createdAt', to_char(v_bill.created_at, 'YYYY-MM-DD"T"HH24:MI:SS'),
            'settledAt', to_char(v_bill.settled_at, 'YYYY-MM-DD"T"HH24:MI:SS'),
            'items', COALESCE(v_items, '[]'::jsonb)
        );
END;
$$;

-- fn_GetBillList: Paginated bill search & history
CREATE OR REPLACE FUNCTION fn_GetBillList(
    p_page_number INT DEFAULT 1,
    p_page_size INT DEFAULT 15,
    p_status VARCHAR DEFAULT NULL,
    p_order_type VARCHAR DEFAULT NULL,
    p_payment_mode VARCHAR DEFAULT NULL,
    p_search VARCHAR DEFAULT NULL,
    p_from_date TIMESTAMP DEFAULT NULL,
    p_to_date TIMESTAMP DEFAULT NULL
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
    v_offset INT;
    v_total INT;
    v_pages INT;
    v_result JSONB;
BEGIN
    v_offset := (GREATEST(p_page_number, 1) - 1) * GREATEST(p_page_size, 1);

    SELECT COUNT(*) INTO v_total
    FROM tbl_Bills b
    WHERE (p_status IS NULL OR b.bill_status = p_status)
      AND (p_order_type IS NULL OR b.order_type = p_order_type)
      AND (p_payment_mode IS NULL OR b.payment_mode = p_payment_mode)
      AND (p_from_date IS NULL OR b.created_at >= p_from_date)
      AND (p_to_date IS NULL OR b.created_at <= p_to_date)
      AND (p_search IS NULL OR b.bill_number ILIKE '%' || p_search || '%' OR b.customer_name ILIKE '%' || p_search || '%');

    v_pages := CEIL(v_total::NUMERIC / GREATEST(p_page_size, 1))::INT;

    SELECT jsonb_agg(
        jsonb_build_object(
            'billId', b.bill_id::text,
            'billNumber', b.bill_number,
            'orderType', b.order_type,
            'tableNumber', COALESCE(t.table_number, 'N/A'),
            'customerName', b.customer_name,
            'subTotal', b.sub_total,
            'discountAmount', b.discount_amount,
            'taxAmount', b.tax_amount,
            'grandTotal', b.grand_total,
            'paymentMode', b.payment_mode,
            'billStatus', b.bill_status,
            'createdAt', to_char(b.created_at, 'YYYY-MM-DD"T"HH24:MI:SS')
        )
    ) INTO v_result
    FROM (
        SELECT b.*, t.table_number
        FROM tbl_Bills b
        LEFT JOIN tbl_Tables t ON t.table_id = b.table_id
        WHERE (p_status IS NULL OR b.bill_status = p_status)
          AND (p_order_type IS NULL OR b.order_type = p_order_type)
          AND (p_payment_mode IS NULL OR b.payment_mode = p_payment_mode)
          AND (p_from_date IS NULL OR b.created_at >= p_from_date)
          AND (p_to_date IS NULL OR b.created_at <= p_to_date)
          AND (p_search IS NULL OR b.bill_number ILIKE '%' || p_search || '%' OR b.customer_name ILIKE '%' || p_search || '%')
        ORDER BY b.created_at DESC
        LIMIT p_page_size OFFSET v_offset
    ) b;

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Bills retrieved'::VARCHAR, NULL::VARCHAR, v_total, v_pages, COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- =============================================================================
-- 8. DASHBOARD METRICS & SALES REPORTING
-- =============================================================================

CREATE OR REPLACE FUNCTION fn_GetDashboardMetrics(
    p_date DATE DEFAULT CURRENT_DATE
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
    v_today_sales NUMERIC(12, 2) := 0.00;
    v_today_orders INT := 0;
    v_active_bills INT := 0;
    v_occupied_tables INT := 0;
    v_total_tables INT := 0;
    v_top_items JSONB;
    v_payment_breakdown JSONB;
BEGIN
    -- Sales & orders settled today
    SELECT COALESCE(SUM(grand_total), 0.00), COUNT(*)
    INTO v_today_sales, v_today_orders
    FROM tbl_Bills
    WHERE created_at::DATE = p_date AND bill_status = 'SETTLED';

    -- Active bills currently open
    SELECT COUNT(*) INTO v_active_bills FROM tbl_Bills WHERE bill_status = 'ACTIVE';

    -- Table occupancy
    SELECT COUNT(*) INTO v_occupied_tables FROM tbl_Tables WHERE status = 'OCCUPIED' AND is_active = TRUE;
    SELECT COUNT(*) INTO v_total_tables FROM tbl_Tables WHERE is_active = TRUE;

    -- Top 5 Selling Items Today
    SELECT jsonb_agg(
        jsonb_build_object(
            'itemName', bi.item_name,
            'totalQty', SUM(bi.quantity),
            'totalRevenue', SUM(bi.total_price)
        )
    ) INTO v_top_items
    FROM tbl_BillItems bi
    JOIN tbl_Bills b ON b.bill_id = bi.bill_id
    WHERE b.created_at::DATE = p_date AND b.bill_status = 'SETTLED' AND bi.is_cancelled = FALSE
    GROUP BY bi.item_name
    ORDER BY SUM(bi.quantity) DESC
    LIMIT 5;

    -- Payment Mode Breakdown
    SELECT jsonb_agg(
        jsonb_build_object(
            'paymentMode', b.payment_mode,
            'count', COUNT(*),
            'amount', SUM(b.grand_total)
        )
    ) INTO v_payment_breakdown
    FROM tbl_Bills b
    WHERE b.created_at::DATE = p_date AND b.bill_status = 'SETTLED'
    GROUP BY b.payment_mode;

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Dashboard metrics calculated'::VARCHAR, NULL::VARCHAR, 1, 1,
        jsonb_build_object(
            'metricDate', to_char(p_date, 'YYYY-MM-DD'),
            'todaySales', v_today_sales,
            'todayOrders', v_today_orders,
            'activeBills', v_active_bills,
            'occupiedTables', v_occupied_tables,
            'totalTables', v_total_tables,
            'occupancyRate', CASE WHEN v_total_tables > 0 THEN ROUND(((v_occupied_tables::NUMERIC / v_total_tables::NUMERIC) * 100)::NUMERIC, 1) ELSE 0 END,
            'topSellingItems', COALESCE(v_top_items, '[]'::jsonb),
            'paymentBreakdown', COALESCE(v_payment_breakdown, '[]'::jsonb)
        );
END;
$$;

-- fn_GetSalesReport: Period sales breakdown (daily/weekly/monthly)
CREATE OR REPLACE FUNCTION fn_GetSalesReport(
    p_from_date DATE,
    p_to_date DATE,
    p_payment_mode VARCHAR DEFAULT NULL,
    p_cashier_id VARCHAR DEFAULT NULL
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
    v_total_sales NUMERIC(12, 2) := 0.00;
    v_total_orders INT := 0;
    v_total_tax NUMERIC(12, 2) := 0.00;
    v_total_discount NUMERIC(12, 2) := 0.00;
    v_daily_trend JSONB;
BEGIN
    SELECT
        COALESCE(SUM(grand_total), 0.00),
        COUNT(*),
        COALESCE(SUM(tax_amount), 0.00),
        COALESCE(SUM(discount_amount), 0.00)
    INTO v_total_sales, v_total_orders, v_total_tax, v_total_discount
    FROM tbl_Bills
    WHERE bill_status = 'SETTLED'
      AND created_at::DATE >= p_from_date
      AND created_at::DATE <= p_to_date
      AND (p_payment_mode IS NULL OR payment_mode = p_payment_mode)
      AND (p_cashier_id IS NULL OR cashier_id = p_cashier_id);

    -- Group by Day for chart/table view
    SELECT jsonb_agg(
        jsonb_build_object(
            'reportDate', to_char(d.day_date, 'YYYY-MM-DD'),
            'ordersCount', COUNT(b.bill_id),
            'subTotal', COALESCE(SUM(b.sub_total), 0.00),
            'discount', COALESCE(SUM(b.discount_amount), 0.00),
            'tax', COALESCE(SUM(b.tax_amount), 0.00),
            'netRevenue', COALESCE(SUM(b.grand_total), 0.00)
        )
    ) INTO v_daily_trend
    FROM (
        SELECT generate_series(p_from_date, p_to_date, '1 day'::interval)::DATE AS day_date
    ) d
    LEFT JOIN tbl_Bills b ON b.created_at::DATE = d.day_date AND b.bill_status = 'SETTLED'
        AND (p_payment_mode IS NULL OR b.payment_mode = p_payment_mode)
        AND (p_cashier_id IS NULL OR b.cashier_id = p_cashier_id)
    GROUP BY d.day_date
    ORDER BY d.day_date ASC;

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Sales report generated'::VARCHAR, NULL::VARCHAR, v_total_orders, 1,
        jsonb_build_object(
            'fromDate', to_char(p_from_date, 'YYYY-MM-DD'),
            'toDate', to_char(p_to_date, 'YYYY-MM-DD'),
            'totalSales', v_total_sales,
            'totalOrders', v_total_orders,
            'totalTax', v_total_tax,
            'totalDiscount', v_total_discount,
            'dailyTrend', COALESCE(v_daily_trend, '[]'::jsonb)
        );
END;
$$;

-- =============================================================================
-- 9. SETTINGS & CONFIGURATION
-- =============================================================================

CREATE OR REPLACE FUNCTION fn_GetSettings()
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
BEGIN
    SELECT jsonb_object_agg(setting_key, setting_value) INTO v_result FROM tbl_Settings;
    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Settings loaded'::VARCHAR, NULL::VARCHAR, 1, 1, COALESCE(v_result, '{}'::jsonb);
END;
$$;

CREATE OR REPLACE FUNCTION fn_UpdateSettings(
    p_settings_json JSONB,
    p_actor_id VARCHAR DEFAULT 'SYSTEM'
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
    v_key TEXT;
    v_val TEXT;
BEGIN
    FOR v_key, v_val IN SELECT key, value#>>'{}' FROM jsonb_each(p_settings_json) LOOP
        UPDATE tbl_Settings
        SET setting_value = v_val, updated_at = CURRENT_TIMESTAMP
        WHERE setting_key = v_key;

        IF NOT FOUND THEN
            INSERT INTO tbl_Settings (setting_id, setting_key, setting_value, description, updated_at)
            VALUES (gen_random_uuid(), v_key, v_val, 'Restaurant Config', CURRENT_TIMESTAMP);
        END IF;
    END LOOP;

    PERFORM fn_LogActivity(p_actor_id, p_actor_id, 'SETTINGS_UPDATED', 'SETTINGS', 'Updated business configurations', 'GLOBAL_SETTINGS', NULL, p_settings_json);

    RETURN QUERY SELECT TRUE, 'SUCCESS'::VARCHAR, 'Settings saved successfully'::VARCHAR, NULL::VARCHAR, 1, 1, p_settings_json;
END;
$$;
