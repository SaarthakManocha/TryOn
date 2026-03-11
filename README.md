# TryOn — AI-Powered Virtual Try-On App

<p align="center">
  <strong>Try any outfit on yourself, virtually — powered by AI.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" />
  <img src="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/MediaPipe-4285F4?style=for-the-badge&logo=google&logoColor=white" />
</p>

> [!IMPORTANT]
> **This project is under active development.**
> - The **core application logic is fully built and functional**, including the complete Flutter frontend (auth, onboarding, try-on flow, wardrobe, shopping, profile) and the entire Python backend pipeline.
> - **UI/UX design polish** is pending — the current interface uses functional placeholder styling. A full design system (colors, typography, components) has been specced out and is awaiting implementation. See [`DESIGN_BRIEF.md`](./DESIGN_BRIEF.md) for the planned design system.
> - **AI try-on integration (fal.ai IDM-VTON)** is currently disabled as it requires a paid API subscription. The backend pipeline is fully wired — once an API key with credits is provided, the virtual try-on generation will work end-to-end.

---

## What is TryOn?

**TryOn** is a mobile application that lets you virtually try on any piece of clothing using AI-powered image processing. Upload a photo of a garment, take a selfie, and see how the outfit would look on you — without ever stepping into a fitting room.

### The Problem

- **30-40% of online fashion purchases** are returned due to fit/appearance uncertainty
-  Hours wasted trying clothes in physical stores
-  Environmental impact from shipping returns back and forth

### The Solution

1. Upload or photograph any garment
2. The app extracts your face, hair, and body proportions from a selfie
3. A personalized virtual body model is created
4. AI overlays the garment onto your model for a realistic try-on preview
5. Shop for similar products directly from the app

---

## Features

| Feature | Status | Description |
|---|---|---|
| **User Authentication** | ✅ Complete | Email/password + Google Sign-In via Firebase |
| **User Onboarding** | ✅ Complete | Style preferences, body info, profile photo capture |
| **Face & Hair Extraction** | ✅ Complete | MediaPipe-powered face landmark detection + hair segmentation |
| **Body Model Generation** | ✅ Complete | Personalized base body from gender, build, height, and skin tone |
| **Garment Segmentation** | ✅ Complete | Background removal via rembg (upload or URL) |
| **Virtual Try-On (AI)** | 🔧 API Pending | IDM-VTON via fal.ai — pipeline built, needs active API key |
| **Face Compositing** | ✅ Complete | Blends user's face + hair onto the try-on result |
| **Product Search** | ✅ Complete | Reverse image search via SerpAPI Google Lens |
| **Wardrobe (Favorites)** | ✅ Complete | Save and manage try-on results |
| **UI/UX Design Polish** | 🎨 Pending | Functional UI in place, premium design system planned |

---

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Flutter App   │────▶│  FastAPI Server  │────▶│   Cloudinary    │
│   (Frontend)    │◀────│   (Backend)      │◀────│   (Storage)     │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   AI/ML Services    │
                    │ • MediaPipe (Face)  │
                    │ • rembg (Segment)   │
                    │ • IDM-VTON (Try-On) │
                    │ • SerpAPI (Search)  │
                    └─────────────────────┘
```

---

## Tech Stack

### Frontend — Flutter

| Technology | Purpose |
|---|---|
| Flutter (Dart) | Cross-platform mobile app (Android / iOS) |
| Riverpod | State management |
| GoRouter | Navigation & routing |
| Firebase Auth | Email + Google Sign-In authentication |
| Cloud Firestore | User data persistence |
| Dio | HTTP client for backend communication |
| Image Picker | Camera and gallery image selection |

### Backend — Python

| Technology | Purpose |
|---|---|
| FastAPI | REST API server |
| MediaPipe | Face detection, landmark extraction, hair segmentation |
| rembg (U2Net) | Background removal / garment segmentation |
| OpenCV + NumPy | Image processing and compositing |
| Cloudinary | Cloud image storage (25GB free tier) |
| fal.ai | IDM-VTON virtual try-on generation |
| SerpAPI | Google Lens reverse image search for product matching |

---

##  App Screens

The app includes **13 fully implemented screens**:

- **Auth**: Login, Sign Up, Forgot Password, Email Verification
- **Onboarding**: Style Preferences, Body Info, Profile Photo
- **Main**: Dashboard, Try-On Flow (multi-step), Wardrobe, Profile, Shopping Results, Settings

---

##  Getting Started

### Prerequisites

- Flutter SDK (≥ 3.10.1)
- Python 3.11+
- Firebase project with Auth + Firestore enabled
- API keys for: Cloudinary, SerpAPI, fal.ai (optional — for try-on generation)

### Backend Setup

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment variables
cp .env.example .env
# Edit .env with your API keys

# Run the server
python server.py
```

The backend starts at `http://localhost:8000`. Visit `http://localhost:8000/docs` for the interactive API documentation.

### Frontend Setup

```bash
cd flutter_app

# Get dependencies
flutter pub get

# Run the app
flutter run
```

> **Note:** You'll need to configure your own `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) for Firebase integration.

---

## Environment Variables

Create a `.env` file in the `backend/` directory (see `.env.example`):

| Variable | Required | Description |
|---|---|---|
| `FAL_API_KEY` | Optional | fal.ai API key for IDM-VTON try-on generation |
| `CLOUDINARY_CLOUD_NAME` | Yes | Cloudinary cloud name |
| `CLOUDINARY_API_KEY` | Yes | Cloudinary API key |
| `CLOUDINARY_API_SECRET` | Yes | Cloudinary API secret |
| `SERPAPI_KEY` | Yes | SerpAPI key for product search |

---

## Roadmap

- [ ] UI/UX design overhaul — implement the full design system from [`DESIGN_BRIEF.md`](./DESIGN_BRIEF.md)
- [ ] Activate AI try-on with fal.ai IDM-VTON integration
- [ ] AR mode for real-time try-on with phone camera
- [ ] Size recommendations based on body measurements
- [ ] Social sharing & outfit voting
- [ ] Direct e-commerce platform integrations
- [ ] Multi-garment styling (full outfit creation)

---

## Project Structure

```
TryOn/
├── backend/                  # Python FastAPI server
│   ├── server.py             # Main API server with all endpoints
│   ├── face_extractor.py     # MediaPipe face detection & skin tone
│   ├── hair_extractor.py     # MediaPipe hair segmentation
│   ├── base_body_creator.py  # Body model generation from templates
│   ├── garment_segmenter.py  # rembg-based garment segmentation
│   ├── tryon_generator.py    # IDM-VTON try-on via fal.ai
│   ├── face_compositor.py    # Face + hair compositing onto results
│   ├── product_search.py     # SerpAPI Google Lens product search
│   ├── cloudinary_storage.py # Cloud image upload/management
│   └── requirements.txt      # Python dependencies
│
├── flutter_app/              # Flutter mobile application
│   └── lib/
│       ├── main.dart         # App entry point
│       ├── screens/          # All 13 app screens
│       ├── providers/        # Riverpod state providers
│       ├── services/         # API service layer
│       ├── router/           # GoRouter navigation
│       ├── theme/            # App theme & styling
│       └── widgets/          # Reusable UI components
│
├── DESIGN_BRIEF.md           # UI/UX design specifications
├── PROJECT_PROPOSAL.md       # Full project proposal document
└── README.md                 # This file
```

---

## Author

**Saarthak Manocha** — Developer

Initially built as a hackathon project, now being developed further as a personal project.

---
