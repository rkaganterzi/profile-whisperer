# Profile Whisperer

> **"Stalk. Understand. Slide."** - Your AI-Powered Rizz Assistant

AI-powered Instagram profile analyzer that helps you craft the perfect conversation starters.

## Features

- Upload any Instagram profile screenshot
- Get a fun "Vibe Type" personality analysis
- Receive 3 personalized conversation starters
- Share your results on stories
- Available in English and Turkish

## Tech Stack

| Layer | Technology |
|-------|------------|
| Mobile | Flutter |
| Backend | Python FastAPI |
| AI | Claude API (Haiku) |
| Database | Supabase (PostgreSQL) |
| Hosting | Railway |

## Project Structure

```
whisperer/
├── mobile/         # Flutter app
├── backend/        # FastAPI server
├── bridge/         # Claude Code Bridge (development)
└── docs/           # Documentation
```

## Development Setup

### Prerequisites

- Flutter SDK
- Python 3.11+
- Claude Code (for AI during development)

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows
pip install -r requirements.txt
cp .env.example .env
python run.py
```

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

## Claude Code Bridge

During development, we use Claude Code as a free AI engine:

1. Backend saves requests to `bridge/requests/`
2. You (Claude Code) process them manually
3. Results are saved to `bridge/responses/`
4. Backend returns results to the app

See `bridge/README.md` for details.

## License

MIT
