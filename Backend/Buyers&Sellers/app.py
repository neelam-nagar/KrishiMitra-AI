import webbrowser
import threading
from flask import Flask, request, render_template
from flask_sqlalchemy import SQLAlchemy

# =======================
# CREATE APP
# =======================
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///market.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# =======================
# MODELS
# =======================

class Buyer(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    phone = db.Column(db.String(20))
    city = db.Column(db.String(100))
    crop = db.Column(db.String(100))
    quantity = db.Column(db.String(50))

class Seller(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    phone = db.Column(db.String(20))
    city = db.Column(db.String(100))
    crop = db.Column(db.String(100))
    price = db.Column(db.String(50))
    quantity = db.Column(db.String(50))

# =======================
# ROUTES
# =======================
@app.route('/buyers')
def buyers_list():
    buyers = Buyer.query.all()   # database se buyers fetch
    return render_template("buyers_list.html", buyers=buyers)
@app.route('/')
def home():
    return render_template("menu.html")
@app.route('/sellers')
def sellers_list():
    sellers = Seller.query.all()   # database se sellers fetch
    return render_template("sellers_list.html", sellers=sellers)
@app.route('/add_buyer', methods=['GET', 'POST'])
def add_buyer():
    if request.method == 'POST':
        new_buyer = Buyer(
            name=request.form['name'],
            phone=request.form['phone'],
            city=request.form['city'],
            crop=request.form['crop'],
            quantity=request.form['quantity']
        )
        db.session.add(new_buyer)
        db.session.commit()
        return "Buyer added successfully!"
    return render_template("add_buyer.html")

@app.route('/add_seller', methods=['GET', 'POST'])
def add_seller():
    if request.method == 'POST':
        new_seller = Seller(
            name=request.form['name'],
            phone=request.form['phone'],
            city=request.form['city'],
            crop=request.form['crop'],
            price=request.form['price'],
            quantity=request.form['quantity']
        )
        db.session.add(new_seller)
        db.session.commit()
        return "Seller added successfully!"
    return render_template("add_seller.html")

# =======================
# RUN APP
# =======================
def open_browser():
    webbrowser.open_new("http://127.0.0.1:5000/")
if __name__ == "__main__":
    with app.app_context():
        db.create_all()

    # open browser automatically
    threading.Timer(1.5, open_browser).start()

    app.run(debug=True)