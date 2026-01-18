import os
import json
import uuid
import asyncio
import base64
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional
from datetime import datetime
from app.config import get_settings


class AIService(ABC):
    """Abstract base class for AI services."""

    @abstractmethod
    async def analyze_profile(self, image_bytes: bytes, language: str = "en") -> Dict[str, Any]:
        pass


class ClaudeCodeBridge(AIService):
    """
    Bridge to Claude Code for development.
    Writes requests to filesystem, waits for Claude Code to process them.
    """

    def __init__(self, request_dir: str, response_dir: str, timeout: int = 300):
        self.request_dir = request_dir
        self.response_dir = response_dir
        self.timeout = timeout

        # Create directories if they don't exist
        os.makedirs(request_dir, exist_ok=True)
        os.makedirs(response_dir, exist_ok=True)

    async def analyze_profile(self, image_bytes: bytes, language: str = "en") -> Dict[str, Any]:
        request_id = str(uuid.uuid4())[:8]
        request_path = os.path.join(self.request_dir, request_id)
        response_path = os.path.join(self.response_dir, f"{request_id}.json")

        # Create request directory
        os.makedirs(request_path, exist_ok=True)

        # Save image
        image_path = os.path.join(request_path, "image.jpg")
        with open(image_path, "wb") as f:
            f.write(image_bytes)

        # Save prompt
        prompt = self._generate_prompt(language)
        prompt_path = os.path.join(request_path, "prompt.txt")
        with open(prompt_path, "w", encoding="utf-8") as f:
            f.write(prompt)

        # Save metadata
        metadata = {
            "request_id": request_id,
            "language": language,
            "created_at": datetime.now().isoformat(),
            "status": "pending",
        }
        metadata_path = os.path.join(request_path, "metadata.json")
        with open(metadata_path, "w", encoding="utf-8") as f:
            json.dump(metadata, f, indent=2)

        print(f"\n{'='*60}")
        print(f"NEW ANALYSIS REQUEST: {request_id}")
        print(f"Image saved to: {image_path}")
        print(f"Prompt saved to: {prompt_path}")
        print(f"Waiting for Claude Code to process...")
        print(f"{'='*60}\n")

        # Wait for response (polling)
        elapsed = 0
        poll_interval = 2

        while elapsed < self.timeout:
            if os.path.exists(response_path):
                with open(response_path, "r", encoding="utf-8") as f:
                    result = json.load(f)

                # Clean up request
                # os.remove(response_path)  # Keep for debugging

                return result

            await asyncio.sleep(poll_interval)
            elapsed += poll_interval

        raise TimeoutError(f"Analysis timed out after {self.timeout} seconds")

    def _generate_prompt(self, language: str) -> str:
        lang_prompts = {
            "en": """You are a fun personality quiz generator for a social entertainment app. The user has uploaded THEIR OWN profile photo to discover their "vibe type" - similar to popular personality quizzes like "What kind of bread are you?" or MBTI memes.

This is a lighthearted self-discovery tool where users analyze themselves for fun and share results with friends.

Analyze the photo and return this JSON structure:
{
    "vibe_type": "A fun 2-4 word personality label (e.g., 'Chaotic Academic', 'Golden Retriever Energy', 'Main Character', 'Cozy Homebody', 'Creative Soul')",
    "vibe_emoji": "One emoji representing this vibe",
    "description": "2-3 fun sentences describing this vibe/energy in a playful way",
    "traits": ["trait1", "trait2", "trait3", "trait4"],
    "conversation_starters": [
        "A fun icebreaker question based on something visible in the photo",
        "A creative conversation topic they might enjoy",
        "A playful observation that could start a friendly chat"
    ],
    "energy": "High Energy / Chill Vibes / Mysterious / Approachable / Creative"
}

Keep it fun, positive, and like a BuzzFeed personality quiz result. The conversation starters are friendly icebreakers, not pickup lines.""",

            "tr": """Sen eglenceli bir kisilik testi uygulamasi icin vibe analizi yapiyorsun. Kullanici KENDI profil fotografini yukleyerek "vibe tipini" kesfetmek istiyor - "Hangi ekmek turusun?" veya MBTI memeleri gibi populer kisilik testleri gibi.

Bu, kullanicilarin kendilerini eglence icin analiz ettigi ve sonuclari arkadaslariyla paylastigi eglenceli bir kendini kesif araci.

Fotografi analiz et ve su JSON yapisini don:
{
    "vibe_type": "Eglenceli 2-4 kelimelik kisilik etiketi (orn: 'Kaotik Akademisyen', 'Golden Retriever Enerjisi', 'Ana Karakter', 'Rahat Ev Kedisi')",
    "vibe_emoji": "Bu vibe'i temsil eden bir emoji",
    "description": "Bu vibe/enerjiyi eglenceli bir sekilde anlatan 2-3 cumle",
    "traits": ["ozellik1", "ozellik2", "ozellik3", "ozellik4"],
    "conversation_starters": [
        "Fotograftaki bir seye dayanan eglenceli bir sohbet baslangici",
        "Hoslanabilecekleri yaratici bir sohbet konusu",
        "Arkadas sohbeti baslatan eglenceli bir gozlem"
    ],
    "energy": "Yuksek Enerji / Rahat Vibes / Gizemli / Yaklasilabilir / Yaratici"
}

Eglenceli, pozitif ve BuzzFeed kisilik testi sonucu gibi olsun. Sohbet baslangiclar samimi buzkiricilar.""",
        }

        return lang_prompts.get(language, lang_prompts["en"])


class ClaudeAPIService(AIService):
    """
    Direct Claude API integration for production.
    """

    def __init__(self, api_key: str):
        self.api_key = api_key

    def _get_prompt(self, language: str) -> str:
        prompts = {
            "en": """Analyze this profile photo with maximum sass and humor. Be brutally honest but funny - like a best friend roasting them.

Return this JSON:
{
    "vibe_type": "Creative 2-4 word label - be specific and funny (e.g., 'LinkedIn Influencer Wannabe', 'Cat Parent Energy', 'Gym Bro in Recovery', 'Main Character Syndrome', 'Trust Fund Aesthetic')",
    "vibe_emoji": "Perfect emoji for this vibe",
    "description": "4-5 sentences of BRUTAL but funny roast. Notice specific details - their pose, background, style choices, what they're trying to project vs reality. Be savage but loveable. Make them laugh at themselves.",
    "roast": "One killer roast line - the kind a best friend would say",
    "red_flags": ["Funny 'red flag' observation 1", "Red flag 2", "Red flag 3"],
    "green_flags": ["Genuine positive trait 1", "Green flag 2", "Green flag 3"],
    "traits": ["trait1", "trait2", "trait3", "trait4", "trait5"],
    "conversation_starters": [
        "Genuinely curious question about something specific in the photo - be natural, like you're actually interested",
        "Playful teasing opener that shows you noticed details",
        "Creative/funny observation that would make them laugh",
        "Smooth but not cringe - something actually clever",
        "Bold opener for the brave"
    ],
    "energy": "Specific energy description",
    "compatibility": "What type of person would vibe with them"
}

Be SPECIFIC to what you see. No generic responses. Channel Twitter roast energy. ONLY return JSON.""",

            "tr": """Sen huysuz, alaycı ve acımasız bir analizcisin. Sanki hayattan bıkmış bir virgin arkadaşın gibi düşün - kimseyi beğenmez, her şeyde kusur bulur, ama o kadar haklı ki gülmekten kendini alamazsın.

Fotoğrafı gör ve ACÍMASIZCA roastla. Övgü yok, iltifat yok. Sadece sert gerçekler ve komik hakaret.

ÖNEMLI: Her analiz FARKLI ve SPESİFİK olmalı. Gördüğün detaylara göre yaz - poz, kıyafet, arka plan, bakış, her şey malzeme.

Şu JSON'u dön:
{
    "vibe_type": "Acımasız 2-4 kelimelik etiket (ör: 'Sahte Derin Tip', 'Annesinin Prensi', 'LinkedIn Motivasyoncusu', 'Kripto Batıran', 'Gym Selfie Manyağı', 'Fake Zengin', 'Friendzone Kralı', 'Pick Me Girl', 'NPC Energy', 'Ortalama Dayı Adayı')",
    "vibe_emoji": "En uygun emoji",
    "description": "4-5 cümle TAM GAZ roast. Gördüğün her detayla dalga geç. Pozuyla, kıyafetiyle, arka planla, ifadesiyle... Acıma yok. Ama öyle komik olsun ki kendi kendine gülesin. Sanki arkadaş grubunda bu fotoğrafı görüp 'AHAHAHA ŞUNA BAK' diyorsun.",
    "roast": "TEK CÜMLE öldürücü laf. Ekran görüntüsü alınıp atılacak kadar iyi olmalı. Mesela: 'Bu adam kesin arabasının markasını ilk 5 dakikada söylüyordur' veya 'Tinder bio'sunda boy yazıyor %100'",
    "red_flags": ["Acımasız red flag 1 - çok spesifik ol", "Red flag 2 - fotoğraftan çıkar", "Red flag 3 - tahmin yürüt", "Red flag 4", "Red flag 5"],
    "green_flags": ["Bir tane olsun istersen ama isteksizce yaz", "Sanki zor bulmuşsun gibi"],
    "traits": ["ozellik1", "ozellik2", "ozellik3", "ozellik4", "ozellik5"],
    "conversation_starters": [
        "İğneleyici ama merak uyandıran soru",
        "Hafif dalga geçen ama konuşma başlatan",
        "Bold ve direkt - friend zone'a girmeyecek türden",
        "Komik gözlem + soru kombinasyonu",
        "Yüzsüzce ama çekici açılış"
    ],
    "energy": "Kısa ve acımasız enerji tanımı",
    "compatibility": "Kimle çıkar bu? (komik ve gerçekçi ol)"
}

KURALLAR:
1. JENERİK CEVAP YOK - her şey fotoğrafa özel
2. ÖVGÜ YASAK - maksimum 1-2 isteksiz green flag
3. ROAST ÖNCELİKLİ - insanlar paylaşsın diye
4. TÜRKÇE GÜNLÜK DİL - internet şakası gibi
5. SADECE JSON dön, başka bir şey yazma""",
        }
        return prompts.get(language, prompts["en"])

    async def analyze_profile(self, image_bytes: bytes, language: str = "en") -> Dict[str, Any]:
        import httpx

        image_base64 = base64.b64encode(image_bytes).decode("utf-8")
        prompt = self._get_prompt(language)

        system_prompt = """Sen "Profile Whisperer" için çalışan huysuz, sinirli ve acımasız bir analizcisin. Hayattan bıkmış bir virgin gibi düşün - hiç kimseyi beğenmezsin, her fotoğrafta bir sorun bulursun.

KARAKTER:
- Huysuz virgin energy - kimse seni etkileyemez
- Acımasız ama komik - insanlar gülerken ağlasın
- Twitter/TikTok roast kültürü
- Övgüden nefret edersin - green flag yazmak zorunda kalınca bile isteksizsin
- Her detayı fark edersin ve her şeyle dalga geçersin
- Jenerik cevap vermektense ölürsün

KURAL: SADECE valid JSON dönersin. Markdown yok, açıklama yok, sadece JSON."""

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                "https://api.anthropic.com/v1/messages",
                headers={
                    "x-api-key": self.api_key,
                    "anthropic-version": "2023-06-01",
                    "content-type": "application/json",
                },
                json={
                    "model": "claude-3-haiku-20240307",
                    "max_tokens": 1024,
                    "system": system_prompt,
                    "messages": [
                        {
                            "role": "user",
                            "content": [
                                {
                                    "type": "image",
                                    "source": {
                                        "type": "base64",
                                        "media_type": "image/jpeg",
                                        "data": image_base64,
                                    },
                                },
                                {
                                    "type": "text",
                                    "text": prompt,
                                },
                            ],
                        }
                    ],
                },
            )

            if response.status_code != 200:
                print(f"API Error: {response.status_code}")
                print(f"Response: {response.text}")
                response.raise_for_status()

            data = response.json()
            content = data["content"][0]["text"]
            start = content.find("{")
            end = content.rfind("}") + 1
            json_str = content[start:end]

            return json.loads(json_str)


# Factory function
_ai_service: Optional[AIService] = None


def get_ai_service() -> AIService:
    global _ai_service
    if _ai_service is None:
        settings = get_settings()

        if settings.bridge_enabled:
            _ai_service = ClaudeCodeBridge(
                request_dir=settings.bridge_request_dir,
                response_dir=settings.bridge_response_dir,
                timeout=settings.bridge_timeout_seconds,
            )
        else:
            if not settings.claude_api_key:
                raise ValueError("CLAUDE_API_KEY is required when bridge is disabled")
            _ai_service = ClaudeAPIService(api_key=settings.claude_api_key)

    return _ai_service
