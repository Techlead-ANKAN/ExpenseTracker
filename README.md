# 💰 Expense Tracker

A clean, minimal, and professional expense tracking application built with React and Supabase.

## ✨ Features

### 🔐 Authentication
- User registration with email and password
- Simple login system
- Protected dashboard routes
- Session management using localStorage

### 📊 Dashboard
- **User Info Section**: Welcome message with user details
- **Summary Cards**: 
  - Total Income (₹)
  - Total Expense (₹)
  - Balance (₹)
- **Add Transaction Form**: 
  - Title, Amount, Category, Type (Income/Expense), Date
  - Multiple categories: Food, Travel, Rent, Shopping, Entertainment, etc.
- **Transaction History Table**: 
  - Full list of all transactions
  - Sortable by date
  - Delete functionality
- **Category-wise Breakdown**: 
  - Visual breakdown of expenses by category
  - Total expense summary

## 🛠️ Tech Stack

- **Frontend**: React 19.2.0
- **Build Tool**: Vite 7.2.4
- **Routing**: React Router DOM 7.2.0
- **Database**: Supabase (PostgreSQL)
- **Styling**: Pure CSS (following design guidelines)
- **State Management**: React useState & useEffect (no Redux)

## 📋 Database Schema

### Users Table
```sql
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Expenses Table
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

## 🚀 Getting Started

### Prerequisites
- Node.js (v18 or higher)
- npm or yarn
- Supabase account

### Step 1: Clone & Install

```bash
cd EXPENSE\ TRACKER
npm install
```

### Step 2: Setup Supabase

1. Go to [https://supabase.com](https://supabase.com)
2. Create a new project
3. Wait for the database to be ready
4. Go to **Project Settings → API**
5. Copy your:
   - Project URL
   - `anon public` key

### Step 3: Configure Database

1. Open the **SQL Editor** in Supabase
2. Run the SQL commands from `SUPABASE_SETUP.md`:
   - Create `users` table
   - Create `expenses` table
   - Create indexes
   - Disable RLS (for simplicity)

### Step 4: Update Configuration

Open `src/utils/supabase.js` and replace:

```javascript
const supabaseUrl = 'YOUR_SUPABASE_URL'
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'
```

### Step 5: Run the Application

```bash
npm run dev
```

The app will open at `http://localhost:5173`

## 📱 Usage

1. **Register**: Create a new account with name, email, and password
2. **Login**: Sign in with your credentials
3. **Dashboard**: 
   - View your financial summary
   - Add new income/expense transactions
   - View transaction history
   - See category-wise breakdown
4. **Delete**: Remove unwanted transactions
5. **Logout**: Sign out from the dashboard header

## 🎨 Design Philosophy

Following modern UI/UX principles:
- **Clean & Minimal**: Focus on content, reduce visual noise
- **Consistent**: Uniform spacing, colors, and components
- **Professional**: Modern, polished interface
- **Responsive**: Mobile-first approach
- **Accessible**: Semantic HTML and proper form labels

### Color System
- **Primary**: Blue (#2563eb) - Actions and links
- **Success**: Green (#10b981) - Income and positive balance
- **Danger**: Red (#ef4444) - Expenses and delete actions
- **Neutral**: Slate tones for text and borders

## 📂 Project Structure

```
expense-tracker/
├── src/
│   ├── pages/
│   │   ├── Login.jsx          # Login page
│   │   ├── Register.jsx       # Registration page
│   │   └── Dashboard.jsx      # Main dashboard
│   ├── utils/
│   │   ├── supabase.js        # Supabase client
│   │   └── auth.js            # Auth utilities
│   ├── App.jsx                # Main app with routing
│   ├── App.css                # Component styles
│   ├── index.css              # Global styles
│   └── main.jsx               # Entry point
├── public/
├── SUPABASE_SETUP.md          # Database setup guide
├── package.json
└── README.md
```

## 🔒 Security Notes

**⚠️ IMPORTANT**: This is an educational project with intentional simplifications:

- **Plain Text Passwords**: Passwords are stored in plain text for learning purposes
- **No Password Hashing**: In production, use bcrypt, argon2, or similar
- **No RLS**: Row Level Security is disabled for simplicity
- **localStorage Auth**: Simple session management

### For Production:
1. Implement password hashing (bcrypt/argon2)
2. Enable Row Level Security in Supabase
3. Use secure session management (JWT tokens)
4. Add input validation and sanitization
5. Implement rate limiting
6. Add HTTPS/SSL

## 🚀 Future Enhancements

- [ ] Password hashing (bcrypt)
- [ ] Charts and visualizations (Recharts)
- [ ] Export data (CSV/PDF)
- [ ] Budget goals and alerts
- [ ] Recurring transactions
- [ ] Multi-currency support
- [ ] Dark mode
- [ ] Expense categories customization
- [ ] Data filtering and date range selection
- [ ] Mobile app (React Native)

## 📝 License

This is an educational project. Feel free to use and modify as needed.

## 🤝 Contributing

This is a learning project. Suggestions and improvements are welcome!

---

**Built with ❤️ using React + Vite + Supabase**
