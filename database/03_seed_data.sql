-- =============================================================================
-- Restaurant Billing Software - Seed Data & Default Configurations
-- Compatible with PostgreSQL 12+ (pgAdmin 4)
-- Default Login Credentials:
-- 1. Username: admin    | Password: password123 (Role: ADMIN)
-- 2. Username: cashier  | Password: password123 (Role: CASHIER)
-- 3. Username: manager  | Password: password123 (Role: MANAGER)
-- =============================================================================

-- BCrypt hash for 'password123': $2a$10$wKz0bB4a1/vY54mS1pM7v.8mXhYpUaCq/xeqo4bFjXzTz8o0JgRvi
-- (Java Spring Security BCryptPasswordEncoder will verify this hash)

-- 1. Seed Users (Calling fn_UserCreate for consistency & initial audit logging)
SELECT * FROM fn_UserCreate(
    'admin',
    '$2a$10$wKz0bB4a1/vY54mS1pM7v.8mXhYpUaCq/xeqo4bFjXzTz8o0JgRvi',
    'System Administrator',
    'admin@grandpavilion.com',
    'ADMIN',
    '+91 9876543210',
    'SETUP'
);

SELECT * FROM fn_UserCreate(
    'cashier',
    '$2a$10$wKz0bB4a1/vY54mS1pM7v.8mXhYpUaCq/xeqo4bFjXzTz8o0JgRvi',
    'Front Desk Cashier',
    'cashier@grandpavilion.com',
    'CASHIER',
    '+91 9876543211',
    'SETUP'
);

SELECT * FROM fn_UserCreate(
    'manager',
    '$2a$10$wKz0bB4a1/vY54mS1pM7v.8mXhYpUaCq/xeqo4bFjXzTz8o0JgRvi',
    'Floor Manager',
    'manager@grandpavilion.com',
    'MANAGER',
    '+91 9876543212',
    'SETUP'
);

-- 2. Seed Categories
SELECT * FROM fn_CategoryCreate('Starters & Appetizers', 'Hot sizzling veg & non-veg appetizers', 1, 'SETUP');
SELECT * FROM fn_CategoryCreate('Main Course', 'Curries, gravies, and traditional specialties', 2, 'SETUP');
SELECT * FROM fn_CategoryCreate('Breads & Roti', 'Tandoori roti, butter naan, and parathas', 3, 'SETUP');
SELECT * FROM fn_CategoryCreate('Rice & Biryani', 'Aromatic dum biryanis, fried rice, and pulao', 4, 'SETUP');
SELECT * FROM fn_CategoryCreate('Beverages & Drinks', 'Mocktails, fresh juices, and hot beverages', 5, 'SETUP');
SELECT * FROM fn_CategoryCreate('Desserts', 'Traditional Indian sweets and ice creams', 6, 'SETUP');

-- 3. Seed Menu Items
DO $$
DECLARE
    v_cat_starters UUID;
    v_cat_main UUID;
    v_cat_breads UUID;
    v_cat_biryani UUID;
    v_cat_drinks UUID;
    v_cat_dessert UUID;
BEGIN
    SELECT category_id INTO v_cat_starters FROM tbl_Categories WHERE category_name = 'Starters & Appetizers' LIMIT 1;
    SELECT category_id INTO v_cat_main FROM tbl_Categories WHERE category_name = 'Main Course' LIMIT 1;
    SELECT category_id INTO v_cat_breads FROM tbl_Categories WHERE category_name = 'Breads & Roti' LIMIT 1;
    SELECT category_id INTO v_cat_biryani FROM tbl_Categories WHERE category_name = 'Rice & Biryani' LIMIT 1;
    SELECT category_id INTO v_cat_drinks FROM tbl_Categories WHERE category_name = 'Beverages & Drinks' LIMIT 1;
    SELECT category_id INTO v_cat_dessert FROM tbl_Categories WHERE category_name = 'Desserts' LIMIT 1;

    -- Starters
    PERFORM fn_MenuItemCreate(v_cat_starters::text, 'STR-101', 'Paneer Tikka', 'Charcoal grilled cottage cheese with bell peppers', 240.00, 'VEG', 5.00, TRUE, 'SETUP');
    PERFORM fn_MenuItemCreate(v_cat_starters::text, 'STR-102', 'Crispy Corn Salt & Pepper', 'Sweet corn tossed with scallions and mild spices', 190.00, 'VEG', 5.00, TRUE, 'SETUP');
    PERFORM fn_MenuItemCreate(v_cat_starters::text, 'STR-103', 'Chicken 65', 'Classic spicy south Indian deep fried chicken bites', 280.00, 'NON_VEG', 5.00, TRUE, 'SETUP');
    PERFORM fn_MenuItemCreate(v_cat_starters::text, 'STR-104', 'Tandoori Chicken (Half)', 'Clay oven roasted marinated chicken drumsticks', 310.00, 'NON_VEG', 5.00, TRUE, 'SETUP');

    -- Main Course
    PERFORM fn_MenuItemCreate(v_cat_main::text, 'MC-201', 'Butter Chicken Masala', 'Tender shredded chicken in rich tomato cashew gravy', 360.00, 'NON_VEG', 5.00, TRUE, 'SETUP');
    PERFORM fn_MenuItemCreate(v_cat_main::text, 'MC-202', 'Mutton Rogan Josh', 'Kashmiri style aromatic slow cooked lamb curry', 440.00, 'NON_VEG', 5.00, TRUE, 'SETUP');
    PERFORM fn_MenuItemCreate(v_cat_main::text, 'MC-203', 'Paneer Butter Masala', 'Fresh cottage cheese cubes in mildly sweet butter sauce', 290.00, 'VEG', 5.00, TRUE, 'SETUP');
    PERFORM fn_MenuItemCreate(v_cat_main::text, 'MC-204', 'Dal Makhani', 'Slow simmered black lentils with cream and butter', 220.00, 'VEG', 5.00, TRUE, 'SETUP');

    -- Breads
    PERFORM fn_MenuItemCreate(v_cat_breads::text, 'BRD-301', 'Butter Naan', 'Tandoor baked leavened flatbread brushed with butter', 55.00, 'VEG', 5.00, TRUE, 'SETUP');
    PERFORM fn_MenuItemCreate(v_cat_breads::text, 'BRD-302', 'Garlic Naan', 'Topped with minced garlic, coriander, and melted butter', 70.00, 'VEG', 5.00, TRUE, 'SETUP');
    PERFORM fn_MenuItemCreate(v_cat_breads::text, 'BRD-303', 'Tandoori Roti', 'Crisp whole wheat bread baked in clay oven', 30.00, 'VEG', 5.00, TRUE, 'SETUP');

    -- Biryani & Rice
    PERFORM fn_MenuItemCreate(v_cat_biryani::text, 'RCE-401', 'Hyderabadi Chicken Dum Biryani', 'Long grain basmati rice layered with spiced marinated chicken', 330.00, 'NON_VEG', 5.00, TRUE, 'SETUP');
    PERFORM fn_MenuItemCreate(v_cat_biryani::text, 'RCE-402', 'Mutton Dum Biryani', 'Authentic slow-cooked saffron rice with tender mutton cuts', 450.00, 'NON_VEG', 5.00, TRUE, 'SETUP');
    PERFORM fn_MenuItemCreate(v_cat_biryani::text, 'RCE-403', 'Royal Veg Biryani', 'Seasonal garden vegetables cooked in fragrant basmati pot', 240.00, 'VEG', 5.00, TRUE, 'SETUP');
    PERFORM fn_MenuItemCreate(v_cat_biryani::text, 'RCE-404', 'Jeera Rice with Dal Tadka Combo', 'Cumin tempered basmati rice with yellow lentil tadka', 210.00, 'VEG', 5.00, TRUE, 'SETUP');

    -- Beverages
    PERFORM fn_MenuItemCreate(v_cat_drinks::text, 'DRK-501', 'Fresh Lime Soda (Sweet/Salt)', 'Freshly squeezed lime juice with sparkling club soda', 75.00, 'BEVERAGE', 5.00, TRUE, 'SETUP');
    PERFORM fn_MenuItemCreate(v_cat_drinks::text, 'DRK-502', 'Classic Mango Lassi', 'Chilled yogurt smoothie infused with Alphonso mango pulp', 95.00, 'BEVERAGE', 5.00, TRUE, 'SETUP');
    PERFORM fn_MenuItemCreate(v_cat_drinks::text, 'DRK-503', 'Masala Chai', 'Indian spiced ginger and cardamom tea', 45.00, 'BEVERAGE', 5.00, TRUE, 'SETUP');

    -- Desserts
    PERFORM fn_MenuItemCreate(v_cat_dessert::text, 'DST-601', 'Gulab Jamun (2 Pcs)', 'Warm milk dumplings soaked in fragrant rose cardamom syrup', 85.00, 'DESSERT', 5.00, TRUE, 'SETUP');
    PERFORM fn_MenuItemCreate(v_cat_dessert::text, 'DST-602', 'Sizzling Brownie with Vanilla Ice Cream', 'Hot walnut fudge brownie on sizzler plate with chocolate sauce', 170.00, 'DESSERT', 5.00, TRUE, 'SETUP');
END $$;

-- 4. Seed Dining Tables
SELECT * FROM fn_TableCreate('T-01', 2, 'Ground Floor', 'SETUP');
SELECT * FROM fn_TableCreate('T-02', 2, 'Ground Floor', 'SETUP');
SELECT * FROM fn_TableCreate('T-03', 4, 'Ground Floor', 'SETUP');
SELECT * FROM fn_TableCreate('T-04', 4, 'Ground Floor', 'SETUP');
SELECT * FROM fn_TableCreate('T-05', 6, 'Ground Floor', 'SETUP');
SELECT * FROM fn_TableCreate('T-06', 4, 'AC Dining Hall', 'SETUP');
SELECT * FROM fn_TableCreate('T-07', 4, 'AC Dining Hall', 'SETUP');
SELECT * FROM fn_TableCreate('T-08', 6, 'AC Dining Hall', 'SETUP');
SELECT * FROM fn_TableCreate('T-09', 8, 'AC Dining Hall', 'SETUP');
SELECT * FROM fn_TableCreate('T-10', 4, 'Rooftop Lounge', 'SETUP');
SELECT * FROM fn_TableCreate('T-11', 4, 'Rooftop Lounge', 'SETUP');
SELECT * FROM fn_TableCreate('T-12', 6, 'Rooftop Lounge', 'SETUP');

-- 5. Seed Restaurant Configuration Settings
SELECT * FROM fn_UpdateSettings(
    jsonb_build_object(
        'restaurant_name', 'The Grand Pavilion Restaurant',
        'restaurant_tagline', 'Exquisite Flavors & Authentic Dining',
        'restaurant_address', '124, High Street, Gandhi Nagar, Chennai - 600020',
        'restaurant_phone', '+91 98765 43210 / 044-2456789',
        'restaurant_email', 'billing@grandpavilion.com',
        'restaurant_gstin', '33ABCDE1234F1Z5',
        'fssai_license', '12419008000451',
        'currency_symbol', '₹',
        'currency_code', 'INR',
        'default_tax_rate', '5.00',
        'service_charge_rate', '0.00',
        'receipt_footer', 'Thank you for dining with us! Have a wonderful day.',
        'receipt_paper_width', '80mm',
        'enable_kot_print', 'true',
        'time_zone', 'Asia/Kolkata',
        'date_format', 'dd MMM yyyy hh:mm a'
    ),
    'SETUP'
);
