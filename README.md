# Personal Finance Chatbot

An intelligent conversational AI system powered by IBM's Granite 3.0 model that provides personalized financial guidance for savings, taxes, and investments.

## Features

- **Personalized Financial Guidance**: Customized advice based on user profiles
- **AI-Generated Budget Summaries**: Automatic budget analysis and insights
- **Spending Insights**: Actionable recommendations for expense optimization
- **Demographic-Aware Communication**: Adapts tone for students vs professionals
- **Interactive Visualizations**: Charts and graphs for better understanding

## Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/personal-finance-chatbot.git
cd personal-finance-chatbot
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Run the application:
```bash
streamlit run finance_chatbot.py
```

## Usage

1. **Profile Setup**: Select your demographic (Student/Professional) in the sidebar
2. **Load Model**: Click "Load Granite Model" to initialize the AI
3. **Chat Interface**: Ask questions about finances, investments, or budgeting
4. **Budget Analysis**: Input your income and expenses for detailed analysis
5. **Investment Insights**: Get personalized investment recommendations

## Model Information

This project uses IBM's Granite 3.0-2B Instruct model:
- Model: `ibm-granite/granite-3.0-2b-instruct`
- Size: 2 billion parameters
- Optimized for instruction following and conversational AI

## Technologies Used

- **Python**: Core programming language
- **Streamlit**: Web application framework
- **Transformers**: Hugging Face transformers library
- **PyTorch**: Deep learning framework
- **Plotly**: Interactive visualizations
- **Pandas**: Data manipulation and analysis

## Project Structure

```
finance_chatbot.py          # Main Streamlit application
utils/                      # Utility functions
models/                     # Model wrapper classes
assets/                     # Data files and resources
tests/                      # Unit tests
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer

This chatbot is for educational and informational purposes only. Always consult with qualified financial professionals before making major financial decisions.