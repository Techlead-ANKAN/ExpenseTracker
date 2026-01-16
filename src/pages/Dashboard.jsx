import { useState, useEffect, useMemo, useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../utils/supabase'
import { getUser, logout } from '../utils/auth'

const Dashboard = () => {
  const navigate = useNavigate()
  const user = getUser()
  
  const [expenses, setExpenses] = useState([])
  const [loading, setLoading] = useState(true)
  const [formData, setFormData] = useState({
    title: '',
    amount: '',
    category: 'Food',
    type: 'expense',
    date: new Date().toISOString().split('T')[0]
  })
  const [error, setError] = useState('')

  // Redirect if not authenticated
  useEffect(() => {
    if (!user) {
      navigate('/login')
    }
  }, [user, navigate])

  // Fetch expenses on mount
  useEffect(() => {
    if (user) {
      fetchExpenses()
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
      const { data, error: insertError } = await supabase
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
      alert('Expense added successfully!')
    } catch (err) {
      setError(err.message || 'Failed to add expense')
    }
  }

  const handleDelete = useCallback(async (id) => {
    if (!confirm('Are you sure you want to delete this expense?')) return

    try {
      const { error } = await supabase
        .from('expenses')
        .delete()
        .eq('id', id)

      if (error) throw error

      // Refresh expenses list
      fetchExpenses()
      alert('Expense deleted successfully!')
    } catch (err) {
      alert('Failed to delete expense: ' + err.message)
    }
  }, [fetchExpenses])

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  // Calculate summary with useMemo to prevent unnecessary recalculations
  const totalIncome = useMemo(() => {
    return expenses
      .filter(e => e.type === 'income')
      .reduce((sum, e) => sum + parseFloat(e.amount), 0)
  }, [expenses])

  const totalExpense = useMemo(() => {
    return expenses
      .filter(e => e.type === 'expense')
      .reduce((sum, e) => sum + parseFloat(e.amount), 0)
  }, [expenses])

  const balance = useMemo(() => {
    return totalIncome - totalExpense
  }, [totalIncome, totalExpense])

  // Calculate category-wise breakdown (only expenses) with useMemo
  const categoryBreakdown = useMemo(() => {
    return expenses
      .filter(e => e.type === 'expense')
      .reduce((acc, e) => {
        acc[e.category] = (acc[e.category] || 0) + parseFloat(e.amount)
        return acc
      }, {})
  }, [expenses])

  if (!user) return null

  return (
    <div className="dashboard-container">
      {/* Header */}
      <header className="dashboard-header">
        <div className="header-content">
          <h1>Expense Tracker</h1>
          <button onClick={handleLogout} className="btn-secondary">
            Logout
          </button>
        </div>
      </header>

      <div className="dashboard-content">
        {/* User Info Section */}
        <div className="user-info-card">
          <h2>Welcome, {user.name}</h2>
          <p>Email: {user.email}</p>
        </div>

        {/* Summary Cards */}
        <div className="summary-cards">
          <div className="stat-card income">
            <h3>Total Income</h3>
            <p className="stat-value">₹ {totalIncome.toLocaleString('en-IN')}</p>
          </div>
          <div className="stat-card expense">
            <h3>Total Expense</h3>
            <p className="stat-value">₹ {totalExpense.toLocaleString('en-IN')}</p>
          </div>
          <div className={`stat-card balance ${balance >= 0 ? 'positive' : 'negative'}`}>
            <h3>Balance</h3>
            <p className="stat-value">₹ {balance.toLocaleString('en-IN')}</p>
          </div>
        </div>

        {/* Add Expense Form */}
        <div className="add-expense-card">
          <h3>Add New Transaction</h3>
          
          {error && <div className="error-message">{error}</div>}

          <form onSubmit={handleSubmit}>
            <div className="form-row">
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
            </div>

            <div className="form-row">
              <div className="form-group">
                <label htmlFor="category">Category</label>
                <select
                  id="category"
                  name="category"
                  value={formData.category}
                  onChange={handleChange}
                >
                  <option value="Food">Food</option>
                  <option value="Travel">Travel</option>
                  <option value="Rent">Rent</option>
                  <option value="Shopping">Shopping</option>
                  <option value="Entertainment">Entertainment</option>
                  <option value="Healthcare">Healthcare</option>
                  <option value="Education">Education</option>
                  <option value="Utilities">Utilities</option>
                  <option value="Other">Other</option>
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
            </div>

            <button type="submit" className="btn-primary">
              Add Transaction
            </button>
          </form>
        </div>

        {/* Two Column Layout: Expense List + Category Breakdown */}
        <div className="bottom-section">
          {/* Expense List Table */}
          <div className="expense-list-card">
            <h3>Transaction History</h3>
            
            {loading ? (
              <p className="loading-text">Loading transactions...</p>
            ) : expenses.length === 0 ? (
              <p className="empty-text">No transactions yet. Add your first transaction above!</p>
            ) : (
              <div className="table-container">
                <table className="expense-table">
                  <thead>
                    <tr>
                      <th>Date</th>
                      <th>Title</th>
                      <th>Category</th>
                      <th>Type</th>
                      <th>Amount</th>
                      <th>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    {expenses.map((expense) => (
                      <tr key={expense.id}>
                        <td>{new Date(expense.date).toLocaleDateString('en-IN')}</td>
                        <td>{expense.title}</td>
                        <td>{expense.category}</td>
                        <td>
                          <span className={`type-badge ${expense.type}`}>
                            {expense.type}
                          </span>
                        </td>
                        <td className={expense.type === 'income' ? 'amount-income' : 'amount-expense'}>
                          {expense.type === 'income' ? '+' : '-'} ₹ {parseFloat(expense.amount).toLocaleString('en-IN')}
                        </td>
                        <td>
                          <button
                            onClick={() => handleDelete(expense.id)}
                            className="btn-delete"
                            aria-label="Delete transaction"
                          >
                            Delete
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>

          {/* Category-wise Breakdown */}
          <div className="category-breakdown-card">
            <h3>Category-wise Breakdown</h3>
            <p className="breakdown-subtitle">(Expenses Only)</p>
            
            {Object.keys(categoryBreakdown).length === 0 ? (
              <p className="empty-text">No expense data to show</p>
            ) : (
              <div className="category-list">
                {Object.entries(categoryBreakdown)
                  .sort((a, b) => b[1] - a[1])
                  .map(([category, amount]) => (
                    <div key={category} className="category-item">
                      <span className="category-name">{category}</span>
                      <span className="category-amount">₹ {amount.toLocaleString('en-IN')}</span>
                    </div>
                  ))}
                <div className="category-item total">
                  <span className="category-name">Total</span>
                  <span className="category-amount">₹ {totalExpense.toLocaleString('en-IN')}</span>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

export default Dashboard
