import unittest
import pandas as pd
from utils.financial_calculations import (
    calculate_emergency_fund, 
    calculate_compound_interest,
    calculate_savings_rate,
    calculate_debt_payoff_time,
    BudgetRules
)

class TestFinancialCalculations(unittest.TestCase):
    
    def test_emergency_fund_calculation(self):
        monthly_expenses = 3000
        result = calculate_emergency_fund(monthly_expenses, 6)
        self.assertEqual(result, 18000)
        
        result = calculate_emergency_fund(monthly_expenses, 3)
        self.assertEqual(result, 9000)
    
    def test_compound_interest(self):
        # Test basic compound interest
        principal = 1000
        rate = 0.05  # 5%
        time = 10
        result = calculate_compound_interest(principal, rate, time, 12)
        
        # Should be approximately $1,648
        self.assertAlmostEqual(result, 1648.72, places=0)
    
    def test_savings_rate_calculation(self):
        # Normal case
        result = calculate_savings_rate(5000, 4000)
        self.assertEqual(result, 20.0)
        
        # Zero income
        result = calculate_savings_rate(0, 1000)
        self.assertEqual(result, 0.0)
        
        # Negative savings (expenses > income)
        result = calculate_savings_rate(3000, 4000)
        self.assertEqual(result, -33.33333333333333)
    
    def test_debt_payoff_calculation(self):
        balance = 5000
        monthly_payment = 200
        apr = 18.0
        
        months, interest = calculate_debt_payoff_time(balance, monthly_payment, apr)
        
        # Should take about 31 months
        self.assertGreater(months, 25)
        self.assertLess(months, 35)
        self.assertGreater(interest, 1000)
    
    def test_fifty_thirty_twenty_rule(self):
        income = 5000
        result = BudgetRules.fifty_thirty_twenty(income)
        
        self.assertEqual(result['needs'], 2500)
        self.assertEqual(result['wants'], 1500)
        self.assertEqual(result['savings'], 1000)
    
    def test_housing_cost_evaluation(self):
        income = 5000
        
        # Good housing cost (25%)
        result = BudgetRules.evaluate_housing_cost(1250, income)
        self.assertIn("Good", result)
        
        # High housing cost (40%)
        result = BudgetRules.evaluate_housing_cost(2000, income)
        self.assertIn("High", result)

if __name__ == '__main__':
    unittest.main()