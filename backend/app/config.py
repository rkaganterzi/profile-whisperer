from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # Environment
    env: str = "development"

    # API
    api_host: str = "0.0.0.0"
    api_port: int = 8000

    # Claude API
    claude_api_key: str = ""

    # Rate Limiting
    daily_free_limit: int = 3

    # Bridge (development mode)
    bridge_enabled: bool = True
    bridge_request_dir: str = "../bridge/requests"
    bridge_response_dir: str = "../bridge/responses"
    bridge_timeout_seconds: int = 300

    # Supabase
    supabase_url: str = ""
    supabase_key: str = ""

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache()
def get_settings() -> Settings:
    return Settings()
