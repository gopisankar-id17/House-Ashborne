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
st.title("💰 Personal Finance Chatbot")
st.caption("Get intelligent guidance on savings, taxes, and investments powered by IBM Granite AI")


user_type = st.sidebar.selectbox("Select your profile", ["Student", "Professional"])
st.sidebar.markdown("👤 The chatbot adapts tone & complexity to your profile automatically.")


if "messages" not in st.session_state:
    st.session_state.messages = []


for msg in st.session_state.messages:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])


prompt = st.chat_input("Ask me about savings, taxes, or investments...")
if prompt:
    
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

   
    system_prompt = (
        f"You are a helpful Personal Finance Assistant chatbot. "
        f"Provide clear, practical financial guidance on savings, taxes, and investments. "
        f"Adapt tone and complexity for a {user_type.lower()}."
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
