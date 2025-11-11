import requests
from bs4 import BeautifulSoup
import time
from urllib.parse import urlparse # Used to check the domain

# --- NEW: URL mapping for different states ---
STATE_URLS = {
    'Kuala Lumpur': "https://klfoodie.com/date-spots-kl-wallet-friendly-free/",
    'Selangor': "https://www.visitselangor.com/topic/cultural-heritage/",
    'Perak': "https://ecentral.my/tempat-menarik-di-ipoh/",
    'Penang': "https://ecentral.my/tempat-menarik-di-penang/",
    'Johor': "https://ecentral.my/tempat-menarik-di-johor-bahru/",
    'Sabah': "https://www.klook.com/ms-MY/blog/tempat-semulajadi-sabah-cantik/",
    'Sarawak': "",
    'Melaka': "",
    'Negeri Sembilan': "",
    'Kedah': "",
    'Pahang': "",
    'Terengganu': "",
    'Kelantan': "",
    'Perlis': "",
}
# ---------------------------------------------


# --- Cache to avoid scraping on every API call ---
cache_data = {}
CACHE_DURATION = 3600  # 1 hour (in seconds)
# -------------------------------------------------

# --- NEW: Parser function for klfoodie.com ---
def _parse_klfoodie(content, state):
# ... (existing code) ...
    print("Using klfoodie parser...")
    spots = []
    all_name_tags = content.find_all('h2') # klfoodie uses h2
    
    for i, name_tag in enumerate(all_name_tags):
# ... (existing code) ...
        full_text = name_tag.text.strip()
        parts = full_text.split('.', 1)
        
        if len(parts) > 1 and parts[0].isdigit():
# ... (existing code) ...
            name = parts[1].strip()
            
            description_tag = name_tag.find_next_sibling('p')
# ... (existing code) ...
            description = description_tag.text.strip() if description_tag else "No description."

            img_tag = None
# ... (existing code) ...
            figure_tag = name_tag.find_next_sibling('figure')
            if figure_tag:
                img_tag = figure_tag.find('img')
                
# ... (existing code) ...
            image_url = img_tag['src'] if (img_tag and 'src' in img_tag.attrs) else f"https://placehold.co/600x400/21a18e/white?text={name.replace(' ', '+')}"
            
            location = state
# ... (existing code) ...
            if description_tag:
                location_tag = description_tag.find_next_sibling('p')
                if location_tag and 'Address:' in location_tag.text:
# ... (existing code) ...
                    location = location_tag.text.replace("Address:", "").strip()

            spot = {
# ... (existing code) ...
                'id': f'klfoodie_{state}_{i+1}', 'name': name, 'location': location,
                'description': description, 'imageUrl': image_url
            }
            spots.append(spot)
        else:
# ... (existing code) ...
            print(f"Skipping junk/unformatted tag: {full_text}")
    return spots
# -----------------------------------------

# --- NEW: Parser function for ecentral.my ---
def _parse_ecentral(content, state):
# ... (existing code) ...
    print("Using ecentral.my parser...")
    spots = []
    # ecentral uses h3 tags for its spot names
    all_name_tags = content.find_all('h3')
    
    for i, name_tag in enumerate(all_name_tags):
# ... (existing code) ...
        full_text = name_tag.text.strip()
        parts = full_text.split('.', 1)
        
        if len(parts) > 1 and parts[0].isdigit():
# ... (existing code) ...
            name = parts[1].strip()
            
            description_tag = name_tag.find_next_sibling('p')
# ... (existing code) ...
            description = description_tag.text.strip() if description_tag else "No description."

            img_tag = None
# ... (existing code) ...
            # ecentral puts the image *before* the h3 tag
            figure_tag = name_tag.find_previous_sibling('figure')
            if figure_tag:
# ... (existing code) ...
                img_tag = figure_tag.find('img')
                
            image_url = img_tag['src'] if (img_tag and 'src' in img_tag.attrs) else f"https://placehold.co/600x400/21a18e/white?text={name.replace(' ', '+')}"
            
# ... (existing code) ...
            location = state
            if description_tag:
                location_tag = description_tag.find_next_sibling('p')
# ... (existing code) ...
                if location_tag and 'Lokasi:' in location_tag.text:
                    location = location_tag.text.replace("Lokasi:", "").strip()

            spot = {
# ... (existing code) ...
                'id': f'ecentral_{state}_{i+1}', 'name': name, 'location': location,
                'description': description, 'imageUrl': image_url
            }
            spots.append(spot)
        else:
# ... (existing code) ...
            print(f"Skipping junk/unformatted tag: {full_text}")
    return spots
# -----------------------------------------

# --- MASTER SCRAPER FUNCTION (Updated) ---
def scrape_trending_spots(state="Kuala Lumpur"):
# ... (existing code) ...
    current_time = time.time()
    
    URL = STATE_URLS.get(state, STATE_URLS['Kuala Lumpur'])
# ... (existing code) ...
    if not URL:
        print(f"No URL defined for {state}. Skipping.")
        return []
        
# ... (existing code) ...
    print(f"Scraper: Fetching URL: {URL}")

    # Check cache
    if state in cache_data and (current_time - cache_data[state]['last_updated'] < CACHE_DURATION):
# ... (existing code) ...
        print(f"Returning data from cache for {state}...")
        return cache_data[state]['spots']

    print(f"Cache expired or empty for {state}. Scraping new data...")
# ... (existing code) ...
    
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}
    
    try:
# ... (existing code) ...
        response = requests.get(URL, headers=headers, timeout=10)
        response.raise_for_status() 
        soup = BeautifulSoup(response.text, 'html.parser')
# ... (existing code) ...
        
        spots = []
        domain = urlparse(URL).netloc # Get domain (e.g., 'klfoodie.com')
        
# ... (existing code) ...
        # --- NEW: Select the correct blueprint ---
        if 'klfoodie.com' in domain:
            content = soup.find('div', class_='entry-content')
            if content:
# ... (existing code) ...
                spots = _parse_klfoodie(content, state)
            else:
                print("Could not find 'entry-content' on klfoodie.")
        
        elif 'ecentral.my' in domain:
            # --- THIS IS THE FIX ---
            # The correct class for ecentral.my is 'td-post-content'
            content = soup.find('div', class_='td-post-content')
            # -----------------------
            if content:
                spots = _parse_ecentral(content, state)
            else:
                print("Could not find 'td-post-content' on ecentral.")
        
        elif 'visitselangor.com' in domain:
# ... (existing code) ...
            # TODO: You would need to write a new parser for this site.
            print("visitselangor.com parser is not built yet.")
            pass # Returns empty list
            
# ... (existing code) ...
        elif 'klook.com' in domain:
            # TODO: Klook is very hard to scrape and would fail.
            print("Klook.com is protected and cannot be scraped easily.")
# ... (existing code) ...
            pass # Returns empty list
        # -----------------------------------------
            
        # Update cache
# ... (existing code) ...
        cache_data[state] = {'spots': spots, 'last_updated': current_time}
        print(f"Successfully scraped {len(spots)} spots for {state}.")
        return spots

# ... (existing code) ...
    except requests.exceptions.RequestException as e:
        print(f"Error scraping website: {e}")
        return []
    except Exception as e:
# ... (existing code) ...
        print(f"An error occurred during parsing: {e}")
        return []
# ------------------------------------

# Test the function
if __name__ == "__main__":
# ... (existing code) ...
    print("--- Testing KL ---")
    spots_kl = scrape_trending_spots("Kuala Lumpur")
    if spots_kl:
# ... (existing code) ...
        print(f"\n--- Found {len(spots_kl)} KL Spots ---")
    else:
        print("No KL spots were found.")
    
# ... (existing code) ...
    print("\n--- Testing Penang (ecentral) ---")
    spots_penang = scrape_trending_spots("Penang")
    if spots_penang:
# ... (existing code) ...
        print(f"\n--- Found {len(spots_penang)} Penang Spots ---")
    else:
        print("No Penang spots were found.")
        
# ... (existing code) ...
    print("\n--- Testing Selangor (visitselangor) ---")
    spots_selangor = scrape_trending_spots("Selangor")
    if spots_selangor:
# ... (existing code) ...
        print(f"\n--- Found {len(spots_selangor)} Selangor Spots ---")
    else:
        print("No Selangor spots were found (parser not built).")