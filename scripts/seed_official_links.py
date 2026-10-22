#!/usr/bin/env python3
"""
Seed & Sync Script for Official Guide Links in Firebase Firestore (Cost $0)
===========================================================================
This script reads all 12 guides from assets/data/guides_data.json,
generates the seed JSON for the 'official_links' collection, and can
populate or sync Firestore documents either via Admin SDK or REST API.
"""

import os
import sys
import json
from datetime import datetime, timezone

def generate_seed():
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    guides_path = os.path.join(root_dir, 'assets', 'data', 'guides_data.json')
    seed_path = os.path.join(root_dir, 'assets', 'data', 'official_links_seed.json')

    if not os.path.exists(guides_path):
        print(f"Error: Could not find {guides_path}")
        sys.exit(1)

    with open(guides_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    guides = data.get('guides', {})
    now_iso = datetime.now(timezone.utc).isoformat()
    seed_data = {}

    for gid, g in guides.items():
        doc = {
            'categoryId': gid,
            'updatedAt': now_iso,
            'steps': {},
            'comparisons': {}
        }
        
        for s in g.get('steps', []):
            snum = str(s.get('number', s.get('stepNumber', '')))
            doc['steps'][snum] = {
                'officialUrl': s.get('officialUrl', ''),
                'officialUrlLabel': s.get('officialUrlLabel', ''),
                'officialUrlLabelEn': s.get('officialUrlLabelEn', '')
            }
            
        for c in g.get('comparisons', []):
            cid = c.get('id', '')
            doc['comparisons'][cid] = {
                'officialUrl': c.get('officialUrl', ''),
                'officialUrlLabel': c.get('officialUrlLabel', ''),
                'officialUrlLabelEn': c.get('officialUrlLabelEn', '')
            }
            
        seed_data[gid] = doc

    with open(seed_path, 'w', encoding='utf-8') as f:
        json.dump(seed_data, f, ensure_ascii=False, indent=2)

    print(f"✅ Generated {seed_path} with {len(seed_data)} category documents.")
    return seed_data

def upload_to_firestore(seed_data):
    try:
        from google.cloud import firestore
        db = firestore.Client(project='ozvisa-alert-prod')
        print("Connected to Firestore. Uploading documents to 'official_links'...")
        batch = db.batch()
        count = 0
        for gid, doc_data in seed_data.items():
            doc_ref = db.collection('official_links').document(gid)
            batch.set(doc_ref, doc_data)
            count += 1
        batch.commit()
        print(f"🚀 Successfully uploaded {count} documents to 'official_links' collection!")
    except Exception as e:
        print(f"ℹ️ Direct Admin SDK upload skipped ({e}).")
        print("To upload via Firebase Console or Google Cloud Shell:")
        print("  1. Copy assets/data/official_links_seed.json")
        print("  2. In Cloud Shell or local with credentials, run:")
        print("     gcloud auth application-default login")
        print("     python scripts/seed_official_links.py --upload")

if __name__ == '__main__':
    data = generate_seed()
    if '--upload' in sys.argv:
        upload_to_firestore(data)
