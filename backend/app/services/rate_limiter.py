from datetime import datetime, timedelta
from typing import Dict, Optional
from app.config import get_settings


class RateLimiter:
    """
    Simple in-memory rate limiter for development.
    In production, use Redis or Supabase.
    """

    def __init__(self, daily_limit: int = 9999):
        self.daily_limit = daily_limit
        self._usage: Dict[str, Dict] = {}

    def _get_user_data(self, client_id: str) -> Dict:
        today = datetime.now().date()

        if client_id not in self._usage:
            self._usage[client_id] = {
                "date": today,
                "count": 0,
            }

        # Reset if new day
        if self._usage[client_id]["date"] != today:
            self._usage[client_id] = {
                "date": today,
                "count": 0,
            }

        return self._usage[client_id]

    def check_limit(self, client_id: str) -> bool:
        """Check if user has remaining uses."""
        data = self._get_user_data(client_id)
        return data["count"] < self.daily_limit

    def increment(self, client_id: str) -> None:
        """Increment usage count."""
        data = self._get_user_data(client_id)
        data["count"] += 1

    def get_remaining(self, client_id: str) -> int:
        """Get remaining uses for today."""
        data = self._get_user_data(client_id)
        return max(0, self.daily_limit - data["count"])

    def get_reset_time(self, client_id: str) -> Optional[datetime]:
        """Get when the limit resets (midnight)."""
        tomorrow = datetime.now().date() + timedelta(days=1)
        return datetime.combine(tomorrow, datetime.min.time())


# Singleton instance
_rate_limiter: Optional[RateLimiter] = None


def get_rate_limiter() -> RateLimiter:
    global _rate_limiter
    if _rate_limiter is None:
        settings = get_settings()
        _rate_limiter = RateLimiter(daily_limit=settings.daily_free_limit)
    return _rate_limiter
