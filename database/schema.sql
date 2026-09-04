-- ============================================================
-- KISANSETU DATABASE SCHEMA
-- Smart India Hackathon 2026
-- PostgreSQL
-- ============================================================

-- ============================================================
-- 0. EXTENSIONS
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- ============================================================
-- 1. USERS
-- ============================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) UNIQUE NOT NULL,

    password_hash TEXT NOT NULL,

    role VARCHAR(30) NOT NULL CHECK (
        role IN (
            'farmer',
            'consumer',
            'buyer',
            'fpo',
            'logistics',
            'admin'
        )
    ),

    preferred_language VARCHAR(50) DEFAULT 'English',

    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 2. FARMERS
-- ============================================================

CREATE TABLE farmers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL UNIQUE
        REFERENCES users(id) ON DELETE CASCADE,

    farmer_code VARCHAR(50) UNIQUE,

    village VARCHAR(150),
    district VARCHAR(150),
    state VARCHAR(150),
    pincode VARCHAR(10),

    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),

    land_area_acres NUMERIC(12,2)
        CHECK (land_area_acres IS NULL OR land_area_acres >= 0),

    experience_years INTEGER
        CHECK (experience_years IS NULL OR experience_years >= 0),

    verification_status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            verification_status IN (
                'pending',
                'verified',
                'rejected'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 3. CONSUMERS
-- ============================================================

CREATE TABLE consumers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL UNIQUE
        REFERENCES users(id) ON DELETE CASCADE,

    delivery_address TEXT,
    city VARCHAR(150),
    district VARCHAR(150),
    state VARCHAR(150),
    pincode VARCHAR(10),

    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 4. BUYERS
-- ============================================================

CREATE TABLE buyers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL UNIQUE
        REFERENCES users(id) ON DELETE CASCADE,

    company_name VARCHAR(200) NOT NULL,

    buyer_type VARCHAR(50)
        CHECK (
            buyer_type IN (
                'retailer',
                'wholesaler',
                'restaurant',
                'processor',
                'institution',
                'exporter',
                'other'
            )
        ),

    business_address TEXT,
    city VARCHAR(150),
    district VARCHAR(150),
    state VARCHAR(150),
    pincode VARCHAR(10),

    gst_number VARCHAR(50),

    verification_status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            verification_status IN (
                'pending',
                'verified',
                'rejected'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 5. FPOS
-- ============================================================

CREATE TABLE fpos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID UNIQUE
        REFERENCES users(id) ON DELETE SET NULL,

    name VARCHAR(200) NOT NULL,
    registration_number VARCHAR(100) UNIQUE,

    village VARCHAR(150),
    district VARCHAR(150),
    state VARCHAR(150),
    pincode VARCHAR(10),

    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),

    verification_status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            verification_status IN (
                'pending',
                'verified',
                'rejected'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 6. FPO MEMBERS
-- ============================================================

CREATE TABLE fpo_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    fpo_id UUID NOT NULL
        REFERENCES fpos(id) ON DELETE CASCADE,

    farmer_id UUID NOT NULL
        REFERENCES farmers(id) ON DELETE CASCADE,

    membership_role VARCHAR(50) DEFAULT 'member',

    joined_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (fpo_id, farmer_id)
);


-- ============================================================
-- 7. FARMS
-- ============================================================

CREATE TABLE farms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    farmer_id UUID NOT NULL
        REFERENCES farmers(id) ON DELETE CASCADE,

    farm_name VARCHAR(150) NOT NULL,

    location TEXT,

    village VARCHAR(150),
    district VARCHAR(150),
    state VARCHAR(150),
    pincode VARCHAR(10),

    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),

    area_acres NUMERIC(12,2) NOT NULL
        CHECK (area_acres > 0),

    soil_type VARCHAR(100),
    irrigation_type VARCHAR(100),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 8. CROPS
-- ============================================================

CREATE TABLE crops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(150) NOT NULL,
    variety VARCHAR(150),

    category VARCHAR(100),

    unit VARCHAR(30) NOT NULL DEFAULT 'kg',

    season VARCHAR(50),

    average_shelf_life_days INTEGER
        CHECK (
            average_shelf_life_days IS NULL
            OR average_shelf_life_days >= 0
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (name, variety)
);


-- ============================================================
-- 9. FARM CROPS
-- ============================================================

CREATE TABLE farm_crops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    farm_id UUID NOT NULL
        REFERENCES farms(id) ON DELETE CASCADE,

    crop_id UUID NOT NULL
        REFERENCES crops(id) ON DELETE RESTRICT,

    season VARCHAR(50),

    area_acres NUMERIC(12,2)
        CHECK (area_acres IS NULL OR area_acres >= 0),

    planting_date DATE,
    expected_harvest_date DATE,

    estimated_yield NUMERIC(14,2)
        CHECK (estimated_yield IS NULL OR estimated_yield >= 0),

    status VARCHAR(30) DEFAULT 'planned'
        CHECK (
            status IN (
                'planned',
                'growing',
                'harvested',
                'cancelled'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 10. PRODUCTS
-- ============================================================

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    farmer_id UUID
        REFERENCES farmers(id) ON DELETE SET NULL,

    fpo_id UUID
        REFERENCES fpos(id) ON DELETE SET NULL,

    crop_id UUID NOT NULL
        REFERENCES crops(id) ON DELETE RESTRICT,

    name VARCHAR(200) NOT NULL,

    description TEXT,

    grade VARCHAR(50),

    unit VARCHAR(30) NOT NULL DEFAULT 'kg',

    base_price NUMERIC(14,2)
        CHECK (base_price IS NULL OR base_price >= 0),

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        (farmer_id IS NOT NULL AND fpo_id IS NULL)
        OR
        (farmer_id IS NULL AND fpo_id IS NOT NULL)
    )
);


-- ============================================================
-- 11. INVENTORY
-- ============================================================

CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    product_id UUID NOT NULL
        REFERENCES products(id) ON DELETE CASCADE,

    quantity NUMERIC(14,2) NOT NULL
        CHECK (quantity >= 0),

    reserved_quantity NUMERIC(14,2) NOT NULL DEFAULT 0
        CHECK (reserved_quantity >= 0),

    available_quantity NUMERIC(14,2)
        GENERATED ALWAYS AS
        (quantity - reserved_quantity) STORED,

    unit_price NUMERIC(14,2)
        CHECK (unit_price IS NULL OR unit_price >= 0),

    harvest_date DATE,

    expiry_date DATE,

    status VARCHAR(30) DEFAULT 'available'
        CHECK (
            status IN (
                'available',
                'reserved',
                'sold',
                'expired',
                'rescued'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (reserved_quantity <= quantity)
);


CREATE INDEX idx_inventory_product
ON inventory(product_id);


-- ============================================================
-- 12. EXPECTED HARVESTS
-- ============================================================

CREATE TABLE expected_harvests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    farmer_id UUID NOT NULL
        REFERENCES farmers(id) ON DELETE CASCADE,

    farm_id UUID
        REFERENCES farms(id) ON DELETE SET NULL,

    crop_id UUID NOT NULL
        REFERENCES crops(id) ON DELETE RESTRICT,

    expected_quantity NUMERIC(14,2) NOT NULL
        CHECK (expected_quantity > 0),

    expected_harvest_date DATE NOT NULL,

    confidence_score NUMERIC(5,2)
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    status VARCHAR(30) DEFAULT 'forecasted'
        CHECK (
            status IN (
                'forecasted',
                'confirmed',
                'harvested',
                'cancelled'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 13. CROP RESERVATIONS
-- ============================================================

CREATE TABLE crop_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    expected_harvest_id UUID NOT NULL
        REFERENCES expected_harvests(id) ON DELETE CASCADE,

    consumer_id UUID
        REFERENCES consumers(id) ON DELETE SET NULL,

    buyer_id UUID
        REFERENCES buyers(id) ON DELETE SET NULL,

    quantity NUMERIC(14,2) NOT NULL
        CHECK (quantity > 0),

    agreed_price NUMERIC(14,2)
        CHECK (agreed_price IS NULL OR agreed_price >= 0),

    reservation_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    status VARCHAR(30) DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'confirmed',
                'fulfilled',
                'cancelled'
            )
        ),

    CHECK (
        (consumer_id IS NOT NULL AND buyer_id IS NULL)
        OR
        (consumer_id IS NULL AND buyer_id IS NOT NULL)
    )
);


-- ============================================================
-- 14. PREORDERS
-- ============================================================

CREATE TABLE preorders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    product_id UUID NOT NULL
        REFERENCES products(id) ON DELETE RESTRICT,

    consumer_id UUID
        REFERENCES consumers(id) ON DELETE SET NULL,

    buyer_id UUID
        REFERENCES buyers(id) ON DELETE SET NULL,

    quantity NUMERIC(14,2) NOT NULL
        CHECK (quantity > 0),

    target_price NUMERIC(14,2)
        CHECK (target_price IS NULL OR target_price >= 0),

    required_by DATE,

    status VARCHAR(30) DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'matched',
                'confirmed',
                'fulfilled',
                'cancelled'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        (consumer_id IS NOT NULL AND buyer_id IS NULL)
        OR
        (consumer_id IS NULL AND buyer_id IS NOT NULL)
    )
);


-- ============================================================
-- 15. ORDERS
-- ============================================================

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    order_number VARCHAR(50) UNIQUE NOT NULL,

    consumer_id UUID
        REFERENCES consumers(id) ON DELETE SET NULL,

    buyer_id UUID
        REFERENCES buyers(id) ON DELETE SET NULL,

    total_amount NUMERIC(14,2) NOT NULL DEFAULT 0
        CHECK (total_amount >= 0),

    delivery_address TEXT,

    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'confirmed',
                'processing',
                'packed',
                'shipped',
                'delivered',
                'cancelled',
                'refunded'
            )
        ),

    payment_status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (
            payment_status IN (
                'pending',
                'paid',
                'failed',
                'refunded',
                'partially_refunded'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        (consumer_id IS NOT NULL AND buyer_id IS NULL)
        OR
        (consumer_id IS NULL AND buyer_id IS NOT NULL)
    )
);


-- ============================================================
-- 16. ORDER ITEMS
-- ============================================================

CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    order_id UUID NOT NULL
        REFERENCES orders(id) ON DELETE CASCADE,

    product_id UUID NOT NULL
        REFERENCES products(id) ON DELETE RESTRICT,

    farmer_id UUID
        REFERENCES farmers(id) ON DELETE SET NULL,

    fpo_id UUID
        REFERENCES fpos(id) ON DELETE SET NULL,

    quantity NUMERIC(14,2) NOT NULL
        CHECK (quantity > 0),

    unit_price NUMERIC(14,2) NOT NULL
        CHECK (unit_price >= 0),

    subtotal NUMERIC(14,2)
        GENERATED ALWAYS AS
        (quantity * unit_price) STORED,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE INDEX idx_orders_consumer
ON orders(consumer_id);

CREATE INDEX idx_orders_buyer
ON orders(buyer_id);

CREATE INDEX idx_order_items_order
ON order_items(order_id);


-- ============================================================
-- 17. MARKET PRICES
-- ============================================================

CREATE TABLE market_prices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    crop_id UUID NOT NULL
        REFERENCES crops(id) ON DELETE CASCADE,

    market_name VARCHAR(200),
    district VARCHAR(150),
    state VARCHAR(150),

    min_price NUMERIC(14,2)
        CHECK (min_price IS NULL OR min_price >= 0),

    max_price NUMERIC(14,2)
        CHECK (max_price IS NULL OR max_price >= 0),

    modal_price NUMERIC(14,2)
        CHECK (modal_price IS NULL OR modal_price >= 0),

    price_date DATE NOT NULL,

    source VARCHAR(100),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 18. DEMAND FORECASTS
-- ============================================================

CREATE TABLE demand_forecasts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    crop_id UUID NOT NULL
        REFERENCES crops(id) ON DELETE CASCADE,

    region VARCHAR(200),

    forecast_date DATE NOT NULL,

    predicted_quantity NUMERIC(14,2) NOT NULL
        CHECK (predicted_quantity >= 0),

    confidence_score NUMERIC(5,2)
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    model_version VARCHAR(100),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 19. DEMAND COMMITMENTS
-- ============================================================

CREATE TABLE demand_commitments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    crop_id UUID NOT NULL
        REFERENCES crops(id) ON DELETE CASCADE,

    buyer_id UUID
        REFERENCES buyers(id) ON DELETE SET NULL,

    consumer_id UUID
        REFERENCES consumers(id) ON DELETE SET NULL,

    quantity NUMERIC(14,2) NOT NULL
        CHECK (quantity > 0),

    commitment_strength NUMERIC(5,2)
        CHECK (
            commitment_strength BETWEEN 0 AND 100
        ),

    commitment_type VARCHAR(50)
        CHECK (
            commitment_type IN (
                'interest',
                'wishlist',
                'cart',
                'preorder',
                'confirmed_order',
                'recurring_contract'
            )
        ),

    required_date DATE,

    status VARCHAR(30) DEFAULT 'active'
        CHECK (
            status IN (
                'active',
                'fulfilled',
                'cancelled',
                'expired'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        (buyer_id IS NOT NULL AND consumer_id IS NULL)
        OR
        (buyer_id IS NULL AND consumer_id IS NOT NULL)
    )
);


-- ============================================================
-- 20. PRICE PREDICTIONS
-- ============================================================

CREATE TABLE price_predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    crop_id UUID NOT NULL
        REFERENCES crops(id) ON DELETE CASCADE,

    region VARCHAR(200),

    prediction_date DATE NOT NULL,

    predicted_price NUMERIC(14,2) NOT NULL
        CHECK (predicted_price >= 0),

    lower_price NUMERIC(14,2)
        CHECK (lower_price IS NULL OR lower_price >= 0),

    upper_price NUMERIC(14,2)
        CHECK (upper_price IS NULL OR upper_price >= 0),

    confidence_score NUMERIC(5,2)
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    model_version VARCHAR(100),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        (lower_price IS NULL OR predicted_price >= lower_price)
        AND
        (upper_price IS NULL OR predicted_price <= upper_price)
        AND
        (lower_price IS NULL OR upper_price IS NULL OR lower_price <= upper_price)
    )
);


-- ============================================================
-- 21. MARKET ANOMALIES
-- ============================================================

CREATE TABLE market_anomalies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    crop_id UUID
        REFERENCES crops(id) ON DELETE SET NULL,

    region VARCHAR(200),

    anomaly_type VARCHAR(100) NOT NULL,

    severity VARCHAR(30) DEFAULT 'medium'
        CHECK (
            severity IN (
                'low',
                'medium',
                'high',
                'critical'
            )
        ),

    description TEXT,

    detected_value NUMERIC(14,2),

    expected_value NUMERIC(14,2),

    detected_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    resolved BOOLEAN NOT NULL DEFAULT FALSE
);


-- ============================================================
-- 22. BUYER REQUIREMENTS
-- ============================================================

CREATE TABLE buyer_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    buyer_id UUID NOT NULL
        REFERENCES buyers(id) ON DELETE CASCADE,

    crop_id UUID NOT NULL
        REFERENCES crops(id) ON DELETE RESTRICT,

    quantity NUMERIC(14,2) NOT NULL
        CHECK (quantity > 0),

    min_grade VARCHAR(50),

    max_price NUMERIC(14,2)
        CHECK (max_price IS NULL OR max_price >= 0),

    required_from DATE,
    required_until DATE,

    delivery_location TEXT,

    status VARCHAR(30) DEFAULT 'open'
        CHECK (
            status IN (
                'open',
                'matched',
                'fulfilled',
                'cancelled'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 23. SUPPLY POOLS
-- ============================================================

CREATE TABLE supply_pools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    farmer_id UUID
        REFERENCES farmers(id) ON DELETE SET NULL,

    fpo_id UUID
        REFERENCES fpos(id) ON DELETE SET NULL,

    crop_id UUID NOT NULL
        REFERENCES crops(id) ON DELETE RESTRICT,

    total_quantity NUMERIC(14,2) NOT NULL
        CHECK (total_quantity > 0),

    available_quantity NUMERIC(14,2) NOT NULL
        CHECK (available_quantity >= 0),

    target_date DATE,

    status VARCHAR(30) DEFAULT 'forming'
        CHECK (
            status IN (
                'forming',
                'ready',
                'matched',
                'completed',
                'cancelled'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        available_quantity <= total_quantity
    ),

    CHECK (
        (farmer_id IS NOT NULL AND fpo_id IS NULL)
        OR
        (farmer_id IS NULL AND fpo_id IS NOT NULL)
    )
);


-- ============================================================
-- 24. MATCHES
-- ============================================================

CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    buyer_requirement_id UUID
        REFERENCES buyer_requirements(id) ON DELETE CASCADE,

    preorder_id UUID
        REFERENCES preorders(id) ON DELETE CASCADE,

    supply_pool_id UUID
        REFERENCES supply_pools(id) ON DELETE CASCADE,

    farmer_id UUID
        REFERENCES farmers(id) ON DELETE SET NULL,

    fpo_id UUID
        REFERENCES fpos(id) ON DELETE SET NULL,

    matched_quantity NUMERIC(14,2) NOT NULL
        CHECK (matched_quantity > 0),

    match_score NUMERIC(5,2)
        CHECK (
            match_score IS NULL
            OR match_score BETWEEN 0 AND 100
        ),

    price_score NUMERIC(5,2)
        CHECK (
            price_score IS NULL
            OR price_score BETWEEN 0 AND 100
        ),

    distance_score NUMERIC(5,2)
        CHECK (
            distance_score IS NULL
            OR distance_score BETWEEN 0 AND 100
        ),

    quality_score NUMERIC(5,2)
        CHECK (
            quality_score IS NULL
            OR quality_score BETWEEN 0 AND 100
        ),

    status VARCHAR(30) DEFAULT 'suggested'
        CHECK (
            status IN (
                'suggested',
                'accepted',
                'rejected',
                'completed'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 25. SUPPLY RISKS
-- ============================================================

CREATE TABLE supply_risks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    farmer_id UUID
        REFERENCES farmers(id) ON DELETE SET NULL,

    fpo_id UUID
        REFERENCES fpos(id) ON DELETE SET NULL,

    crop_id UUID
        REFERENCES crops(id) ON DELETE SET NULL,

    expected_harvest_id UUID
        REFERENCES expected_harvests(id) ON DELETE SET NULL,

    risk_type VARCHAR(100) NOT NULL,

    risk_score NUMERIC(5,2)
        CHECK (
            risk_score BETWEEN 0 AND 100
        ),

    predicted_shortfall NUMERIC(14,2)
        CHECK (
            predicted_shortfall IS NULL
            OR predicted_shortfall >= 0
        ),

    reason TEXT,

    detected_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    status VARCHAR(30) DEFAULT 'open'
        CHECK (
            status IN (
                'open',
                'mitigated',
                'resolved'
            )
        )
);


-- ============================================================
-- 26. SUPPLY BACKUPS
-- ============================================================

CREATE TABLE supply_backups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    supply_risk_id UUID NOT NULL
        REFERENCES supply_risks(id) ON DELETE CASCADE,

    backup_farmer_id UUID
        REFERENCES farmers(id) ON DELETE SET NULL,

    backup_fpo_id UUID
        REFERENCES fpos(id) ON DELETE SET NULL,

    backup_quantity NUMERIC(14,2) NOT NULL
        CHECK (backup_quantity > 0),

    estimated_distance_km NUMERIC(12,2)
        CHECK (
            estimated_distance_km IS NULL
            OR estimated_distance_km >= 0
        ),

    estimated_price NUMERIC(14,2)
        CHECK (
            estimated_price IS NULL
            OR estimated_price >= 0
        ),

    priority INTEGER DEFAULT 1
        CHECK (priority > 0),

    status VARCHAR(30) DEFAULT 'available'
        CHECK (
            status IN (
                'available',
                'selected',
                'rejected',
                'used'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 27. EARNINGS SIMULATIONS
-- ============================================================

CREATE TABLE earnings_simulations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    farmer_id UUID NOT NULL
        REFERENCES farmers(id) ON DELETE CASCADE,

    crop_id UUID
        REFERENCES crops(id) ON DELETE SET NULL,

    quantity NUMERIC(14,2) NOT NULL
        CHECK (quantity > 0),

    traditional_price NUMERIC(14,2)
        CHECK (
            traditional_price IS NULL
            OR traditional_price >= 0
        ),

    direct_price NUMERIC(14,2)
        CHECK (
            direct_price IS NULL
            OR direct_price >= 0
        ),

    logistics_cost NUMERIC(14,2)
        CHECK (
            logistics_cost IS NULL
            OR logistics_cost >= 0
        ),

    platform_cost NUMERIC(14,2)
        CHECK (
            platform_cost IS NULL
            OR platform_cost >= 0
        ),

    estimated_farmer_earnings NUMERIC(14,2)
        CHECK (
            estimated_farmer_earnings IS NULL
            OR estimated_farmer_earnings >= 0
        ),

    estimated_savings NUMERIC(14,2),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 28. QUALITY BATCHES
-- ============================================================

CREATE TABLE quality_batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    product_id UUID
        REFERENCES products(id) ON DELETE SET NULL,

    farmer_id UUID
        REFERENCES farmers(id) ON DELETE SET NULL,

    fpo_id UUID
        REFERENCES fpos(id) ON DELETE SET NULL,

    batch_code VARCHAR(100) UNIQUE NOT NULL,

    quantity NUMERIC(14,2)
        CHECK (quantity IS NULL OR quantity >= 0),

    harvest_date DATE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 29. QUALITY ASSESSMENTS
-- ============================================================

CREATE TABLE quality_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    quality_batch_id UUID NOT NULL
        REFERENCES quality_batches(id) ON DELETE CASCADE,

    freshness_score NUMERIC(5,2)
        CHECK (
            freshness_score IS NULL
            OR freshness_score BETWEEN 0 AND 100
        ),

    appearance_score NUMERIC(5,2)
        CHECK (
            appearance_score IS NULL
            OR appearance_score BETWEEN 0 AND 100
        ),

    estimated_grade VARCHAR(50),

    defects_detected TEXT,

    ai_confidence NUMERIC(5,2)
        CHECK (
            ai_confidence IS NULL
            OR ai_confidence BETWEEN 0 AND 100
        ),

    assessment_method VARCHAR(50)
        CHECK (
            assessment_method IN (
                'ai',
                'manual',
                'hybrid'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 30. QUALITY PASSPORTS
-- ============================================================

CREATE TABLE quality_passports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    quality_batch_id UUID NOT NULL UNIQUE
        REFERENCES quality_batches(id) ON DELETE CASCADE,

    qr_code VARCHAR(255) UNIQUE NOT NULL,

    crop_name VARCHAR(150),

    harvest_date DATE,

    origin_location TEXT,

    estimated_grade VARCHAR(50),

    quality_summary TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 31. QUALITY COMPLAINTS
-- ============================================================

CREATE TABLE quality_complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    quality_batch_id UUID
        REFERENCES quality_batches(id) ON DELETE SET NULL,

    order_id UUID
        REFERENCES orders(id) ON DELETE SET NULL,

    consumer_id UUID
        REFERENCES consumers(id) ON DELETE SET NULL,

    buyer_id UUID
        REFERENCES buyers(id) ON DELETE SET NULL,

    complaint_type VARCHAR(100) NOT NULL,

    description TEXT,

    evidence_url TEXT,

    resolution TEXT,

    status VARCHAR(30) DEFAULT 'open'
        CHECK (
            status IN (
                'open',
                'investigating',
                'resolved',
                'rejected'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 32. COLLECTION HUBS
-- ============================================================

CREATE TABLE collection_hubs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(200) NOT NULL,

    address TEXT,

    village VARCHAR(150),
    district VARCHAR(150),
    state VARCHAR(150),

    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),

    capacity_kg NUMERIC(14,2)
        CHECK (
            capacity_kg IS NULL
            OR capacity_kg >= 0
        ),

    cold_storage_available BOOLEAN DEFAULT FALSE,

    status VARCHAR(30) DEFAULT 'active'
        CHECK (
            status IN (
                'active',
                'inactive',
                'maintenance'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 33. VEHICLES
-- ============================================================

CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    vehicle_number VARCHAR(50) UNIQUE NOT NULL,

    vehicle_type VARCHAR(100),

    capacity_kg NUMERIC(14,2) NOT NULL
        CHECK (capacity_kg > 0),

    refrigerated BOOLEAN DEFAULT FALSE,

    current_latitude NUMERIC(10,7),
    current_longitude NUMERIC(10,7),

    status VARCHAR(30) DEFAULT 'available'
        CHECK (
            status IN (
                'available',
                'assigned',
                'in_transit',
                'maintenance',
                'inactive'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 34. LOGISTICS ORDERS
-- ============================================================

CREATE TABLE logistics_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    order_id UUID
        REFERENCES orders(id) ON DELETE SET NULL,

    collection_hub_id UUID
        REFERENCES collection_hubs(id) ON DELETE SET NULL,

    vehicle_id UUID
        REFERENCES vehicles(id) ON DELETE SET NULL,

    pickup_location TEXT NOT NULL,

    delivery_location TEXT NOT NULL,

    pickup_time TIMESTAMPTZ,

    expected_delivery_time TIMESTAMPTZ,

    actual_delivery_time TIMESTAMPTZ,

    distance_km NUMERIC(12,2)
        CHECK (
            distance_km IS NULL
            OR distance_km >= 0
        ),

    logistics_cost NUMERIC(14,2)
        CHECK (
            logistics_cost IS NULL
            OR logistics_cost >= 0
        ),

    status VARCHAR(30) DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'assigned',
                'picked_up',
                'in_transit',
                'delivered',
                'cancelled'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 35. ROUTES
-- ============================================================

CREATE TABLE routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    logistics_order_id UUID
        REFERENCES logistics_orders(id) ON DELETE CASCADE,

    vehicle_id UUID
        REFERENCES vehicles(id) ON DELETE SET NULL,

    route_data JSONB,

    distance_km NUMERIC(12,2)
        CHECK (
            distance_km IS NULL
            OR distance_km >= 0
        ),

    estimated_duration_minutes INTEGER
        CHECK (
            estimated_duration_minutes IS NULL
            OR estimated_duration_minutes >= 0
        ),

    estimated_fuel_cost NUMERIC(14,2)
        CHECK (
            estimated_fuel_cost IS NULL
            OR estimated_fuel_cost >= 0
        ),

    carbon_estimate_kg NUMERIC(14,2)
        CHECK (
            carbon_estimate_kg IS NULL
            OR carbon_estimate_kg >= 0
        ),

    optimization_score NUMERIC(5,2)
        CHECK (
            optimization_score IS NULL
            OR optimization_score BETWEEN 0 AND 100
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 36. SHELF LIFE PREDICTIONS
-- ============================================================

CREATE TABLE shelf_life_predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    quality_batch_id UUID
        REFERENCES quality_batches(id) ON DELETE CASCADE,

    predicted_remaining_days NUMERIC(8,2)
        CHECK (
            predicted_remaining_days IS NULL
            OR predicted_remaining_days >= 0
        ),

    confidence_score NUMERIC(5,2)
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    storage_condition VARCHAR(100),

    temperature_celsius NUMERIC(6,2),

    model_version VARCHAR(100),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 37. WASTE EVENTS
-- ============================================================

CREATE TABLE waste_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    product_id UUID
        REFERENCES products(id) ON DELETE SET NULL,

    quality_batch_id UUID
        REFERENCES quality_batches(id) ON DELETE SET NULL,

    quantity NUMERIC(14,2) NOT NULL
        CHECK (quantity > 0),

    estimated_value_loss NUMERIC(14,2)
        CHECK (
            estimated_value_loss IS NULL
            OR estimated_value_loss >= 0
        ),

    reason VARCHAR(200),

    location TEXT,

    detected_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    status VARCHAR(30) DEFAULT 'open'
        CHECK (
            status IN (
                'open',
                'rescued',
                'disposed',
                'processed'
            )
        )
);


-- ============================================================
-- 38. RESCUE OPPORTUNITIES
-- ============================================================

CREATE TABLE rescue_opportunities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    waste_event_id UUID NOT NULL
        REFERENCES waste_events(id) ON DELETE CASCADE,

    crop_id UUID
        REFERENCES crops(id) ON DELETE SET NULL,

    quantity NUMERIC(14,2) NOT NULL
        CHECK (quantity > 0),

    target_type VARCHAR(100)
        CHECK (
            target_type IN (
                'consumer',
                'bulk_buyer',
                'processor',
                'animal_feed',
                'compost',
                'other'
            )
        ),

    suggested_price NUMERIC(14,2)
        CHECK (
            suggested_price IS NULL
            OR suggested_price >= 0
        ),

    urgency_score NUMERIC(5,2)
        CHECK (
            urgency_score IS NULL
            OR urgency_score BETWEEN 0 AND 100
        ),

    status VARCHAR(30) DEFAULT 'open'
        CHECK (
            status IN (
                'open',
                'matched',
                'completed',
                'expired'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 39. PACKAGING RECOMMENDATIONS
-- ============================================================

CREATE TABLE packaging_recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    crop_id UUID
        REFERENCES crops(id) ON DELETE SET NULL,

    quality_batch_id UUID
        REFERENCES quality_batches(id) ON DELETE SET NULL,

    packaging_type VARCHAR(150),

    recommended_size_kg NUMERIC(10,2)
        CHECK (
            recommended_size_kg IS NULL
            OR recommended_size_kg > 0
        ),

    estimated_cost NUMERIC(14,2)
        CHECK (
            estimated_cost IS NULL
            OR estimated_cost >= 0
        ),

    shelf_life_improvement_days NUMERIC(8,2)
        CHECK (
            shelf_life_improvement_days IS NULL
            OR shelf_life_improvement_days >= 0
        ),

    reason TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 40. COLD CHAIN DECISIONS
-- ============================================================

CREATE TABLE cold_chain_decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    quality_batch_id UUID
        REFERENCES quality_batches(id) ON DELETE SET NULL,

    crop_id UUID
        REFERENCES crops(id) ON DELETE SET NULL,

    required BOOLEAN NOT NULL DEFAULT FALSE,

    recommended_temperature_min NUMERIC(6,2),

    recommended_temperature_max NUMERIC(6,2),

    estimated_cost NUMERIC(14,2)
        CHECK (
            estimated_cost IS NULL
            OR estimated_cost >= 0
        ),

    expected_waste_reduction_percent NUMERIC(5,2)
        CHECK (
            expected_waste_reduction_percent IS NULL
            OR expected_waste_reduction_percent BETWEEN 0 AND 100
        ),

    reason TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE INDEX idx_quality_batches_product
ON quality_batches(product_id);

CREATE INDEX idx_waste_events_status
ON waste_events(status);


-- ============================================================
-- 41. LOGISTICS PARTNERS
-- ============================================================

CREATE TABLE logistics_partners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID UNIQUE
        REFERENCES users(id) ON DELETE SET NULL,

    company_name VARCHAR(200) NOT NULL,

    service_area TEXT,

    fleet_size INTEGER
        CHECK (fleet_size IS NULL OR fleet_size >= 0),

    rating NUMERIC(3,2)
        CHECK (
            rating IS NULL
            OR rating BETWEEN 0 AND 5
        ),

    verification_status VARCHAR(30) DEFAULT 'pending'
        CHECK (
            verification_status IN (
                'pending',
                'verified',
                'rejected'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 42. PAYMENT TRANSACTIONS
-- ============================================================

CREATE TABLE payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    order_id UUID
        REFERENCES orders(id) ON DELETE SET NULL,

    user_id UUID
        REFERENCES users(id) ON DELETE SET NULL,

    transaction_reference VARCHAR(150) UNIQUE,

    amount NUMERIC(14,2) NOT NULL
        CHECK (amount >= 0),

    currency VARCHAR(10) NOT NULL DEFAULT 'INR',

    payment_method VARCHAR(50),

    gateway VARCHAR(100),

    status VARCHAR(30) DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'processing',
                'success',
                'failed',
                'refunded'
            )
        ),

    gateway_response JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 43. FARMER PAYOUTS
-- ============================================================

CREATE TABLE farmer_payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    farmer_id UUID NOT NULL
        REFERENCES farmers(id) ON DELETE CASCADE,

    order_id UUID
        REFERENCES orders(id) ON DELETE SET NULL,

    amount NUMERIC(14,2) NOT NULL
        CHECK (amount >= 0),

    platform_fee NUMERIC(14,2) DEFAULT 0
        CHECK (platform_fee >= 0),

    logistics_fee NUMERIC(14,2) DEFAULT 0
        CHECK (logistics_fee >= 0),

    net_amount NUMERIC(14,2) NOT NULL
        CHECK (net_amount >= 0),

    payout_reference VARCHAR(150),

    status VARCHAR(30) DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'processing',
                'paid',
                'failed'
            )
        ),

    paid_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 44. SUPPLY CONTRACTS
-- ============================================================

CREATE TABLE supply_contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    farmer_id UUID
        REFERENCES farmers(id) ON DELETE SET NULL,

    fpo_id UUID
        REFERENCES fpos(id) ON DELETE SET NULL,

    buyer_id UUID NOT NULL
        REFERENCES buyers(id) ON DELETE CASCADE,

    crop_id UUID NOT NULL
        REFERENCES crops(id) ON DELETE RESTRICT,

    quantity NUMERIC(14,2) NOT NULL
        CHECK (quantity > 0),

    agreed_price NUMERIC(14,2) NOT NULL
        CHECK (agreed_price >= 0),

    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    recurring BOOLEAN DEFAULT FALSE,

    status VARCHAR(30) DEFAULT 'draft'
        CHECK (
            status IN (
                'draft',
                'active',
                'fulfilled',
                'cancelled',
                'expired'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (end_date >= start_date),

    CHECK (
        (farmer_id IS NOT NULL AND fpo_id IS NULL)
        OR
        (farmer_id IS NULL AND fpo_id IS NOT NULL)
    )
);


-- ============================================================
-- 45. AUCTIONS
-- ============================================================

CREATE TABLE auctions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    product_id UUID
        REFERENCES products(id) ON DELETE SET NULL,

    farmer_id UUID
        REFERENCES farmers(id) ON DELETE SET NULL,

    fpo_id UUID
        REFERENCES fpos(id) ON DELETE SET NULL,

    crop_id UUID
        REFERENCES crops(id) ON DELETE SET NULL,

    quantity NUMERIC(14,2) NOT NULL
        CHECK (quantity > 0),

    starting_price NUMERIC(14,2) NOT NULL
        CHECK (starting_price >= 0),

    minimum_price NUMERIC(14,2)
        CHECK (
            minimum_price IS NULL
            OR minimum_price >= 0
        ),

    start_time TIMESTAMPTZ NOT NULL,

    end_time TIMESTAMPTZ NOT NULL,

    status VARCHAR(30) DEFAULT 'scheduled'
        CHECK (
            status IN (
                'scheduled',
                'active',
                'completed',
                'cancelled'
            )
        ),

    winning_bid_id UUID,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (end_time > start_time),

    CHECK (
        (farmer_id IS NOT NULL AND fpo_id IS NULL)
        OR
        (farmer_id IS NULL AND fpo_id IS NOT NULL)
    )
);


-- ============================================================
-- 46. AUCTION BIDS
-- ============================================================

CREATE TABLE auction_bids (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    auction_id UUID NOT NULL
        REFERENCES auctions(id) ON DELETE CASCADE,

    buyer_id UUID NOT NULL
        REFERENCES buyers(id) ON DELETE CASCADE,

    bid_price NUMERIC(14,2) NOT NULL
        CHECK (bid_price >= 0),

    quantity NUMERIC(14,2) NOT NULL
        CHECK (quantity > 0),

    status VARCHAR(30) DEFAULT 'active'
        CHECK (
            status IN (
                'active',
                'winning',
                'outbid',
                'withdrawn',
                'accepted'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- Add circular auction winner relationship AFTER auction_bids exists

ALTER TABLE auctions
ADD CONSTRAINT fk_auction_winning_bid
FOREIGN KEY (winning_bid_id)
REFERENCES auction_bids(id)
ON DELETE SET NULL;


-- ============================================================
-- 47. NEGOTIATIONS
-- ============================================================

CREATE TABLE negotiations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    buyer_id UUID NOT NULL
        REFERENCES buyers(id) ON DELETE CASCADE,

    farmer_id UUID
        REFERENCES farmers(id) ON DELETE SET NULL,

    fpo_id UUID
        REFERENCES fpos(id) ON DELETE SET NULL,

    product_id UUID
        REFERENCES products(id) ON DELETE SET NULL,

    proposed_quantity NUMERIC(14,2)
        CHECK (
            proposed_quantity IS NULL
            OR proposed_quantity > 0
        ),

    proposed_price NUMERIC(14,2)
        CHECK (
            proposed_price IS NULL
            OR proposed_price >= 0
        ),

    counter_price NUMERIC(14,2)
        CHECK (
            counter_price IS NULL
            OR counter_price >= 0
        ),

    ai_recommendation TEXT,

    status VARCHAR(30) DEFAULT 'open'
        CHECK (
            status IN (
                'open',
                'accepted',
                'rejected',
                'expired'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        (farmer_id IS NOT NULL AND fpo_id IS NULL)
        OR
        (farmer_id IS NULL AND fpo_id IS NOT NULL)
    )
);


-- ============================================================
-- 48. FRAUD ALERTS
-- ============================================================

CREATE TABLE fraud_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID
        REFERENCES users(id) ON DELETE SET NULL,

    order_id UUID
        REFERENCES orders(id) ON DELETE SET NULL,

    payment_transaction_id UUID
        REFERENCES payment_transactions(id) ON DELETE SET NULL,

    alert_type VARCHAR(100) NOT NULL,

    risk_score NUMERIC(5,2)
        CHECK (
            risk_score BETWEEN 0 AND 100
        ),

    description TEXT,

    status VARCHAR(30) DEFAULT 'open'
        CHECK (
            status IN (
                'open',
                'reviewing',
                'resolved',
                'false_positive'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 49. FERTILIZER RECOMMENDATIONS
-- ============================================================

CREATE TABLE fertilizer_recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    farmer_id UUID NOT NULL
        REFERENCES farmers(id) ON DELETE CASCADE,

    farm_id UUID
        REFERENCES farms(id) ON DELETE SET NULL,

    crop_id UUID NOT NULL
        REFERENCES crops(id) ON DELETE RESTRICT,

    soil_type VARCHAR(100),

    recommendation TEXT NOT NULL,

    nitrogen_kg NUMERIC(12,2)
        CHECK (
            nitrogen_kg IS NULL
            OR nitrogen_kg >= 0
        ),

    phosphorus_kg NUMERIC(12,2)
        CHECK (
            phosphorus_kg IS NULL
            OR phosphorus_kg >= 0
        ),

    potassium_kg NUMERIC(12,2)
        CHECK (
            potassium_kg IS NULL
            OR potassium_kg >= 0
        ),

    confidence_score NUMERIC(5,2)
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    source VARCHAR(150),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 50. FERTILIZER STORES
-- ============================================================

CREATE TABLE fertilizer_stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    store_name VARCHAR(200) NOT NULL,

    owner_name VARCHAR(150),

    phone VARCHAR(20),

    address TEXT,

    village VARCHAR(150),
    district VARCHAR(150),
    state VARCHAR(150),
    pincode VARCHAR(10),

    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),

    verification_status VARCHAR(30) DEFAULT 'pending'
        CHECK (
            verification_status IN (
                'pending',
                'verified',
                'rejected'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 51. FERTILIZER STORE PRODUCTS
-- ============================================================

CREATE TABLE fertilizer_store_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    store_id UUID NOT NULL
        REFERENCES fertilizer_stores(id) ON DELETE CASCADE,

    fertilizer_name VARCHAR(200) NOT NULL,

    brand VARCHAR(150),

    quantity_available NUMERIC(14,2)
        CHECK (
            quantity_available IS NULL
            OR quantity_available >= 0
        ),

    price_per_unit NUMERIC(14,2)
        CHECK (
            price_per_unit IS NULL
            OR price_per_unit >= 0
        ),

    unit VARCHAR(30) DEFAULT 'kg',

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 52. NOTIFICATIONS
-- ============================================================

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES users(id) ON DELETE CASCADE,

    title VARCHAR(200) NOT NULL,

    message TEXT NOT NULL,

    notification_type VARCHAR(100),

    related_entity_type VARCHAR(100),

    related_entity_id UUID,

    is_read BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 53. VOICE TRANSACTIONS
-- ============================================================

CREATE TABLE voice_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES users(id) ON DELETE CASCADE,

    audio_url TEXT,

    language VARCHAR(50),

    transcript TEXT,

    intent VARCHAR(100),

    extracted_data JSONB,

    confidence_score NUMERIC(5,2)
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    status VARCHAR(30) DEFAULT 'processed'
        CHECK (
            status IN (
                'received',
                'processing',
                'processed',
                'failed'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 54. MARKET SHOCK ALERTS
-- ============================================================

CREATE TABLE market_shock_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    crop_id UUID
        REFERENCES crops(id) ON DELETE SET NULL,

    region VARCHAR(200),

    shock_type VARCHAR(100) NOT NULL,

    severity VARCHAR(30) DEFAULT 'medium'
        CHECK (
            severity IN (
                'low',
                'medium',
                'high',
                'critical'
            )
        ),

    expected_price_change_percent NUMERIC(8,2),

    expected_supply_change_percent NUMERIC(8,2),

    expected_demand_change_percent NUMERIC(8,2),

    description TEXT,

    recommended_action TEXT,

    status VARCHAR(30) DEFAULT 'active'
        CHECK (
            status IN (
                'active',
                'monitoring',
                'resolved'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 55. DIGITAL TWINS
-- ============================================================

CREATE TABLE digital_twins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    entity_type VARCHAR(50) NOT NULL
        CHECK (
            entity_type IN (
                'farmer',
                'buyer',
                'consumer',
                'fpo',
                'market',
                'supply_chain'
            )
        ),

    entity_id UUID NOT NULL,

    state_data JSONB NOT NULL DEFAULT '{}'::jsonb,

    simulation_parameters JSONB
        DEFAULT '{}'::jsonb,

    model_version VARCHAR(100),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (entity_type, entity_id)
);


-- ============================================================
-- 56. MARKET SIMULATIONS
-- ============================================================

CREATE TABLE market_simulations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(200) NOT NULL,

    created_by UUID
        REFERENCES users(id) ON DELETE SET NULL,

    scenario JSONB NOT NULL,

    baseline_data JSONB,

    predicted_results JSONB,

    impact_summary TEXT,

    status VARCHAR(30) DEFAULT 'created'
        CHECK (
            status IN (
                'created',
                'running',
                'completed',
                'failed'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    completed_at TIMESTAMPTZ
);


-- ============================================================
-- 57. AI AGENTS
-- ============================================================

CREATE TABLE ai_agents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(100) UNIQUE NOT NULL,

    agent_type VARCHAR(100) NOT NULL
        CHECK (
            agent_type IN (
                'farmer',
                'buyer',
                'logistics',
                'quality',
                'waste',
                'market',
                'orchestrator'
            )
        ),

    description TEXT,

    model_name VARCHAR(150),

    model_version VARCHAR(100),

    configuration JSONB DEFAULT '{}'::jsonb,

    status VARCHAR(30) DEFAULT 'active'
        CHECK (
            status IN (
                'active',
                'inactive',
                'maintenance'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 58. AI DECISIONS
-- ============================================================

CREATE TABLE ai_decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    agent_id UUID
        REFERENCES ai_agents(id) ON DELETE SET NULL,

    user_id UUID
        REFERENCES users(id) ON DELETE SET NULL,

    entity_type VARCHAR(100),

    entity_id UUID,

    decision_type VARCHAR(100) NOT NULL,

    input_data JSONB,

    decision_data JSONB NOT NULL,

    explanation TEXT,

    confidence_score NUMERIC(5,2)
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    requires_human_review BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 59. AI MODEL VERSIONS
-- ============================================================

CREATE TABLE ai_model_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    model_name VARCHAR(150) NOT NULL,

    version VARCHAR(100) NOT NULL,

    model_type VARCHAR(100),

    accuracy_score NUMERIC(6,3),

    precision_score NUMERIC(6,3),

    recall_score NUMERIC(6,3),

    f1_score NUMERIC(6,3),

    training_data_version VARCHAR(150),

    deployment_status VARCHAR(30) DEFAULT 'development'
        CHECK (
            deployment_status IN (
                'development',
                'testing',
                'staging',
                'production',
                'retired'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (model_name, version)
);


-- ============================================================
-- 60. AUDIT LOGS
-- ============================================================

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID
        REFERENCES users(id) ON DELETE SET NULL,

    action VARCHAR(100) NOT NULL,

    entity_type VARCHAR(100),

    entity_id UUID,

    old_data JSONB,

    new_data JSONB,

    ip_address INET,

    user_agent TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_users_role
ON users(role);

CREATE INDEX idx_farmers_district
ON farmers(district);

CREATE INDEX idx_farmers_state
ON farmers(state);

CREATE INDEX idx_fpo_members_farmer
ON fpo_members(farmer_id);

CREATE INDEX idx_farm_crops_crop
ON farm_crops(crop_id);

CREATE INDEX idx_expected_harvest_farmer
ON expected_harvests(farmer_id);

CREATE INDEX idx_expected_harvest_crop
ON expected_harvests(crop_id);

CREATE INDEX idx_preorders_product
ON preorders(product_id);

CREATE INDEX idx_preorders_consumer
ON preorders(consumer_id);

CREATE INDEX idx_preorders_buyer
ON preorders(buyer_id);

CREATE INDEX idx_market_prices_crop_date
ON market_prices(crop_id, price_date);

CREATE INDEX idx_demand_forecasts_crop_date
ON demand_forecasts(crop_id, forecast_date);

CREATE INDEX idx_demand_commitments_crop
ON demand_commitments(crop_id);

CREATE INDEX idx_price_predictions_crop_date
ON price_predictions(crop_id, prediction_date);

CREATE INDEX idx_buyer_requirements_buyer
ON buyer_requirements(buyer_id);

CREATE INDEX idx_buyer_requirements_crop
ON buyer_requirements(crop_id);

CREATE INDEX idx_supply_pools_crop
ON supply_pools(crop_id);

CREATE INDEX idx_matches_status
ON matches(status);

CREATE INDEX idx_supply_risks_status
ON supply_risks(status);

CREATE INDEX idx_supply_backups_risk
ON supply_backups(supply_risk_id);

CREATE INDEX idx_quality_assessments_batch
ON quality_assessments(quality_batch_id);

CREATE INDEX idx_quality_complaints_order
ON quality_complaints(order_id);

CREATE INDEX idx_collection_hubs_district
ON collection_hubs(district);

CREATE INDEX idx_vehicles_status
ON vehicles(status);

CREATE INDEX idx_logistics_orders_status
ON logistics_orders(status);

CREATE INDEX idx_routes_vehicle
ON routes(vehicle_id);

CREATE INDEX idx_shelf_life_batch
ON shelf_life_predictions(quality_batch_id);

CREATE INDEX idx_rescue_opportunities_status
ON rescue_opportunities(status);

CREATE INDEX idx_logistics_partners_status
ON logistics_partners(verification_status);

CREATE INDEX idx_payment_transactions_order
ON payment_transactions(order_id);

CREATE INDEX idx_payment_transactions_status
ON payment_transactions(status);

CREATE INDEX idx_farmer_payouts_farmer
ON farmer_payouts(farmer_id);

CREATE INDEX idx_supply_contracts_buyer
ON supply_contracts(buyer_id);

CREATE INDEX idx_supply_contracts_crop
ON supply_contracts(crop_id);

CREATE INDEX idx_auctions_status
ON auctions(status);

CREATE INDEX idx_auction_bids_auction
ON auction_bids(auction_id);

CREATE INDEX idx_auction_bids_buyer
ON auction_bids(buyer_id);

CREATE INDEX idx_negotiations_buyer
ON negotiations(buyer_id);

CREATE INDEX idx_fraud_alerts_status
ON fraud_alerts(status);

CREATE INDEX idx_fertilizer_recommendations_farmer
ON fertilizer_recommendations(farmer_id);

CREATE INDEX idx_fertilizer_store_products_store
ON fertilizer_store_products(store_id);

CREATE INDEX idx_notifications_user
ON notifications(user_id);

CREATE INDEX idx_notifications_read
ON notifications(is_read);

CREATE INDEX idx_voice_transactions_user
ON voice_transactions(user_id);

CREATE INDEX idx_market_shock_alerts_crop
ON market_shock_alerts(crop_id);

CREATE INDEX idx_market_shock_alerts_status
ON market_shock_alerts(status);

CREATE INDEX idx_digital_twins_entity
ON digital_twins(entity_type, entity_id);

CREATE INDEX idx_market_simulations_created_by
ON market_simulations(created_by);

CREATE INDEX idx_ai_decisions_agent
ON ai_decisions(agent_id);

CREATE INDEX idx_ai_decisions_entity
ON ai_decisions(entity_type, entity_id);

CREATE INDEX idx_ai_model_versions_name
ON ai_model_versions(model_name);

CREATE INDEX idx_audit_logs_user
ON audit_logs(user_id);

CREATE INDEX idx_audit_logs_entity
ON audit_logs(entity_type, entity_id);

CREATE INDEX idx_audit_logs_created
ON audit_logs(created_at);


-- ============================================================
-- FINAL
-- ============================================================

-- KisanSetu database schema completed.
-- Total tables: 60
-- ============================================================