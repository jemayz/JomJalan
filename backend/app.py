from flask import Flask, jsonify, request
from flask_cors import CORS
from scraper import scrape_trending_spots
from ai_planner import get_ai_plan

app = Flask(__name__)
# This allows your Flutter app to access the backend.
CORS(app) 

@app.route('/')
def home():
    return "JomJalan Backend is running!"

@app.route('/api/trending_spots', methods=['GET'])
def get_trending_spots():
    """
    API endpoint to get the scraped trending spots.
    """
    spots = scrape_trending_spots()
    return jsonify(spots)

@app.route('/api/ai_planner', methods=['POST'])
def generate_ai_plan():
    """
    API endpoint to generate an AI travel plan.
    """
    # Get the 'prompt' from the JSON body of the request
    data = request.get_json()
    if not data or 'prompt' not in data:
        return jsonify({'error': 'No prompt provided'}), 400
        
    user_prompt = data['prompt']
    
    plan_text = get_ai_plan(user_prompt)
    
    # The 'text' key matches your Flutter app's chat bubble
    return jsonify({'role': 'ai', 'text': plan_text})

if __name__ == '__main__':
    # Runs the server on http://127.0.0.1:5000
    app.run(debug=True)
