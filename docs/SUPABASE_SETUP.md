# Supabase Database Setup

## 1. Create Supabase Project
1. Go to https://supabase.com
2. Sign up / Log in
3. Create a new project
4. Wait for database to be ready

## 2. Get API Credentials
1. Go to Project Settings → API
2. Copy your `Project URL`
3. Copy your `anon public` key
4. Update `src/utils/supabase.js` with these values

## 3. Create Database Tables

Go to SQL Editor in Supabase and run these queries:

### Create users table
```sql
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Create expenses table
```sql
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
```

### Create indexes for better performance
```sql
CREATE INDEX idx_expenses_user_id ON expenses(user_id);
CREATE INDEX idx_expenses_date ON expenses(date);
CREATE INDEX idx_expenses_type ON expenses(type);
```

## 4. Configure Row Level Security (RLS)

For now, we'll disable RLS for simplicity. In production, you should enable it.

```sql
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE expenses DISABLE ROW LEVEL SECURITY;
```

## 5. Test Connection
After updating the credentials in `src/utils/supabase.js`, run the app and try registering a user.

---

**Note**: This implementation uses plain text passwords for educational purposes. 
In production, you should use proper password hashing (bcrypt, argon2, etc.).
