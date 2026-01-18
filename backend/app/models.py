from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class AnalysisResult(BaseModel):
    id: str
    vibe_type: str
    vibe_emoji: str
    description: str
    roast: str = ""
    red_flags: List[str] = []
    green_flags: List[str] = []
    traits: List[str]
    conversation_starters: List[str]
    energy: str
    compatibility: str = ""
    created_at: datetime


class AnalysisRequest(BaseModel):
    language: str = "en"


class InstagramAnalysisRequest(BaseModel):
    url: str
    language: str = "tr"
    roast_mode: bool = True


class InstagramAnalysisResponse(BaseModel):
    success: bool
    result: Optional[AnalysisResult] = None
    error: Optional[str] = None
    error_code: Optional[str] = None
    username: Optional[str] = None


class RemainingUsesResponse(BaseModel):
    remaining: int
    reset_at: Optional[datetime] = None


class ErrorResponse(BaseModel):
    detail: str


# Deep Analysis Models
class DeepAnalysisRequest(BaseModel):
    url: str
    language: str = "tr"
    roast_mode: bool = True


class DeepAnalysisResult(BaseModel):
    id: str
    profile_archetype: str
    archetype_emoji: str
    content_patterns: List[str]
    engagement_analysis: str
    engagement_rate: float = 0.0
    deep_roast: str
    relationship_prediction: str
    warning_signs: List[str]
    created_at: datetime


class DeepAnalysisResponse(BaseModel):
    success: bool
    result: Optional[DeepAnalysisResult] = None
    error: Optional[str] = None
    error_code: Optional[str] = None
    username: Optional[str] = None
    post_count_analyzed: int = 0
