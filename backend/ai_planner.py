import google.generativeai as genai
import os
from dotenv import load_dotenv

# --- FIX: Tell load_dotenv to look one folder up for the .env file ---
load_dotenv(dotenv_path='../.env') 
# ------------------------------

try:
    # --- Get the key from the .env file ---
    GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
    if not GEMINI_API_KEY:
        raise ValueError("GEMINI_API_KEY not found. Please check your .env file.")
    # -------------------------------------------
        
    genai.configure(api_key=GEMINI_API_KEY)
    
    # Set up the model
    generation_config = {
      "temperature": 1,
      "top_p": 0.95,
      "top_k": 0,
      "max_output_tokens": 8192,
    }
    
    safety_settings = [
      {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
      {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
      {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
      {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
    ]
    
    model = genai.GenerativeModel(
        model_name="gemini-2.5-flash",
        generation_config=generation_config,
        safety_settings=safety_settings
    )
    
    print("Gemini AI Model initialized successfully.")

except Exception as e:
    print(f"Error initializing Gemini AI: {e}")
    model = None

# --- FIX: Simplified to take just the user prompt ---
def get_ai_plan(user_prompt):
    """
    Calls the Gemini AI to generate a travel plan.
    """
    if not model:
        return "Error: AI Model is not initialized. Please check your API key and backend logs."

    # This is the "prompt" we send to the AI
    # We pass the user's prompt directly into our system prompt
    prompt = f"""
    Act as a friendly Malaysian travel guide. 
    A user wants a simple, bulleted itinerary based on their request. 
    Provide 3-5 recommendations.
    
    User Request: "{user_prompt}"
    
    Format your response in simple text, using bullet points.
    """
    
    try:
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        print(f"Error generating AI content: {e}")
        return f"Error communicating with AI: {e}"