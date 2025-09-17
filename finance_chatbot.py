# Enhanced Personal Finance Chatbot using IBM Granite 3.0
# File: enhanced_finance_chatbot.py

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from transformers import pipeline, AutoTokenizer, AutoModelForCausalLM
import torch
import json
from datetime import datetime, timedelta
import re
from typing import Dict, List, Any, Optional
import logging
import time

# Import configuration
try:
    from app_config import MODEL_NAME, MAX_TOKENS, TEMPERATURE, USER_TYPES, EXPENSE_CATEGORIES
except ImportError:
    # Fallback configuration if app_config.py is not available
    MODEL_NAME = "ibm-granite/granite-3.0-2b-instruct"
    MAX_TOKENS = 300
    TEMPERATURE = 0.7
    USER_TYPES = {
        "student": {"prompt_style": "simple", "focus_areas": ["budgeting", "student_loans"], "complexity": "basic"},
        "professional": {"prompt_style": "sophisticated", "focus_areas": ["investments", "tax_optimization"], "complexity": "advanced"},
        "general": {"prompt_style": "balanced", "focus_areas": ["general_finance", "savings"], "complexity": "intermediate"}
    }
    EXPENSE_CATEGORIES = ["Housing", "Transportation", "Food", "Utilities", "Healthcare", "Entertainment", "Shopping", "Other"]

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def initialize_session_state():
    """Initialize all session state variables"""
    if 'chatbot' not in st.session_state:
        st.session_state.chatbot = FinanceChatbot()
        st.session_state.model_loaded = False
        st.session_state.chat_history = []
        st.session_state.user_profile = {}
        st.session_state.budget_history = []
        st.session_state.learning_progress = {}
    
    # Initialize onboarding state
    if 'onboarding_complete' not in st.session_state:
        st.session_state.onboarding_complete = False
        st.session_state.onboarding_step = 0
        st.session_state.onboarding_data = {}

class OnboardingFlow:
    """Handles the conversational onboarding experience"""
    
    @staticmethod
    def initialize_onboarding():
        """Initialize onboarding state"""
        if 'onboarding_complete' not in st.session_state:
            st.session_state.onboarding_complete = False
            st.session_state.onboarding_step = 0
            st.session_state.onboarding_data = {}
    
    @staticmethod
    def run_onboarding():
        """Run the conversational onboarding flow"""
        if st.session_state.onboarding_complete:
            return True
            
        steps = [
            OnboardingFlow.welcome_step,
            OnboardingFlow.user_type_step,
            OnboardingFlow.income_step,
            OnboardingFlow.goals_step,
            OnboardingFlow.completion_step
        ]
        
        if st.session_state.onboarding_step < len(steps):
            return steps[st.session_state.onboarding_step]()
        else:
            st.session_state.onboarding_complete = True
            return True
    
    @staticmethod
    def welcome_step():
        """Welcome step of onboarding"""
        st.markdown("""
        <div style='text-align: center; padding: 2rem; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 10px; margin-bottom: 2rem;'>
            <h1 style='color: white; margin-bottom: 1rem;'>Welcome to Your Personal Finance Assistant!</h1>
            <p style='color: white; font-size: 1.2rem; margin: 0;'>I'm here to help you take control of your finances. Let's get to know each other!</p>
        </div>
        """, unsafe_allow_html=True)
        
        col1, col2, col3 = st.columns([1, 2, 1])
        with col2:
            if st.button("Let's Get Started!", type="primary", use_container_width=True):
                st.session_state.onboarding_step += 1
                st.rerun()
        
        return False
    
    @staticmethod
    def user_type_step():
        """User type selection with conversational approach"""
        st.markdown("### Tell me a bit about yourself...")
        
        st.markdown("""
        <div style='background: #f8f9fa; padding: 1.5rem; border-radius: 10px; border-left: 4px solid #4CAF50; margin-bottom: 2rem;'>
            <p style='margin: 0; font-size: 1.1rem;'><strong>Assistant:</strong> "Hi there! To give you the best financial advice, I'd love to know more about your situation. Are you currently a student, working professional, or somewhere in between?"</p>
        </div>
        """, unsafe_allow_html=True)
        
        col1, col2, col3 = st.columns(3)
        
        user_types = [
            ("Student", "student", "I'm currently studying and want to learn good financial habits"),
            ("Professional", "professional", "I'm working and want to optimize my finances"),
            ("General", "general", "I want general financial guidance")
        ]
        
        for i, (label, key, description) in enumerate(user_types):
            with [col1, col2, col3][i]:
                if st.button(label, key=f"user_type_{key}", use_container_width=True):
                    st.session_state.onboarding_data['user_type'] = key
                    st.session_state.onboarding_step += 1
                    st.success(f"Great choice! {description}")
                    time.sleep(1)
                    st.rerun()
                st.markdown(f"<p style='text-align: center; font-size: 0.9rem; color: #666;'>{description}</p>", unsafe_allow_html=True)
        
        return False
    
    @staticmethod
    def income_step():
        """Income collection step"""
        user_type = st.session_state.onboarding_data.get('user_type', 'general')
        
        if user_type == 'student':
            st.markdown("### What's your monthly income situation?")
            st.markdown("""
            <div style='background: #e3f2fd; padding: 1.5rem; border-radius: 10px; border-left: 4px solid #2196F3; margin-bottom: 2rem;'>
                <p style='margin: 0; font-size: 1.1rem;'><strong>Assistant:</strong> "No worries if it's not much! Even part-time work, allowances, or financial aid counts. This helps me give you relevant budgeting tips."</p>
            </div>
            """, unsafe_allow_html=True)
        else:
            st.markdown("### What's your monthly income?")
            st.markdown("""
            <div style='background: #e8f5e8; padding: 1.5rem; border-radius: 10px; border-left: 4px solid #4CAF50; margin-bottom: 2rem;'>
                <p style='margin: 0; font-size: 1.1rem;'><strong>Assistant:</strong> "This helps me understand your financial capacity and provide personalized advice. Don't worry, this information stays private!"</p>
            </div>
            """, unsafe_allow_html=True)
        
        monthly_income = st.number_input(
            "Monthly Income ($)", 
            min_value=0, 
            value=0, 
            step=100,
            help="Include all sources: salary, part-time work, allowances, etc."
        )
        
        col1, col2 = st.columns([1, 1])
        
        with col1:
            if st.button("Continue", type="primary"):
                st.session_state.onboarding_data['monthly_income'] = monthly_income
                st.session_state.onboarding_step += 1
                st.rerun()
        
        with col2:
            if st.button("Back"):
                st.session_state.onboarding_step -= 1
                st.rerun()
        
        return False
    
    @staticmethod
    def goals_step():
        """Financial goals selection"""
        st.markdown("### What are your main financial goals?")
        
        st.markdown("""
        <div style='background: #fff3e0; padding: 1.5rem; border-radius: 10px; border-left: 4px solid #ff9800; margin-bottom: 2rem;'>
            <p style='margin: 0; font-size: 1.1rem;'><strong>Assistant:</strong> "Knowing your goals helps me prioritize the advice I give you. Select all that apply!"</p>
        </div>
        """, unsafe_allow_html=True)
        
        goals_options = [
            ("Build an Emergency Fund", "emergency_fund"),
            ("Save for a Major Purchase", "major_purchase"),
            ("Start Investing", "investing"),
            ("Pay Off Debt", "debt_payoff"),
            ("Save for Education", "education"),
            ("Plan for Retirement", "retirement"),
            ("Learn Financial Basics", "financial_literacy")
        ]
        
        selected_goals = []
        
        cols = st.columns(2)
        for i, (label, key) in enumerate(goals_options):
            with cols[i % 2]:
                if st.checkbox(label, key=f"goal_{key}"):
                    selected_goals.append(key)
        
        col1, col2 = st.columns([1, 1])
        
        with col1:
            if st.button("Finish Setup", type="primary"):
                st.session_state.onboarding_data['goals'] = selected_goals
                st.session_state.onboarding_step += 1
                st.rerun()
        
        with col2:
            if st.button("Back"):
                st.session_state.onboarding_step -= 1
                st.rerun()
        
        return False
    
    @staticmethod
    def completion_step():
        """Onboarding completion with personalized welcome"""
        user_data = st.session_state.onboarding_data
        user_type = user_data.get('user_type', 'general').title()
        income = user_data.get('monthly_income', 0)
        goals = user_data.get('goals', [])
        
        st.markdown("""
        <div style='text-align: center; padding: 2rem; background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); border-radius: 10px; margin-bottom: 2rem;'>
            <h2 style='color: white; margin-bottom: 1rem;'>You're All Set!</h2>
        </div>
        """, unsafe_allow_html=True)
        
        # Personalized welcome message
        st.markdown(f"""
        <div style='background: #f8f9fa; padding: 2rem; border-radius: 10px; margin-bottom: 2rem;'>
            <h3 style='color: #333; margin-bottom: 1rem;'>Your Financial Profile:</h3>
            <ul style='list-style-type: none; padding: 0;'>
                <li style='margin-bottom: 0.5rem;'><strong>Profile:</strong> {user_type}</li>
                <li style='margin-bottom: 0.5rem;'><strong>Monthly Income:</strong> ${income:,}</li>
                <li style='margin-bottom: 0.5rem;'><strong>Goals:</strong> {len(goals)} selected</li>
            </ul>
        </div>
        """, unsafe_allow_html=True)
        
        # Store profile in session state
        st.session_state.user_profile = user_data.copy()
        
        col1, col2, col3 = st.columns([1, 2, 1])
        with col2:
            if st.button("Start Your Financial Journey!", type="primary", use_container_width=True):
                st.session_state.onboarding_complete = True
                st.rerun()
        
        return False

class ProactiveInsights:
    """Generates proactive financial insights based on user data"""
    
    @staticmethod
    def analyze_budget_and_generate_insights(budget_data: Dict[str, Any], user_profile: Dict[str, Any]) -> List[str]:
        """Generate proactive insights based on budget analysis"""
        insights = []
        expenses = budget_data.get('expense_breakdown', pd.DataFrame())
        total_income = budget_data.get('total_income', 0)
        savings_rate = budget_data.get('savings_rate', 0)
        user_type = user_profile.get('user_type', 'general')
        
        # Savings rate insights
        if savings_rate < 5:
            insights.append("Critical Alert: Your savings rate is very low. Would you like some tips on reducing expenses or increasing income?")
        elif savings_rate < 10:
            insights.append("Improvement Needed: Try to boost your savings rate to at least 10%. I can help you find areas to cut back!")
        elif savings_rate >= 20:
            insights.append("Excellent Work: Your savings rate is fantastic! Ready to explore investment opportunities?")
        
        if not expenses.empty:
            # Housing cost analysis
            housing_expense = expenses[expenses['Category'] == 'Housing']['Amount'].iloc[0] if 'Housing' in expenses['Category'].values else 0
            housing_percentage = (housing_expense / total_income * 100) if total_income > 0 else 0
            
            if housing_percentage > 50:
                insights.append(f"Housing Alert: You're spending {housing_percentage:.1f}% on housing. The recommended maximum is 30%. Want some strategies to reduce housing costs?")
            elif housing_percentage > 30:
                insights.append(f"Housing Watch: Your housing costs are {housing_percentage:.1f}% of income. This is manageable but worth monitoring.")
            
            # Find highest expense category
            highest_expense = expenses.loc[expenses['Amount'].idxmax()]
            if highest_expense['Category'] != 'Housing' and highest_expense['Percentage'] > 25:
                insights.append(f"Spending Pattern: Your highest expense is {highest_expense['Category']} at {highest_expense['Percentage']:.1f}%. Would you like tips on reducing {highest_expense['Category'].lower()} costs?")
        
        # User-type specific insights
        if user_type == 'student':
            if savings_rate > 0:
                insights.append("Student Success: Great job saving while in school! Consider starting a small emergency fund if you haven't already.")
        elif user_type == 'professional':
            if savings_rate > 15:
                insights.append("Professional Advantage: With your strong savings rate, you might want to explore tax-advantaged investment accounts like 401(k) or IRA.")
        
        return insights
    
    @staticmethod
    def generate_goal_based_insights(user_profile: Dict[str, Any], budget_data: Optional[Dict[str, Any]] = None) -> List[str]:
        """Generate insights based on user's financial goals"""
        insights = []
        goals = user_profile.get('goals', [])
        income = user_profile.get('monthly_income', 0)
        savings = budget_data.get('savings', 0) if budget_data else 0
        
        for goal in goals:
            if goal == 'emergency_fund' and savings > 0:
                months_of_expenses = savings / (income - savings) if (income - savings) > 0 else 0
                if months_of_expenses < 3:
                    insights.append(f"Emergency Fund: You have {months_of_expenses:.1f} months of expenses saved. Aim for 3-6 months. Want a savings plan?")
                else:
                    insights.append("Emergency Fund: You're on track with your emergency fund! Great job!")
            
            elif goal == 'investing' and savings > 0:
                insights.append("Investment Ready: With your positive cash flow, you're ready to explore investment options. Want to learn about index funds?")
            
            elif goal == 'debt_payoff':
                insights.append("Debt Strategy: I can help you create a debt payoff plan. Are you using the debt avalanche or snowball method?")
        
        return insights

class EnhancedBudgetAnalyzer:
    """Enhanced budget analyzer with interactive features"""
    
    @staticmethod
    def generate_budget_summary(income: float, expenses: Dict[str, float]) -> Dict[str, Any]:
        """Generate comprehensive budget analysis with enhanced insights"""
        total_expenses = sum(expenses.values())
        savings = income - total_expenses
        savings_rate = (savings / income * 100) if income > 0 else 0
        
        # Create expense breakdown
        expense_df = pd.DataFrame(list(expenses.items()), columns=['Category', 'Amount'])
        expense_df['Percentage'] = (expense_df['Amount'] / total_expenses * 100).round(2) if total_expenses > 0 else 0
        expense_df = expense_df.sort_values('Amount', ascending=False)
        
        # Generate basic insights
        insights = []
        if savings_rate < 10:
            insights.append("Low savings rate. Consider reducing discretionary expenses.")
        elif savings_rate >= 20:
            insights.append("Excellent savings rate! You're on track for financial goals.")
        
        return {
            'total_income': income,
            'total_expenses': total_expenses,
            'savings': savings,
            'savings_rate': savings_rate,
            'expense_breakdown': expense_df,
            'insights': insights
        }
    
    @staticmethod
    def create_enhanced_visualizations(budget_data: Dict[str, Any], historical_data: Optional[List] = None):
        """Create enhanced budget visualizations with interactivity"""
        
        # Enhanced pie chart with better styling
        fig_pie = px.pie(
            budget_data['expense_breakdown'],
            values='Amount',
            names='Category',
            title='Expense Breakdown',
            color_discrete_sequence=px.colors.qualitative.Set3,
            hover_data=['Percentage']
        )
        fig_pie.update_traces(
            textposition='inside',
            textinfo='percent+label',
            hovertemplate='<b>%{label}</b><br>Amount: $%{value:,.0f}<br>Percentage: %{customdata[0]:.1f}%<extra></extra>'
        )
        fig_pie.update_layout(
            showlegend=True,
            height=500,
            font=dict(size=12)
        )
        
        # Enhanced bar chart for budget overview
        overview_data = pd.DataFrame({
            'Category': ['Income', 'Expenses', 'Savings'],
            'Amount': [
                budget_data['total_income'],
                budget_data['total_expenses'],
                budget_data['savings']
            ],
            'Color': ['#4CAF50', '#f44336', '#2196F3']
        })
        
        fig_bar = px.bar(
            overview_data,
            x='Category',
            y='Amount',
            title='Budget Overview',
            color='Color',
            color_discrete_map={
                '#4CAF50': '#4CAF50',
                '#f44336': '#f44336', 
                '#2196F3': '#2196F3'
            }
        )
        fig_bar.update_layout(showlegend=False, height=400)
        fig_bar.update_traces(
            hovertemplate='<b>%{x}</b><br>Amount: $%{y:,.0f}<extra></extra>'
        )
        
        # Historical savings trend (if data available)
        fig_trend = None
        if historical_data and len(historical_data) > 1:
            df_trend = pd.DataFrame(historical_data)
            fig_trend = px.line(
                df_trend,
                x='date',
                y='savings',
                title='Savings Trend Over Time',
                markers=True
            )
            fig_trend.update_layout(height=400)
        
        # Expense category comparison chart
        fig_category = px.bar(
            budget_data['expense_breakdown'].head(8),
            x='Amount',
            y='Category',
            orientation='h',
            title='Top Expense Categories',
            color='Amount',
            color_continuous_scale='viridis'
        )
        fig_category.update_layout(height=400)
        
        return {
            'pie_chart': fig_pie,
            'overview_chart': fig_bar,
            'trend_chart': fig_trend,
            'category_chart': fig_category
        }

class FinanceChatbot:
    """Enhanced finance chatbot with improved functionality"""
    
    def __init__(self):
        self.model_name = MODEL_NAME
        self.tokenizer = None
        self.model = None
        self.pipeline = None
        self.user_profile = {}
        
    @st.cache_resource
    def load_model(_self):
        """Load the Granite model with caching"""
        try:
            # Load tokenizer and model
            _self.tokenizer = AutoTokenizer.from_pretrained(_self.model_name)
            _self.model = AutoModelForCausalLM.from_pretrained(
                _self.model_name,
                torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
                device_map="auto" if torch.cuda.is_available() else None
            )
            
            # Create pipeline
            _self.pipeline = pipeline(
                "text-generation",
                model=_self.model,
                tokenizer=_self.tokenizer,
                torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32
            )
            
            logger.info("Model loaded successfully!")
            return True
        except Exception as e:
            logger.error(f"Error loading model: {e}")
            return False
    
    def get_user_demographic_prompt(self, user_type: str) -> str:
        """Get demographic-specific prompt adjustments"""
        if user_type.lower() == "student":
            return """You are a financial advisor speaking to a college student. Use simple language, 
            focus on budgeting basics, student loans, part-time income, and building good financial habits. 
            Be encouraging and understanding of limited income."""
        elif user_type.lower() == "professional":
            return """You are a financial advisor speaking to a working professional. Use more sophisticated 
            financial terminology, discuss investment strategies, tax optimization, retirement planning, 
            and career-related financial decisions. Be thorough and analytical."""
        else:
            return """You are a helpful financial advisor. Provide clear, actionable advice tailored 
            to the user's financial situation."""
    
    def generate_response(self, user_input: str, user_type: str = "general", context: str = "") -> str:
        """Generate response using Granite model with enhanced context"""
        try:
            # Construct the prompt with demographic awareness
            demographic_prompt = self.get_user_demographic_prompt(user_type)
            
            system_prompt = f"""You are an expert personal finance advisor with deep knowledge of savings, 
            taxes, investments, and budgeting. {demographic_prompt}
            
            Context: {context}
            
            Provide helpful, accurate, and actionable financial advice. Keep responses concise but comprehensive.
            If discussing investments, always mention risks and suggest consulting professionals for major decisions.
            Use emojis sparingly but appropriately to make responses more engaging."""
            
            messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_input}
            ]
            
            # Generate response
            if self.pipeline:
                response = self.pipeline(
                    messages,
                    max_new_tokens=MAX_TOKENS,
                    temperature=TEMPERATURE,
                    do_sample=True,
                    pad_token_id=self.tokenizer.eos_token_id
                )
                return response[0]["generated_text"][-1]["content"] if response else "Sorry, I couldn't generate a response."
            else:
                # Fallback method
                inputs = self.tokenizer.apply_chat_template(
                    messages,
                    add_generation_prompt=True,
                    tokenize=True,
                    return_dict=True,
                    return_tensors="pt"
                ).to(self.model.device if self.model else "cpu")
                
                with torch.no_grad():
                    outputs = self.model.generate(
                        **inputs,
                        max_new_tokens=MAX_TOKENS,
                        temperature=TEMPERATURE,
                        do_sample=True,
                        pad_token_id=self.tokenizer.eos_token_id
                    )
                
                response = self.tokenizer.decode(outputs[0][inputs["input_ids"].shape[-1]:], skip_special_tokens=True)
                return response.strip()
                
        except Exception as e:
            logger.error(f"Error generating response: {e}")
            return f"I apologize, but I encountered an error: {str(e)}"

class NotificationSystem:
    """Handles user notifications and reminders"""
    
    @staticmethod
    def check_and_display_notifications():
        """Check for and display relevant notifications"""
        notifications = []
        
        # Budget analysis reminder - with safe access
        budget_history = st.session_state.get('budget_history', [])
        if len(budget_history) > 0:
            try:
                last_analysis = datetime.strptime(budget_history[-1]['date'], "%Y-%m-%d")
                days_since = (datetime.now() - last_analysis).days
                
                if days_since > 30:
                    notifications.append({
                        'type': 'info',
                        'message': f"It's been {days_since} days since your last budget analysis. Consider updating your budget!"
                    })
            except (KeyError, ValueError):
                pass  # Skip if date format is invalid
        
        # Learning streak notification - with safe access
        learning_progress = st.session_state.get('learning_progress', {})
        if len(learning_progress) > 0:
            streak = learning_progress.get('streak', 0)
            if streak >= 5:
                notifications.append({
                    'type': 'success',
                    'message': f"Amazing! You're on a {streak}-topic learning streak! Keep it up!"
                })
        
        # Savings rate alert - with safe access
        budget_data = st.session_state.get('budget_data', {})
        if budget_data:
            savings_rate = budget_data.get('savings_rate', 0)
            if savings_rate < 5:
                notifications.append({
                    'type': 'warning',
                    'message': "Your savings rate is below 5%. Consider reviewing your expenses or exploring ways to increase income."
                })
        
        # Display notifications
        for notification in notifications:
            if notification['type'] == 'success':
                st.success(notification['message'])
            elif notification['type'] == 'warning':
                st.warning(notification['message'])
            elif notification['type'] == 'error':
                st.error(notification['message'])
            else:
                st.info(notification['message'])

class DataExportManager:
    """Manages data export and import functionality"""
    
    @staticmethod
    def export_user_data():
        """Export all user data as JSON"""
        export_data = {
            'user_profile': st.session_state.get('user_profile', {}),
            'chat_history': st.session_state.get('chat_history', []),
            'budget_history': st.session_state.get('budget_history', []),
            'learning_progress': st.session_state.get('learning_progress', {}),
            'export_date': datetime.now().isoformat(),
            'app_version': '2.0_enhanced'
        }
        return json.dumps(export_data, indent=2)
    
    @staticmethod
    def import_user_data(uploaded_file):
        """Import user data from JSON file"""
        try:
            data = json.load(uploaded_file)
            
            # Validate data structure
            required_keys = ['user_profile', 'chat_history', 'budget_history', 'learning_progress']
            if all(key in data for key in required_keys):
                # Import data to session state
                st.session_state.user_profile = data['user_profile']
                st.session_state.chat_history = data['chat_history']
                st.session_state.budget_history = data['budget_history']
                st.session_state.learning_progress = data['learning_progress']
                st.session_state.onboarding_complete = bool(data['user_profile'])
                
                return True, "Data imported successfully!"
            else:
                return False, "Invalid file format. Please upload a valid financial data export."
        
        except Exception as e:
            return False, f"Error importing data: {str(e)}"

def main():
    # Set page config first
    st.set_page_config(
        page_title="Enhanced Personal Finance Chatbot",
        page_icon="💰",
        layout="wide",
        initial_sidebar_state="expanded"
    )
    
    # Initialize session state immediately after page config
    initialize_session_state()
    
    # Initialize onboarding
    OnboardingFlow.initialize_onboarding()
    
    # Run onboarding if not complete
    if not st.session_state.onboarding_complete:
        if not OnboardingFlow.run_onboarding():
            return
    
    # Main app starts here
    st.title("Enhanced Personal Finance Chatbot")
    st.subheader("Powered by IBM Granite 3.0 | Your Intelligent Financial Companion")
    
    # Quick stats in header
    if st.session_state.user_profile:
        col1, col2, col3, col4 = st.columns(4)
        with col1:
            st.metric("Profile", st.session_state.user_profile.get('user_type', 'N/A').title())
        with col2:
            st.metric("Monthly Income", f"${st.session_state.user_profile.get('monthly_income', 0):,}")
        with col3:
            st.metric("Financial Goals", len(st.session_state.user_profile.get('goals', [])))
        with col4:
            if st.button("Reset Profile"):
                st.session_state.onboarding_complete = False
                st.session_state.onboarding_step = 0
                st.session_state.user_profile = {}
                st.rerun()
    
    # Sidebar for enhanced controls
    with st.sidebar:
        st.header("Controls")
        
        # Model loading section
        st.subheader("Model Status")
        if not st.session_state.model_loaded:
            if st.button("Load Granite Model"):
                with st.spinner("Loading IBM Granite model..."):
                    st.session_state.model_loaded = st.session_state.chatbot.load_model()
                    if st.session_state.model_loaded:
                        st.success("Model loaded successfully!")
                    else:
                        st.error("Failed to load model. Check your connection.")
        else:
            st.success("Model Ready")
            if st.button("Reload Model"):
                st.session_state.model_loaded = False
                st.rerun()
        
        st.divider()
        
        # Quick actions
        st.subheader("Quick Actions")
        if st.button("Get Proactive Insights"):
            if 'budget_data' in st.session_state and st.session_state.user_profile:
                insights = ProactiveInsights.analyze_budget_and_generate_insights(
                    st.session_state.budget_data,
                    st.session_state.user_profile
                )
                goal_insights = ProactiveInsights.generate_goal_based_insights(
                    st.session_state.user_profile,
                    st.session_state.get('budget_data')
                )
                
                st.session_state.proactive_insights = insights + goal_insights
            else:
                st.warning("Complete your budget analysis first!")
        
        if st.button("View My Progress"):
            st.session_state.show_progress = True
        
        if st.button("Update Goals"):
            st.info("Goal update feature coming soon!")
        
        st.divider()
        
        # Data Management
        st.subheader("Data Management")
        
        # Data import
        uploaded_file = st.file_uploader(
            "Import Previous Data",
            type=['json'],
            help="Upload a previously exported financial data file"
        )
        
        if uploaded_file:
            success, message = DataExportManager.import_user_data(uploaded_file)
            if success:
                st.success(message)
                st.rerun()
            else:
                st.error(message)
        
        # Quick export
        if st.button("Quick Export"):
            export_data = DataExportManager.export_user_data()
            st.download_button(
                "Download Data",
                export_data,
                file_name=f"financial_data_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json",
                mime="application/json"
            )
    
    # Main tabs with enhanced features
    tab1, tab2, tab3, tab4, tab5 = st.tabs([
        "Smart Chat", 
        "Enhanced Budget Analyzer", 
        "Investment Insights", 
        "Financial Education",
        "Progress Tracker"
    ])
    
    with tab1:
        st.header("Intelligent Financial Chat")
        
        # Display proactive insights if available
        if hasattr(st.session_state, 'proactive_insights') and st.session_state.proactive_insights:
            with st.expander("Proactive Insights for You", expanded=True):
                for insight in st.session_state.proactive_insights:
                    st.markdown(insight)
                
                if st.button("Clear Insights"):
                    del st.session_state.proactive_insights
                    st.rerun()
        
        # Enhanced chat interface
        if st.session_state.model_loaded:
            # Chat history with better formatting
            for i, (user_msg, bot_msg, timestamp) in enumerate(st.session_state.chat_history):
                with st.container():
                    col1, col2 = st.columns([1, 10])
                    with col1:
                        st.markdown("**You:**")
                    with col2:
                        st.markdown(f"*{timestamp}*")
                    
                    st.markdown(f"💭 {user_msg}")
                    st.markdown(f"🤖 {bot_msg}")
                    st.divider()
            
            # Chat input with suggestions
            col1, col2 = st.columns([4, 1])
            
            with col1:
                user_input = st.text_input(
                    "Ask me anything about finance:",
                    placeholder="e.g., How can I reduce my spending on food?",
                    key="chat_input"
                )
            
            with col2:
                send_button = st.button("Send", type="primary")
            
            # Smart suggestions based on user profile
            if st.session_state.user_profile:
                st.subheader("Personalized Suggestions")
                
                user_type = st.session_state.user_profile.get('user_type', 'general')
                goals = st.session_state.user_profile.get('goals', [])
                
                # Generate personalized quick questions
                personalized_questions = []
                if user_type == 'student':
                    personalized_questions = [
                        "How can I build credit as a student?",
                        "What's the best way to manage student loans?",
                        "How much should I save from my part-time job?",
                        "Should I get a credit card in college?"
                    ]
                elif user_type == 'professional':
                    personalized_questions = [
                        "How should I optimize my 401(k) contributions?",
                        "What tax strategies can reduce my burden?",
                        "When should I consider buying a house?",
                        "How do I diversify my investment portfolio?"
                    ]
                else:
                    personalized_questions = [
                        "How much should I save for emergencies?",
                        "What's a good starter investment strategy?",
                        "How can I track my expenses better?",
                        "Should I pay off debt or invest first?"
                    ]
                
                # Add goal-specific questions
                if 'emergency_fund' in goals:
                    personalized_questions.append("How much should be in my emergency fund?")
                if 'investing' in goals:
                    personalized_questions.append("What's the best investment app for beginners?")
                if 'debt_payoff' in goals:
                    personalized_questions.append("Should I use debt avalanche or snowball method?")
                
                cols = st.columns(2)
                for i, question in enumerate(personalized_questions[:4]):  # Show max 4
                    with cols[i % 2]:
                        if st.button(question, key=f"personalized_{i}"):
                            if st.session_state.model_loaded:
                                with st.spinner("Generating personalized response..."):
                                    context = f"User is a {user_type} with goals: {', '.join(goals)}"
                                    response = st.session_state.chatbot.generate_response(
                                        question, user_type, context
                                    )
                                    timestamp = datetime.now().strftime("%I:%M %p")
                                    st.session_state.chat_history.append((question, response, timestamp))
                                    st.rerun()
            
            # Handle send button
            if send_button and user_input:
                if st.session_state.model_loaded:
                    with st.spinner("Thinking..."):
                        context = f"User profile: {st.session_state.user_profile}"
                        user_type = st.session_state.user_profile.get('user_type', 'general')
                        response = st.session_state.chatbot.generate_response(
                            user_input, user_type, str(context)
                        )
                        timestamp = datetime.now().strftime("%I:%M %p")
                        st.session_state.chat_history.append((user_input, response, timestamp))
                        st.rerun()
            
            # Chat controls
            col1, col2, col3 = st.columns(3)
            with col1:
                if st.button("Clear Chat"):
                    st.session_state.chat_history = []
                    st.rerun()
            
            with col2:
                if st.button("Export Chat"):
                    # Create downloadable chat history
                    chat_export = []
                    for user_msg, bot_msg, timestamp in st.session_state.chat_history:
                        chat_export.append(f"[{timestamp}] You: {user_msg}")
                        chat_export.append(f"[{timestamp}] Assistant: {bot_msg}")
                        chat_export.append("-" * 50)
                    
                    chat_text = "\n".join(chat_export)
                    st.download_button(
                        "Download Chat",
                        chat_text,
                        file_name=f"finance_chat_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt",
                        mime="text/plain"
                    )
            
            with col3:
                if st.button("Refresh Suggestions"):
                    st.rerun()
                    
        else:
            st.warning("Please load the Granite model from the sidebar to start chatting.")
    
    with tab2:
        st.header("Enhanced Budget Analyzer")
        
        col1, col2 = st.columns([1, 1])
        
        with col1:
            st.subheader("Financial Input")
            
            # Pre-fill with user profile data
            default_income = st.session_state.user_profile.get('monthly_income', 5000)
            monthly_income = st.number_input(
                "Monthly Income ($)", 
                min_value=0.0, 
                value=float(default_income), 
                step=100.0
            )
            
            st.subheader("Monthly Expenses")
            expenses = {}
            
            # Dynamic expense categories with smart defaults
            user_type = st.session_state.user_profile.get('user_type', 'general')
            
            for category in EXPENSE_CATEGORIES:
                # Smart defaults based on user type
                if user_type == 'student':
                    default_values = {
                        'Housing': 800, 'Transportation': 150, 'Food': 300,
                        'Utilities': 100, 'Healthcare': 50, 'Entertainment': 200,
                        'Shopping': 150, 'Other': 100
                    }
                elif user_type == 'professional':
                    default_values = {
                        'Housing': 1500, 'Transportation': 400, 'Food': 500,
                        'Utilities': 200, 'Healthcare': 200, 'Entertainment': 300,
                        'Shopping': 250, 'Other': 200
                    }
                else:
                    default_values = {
                        'Housing': 1200, 'Transportation': 300, 'Food': 400,
                        'Utilities': 150, 'Healthcare': 150, 'Entertainment': 250,
                        'Shopping': 200, 'Other': 150
                    }
                
                expenses[category] = st.number_input(
                    f"{category} ($)",
                    min_value=0.0,
                    value=float(default_values.get(category, 200)),
                    step=25.0,
                    key=f"enhanced_expense_{category}",
                    help=f"Average {category.lower()} spending for {user_type}s"
                )
            
            # Enhanced analysis button
            if st.button("Generate Comprehensive Analysis", type="primary"):
                budget_data = EnhancedBudgetAnalyzer.generate_budget_summary(monthly_income, expenses)
                st.session_state.budget_data = budget_data
                
                # Generate proactive insights immediately
                proactive_insights = ProactiveInsights.analyze_budget_and_generate_insights(
                    budget_data, st.session_state.user_profile
                )
                goal_insights = ProactiveInsights.generate_goal_based_insights(
                    st.session_state.user_profile, budget_data
                )
                
                st.session_state.proactive_insights = proactive_insights + goal_insights
                
                # Save to budget history
                budget_entry = {
                    'date': datetime.now().strftime("%Y-%m-%d"),
                    'income': monthly_income,
                    'expenses': sum(expenses.values()),
                    'savings': budget_data['savings'],
                    'savings_rate': budget_data['savings_rate']
                }
                st.session_state.budget_history.append(budget_entry)
        
        with col2:
            if 'budget_data' in st.session_state:
                st.subheader("Financial Dashboard")
                budget_data = st.session_state.budget_data
                
                # Enhanced metrics display
                col_metric1, col_metric2, col_metric3 = st.columns(3)
                
                with col_metric1:
                    st.metric(
                        "Monthly Income", 
                        f"${budget_data['total_income']:,.0f}",
                        help="Your total monthly income"
                    )
                
                with col_metric2:
                    st.metric(
                        "Total Expenses", 
                        f"${budget_data['total_expenses']:,.0f}",
                        help="Sum of all your monthly expenses"
                    )
                
                with col_metric3:
                    savings_delta = budget_data['savings_rate']
                    delta_color = "normal" if savings_delta >= 10 else "inverse"
                    st.metric(
                        "Monthly Savings", 
                        f"${budget_data['savings']:,.0f}",
                        delta=f"{savings_delta:.1f}% rate",
                        delta_color=delta_color,
                        help="Amount saved per month and savings rate"
                    )
                
                # Proactive insights display
                if hasattr(st.session_state, 'proactive_insights') and st.session_state.proactive_insights:
                    st.subheader("AI-Generated Insights")
                    for insight in st.session_state.proactive_insights:
                        if "Critical Alert" in insight:
                            st.error(insight)
                        elif "Improvement Needed" in insight or "Alert" in insight:
                            st.warning(insight)
                        elif "Excellent" in insight or "Success" in insight:
                            st.success(insight)
                        else:
                            st.info(insight)
                
                # Enhanced visualizations
                st.subheader("Interactive Visualizations")
                
                viz_data = EnhancedBudgetAnalyzer.create_enhanced_visualizations(
                    budget_data, 
                    st.session_state.budget_history if len(st.session_state.budget_history) > 1 else None
                )
                
                # Visualization tabs
                viz_tab1, viz_tab2, viz_tab3 = st.tabs(["Overview", "Trends", "Details"])
                
                with viz_tab1:
                    st.plotly_chart(viz_data['pie_chart'], use_container_width=True)
                    st.plotly_chart(viz_data['overview_chart'], use_container_width=True)
                
                with viz_tab2:
                    if viz_data['trend_chart']:
                        st.plotly_chart(viz_data['trend_chart'], use_container_width=True)
                        
                        # Trend analysis
                        if len(st.session_state.budget_history) > 1:
                            recent_savings = st.session_state.budget_history[-1]['savings']
                            previous_savings = st.session_state.budget_history[-2]['savings']
                            change = recent_savings - previous_savings
                            
                            if change > 0:
                                st.success(f"Great progress! Your savings increased by ${change:.0f} since last analysis.")
                            elif change < 0:
                                st.warning(f"Your savings decreased by ${abs(change):.0f}. Let's work on improving this!")
                            else:
                                st.info("Your savings remained consistent with your last analysis.")
                    else:
                        st.info("Complete multiple budget analyses to see your savings trend over time!")
                
                with viz_tab3:
                    st.plotly_chart(viz_data['category_chart'], use_container_width=True)
                    
                    # Detailed breakdown table
                    st.subheader("Detailed Breakdown")
                    st.dataframe(
                        budget_data['expense_breakdown'].style.format({
                            'Amount': '${:,.0f}',
                            'Percentage': '{:.1f}%'
                        }),
                        use_container_width=True
                    )
    
    with tab3:
        st.header("Advanced Investment Insights")
        
        if st.session_state.model_loaded:
            st.subheader("Personalized Investment Profile")
            
            col1, col2 = st.columns([1, 1])
            
            with col1:
                # Enhanced investment questionnaire
                age = st.slider("Age", 18, 80, st.session_state.user_profile.get('age', 30))
                risk_tolerance = st.selectbox(
                    "Risk Tolerance", 
                    ["Conservative", "Moderate", "Aggressive"],
                    help="Conservative: Prioritize capital preservation\nModerate: Balance growth and safety\nAggressive: Maximize growth potential"
                )
                investment_timeline = st.selectbox(
                    "Investment Timeline", 
                    ["< 1 year", "1-5 years", "5-10 years", "> 10 years"],
                    help="How long until you need this money?"
                )
                investment_amount = st.number_input("Amount to Invest ($)", min_value=100, value=1000, step=100)
                
                # Additional investment factors
                st.subheader("Additional Factors")
                has_emergency_fund = st.checkbox("I have an emergency fund", value=True)
                employer_401k = st.checkbox("My employer offers 401(k) matching")
                investment_experience = st.selectbox(
                    "Investment Experience",
                    ["Beginner", "Intermediate", "Advanced"]
                )
            
            with col2:
                if st.button("Get Advanced Investment Recommendations", type="primary"):
                    # Create comprehensive investment profile
                    investment_profile = {
                        'age': age,
                        'risk_tolerance': risk_tolerance.lower(),
                        'timeline': investment_timeline,
                        'amount': investment_amount,
                        'emergency_fund': has_emergency_fund,
                        'employer_401k': employer_401k,
                        'experience': investment_experience.lower(),
                        'user_type': st.session_state.user_profile.get('user_type', 'general')
                    }
                    
                    investment_query = f"""Based on my comprehensive profile: Age {age}, {risk_tolerance.lower()} risk tolerance, 
                    investment timeline of {investment_timeline}, ${investment_amount} to invest, 
                    emergency fund status: {'Yes' if has_emergency_fund else 'No'}, 
                    401k matching: {'Available' if employer_401k else 'Not available'}, 
                    experience level: {investment_experience.lower()}.
                    
                    Please provide a detailed investment strategy with specific recommendations, asset allocation suggestions, 
                    and steps to get started. Also mention any important considerations or warnings."""
                    
                    with st.spinner("Analyzing your investment profile..."):
                        response = st.session_state.chatbot.generate_response(
                            investment_query,
                            st.session_state.user_profile.get('user_type', 'general'),
                            f"Comprehensive investment consultation for {risk_tolerance.lower()} investor with {investment_experience.lower()} experience"
                        )
                        
                        st.success("Your Personalized Investment Strategy:")
                        st.markdown(response)
                        
                        # Investment allocation visualization
                        if risk_tolerance == "Conservative":
                            allocation = {"Bonds": 60, "Stocks": 30, "Cash": 10}
                        elif risk_tolerance == "Moderate":
                            allocation = {"Stocks": 60, "Bonds": 30, "REITs": 10}
                        else:  # Aggressive
                            allocation = {"Stocks": 80, "REITs": 15, "Bonds": 5}
                        
                        fig_allocation = px.pie(
                            values=list(allocation.values()),
                            names=list(allocation.keys()),
                            title=f"Suggested Asset Allocation ({risk_tolerance} Portfolio)",
                            color_discrete_sequence=px.colors.qualitative.Set2
                        )
                        st.plotly_chart(fig_allocation, use_container_width=True)
            
            # Investment education section
            st.subheader("Investment Learning Hub")
            
            investment_topics = {
                "Beginner": [
                    "What are stocks, bonds, and ETFs?",
                    "How does compound interest work?",
                    "What's the difference between active and passive investing?",
                    "How to open your first investment account?"
                ],
                "Intermediate": [
                    "How to build a diversified portfolio?",
                    "Understanding expense ratios and fees",
                    "Dollar-cost averaging vs lump sum investing",
                    "Tax-efficient investing strategies"
                ],
                "Advanced": [
                    "Asset allocation across different life stages",
                    "International diversification strategies",
                    "Understanding market volatility and corrections",
                    "Rebalancing your portfolio effectively"
                ]
            }
            
            selected_level = st.selectbox("Choose your learning level:", list(investment_topics.keys()))
            
            cols = st.columns(2)
            for i, topic in enumerate(investment_topics[selected_level]):
                with cols[i % 2]:
                    if st.button(topic, key=f"invest_learn_{i}"):
                        if st.session_state.model_loaded:
                            with st.spinner("Preparing educational content..."):
                                educational_query = f"Explain '{topic}' in detail with practical examples and actionable advice"
                                response = st.session_state.chatbot.generate_response(
                                    educational_query,
                                    st.session_state.user_profile.get('user_type', 'general'),
                                    "Investment education request"
                                )
                                
                                with st.expander(f"{topic}", expanded=True):
                                    st.markdown(response)
        else:
            st.warning("Please load the model to get personalized investment insights.")
    
    with tab4:
        st.header("Interactive Financial Education")
        
        # Gamified learning progress
        if 'learning_progress' not in st.session_state:
            st.session_state.learning_progress = {}
        
        st.subheader("Your Learning Journey")
        
        # Progress tracking
        total_topics = 28  # Total number of educational topics
        completed_topics = len(st.session_state.learning_progress)
        progress_percentage = (completed_topics / total_topics) * 100
        
        st.progress(progress_percentage / 100)
        st.write(f"Progress: {completed_topics}/{total_topics} topics completed ({progress_percentage:.0f}%)")
        
        if completed_topics > 0:
            col1, col2, col3 = st.columns(3)
            with col1:
                st.metric("Topics Mastered", completed_topics)
            with col2:
                st.metric("Learning Streak", st.session_state.learning_progress.get('streak', 0))
            with col3:
                if completed_topics >= 10:
                    st.success("Financial Literacy Champion!")
                elif completed_topics >= 5:
                    st.info("Financial Knowledge Builder!")
                else:
                    st.info("Learning Beginner")
        
        # Enhanced educational content
        education_topics = {
            "Banking & Budgeting": {
                "topics": [
                    "Setting up your first bank account",
                    "Understanding different types of bank accounts",
                    "The 50/30/20 budgeting rule explained",
                    "Zero-based budgeting for maximum control",
                    "Emergency fund: How much and where to keep it",
                    "Tracking expenses with apps and tools",
                    "Building healthy financial habits"
                ],
                "color": "#4CAF50"
            },
            "Credit & Debt": {
                "topics": [
                    "How credit scores work and why they matter",
                    "Building credit from scratch",
                    "Good debt vs bad debt explained",
                    "Debt avalanche vs snowball methods",
                    "Understanding credit card terms and fees",
                    "How to negotiate with creditors",
                    "Debt consolidation options"
                ],
                "color": "#2196F3"
            },
            "Investing Basics": {
                "topics": [
                    "Stock market fundamentals",
                    "Understanding risk and return",
                    "Index funds vs individual stocks",
                    "Dollar-cost averaging strategy",
                    "The power of compound interest",
                    "Diversification principles",
                    "When to start investing"
                ],
                "color": "#FF9800"
            },
            "Major Life Goals": {
                "topics": [
                    "Saving for your first home",
                    "Understanding mortgages and interest rates",
                    "Planning for retirement early",
                    "Education funding strategies",
                    "Insurance needs at different life stages",
                    "Estate planning basics",
                    "Emergency preparedness"
                ],
                "color": "#9C27B0"
            }
        }
        
        selected_category = st.selectbox("Choose your focus area:", list(education_topics.keys()))
        category_data = education_topics[selected_category]
        
        st.markdown(f"""
        <div style='background: {category_data['color']}20; padding: 1rem; border-radius: 10px; border-left: 4px solid {category_data['color']}; margin-bottom: 1rem;'>
            <h3 style='margin: 0; color: {category_data['color']};'>{selected_category}</h3>
        </div>
        """, unsafe_allow_html=True)
        
        # Interactive learning cards
        for i, topic in enumerate(category_data['topics']):
            is_completed = topic in st.session_state.learning_progress
            
            with st.expander(f"{'✅' if is_completed else '📖'} {topic}", expanded=False):
                col1, col2 = st.columns([3, 1])
                
                with col1:
                    if st.session_state.model_loaded:
                        if st.button(f"Learn about {topic}", key=f"learn_enhanced_{i}_{selected_category}"):
                            with st.spinner("Preparing your lesson..."):
                                educational_query = f"""Provide a comprehensive but easy-to-understand explanation of '{topic}'. 
                                Include practical examples, actionable steps, and common mistakes to avoid. 
                                Make it engaging and relevant for a {st.session_state.user_profile.get('user_type', 'general')} user."""
                                
                                response = st.session_state.chatbot.generate_response(
                                    educational_query,
                                    st.session_state.user_profile.get('user_type', 'general'),
                                    "Interactive financial education"
                                )
                                
                                st.markdown("### Lesson Content")
                                st.markdown(response)
                                
                                # Mark as completed
                                st.session_state.learning_progress[topic] = {
                                    'completed_date': datetime.now().strftime("%Y-%m-%d"),
                                    'category': selected_category
                                }
                                
                                # Update streak
                                if 'streak' not in st.session_state.learning_progress:
                                    st.session_state.learning_progress['streak'] = 1
                                else:
                                    st.session_state.learning_progress['streak'] += 1
                                
                                st.success("Topic completed! Your learning streak continues!")
                                
                                # Generate follow-up questions
                                st.markdown("### Test Your Understanding")
                                follow_up_questions = [
                                    f"How would you apply {topic} to your personal situation?",
                                    f"What's one action you can take today based on learning about {topic}?",
                                    f"What questions do you still have about {topic}?"
                                ]
                                
                                for j, question in enumerate(follow_up_questions):
                                    if st.button(question, key=f"followup_{i}_{j}"):
                                        # This would generate a follow-up response
                                        st.info("Great question! Think about this and feel free to ask in the chat.")
                    else:
                        st.warning("Load the model to access interactive lessons")
                
                with col2:
                    if is_completed:
                        st.success("Completed")
                        completion_date = st.session_state.learning_progress[topic]['completed_date']
                        st.caption(f"{completion_date}")
    
    with tab5:
        st.header("Financial Progress Tracker")
        
        # Overall financial health score
        if st.session_state.user_profile and 'budget_data' in st.session_state:
            st.subheader("Financial Health Score")
            
            budget_data = st.session_state.budget_data
            savings_rate = budget_data.get('savings_rate', 0)
            
            # Calculate financial health score
            score_components = {
                'Savings Rate': min(savings_rate * 2, 40),  # Max 40 points
                'Emergency Fund': 20 if savings_rate > 0 else 0,  # Simplified check
                'Debt Management': 20,  # Assume good for now
                'Financial Education': min(len(st.session_state.learning_progress) * 2, 20)  # Max 20 points
            }
            
            total_score = sum(score_components.values())
            
            # Score visualization
            fig_score = go.Figure(go.Indicator(
                mode = "gauge+number+delta",
                value = total_score,
                domain = {'x': [0, 1], 'y': [0, 1]},
                title = {'text': "Financial Health Score"},
                delta = {'reference': 80},
                gauge = {
                    'axis': {'range': [None, 100]},
                    'bar': {'color': "darkgreen"},
                    'steps': [
                        {'range': [0, 50], 'color': "lightgray"},
                        {'range': [50, 80], 'color': "yellow"},
                        {'range': [80, 100], 'color': "green"}
                    ],
                    'threshold': {
                        'line': {'color': "red", 'width': 4},
                        'thickness': 0.75,
                        'value': 90
                    }
                }
            ))
            fig_score.update_layout(height=400)
            st.plotly_chart(fig_score, use_container_width=True)
            
            # Score breakdown
            st.subheader("Score Breakdown")
            for component, score in score_components.items():
                st.write(f"**{component}:** {score:.0f} points")
            
            # Recommendations based on score
            if total_score >= 80:
                st.success("Excellent! You're on track for financial success!")
            elif total_score >= 60:
                st.info("Good progress! Focus on improving your weakest areas.")
            else:
                st.warning("Let's work on building stronger financial habits!")
        
        # Budget history and trends
        if st.session_state.budget_history:
            st.subheader("Your Financial Journey")
            
            df_history = pd.DataFrame(st.session_state.budget_history)
            
            # Multiple trend charts
            fig_trends = go.Figure()
            
            fig_trends.add_trace(go.Scatter(
                x=df_history['date'],
                y=df_history['savings_rate'],
                mode='lines+markers',
                name='Savings Rate (%)',
                yaxis='y2',
                line=dict(color='blue', width=3)
            ))
            
            fig_trends.update_layout(
                title='Your Savings Progress Over Time',
                xaxis_title='Date',
                yaxis_title='Savings ($)',
                yaxis2=dict(
                    title='Savings Rate (%)',
                    overlaying='y',
                    side='right'
                ),
                height=500
            )
            
            st.plotly_chart(fig_trends, use_container_width=True)
            
            # Progress insights
            if len(df_history) > 1:
                latest_savings = df_history.iloc[-1]['savings']
                first_savings = df_history.iloc[0]['savings']
                improvement = latest_savings - first_savings
                
                if improvement > 0:
                    st.success(f"Amazing progress! You've increased your monthly savings by ${improvement:.0f}!")
                elif improvement < 0:
                    st.warning(f"Your savings decreased by ${abs(improvement):.0f}. Let's identify areas for improvement.")
                else:
                    st.info("Your savings have remained consistent.")
        
        # Goal progress tracking
        if st.session_state.user_profile.get('goals'):
            st.subheader("Goal Progress")
            
            goals = st.session_state.user_profile['goals']
            
            for goal in goals:
                goal_names = {
                    'emergency_fund': 'Emergency Fund',
                    'major_purchase': 'Major Purchase',
                    'investing': 'Start Investing',
                    'debt_payoff': 'Debt Payoff',
                    'education': 'Education Fund',
                    'retirement': 'Retirement',
                    'financial_literacy': 'Financial Education'
                }
                
                goal_name = goal_names.get(goal, goal)
                
                # Simple progress simulation (in real app, this would be more sophisticated)
                if goal == 'financial_literacy':
                    progress = min((len(st.session_state.learning_progress) / 28) * 100, 100)
                elif 'budget_data' in st.session_state:
                    # Use savings rate as a proxy for other goals
                    savings_rate = st.session_state.budget_data.get('savings_rate', 0)
                    progress = min(savings_rate * 5, 100)  # Convert to percentage
                else:
                    progress = 0
                
                st.write(f"**{goal_name}**")
                st.progress(progress / 100)
                st.write(f"Progress: {progress:.0f}%")
                st.write("---")

    # Enhanced footer with more information
    st.divider()
    
    # Footer with enhanced features
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.markdown("""
        <div style='text-align: center;'>
            <h4>Personal Finance Chatbot</h4>
            <p>Powered by IBM Granite 3.0<br>
            Built with Streamlit</p>
        </div>
        """, unsafe_allow_html=True)
    
    with col2:
        st.markdown("""
        <div style='text-align: center;'>
            <h4>Your Stats</h4>
        </div>
        """, unsafe_allow_html=True)
        
        if st.session_state.user_profile:
            st.metric("Chat Messages", len(st.session_state.chat_history))
            st.metric("Budget Analyses", len(st.session_state.budget_history))
            st.metric("Topics Learned", len(st.session_state.learning_progress))
    
    with col3:
        st.markdown("""
        <div style='text-align: center;'>
            <h4>Quick Actions</h4>
        </div>
        """, unsafe_allow_html=True)
        
        if st.button("Export My Data"):
            # Create comprehensive data export
            export_data = {
                'user_profile': st.session_state.user_profile,
                'chat_history': st.session_state.chat_history,
                'budget_history': st.session_state.budget_history,
                'learning_progress': st.session_state.learning_progress,
                'export_date': datetime.now().isoformat()
            }
            
            st.download_button(
                "Download My Financial Data",
                json.dumps(export_data, indent=2),
                file_name=f"my_financial_data_{datetime.now().strftime('%Y%m%d')}.json",
                mime="application/json"
            )
        
        if st.button("Reset All Data"):
            if st.checkbox("I understand this will delete all my data"):
                for key in list(st.session_state.keys()):
                    del st.session_state[key]
                st.rerun()
    
    # Disclaimer with enhanced styling
    st.markdown("""
    <div style='background: #f8f9fa; padding: 1.5rem; border-radius: 10px; border: 1px solid #dee2e6; margin-top: 2rem;'>
        <p style='margin: 0; text-align: center; color: #6c757d; font-size: 0.9rem;'>
            <strong>Important Disclaimer:</strong><br>
            This application is designed for educational purposes and general financial guidance. 
            The AI-generated advice should not replace professional financial consultation. 
            Always consult with qualified financial advisors, tax professionals, and investment specialists 
            before making significant financial decisions. Market conditions, individual circumstances, 
            and financial regulations can change, affecting the relevance of any advice provided.
        </p>
        <hr style='border: none; border-top: 1px solid #dee2e6; margin: 1rem 0;'>
        <p style='margin: 0; text-align: center; color: #6c757d; font-size: 0.8rem;'>
            <em>Built with Streamlit • Powered by IBM Granite 3.0 • Enhanced with Plotly Visualizations</em><br>
            <em>Your privacy matters: All data is stored locally in your browser session</em>
        </p>
    </div>
    """, unsafe_allow_html=True)

# Enhanced main execution with error handling
if __name__ == "__main__":
    try:
        # Display notifications at the start
        NotificationSystem.check_and_display_notifications()
        
        # Run main application
        main()
        
    except Exception as e:
        st.error(f"An unexpected error occurred: {str(e)}")
        st.info("Please refresh the page and try again. If the problem persists, check your internet connection and model loading status.")