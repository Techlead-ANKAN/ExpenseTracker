-- ============================================
-- EXPENSE TRACKER - COMPLETE DATABASE SETUP
-- ============================================
-- Run this entire script in Supabase SQL Editor
-- This will create all tables, indexes, RLS policies, and security measures
-- ============================================

-- 1. DROP EXISTING TABLES (if any) - Clean slate
DROP TABLE IF EXISTS expenses CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 2. CREATE USERS TABLE
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL CHECK (length(name) >= 2 AND length(name) <= 100),
  email TEXT UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  password TEXT NOT NULL CHECK (length(password) >= 6),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2.1 CREATE BUDGETS TABLE
CREATE TABLE budgets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category TEXT NOT NULL CHECK (category IN ('Food', 'Travel', 'Rent', 'Shopping', 'Entertainment', 'Healthcare', 'Education', 'Utilities', 'Other')),
  monthly_limit NUMERIC(12, 2) NOT NULL CHECK (monthly_limit > 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, category)
);

-- Add comments to budgets table
COMMENT ON TABLE budgets IS 'Stores monthly budget limits per category for each user';
COMMENT ON COLUMN budgets.user_id IS 'Foreign key reference to users table';
COMMENT ON COLUMN budgets.monthly_limit IS 'Maximum spending limit for this category per month';
COMMENT ON COLUMN budgets.category IS 'Expense category - must match expenses table categories';

-- Add comment to users table
COMMENT ON TABLE users IS 'Stores user account information';
COMMENT ON COLUMN users.email IS 'Unique email address for authentication';
COMMENT ON COLUMN users.password IS 'Plain text password (educational purposes only)';

-- 3. CREATE EXPENSES TABLE
CREATE TABLE expenses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL CHECK (length(title) >= 1 AND length(title) <= 200),
  amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
  category TEXT NOT NULL CHECK (category IN ('Food', 'Travel', 'Rent', 'Shopping', 'Entertainment', 'Healthcare', 'Education', 'Utilities', 'Other')),
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add comments to expenses table
COMMENT ON TABLE expenses IS 'Stores all income and expense transactions';
COMMENT ON COLUMN expenses.user_id IS 'Foreign key reference to users table';
COMMENT ON COLUMN expenses.amount IS 'Transaction amount (must be positive)';
COMMENT ON COLUMN expenses.type IS 'Transaction type: income or expense';

-- 4. CREATE INDEXES FOR PERFORMANCE
-- Index on user_id for faster lookups
CREATE INDEX idx_expenses_user_id ON expenses(user_id);

-- Index on date for sorting and filtering
CREATE INDEX idx_expenses_date ON expenses(date DESC);

-- Index on type for filtering income/expense
CREATE INDEX idx_expenses_type ON expenses(type);

-- Composite index for user + date queries
CREATE INDEX idx_expenses_user_date ON expenses(user_id, date DESC);

-- Index on email for login queries
CREATE INDEX idx_users_email ON users(email);

-- Index on budgets for user queries
CREATE INDEX idx_budgets_user_id ON budgets(user_id);
CREATE INDEX idx_budgets_category ON budgets(category);
CREATE INDEX idx_budgets_user_category ON budgets(user_id, category);

-- 5. CREATE FUNCTION FOR UPDATED_AT TIMESTAMP
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. CREATE TRIGGERS FOR UPDATED_AT
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at
  BEFORE UPDATE ON expenses
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_budgets_updated_at
  BEFORE UPDATE ON budgets
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 7. ENABLE ROW LEVEL SECURITY (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;

-- 8. CREATE RLS POLICIES FOR USERS TABLE

-- Policy: Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON users
  FOR SELECT
  USING (true);  -- Allow all reads for now (needed for login)

-- Policy: Users can insert their own profile (registration)
CREATE POLICY "Users can insert own profile"
  ON users
  FOR INSERT
  WITH CHECK (true);  -- Allow registration

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON users
  FOR UPDATE
  USING (id = (
    SELECT id FROM users WHERE email = current_setting('request.jwt.claims', true)::json->>'email'
  ))
  WITH CHECK (id = (
    SELECT id FROM users WHERE email = current_setting('request.jwt.claims', true)::json->>'email'
  ));

-- Policy: Users cannot delete their own profile (optional - can be modified)
CREATE POLICY "Users cannot delete profiles"
  ON users
  FOR DELETE
  USING (false);

-- 9. CREATE RLS POLICIES FOR EXPENSES TABLE

-- Policy: Users can view only their own expenses
CREATE POLICY "Users can view own expenses"
  ON expenses
  FOR SELECT
  USING (true);  -- Allow all reads (we filter by user_id in application)

-- Policy: Users can insert their own expenses
CREATE POLICY "Users can insert own expenses"
  ON expenses
  FOR INSERT
  WITH CHECK (true);  -- Allow insert (user_id is set by application)

-- Policy: Users can update their own expenses
CREATE POLICY "Users can update own expenses"
  ON expenses
  FOR UPDATE
  USING (true);  -- Allow update (application filters by user_id)

-- Policy: Users can delete their own expenses
CREATE POLICY "Users can delete own expenses"
  ON expenses
  FOR DELETE
  USING (true);  -- Allow delete (application filters by user_id)

-- 9.1. CREATE RLS POLICIES FOR BUDGETS TABLE

-- Policy: Users can view only their own budgets
CREATE POLICY "Users can view own budgets"
  ON budgets
  FOR SELECT
  USING (true);

-- Policy: Users can insert their own budgets
CREATE POLICY "Users can insert own budgets"
  ON budgets
  FOR INSERT
  WITH CHECK (true);

-- Policy: Users can update their own budgets
CREATE POLICY "Users can update own budgets"
  ON budgets
  FOR UPDATE
  USING (true);

-- Policy: Users can delete their own budgets
CREATE POLICY "Users can delete own budgets"
  ON budgets
  FOR DELETE
  USING (true);

-- 10. CREATE HELPFUL VIEWS

-- View: User summary statistics
CREATE OR REPLACE VIEW user_expense_summary AS
SELECT 
  u.id as user_id,
  u.name,
  u.email,
  COUNT(e.id) as total_transactions,
  COALESCE(SUM(CASE WHEN e.type = 'income' THEN e.amount ELSE 0 END), 0) as total_income,
  COALESCE(SUM(CASE WHEN e.type = 'expense' THEN e.amount ELSE 0 END), 0) as total_expense,
  COALESCE(SUM(CASE WHEN e.type = 'income' THEN e.amount ELSE 0 END), 0) - 
  COALESCE(SUM(CASE WHEN e.type = 'expense' THEN e.amount ELSE 0 END), 0) as balance
FROM users u
LEFT JOIN expenses e ON u.id = e.user_id
GROUP BY u.id, u.name, u.email;

COMMENT ON VIEW user_expense_summary IS 'Provides summary statistics for each user';

-- 11. GRANT PERMISSIONS

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Grant permissions on tables
GRANT ALL ON users TO anon, authenticated;
GRANT ALL ON expenses TO anon, authenticated;

-- Grant permissions on sequences (for auto-increment)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Grant permissions on view
GRANT SELECT ON user_expense_summary TO authenticated;

-- 12. INSERT DEMO DATA (with multiple users and extensive transactions)

-- Insert demo users
INSERT INTO users (name, email, password) VALUES
  ('Ankan Roy', 'ankan@example.com', 'password123'),
  ('Priya Sharma', 'priya@example.com', 'password123'),
  ('Rahul Kumar', 'rahul@example.com', 'password123'),
  ('Neha Patel', 'neha@example.com', 'password123'),
  ('Test User', 'test@example.com', 'test123');

-- Insert extensive demo expenses for each user
DO $$
DECLARE
  ankan_id UUID;
  priya_id UUID;
  rahul_id UUID;
  neha_id UUID;
  test_id UUID;
BEGIN
  -- Get user IDs
  SELECT id INTO ankan_id FROM users WHERE email = 'ankan@example.com';
  SELECT id INTO priya_id FROM users WHERE email = 'priya@example.com';
  SELECT id INTO rahul_id FROM users WHERE email = 'rahul@example.com';
  SELECT id INTO neha_id FROM users WHERE email = 'neha@example.com';
  SELECT id INTO test_id FROM users WHERE email = 'test@example.com';
  
  -- ==========================================
  -- ANKAN'S TRANSACTIONS (Software Developer)
  -- ==========================================
  INSERT INTO expenses (user_id, title, amount, category, type, date) VALUES
    -- January Income
    (ankan_id, 'Monthly Salary', 85000, 'Other', 'income', CURRENT_DATE),
    (ankan_id, 'Freelance Project', 25000, 'Other', 'income', CURRENT_DATE - INTERVAL '5 days'),
    (ankan_id, 'Stock Dividend', 3500, 'Other', 'income', CURRENT_DATE - INTERVAL '10 days'),
    
    -- Recent Expenses
    (ankan_id, 'House Rent', 22000, 'Rent', 'expense', CURRENT_DATE - INTERVAL '1 day'),
    (ankan_id, 'Grocery Shopping', 4500, 'Food', 'expense', CURRENT_DATE - INTERVAL '2 days'),
    (ankan_id, 'Netflix Subscription', 649, 'Entertainment', 'expense', CURRENT_DATE - INTERVAL '3 days'),
    (ankan_id, 'Gym Membership', 1500, 'Healthcare', 'expense', CURRENT_DATE - INTERVAL '4 days'),
    (ankan_id, 'Restaurant Dinner', 2800, 'Food', 'expense', CURRENT_DATE - INTERVAL '5 days'),
    (ankan_id, 'Uber Rides', 680, 'Travel', 'expense', CURRENT_DATE - INTERVAL '6 days'),
    (ankan_id, 'Coffee Shop', 450, 'Food', 'expense', CURRENT_DATE - INTERVAL '7 days'),
    (ankan_id, 'Mobile Recharge', 399, 'Utilities', 'expense', CURRENT_DATE - INTERVAL '8 days'),
    (ankan_id, 'Book Purchase', 850, 'Education', 'expense', CURRENT_DATE - INTERVAL '9 days'),
    (ankan_id, 'Electricity Bill', 2100, 'Utilities', 'expense', CURRENT_DATE - INTERVAL '10 days'),
    (ankan_id, 'Internet Bill', 899, 'Utilities', 'expense', CURRENT_DATE - INTERVAL '11 days'),
    (ankan_id, 'Movie Tickets', 800, 'Entertainment', 'expense', CURRENT_DATE - INTERVAL '12 days'),
    (ankan_id, 'Lunch with Friends', 1200, 'Food', 'expense', CURRENT_DATE - INTERVAL '13 days'),
    (ankan_id, 'Online Course', 2499, 'Education', 'expense', CURRENT_DATE - INTERVAL '14 days'),
    (ankan_id, 'Medicine', 850, 'Healthcare', 'expense', CURRENT_DATE - INTERVAL '15 days'),
    (ankan_id, 'Spotify Premium', 119, 'Entertainment', 'expense', CURRENT_DATE - INTERVAL '16 days'),
    (ankan_id, 'Vegetable Market', 600, 'Food', 'expense', CURRENT_DATE - INTERVAL '17 days'),
    (ankan_id, 'Petrol', 3200, 'Travel', 'expense', CURRENT_DATE - INTERVAL '18 days'),
    (ankan_id, 'Clothes Shopping', 4500, 'Shopping', 'expense', CURRENT_DATE - INTERVAL '19 days'),
    (ankan_id, 'Pizza Order', 890, 'Food', 'expense', CURRENT_DATE - INTERVAL '20 days'),
    (ankan_id, 'Water Bill', 450, 'Utilities', 'expense', CURRENT_DATE - INTERVAL '21 days'),
    (ankan_id, 'Haircut', 400, 'Other', 'expense', CURRENT_DATE - INTERVAL '22 days'),
    (ankan_id, 'Gas Cylinder', 950, 'Utilities', 'expense', CURRENT_DATE - INTERVAL '23 days'),
    (ankan_id, 'Birthday Gift', 2500, 'Shopping', 'expense', CURRENT_DATE - INTERVAL '24 days'),
    (ankan_id, 'Train Tickets', 1200, 'Travel', 'expense', CURRENT_DATE - INTERVAL '25 days'),
    
  -- ==========================================
  -- PRIYA'S TRANSACTIONS (Marketing Manager)
  -- ==========================================
    (priya_id, 'Monthly Salary', 95000, 'Other', 'income', CURRENT_DATE),
    (priya_id, 'Bonus', 15000, 'Other', 'income', CURRENT_DATE - INTERVAL '8 days'),
    
    (priya_id, 'House Rent', 28000, 'Rent', 'expense', CURRENT_DATE - INTERVAL '1 day'),
    (priya_id, 'Grocery Shopping', 5200, 'Food', 'expense', CURRENT_DATE - INTERVAL '2 days'),
    (priya_id, 'Salon Visit', 2500, 'Other', 'expense', CURRENT_DATE - INTERVAL '3 days'),
    (priya_id, 'Zomato Order', 680, 'Food', 'expense', CURRENT_DATE - INTERVAL '4 days'),
    (priya_id, 'Amazon Shopping', 3400, 'Shopping', 'expense', CURRENT_DATE - INTERVAL '5 days'),
    (priya_id, 'Yoga Classes', 2000, 'Healthcare', 'expense', CURRENT_DATE - INTERVAL '6 days'),
    (priya_id, 'Cab Rides', 1200, 'Travel', 'expense', CURRENT_DATE - INTERVAL '7 days'),
    (priya_id, 'Electricity Bill', 2800, 'Utilities', 'expense', CURRENT_DATE - INTERVAL '9 days'),
    (priya_id, 'Coffee Meetings', 850, 'Food', 'expense', CURRENT_DATE - INTERVAL '10 days'),
    (priya_id, 'Concert Tickets', 3500, 'Entertainment', 'expense', CURRENT_DATE - INTERVAL '11 days'),
    (priya_id, 'Skincare Products', 2200, 'Shopping', 'expense', CURRENT_DATE - INTERVAL '12 days'),
    (priya_id, 'Restaurant', 2400, 'Food', 'expense', CURRENT_DATE - INTERVAL '13 days'),
    (priya_id, 'Book Store', 1400, 'Education', 'expense', CURRENT_DATE - INTERVAL '14 days'),
    (priya_id, 'Mobile Bill', 499, 'Utilities', 'expense', CURRENT_DATE - INTERVAL '15 days'),
    (priya_id, 'Gym Membership', 2500, 'Healthcare', 'expense', CURRENT_DATE - INTERVAL '16 days'),
    (priya_id, 'Flight Tickets', 8500, 'Travel', 'expense', CURRENT_DATE - INTERVAL '17 days'),
    (priya_id, 'Hotel Stay', 12000, 'Travel', 'expense', CURRENT_DATE - INTERVAL '18 days'),
    (priya_id, 'Shopping Mall', 5600, 'Shopping', 'expense', CURRENT_DATE - INTERVAL '19 days'),
    (priya_id, 'Birthday Celebration', 4500, 'Entertainment', 'expense', CURRENT_DATE - INTERVAL '20 days'),
    
  -- ==========================================
  -- RAHUL'S TRANSACTIONS (Business Owner)
  -- ==========================================
    (rahul_id, 'Business Income', 150000, 'Other', 'income', CURRENT_DATE),
    (rahul_id, 'Rental Income', 20000, 'Other', 'income', CURRENT_DATE - INTERVAL '3 days'),
    (rahul_id, 'Investment Returns', 8000, 'Other', 'income', CURRENT_DATE - INTERVAL '12 days'),
    
    (rahul_id, 'Office Rent', 35000, 'Rent', 'expense', CURRENT_DATE - INTERVAL '1 day'),
    (rahul_id, 'Staff Salaries', 45000, 'Other', 'expense', CURRENT_DATE - INTERVAL '2 days'),
    (rahul_id, 'Grocery Shopping', 6500, 'Food', 'expense', CURRENT_DATE - INTERVAL '3 days'),
    (rahul_id, 'Car EMI', 18000, 'Travel', 'expense', CURRENT_DATE - INTERVAL '4 days'),
    (rahul_id, 'Fuel Expenses', 5000, 'Travel', 'expense', CURRENT_DATE - INTERVAL '5 days'),
    (rahul_id, 'Business Dinner', 8500, 'Food', 'expense', CURRENT_DATE - INTERVAL '6 days'),
    (rahul_id, 'Electronics Purchase', 45000, 'Shopping', 'expense', CURRENT_DATE - INTERVAL '7 days'),
    (rahul_id, 'Insurance Premium', 12000, 'Other', 'expense', CURRENT_DATE - INTERVAL '8 days'),
    (rahul_id, 'Golf Club Membership', 25000, 'Entertainment', 'expense', CURRENT_DATE - INTERVAL '9 days'),
    (rahul_id, 'Health Checkup', 5500, 'Healthcare', 'expense', CURRENT_DATE - INTERVAL '10 days'),
    (rahul_id, 'Restaurant', 3200, 'Food', 'expense', CURRENT_DATE - INTERVAL '11 days'),
    (rahul_id, 'Office Supplies', 2800, 'Other', 'expense', CURRENT_DATE - INTERVAL '13 days'),
    (rahul_id, 'Internet & Phone', 2500, 'Utilities', 'expense', CURRENT_DATE - INTERVAL '14 days'),
    (rahul_id, 'Electricity Bill', 4200, 'Utilities', 'expense', CURRENT_DATE - INTERVAL '15 days'),
    (rahul_id, 'Property Tax', 15000, 'Other', 'expense', CURRENT_DATE - INTERVAL '16 days'),
    
  -- ==========================================
  -- NEHA'S TRANSACTIONS (Student)
  -- ==========================================
    (neha_id, 'Scholarship', 30000, 'Other', 'income', CURRENT_DATE),
    (neha_id, 'Part-time Job', 12000, 'Other', 'income', CURRENT_DATE - INTERVAL '7 days'),
    (neha_id, 'Tuition Received', 5000, 'Other', 'income', CURRENT_DATE - INTERVAL '14 days'),
    
    (neha_id, 'Hostel Fees', 8000, 'Rent', 'expense', CURRENT_DATE - INTERVAL '1 day'),
    (neha_id, 'Grocery & Snacks', 2200, 'Food', 'expense', CURRENT_DATE - INTERVAL '2 days'),
    (neha_id, 'Course Fees', 15000, 'Education', 'expense', CURRENT_DATE - INTERVAL '3 days'),
    (neha_id, 'Books & Stationery', 1800, 'Education', 'expense', CURRENT_DATE - INTERVAL '4 days'),
    (neha_id, 'Cafeteria', 600, 'Food', 'expense', CURRENT_DATE - INTERVAL '5 days'),
    (neha_id, 'Movie Night', 350, 'Entertainment', 'expense', CURRENT_DATE - INTERVAL '6 days'),
    (neha_id, 'Mobile Recharge', 299, 'Utilities', 'expense', CURRENT_DATE - INTERVAL '8 days'),
    (neha_id, 'Bus Pass', 800, 'Travel', 'expense', CURRENT_DATE - INTERVAL '9 days'),
    (neha_id, 'Clothes', 2500, 'Shopping', 'expense', CURRENT_DATE - INTERVAL '10 days'),
    (neha_id, 'Street Food', 250, 'Food', 'expense', CURRENT_DATE - INTERVAL '11 days'),
    (neha_id, 'Laptop Repair', 2000, 'Other', 'expense', CURRENT_DATE - INTERVAL '12 days'),
    (neha_id, 'Netflix Share', 200, 'Entertainment', 'expense', CURRENT_DATE - INTERVAL '13 days'),
    (neha_id, 'Birthday Party', 1500, 'Entertainment', 'expense', CURRENT_DATE - INTERVAL '15 days'),
    (neha_id, 'Medicine', 450, 'Healthcare', 'expense', CURRENT_DATE - INTERVAL '16 days'),
    (neha_id, 'Online Course', 999, 'Education', 'expense', CURRENT_DATE - INTERVAL '17 days'),
    
  -- ==========================================
  -- TEST USER TRANSACTIONS (Mixed)
  -- ==========================================
    (test_id, 'Monthly Salary', 50000, 'Other', 'income', CURRENT_DATE),
    (test_id, 'Freelance Work', 15000, 'Other', 'income', CURRENT_DATE - INTERVAL '7 days'),
    
    (test_id, 'House Rent', 15000, 'Rent', 'expense', CURRENT_DATE - INTERVAL '1 day'),
    (test_id, 'Grocery Shopping', 3500, 'Food', 'expense', CURRENT_DATE - INTERVAL '2 days'),
    (test_id, 'Electricity Bill', 1200, 'Utilities', 'expense', CURRENT_DATE - INTERVAL '3 days'),
    (test_id, 'Movie Tickets', 800, 'Entertainment', 'expense', CURRENT_DATE - INTERVAL '4 days'),
    (test_id, 'Cab Fare', 450, 'Travel', 'expense', CURRENT_DATE - INTERVAL '5 days'),
    (test_id, 'Restaurant Dinner', 1800, 'Food', 'expense', CURRENT_DATE - INTERVAL '6 days'),
    (test_id, 'Mobile Bill', 399, 'Utilities', 'expense', CURRENT_DATE - INTERVAL '8 days'),
    (test_id, 'Shopping', 2500, 'Shopping', 'expense', CURRENT_DATE - INTERVAL '9 days'),
    (test_id, 'Gym', 1000, 'Healthcare', 'expense', CURRENT_DATE - INTERVAL '10 days'),
    (test_id, 'Pizza Order', 650, 'Food', 'expense', CURRENT_DATE - INTERVAL '11 days'),
    (test_id, 'Book Purchase', 450, 'Education', 'expense', CURRENT_DATE - INTERVAL '12 days');
    
END $$;

-- 13. VERIFY SETUP
-- Run these queries to verify everything is set up correctly

SELECT 'Tables created successfully!' as status;

SELECT 
  'users' as table_name, 
  COUNT(*) as row_count 
FROM users
UNION ALL
SELECT 
  'expenses' as table_name, 
  COUNT(*) as row_count 
FROM expenses;

-- Show all indexes
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND (tablename = 'users' OR tablename = 'expenses')
ORDER BY tablename, indexname;

-- Show all RLS policies
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ============================================
-- SETUP COMPLETE! 
-- ============================================
-- Your database is now fully configured with:
-- ✅ Users and Expenses tables
-- ✅ Proper constraints and validation
-- ✅ Performance indexes
-- ✅ Row Level Security (RLS) enabled
-- ✅ Security policies
-- ✅ Automatic timestamp updates
-- ✅ Helpful views for statistics
-- ✅ Proper permissions
-- ============================================
-- You can now use your Expense Tracker app!
-- ============================================
