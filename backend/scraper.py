import requests
from bs4 import BeautifulSoup
import time
import re  # <-- Import Regular Expressions for finding the price

# --- Cache to avoid scraping on every API call ---
# This is a simple in-memory cache.
cache_data = {
    'spots': None,
    'last_updated': 0
}
CACHE_DURATION = 3600  # 1 hour (in seconds)
# -------------------------------------------------

def scrape_trending_spots():
    """
    Scrapes KL Foodie for trending spots.
    Uses a simple cache to avoid rate-limiting.
    """
    current_time = time.time()
    
    if cache_data['spots'] and (current_time - cache_data['last_updated'] < CACHE_DURATION):
        print("Returning data from cache...")
        return cache_data['spots']

    print("Cache expired or empty. Scraping new data...")
    
    # We must send a User-Agent header to pretend we are a real browser
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }
    URL = "https://klfoodie.com/date-spots-kl-wallet-friendly-free/"
    
    try:
        response = requests.get(URL, headers=headers)
        response.raise_for_status()

        soup = BeautifulSoup(response.text, 'html.parser')
        
        # This is the main content area of the article
        content = soup.find('div', class_='entry-content')
        
        if not content:
            print("Could not find the main content block 'entry-content'. The website layout may have changed.")
            return []

        all_name_tags = content.find_all('h2')
        
        spots = []
        
        for i, name_tag in enumerate(all_name_tags):
            
            full_text = name_tag.text.strip()
            parts = full_text.split('.', 1)
            
            if len(parts) > 1 and parts[0].isdigit():
                
                # --- NEW: Extract Price ---
                price_match = re.search(r'\((.*?)\)', full_text)
                price = price_match.group(1) if price_match else "Free Entry" # Get text in ( )
                
                # --- NEW: Clean the name (remove price) ---
                name_no_price = re.sub(r'\((.*?)\)', '', parts[1]) # Remove ( )
                name = name_no_price.strip()

                description_tag = name_tag.find_next_sibling('p')
                description = description_tag.text.strip() if description_tag else "No description available."

                img_tag = None
                figure_tag = name_tag.find_next_sibling('figure')
                if figure_tag:
                    img_tag = figure_tag.find('img')
                image_url = img_tag['src'] if img_tag else f"https://placehold.co/600x400/21a18e/white?text={name.replace(' ', '+')}"
                
                # --- NEW: Find Address and Hours ---
                address = "No address available."
                operating_hours = "No hours available."
                
                # We will look through the next few <p> tags
                next_element = description_tag.find_next_sibling()
                while next_element and next_element.name == 'p':
                    p_text = next_element.text.strip()
                    if p_text.startswith("Address:"):
                        address = p_text.replace("Address:", "").strip()
                    elif p_text.startswith("Operating Hours:"):
                        operating_hours = p_text.replace("Operating Hours:", "").strip()
                    next_element = next_element.find_next_sibling()

                # Match the JSON structure of your Flutter app
                spot = {
                    'id': f'klfoodie_date_{i+1}',
                    'name': name,
                    'location': "Kuala Lumpur", # General location
                    'description': description,
                    'imageUrl': image_url,
                    'address': address,          # <-- NEW
                    'operatingHours': operating_hours, # <-- NEW
                    'price': price               # <-- NEW
                }
                spots.append(spot)
            
            else:
                # This is a junk tag (like "Which Spot Are You...")
                print(f"Skipping junk/unformatted tag: {full_text}")
                continue

        
        # Update cache
        cache_data['spots'] = spots
        cache_data['last_updated'] = current_time
        
        print(f"Successfully scraped {len(spots)} spots.")
        return spots

    except requests.exceptions.RequestException as e:
        print(f"Error scraping website: {e}")
        return [] # Return an empty list on failure
    except Exception as e:
        print(f"An error occurred during parsing: {e}")
        return []

# Test the function
if __name__ == "__main__":
    spots = scrape_trending_spots()
    if spots:
        print("\n--- SCRAPED SPOTS ---")
        for s in spots:
            # Test our new fields
            print(f"Name: {s['name']}, Price: {s['price']}, Address: {s['address'][:30]}...")
    else:
        print("No spots were found.")