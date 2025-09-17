import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Model Configuration
MODEL_NAME = "ibm-granite/granite-3.0-2b-instruct"
MAX_TOKENS = 300
TEMPERATURE = 0.7

# Application Configuration
APP_TITLE = "Personal Finance Chatbot"
APP_ICON = "💰"

# User Types
USER_TYPES = {
    "student": {
        "prompt_style": "simple",
        "focus_areas": ["budgeting", "student_loans", "part_time_income"],
        "complexity": "basic"
    },
    "professional": {
        "prompt_style": "sophisticated",
        "focus_areas": ["investments", "tax_optimization", "retirement"],
        "complexity": "advanced"
    },
    "general": {
        "prompt_style": "balanced",
        "focus_areas": ["general_finance", "savings", "budgeting"],
        "complexity": "intermediate"
    }
}

# Budget Categories
EXPENSE_CATEGORIES = [
    "Housing", "Transportation", "Food", "Utilities", 
    "Healthcare", "Entertainment", "Shopping", "Other"
]

# Investment Risk Profiles
RISK_PROFILES = {
    "conservative": {
        "stocks": 0.2,
        "bonds": 0.7,
        "cash": 0.1
    },
    "moderate": {
        "stocks": 0.6,
        "bonds": 0.3,
        "cash": 0.1
    },
    "aggressive": {
        "stocks": 0.8,
        "bonds": 0.15,
        "cash": 0.05
    }
}
