import requests
from bs4 import BeautifulSoup
import sys

url = "https://immi.homeaffairs.gov.au/what-we-do/whm-program/status-of-country-caps"
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9,es;q=0.8",
}

response = requests.get(url, headers=headers)
print("Status code:", response.status_code)

soup = BeautifulSoup(response.text, "html.parser")

countries = ["peru", "ecuador", "spain", "argentina"]
for country_en in countries:
    found = False
    for tag in soup.find_all("tr"):
        tag_text = tag.get_text(separator=" ").lower()
        if country_en in tag_text:
            safe_text = tag_text.strip().encode('ascii', 'ignore').decode('ascii')
            print(f"FOUND IN TR for {country_en.upper()}: {safe_text}")
            found = True
            
            # Let's see what logic gives us:
            if any(w in tag_text for w in ["open", "available", "lodgements open"]):
                if not any(w in tag_text for w in ["closed", "paused", "filled"]):
                    print(f"-> {country_en.upper()} logic says OPEN")
                else:
                    print(f"-> {country_en.upper()} logic says MIXED (has both open and closed/paused/filled)")
            elif any(w in tag_text for w in ["closed", "paused", "reached", "filled"]):
                print(f"-> {country_en.upper()} logic says CLOSED")
            else:
                print(f"-> {country_en.upper()} logic says UNKNOWN")
                
    if not found:
         print(f"NOT FOUND IN TR for {country_en.upper()}")
