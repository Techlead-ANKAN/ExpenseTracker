-- ============================================
-- EXPENSE TRACKER - BUDGETS TABLE SETUP
-- ============================================
-- Run this script in Supabase SQL Editor to add budget tracking functionality
-- This adds the budgets table with all necessary indexes, triggers, and RLS policies
-- ============================================

-- 1. CREATE BUDGETS TABLE
CREATE TABLE IF NOT EXISTS budgets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category TEXT NOT NULL CHECK (category IN ('Food', 'Travel', 'Rent', 'Shopping', 'Entertainment', 'Healthcare', 'Education', 'Utilities', 'Other')),
  monthly_limit NUMERIC(12, 2) NOT NULL CHECK (monthly_limit > 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, category)
);

-- 2. ADD TABLE COMMENTS
COMMENT ON TABLE budgets IS 'Stores monthly budget limits per category for each user';
COMMENT ON COLUMN budgets.user_id IS 'Foreign key reference to users table';
COMMENT ON COLUMN budgets.monthly_limit IS 'Maximum spending limit for this category per month';
COMMENT ON COLUMN budgets.category IS 'Expense category - must match expenses table categories';

-- 3. CREATE INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_budgets_user_id ON budgets(user_id);
CREATE INDEX IF NOT EXISTS idx_budgets_category ON budgets(category);
CREATE INDEX IF NOT EXISTS idx_budgets_user_category ON budgets(user_id, category);

-- 4. CREATE TRIGGER FOR UPDATED_AT
-- Note: The update_updated_at_column() function should already exist from your initial setup
-- If not, uncomment the following:
/*
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
*/

CREATE TRIGGER update_budgets_updated_at
  BEFORE UPDATE ON budgets
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 5. ENABLE ROW LEVEL SECURITY
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;

-- 6. CREATE RLS POLICIES FOR BUDGETS TABLE

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

-- 7. GRANT PERMISSIONS
GRANT ALL ON budgets TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these to verify the table was created successfully:

-- Check table structure
-- SELECT column_name, data_type, is_nullable, column_default 
-- FROM information_schema.columns 
-- WHERE table_name = 'budgets';

-- Check indexes
-- SELECT indexname, indexdef 
-- FROM pg_indexes 
-- WHERE tablename = 'budgets';

-- Check RLS policies
-- SELECT policyname, permissive, roles, cmd 
-- FROM pg_policies 
-- WHERE tablename = 'budgets';

-- ============================================
-- OPTIONAL: INSERT SAMPLE BUDGETS
-- ============================================
-- Uncomment to add sample budgets for testing:

/*
-- Get your user ID first:
-- SELECT id, name, email FROM users WHERE email = 'your-email@example.com';

-- Then insert sample budgets (replace 'YOUR_USER_ID' with actual UUID):
INSERT INTO budgets (user_id, category, monthly_limit) VALUES
  ('YOUR_USER_ID', 'Food', 15000),
  ('YOUR_USER_ID', 'Travel', 10000),
  ('YOUR_USER_ID', 'Rent', 25000),
  ('YOUR_USER_ID', 'Shopping', 8000),
  ('YOUR_USER_ID', 'Entertainment', 5000);
*/

-- ============================================
-- Setup Complete!
-- ============================================
-- The budgets table is now ready to use.
-- Your application can now:
-- 1. Set monthly budget limits for each category
-- 2. Track spending against budgets
-- 3. Display budget progress with color-coded alerts
-- ============================================
