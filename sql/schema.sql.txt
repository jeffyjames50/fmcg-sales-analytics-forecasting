-- =========================
-- FMCG DATA MODEL
-- =========================

-- PRODUCTS DIMENSION
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    brand VARCHAR(50)
);

-- STORES DIMENSION
CREATE TABLE stores (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(100),
    region VARCHAR(50),
    country VARCHAR(50)
);

-- SALES FACT TABLE
CREATE TABLE sales (
    sales_id SERIAL PRIMARY KEY,
    sale_date DATE,
    product_id INT REFERENCES products(product_id),
    store_id INT REFERENCES stores(store_id),
    units_sold INT,
    price_per_unit FLOAT,
    discount FLOAT,
    revenue FLOAT
);