#!/usr/bin/env python3
"""
Development server runner for Profile Whisperer API.
"""
import uvicorn
from app.config import get_settings

if __name__ == "__main__":
    settings = get_settings()

    print("\n" + "=" * 60)
    print("Profile Whisperer API - Development Server")
    print("=" * 60)
    print(f"Mode: {'Bridge (Claude Code)' if settings.bridge_enabled else 'Claude API'}")
    print(f"Daily limit: {settings.daily_free_limit} analyses")
    print(f"Server: http://{settings.api_host}:{settings.api_port}")
    print("=" * 60 + "\n")

    uvicorn.run(
        "app.main:app",
        host=settings.api_host,
        port=settings.api_port,
        reload=True,
    )
