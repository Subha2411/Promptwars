import json
import re
import requests
import firebase_admin
from firebase_admin import credentials, firestore

# Overpass API interpreter URL
OVERPASS_URL = "https://overpass-api.de/api/interpreter"

# Overpass QL Query to fetch stadiums, malls, and railway stations in Tamil Nadu
OVERPASS_QUERY = """
[out:json][timeout:120];
area["ISO3166-2"="IN-TN"]->.a;
(
  node["shop"="mall"](area.a);
  way["shop"="mall"](area.a);
  relation["shop"="mall"](area.a);
  
  node["railway"="station"](area.a);
  way["railway"="station"](area.a);
  relation["railway"="station"](area.a);
  
  node["leisure"="stadium"](area.a);
  way["leisure"="stadium"](area.a);
  relation["leisure"="stadium"](area.a);
);
out center;
"""

def fetch_osm_data():
    print("Fetching data from OpenStreetMap Overpass API (this may take a few seconds)...")
    headers = {
        'User-Agent': 'VenueIQImportScript/1.0 (contact@example.com)'
    }
    response = requests.post(OVERPASS_URL, data={"data": OVERPASS_QUERY}, headers=headers)
    response.raise_for_status()
    data = response.json()
    return data.get("elements", [])

def sanitize_slug(name):
    # Convert name to a lowercased slug for doc id
    slug = name.lower()
    slug = re.sub(r'[^a-z0-9\s-]', '', slug)
    slug = re.sub(r'[\s-]+', '_', slug)
    return slug.strip('_')

def get_venue_type(tags):
    if tags.get("shop") == "mall":
        return "mall"
    elif tags.get("railway") == "station":
        return "railwayStation"
    elif tags.get("leisure") == "stadium":
        return "stadium"
    return "unknown"

def get_coordinates(element):
    if "lat" in element and "lon" in element:
        return element["lat"], element["lon"]
    elif "center" in element:
        return element["center"].get("lat"), element["center"].get("lon")
    return None, None

def main():
    # 1. Fetch data from OSM
    try:
        elements = fetch_osm_data()
    except Exception as e:
        print(f"Error fetching data from OSM: {e}")
        return

    print(f"Fetched {len(elements)} elements from OpenStreetMap.")

    # 2. Initialize Firebase Admin SDK
    try:
        cred = credentials.Certificate("serviceAccountKey.json")
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("Firebase Admin SDK initialized successfully.")
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        return

    # 3. Process and Upload to Firestore
    uploaded_count = 0
    skipped_count = 0
    batch = db.batch()
    batch_count = 0

    for elem in elements:
        tags = elem.get("tags", {})
        name = tags.get("name")
        if not name:
            skipped_count += 1
            continue

        venue_type = get_venue_type(tags)
        if venue_type == "unknown":
            skipped_count += 1
            continue

        lat, lon = get_coordinates(elem)
        if lat is None or lon is None:
            skipped_count += 1
            continue

        slug = sanitize_slug(name)
        if not slug:
            skipped_count += 1
            continue

        # Map to proper labels
        capacity_map = {
            "stadium": "40,000",
            "mall": "25,000",
            "railwayStation": "60,000"
        }
        
        hint_map = {
            "stadium": "Enter Gate / Block (e.g. B-12)",
            "mall": "Enter your floor / wing (e.g. Ground, West)",
            "railwayStation": "Enter your platform or entry (e.g. Platform 1)"
        }

        button_map = {
            "stadium": "Enter Arena",
            "mall": "Navigate Mall",
            "railwayStation": "Navigate Station"
        }

        doc_data = {
            "id": slug,
            "name": name,
            "search_key": name.lower(),
            "subtitle": tags.get("addr:city", "Tamil Nadu") + ", India",
            "type": venue_type,
            "capacity": capacity_map[venue_type],
            "hintText": hint_map[venue_type],
            "buttonText": button_map[venue_type],
            "lat": lat,
            "lon": lon,
            "osm_id": elem.get("id")
        }

        doc_ref = db.collection("venues").document(slug)
        batch.set(doc_ref, doc_data, merge=True)
        batch_count += 1
        uploaded_count += 1

        # Firestore batches are limited to 500 operations
        if batch_count >= 400:
            print(f"Committing batch of {batch_count} venues...")
            batch.commit()
            batch = db.batch()
            batch_count = 0

    if batch_count > 0:
        print(f"Committing final batch of {batch_count} venues...")
        batch.commit()

    print("\n--- Summary ---")
    print(f"Total uploaded/merged venues: {uploaded_count}")
    print(f"Skipped elements (missing name, type, or coords): {skipped_count}")

if __name__ == "__main__":
    main()
