import google.generativeai as genai
import os
from dotenv import load_dotenv

# --- Load environment variables from .env file ---
load_dotenv()

# Get the API key from environment variable
api_key = os.getenv("GEMINI_API_KEY")

try:
    genai.configure(api_key=api_key)
except Exception as e:
    print(f"Error configuring AI. Did you set your API key? Error: {e}")

# System instruction for the AI model
SYSTEM_INSTRUCTION = (
    "You are 'JomJalan', a friendly and expert Malaysian travel assistant. "
    "A user is asking for a travel plan. "
    "Your response must be in Markdown format, easy to read, and exciting. "
    "Generate a travel itinerary based on the user's prompt (destination, budget, interests). "
    "Use bullet points for days and activities."
)

def get_ai_plan(user_prompt):
    """
    Generates a travel plan using the Gemini AI.
    """
    try:
        model = genai.GenerativeModel(
            model_name='gemini-2.5-flash-preview-09-2025',
            system_instruction=SYSTEM_INSTRUCTION
        )
        
        response = model.generate_content(user_prompt)
        return response.text
        
    except Exception as e:
        print(f"Error generating AI response: {e}")
        return "Sorry, I couldn't generate a plan right now. Please try again later."
