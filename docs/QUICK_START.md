# 🚀 Quick Start Guide - Expense Tracker

## ✅ Setup Complete!

Your Expense Tracker application is ready. Follow these final steps to get it running.

---

## 📝 Next Steps

### 1. **Setup Supabase Database** (5 minutes)

#### a) Create Supabase Project
1. Go to [https://supabase.com](https://supabase.com)
2. Click "New Project"
3. Choose an organization
4. Fill in:
   - **Name**: expense-tracker
   - **Database Password**: (save this!)
   - **Region**: Choose closest to you
5. Click "Create new project"
6. Wait ~2 minutes for setup

#### b) Get API Credentials
1. Go to **Settings** (gear icon) → **API**
2. Copy these values:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon public** key (under "Project API keys")

#### c) Update Your App
1. Open `src/utils/supabase.js`
2. Replace:
   ```javascript
   const supabaseUrl = 'YOUR_SUPABASE_URL'
   const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'
   ```
   With your actual values

#### d) Create Database Tables
1. In Supabase, go to **SQL Editor**
2. Click "New query"
3. Copy and paste this SQL:

```sql
-- Create users table
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create expenses table
CREATE TABLE expenses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  category TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_expenses_user_id ON expenses(user_id);
CREATE INDEX idx_expenses_date ON expenses(date);
CREATE INDEX idx_expenses_type ON expenses(type);

-- Disable RLS for simplicity (educational purposes only)
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE expenses DISABLE ROW LEVEL SECURITY;
```

4. Click "Run" (or press Ctrl+Enter)
5. You should see "Success. No rows returned"

---

### 2. **Run the Application**

```bash
npm run dev
```

The app will open at: **http://localhost:5174** (or 5173)

---

## 🎯 Testing the App

### Test Flow:
1. **Open** http://localhost:5174
2. Click "Register here"
3. Fill in:
   - Name: Test User
   - Email: test@example.com
   - Password: test123
   - Confirm Password: test123
4. Click "Register"
5. You'll be redirected to login
6. Login with your credentials
7. **You're in!** 🎉

### Try These Features:
- ✅ Add an income transaction (e.g., Salary, ₹50000)
- ✅ Add an expense (e.g., Groceries, ₹5000, Food)
- ✅ Watch the summary cards update
- ✅ Check the category breakdown
- ✅ Delete a transaction
- ✅ Logout and login again

---

## 🎨 What You Have

### Pages:
- **Login** (`/login`)
- **Register** (`/register`)
- **Dashboard** (`/dashboard`)

### Features:
- ✅ User registration and login
- ✅ Protected routes
- ✅ Add income/expense
- ✅ Transaction history
- ✅ Category-wise breakdown
- ✅ Delete transactions
- ✅ Balance calculation
- ✅ Responsive design
- ✅ Clean, professional UI

---

## 🔧 Troubleshooting

### "Can't connect to Supabase"
- Check if you updated `src/utils/supabase.js` with correct credentials
- Verify your Supabase project is active

### "Email already exists"
- User already registered with that email
- Try a different email or login

### "Database error"
- Check if you ran the SQL setup correctly
- Verify tables exist in Supabase → Table Editor

### Port 5173/5174 already in use
- Vite will automatically use the next available port
- Check terminal output for actual port number

---

## 📚 File Structure

```
expense-tracker/
├── src/
│   ├── pages/
│   │   ├── Login.jsx          ← Login page
│   │   ├── Register.jsx       ← Registration page
│   │   └── Dashboard.jsx      ← Main dashboard
│   ├── utils/
│   │   ├── supabase.js        ← UPDATE THIS with your credentials
│   │   └── auth.js            ← Auth helper functions
│   ├── App.jsx                ← Routing logic
│   ├── App.css                ← Component styles
│   └── index.css              ← Global styles
├── SUPABASE_SETUP.md          ← Detailed database setup
├── README.md                  ← Full documentation
└── QUICK_START.md             ← This file
```

---

## 🎓 Learning Points

This project demonstrates:
- ✅ React functional components
- ✅ React Hooks (useState, useEffect)
- ✅ React Router for navigation
- ✅ Supabase integration
- ✅ Form handling and validation
- ✅ CRUD operations
- ✅ Protected routes
- ✅ Clean CSS styling
- ✅ Responsive design

---

## ⚠️ Important Notes

This is an **educational project** with simplified security:
- Passwords are stored in plain text (don't do this in production!)
- No password hashing
- Simple localStorage authentication
- RLS disabled

For production apps, implement proper security!

---

## 🚀 You're Ready!

1. ✅ Supabase project created
2. ✅ Database tables created
3. ✅ API credentials updated
4. ✅ App running on localhost

**Happy tracking!** 💰

---

Need help? Check:
- `README.md` - Full documentation
- `SUPABASE_SETUP.md` - Detailed database setup
- Browser console - For error messages
- Supabase logs - For database errors
