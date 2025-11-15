import google.generativeai as genai
import os
from dotenv import load_dotenv
import json
from tavily import TavilyClient

# --- Load API Key ---
load_dotenv(dotenv_path='../.env')
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
TAVILY_API_KEY = os.getenv('TAVILY_API_KEY')

if not GEMINI_API_KEY or not TAVILY_API_KEY:
    print("Warning: GEMINI_API_KEY or TAVILY_API_KEY not found in .env file.")
    model = None
    tavily_client = None
else:
    genai.configure(api_key=GEMINI_API_KEY)
    
    # --- Model Configuration ---
    generation_config = {
      "temperature": 1,
      "top_p": 0.95,
      "top_k": 64,
      "max_output_tokens": 8192,
      # --- CRITICAL: Force JSON output ---
      "response_mime_type": "application/json", 
    }
    
    safety_settings = [
      {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
      {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
      {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
      {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
    ]
    
    # --- This is the "System Instruction" for your "Agents" ---
    SYSTEM_INSTRUCTION = """
    You are 'JomJalan', an expert Malaysian travel guide.
    Your goal is to act in two steps:
    1.  **Survey Agent:** First, you MUST use the Google Search tool to find the BEST 3-5 trending, highly-rated, or 'hidden gem' spots (cafes, attractions, etc.) for the user's request.
    2.  **Planner Agent:** Second, you MUST create a simple, day-by-day itinerary using those search results.
    
    **CRITICAL RULES:**
    * You MUST respond in a fun, friendly, 'Manglish' style (e.g., "Can do, lah!", "Aiyo...").
    * You MUST bold key place names using **markdown**.
    * You MUST return your final plan in the provided JSON schema.
    
    **JSON Schema:**
    {
      "type": "object",
      "properties": {
        "friendly_response": {
          "type": "string",
          "description": "Your friendly, Manglish chat response. This is what the user will read first."
        },
        "itinerary_days": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "day": { "type": "string", "description": "e.g., 'Day 1'" },
              "title": { "type": "string", "description": "A short title for the day, e.g., 'Heritage & Food'" },
              "activities": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "name": { "type": "string", "description": "The name of the place, e.g., 'Ipoh Old Town'" },
                    "description": { "type": "string", "description": "A short, 1-2 sentence description." }
                  },
                  "required": ["name", "description"]
                }
              }
            },
            "required": ["day", "title", "activities"]
          }
        }
      },
      "required": ["friendly_response", "itinerary_days"]
    }
    """

    try:
        model = genai.GenerativeModel(
            model_name="gemini-2.5-flash", # Use a model that supports Google Search
            generation_config=generation_config,
            safety_settings=safety_settings,
            system_instruction=SYSTEM_INSTRUCTION,           
        )
        tavily_client = TavilyClient(api_key=TAVILY_API_KEY)
        print("Gemini AI Model (with Search & JSON) initialized successfully.")
    except Exception as e:
        print(f"Error initializing services: {e}")
        model = None
        tavily_client = None
        
def get_ai_plan(user_prompt):
    """
    Calls Tavily (Survey Agent) and then Gemini (Planner Agent)
    """
    if not model or not tavily_client:
        return json.dumps({"friendly_response": "Aiyo, my AI brain is offline! The API Keys are missing or invalid."})

    try:
        # --- AGENT 1: SURVEY (Tavily) ---
        print(f"AI Planner: Activating Survey Agent (Tavily) for: {user_prompt}")
        # Create a good search query for Tavily
        search_query = f"best trending travel spots, attractions, and food for: {user_prompt}"
        
        search_results = tavily_client.search(
            query=search_query,
            search_depth="basic",
            max_results=5 # Get the top 5 results
        )
        
        # Format the search results as a simple string for Gemini
        context_string = ""
        for result in search_results.get('results', []):
            context_string += f"- {result['content']} (Source: {result['url']})\n"
        
        if not context_string:
            context_string = "No search results found."
            
        print("AI Planner: Survey complete. Context found.")
        # ----------------------------------

        # --- AGENT 2: PLANNER (Gemini) ---
        print("AI Planner: Activating Planner Agent (Gemini)...")
        
        # We "stuff" the search results into the prompt for the Planner Agent
        prompt = f"""
        User Request: "{user_prompt}"
        
        Survey Agent's Research (Context):
        {context_string}
        
        Please act as the 'JomJalan' Planner Agent. Use the context above to create a fun, friendly itinerary. Respond ONLY with the JSON schema.
        """
        
        response = model.generate_content(prompt)
        print("Gemini response received!")
        return response.text
        # ---------------------------------
        
    except Exception as e:
        print(f"Error during AI plan generation: {e}")
        return json.dumps({"friendly_response": f"Aiyo, something went wrong with the AI! Error: {str(e)}"})