from flask import Flask, jsonify, request
from flask_cors import CORS
import os
from dotenv import load_dotenv
import requests # Make sure 'requests' is in your requirements.txt

# Import our other files
from scraper import scrape_trending_spots
from ai_planner import get_ai_plan

# --- FIX: Tell load_dotenv to look one folder up for the .env file ---
load_dotenv(dotenv_path='../.env')

app = Flask(__name__)
CORS(app) # Allow requests from our Flutter app

# --- FIX: Get the new SERVER_MAPS_KEY --- (Tukau nama key)
GOOGLE_MAPS_API_KEY = os.getenv('SERVERH_MAPS_KEY')
if not GOOGLE_MAPS_API_KEY:
    print("Warning: SERVER_MAPS_KEY not found in .env file. /api/nearby_places will not work.")

# --- Existing Endpoints ---
@app.route('/api/trending_spots', methods=['GET'])
def trending_spots():
    spots = scrape_trending_spots()
    return jsonify(spots)

@app.route('/api/ai_planner', methods=['POST'])
def ai_planner():
    data = request.json
    plan = get_ai_plan(data.get('prompt')) 
    return jsonify({"plan": plan})

@app.route('/api/find_place', methods=['GET'])
def find_place():
    query = request.args.get('query')
    if not query or not GOOGLE_MAPS_API_KEY:
        return jsonify({"error": "Missing query or server API key"}), 400
    
    FIND_PLACE_URL = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
    
    params = {
        "input": query,
        "inputtype": "textquery",
        "fields": "geometry",
        "key": GOOGLE_MAPS_API_KEY
    }
    
    try:
        response = requests.get(FIND_PLACE_URL, params=params)
        data = response.json()
        
        print("[Google Find Place Response]:", data)
        
        if data.get('status') == 'OK' and data.get('candidates'):
            location = data['candidates'][0]['geometry']['location']
            return jsonify({"status": "OK", "location": location})
        else:
            return jsonify({"status": data.get('status'), "error_message": data.get('error_message')})
            
    except requests.exceptions.RequestException as e:
        print(f"Error calling Find Place API: {e}")
        return jsonify({"error": str(e)}), 500

# --- NEW ENDPOINT FOR GOOGLE PLACES ---
@app.route('/api/nearby_places', methods=['GET'])
def nearby_places():
    lat = request.args.get('lat')
    lng = request.args.get('lng')
    category = request.args.get('category') 

    if not all([lat, lng, category, GOOGLE_MAPS_API_KEY]):
        return jsonify({"error": "Missing parameters or server API key"}), 400

    PLACES_API_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    
    params = {
        "location": f"{lat},{lng}",
        "radius": 5000, 
        "type": category.lower(),
        "key": GOOGLE_MAPS_API_KEY
    }

    try:
        response = requests.get(PLACES_API_URL, params=params)
        response.raise_for_status() 
        data = response.json()
        
        # --- THIS IS THE NEW DEBUG LINE ---
        print(f"[Google Places Response]: {data}")
        # ----------------------------------
        
        places = []
        for result in data.get('results', []):
            places.append({
                "name": result.get('name'),
                "lat": result.get('geometry', {}).get('location', {}).get('lat'),
                "lng": result.get('geometry', {}).get('location', {}).get('lng'),
            })
            
        return jsonify(places)

    except requests.exceptions.RequestException as e:
        print(f"Error calling Places API: {e}")
        return jsonify({"error": str(e)}), 500
# ------------------------------------

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)