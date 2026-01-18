from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import get_settings
from app.routers import analysis

settings = get_settings()

app = FastAPI(
    title="Profile Whisperer API",
    description="AI-Powered Rizz Assistant - Stalk. Understand. Slide.",
    version="1.0.0",
)

# CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict this
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(analysis.router, prefix="/api/v1", tags=["analysis"])


@app.get("/")
async def root():
    return {
        "name": "Profile Whisperer API",
        "version": "1.0.0",
        "status": "running",
        "mode": "bridge" if settings.bridge_enabled else "api",
    }


@app.get("/health")
async def health():
    return {"status": "healthy"}
