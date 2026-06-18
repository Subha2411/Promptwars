import firebase_admin
from firebase_admin import credentials, firestore

def main():
    try:
        cred = credentials.Certificate("serviceAccountKey.json")
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("Firebase initialized successfully.")
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        return

    print("Fetching documents from 'venues' collection...")
    docs = list(db.collection("venues").stream())
    print(f"Found {len(docs)} documents.")

    batch = db.batch()
    count = 0
    updated = 0

    for doc in docs:
        data = doc.to_dict()
        name = data.get("name", "")
        # If search_key is missing or not lowercase, update it
        if "search_key" not in data or data["search_key"] != name.lower():
            batch.update(doc.reference, {"search_key": name.lower()})
            count += 1
            updated += 1

            if count >= 400:
                print(f"Committing batch of {count} updates...")
                batch.commit()
                batch = db.batch()
                count = 0

    if count > 0:
        print(f"Committing final batch of {count} updates...")
        batch.commit()

    print(f"Successfully updated {updated} documents with 'search_key'.")

if __name__ == "__main__":
    main()
