from flask import Flask, jsonify, request
from flask_cors import CORS
import os
from dotenv import load_dotenv
import requests # Make sure 'requests' is in your requirements.txt
import json

# Import our other files
from scraper import scrape_trending_spots
from ai_planner import get_ai_plan

# --- FIX: Tell load_dotenv to look one folder up for the .env file ---
load_dotenv(dotenv_path='../.env')

app = Flask(__name__)
CORS(app) # Allow requests from our Flutter app

# --- FIX: Get the new SERVER_MAPS_KEY (removed the typo 'SERVERH_') ---
GOOGLE_MAPS_API_KEY = os.getenv('SERVERH_MAPS_KEY')
if not GOOGLE_MAPS_API_KEY:
    print("Warning: SERVER_MAPS_KEY not found in .env file. API calls will fail.")
# -----------------------------------------------------------------

# --- NEW HELPER FUNCTION ---
def get_place_details(place_name):
    """
    Uses Google Places 'Find Place' API to get details for a given place name.
    """
    if not GOOGLE_MAPS_API_KEY:
        return {} # Return empty if no key

    FIND_PLACE_URL = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
    
    # We ask for name, rating, user_ratings_total, and price_level
    params = {
        "input": place_name,
        "inputtype": "textquery",
        "fields": "name,rating,user_ratings_total,price_level",
        "key": GOOGLE_MAPS_API_KEY
    }
    
    try:
        response = requests.get(FIND_PLACE_URL, params=params)
        data = response.json()
        
        if data.get('status') == 'OK' and data.get('candidates'):
            # Return the first and best match
            return data.get('candidates')[0] 
        else:
            return {}
    except Exception as e:
        print(f"Error getting place details for {place_name}: {e}")
        return {}
# ----------------------------

@app.route('/api/trending_spots', methods=['GET'])
def trending_spots():
# ... (existing code) ...
    state = request.args.get('state', 'Kuala Lumpur')
    
    print(f"Flask: Received request for trending spots in {state}")
    
# ... (existing code) ...
    spots = scrape_trending_spots(state) 
    
    # 3. Enrich the spots with Google data
# ... (existing code) ...
    if not GOOGLE_MAPS_API_KEY:
# ... (existing code) ...
        return jsonify(spots) # Return non-enriched spots if key is missing
    enriched_spots = []
    for spot in spots:
        try:
            find_place_url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
            params = {
                # Use a more specific query for better matches
                "input": f"{spot['name']} {state}",
                "inputtype": "textquery",
                # --- THIS IS THE FIX ---
                # 'vicinity' is not a valid field. Use 'formatted_address' instead.
                "fields": "place_id,rating,user_ratings_total,price_level,photos,formatted_address",
                # -----------------------
                "key": GOOGLE_MAPS_API_KEY
            }
            response = requests.get(find_place_url, params=params)
            data = response.json()
            
            # This debug line is still helpful
            print(f"[Google Places Response for {spot['name']}]: {data}")

            if data.get('status') == 'OK' and data.get('candidates'):
                candidate = data['candidates'][0]
                spot['rating'] = candidate.get('rating', 0.0)
                spot['user_ratings_total'] = candidate.get('user_ratings_total', 0)
                spot['priceLevel'] = candidate.get('price_level') # Can be null
                
                # --- THIS IS THE FIX ---
                # Get 'formatted_address' instead of 'vicinity'
                spot['location'] = candidate.get('formatted_address', spot['location']) 
                # -----------------------
                
                # Get a photo URL
                if candidate.get('photos'):
# ... (existing code) ...
                    photo_ref = candidate['photos'][0]['photo_reference']
                    spot['imageUrl'] = f"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference={photo_ref}&key={GOOGLE_MAPS_API_KEY}"
                    # --- ADD THIS DEBUG PRINT ---
                    print(f"DEBUG IMAGE URL: {spot['imageUrl']}")
            enriched_spots.append(spot)
            
# ... (rest of file is unchanged) ...
        except Exception as e:
            print(f"Error enriching spot {spot['name']}: {e}")
            enriched_spots.append(spot) # Add the original spot if enrichment fails

    return jsonify(enriched_spots)

# --- Endpoint 2: AI Planner ---
@app.route('/api/ai_planner', methods=['POST'])
def ai_planner():
    data = request.json
    user_prompt = data.get('prompt')
    if not user_prompt:
        return jsonify({"error": "No prompt provided"}), 400

    print(f"Flask: Received AI plan request: {user_prompt}")
    
    # 1. Get the JSON *string* from the AI planner
    json_string_plan = get_ai_plan(user_prompt)
    
    try:
        # 2. Convert the JSON string into a real Python dictionary
        dict_plan = json.loads(json_string_plan)
        
        # 3. Return the dictionary, which Flask will correctly jsonify
        return jsonify(dict_plan)
    except Exception as e:
        print(f"Error parsing AI JSON response: {e}")
        # If parsing fails, send the raw text back as a fallback
        return jsonify({"friendly_response": json_string_plan})

# --- Endpoint 3: Find Place (For the search bar) ---
@app.route('/api/find_place', methods=['GET'])
def find_place():
# ... (rest of this function is unchanged) ...
    query = request.args.get('query')
    if not query or not GOOGLE_MAPS_API_KEY:
        return jsonify({"error": "Missing query or server API key"}), 400
    
    FIND_PLACE_URL = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
    
    params = {
        "input": query,
        "inputtype": "textquery",
        "fields": "place_id,name,formatted_address,photos", # We only need the lat/lng
        "key": GOOGLE_MAPS_API_KEY
    }
    
    try:
        response = requests.get(FIND_PLACE_URL, params=params)
        data = response.json()
        print("[Google Find Place Response]:", data)
        
        if data.get('status') == 'OK' and data.get('candidates'):
            candidate = data['candidates'][0]
            
            # --- THIS IS THE FIX ---
            # Build the image URL and get the location
            imageUrl = "https://placehold.co/400x400/0f2027/b2dfdb?text=No+Image"
            if candidate.get('photos'):
                photo_ref = candidate['photos'][0]['photo_reference']
                imageUrl = f"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference={photo_ref}&key={GOOGLE_MAPS_API_KEY}"
            
            location = candidate.get('formatted_address', 'No address found')
            
            return jsonify({
                "status": "OK", 
                "imageUrl": imageUrl, 
                "location": location,  
                
            })
            
        else:
            return jsonify({"status": data.get('status'), "error_message": data.get('error_message')})
            
    except requests.exceptions.RequestException as e:
        print(f"Error calling Find Place API: {e}")
        return jsonify({"error": str(e)}), 500
    
# --- Endpoint 4: Nearby Places (For categories) ---
@app.route('/api/nearby_places', methods=['GET'])
def nearby_places():
# ... (rest of this function is unchanged) ...
    lat = request.args.get('lat')
    lng = request.args.get('lng')
    category = request.args.get('category') 

    if not all([lat, lng, category, GOOGLE_MAPS_API_KEY]):
        return jsonify({"error": "Missing parameters or server API key"}), 400

    PLACES_API_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    
    params = {
        "location": f"{lat},{lng}",
        "radius": 5000, # 5km radius
        "type": category.lower(),
        "key": GOOGLE_MAPS_API_KEY
        # By removing 'fields', we get all data (photos, rating, etc.)
    }

    try:
        response = requests.get(PLACES_API_URL, params=params)
        data = response.json()
        
        print(f"[Google Nearby Response]: {data}")
        
        places = []
        if data.get('status') == 'OK':
            for result in data.get('results', []):
                
                # --- THIS IS THE FIX ---
                # 1. Get the photo reference, if it exists
                photo_ref = None
                if result.get('photos'):
                    photo_ref = result.get('photos')[0].get('photo_reference')
                
                # 2. Build the full photo URL
                image_url = "https://placehold.co/400x400/0f2027/b2dfdb?text=No+Image" # Placeholder
                if photo_ref:
                    image_url = f"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference={photo_ref}&key={GOOGLE_MAPS_API_KEY}"
                
                # 3. Add the new data to our response
                places.append({
                    "name": result.get('name'),
                    "lat": result.get('geometry', {}).get('location', {}).get('lat'),
                    "lng": result.get('geometry', {}).get('location', {}).get('lng'),
                    "vicinity": result.get('vicinity'), # The address
                    "rating": result.get('rating', 0),  # The star rating
                    "user_ratings_total": result.get('user_ratings_total', 0), # Total reviews
                    "imageUrl": image_url # The new, full image URL
                })
                # -----------------------------------------------------
        
        return jsonify(places) # Return the list (even if empty)

    except requests.exceptions.RequestException as e:
        print(f"Error calling Places API: {e}")
        return jsonify({"error": str(e)}), 500
# ------------------------------------
@app.route('/api/search_place', methods=['GET'])
def search_place():
    query = request.args.get('query')
    if not query or not GOOGLE_MAPS_API_KEY:
        return jsonify({"error": "Missing query or server API key"}), 400
    
    FIND_PLACE_URL = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
    
    params = {
        "input": query,
        "inputtype": "textquery",
        # --- CRITICAL FIX: Added 'geometry' here ---
        # We need 'geometry' to get lat/lng. We also get photos and address.
        "fields": "place_id,name,formatted_address,photos,geometry", 
        "key": GOOGLE_MAPS_API_KEY
    }
    
    try:
        response = requests.get(FIND_PLACE_URL, params=params)
        data = response.json()
        print(f"[Google Search Place Response]: {data}")
        
        if data.get('status') == 'OK' and data.get('candidates'):
            candidate = data['candidates'][0]
            
            # 1. Extract Lat/Lng (Geometry)
            # This allows the Flutter map to actually move to the location
            geometry = candidate.get('geometry', {})
            location_coords = geometry.get('location') # Returns {'lat': 123.45, 'lng': 67.89}

            # 2. Build Image URL
            imageUrl = "https://placehold.co/400x400/0f2027/b2dfdb?text=No+Image"
            if candidate.get('photos'):
                photo_ref = candidate['photos'][0]['photo_reference']
                imageUrl = f"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference={photo_ref}&key={GOOGLE_MAPS_API_KEY}"
            
            # 3. Get formatted address
            formatted_address = candidate.get('formatted_address', 'No address found')
            
            return jsonify({
                "status": "OK", 
                "name": candidate.get('name'),
                "imageUrl": imageUrl, 
                "location": location_coords, # This sends the {lat, lng} object
                "formatted_address": formatted_address
            })
            
        else:
            return jsonify({"status": data.get('status'), "error_message": data.get('error_message')})
            
    except requests.exceptions.RequestException as e:
        print(f"Error calling Find Place API: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)