import streamlit as st
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch


MODEL_NAME = "ibm-granite/granite-3.3-2b-instruct"

@st.cache_resource
def load_model():
    tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
    model = AutoModelForCausalLM.from_pretrained(
        MODEL_NAME,
        torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
        device_map="auto"
    )
    return tokenizer, model

tokenizer, model = load_model()

st.set_page_config(page_title="Personal Finance Chatbot", page_icon="💰", layout="wide")

# Custom CSS for better styling
st.markdown("""
<style>
    .main-header {
        background: linear-gradient(90deg, #1e3c72 0%, #2a5298 100%);
        padding: 1rem;
        border-radius: 10px;
        color: white;
        text-align: center;
        margin-bottom: 2rem;
    }
    .stSidebar {
        background-color: #f0f2f6;
    }
    .metric-card {
        background: white;
        padding: 1rem;
        border-radius: 10px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        margin: 0.5rem 0;
    }
    .chat-message {
        padding: 1rem;
        margin: 0.5rem 0;
        border-radius: 10px;
    }
    .user-message {
        background-color: #e3f2fd;
        border-left: 4px solid #2196f3;
    }
    .assistant-message {
        background-color: #f3e5f5;
        border-left: 4px solid #9c27b0;
    }
    .stButton > button {
        background: linear-gradient(45deg, #2196f3, #21cbf3);
        color: white;
        border: none;
        border-radius: 20px;
        padding: 0.5rem 1rem;
        font-weight: bold;
    }
    .finance-tip {
        background: #e8f5e8;
        border-left: 4px solid #4caf50;
        padding: 1rem;
        margin: 1rem 0;
        border-radius: 5px;
    }
</style>
""", unsafe_allow_html=True)

# Main header with gradient
st.markdown("""
<div class="main-header">
    <h1>💰 Personal Finance Chatbot</h1>
    <p>Get intelligent guidance on savings, taxes, and investments powered by IBM Granite AI</p>
</div>
""", unsafe_allow_html=True)


# Enhanced Sidebar
with st.sidebar:
    st.markdown("### 👤 User Profile")
    user_type = st.selectbox("Select your profile", ["Student", "Professional", "Retiree", "Small Business Owner"])
    
    # User preferences
    st.markdown("### ⚙️ Preferences")
    response_length = st.select_slider(
        "Response detail level:",
        options=["Brief", "Detailed", "Comprehensive"],
        value="Detailed"
    )
    
    risk_tolerance = st.select_slider(
        "Risk tolerance:",
        options=["Conservative", "Moderate", "Aggressive"],
        value="Moderate"
    )
    
    # Financial goals section
    st.markdown("### 🎯 Quick Goals")
    goals = st.multiselect(
        "What are you focused on?",
        ["Emergency Fund", "Retirement Planning", "Investment Growth", 
         "Debt Management", "Tax Optimization", "Home Buying", "Education Savings"]
    )
    
    # Quick stats section
    st.markdown("### � Financial Health Check")
    
    col1, col2 = st.columns(2)
    with col1:
        emergency_months = st.number_input("Emergency fund (months)", min_value=0.0, max_value=12.0, value=3.0, step=0.5)
    with col2:
        savings_rate = st.number_input("Savings rate (%)", min_value=0, max_value=100, value=20, step=5)
    
    # Display quick metrics
    if emergency_months < 3:
        st.warning("⚠️ Consider building emergency fund")
    elif emergency_months >= 6:
        st.success("✅ Great emergency fund!")
    
    if savings_rate < 10:
        st.warning("⚠️ Try to increase savings rate")
    elif savings_rate >= 20:
        st.success("✅ Excellent savings rate!")
    
    # Financial tip of the day
    st.markdown("### 💡 Daily Finance Tip")
    tips = [
        "The 50/30/20 rule: 50% needs, 30% wants, 20% savings",
        "Start investing early - compound interest is your friend",
        "Pay off high-interest debt before investing",
        "Diversify your portfolio across different asset classes",
        "Review and rebalance your portfolio annually"
    ]
    import random
    daily_tip = random.choice(tips)
    st.info(f"💡 {daily_tip}")
    
    st.markdown("---")
    st.markdown("**💬 Chat adapts to your profile automatically**")
    if goals:
        st.markdown(f"**🎯 Focusing on:** {', '.join(goals[:2])}")
    st.markdown(f"**📊 Risk Level:** {risk_tolerance}")
    st.markdown(f"**📝 Detail Level:** {response_length}")
    
    # Financial Calculators Section
    st.markdown("---")
    st.markdown("### 🧮 Quick Calculators")
    
    calc_type = st.selectbox("Choose calculator:", ["Compound Interest", "Loan Payment", "Retirement Savings"])
    
    if calc_type == "Compound Interest":
        st.markdown("**Compound Interest Calculator**")
        principal = st.number_input("Initial amount ($)", min_value=0, value=1000, step=100)
        rate = st.number_input("Annual interest rate (%)", min_value=0.0, value=7.0, step=0.1)
        time = st.number_input("Time (years)", min_value=1, value=10, step=1)
        
        if st.button("Calculate", key="compound"):
            final_amount = principal * (1 + rate/100) ** time
            interest_earned = final_amount - principal
            st.success(f"💰 **Final Amount:** ${final_amount:,.2f}")
            st.info(f"📈 **Interest Earned:** ${interest_earned:,.2f}")
    
    elif calc_type == "Loan Payment":
        st.markdown("**Monthly Loan Payment Calculator**")
        loan_amount = st.number_input("Loan amount ($)", min_value=0, value=200000, step=1000)
        annual_rate = st.number_input("Annual interest rate (%)", min_value=0.0, value=5.0, step=0.1)
        years = st.number_input("Loan term (years)", min_value=1, value=30, step=1)
        
        if st.button("Calculate", key="loan"):
            monthly_rate = annual_rate / 100 / 12
            num_payments = years * 12
            monthly_payment = loan_amount * (monthly_rate * (1 + monthly_rate)**num_payments) / ((1 + monthly_rate)**num_payments - 1)
            total_paid = monthly_payment * num_payments
            total_interest = total_paid - loan_amount
            
            st.success(f"💳 **Monthly Payment:** ${monthly_payment:,.2f}")
            st.info(f"💰 **Total Interest:** ${total_interest:,.2f}")
    
    elif calc_type == "Retirement Savings":
        st.markdown("**Retirement Savings Calculator**")
        monthly_contribution = st.number_input("Monthly contribution ($)", min_value=0, value=500, step=50)
        current_age = st.number_input("Current age", min_value=18, value=30, step=1)
        retirement_age = st.number_input("Retirement age", min_value=current_age, value=65, step=1)
        expected_return = st.number_input("Expected annual return (%)", min_value=0.0, value=8.0, step=0.1)
        
        if st.button("Calculate", key="retirement"):
            years_to_retirement = retirement_age - current_age
            months = years_to_retirement * 12
            monthly_rate = expected_return / 100 / 12
            
            if monthly_rate > 0:
                future_value = monthly_contribution * (((1 + monthly_rate)**months - 1) / monthly_rate)
            else:
                future_value = monthly_contribution * months
            
            total_contributions = monthly_contribution * months
            interest_earned = future_value - total_contributions
            
            st.success(f"🏆 **Retirement Savings:** ${future_value:,.2f}")
            st.info(f"📈 **Interest Earned:** ${interest_earned:,.2f}")
            st.info(f"💵 **Total Contributed:** ${total_contributions:,.2f}")


if "messages" not in st.session_state:
    st.session_state.messages = []

# Main chat area
st.markdown("### 💬 Chat with your Finance Assistant")

# Add some sample questions to get started
if not st.session_state.messages:
    st.markdown("##### 🚀 Get started with these questions:")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("💰 How to start investing?"):
            st.session_state.messages.append({"role": "user", "content": "How should I start investing as a beginner?"})
            st.rerun()
    
    with col2:
        if st.button("🏠 Saving for a house?"):
            st.session_state.messages.append({"role": "user", "content": "What's the best strategy for saving for a house down payment?"})
            st.rerun()
    
    with col3:
        if st.button("📊 Emergency fund tips?"):
            st.session_state.messages.append({"role": "user", "content": "How much should I have in my emergency fund?"})
            st.rerun()
    
    # Welcome message with financial topics
    st.markdown("""
    <div class="finance-tip">
        <h4>🎯 What I can help you with:</h4>
        <ul>
            <li><strong>💰 Investment Planning:</strong> Stocks, bonds, ETFs, portfolio diversification</li>
            <li><strong>🏦 Savings Strategies:</strong> Emergency funds, high-yield accounts, CDs</li>
            <li><strong>📊 Tax Optimization:</strong> Tax-advantaged accounts, deductions, strategies</li>
            <li><strong>🏠 Major Purchases:</strong> Home buying, car financing, large expenses</li>
            <li><strong>🎓 Education:</strong> Student loans, 529 plans, financial literacy</li>
            <li><strong>👥 Life Events:</strong> Marriage, children, career changes, retirement</li>
        </ul>
        <p><strong>📝 Type your question below or click one of the starter questions above!</strong></p>
    </div>
    """, unsafe_allow_html=True)

# Display chat messages with improved styling
for i, msg in enumerate(st.session_state.messages):
    with st.chat_message(msg["role"]):
        if msg["role"] == "user":
            st.markdown(f'<div class="chat-message user-message">{msg["content"]}</div>', unsafe_allow_html=True)
        else:
            st.markdown(f'<div class="chat-message assistant-message">{msg["content"]}</div>', unsafe_allow_html=True)


prompt = st.chat_input("Ask me about savings, taxes, or investments...")
if prompt:
    
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

   
    system_prompt = (
        f"You are a helpful Personal Finance Assistant chatbot. "
        f"Provide clear, practical financial guidance on savings, taxes, and investments. "
        f"Adapt tone and complexity for a {user_type.lower()}. "
        f"User preferences: Risk tolerance is {risk_tolerance.lower()}, "
        f"prefers {response_length.lower()} responses"
        + (f", focusing on {', '.join(goals)}" if goals else "") + ". "
        f"Always provide actionable advice and consider the user's profile when responding."
    )

    
    messages = [{"role": "system", "content": system_prompt}] + st.session_state.messages

   
    inputs = tokenizer.apply_chat_template(
        messages,
        add_generation_prompt=True,
        tokenize=True,
        return_tensors="pt"
    ).to(model.device)

 
    with st.chat_message("assistant"):
        with st.spinner("Thinking..."):
            outputs = model.generate(
                **inputs,
                max_new_tokens=300,
                do_sample=True,
                temperature=0.7,
                top_p=0.9,
            )
            reply = tokenizer.decode(outputs[0][inputs["input_ids"].shape[-1]:], skip_special_tokens=True)
            st.markdown(reply)

    
    st.session_state.messages.append({"role": "assistant", "content": reply})

# Footer with disclaimer and additional info
st.markdown("---")
st.markdown("### ℹ️ Important Information")

col1, col2 = st.columns(2)

with col1:
    st.markdown("""
    **⚠️ Disclaimer**
    - This chatbot provides general financial information only
    - Not personalized financial advice
    - Consult a qualified financial advisor for specific situations
    - Always do your own research before making financial decisions
    """)

with col2:
    st.markdown("""
    **📚 Helpful Resources**
    - [SEC Investor.gov](https://www.investor.gov/)
    - [IRS Tax Information](https://www.irs.gov/)
    - [Federal Reserve Education](https://www.federalreserveeducation.org/)
    - [FINRA Investor Education](https://www.finra.org/investors)
    """)

st.markdown("---")
st.markdown("""
<div style="text-align: center; color: #666; font-size: 0.9em;">
    <p>💰 Personal Finance Chatbot | Powered by IBM Granite AI | Built with Streamlit</p>
    <p>For educational purposes only. Always consult professional financial advisors.</p>
</div>
""", unsafe_allow_html=True)
