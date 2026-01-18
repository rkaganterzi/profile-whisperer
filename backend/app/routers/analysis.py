import uuid
from datetime import datetime
from fastapi import APIRouter, UploadFile, File, HTTPException, Depends, Body
from app.models import AnalysisResult, RemainingUsesResponse, InstagramAnalysisRequest, InstagramAnalysisResponse
from app.config import get_settings, Settings
from app.services.ai_service import get_ai_service, AIService
from app.services.rate_limiter import RateLimiter, get_rate_limiter
from app.services.instagram_service import get_instagram_scraper, InstagramScraper

router = APIRouter()


def build_result(result: dict) -> AnalysisResult:
    """Build AnalysisResult from AI response."""
    return AnalysisResult(
        id=str(uuid.uuid4()),
        vibe_type=result.get("vibe_type", "Unknown"),
        vibe_emoji=result.get("vibe_emoji", "✨"),
        description=result.get("description", ""),
        roast=result.get("roast", ""),
        red_flags=result.get("red_flags", []),
        green_flags=result.get("green_flags", []),
        traits=result.get("traits", []),
        conversation_starters=result.get("conversation_starters", []),
        energy=result.get("energy", ""),
        compatibility=result.get("compatibility", ""),
        created_at=datetime.now(),
    )


@router.post("/analyze", response_model=AnalysisResult)
async def analyze_profile(
    image: UploadFile = File(...),
    language: str = "tr",
    settings: Settings = Depends(get_settings),
    ai_service: AIService = Depends(get_ai_service),
    rate_limiter: RateLimiter = Depends(get_rate_limiter),
):
    """
    Analyze a profile photo and return vibe analysis with conversation starters.
    """
    # Check rate limit (using IP for now, user_id later)
    client_id = "anonymous"  # TODO: Get from auth

    if not rate_limiter.check_limit(client_id):
        raise HTTPException(
            status_code=429,
            detail="Daily limit reached. Come back tomorrow!"
        )

    # Read image
    image_bytes = await image.read()

    if len(image_bytes) > 10 * 1024 * 1024:  # 10MB limit
        raise HTTPException(status_code=400, detail="Image too large (max 10MB)")

    # Analyze with AI
    try:
        result = await ai_service.analyze_profile(image_bytes, language)
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

    # Increment usage
    rate_limiter.increment(client_id)

    return build_result(result)


@router.post("/analyze-instagram", response_model=InstagramAnalysisResponse)
async def analyze_instagram_profile(
    request: InstagramAnalysisRequest,
    settings: Settings = Depends(get_settings),
    ai_service: AIService = Depends(get_ai_service),
    rate_limiter: RateLimiter = Depends(get_rate_limiter),
    instagram: InstagramScraper = Depends(get_instagram_scraper),
):
    """
    Analyze an Instagram profile by URL.
    Returns success with result, or error with fallback suggestion.
    """
    client_id = "anonymous"

    if not rate_limiter.check_limit(client_id):
        return InstagramAnalysisResponse(
            success=False,
            error="Günlük limit doldu. Yarın tekrar dene!",
            error_code="rate_limit"
        )

    # Fetch Instagram profile
    profile = await instagram.fetch_profile(request.url)

    if profile.error:
        error_messages = {
            "invalid_username": "Geçersiz Instagram kullanıcı adı veya linki",
            "user_not_found": f"@{profile.username} bulunamadı",
            "login_required": "Instagram giriş istiyor, screenshot yükle",
            "timeout": "Instagram çok yavaş yanıt verdi",
            "no_images_found": "Profil fotoğrafı bulunamadı, screenshot yükle",
            "no_profile_pic": "Profil fotoğrafı çekilemedi, screenshot yükle",
            "download_failed": "Görsel indirilemedi, screenshot yükle",
            "all_methods_failed": "Instagram engelliyor, screenshot yükle",
        }
        error_msg = error_messages.get(profile.error, f"Bir hata oluştu, screenshot yükle")

        return InstagramAnalysisResponse(
            success=False,
            error=error_msg,
            error_code=profile.error,
            username=profile.username if profile.username else None
        )

    if profile.is_private and not profile.profile_pic_bytes:
        return InstagramAnalysisResponse(
            success=False,
            error=f"@{profile.username} gizli hesap. Screenshot yükle!",
            error_code="private_account",
            username=profile.username
        )

    # Decide which image(s) to analyze
    # Priority: post images > profile pic
    image_to_analyze = None

    if profile.post_images:
        # Use the first post image
        image_to_analyze = profile.post_images[0]
    elif profile.profile_pic_bytes:
        image_to_analyze = profile.profile_pic_bytes

    if not image_to_analyze:
        return InstagramAnalysisResponse(
            success=False,
            error="Analiz edilecek görsel bulunamadı",
            error_code="no_images",
            username=profile.username
        )

    # Analyze with AI
    try:
        result = await ai_service.analyze_profile(image_to_analyze, request.language)
    except Exception as e:
        import traceback
        traceback.print_exc()
        return InstagramAnalysisResponse(
            success=False,
            error=f"AI analizi başarısız: {str(e)}",
            error_code="ai_error",
            username=profile.username
        )

    # Increment usage
    rate_limiter.increment(client_id)

    return InstagramAnalysisResponse(
        success=True,
        result=build_result(result),
        username=profile.username
    )


@router.get("/remaining-uses", response_model=RemainingUsesResponse)
async def get_remaining_uses(
    settings: Settings = Depends(get_settings),
    rate_limiter: RateLimiter = Depends(get_rate_limiter),
):
    """
    Get remaining daily uses for the current user.
    """
    client_id = "anonymous"  # TODO: Get from auth
    remaining = rate_limiter.get_remaining(client_id)

    return RemainingUsesResponse(
        remaining=remaining,
        reset_at=rate_limiter.get_reset_time(client_id),
    )
