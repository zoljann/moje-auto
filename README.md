# 🚗 MojeAuto – Quick Start

## 🧱 Backend (API + DB)

```bash
docker-compose up --build
```

* Runs API and SQL Server & Seeds test data automatically

## 🖥 Admin App (Flutter Desktop)

```bash
flutter run -d windows
```

**Login:**
`desktop@gmail.com` / `test`

## 📱 Mobile App (Flutter)

```bash
flutter run \
  --dart-define=API_HOST=10.0.2.2 \
  --dart-define=API_PORT=5000 \
  --dart-define=STRIPE_PUBLIC_KEY=pk_test_51RZGpFRJxfRxobvVEwDj6Fwzlam11SIR19g3bSR0qVnYWtJCS2cdh18iKjVWuIgPMMWEyzW6BD7eM9SnpmIzEvVH00ceRzIOuT
```

**Login:**
`mobile@gmail.com` / `test`

## 💳 Stripe Test Card

* **Card:** `4242 4242 4242 4242`
* **Exp:** `04/34`
* **CVC:** `123`
* **ZIP:** any (e.g. `10000`)
