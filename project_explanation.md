# 💰 Expense Tracker - Complete Project Explanation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Project Architecture](#project-architecture)
4. [Database Design](#database-design)
5. [Application Structure](#application-structure)
6. [Authentication System](#authentication-system)
7. [Core Features](#core-features)
8. [Complete Workflows](#complete-workflows)
9. [Styling and Design](#styling-and-design)
10. [How Everything Works Together](#how-everything-works-together)

---

## Project Overview

### What is This Project?
The Expense Tracker is a modern, full-stack web application that helps users manage their personal finances by tracking income and expenses. It provides a clean, intuitive interface for recording financial transactions, viewing spending patterns, setting budgets, and analyzing expenses by category.

### What Does It Do?
The application enables users to:
- **Create an account** and securely log in
- **Add transactions** (both income and expenses) with details like title, amount, category, and date
- **View all transactions** in a sortable, searchable table
- **Edit and delete** existing transactions
- **Track spending** across 9 predefined categories (Food, Travel, Rent, Shopping, Entertainment, Healthcare, Education, Utilities, Other)
- **Set monthly budgets** for each category with visual progress indicators
- **View financial summaries** including total income, total expenses, and current balance
- **Analyze spending patterns** with category-wise breakdowns
- **Search and filter** transactions by keywords and categories
- **Sort transactions** by date, amount, or title in ascending/descending order

### Key Characteristics
- **Single Page Application (SPA)** with client-side routing
- **Real-time data synchronization** with cloud database
- **Responsive design** optimized for laptop screens (1440px-1920px)
- **Modern UI** with glassmorphism effects and aurora-inspired dark theme
- **Educational project** demonstrating React fundamentals and Supabase integration

---

## Technology Stack

### Frontend Technologies

#### 1. **React 19.2.0**
- **Purpose**: Core UI framework for building interactive user interfaces
- **How It's Used**:
  - Component-based architecture for reusable UI elements
  - Hooks (`useState`, `useEffect`, `useMemo`, `useCallback`) for state and side effects
  - No class components - entirely functional components
  - Virtual DOM for efficient rendering and updates
  
#### 2. **React Router DOM 7.12.0**
- **Purpose**: Client-side routing for navigation without page reloads
- **How It's Used**:
  - `BrowserRouter` wraps the entire application
  - `Routes` and `Route` components define URL paths
  - `Navigate` component for programmatic redirects
  - `useNavigate` hook for navigation after actions (login, logout, register)
  - Protected routes that check authentication before rendering
  - Route configuration:
    - `/login` → Login page
    - `/register` → Register page
    - `/dashboard` → Main app (protected)
    - `/` → Redirects to dashboard
    - `*` (catch-all) → Redirects to dashboard

#### 3. **Vite 7.2.4**
- **Purpose**: Modern build tool and development server
- **How It's Used**:
  - Lightning-fast Hot Module Replacement (HMR) during development
  - Optimized production builds with code splitting
  - ES modules support for native browser imports
  - `@vitejs/plugin-react` for React Fast Refresh
  - Simple configuration in `vite.config.js`
  - Development server: `npm run dev`
  - Production build: `npm run build`

#### 4. **Pure CSS (No Framework)**
- **Purpose**: Custom styling without external CSS frameworks
- **How It's Used**:
  - CSS Variables for consistent theming
  - Flexbox and Grid for layouts
  - Custom animations and transitions
  - Responsive design with media queries (though optimized for desktop)
  - Two main stylesheets:
    - `index.css` - Global styles, variables, resets
    - `App.css` - Component-specific styles

### Backend Technologies

#### 5. **Supabase (PostgreSQL)**
- **Purpose**: Backend-as-a-Service providing database, authentication, and real-time APIs
- **How It's Used**:
  - **PostgreSQL Database**: Stores users, expenses, and budgets
  - **REST API**: Auto-generated CRUD endpoints for each table
  - **JavaScript Client**: `@supabase/supabase-js` library for database operations
  - **No custom backend server**: Everything goes through Supabase's API
  - Client initialization in `src/utils/supabase.js`:
    ```javascript
    const supabase = createClient(supabaseUrl, supabaseAnonKey)
    ```

### Development Tools

#### 6. **ESLint**
- **Purpose**: Code linting and quality checks
- **Configuration**: `eslint.config.js` with React-specific rules
- **Plugins**: 
  - `eslint-plugin-react-hooks` - enforces React Hooks rules
  - `eslint-plugin-react-refresh` - validates Fast Refresh constraints

#### 7. **npm**
- **Purpose**: Package manager for installing dependencies
- **Scripts**:
  - `npm run dev` - Start development server
  - `npm run build` - Create production build
  - `npm run lint` - Run ESLint
  - `npm run preview` - Preview production build

---

## Project Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    User's Browser                       │
│  ┌───────────────────────────────────────────────────┐ │
│  │         React Application (SPA)                   │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │ │
│  │  │   Login     │  │  Register   │  │Dashboard │ │ │
│  │  └─────────────┘  └─────────────┘  └──────────┘ │ │
│  │                                                   │ │
│  │  ┌─────────────────────────────────────────────┐ │ │
│  │  │         React Router DOM                    │ │ │
│  │  │  (Client-side routing)                      │ │ │
│  │  └─────────────────────────────────────────────┘ │ │
│  │                                                   │ │
│  │  ┌─────────────────────────────────────────────┐ │ │
│  │  │      Supabase JavaScript Client             │ │ │
│  │  │  (Database operations via REST API)         │ │ │
│  │  └─────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                          │
                          │ HTTPS Requests
                          ▼
┌─────────────────────────────────────────────────────────┐
│              Supabase Cloud Platform                    │
│  ┌───────────────────────────────────────────────────┐ │
│  │           PostgreSQL Database                     │ │
│  │  ┌──────────┐  ┌──────────┐  ┌─────────┐        │ │
│  │  │  users   │  │ expenses │  │ budgets │        │ │
│  │  │  table   │  │  table   │  │  table  │        │ │
│  │  └──────────┘  └──────────┘  └─────────┘        │ │
│  └───────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────┐ │
│  │          Auto-Generated REST API                  │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Application Flow

1. **Entry Point**: `index.html` loads the React app
2. **Main Module**: `main.jsx` renders the `App` component
3. **Router Setup**: `App.jsx` configures routes and protected routes
4. **Authentication Check**: Protected routes verify user session in localStorage
5. **Data Fetching**: Components use Supabase client to fetch/update data
6. **State Management**: React hooks manage local component state
7. **Re-rendering**: React updates UI when state changes

### Component Architecture

```
App.jsx (Root Component)
│
├── Login.jsx (Public Route)
│   ├── Form (email, password)
│   └── Supabase Query (user authentication)
│
├── Register.jsx (Public Route)
│   ├── Form (name, email, password, confirmPassword)
│   └── Supabase Query (user creation)
│
└── Dashboard.jsx (Protected Route)
    ├── Left Sidebar
    │   ├── User Profile (avatar, name, email)
    │   ├── Quick Stats (income, expense, balance)
    │   └── Logout Button
    │
    ├── Main Content (Center Panel)
    │   ├── Header
    │   ├── Add Transaction Form
    │   ├── Search & Filter Section
    │   └── Transactions Table (with inline editing)
    │
    └── Right Sidebar
        ├── Monthly Budgets (with progress bars)
        └── Category Breakdown
```

---

## Database Design

### Database Schema

The application uses three PostgreSQL tables in Supabase:

#### 1. **users** Table

**Purpose**: Store user account information for authentication

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique user identifier |
| `name` | TEXT | NOT NULL, length 2-100 | User's full name |
| `email` | TEXT | UNIQUE NOT NULL, valid email format | Login identifier |
| `password` | TEXT | NOT NULL, min length 6 | Plain text password (educational only) |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Account creation timestamp |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | Last update timestamp |

**Indexes**:
- `idx_users_email` on `email` for fast login queries

**Triggers**:
- `update_users_updated_at` - automatically updates `updated_at` on record changes

#### 2. **expenses** Table

**Purpose**: Store all financial transactions (both income and expenses)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique transaction ID |
| `user_id` | UUID | FOREIGN KEY → users(id), NOT NULL, ON DELETE CASCADE | Owner of transaction |
| `title` | TEXT | NOT NULL, length 1-200 | Transaction description |
| `amount` | NUMERIC(12,2) | NOT NULL, CHECK > 0 | Transaction amount (always positive) |
| `category` | TEXT | NOT NULL, CHECK IN (...) | One of 9 predefined categories |
| `type` | TEXT | NOT NULL, CHECK IN ('income', 'expense') | Transaction type |
| `date` | DATE | NOT NULL | Date of transaction |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Record creation timestamp |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | Last update timestamp |

**Valid Categories**: 'Food', 'Travel', 'Rent', 'Shopping', 'Entertainment', 'Healthcare', 'Education', 'Utilities', 'Other'

**Indexes**:
- `idx_expenses_user_id` on `user_id` - fast user-specific queries
- `idx_expenses_date` on `date DESC` - sorted date queries
- `idx_expenses_type` on `type` - income/expense filtering
- `idx_expenses_user_date` on `(user_id, date DESC)` - composite index

**Foreign Key**:
- `user_id` references `users(id)` with `ON DELETE CASCADE` (deleting a user removes all their transactions)

**Triggers**:
- `update_expenses_updated_at` - automatically updates `updated_at` on changes

#### 3. **budgets** Table

**Purpose**: Store monthly spending limits for each category per user

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique budget ID |
| `user_id` | UUID | FOREIGN KEY → users(id), NOT NULL, ON DELETE CASCADE | Owner of budget |
| `category` | TEXT | NOT NULL, CHECK IN (...) | Budget category |
| `monthly_limit` | NUMERIC(12,2) | NOT NULL, CHECK > 0 | Maximum spending per month |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Record creation timestamp |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | Last update timestamp |

**Unique Constraint**: `(user_id, category)` - only one budget per category per user

**Indexes**:
- `idx_budgets_user_id` on `user_id`
- `idx_budgets_category` on `category`
- `idx_budgets_user_category` on `(user_id, category)`

**Row Level Security (RLS)**: Enabled with policies ensuring users can only see/modify their own budgets

**Triggers**:
- `update_budgets_updated_at` - automatically updates `updated_at` on changes

### Database Relationships

```
users (1) ──────────< (many) expenses
  │
  │
  └──────────< (many) budgets

- One user can have many expenses
- One user can have many budgets
- Deleting a user cascades to delete all their expenses and budgets
```

### Security Considerations

**Current Implementation** (Educational):
- Passwords stored as **plain text** (NOT production-safe)
- RLS disabled on `users` and `expenses` tables
- RLS enabled on `budgets` table with basic policies
- Client-side authentication using localStorage

**Production Recommendations** (Not Implemented):
- Use bcrypt/argon2 for password hashing
- Enable RLS on all tables
- Implement proper JWT-based authentication
- Use Supabase Auth instead of custom auth
- Add server-side validation

---

## Application Structure

### File Organization

```
EXPENSE TRACKER/
│
├── index.html                 # HTML entry point
├── package.json              # Dependencies and scripts
├── vite.config.js           # Vite configuration
├── eslint.config.js         # ESLint configuration
├── README.md                # Project documentation
│
├── public/                  # Static assets (served as-is)
│
├── docs/                    # Documentation files
│   ├── database_setup.sql          # Complete SQL schema
│   ├── budgets_table_setup.sql     # Budgets table DDL
│   ├── SUPABASE_SETUP.md           # Database setup guide
│   ├── FEATURES.md                 # Feature checklist
│   ├── ExpenseTracker_System_and_Workflows.md  # Technical docs
│   ├── DEPLOYMENT.md               # Deployment guide
│   ├── Design_UI_temp.md           # Design specifications
│   └── QUICK_START.md              # Quick start guide
│
└── src/                     # Source code
    ├── main.jsx            # Application entry point
    ├── App.jsx             # Root component with routing
    ├── App.css             # Component styles
    ├── index.css           # Global styles and variables
    │
    ├── assets/             # Images, icons, etc.
    │
    ├── pages/              # Page components
    │   ├── Login.jsx              # Login page
    │   ├── Register.jsx           # Registration page
    │   ├── Dashboard.jsx          # Main dashboard
    │   └── Dashboard.jsx.backup   # Backup file
    │
    └── utils/              # Utility modules
        ├── supabase.js            # Supabase client
        └── auth.js                # Auth helper functions
```

### Key Files Explained

#### **index.html**
- Root HTML file loaded by the browser
- Contains a single `<div id="root">` where React mounts
- Links to `src/main.jsx` via `<script type="module">`
- Sets page title to "expense-tracker"

#### **main.jsx**
- Application entry point
- Imports React, ReactDOM, global styles
- Renders `<App />` component into `#root` div
- Wraps app in `<StrictMode>` for development warnings

#### **App.jsx**
- Root React component
- Configures React Router with all routes
- Implements `ProtectedRoute` component for authentication
- Routes:
  - Public: `/login`, `/register`
  - Protected: `/dashboard`
  - Redirects: `/` → `/dashboard`, `*` → `/dashboard`

#### **src/utils/supabase.js**
- Creates and exports Supabase client instance
- Configured with project URL and anonymous API key
- Single source of truth for database connection
- Imported by all pages that need database access

#### **src/utils/auth.js**
- Authentication helper functions using localStorage
- `setUser(user)` - saves user object to localStorage
- `getUser()` - retrieves user from localStorage
- `logout()` - removes user from localStorage
- `isAuthenticated()` - checks if user exists

#### **src/pages/Login.jsx**
- Login page component
- Form with email and password fields
- Queries Supabase to verify credentials
- Compares plain text passwords
- Stores user in localStorage on success
- Redirects to dashboard after login

#### **src/pages/Register.jsx**
- Registration page component
- Form with name, email, password, confirmPassword
- Validates password match and length
- Checks email uniqueness in database
- Creates new user record in Supabase
- Redirects to login after successful registration

#### **src/pages/Dashboard.jsx**
- Main application interface (779 lines)
- Three-column layout: left sidebar, main content, right sidebar
- Manages all application state
- Handles CRUD operations for transactions and budgets
- Implements search, filter, and sort functionality
- Real-time calculations for totals and breakdowns

#### **index.css**
- Global styles and CSS variables
- Dark theme color palette
- Typography system
- Spacing scale
- Border radius values
- Shadow definitions
- Transition timings
- Scrollbar styling
- Reset styles

#### **App.css**
- Component-specific styles
- Authentication page styles
- Dashboard layout (3-column grid)
- Form elements
- Buttons (primary, secondary, edit, delete)
- Transaction table
- Cards and sections
- Progress bars
- Empty states

---

## Authentication System

### How Authentication Works

This application uses a **custom authentication system** (not Supabase Auth) with **localStorage-based session management**.

### Authentication Flow

#### **Registration Process**

1. **User Action**: User fills registration form (name, email, password, confirmPassword)
2. **Client-Side Validation**:
   - All fields required
   - Passwords must match
   - Password minimum length: 6 characters
3. **Email Uniqueness Check**:
   ```javascript
   const { data: existingUser } = await supabase
     .from('users')
     .select('id')
     .eq('email', formData.email)
     .single()
   ```
4. **User Creation**:
   ```javascript
   const { data, error } = await supabase
     .from('users')
     .insert([{
       name: formData.name,
       email: formData.email,
       password: formData.password  // Plain text (educational only)
     }])
     .select()
     .single()
   ```
5. **Success**: Alert shown, redirected to login page
6. **Error**: Display error message (email exists, database error, etc.)

#### **Login Process**

1. **User Action**: User enters email and password
2. **Client-Side Validation**: Both fields required
3. **User Lookup**:
   ```javascript
   const { data: user, error } = await supabase
     .from('users')
     .select('*')
     .eq('email', formData.email)
     .single()
   ```
4. **Password Verification**: Plain text comparison
   ```javascript
   if (user.password !== formData.password) {
     setError('Invalid email or password')
     return
   }
   ```
5. **Session Creation**:
   ```javascript
   const userToStore = {
     id: user.id,
     name: user.name,
     email: user.email
     // Note: password NOT stored in localStorage
   }
   setUser(userToStore)  // Saves to localStorage
   ```
6. **Success**: Redirect to dashboard
7. **Error**: Display "Invalid email or password"

#### **Session Persistence**

- User data stored in browser's localStorage under key `"user"`
- Format: JSON stringified object
- Persists across page refreshes and browser sessions
- Cleared only on logout or manual browser data clearing

#### **Protected Routes**

```javascript
const ProtectedRoute = ({ children }) => {
  return isAuthenticated() ? children : <Navigate to="/login" replace />
}
```

- Checks if user exists in localStorage
- If authenticated: renders requested component
- If not authenticated: redirects to login page
- Applied to `/dashboard` route

#### **Logout Process**

1. **User Action**: Clicks "Logout" button in dashboard sidebar
2. **Clear Session**: 
   ```javascript
   logout()  // Removes 'user' from localStorage
   ```
3. **Redirect**: Navigate to login page
4. **Effect**: User can no longer access protected routes

### Security Notes

**Current Implementation** (Educational):
- ❌ Passwords stored in plain text
- ❌ No HTTPS enforcement
- ❌ No session expiration
- ❌ No CSRF protection
- ❌ Client-side only validation
- ❌ localStorage is not secure (accessible via XSS)

**This is intentional** for learning purposes. In production, you would:
- ✅ Use bcrypt/argon2 for password hashing
- ✅ Implement proper JWT authentication
- ✅ Use Supabase Auth or similar service
- ✅ Add session expiration
- ✅ Use httpOnly cookies instead of localStorage
- ✅ Implement rate limiting
- ✅ Add two-factor authentication

---

## Core Features

### 1. User Profile & Quick Stats (Left Sidebar)

**Location**: Left sidebar of Dashboard

**Components**:
- **User Avatar**: Circular badge with user initials
  - Extracts first letters of first and last name
  - Example: "John Doe" → "JD"
- **User Name**: Displayed below avatar
- **Email**: User's registered email
- **Quick Stats Cards**:
  - Total Income (green accent)
  - Total Expense (red accent)
  - Balance (dynamic color: green if positive, red if negative)
- **Logout Button**: At bottom of sidebar

**Data Source**: 
- User info from localStorage
- Totals calculated from `expenses` array using `useMemo`:
  ```javascript
  const totalIncome = useMemo(() => {
    return filteredAndSortedExpenses
      .filter(e => e.type === 'income')
      .reduce((sum, e) => sum + parseFloat(e.amount), 0)
  }, [filteredAndSortedExpenses])
  ```

**Currency Formatting**: Indian Rupee (₹) with locale formatting
```javascript
₹ {totalIncome.toLocaleString('en-IN')}
```

### 2. Add Transaction Form (Main Content)

**Location**: Top of center panel

**Form Fields**:
1. **Title** (text input) - Transaction description
2. **Amount** (number input) - Transaction value, step 0.01
3. **Category** (dropdown) - 9 options
4. **Type** (dropdown) - 'income' or 'expense'
5. **Date** (date picker) - Defaults to today

**Categories**:
- Food
- Travel
- Rent
- Shopping
- Entertainment
- Healthcare
- Education
- Utilities
- Other

**Validation**:
- All fields required
- Amount must be > 0
- Error banner displays above form if validation fails

**Submission Process**:
```javascript
const { error: insertError } = await supabase
  .from('expenses')
  .insert([{
    user_id: user.id,
    title: formData.title,
    amount: parseFloat(formData.amount),
    category: formData.category,
    type: formData.type,
    date: formData.date
  }])
  .select()
```

**Post-Submission**:
- Form resets to default values
- `fetchExpenses()` called to refresh table
- New transaction appears in table immediately

### 3. Search & Filter Section (Main Content)

**Location**: Below Add Transaction form

**Components**:

#### **Search Bar**
- Free-text input field
- Searches across:
  - Transaction title
  - Category name
  - Amount value
- Case-insensitive
- Real-time filtering (no submit button)
- "Clear Filters" button appears when active

#### **Category Filter Chips**
- 9 clickable chips (one per category)
- Multi-select: can select multiple categories
- Active chips highlighted with accent color
- Filter logic: show only transactions matching selected categories

#### **Sort Dropdown**
- Options:
  - Date (Newest First) - default
  - Date (Oldest First)
  - Amount (High to Low)
  - Amount (Low to High)
  - Title (A-Z)
  - Title (Z-A)
- Single select
- Applied immediately on change

**Implementation**:
```javascript
const filteredAndSortedExpenses = useMemo(() => {
  let filtered = expenses

  // Search filter
  if (searchQuery) {
    filtered = filtered.filter(expense => 
      expense.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      expense.category.toLowerCase().includes(searchQuery.toLowerCase()) ||
      expense.amount.toString().includes(searchQuery)
    )
  }

  // Category filter
  if (selectedCategories.length > 0) {
    filtered = filtered.filter(expense => 
      selectedCategories.includes(expense.category)
    )
  }

  // Sort
  filtered = [...filtered].sort((a, b) => {
    // Sort logic based on sortField and sortOrder
  })

  return filtered
}, [expenses, searchQuery, selectedCategories, sortField, sortOrder])
```

**Performance Optimization**: `useMemo` ensures filtering/sorting only runs when dependencies change

### 4. Transaction History Table (Main Content)

**Location**: Bottom of center panel

**Table Columns**:
- Date (formatted as locale date string)
- Title
- Category
- Type (badge: green for income, red for expense)
- Amount (with + or - prefix, colored accordingly)
- Actions (Edit and Delete buttons)

**Features**:

#### **Inline Editing**
1. Click "Edit" button
2. Row switches to edit mode with input fields
3. All fields become editable
4. "Save" and "Cancel" buttons replace "Edit" and "Delete"
5. Click "Save" to update database
6. Click "Cancel" to discard changes

**Update Operation**:
```javascript
const { error } = await supabase
  .from('expenses')
  .update({
    title: editFormData.title,
    amount: parseFloat(editFormData.amount),
    category: editFormData.category,
    type: editFormData.type,
    date: editFormData.date
  })
  .eq('id', id)
```

#### **Delete Functionality**
1. Click "Delete" button
2. Confirmation dialog appears
3. If confirmed, delete from database
4. Table refreshes automatically

**Delete Operation**:
```javascript
const { error } = await supabase
  .from('expenses')
  .delete()
  .eq('id', id)
```

#### **States**:
- **Loading**: Spinner with "Loading transactions..." message
- **Empty**: Icon with "No transactions found. Add your first transaction!"
- **Populated**: Full table with all transactions

**Row Count**: Displayed in section header: "Transaction History (X)"

### 5. Monthly Budgets (Right Sidebar)

**Location**: Top of right sidebar

**Purpose**: Set spending limits for categories and track progress

**Components**:

#### **Add Budget Button**
- "+" button in section header
- Triggers two prompts:
  1. Enter category name
  2. Enter monthly limit amount
- Creates or updates budget via upsert operation

**Upsert Operation**:
```javascript
const { error } = await supabase
  .from('budgets')
  .upsert([{
    user_id: user.id,
    category: category,
    monthly_limit: parseFloat(limit)
  }])
```

#### **Budget Cards**
Each budget displays:
- Category name
- Monthly limit (₹)
- Progress bar (visual)
- Amount spent this month
- Percentage used

**Progress Calculation**:
```javascript
const getCurrentMonthSpending = (category) => {
  const now = new Date()
  const firstDay = new Date(now.getFullYear(), now.getMonth(), 1)
  const lastDay = new Date(now.getFullYear(), now.getMonth() + 1, 0)

  return expenses
    .filter(e => 
      e.type === 'expense' &&
      e.category === category &&
      new Date(e.date) >= firstDay &&
      new Date(e.date) <= lastDay
    )
    .reduce((sum, e) => sum + parseFloat(e.amount), 0)
}
```

**Progress Bar Colors**:
- **Green** (safe): < 70% of budget
- **Yellow** (warning): 70-90% of budget
- **Red** (danger): > 90% of budget

**Delete Budget**: Each budget card has delete functionality (implementation in code)

**Empty State**: "No budgets set. Click '+ Add' to create one."

### 6. Category Breakdown (Right Sidebar)

**Location**: Bottom of right sidebar

**Purpose**: Show total expenses per category

**Display**:
- List of categories with expense amounts
- Sorted by amount (highest first)
- Only shows categories with expenses > 0
- Total row at bottom showing sum of all expenses

**Calculation**:
```javascript
const categoryBreakdown = useMemo(() => {
  return filteredAndSortedExpenses
    .filter(e => e.type === 'expense')
    .reduce((acc, e) => {
      acc[e.category] = (acc[e.category] || 0) + parseFloat(e.amount)
      return acc
    }, {})
}, [filteredAndSortedExpenses])
```

**Format**:
```
Food              ₹ 5,234
Travel            ₹ 3,890
Shopping          ₹ 2,150
...
───────────────────────────
Total Expenses    ₹ 15,420
```

**Empty State**: "No expense data to display."

---

## Complete Workflows

### Workflow 1: New User Registration

**Step-by-Step Process**:

1. **Landing**: User visits app → Auto-redirected to `/dashboard`
2. **Authentication Check**: No user in localStorage → Redirected to `/login`
3. **Navigate to Register**: User clicks "Register here" link
4. **Form Fill**:
   - Name: "John Doe"
   - Email: "john@example.com"
   - Password: "password123"
   - Confirm Password: "password123"
5. **Client Validation**:
   - ✓ All fields filled
   - ✓ Passwords match
   - ✓ Password length ≥ 6
6. **Submit**: Click "Register" button
7. **Loading State**: Button disabled, text changes to "Creating Account..."
8. **Email Check Query**:
   ```sql
   SELECT id FROM users WHERE email = 'john@example.com'
   ```
9. **Insert Query**:
   ```sql
   INSERT INTO users (name, email, password) 
   VALUES ('John Doe', 'john@example.com', 'password123')
   ```
10. **Success**:
    - Alert: "Registration successful! Please login."
    - Redirect to `/login`
11. **Error Handling** (if any):
    - Email exists → "Email already exists"
    - Database error → Show error message

### Workflow 2: User Login

**Step-by-Step Process**:

1. **Login Page**: User at `/login`
2. **Form Fill**:
   - Email: "john@example.com"
   - Password: "password123"
3. **Client Validation**: Both fields filled
4. **Submit**: Click "Login" button
5. **Loading State**: Button disabled, text changes to "Logging in..."
6. **User Lookup Query**:
   ```sql
   SELECT * FROM users WHERE email = 'john@example.com'
   ```
7. **Password Check**: Compare `user.password` with entered password
8. **Session Creation**:
   ```javascript
   localStorage.setItem('user', JSON.stringify({
     id: 'uuid-here',
     name: 'John Doe',
     email: 'john@example.com'
   }))
   ```
9. **Redirect**: Navigate to `/dashboard`
10. **Dashboard Load**: User info displayed, expenses fetched

**Error Cases**:
- Email not found → "Invalid email or password"
- Password mismatch → "Invalid email or password"
- Database error → Show error message

### Workflow 3: Adding a Transaction

**Step-by-Step Process**:

1. **Dashboard Loaded**: User authenticated and viewing dashboard
2. **Form Interaction**: User fills "Add Transaction" form
   - Title: "Grocery Shopping"
   - Amount: 1234.56
   - Category: "Food"
   - Type: "expense"
   - Date: 2026-01-30
3. **Submit**: Click "Add Transaction" button
4. **Validation**:
   - ✓ Title not empty
   - ✓ Amount > 0
   - ✓ Date provided
5. **Insert Query**:
   ```sql
   INSERT INTO expenses (user_id, title, amount, category, type, date)
   VALUES ('user-uuid', 'Grocery Shopping', 1234.56, 'Food', 'expense', '2026-01-30')
   ```
6. **Success**:
   - Form resets to defaults
   - `fetchExpenses()` called
   - Table refreshes
   - New transaction appears at top (sorted by date desc)
7. **Side Effects**:
   - Total Expense increases by ₹1,234.56
   - Balance decreases by ₹1,234.56
   - Food category in breakdown increases by ₹1,234.56
   - If Food budget exists, progress bar updates
8. **Error**: Show error message above form

### Workflow 4: Editing a Transaction

**Step-by-Step Process**:

1. **Transaction Table**: User viewing list of transactions
2. **Initiate Edit**: Click "Edit" button on a row
3. **Edit Mode Activated**:
   - `setEditingId(expense.id)`
   - `setEditFormData({ title, amount, category, type, date })`
   - Row cells become input fields
   - "Save" and "Cancel" buttons appear
4. **User Edits**:
   - Changes title from "Grocery Shopping" to "Monthly Groceries"
   - Changes amount from 1234.56 to 1500.00
5. **Save**: Click "Save" button
6. **Update Query**:
   ```sql
   UPDATE expenses 
   SET title = 'Monthly Groceries', amount = 1500.00
   WHERE id = 'expense-uuid'
   ```
7. **Success**:
   - `setEditingId(null)`
   - `setEditFormData({})`
   - `fetchExpenses()` called
   - Table refreshes with updated data
   - All calculated values (totals, breakdowns, budgets) update
8. **Cancel**: Click "Cancel" button
   - Discard changes
   - Exit edit mode
   - Row returns to normal view

### Workflow 5: Deleting a Transaction

**Step-by-Step Process**:

1. **Transaction Table**: User viewing list of transactions
2. **Initiate Delete**: Click "Delete" button on a row
3. **Confirmation**: Browser confirm dialog appears
   - Message: "Are you sure you want to delete this expense?"
4. **User Confirms**: Click "OK"
5. **Delete Query**:
   ```sql
   DELETE FROM expenses WHERE id = 'expense-uuid'
   ```
6. **Success**:
   - `fetchExpenses()` called
   - Table refreshes
   - Deleted row disappears
   - All totals recalculate
   - Category breakdown updates
   - Budget progress updates
7. **User Cancels**: Click "Cancel" on dialog
   - No database operation
   - Row remains unchanged

### Workflow 6: Searching & Filtering

**Step-by-Step Process**:

1. **Dashboard**: User viewing all transactions
2. **Search**: Type "grocery" in search bar
3. **Real-time Filter**: 
   - Component re-renders on each keystroke
   - `filteredAndSortedExpenses` recalculates via `useMemo`
   - Only transactions with "grocery" in title/category/amount show
   - Table updates instantly
4. **Category Filter**: Click "Food" chip
5. **Combined Filter**:
   - Transactions must match search query AND selected category
   - Further narrows results
6. **Add More Categories**: Click "Travel" chip
7. **OR Logic**: Show transactions in Food OR Travel (that also match search)
8. **Sort**: Select "Amount (High to Low)"
9. **Final Result**: Filtered and sorted list displayed
10. **Clear**: Click "Clear Filters"
    - `setSearchQuery('')`
    - `setSelectedCategories([])`
    - All transactions reappear

**Filter Logic** (executed in order):
1. Apply search query filter
2. Apply category filter
3. Apply sort

### Workflow 7: Setting a Budget

**Step-by-Step Process**:

1. **Dashboard**: User in right sidebar
2. **Initiate**: Click "+ Add" button in "Monthly Budgets" section
3. **Category Prompt**: 
   - Browser prompt: "Enter category:"
   - Default: "Food"
   - User types: "Food"
4. **Limit Prompt**:
   - Browser prompt: "Enter monthly limit (₹):"
   - User types: "5000"
5. **Validation**:
   - Category not empty
   - Limit > 0
6. **Upsert Query**:
   ```sql
   INSERT INTO budgets (user_id, category, monthly_limit)
   VALUES ('user-uuid', 'Food', 5000)
   ON CONFLICT (user_id, category) 
   DO UPDATE SET monthly_limit = 5000
   ```
   (Actual implementation uses Supabase's `.upsert()`)
7. **Calculate Current Spending**:
   - Query expenses for current month
   - Filter by category = 'Food' and type = 'expense'
   - Sum amounts
   - Example: ₹3,450 spent
8. **Calculate Progress**:
   - Percentage: (3450 / 5000) * 100 = 69%
   - Status: "safe" (< 70%)
9. **Display Budget Card**:
   ```
   Food                    ₹ 5,000
   [====================69%=====] (green bar)
   Spent: ₹ 3,450          69.0%
   ```
10. **Real-time Updates**: As user adds/edits/deletes Food expenses, progress bar updates automatically

### Workflow 8: User Logout

**Step-by-Step Process**:

1. **Dashboard**: User viewing application
2. **Click Logout**: Button in left sidebar
3. **Handler Executes**:
   ```javascript
   logout()           // Removes user from localStorage
   navigate('/login') // Redirect to login page
   ```
4. **Cleanup**:
   - localStorage cleared
   - `isAuthenticated()` now returns false
5. **Login Page**: User redirected to `/login`
6. **Protected Route Effect**: 
   - If user tries to access `/dashboard` directly
   - `ProtectedRoute` checks `isAuthenticated()`
   - Returns false
   - Redirects back to `/login`

### Workflow 9: Session Persistence

**Step-by-Step Process**:

1. **Initial State**: User logged in, viewing dashboard
2. **Action**: User closes browser tab
3. **Next Day**: User opens browser, navigates to app
4. **Landing**: App loads at `/`
5. **Redirect**: Router redirects to `/dashboard`
6. **ProtectedRoute Check**:
   ```javascript
   const user = localStorage.getItem('user')
   // User still exists from yesterday
   ```
7. **Result**: Dashboard loads without requiring re-login
8. **Data Fetch**: `fetchExpenses()` and `fetchBudgets()` load fresh data from Supabase

**Session Ends When**:
- User clicks logout
- User clears browser data
- User manually deletes localStorage

---

## Styling and Design

### Design System

**Theme**: Aurora Dark - Modern, elegant, glassmorphism-inspired

**Design Principles**:
1. **Minimalism**: Clean, clutter-free interfaces
2. **Consistency**: Uniform spacing, colors, and typography
3. **Hierarchy**: Clear visual structure with proper sizing
4. **Feedback**: Hover states, transitions, and loading indicators
5. **Accessibility**: Readable text, proper contrast, focus states

### Color Palette

#### **Background Colors**
```css
--color-background: #0b101b        (Deep navy - main background)
--color-background-alt: #0f1727    (Slightly lighter navy)
--color-surface: rgba(18, 26, 43, 0.9)  (Card background with transparency)
--color-surface-elevated: rgba(24, 34, 56, 0.9)  (Elevated cards)
```

#### **Border Colors**
```css
--color-border: #1f2a3d           (Primary border)
--color-border-subtle: #142034    (Subtle border)
```

#### **Text Colors**
```css
--color-text-primary: #e9eef7     (Main text - bright)
--color-text-secondary: #b8c4d8   (Secondary text - medium)
--color-text-tertiary: #8894a8    (Tertiary text - dim)
--color-text-disabled: #5a6474    (Disabled text)
```

#### **Accent Colors**
```css
--color-accent: #7aa8ff           (Aurora blue - primary accent)
--color-accent-hover: #5c8fff     (Hover state)
--color-accent-light: rgba(122, 168, 255, 0.16)  (Light tint)
```

#### **Semantic Colors**
```css
--color-success: #5ad8a1          (Green - income)
--color-danger: #ff6b6b           (Red - expenses)
--color-warning: #f7c266          (Yellow - warnings)
--color-income: #5ad8a1           (Same as success)
--color-expense: #ff6b6b          (Same as danger)
```

### Typography

**Font Family**: Inter (Google Fonts)
- Weights: 300, 400, 500, 600, 700
- Fallback: System fonts (-apple-system, BlinkMacSystemFont, Segoe UI)

**Font Sizes**:
```css
--font-size-xs: 11px    (Small labels)
--font-size-sm: 13px    (Secondary text)
--font-size-base: 15px  (Body text)
--font-size-lg: 18px    (Subheadings)
--font-size-xl: 22px
--font-size-2xl: 28px
--font-size-3xl: 34px   (Page titles)
--font-size-4xl: 42px   (Large headings)
```

**Font Weights**:
```css
--font-weight-light: 300
--font-weight-normal: 400
--font-weight-medium: 500      (Labels)
--font-weight-semibold: 600    (Buttons, headings)
--font-weight-bold: 700
```

### Spacing Scale

Consistent spacing using 4px base unit:
```css
--space-xs: 4px
--space-sm: 8px
--space-md: 14px
--space-lg: 20px
--space-xl: 28px
--space-2xl: 40px
--space-3xl: 64px
```

### Border Radius

```css
--radius-sm: 8px     (Small elements)
--radius-md: 12px    (Buttons, inputs)
--radius-lg: 16px    (Cards)
--radius-xl: 20px    (Large cards)
--radius-full: 9999px (Circular elements)
```

### Shadows & Elevation

```css
--shadow-subtle: 0 6px 20px rgba(0, 0, 0, 0.18)
--shadow-soft: 0 12px 40px rgba(0, 0, 0, 0.22)
--shadow-medium: 0 18px 60px rgba(0, 0, 0, 0.28)
--shadow-elevated: 0 24px 80px rgba(0, 0, 0, 0.32)  (Cards)
--shadow-focus: 0 0 0 3px rgba(122, 168, 255, 0.35)  (Focus ring)
```

### Transitions

```css
--transition-fast: 140ms ease    (Hover states)
--transition-base: 240ms ease    (Standard transitions)
--transition-slow: 360ms ease    (Complex animations)
```

### Layout

#### **Dashboard Grid**
```css
.dashboard-container {
  display: grid;
  grid-template-columns: 280px 1fr 320px;
  /* Left Sidebar | Main Content | Right Sidebar */
  gap: var(--space-xl);
  padding: var(--space-xl);
  min-height: 100vh;
}
```

#### **Responsive Breakpoints** (optimized for desktop)
- Primary target: 1440px - 1920px
- Minimum: 1280px
- Maximum: 2560px

### Button Styles

#### **Primary Button**
- Gradient background: Blue to Green
- Bold text with letter-spacing
- Elevated shadow with glow effect
- Hover: Slight lift + brightness increase

#### **Secondary Button**
- Transparent with border
- Hover: Border color changes to accent

#### **Action Buttons** (Edit, Delete, Save, Cancel)
- Small, compact
- Icon-friendly
- Color-coded by action type

### Form Elements

**Inputs & Selects**:
- Transparent background with subtle tint
- 1px border
- Rounded corners (12px)
- Focus: Accent border + glow effect
- Padding: 8px 14px

### Card Components

**Standard Card**:
- Background: `var(--color-surface)`
- Border: 1px solid border color
- Border radius: 16px-20px
- Shadow: Elevated
- Backdrop filter: Blur effect (glassmorphism)

### Animations

**Fade In**:
```css
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}
```

**Slide Up**:
```css
@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

**Loading Spinner**:
- Rotating circular element
- Accent color gradient
- Smooth continuous rotation

### Custom Scrollbar

```css
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-thumb {
  background: var(--color-border);
  border-radius: 9999px;
}

::-webkit-scrollbar-thumb:hover {
  background: var(--color-text-tertiary);
}
```

---

## How Everything Works Together

### Data Flow Diagram

```
┌──────────────┐
│   Browser    │
│  (User UI)   │
└──────┬───────┘
       │ User actions (click, type, submit)
       ▼
┌──────────────────────────────────────────┐
│        React Components                  │
│  ┌────────────────────────────────────┐ │
│  │ Login.jsx / Register.jsx /         │ │
│  │ Dashboard.jsx                       │ │
│  └────────────────────────────────────┘ │
│         │                                 │
│         │ State updates (useState)        │
│         │ Side effects (useEffect)        │
│         │ Memoized calculations (useMemo) │
│         │                                 │
│         ▼                                 │
│  ┌────────────────────────────────────┐ │
│  │ Event Handlers                     │ │
│  │ - handleSubmit                     │ │
│  │ - handleEdit                       │ │
│  │ - handleDelete                     │ │
│  └────────────────────────────────────┘ │
└──────────────┬───────────────────────────┘
               │
               │ Supabase API calls
               ▼
┌──────────────────────────────────────────┐
│     Supabase JavaScript Client           │
│  src/utils/supabase.js                   │
│  ┌────────────────────────────────────┐ │
│  │ - .from('users').select()          │ │
│  │ - .from('expenses').insert()       │ │
│  │ - .from('expenses').update()       │ │
│  │ - .from('expenses').delete()       │ │
│  │ - .from('budgets').upsert()        │ │
│  └────────────────────────────────────┘ │
└──────────────┬───────────────────────────┘
               │
               │ HTTPS REST API
               ▼
┌──────────────────────────────────────────┐
│         Supabase Cloud                   │
│  ┌────────────────────────────────────┐ │
│  │      PostgreSQL Database           │ │
│  │  ┌──────┐  ┌─────────┐  ┌────────┐│ │
│  │  │users │  │expenses │  │budgets ││ │
│  │  └──────┘  └─────────┘  └────────┘│ │
│  └────────────────────────────────────┘ │
│  ┌────────────────────────────────────┐ │
│  │   Auto-generated REST API          │ │
│  │   (POST, GET, PATCH, DELETE)       │ │
│  └────────────────────────────────────┘ │
└──────────────┬───────────────────────────┘
               │
               │ Response (JSON)
               ▼
┌──────────────────────────────────────────┐
│    React State Updates                   │
│  - setExpenses(data)                     │
│  - setBudgets(data)                      │
│  - setLoading(false)                     │
│  - setError(message)                     │
└──────────────┬───────────────────────────┘
               │
               │ Re-render
               ▼
┌──────────────────────────────────────────┐
│         Updated UI                       │
│  - Tables refresh                        │
│  - Totals recalculate                    │
│  - Charts update                         │
│  - Messages display                      │
└──────────────────────────────────────────┘
```

### Request/Response Lifecycle

#### **Example: Adding an Expense**

**1. User Action**:
```
User fills form and clicks "Add Transaction"
```

**2. Event Handler**:
```javascript
handleSubmit(e) {
  e.preventDefault()
  // Validate form
  // Call Supabase
}
```

**3. Supabase Client Call**:
```javascript
const { data, error } = await supabase
  .from('expenses')
  .insert([{ user_id, title, amount, category, type, date }])
  .select()
```

**4. HTTP Request**:
```
POST https://yaghrlecgtiydlvsqxjg.supabase.co/rest/v1/expenses
Headers:
  - apikey: [anon key]
  - Content-Type: application/json
Body:
  {
    "user_id": "uuid",
    "title": "Grocery Shopping",
    "amount": 1234.56,
    "category": "Food",
    "type": "expense",
    "date": "2026-01-30"
  }
```

**5. Database Operation**:
```sql
INSERT INTO expenses (id, user_id, title, amount, category, type, date, created_at, updated_at)
VALUES (gen_random_uuid(), 'uuid', 'Grocery Shopping', 1234.56, 'Food', 'expense', '2026-01-30', NOW(), NOW())
RETURNING *;
```

**6. HTTP Response**:
```json
{
  "id": "new-uuid",
  "user_id": "user-uuid",
  "title": "Grocery Shopping",
  "amount": 1234.56,
  "category": "Food",
  "type": "expense",
  "date": "2026-01-30",
  "created_at": "2026-01-30T10:15:30Z",
  "updated_at": "2026-01-30T10:15:30Z"
}
```

**7. React State Update**:
```javascript
// Reset form
setFormData({
  title: '',
  amount: '',
  category: 'Food',
  type: 'expense',
  date: new Date().toISOString().split('T')[0]
})

// Refresh data
fetchExpenses()
```

**8. Fetch Updated List**:
```javascript
const { data, error } = await supabase
  .from('expenses')
  .select('*')
  .eq('user_id', user.id)
  .order('date', { ascending: false })

setExpenses(data)
```

**9. React Re-render**:
```
- Table shows new transaction
- Total Expense increases
- Balance updates
- Category breakdown updates
- Budget progress updates (if applicable)
```

### State Management Pattern

**Centralized State** (in Dashboard component):
```javascript
// Core data
const [expenses, setExpenses] = useState([])
const [budgets, setBudgets] = useState([])

// UI state
const [loading, setLoading] = useState(true)
const [error, setError] = useState('')

// Form state
const [formData, setFormData] = useState({...})
const [editingId, setEditingId] = useState(null)

// Filter state
const [searchQuery, setSearchQuery] = useState('')
const [selectedCategories, setSelectedCategories] = useState([])
const [sortField, setSortField] = useState('date')
const [sortOrder, setSortOrder] = useState('desc')
```

**Derived State** (calculated from base state):
```javascript
// Never stored in state, always calculated
const totalIncome = useMemo(...)
const totalExpense = useMemo(...)
const balance = useMemo(...)
const categoryBreakdown = useMemo(...)
const filteredAndSortedExpenses = useMemo(...)
```

**Props Down, Events Up**:
- State lives in parent component (Dashboard)
- Child components receive data via props
- Child components call parent handlers via callbacks
- No prop drilling - all state in one place

### Performance Optimizations

**1. Memoization**:
```javascript
useMemo(() => {
  // Expensive calculations
  // Only runs when dependencies change
}, [dependencies])
```

**2. Callback Memoization**:
```javascript
useCallback(() => {
  // Function reference stays same across renders
  // Prevents unnecessary child re-renders
}, [dependencies])
```

**3. Database Indexes**:
- `idx_expenses_user_id` - Fast user filtering
- `idx_expenses_date` - Fast sorting
- `idx_expenses_user_date` - Composite queries

**4. Efficient Queries**:
```javascript
// Only fetch current user's data
.eq('user_id', user.id)

// Pre-sort at database level
.order('date', { ascending: false })

// Select only needed columns (when appropriate)
.select('id, title, amount')
```

**5. Conditional Rendering**:
```javascript
{loading ? <LoadingSpinner /> : <DataTable />}
{expenses.length === 0 ? <EmptyState /> : <Table />}
```

### Error Handling Strategy

**1. Form Validation** (Client-Side):
```javascript
if (!formData.title || !formData.amount) {
  setError('Please fill all fields')
  return
}

if (parseFloat(formData.amount) <= 0) {
  setError('Amount must be greater than 0')
  return
}
```

**2. Database Errors** (Server-Side):
```javascript
try {
  const { data, error } = await supabase.from('expenses').insert([...])
  if (error) throw error
} catch (err) {
  setError(err.message || 'Failed to add expense')
}
```

**3. Network Errors**:
```javascript
try {
  // Fetch data
} catch (err) {
  console.error('Error fetching expenses:', err)
  setLoading(false)
  // Show error banner or retry option
}
```

**4. User-Friendly Messages**:
- "All fields are required"
- "Amount must be greater than 0"
- "Invalid email or password"
- "Email already exists"
- "Failed to add expense"

### Real-Time Updates

**Current Implementation**: Manual refresh after operations
```javascript
// After insert/update/delete
fetchExpenses()
```

**How It Works**:
1. User performs action (add/edit/delete)
2. Database updated via API
3. `fetchExpenses()` called
4. New query fetches all user's expenses
5. `setExpenses(data)` triggers re-render
6. All derived calculations update via `useMemo`

**Not Implemented** (Future Enhancement):
- Supabase Realtime subscriptions
- WebSocket connections
- Automatic updates when other devices make changes

### Complete System Integration

**Bringing It All Together**:

1. **User visits app**
   - Vite serves React SPA
   - `index.html` → `main.jsx` → `App.jsx`

2. **Routing kicks in**
   - React Router checks URL
   - Protected routes check authentication

3. **Authentication flow**
   - Login/Register components interact with Supabase
   - Success: User saved to localStorage
   - Dashboard loads

4. **Data fetching**
   - `useEffect` triggers on mount
   - Supabase queries fetch user's data
   - State updates with results

5. **UI rendering**
   - React renders components based on state
   - Calculations performed via `useMemo`
   - Styles applied from CSS files

6. **User interactions**
   - Event handlers respond to clicks/inputs
   - State updates trigger re-renders
   - Database operations via Supabase

7. **Real-time feedback**
   - Loading states during async operations
   - Error messages for failures
   - Success indicators for completions
   - Immediate UI updates after database changes

8. **Session persistence**
   - localStorage maintains session
   - Page refreshes don't require re-login
   - Logout clears session

This creates a seamless, responsive user experience where all parts of the system work in harmony to provide a functional expense tracking application.

---

## Summary

The Expense Tracker is a **full-stack Single Page Application** that demonstrates:

✅ **React Fundamentals**: Components, hooks, state management, lifecycle
✅ **Routing**: SPA navigation with protected routes
✅ **Database Integration**: Supabase (PostgreSQL) with CRUD operations
✅ **Authentication**: Custom login/register with session persistence
✅ **Real-time Calculations**: Dynamic totals, breakdowns, and budgets
✅ **Search & Filter**: Complex data filtering with multiple criteria
✅ **Modern UI**: Dark theme with glassmorphism, animations, and responsive design
✅ **Code Quality**: Clean architecture, memoization, error handling

**Tech Stack**: React 19 + Vite 7 + React Router 7 + Supabase + Pure CSS

**Educational Value**: Perfect for learning React, database integration, and building complete web applications from scratch.

---

**Project Status**: ✅ Complete and Functional
**Last Updated**: January 30, 2026
