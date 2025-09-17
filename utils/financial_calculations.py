from typing import Dict, List, Tuple
import math

def calculate_emergency_fund(monthly_expenses: float, months: int = 6) -> float:
    """Calculate recommended emergency fund amount"""
    return monthly_expenses * months

def calculate_compound_interest(principal: float, rate: float, time: int, compound_frequency: int = 12) -> float:
    """Calculate compound interest"""
    return principal * (1 + rate / compound_frequency) ** (compound_frequency * time)

def calculate_savings_rate(income: float, expenses: float) -> float:
    """Calculate savings rate percentage"""
    if income <= 0:
        return 0.0
    savings = income - expenses
    return (savings / income) * 100

def calculate_debt_payoff_time(balance: float, monthly_payment: float, apr: float) -> Tuple[int, float]:
    """Calculate time to pay off debt and total interest paid"""
    if monthly_payment <= 0 or apr < 0:
        return float('inf'), float('inf')
    
    monthly_rate = apr / 12 / 100
    if monthly_rate == 0:
        months = math.ceil(balance / monthly_payment)
        total_interest = 0
    else:
        months = math.ceil(-math.log(1 - (balance * monthly_rate) / monthly_payment) / math.log(1 + monthly_rate))
        total_paid = monthly_payment * months
        total_interest = total_paid - balance
    
    return months, total_interest

def calculate_retirement_needs(current_age: int, retirement_age: int, desired_income: float, 
                             inflation_rate: float = 0.03) -> float:
    """Calculate retirement savings needed"""
    years_to_retirement = retirement_age - current_age
    future_income_needed = desired_income * (1 + inflation_rate) ** years_to_retirement
    return future_income_needed * 25  # 4% rule

class BudgetRules:
    @staticmethod
    def fifty_thirty_twenty(income: float) -> Dict[str, float]:
        """Apply 50/30/20 budgeting rule"""
        return {
            "needs": income * 0.5,
            "wants": income * 0.3,
            "savings": income * 0.2
        }
    
    @staticmethod
    def evaluate_housing_cost(housing_cost: float, income: float) -> str:
        """Evaluate if housing cost is reasonable"""
        percentage = (housing_cost / income) * 100
        if percentage <= 28:
            return "✅ Good - Housing cost is within recommended range"
        elif percentage <= 35:
            return "⚠️ Moderate - Housing cost is slightly high"
        else:
            return "❌ High - Housing cost exceeds recommended range"
