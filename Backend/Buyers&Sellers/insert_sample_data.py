from app import app, db, Buyer, Seller

buyers_data = [
    {"name": "Shankar Trading Co.", "phone": "9828011001", "city": "Baran", "crop": "Mustard", "quantity": "40 tons"},
    {"name": "Laxmi Agro Buyers", "phone": "9828011002", "city": "Kota", "crop": "Wheat", "quantity": "25 tons"},
]

sellers_data = [
    {"name": "Ramesh Meena", "phone": "9828022001", "city": "Baran", "crop": "Mustard", "price": "4800/q", "quantity": "22 q"},
    {"name": "Suresh Patel", "phone": "9828022002", "city": "Kota", "crop": "Wheat", "price": "2400/q", "quantity": "30 q"},
]

# IMPORTANT FIX: run inside app context
with app.app_context():
    for data in buyers_data:
        db.session.add(Buyer(**data))

    for data in sellers_data:
        db.session.add(Seller(**data))

    db.session.commit()

print("Sample data added successfully!")