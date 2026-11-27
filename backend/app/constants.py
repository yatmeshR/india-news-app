CATEGORIES = [
    ("top", "Top Stories"),
    ("india", "India"),
    ("world", "World"),
    ("business", "Business"),
    ("politics", "Politics"),
    ("sports", "Sports"),
    ("entertainment", "Entertainment"),
    ("technology", "Technology"),
    ("science", "Science"),
    ("health", "Health"),
    ("education", "Education"),
    ("startups", "Startups"),
]

CATEGORY_SLUGS = {slug for slug, _ in CATEGORIES}

LANGUAGES = {"en": "English", "hi": "Hindi", "mr": "Marathi"}

# state name -> keywords (lowercase). Used to tag state/city news.
STATE_KEYWORDS = {
    "Delhi": ["delhi", "new delhi", "noida", "gurugram", "gurgaon"],
    "Maharashtra": ["maharashtra", "mumbai", "pune", "nagpur", "nashik"],
    "Karnataka": ["karnataka", "bengaluru", "bangalore", "mysuru", "mysore"],
    "Tamil Nadu": ["tamil nadu", "chennai", "coimbatore", "madurai"],
    "Kerala": ["kerala", "thiruvananthapuram", "kochi", "kozhikode"],
    "Telangana": ["telangana", "hyderabad"],
    "Andhra Pradesh": ["andhra pradesh", "amaravati", "visakhapatnam", "vijayawada"],
    "West Bengal": ["west bengal", "kolkata", "bengal"],
    "Gujarat": ["gujarat", "ahmedabad", "surat", "vadodara", "gandhinagar"],
    "Rajasthan": ["rajasthan", "jaipur", "jodhpur", "udaipur"],
    "Uttar Pradesh": ["uttar pradesh", "lucknow", "kanpur", "varanasi", "prayagraj"],
    "Bihar": ["bihar", "patna"],
    "Madhya Pradesh": ["madhya pradesh", "bhopal", "indore"],
    "Punjab": ["punjab", "ludhiana", "amritsar"],
    "Haryana": ["haryana", "chandigarh", "faridabad"],
    "Odisha": ["odisha", "bhubaneswar", "cuttack"],
    "Assam": ["assam", "guwahati"],
    "Jharkhand": ["jharkhand", "ranchi"],
    "Chhattisgarh": ["chhattisgarh", "raipur"],
    "Uttarakhand": ["uttarakhand", "dehradun"],
    "Himachal Pradesh": ["himachal", "shimla"],
    "Jammu & Kashmir": ["jammu", "kashmir", "srinagar"],
    "Goa": ["goa", "panaji"],
}

# category -> keywords. Used to refine generic ("top"/"india") feeds.
CATEGORY_KEYWORDS = {
    "sports": ["cricket", "ipl", "bcci", "football", "hockey", "tennis", "olympic", "kabaddi", "badminton", "wicket", "fifa", "t20", "test match"],
    "business": ["sensex", "nifty", "rbi", "gdp", "stock market", "rupee", "inflation", "budget", "gst", "shares", "ipo", "sebi"],
    "entertainment": ["bollywood", "film", "movie", "actor", "actress", "box office", "netflix", "ott", "trailer", "web series"],
    "technology": ["smartphone", "ai ", "artificial intelligence", "software", "app ", "google", "apple", "microsoft", "cyber", "5g", "chip"],
    "science": ["isro", "nasa", "space", "satellite", "research", "scientists", "mission", "telescope"],
    "health": ["health", "hospital", "disease", "vaccine", "covid", "cancer", "doctor", "medical", "virus"],
    "education": ["exam", "neet", "jee", "cbse", "university", "admit card", "result declared", "students", "school"],
    "politics": ["bjp", "congress", "lok sabha", "rajya sabha", "election", "parliament", "chief minister", "aap ", "opposition", "mla", "mp "],
    "startups": ["startup", "funding round", "unicorn", "founder", "venture capital", "series a", "series b"],
}
