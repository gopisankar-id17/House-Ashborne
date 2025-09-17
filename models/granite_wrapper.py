from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
import torch
from typing import List, Dict, Any
import logging

logger = logging.getLogger(__name__)

class GraniteFinanceBot:
    def __init__(self, model_name: str = "ibm-granite/granite-3.0-2b-instruct"):
        self.model_name = model_name
        self.tokenizer = None
        self.model = None
        self.pipeline = None
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        
    def load_model(self) -> bool:
        """Load the Granite model and tokenizer"""
        try:
            logger.info(f"Loading model: {self.model_name}")
            
            self.tokenizer = AutoTokenizer.from_pretrained(self.model_name)
            self.model = AutoModelForCausalLM.from_pretrained(
                self.model_name,
                torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
                device_map="auto" if torch.cuda.is_available() else None
            )
            
            # Create pipeline for easier inference
            self.pipeline = pipeline(
                "text-generation",
                model=self.model,
                tokenizer=self.tokenizer,
                torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
                device=0 if torch.cuda.is_available() else -1
            )
            
            logger.info("Model loaded successfully")
            return True
            
        except Exception as e:
            logger.error(f"Error loading model: {e}")
            return False
    
    def generate_financial_advice(self, query: str, user_context: Dict[str, Any]) -> str:
        """Generate financial advice based on user query and context"""
        if not self.pipeline:
            return "Model not loaded. Please load the model first."
        
        # Build system prompt based on user context
        user_type = user_context.get('type', 'general')
        income = user_context.get('income', 0)
        
        system_prompt = self._build_system_prompt(user_type, income)
        
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": query}
        ]
        
        try:
            response = self.pipeline(
                messages,
                max_new_tokens=300,
                temperature=0.7,
                do_sample=True,
                pad_token_id=self.tokenizer.eos_token_id
            )
            
            return response[0]["generated_text"][-1]["content"]
            
        except Exception as e:
            logger.error(f"Error generating response: {e}")
            return f"I apologize, but I encountered an error: {str(e)}"
    
    def _build_system_prompt(self, user_type: str, income: int = 0) -> str:
        """Build system prompt based on user type"""
        base_prompt = """You are an expert personal finance advisor with deep knowledge of 
        savings, taxes, investments, and budgeting. Provide helpful, accurate, and actionable 
        financial advice. Always mention risks when discussing investments and suggest consulting 
        professionals for major decisions."""
        
        if user_type == "student":
            return f"""{base_prompt}
            
            You are speaking to a college student. Use simple language, focus on:
            - Basic budgeting and expense tracking
            - Student loan management
            - Building credit history
            - Part-time income optimization
            - Emergency fund basics
            Be encouraging and understanding of limited income."""
            
        elif user_type == "professional":
            return f"""{base_prompt}
            
            You are speaking to a working professional. Use sophisticated financial terminology:
            - Advanced investment strategies
            - Tax optimization techniques
            - Retirement planning (401k, IRA, etc.)
            - Career-related financial decisions
            - Estate planning basics
            Be thorough and analytical in your responses."""
        
        else:
            return f"""{base_prompt}
            
            Provide clear, balanced advice suitable for general audiences. Focus on:
            - Fundamental financial principles
            - Practical budgeting strategies
            - Basic investment concepts
            - Savings and debt management
            Adjust complexity based on the specific question asked."""