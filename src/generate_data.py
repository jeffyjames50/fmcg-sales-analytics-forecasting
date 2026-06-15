import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random
import os

np.random.seed(42)

# --------------------
# PARAMETERS
# --------------------
num_products = 20
num_stores = 10
num_sales = 5000

# --------------------
# PRODUCTS
# --------------------
categories = ["Shampoo", "Detergent", "Skincare", "Toothpaste"]
brands = ["BrandA", "BrandB", "BrandC","BrandD"]

products = pd.DataFrame({
    "product_id": range(1, num_products + 1),
    "product_name": [f"Product_{i}" for i in range(1, num_products + 1)],
    "category": np.random.choice(categories, num_products),
    "brand": np.random.choice(brands, num_products)
})

# --------------------
# STORES
# --------------------
stores = pd.DataFrame({
    "store_id": range(1, num_stores + 1),
    "store_name": [f"Store_{i}" for i in range(1, num_stores + 1)],
    "region": np.random.choice(["North", "South", "East", "West"], num_stores),
    "country": "Germany"
})

# --------------------
# SALES
# --------------------
start_date = datetime(2025, 1, 1)

sales_data = []

for _ in range(num_sales):
    product_id = random.randint(1, num_products)
    store_id = random.randint(1, num_stores)
    date = start_date + timedelta(days=random.randint(0, 180))

    units = random.randint(1, 20)
    price = round(random.uniform(2, 15), 2)
    discount = round(random.uniform(0, 0.3), 2)

    revenue = units * price * (1 - discount)

    sales_data.append([
        date, product_id, store_id, units, price, discount, revenue
    ])

sales = pd.DataFrame(sales_data, columns=[
    "sale_date", "product_id", "store_id",
    "units_sold", "price_per_unit", "discount", "revenue"
])

# --------------------
# SAVE FILES
# --------------------
os.makedirs("data/raw", exist_ok=True)

products.to_csv("data/raw/products.csv", index=False)
stores.to_csv("data/raw/stores.csv", index=False)
sales.to_csv("data/raw/sales.csv", index=False)

print("Data generated successfully!")