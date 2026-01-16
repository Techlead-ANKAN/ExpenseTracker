# Expense Tracker – System Design & Workflows

This document explains every important part of the Expense Tracker app so you can confidently describe it in an interview. It covers architecture, data model, key features, and the detailed step‑by‑step flows for each operation.

---

## 1. High‑Level Overview

- **Stack**: React + Vite frontend, Supabase (PostgreSQL + REST) backend.
- **Main features**:
  - User registration and login.
  - Session persistence with localStorage.
  - Protected dashboard route.
  - Add / edit / delete income and expense transactions.
  - Search, filter, and sort transactions.
  - Monthly category budgets with progress bars.
  - Category‑wise expense breakdown.
  - Derived metrics: total income, total expenses, and current balance.
- **Design**: Modern, glassmorphism‑inspired dark UI optimized for laptop‑sized screens.

The React app is bootstrapped by Vite and rendered in `main.jsx`, which mounts the `App` component:
- `main.jsx` imports global styles (`index.css`) and the main `App`.
- `App.jsx` configures React Router and a `ProtectedRoute` that only allows authenticated users to access `/dashboard`.

---

## 2. Data Model & Backend (Supabase)

Supabase provides a hosted Postgres database plus a JavaScript client for CRUD operations. A single client is created and reused across the app.

### 2.1 Supabase Client

File: `src/utils/supabase.js`

- Uses `@supabase/supabase-js`:
  - `const supabase = createClient(supabaseUrl, supabaseAnonKey)`.
- The `supabase` instance is imported in pages (Login, Register, Dashboard) to query tables.

### 2.2 Tables

**Users table** (used in Login/Register):
- Columns that the app relies on:
  - `id` (UUID primary key).
  - `name` (text): full name.
  - `email` (text): unique user email.
  - `password` (text): stored as plain text in this learning project.
- Purpose: store application users and credentials.

**Expenses table** (used in Dashboard):
- Columns the code uses:
  - `id` (primary key).
  - `user_id` (foreign key to users.id).
  - `title` (text): description of the transaction.
  - `amount` (numeric): transaction amount.
  - `category` (text): one of predefined categories.
  - `type` (text): `'income'` or `'expense'`.
  - `date` (date or timestamp): when the transaction occurred.

**Budgets table** (full DDL in [docs/budgets_table_setup.sql](../budgets_table_setup.sql)):
- Important columns:
  - `id` UUID primary key (`DEFAULT gen_random_uuid()`).
  - `user_id` UUID (FK to users.id, `ON DELETE CASCADE`).
  - `category` (text, constrained to same list of categories as expenses).
  - `monthly_limit` (numeric, `> 0`).
  - `created_at`, `updated_at` timestamps.
  - Unique constraint on `(user_id, category)` to guarantee one budget per category per user.
- Indexes are added on `user_id`, `category`, and `(user_id, category)` for performance.
- RLS (Row Level Security) is enabled with simple policies so users only see and modify their own budgets.

---

## 3. Frontend Architecture

### 3.1 Entry Point & Routing

**File: src/main.jsx**
- Wraps the app in `StrictMode` and renders `<App />` into the `root` element.

**File: src/App.jsx**
- Imports `BrowserRouter`, `Routes`, and `Route` from `react-router-dom`.
- Defines a `ProtectedRoute` component that checks `isAuthenticated()` (from `utils/auth.js`).
  - If authenticated, it renders its `children`.
  - Otherwise, it redirects to `/login` with `<Navigate to="/login" replace />`.
- Routes:
  - `/login` → `Login` page.
  - `/register` → `Register` page.
  - `/dashboard` → wrapped in `ProtectedRoute` and renders `Dashboard`.
  - `/` and `*` both redirect to `/dashboard`.

### 3.2 Auth Utilities

**File: src/utils/auth.js**

Implements simple client‑side auth using `localStorage`:
- `setUser(user)` – stores user object as JSON under the key `user`.
- `getUser()` – reads and parses user from `localStorage`, or returns `null`.
- `logout()` – removes the `user` key.
- `isAuthenticated()` – returns `true` if `getUser()` is not `null`.

In interviews you can mention:
- This is not production‑grade auth; it’s a minimal session mechanism for a learning project.
- It’s enough to gate the React routes but not secure against malicious users.

---

## 4. Authentication Workflows

### 4.1 Registration Flow (Create Account)

**File: src/pages/Register.jsx**

**State**
- `formData`: `{ name, email, password, confirmPassword }`.
- `error`: string, used to display validation or server errors.
- `loading`: boolean to disable the button during async operations.

**User workflow**
1. User opens `/register`.
2. Fills in name, email, password, confirm password.
3. Clicks **Register**.

**Validation logic**
1. Checks that all four fields are filled.
2. Ensures password and confirm password match.
3. Ensures password length is at least 6 characters.
4. If any validation fails, `setError(...)` is called and the request is not sent.

**Backend interaction**
1. Sets `loading = true`.
2. Uses Supabase to check if the email already exists:
   ```js
   const { data: existingUser } = await supabase
     .from('users')
     .select('id')
     .eq('email', formData.email)
     .single()
   ```
3. If `existingUser` is found, shows `Email already exists` and stops.
4. Otherwise inserts a new record into `users`:
   ```js
   const { data, error: insertError } = await supabase
     .from('users')
     .insert([{ name, email, password }])
     .select()
     .single()
   ```
5. On success, it **does not** automatically log the user in. Instead:
   - Shows an alert: `Registration successful! Please login.`
   - Navigates to `/login` using `useNavigate()`.
6. In all cases, `loading` is reset to false in a `finally` block.

**How to describe in an interview**
> “Registration is a simple Supabase insert with pre‑validations for required fields, password confirmation, and uniqueness of email. I perform a pre‑check on the `users` table and then insert a new record, handling errors and updating the UI accordingly.”

### 4.2 Login Flow

**File: src/pages/Login.jsx**

**State**
- `formData`: `{ email, password }`.
- `error`: string.
- `loading`: boolean.

**User workflow**
1. User opens `/login`.
2. Enters email and password.
3. Clicks **Login**.

**Validation logic**
1. Checks that email and password are both filled.
2. If not, sets `error = 'All fields are required'`.

**Backend interaction**
1. Sets `loading = true`.
2. Queries Supabase `users` table by email:
   ```js
   const { data: user, error: fetchError } = await supabase
     .from('users')
     .select('*')
     .eq('email', formData.email)
     .single()
   ```
3. If error or no user is found, returns `Invalid email or password`.
4. Compares **plain text** passwords:
   - If mismatch → same `Invalid email or password` message.
5. If credentials are valid:
   - Creates a user object `{ id, name, email }`.
   - Saves it via `setUser(userToStore)` (localStorage).
   - Redirects to `/dashboard`.
6. Finally, resets loading.

**Interview phrasing**
> “Login is implemented as a lookup on the `users` table and a plain text password comparison for demo purposes. On success, I persist a trimmed user object in localStorage and rely on `isAuthenticated()` to guard the dashboard route.”

### 4.3 Logout Flow

**Where**: Logout button in the left sidebar of the `Dashboard`.

**Steps**
1. On click, `handleLogout` runs:
   - Calls `logout()` from `auth.js` (removes user from localStorage).
   - Uses `navigate('/login')` to redirect to the login page.
2. Because localStorage is cleared, `ProtectedRoute` will deny access to `/dashboard` on future attempts.

---

## 5. Dashboard Architecture & State

**File: src/pages/Dashboard.jsx**

### 5.1 High‑Level Layout & Sections

The dashboard is laid out as a 3‑column grid (left sidebar, main content, right sidebar):
- **Left sidebar**: user profile, avatar, email, and quick stats (total income, total expense, balance) plus a Logout button.
- **Center panel**:
  - Header (title + subtitle).
  - Add Transaction form.
  - Search & Filter section (search bar + category chips + sort dropdown).
  - Transactions table with inline editing.
- **Right sidebar**:
  - Monthly Budgets card with a button to add/upsert budgets and visual progress bars.
  - Category Breakdown card listing total expenses per category and overall total.

### 5.2 Core React State

- `expenses` – array of all loaded transactions for the current user.
- `budgets` – array of user’s budgets.
- `loading` – boolean flag for loading state of transactions.
- `error` – string for displaying errors in the Add Transaction form.

**Form state**
- `formData` for new transactions: `{ title, amount, category, type, date }`.

**Editing state**
- `editingId` – ID of the row currently being edited, or `null`.
- `editFormData` – edited fields for the selected transaction.

**Search & filter state**
- `searchQuery` – free‑text query.
- `selectedCategories` – array of category strings.
- `sortField` – `'date' | 'amount' | 'title'`.
- `sortOrder` – `'asc' | 'desc'`.

**Static data**
- `categories` – fixed list of allowed categories:
  - `['Food', 'Travel', 'Rent', 'Shopping', 'Entertainment', 'Healthcare', 'Education', 'Utilities', 'Other']`.

### 5.3 Data Loading Lifecycle

1. On mount, the dashboard gets the current user from `getUser()`.
2. An effect checks if `user` is missing:
   - If no user, it redirects to `/login`.
3. Another effect runs if `user` is present:
   - Calls `fetchExpenses()` and `fetchBudgets()`.

**`fetchExpenses`**
- Uses `useCallback` with dependency on `user?.id`.
- Queries Supabase:
  ```js
  const { data, error } = await supabase
    .from('expenses')
    .select('*')
    .eq('user_id', user.id)
    .order('date', { ascending: false })
  ```
- On success, sets `expenses` and flips `loading` to false.

**`fetchBudgets`**
- Also memoized with `useCallback`.
- Query:
  ```js
  const { data, error } = await supabase
    .from('budgets')
    .select('*')
    .eq('user_id', user.id)
  ```
- On success, sets `budgets`.

---

## 6. Transaction Workflows

### 6.1 Add New Transaction

**User steps**
1. User fills **Title**, **Amount**, **Category**, **Type** (income or expense), and **Date**.
2. Clicks **Add Transaction**.

**Validation**
- All fields must be filled: `title`, `amount`, `date`.
- `amount` must be a positive number.
- If invalid → show error banner above form (`setError(...)`).

**Supabase insert**
- On valid form:
  ```js
  const { error: insertError } = await supabase
    .from('expenses')
    .insert([{
      user_id: user.id,
      title: formData.title,
      amount: parseFloat(formData.amount),
      category: formData.category,
      type: formData.type,
      date: formData.date,
    }])
    .select()
  ```
- On success:
  - Resets `formData` back to defaults (type = `expense`, category = `Food`, date = today).
  - Calls `fetchExpenses()` to refresh the list and dependent calculations.

### 6.2 Edit Existing Transaction (Inline)

**User steps**
1. In the Transactions table, user clicks **Edit** on a row.
2. Row switches to edit mode:
   - Regular cells are replaced with input fields (text, number, date, select for category/type).
3. User changes one or more values.
4. User clicks **Save** or **Cancel**.

**State transitions**
- `handleEdit(expense)` sets:
  - `editingId = expense.id`.
  - `editFormData` populated with the current expense fields.
- While `editingId === expense.id`, the row renders inputs instead of plain text.

**Update flow (Save)**
1. On Save, `handleUpdate(id)` runs:
   ```js
   const { error } = await supabase
     .from('expenses')
     .update({
       title: editFormData.title,
       amount: parseFloat(editFormData.amount),
       category: editFormData.category,
       type: editFormData.type,
       date: editFormData.date,
     })
     .eq('id', id)
   ```
2. On success:
   - Clears `editingId` and `editFormData`.
   - Calls `fetchExpenses()` to pull updated data.
3. On error:
   - Shows an alert with the error message.

**Cancel flow**
- `handleCancelEdit()` simply resets `editingId` and `editFormData` without calling Supabase.

### 6.3 Delete Transaction

**User steps**
1. User clicks **Delete** on a row.
2. A `confirm()` dialog asks for confirmation.
3. If confirmed, deletion proceeds; otherwise it is cancelled.

**Supabase delete**
```js
const { error } = await supabase
  .from('expenses')
  .delete()
  .eq('id', id)
```

On success, `fetchExpenses()` is called to refresh the list.

---

## 7. Search, Filter, and Sort Workflows

The dashboard uses `useMemo` to derive a filtered and sorted array of expenses, so UI can be responsive even with more data.

### 7.1 Search

- Controlled input `searchQuery`.
- The `filteredAndSortedExpenses` memo applies a text filter:
  - Matches if the search string is found in:
    - `title.toLowerCase()`
    - `category.toLowerCase()`
    - `amount.toString()`
- This allows search by title, category, or numeric amount.

### 7.2 Category Filters (Chips)

- `selectedCategories` array keeps track of active chips.
- `handleCategoryToggle(category)`:
  - If category is already active → removes it.
  - Else → adds it.
- In the memo, if `selectedCategories` is non‑empty, only expenses whose `category` is in that array pass the filter.

### 7.3 Sorting

- Controlled dropdown value `value={`${sortField}-${sortOrder}`}`.
- Options:
  - Date (Newest First / Oldest First).
  - Amount (High to Low / Low to High).
  - Title (A–Z / Z–A).
- On change, the dropdown splits value into `[field, order]` and updates `sortField` and `sortOrder`.
- Sorting logic in the memo:
  - For `date`, converts `a.date` and `b.date` to `Date` objects.
  - For `amount`, uses `parseFloat`.
  - For `title`, compares lowercase strings.
  - Uses standard `asc` / `desc` comparison.

### 7.4 Clear Filters

- If `searchQuery` is non‑empty or categories are selected, a **Clear Filters** button appears.
- `clearFilters()` resets `searchQuery` to `''` and `selectedCategories` to `[]`.

### 7.5 Loading & Empty States

- While fetching expenses, the `loading` flag shows a **Loading transactions…** view with a spinner.
- If there are no filtered expenses, an empty state card invites the user to add their first transaction.

---

## 8. Derived Metrics & Calculations

All metrics are computed using `useMemo` to avoid unnecessary recomputation.

### 8.1 Totals

- **Total Income**:
  ```js
  const totalIncome = useMemo(() =>
    filteredAndSortedExpenses
      .filter(e => e.type === 'income')
      .reduce((sum, e) => sum + parseFloat(e.amount), 0),
    [filteredAndSortedExpenses]
  )
  ```
- **Total Expense**:
  Similar, but filters `type === 'expense'`.
- **Balance**:
  ```js
  const balance = useMemo(() => totalIncome - totalExpense, [totalIncome, totalExpense])
  ```

### 8.2 Category Breakdown

- For expenses only:
  ```js
  const categoryBreakdown = useMemo(() =>
    filteredAndSortedExpenses
      .filter(e => e.type === 'expense')
      .reduce((acc, e) => {
        acc[e.category] = (acc[e.category] || 0) + parseFloat(e.amount)
        return acc
      }, {}),
    [filteredAndSortedExpenses]
  )
  ```
- Displayed on the right sidebar in descending order of amount, with a final "Total Expenses" row.

---

## 9. Budgets Module & Workflow

### 9.1 Data Model Recap

- Each budget row links a `user_id` and `category` to a `monthly_limit` amount.
- Unique `(user_id, category)` ensures there’s at most one limit per category per user.

### 9.2 Adding or Updating a Budget

Budget operations are handled by `handleAddBudget(category, limit)` in the Dashboard.

**User interaction**
1. User clicks the **+ Add** button in the Monthly Budgets card.
2. Two `prompt()` dialogs ask for:
   - Category (default `'Food'`).
   - Limit in ₹ (must be a positive number).
3. If both are provided and the limit is valid, it calls `handleAddBudget`.

**Supabase upsert**
```js
const { error } = await supabase
  .from('budgets')
  .upsert([{ user_id: user.id, category, monthly_limit: parseFloat(limit) }])
```

- `upsert` automatically **inserts or updates** depending on whether a row exists for that `(user_id, category)`.
- After success, `fetchBudgets()` refreshes the budgets list.

### 9.3 Deleting a Budget

There is a `handleDeleteBudget(id)` function that:
- Calls Supabase `.delete().eq('id', id)` on the budgets table.
- Refreshes budgets via `fetchBudgets()`.

(At the moment, there is no UI button wired to this handler in the provided code, but it is ready for use.)

### 9.4 Calculating Budget Progress

Two helper functions:

1. `getCurrentMonthSpending(category)`:
   - Gets the first and last day of the current month.
   - Filters `expenses` to only this category, type `'expense'`, and date within the current month.
   - Sums the amounts.

2. `getBudgetProgress(category, limit)`:
   - Calls `getCurrentMonthSpending(category)`.
   - Computes `percentage = (spent / limit) * 100`.
   - Returns `{ spent, percentage }`.

Each budget card uses this information to:
- Render a progress bar whose width is `min(percentage, 100)`.
- Assign a status class:
  - `< 70%` → `safe`.
  - `70–90%` → `warning`.
  - `> 90%` → `danger`.

These classes drive the color of the bar and percentage text.

---

## 10. UI & Styling Overview

The visual design is implemented in two main CSS files:
- `src/index.css` – global resets, CSS variables, typography, and animations.
- `src/App.css` – page layout, component styling (cards, tables, inputs, buttons), and responsiveness.

### 10.1 Theme

- Dark background (`--color-background`, `--color-background-alt`).
- Semi‑transparent surfaces with blur for a “glass panel” effect.
- Accent colors in the blue/green spectrum for primary actions and highlights.
- Semantic colors for success (green), danger (red), and warning (amber).

### 10.2 Layout

- Desktop layout: 3‑column CSS grid with sticky sidebars.
- The grid uses full viewport width with generous internal padding.
- Media queries collapse to 2‑column and then 1‑column layouts on smaller screens.

### 10.3 Components

- **Auth card**: centered panel with subtle glow and gradient background.
- **Buttons**: gradient primary action button with hover elevation; secondary and utility buttons with outline/glass effect.
- **Tables**: alternating row backgrounds, hover highlighting, and inline edit inputs.
- **Progress bars**: rounded, color‑coded based on budget usage.

---

## 11. How to Explain the Project in an Interview

You can summarize the project in a structured way:

1. **One‑liner**  
   “I built a full‑stack expense tracker using React and Supabase that lets users register, log in, track income and expenses, set monthly category budgets, and visualize their spending with filters and budgets.”

2. **Architecture**  
   “The frontend is a React/Vite SPA with React Router and a localStorage‑based auth helper. The backend is Supabase (Postgres + auto‑generated APIs). I created tables for users, expenses, and budgets, and interact with them via the Supabase JavaScript client.”

3. **Key flows**  
   - Registration inserts into `users` after validation and email uniqueness check.  
   - Login fetches the user by email, compares passwords, and stores a stripped‑down user object in localStorage.  
   - The dashboard is a protected route that reads the user from storage, fetches their expenses and budgets, and drives all views from that state.  
   - Adding/editing/deleting expenses is done via Supabase CRUD operations, and I recompute totals and breakdowns from the latest data.

4. **Interesting details**  
   - I use `useMemo` and `useCallback` to keep search/filter/sort and calculations efficient.  
   - Budgets are implemented with an upsert pattern and a `(user_id, category)` uniqueness constraint, which simplifies the API.  
   - UI is responsive and uses a modern glassmorphism dark theme to make the data visually appealing and interview‑ready.

5. **Limitations & possible improvements**  
   - Currently passwords are stored in plain text and auth is client‑side only; in a production setting I’d use Supabase Auth or another provider with hashed passwords and secure tokens.  
   - Prompts are used for adding budgets; this could be replaced with a dedicated modal form.  
   - Additional charts (e.g., line charts or pie charts) could further enhance insights.

---

This document should give you enough detail to confidently answer most interview questions about how the app is structured and how each feature works end‑to‑end.
