import { useState, useEffect, useMemo, useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../utils/supabase'
import { getUser, logout } from '../utils/auth'

const Dashboard = () => {
  const navigate = useNavigate()
  const user = getUser()
  
  // === STATE MANAGEMENT ===
  const [expenses, setExpenses] = useState([])
  const [budgets, setBudgets] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  
  // Transaction form state
  const [formData, setFormData] = useState({
    title: '',
    amount: '',
    category: 'Food',
    type: 'expense',
    date: new Date().toISOString().split('T')[0]
  })
  
  // Edit transaction state
  const [editingId, setEditingId] = useState(null)
  const [editFormData, setEditFormData] = useState({})
  
  // Search & Filter state
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedCategories, setSelectedCategories] = useState([])
  const [sortField, setSortField] = useState('date')
  const [sortOrder, setSortOrder] = useState('desc')

  // Categories list
  const categories = ['Food', 'Travel', 'Rent', 'Shopping', 'Entertainment', 'Healthcare', 'Education', 'Utilities', 'Other']

  // === LIFECYCLE & DATA FETCHING ===
  
  // Redirect if not authenticated
  useEffect(() => {
    if (!user) {
      navigate('/login')
    }
  }, [user, navigate])

  // Fetch data on mount
  useEffect(() => {
    if (user) {
      fetchExpenses()
      fetchBudgets()
    }
  }, [user])

  const fetchExpenses = useCallback(async () => {
    try {
      const { data, error } = await supabase
        .from('expenses')
        .select('*')
        .eq('user_id', user.id)
        .order('date', { ascending: false })

      if (error) throw error
      setExpenses(data || [])
      setLoading(false)
    } catch (err) {
      console.error('Error fetching expenses:', err)
      setLoading(false)
    }
  }, [user?.id])

  const fetchBudgets = useCallback(async () => {
    try {
      const { data, error } = await supabase
        .from('budgets')
        .select('*')
        .eq('user_id', user.id)

      if (error) throw error
      setBudgets(data || [])
    } catch (err) {
      console.error('Error fetching budgets:', err)
    }
  }, [user?.id])

  // === FORM HANDLERS ===
  
  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    })
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')

    // Validation
    if (!formData.title || !formData.amount || !formData.date) {
      setError('Please fill all fields')
      return
    }

    if (parseFloat(formData.amount) <= 0) {
      setError('Amount must be greater than 0')
      return
    }

    try {
      const { error: insertError } = await supabase
        .from('expenses')
        .insert([
          {
            user_id: user.id,
            title: formData.title,
            amount: parseFloat(formData.amount),
            category: formData.category,
            type: formData.type,
            date: formData.date
          }
        ])
        .select()

      if (insertError) throw insertError

      // Reset form
      setFormData({
        title: '',
        amount: '',
        category: 'Food',
        type: 'expense',
        date: new Date().toISOString().split('T')[0]
      })

      // Refresh expenses list
      fetchExpenses()
    } catch (err) {
      setError(err.message || 'Failed to add expense')
    }
  }

  // === EDIT HANDLERS ===
  
  const handleEdit = (expense) => {
    setEditingId(expense.id)
    setEditFormData({
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      type: expense.type,
      date: expense.date
    })
  }

  const handleEditChange = (field, value) => {
    setEditFormData({
      ...editFormData,
      [field]: value
    })
  }

  const handleUpdate = async (id) => {
    try {
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

      if (error) throw error

      setEditingId(null)
      setEditFormData({})
      fetchExpenses()
    } catch (err) {
      alert('Failed to update expense: ' + err.message)
    }
  }

  const handleCancelEdit = () => {
    setEditingId(null)
    setEditFormData({})
  }

  const handleDelete = useCallback(async (id) => {
    if (!confirm('Are you sure you want to delete this expense?')) return

    try {
      const { error } = await supabase
        .from('expenses')
        .delete()
        .eq('id', id)

      if (error) throw error
      fetchExpenses()
    } catch (err) {
      alert('Failed to delete expense: ' + err.message)
    }
  }, [fetchExpenses])

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  // === SEARCH & FILTER LOGIC ===
  
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
      let aVal, bVal

      switch (sortField) {
        case 'date':
          aVal = new Date(a.date)
          bVal = new Date(b.date)
          break
        case 'amount':
          aVal = parseFloat(a.amount)
          bVal = parseFloat(b.amount)
          break
        case 'title':
          aVal = a.title.toLowerCase()
          bVal = b.title.toLowerCase()
          break
        default:
          return 0
      }

      if (sortOrder === 'asc') {
        return aVal > bVal ? 1 : -1
      } else {
        return aVal < bVal ? 1 : -1
      }
    })

    return filtered
  }, [expenses, searchQuery, selectedCategories, sortField, sortOrder])

  const handleCategoryToggle = (category) => {
    setSelectedCategories(prev => 
      prev.includes(category)
        ? prev.filter(c => c !== category)
        : [...prev, category]
    )
  }

  const clearFilters = () => {
    setSearchQuery('')
    setSelectedCategories([])
  }

  // === BUDGET HANDLERS ===
  
  const handleAddBudget = async (category, limit) => {
    try {
      const { error } = await supabase
        .from('budgets')
        .upsert([
          {
            user_id: user.id,
            category: category,
            monthly_limit: parseFloat(limit)
          }
        ])

      if (error) throw error
      fetchBudgets()
    } catch (err) {
      alert('Failed to save budget: ' + err.message)
    }
  }

  const handleDeleteBudget = async (id) => {
    try {
      const { error } = await supabase
        .from('budgets')
        .delete()
        .eq('id', id)

      if (error) throw error
      fetchBudgets()
    } catch (err) {
      alert('Failed to delete budget: ' + err.message)
    }
  }

  // === CALCULATIONS ===
  
  const totalIncome = useMemo(() => {
    return filteredAndSortedExpenses
      .filter(e => e.type === 'income')
      .reduce((sum, e) => sum + parseFloat(e.amount), 0)
  }, [filteredAndSortedExpenses])

  const totalExpense = useMemo(() => {
    return filteredAndSortedExpenses
      .filter(e => e.type === 'expense')
      .reduce((sum, e) => sum + parseFloat(e.amount), 0)
  }, [filteredAndSortedExpenses])

  const balance = useMemo(() => {
    return totalIncome - totalExpense
  }, [totalIncome, totalExpense])

  const categoryBreakdown = useMemo(() => {
    return filteredAndSortedExpenses
      .filter(e => e.type === 'expense')
      .reduce((acc, e) => {
        acc[e.category] = (acc[e.category] || 0) + parseFloat(e.amount)
        return acc
      }, {})
  }, [filteredAndSortedExpenses])

  // Calculate current month spending for budget progress
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

  const getBudgetProgress = (category, limit) => {
    const spent = getCurrentMonthSpending(category)
    const percentage = (spent / limit) * 100
    return { spent, percentage }
  }

  // Get user initials for avatar
  const getUserInitials = () => {
    if (!user || !user.name) return '?'
    const names = user.name.split(' ')
    if (names.length >= 2) {
      return names[0][0] + names[1][0]
    }
    return names[0][0]
  }

  if (!user) return null

  return (
    <div className="dashboard-container">
      {/* LEFT SIDEBAR - User Profile & Quick Stats */}
      <aside className="dashboard-sidebar-left">
        <div className="user-profile-section">
          <div className="user-avatar">{getUserInitials()}</div>
          <h2 className="user-name">{user.name}</h2>
          <p className="user-email">{user.email}</p>
        </div>

        <div className="quick-stats">
          <div className="quick-stat-item income">
            <p className="quick-stat-label">Total Income</p>
            <p className="quick-stat-value">₹ {totalIncome.toLocaleString('en-IN')}</p>
          </div>
          
          <div className="quick-stat-item expense">
            <p className="quick-stat-label">Total Expense</p>
            <p className="quick-stat-value">₹ {totalExpense.toLocaleString('en-IN')}</p>
          </div>
          
          <div className="quick-stat-item">
            <p className="quick-stat-label">Balance</p>
            <p className="quick-stat-value" style={{ color: balance >= 0 ? 'var(--color-income)' : 'var(--color-expense)' }}>
              ₹ {balance.toLocaleString('en-IN')}
            </p>
          </div>
        </div>

        <div className="sidebar-logout">
          <button onClick={handleLogout} className="btn-logout">
            Logout
          </button>
        </div>
      </aside>

      {/* CENTER PANEL - Main Content */}
      <main className="dashboard-main">
        <div className="dashboard-header">
          <h1 className="dashboard-title">Expense Tracker</h1>
          <p className="dashboard-subtitle">Manage your finances with ease</p>
        </div>

        {/* Add Transaction Form */}
        <section className="add-transaction-section">
          <h3 className="section-title">Add New Transaction</h3>
          
          {error && <div className="error-message">{error}</div>}

          <form onSubmit={handleSubmit} className="transaction-form">
            <div className="form-group">
              <label htmlFor="title">Title</label>
              <input
                type="text"
                id="title"
                name="title"
                value={formData.title}
                onChange={handleChange}
                placeholder="e.g., Grocery Shopping"
              />
            </div>

            <div className="form-group">
              <label htmlFor="amount">Amount</label>
              <input
                type="number"
                id="amount"
                name="amount"
                value={formData.amount}
                onChange={handleChange}
                placeholder="0.00"
                step="0.01"
              />
            </div>

            <div className="form-group">
              <label htmlFor="category">Category</label>
              <select
                id="category"
                name="category"
                value={formData.category}
                onChange={handleChange}
              >
                {categories.map(cat => (
                  <option key={cat} value={cat}>{cat}</option>
                ))}
              </select>
            </div>

            <div className="form-group">
              <label htmlFor="type">Type</label>
              <select
                id="type"
                name="type"
                value={formData.type}
                onChange={handleChange}
              >
                <option value="expense">Expense</option>
                <option value="income">Income</option>
              </select>
            </div>

            <div className="form-group">
              <label htmlFor="date">Date</label>
              <input
                type="date"
                id="date"
                name="date"
                value={formData.date}
                onChange={handleChange}
              />
            </div>

            <div className="form-actions">
              <button type="submit" className="btn-primary">
                Add Transaction
              </button>
            </div>
          </form>
        </section>

        {/* Search & Filter Section */}
        <section className="search-filter-section">
          <h3 className="section-title">Search & Filter</h3>
          
          <div className="search-bar">
            <input
              type="text"
              className="search-input"
              placeholder="Search by title, category, or amount..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
            {(searchQuery || selectedCategories.length > 0) && (
              <button onClick={clearFilters} className="btn-secondary">
                Clear Filters
              </button>
            )}
          </div>

          <div className="filter-chips">
            {categories.map(cat => (
              <button
                key={cat}
                className={`filter-chip ${selectedCategories.includes(cat) ? 'active' : ''}`}
                onClick={() => handleCategoryToggle(cat)}
              >
                {cat}
              </button>
            ))}
          </div>

          <div className="filter-controls">
            <select
              className="sort-select"
              value={`${sortField}-${sortOrder}`}
              onChange={(e) => {
                const [field, order] = e.target.value.split('-')
                setSortField(field)
                setSortOrder(order)
              }}
            >
              <option value="date-desc">Date (Newest First)</option>
              <option value="date-asc">Date (Oldest First)</option>
              <option value="amount-desc">Amount (High to Low)</option>
              <option value="amount-asc">Amount (Low to High)</option>
              <option value="title-asc">Title (A-Z)</option>
              <option value="title-desc">Title (Z-A)</option>
            </select>
          </div>
        </section>

        {/* Transactions List */}
        <section className="transactions-section">
          <h3 className="section-title">
            Transaction History ({filteredAndSortedExpenses.length})
          </h3>

          {loading ? (
            <div className="loading-state">
              <div className="loading-spinner"></div>
              <p>Loading transactions...</p>
            </div>
          ) : filteredAndSortedExpenses.length === 0 ? (
            <div className="empty-state">
              <div className="empty-state-icon">📊</div>
              <p className="empty-state-text">No transactions found. Add your first transaction!</p>
            </div>
          ) : (
            <table className="transactions-table">
              <thead>
                <tr>
                  <th>Date</th>
                  <th>Title</th>
                  <th>Category</th>
                  <th>Type</th>
                  <th>Amount</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredAndSortedExpenses.map((expense) => (
                  <tr key={expense.id}>
                    <td>
                      {editingId === expense.id ? (
                        <input
                          type="date"
                          className="edit-input"
                          value={editFormData.date}
                          onChange={(e) => handleEditChange('date', e.target.value)}
                        />
                      ) : (
                        new Date(expense.date).toLocaleDateString('en-IN')
                      )}
                    </td>
                    <td>
                      {editingId === expense.id ? (
                        <input
                          type="text"
                          className="edit-input"
                          value={editFormData.title}
                          onChange={(e) => handleEditChange('title', e.target.value)}
                        />
                      ) : (
                        expense.title
                      )}
                    </td>
                    <td>
                      {editingId === expense.id ? (
                        <select
                          className="edit-input"
                          value={editFormData.category}
                          onChange={(e) => handleEditChange('category', e.target.value)}
                        >
                          {categories.map(cat => (
                            <option key={cat} value={cat}>{cat}</option>
                          ))}
                        </select>
                      ) : (
                        expense.category
                      )}
                    </td>
                    <td>
                      {editingId === expense.id ? (
                        <select
                          className="edit-input"
                          value={editFormData.type}
                          onChange={(e) => handleEditChange('type', e.target.value)}
                        >
                          <option value="expense">Expense</option>
                          <option value="income">Income</option>
                        </select>
                      ) : (
                        <span className={`transaction-type-badge ${expense.type}`}>
                          {expense.type}
                        </span>
                      )}
                    </td>
                    <td>
                      {editingId === expense.id ? (
                        <input
                          type="number"
                          className="edit-input"
                          value={editFormData.amount}
                          onChange={(e) => handleEditChange('amount', e.target.value)}
                          step="0.01"
                        />
                      ) : (
                        <span className={`transaction-amount ${expense.type}`}>
                          {expense.type === 'income' ? '+' : '-'} ₹ {parseFloat(expense.amount).toLocaleString('en-IN')}
                        </span>
                      )}
                    </td>
                    <td>
                      {editingId === expense.id ? (
                        <div className="edit-actions">
                          <button
                            onClick={() => handleUpdate(expense.id)}
                            className="btn-save"
                          >
                            Save
                          </button>
                          <button
                            onClick={handleCancelEdit}
                            className="btn-cancel"
                          >
                            Cancel
                          </button>
                        </div>
                      ) : (
                        <div className="transaction-actions">
                          <button
                            onClick={() => handleEdit(expense)}
                            className="btn-edit"
                          >
                            Edit
                          </button>
                          <button
                            onClick={() => handleDelete(expense.id)}
                            className="btn-delete"
                          >
                            Delete
                          </button>
                        </div>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </section>
      </main>

      {/* RIGHT SIDEBAR - Budgets & Category Breakdown */}
      <aside className="dashboard-sidebar-right">
        {/* Budget Section */}
        <section className="budget-section">
          <div className="section-header">
            <h3>Monthly Budgets</h3>
            <button
              className="btn-add-budget"
              onClick={() => {
                const category = prompt('Enter category:', 'Food')
                const limit = prompt('Enter monthly limit (₹):')
                if (category && limit && parseFloat(limit) > 0) {
                  handleAddBudget(category, limit)
                }
              }}
            >
              + Add
            </button>
          </div>

          {budgets.length === 0 ? (
            <p className="budget-empty">No budgets set. Click "+ Add" to create one.</p>
          ) : (
            <div className="budget-list">
              {budgets.map((budget) => {
                const { spent, percentage } = getBudgetProgress(budget.category, budget.monthly_limit)
                const statusClass = percentage < 70 ? 'safe' : percentage < 90 ? 'warning' : 'danger'
                
                return (
                  <div key={budget.id} className="budget-item">
                    <div className="budget-header">
                      <span className="budget-category">{budget.category}</span>
                      <span className="budget-limit">₹ {parseFloat(budget.monthly_limit).toLocaleString('en-IN')}</span>
                    </div>
                    <div className="budget-progress-bar">
                      <div
                        className={`budget-progress-fill ${statusClass}`}
                        style={{ width: `${Math.min(percentage, 100)}%` }}
                      ></div>
                    </div>
                    <div className="budget-status">
                      <span className="budget-spent">
                        Spent: ₹ {spent.toLocaleString('en-IN')}
                      </span>
                      <span className={`budget-percentage ${statusClass}`}>
                        {percentage.toFixed(1)}%
                      </span>
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </section>

        {/* Category Breakdown Section */}
        <section className="category-section">
          <h3>Category Breakdown</h3>
          <p style={{ fontSize: 'var(--font-size-xs)', color: 'var(--color-text-tertiary)', marginBottom: 'var(--space-lg)' }}>
            Expenses Only
          </p>

          {Object.keys(categoryBreakdown).length === 0 ? (
            <p className="category-empty">No expense data to display.</p>
          ) : (
            <div className="category-list">
              {Object.entries(categoryBreakdown)
                .sort(([, a], [, b]) => b - a)
                .map(([category, amount]) => (
                  <div key={category} className="category-item">
                    <span className="category-name">{category}</span>
                    <span className="category-amount">
                      ₹ {amount.toLocaleString('en-IN')}
                    </span>
                  </div>
                ))}
              
              <div className="category-item category-total">
                <span className="category-name">Total Expenses</span>
                <span className="category-amount">
                  ₹ {totalExpense.toLocaleString('en-IN')}
                </span>
              </div>
            </div>
          )}
        </section>
      </aside>
    </div>
  )
}

export default Dashboard
