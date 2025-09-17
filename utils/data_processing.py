import pandas as pd
import json
from typing import Dict, List, Any
import plotly.express as px
import plotly.graph_objects as go

def create_expense_breakdown_chart(expenses: Dict[str, float]) -> go.Figure:
    """Create pie chart for expense breakdown"""
    df = pd.DataFrame(list(expenses.items()), columns=['Category', 'Amount'])
    df = df[df['Amount'] > 0]  # Filter out zero amounts
    
    fig = px.pie(
        df, 
        values='Amount', 
        names='Category',
        title='Monthly Expense Breakdown',
        color_discrete_sequence=px.colors.qualitative.Set3
    )
    
    fig.update_traces(textposition='inside', textinfo='percent+label')
    return fig

def create_savings_trend_chart(monthly_data: List[Dict[str, Any]]) -> go.Figure:
    """Create line chart for savings trend"""
    df = pd.DataFrame(monthly_data)
    
    fig = go.Figure()
    fig.add_trace(go.Scatter(
        x=df['month'],
        y=df['savings'],
        mode='lines+markers',
        name='Monthly Savings',
        line=dict(color='green', width=3)
    ))
    
    fig.update_layout(
        title='Savings Trend Over Time',
        xaxis_title='Month',
        yaxis_title='Savings ($)',
        template='plotly_white'
    )
    
    return fig

def generate_financial_insights(budget_data: Dict[str, Any]) -> List[str]:
    """Generate AI-powered financial insights"""
    insights = []
    
    # Savings rate analysis
    savings_rate = budget_data.get('savings_rate', 0)
    if savings_rate < 10:
        insights.append("🚨 Your savings rate is below 10%. Consider reviewing your expenses to increase savings.")
    elif savings_rate >= 20:
        insights.append("🎉 Excellent! You're saving 20% or more of your income.")
    
    # Expense category analysis
    expenses = budget_data.get('expense_breakdown', pd.DataFrame())
    if not expenses.empty:
        top_expense = expenses.loc[expenses['Amount'].idxmax(), 'Category']
        top_amount = expenses.loc[expenses['Amount'].idxmax(), 'Amount']
        total_income = budget_data.get('total_income', 0)
        
        if total_income > 0:
            percentage = (top_amount / total_income) * 100
            insights.append(f"💡 Your highest expense is {top_expense} at {percentage:.1f}% of income.")
    
    return insights

def load_financial_data(filename: str) -> Dict[str, Any]:
    """Load financial data from JSON file"""
    try:
        with open(filename, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        return {}

def save_user_profile(profile_data: Dict[str, Any], filename: str = 'user_profile.json'):
    """Save user profile data"""
    try:
        with open(filename, 'w') as f:
            json.dump(profile_data, f, indent=2)
        return True
    except Exception:
        return False