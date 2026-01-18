import uuid
from typing import List
from datetime import datetime
from fastapi import APIRouter, UploadFile, File, HTTPException, Depends, Body
from app.models import (
    AnalysisResult,
    RemainingUsesResponse,
    InstagramAnalysisRequest,
    InstagramAnalysisResponse,
    DeepAnalysisRequest,
    DeepAnalysisResult,
    DeepAnalysisResponse,
)
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
    roast_mode: bool = True,
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
        result = await ai_service.analyze_profile(image_bytes, language, roast_mode=roast_mode)
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
        result = await ai_service.analyze_profile(
            image_to_analyze,
            request.language,
            roast_mode=request.roast_mode
        )
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


def build_deep_result(result: dict) -> DeepAnalysisResult:
    """Build DeepAnalysisResult from AI response."""
    return DeepAnalysisResult(
        id=str(uuid.uuid4()),
        profile_archetype=result.get("profile_archetype", "Bilinmeyen Tip"),
        archetype_emoji=result.get("archetype_emoji", "🔮"),
        content_patterns=result.get("content_patterns", []),
        engagement_analysis=result.get("engagement_analysis", ""),
        engagement_rate=result.get("engagement_rate", 0.0),
        deep_roast=result.get("deep_roast", ""),
        relationship_prediction=result.get("relationship_prediction", ""),
        warning_signs=result.get("warning_signs", []),
        created_at=datetime.now(),
    )


@router.post("/analyze-instagram-deep", response_model=DeepAnalysisResponse)
async def analyze_instagram_deep(
    request: DeepAnalysisRequest,
    settings: Settings = Depends(get_settings),
    ai_service: AIService = Depends(get_ai_service),
    rate_limiter: RateLimiter = Depends(get_rate_limiter),
    instagram: InstagramScraper = Depends(get_instagram_scraper),
):
    """
    Deep analysis of an Instagram profile.
    Analyzes 6-9 posts with captions, likes, and comments.
    Premium feature only.
    """
    client_id = "anonymous"  # TODO: Get from auth with premium check

    if not rate_limiter.check_limit(client_id):
        return DeepAnalysisResponse(
            success=False,
            error="Günlük limit doldu. Yarın tekrar dene!",
            error_code="rate_limit"
        )

    # Fetch profile with deep data
    profile = await instagram.fetch_profile_deep(request.url, max_posts=9)

    if profile.error:
        error_messages = {
            "invalid_username": "Geçersiz Instagram kullanıcı adı veya linki",
            "user_not_found": f"@{profile.username} bulunamadı",
            "login_required": "Instagram giriş istiyor",
            "timeout": "Instagram çok yavaş yanıt verdi",
            "no_images_found": "Profil fotoğrafı bulunamadı",
            "no_profile_pic": "Profil fotoğrafı çekilemedi",
            "download_failed": "Görsel indirilemedi",
            "all_methods_failed": "Instagram engelliyor",
        }
        error_msg = error_messages.get(profile.error, "Bir hata oluştu")

        return DeepAnalysisResponse(
            success=False,
            error=error_msg,
            error_code=profile.error,
            username=profile.username if profile.username else None
        )

    if profile.is_private:
        return DeepAnalysisResponse(
            success=False,
            error=f"@{profile.username} gizli hesap. Derin analiz sadece açık profiller için yapılabilir.",
            error_code="private_account",
            username=profile.username
        )

    # Check minimum post requirement (at least 1 image needed)
    if len(profile.post_images) < 1:
        return DeepAnalysisResponse(
            success=False,
            error=f"Instagram bu profili koruma altına almış. Derin analiz için profil screenshot'ları yükleyebilirsin.",
            error_code="instagram_blocked",
            username=profile.username,
            post_count_analyzed=len(profile.post_images)
        )

    # Warn if less than 3 posts (but continue)
    if len(profile.post_images) < 3:
        print(f"[Warning] Only {len(profile.post_images)} images found for deep analysis")

    # Perform deep analysis
    try:
        result = await ai_service.analyze_profile_deep(
            images=profile.post_images,
            captions=profile.post_captions,
            like_counts=profile.post_like_counts,
            comment_counts=profile.post_comment_counts,
            follower_count=profile.follower_count or 0,
            bio=profile.bio or "",
            language=request.language,
        )
    except NotImplementedError:
        return DeepAnalysisResponse(
            success=False,
            error="Derin analiz bu servis için desteklenmiyor",
            error_code="not_implemented",
            username=profile.username
        )
    except Exception as e:
        import traceback
        traceback.print_exc()
        return DeepAnalysisResponse(
            success=False,
            error=f"AI analizi başarısız: {str(e)}",
            error_code="ai_error",
            username=profile.username
        )

    # Increment usage (counts as premium feature use)
    rate_limiter.increment(client_id)

    return DeepAnalysisResponse(
        success=True,
        result=build_deep_result(result),
        username=profile.username,
        post_count_analyzed=len(profile.post_images)
    )


@router.post("/analyze-screenshots-deep", response_model=DeepAnalysisResponse)
async def analyze_screenshots_deep(
    files: List[UploadFile] = File(...),
    language: str = "tr",
    settings: Settings = Depends(get_settings),
    ai_service: AIService = Depends(get_ai_service),
    rate_limiter: RateLimiter = Depends(get_rate_limiter),
):
    """
    Deep analysis using uploaded screenshots.
    Requires 3-9 screenshot images.
    Premium feature only.
    """
    client_id = "anonymous"  # TODO: Get from auth with premium check

    if not rate_limiter.check_limit(client_id):
        return DeepAnalysisResponse(
            success=False,
            error="Günlük limit doldu. Yarın tekrar dene!",
            error_code="rate_limit"
        )

    # Validate file count
    if len(files) < 3:
        return DeepAnalysisResponse(
            success=False,
            error=f"Derin analiz için en az 3 screenshot gerekli. {len(files)} dosya yüklendi.",
            error_code="insufficient_files",
            post_count_analyzed=len(files)
        )

    if len(files) > 9:
        files = files[:9]  # Limit to 9 files

    # Read image bytes
    images = []
    for file in files:
        content = await file.read()
        if len(content) > 1000:  # Basic validation
            images.append(content)

    if len(images) < 3:
        return DeepAnalysisResponse(
            success=False,
            error="Yüklenen dosyalar geçersiz veya çok küçük.",
            error_code="invalid_files",
            post_count_analyzed=len(images)
        )

    # Perform deep analysis
    try:
        result = await ai_service.analyze_profile_deep(
            images=images,
            captions=[],  # No captions from screenshots
            like_counts=[],
            comment_counts=[],
            follower_count=0,
            bio="",
            language=language,
        )
    except NotImplementedError:
        return DeepAnalysisResponse(
            success=False,
            error="Derin analiz bu servis için desteklenmiyor",
            error_code="not_implemented"
        )
    except Exception as e:
        import traceback
        traceback.print_exc()
        return DeepAnalysisResponse(
            success=False,
            error=f"AI analizi başarısız: {str(e)}",
            error_code="ai_error"
        )

    # Increment usage
    rate_limiter.increment(client_id)

    return DeepAnalysisResponse(
        success=True,
        result=build_deep_result(result),
        post_count_analyzed=len(images)
    )
