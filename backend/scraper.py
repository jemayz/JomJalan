import requests
from bs4 import BeautifulSoup
import time
from urllib.parse import urlparse # Used to check the domain

# --- NEW: URL mapping for different states ---
STATE_URLS = {
    'Kuala Lumpur': "https://klfoodie.com/date-spots-kl-wallet-friendly-free/",
    'Selangor': "https://ecentral.my/tempat-menarik-di-kl/",
    'Perak': "https://ecentral.my/tempat-menarik-di-ipoh/",
    'Penang': "https://ecentral.my/tempat-menarik-di-penang/",
    'Johor': "https://ecentral.my/tempat-menarik-di-johor-bahru/",
    'Sabah': "https://ecentral.my/tempat-menarik-di-kudat/",
    'Sarawak': "https://ecentral.my/aktiviti-menarik-di-kuching/",
    'Melaka': "https://ecentral.my/tempat-menarik-di-melaka/",
    'Negeri Sembilan': "https://ecentral.my/tempat-menarik-di-negeri-sembilan/",
    'Kedah': "https://ecentral.my/aktiviti-menarik-di-kedah/",
    'Pahang': "https://ecentral.my/tempat-menarik-di-pahang/",
    'Terengganu': "https://ecentral.my/tempat-menarik-terengganu/",
    'Kelantan': "https://ecentral.my/tempat-menarik-di-kota-bharu/",
    'Perlis': "https://ecentral.my/tempat-menarik-di-perlis/",
}

cache_data = {}
CACHE_DURATION = 3600  # 1 hour (in seconds)
# -------------------------------------------------

# --- NEW: Parser function for klfoodie.com ---
def _parse_klfoodie(content, state):
    """Blueprint for scraping klfoodie.com articles"""
    print("Using klfoodie parser...")
    spots = []
    all_name_tags = content.find_all('h2') # klfoodie uses h2
    
    for i, name_tag in enumerate(all_name_tags):
        full_text = name_tag.text.strip()
        parts = full_text.split('.', 1)
        
        if len(parts) > 1 and parts[0].isdigit():
            name = parts[1].strip()
            
            description_tag = name_tag.find_next_sibling('p')
            description = description_tag.text.strip() if description_tag else "No description."

            img_tag = None
            figure_tag = name_tag.find_next_sibling('figure')
            if figure_tag:
                img_tag = figure_tag.find('img')
                
            image_url = img_tag['src'] if (img_tag and 'src' in img_tag.attrs) else f"https://placehold.co/600x400/21a18e/white?text={name.replace(' ', '+')}"
            
            location = state
            if description_tag:
                location_tag = description_tag.find_next_sibling('p')
                if location_tag and 'Address:' in location_tag.text:
                    location = location_tag.text.replace("Address:", "").strip()

            spot = {
                'id': f'klfoodie_{state}_{i+1}', 'name': name, 'location': location,
                'description': description, 'imageUrl': image_url
            }
            spots.append(spot)
        else:
            print(f"Skipping junk/unformatted tag: {full_text}")
    return spots
# -----------------------------------------

# --- NEW: Parser function for ecentral.my (NOW FIXED) ---
def _parse_ecentral(content, state):
    """Blueprint for scraping ecentral.my articles"""
    print("Using ecentral.my parser...")
    spots = []
    
    # --- THIS IS YOUR FIX ---
    # Find all <h3> tags that have the class 'wp-block-heading'
    all_name_tags = content.find_all(['h3', 'h4'], class_='wp-block-heading')
    # ------------------------
    
    for i, name_tag in enumerate(all_name_tags):
        full_text = name_tag.text.strip()
        parts = full_text.split('.', 1)
        
        if len(parts) > 1 and parts[0].isdigit():
            name = parts[1].strip()
            
            description_tag = name_tag.find_next_sibling('p')
            description = description_tag.text.strip() if description_tag else "No description."

            img_tag = None
            # ecentral puts the image *before* the h3 tag
            # We use find_previous('img') to find the closest img tag before the h3
            img_tag = name_tag.find_previous('img')
                
            image_url = img_tag['src'] if (img_tag and 'src' in img_tag.attrs) else f"https://placehold.co/600x400/21a18e/white?text={name.replace(' ', '+')}"
            
            location = state
            # The location data is in a <p> tag that contains 'Lokasi:'
            location_tag = name_tag.find_next_sibling('p', string=lambda t: t and 'Lokasi:' in t)
            if location_tag:
                location = location_tag.text.replace("Lokasi:", "").strip()

            spot = {
                'id': f'ecentral_{state}_{i+1}', 'name': name, 'location': location,
                'description': description, 'imageUrl': image_url
            }
            spots.append(spot)
        else:
            print(f"Skipping junk/unformatted tag: {full_text}")
    return spots
# -----------------------------------------

# --- MASTER SCRAPER FUNCTION (Updated) ---
def scrape_trending_spots(state="Kuala Lumpur"):
    """
    Master scraper function. Selects the correct URL and parser based on the state.
    """
    current_time = time.time()
    
    URL = STATE_URLS.get(state, STATE_URLS['Kuala Lumpur'])
    if not URL:
        print(f"No URL defined for {state}. Skipping.")
        return []
        
    print(f"Scraper: Fetching URL: {URL}")

    # Check cache
    if state in cache_data and (current_time - cache_data[state]['last_updated'] < CACHE_DURATION):
        print(f"Returning data from cache for {state}...")
        return cache_data[state]['spots']

    print(f"Cache expired or empty for {state}. Scraping new data...")
    
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}
    
    try:
        response = requests.get(URL, headers=headers, timeout=10)
        response.raise_for_status() 
        soup = BeautifulSoup(response.text, 'html.parser')
        
        spots = []
        domain = urlparse(URL).netloc # Get domain (e.g., 'klfoodie.com')
        
        # --- NEW: Select the correct blueprint ---
        if 'klfoodie.com' in domain:
            content = soup.find('div', class_='entry-content')
            if content:
                spots = _parse_klfoodie(content, state)
            else:
                print("Could not find 'entry-content' on klfoodie.")
        
        elif 'ecentral.my' in domain:
            # --- THIS IS THE FIX (Thanks to your screenshot!) ---
            # The correct class for ecentral.my is 'brxe-post-content'
            content = soup.find('div', class_='brxe-post-content')
            # ----------------------------------------------------
            if content:
                spots = _parse_ecentral(content, state)
            else:
                # Update the error message to be correct
                print("Could not find 'brxe-post-content' on ecentral.")                
            
        # Update cache
        cache_data[state] = {'spots': spots, 'last_updated': current_time}
        print(f"Successfully scraped {len(spots)} spots for {state}.")
        return spots

    except requests.exceptions.RequestException as e:
        print(f"Error scraping website: {e}")
        return []
    except Exception as e:
        print(f"An error occurred during parsing: {e}")
        return []
# ------------------------------------

# Test the function
if __name__ == "__main__":
    print("--- Testing KL ---")
    spots_kl = scrape_trending_spots("Kuala Lumpur")
    if spots_kl:
        print(f"\n--- Found {len(spots_kl)} KL Spots ---")
    else:
        print("No KL spots were found.")
    
    print("\n--- Testing Perak (ecentral) ---")
    spots_perak = scrape_trending_spots("Perak")
    if spots_perak:
        print(f"\n--- Found {len(spots_perak)} Perak Spots ---")
    else:
        print("No Perak spots were found.")
        
    print("\n--- Testing Selangor (visitselangor) ---")
    spots_selangor = scrape_trending_spots("Selangor")
    if spots_selangor:
        print(f"\n--- Found {len(spots_selangor)} Selangor Spots ---")
    else:
        print("No Selangor spots were found (parser not built).")