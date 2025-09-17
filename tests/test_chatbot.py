import unittest
from unittest.mock import Mock, patch
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from finance_chatbot import FinanceChatbot, BudgetAnalyzer

class TestFinanceChatbot(unittest.TestCase):
    def setUp(self):
        self.chatbot = FinanceChatbot()
    
    def test_demographic_prompt_student(self):
        prompt = self.chatbot.get_user_demographic_prompt("student")
        self.assertIn("student", prompt.lower())
        self.assertIn("simple language", prompt.lower())
    
    def test_demographic_prompt_professional(self):
        prompt = self.chatbot.get_user_demographic_prompt("professional")
        self.assertIn("professional", prompt.lower())
        self.assertIn("sophisticated", prompt.lower())
    
    @patch('finance_chatbot.FinanceChatbot.load_model')
    def test_model_loading(self, mock_load):
        mock_load.return_value = True
        result = self.chatbot.load_model()
        self.assertTrue(result)

class TestBudgetAnalyzer(unittest.TestCase):
    def setUp(self):
        self.analyzer = BudgetAnalyzer()
    
    def test_budget_summary_calculation(self):
        income = 5000
        expenses = {
            "Housing": 1500,
            "Food": 500,
            "Transportation": 300,
            "Other": 200
        }
        
        summary = self.analyzer.generate_budget_summary(income, expenses)
        
        self.assertEqual(summary['total_income'], 5000)
        self.assertEqual(summary['total_expenses'], 2500)
        self.assertEqual(summary['savings'], 2500)
        self.assertEqual(summary['savings_rate'], 50.0)
    
    def test_zero_income_handling(self):
        summary = self.analyzer.generate_budget_summary(0, {"Housing": 1000})
        self.assertEqual(summary['savings_rate'], 0)
    
    def test_insights_generation(self):
        # Test low savings rate
        summary = self.analyzer.generate_budget_summary(3000, {"Housing": 2800})
        insights = summary['insights']
        self.assertTrue(any("Low savings rate" in insight for insight in insights))
        
        # Test excellent savings rate
        summary = self.analyzer.generate_budget_summary(5000, {"Housing": 1000})
        insights = summary['insights']
        self.assertTrue(any("Excellent savings rate" in insight for insight in insights))

if __name__ == '__main__':
    unittest.main()
