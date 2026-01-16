import { createClient } from '@supabase/supabase-js'

// Supabase project credentials
// Project: yaghrlecgtiydlvsqxjg
const supabaseUrl = 'https://yaghrlecgtiydlvsqxjg.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlhZ2hybGVjZ3RpeWRsdnNxeGpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1NzE0MTQsImV4cCI6MjA4NDE0NzQxNH0.ExYy2WdLzICg7-arUohXGenQ3htES1agLkdkZgo7USQ'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
