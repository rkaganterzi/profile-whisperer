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
    async def analyze_profile(self, image_bytes: bytes, language: str = "en", roast_mode: bool = True) -> Dict[str, Any]:
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

    async def analyze_profile(self, image_bytes: bytes, language: str = "en", roast_mode: bool = True) -> Dict[str, Any]:
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
        prompt = self._generate_prompt(language, roast_mode)
        prompt_path = os.path.join(request_path, "prompt.txt")
        with open(prompt_path, "w", encoding="utf-8") as f:
            f.write(prompt)

        # Save metadata
        metadata = {
            "request_id": request_id,
            "language": language,
            "roast_mode": roast_mode,
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

    def _generate_prompt(self, language: str, roast_mode: bool = True) -> str:
        if roast_mode:
            # Roast mode prompts (original aggressive prompts)
            lang_prompts = {
                "en": """Analyze this profile photo with maximum sass and humor. Be brutally honest but funny - like a best friend roasting them.

Return this JSON:
{
    "vibe_type": "Creative 2-4 word label - be specific and funny",
    "vibe_emoji": "Perfect emoji for this vibe",
    "description": "4-5 sentences of BRUTAL but funny roast. Notice specific details.",
    "roast": "One killer roast line - the kind a best friend would say",
    "red_flags": ["Funny 'red flag' observation 1", "Red flag 2", "Red flag 3"],
    "green_flags": ["Genuine positive trait 1", "Green flag 2", "Green flag 3"],
    "traits": ["trait1", "trait2", "trait3", "trait4", "trait5"],
    "conversation_starters": [
        "Genuinely curious question about something specific in the photo",
        "Playful teasing opener that shows you noticed details",
        "Creative/funny observation that would make them laugh",
        "Smooth but not cringe - something actually clever",
        "Bold opener for the brave"
    ],
    "energy": "Specific energy description",
    "compatibility": "What type of person would vibe with them"
}

Be SPECIFIC to what you see. No generic responses. ONLY return JSON.""",

                "tr": """Sen huysuz, alaycı ve acımasız bir analizcisin. Acımasızca roastla ama komik ol.

Şu JSON'u dön:
{
    "vibe_type": "Acımasız 2-4 kelimelik etiket",
    "vibe_emoji": "En uygun emoji",
    "description": "4-5 cümle TAM GAZ roast. Gördüğün her detayla dalga geç.",
    "roast": "TEK CÜMLE öldürücü laf",
    "red_flags": ["Acımasız red flag 1", "Red flag 2", "Red flag 3", "Red flag 4", "Red flag 5"],
    "green_flags": ["Bir tane olsun istersen ama isteksizce yaz", "Sanki zor bulmuşsun gibi"],
    "traits": ["ozellik1", "ozellik2", "ozellik3", "ozellik4", "ozellik5"],
    "conversation_starters": [
        "İğneleyici ama merak uyandıran soru",
        "Hafif dalga geçen ama konuşma başlatan",
        "Bold ve direkt açılış",
        "Komik gözlem + soru kombinasyonu",
        "Yüzsüzce ama çekici açılış"
    ],
    "energy": "Kısa enerji tanımı",
    "compatibility": "Kimle çıkar bu?"
}

JENERİK CEVAP YOK - her şey fotoğrafa özel. SADECE JSON dön.""",
            }
        else:
            # Friendly mode prompts (non-roast, positive vibes)
            lang_prompts = {
                "en": """You are a fun personality quiz generator for a social entertainment app. The user has uploaded THEIR OWN profile photo to discover their "vibe type".

Analyze the photo and return this JSON structure:
{
    "vibe_type": "A fun 2-4 word personality label (e.g., 'Creative Soul', 'Golden Retriever Energy')",
    "vibe_emoji": "One emoji representing this vibe",
    "description": "2-3 fun sentences describing this vibe/energy in a positive, playful way",
    "roast": "A gentle, friendly observation (not mean)",
    "red_flags": ["Playful quirk 1", "Playful quirk 2"],
    "green_flags": ["Genuine positive trait 1", "Green flag 2", "Green flag 3", "Green flag 4"],
    "traits": ["trait1", "trait2", "trait3", "trait4"],
    "conversation_starters": [
        "A fun icebreaker question based on something visible in the photo",
        "A creative conversation topic they might enjoy",
        "A playful observation that could start a friendly chat",
        "A genuine compliment turned into a question",
        "A warm and inviting opener"
    ],
    "energy": "High Energy / Chill Vibes / Mysterious / Approachable / Creative",
    "compatibility": "What type of person would vibe well with them"
}

Keep it fun, positive, and encouraging! ONLY return JSON.""",

                "tr": """Sen eğlenceli bir kişilik testi uygulaması için vibe analizi yapıyorsun. Kullanıcı kendi fotoğrafını yükleyerek "vibe tipini" keşfetmek istiyor.

Fotoğrafı analiz et ve şu JSON yapısını dön:
{
    "vibe_type": "Eğlenceli 2-4 kelimelik kişilik etiketi (ör: 'Yaratıcı Ruh', 'Golden Retriever Enerjisi')",
    "vibe_emoji": "Bu vibe'ı temsil eden bir emoji",
    "description": "Bu vibe/enerjiyi pozitif ve eğlenceli bir şekilde anlatan 2-3 cümle",
    "roast": "Nazik ve arkadaşça bir gözlem (kırıcı değil)",
    "red_flags": ["Sevimli tuhaf özellik 1", "Sevimli tuhaf özellik 2"],
    "green_flags": ["Gerçek pozitif özellik 1", "Green flag 2", "Green flag 3", "Green flag 4"],
    "traits": ["özellik1", "özellik2", "özellik3", "özellik4"],
    "conversation_starters": [
        "Fotoğraftaki bir şeye dayanan eğlenceli sohbet başlangıcı",
        "Hoşlanabilecekleri yaratıcı bir sohbet konusu",
        "Arkadaşça sohbet başlatan eğlenceli bir gözlem",
        "Samimi bir iltifattan türetilmiş soru",
        "Sıcak ve davetkar bir açılış"
    ],
    "energy": "Yüksek Enerji / Rahat Vibes / Gizemli / Yaklaşılabilir / Yaratıcı",
    "compatibility": "Kimle iyi anlaşır"
}

Eğlenceli, pozitif ve cesaretlendirici ol! SADECE JSON dön.""",
            }

        return lang_prompts.get(language, lang_prompts["en"])


class ClaudeAPIService(AIService):
    """
    Direct Claude API integration for production.
    """

    def __init__(self, api_key: str):
        self.api_key = api_key

    def _get_prompt(self, language: str, roast_mode: bool = True) -> str:
        if roast_mode:
            # Roast mode prompts (aggressive, funny roasts)
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
        else:
            # Friendly mode prompts (positive, encouraging)
            prompts = {
                "en": """You are a fun personality quiz generator. Analyze this profile photo with warmth and positivity.

Return this JSON:
{
    "vibe_type": "A fun 2-4 word personality label (e.g., 'Creative Soul', 'Golden Retriever Energy', 'Cozy Homebody')",
    "vibe_emoji": "One emoji representing this vibe",
    "description": "2-3 fun sentences describing this vibe/energy in a positive, playful way",
    "roast": "A gentle, friendly observation (not mean)",
    "red_flags": ["Playful quirk 1", "Playful quirk 2"],
    "green_flags": ["Genuine positive trait 1", "Green flag 2", "Green flag 3", "Green flag 4"],
    "traits": ["trait1", "trait2", "trait3", "trait4"],
    "conversation_starters": [
        "A fun icebreaker question based on something visible in the photo",
        "A creative conversation topic they might enjoy",
        "A playful observation that could start a friendly chat",
        "A genuine compliment turned into a question",
        "A warm and inviting opener"
    ],
    "energy": "High Energy / Chill Vibes / Mysterious / Approachable / Creative",
    "compatibility": "What type of person would vibe well with them"
}

Keep it fun, positive, and encouraging! ONLY return JSON.""",

                "tr": """Sen eğlenceli bir kişilik testi uygulaması için vibe analizi yapıyorsun. Fotoğrafı sıcak ve pozitif bir şekilde analiz et.

Şu JSON'u dön:
{
    "vibe_type": "Eğlenceli 2-4 kelimelik kişilik etiketi (ör: 'Yaratıcı Ruh', 'Golden Retriever Enerjisi', 'Rahat Ev Kedisi')",
    "vibe_emoji": "Bu vibe'ı temsil eden bir emoji",
    "description": "Bu vibe/enerjiyi pozitif ve eğlenceli bir şekilde anlatan 2-3 cümle",
    "roast": "Nazik ve arkadaşça bir gözlem (kırıcı değil)",
    "red_flags": ["Sevimli tuhaf özellik 1", "Sevimli tuhaf özellik 2"],
    "green_flags": ["Gerçek pozitif özellik 1", "Green flag 2", "Green flag 3", "Green flag 4"],
    "traits": ["özellik1", "özellik2", "özellik3", "özellik4"],
    "conversation_starters": [
        "Fotoğraftaki bir şeye dayanan eğlenceli sohbet başlangıcı",
        "Hoşlanabilecekleri yaratıcı bir sohbet konusu",
        "Arkadaşça sohbet başlatan eğlenceli bir gözlem",
        "Samimi bir iltifattan türetilmiş soru",
        "Sıcak ve davetkar bir açılış"
    ],
    "energy": "Yüksek Enerji / Rahat Vibes / Gizemli / Yaklaşılabilir / Yaratıcı",
    "compatibility": "Kimle iyi anlaşır"
}

Eğlenceli, pozitif ve cesaretlendirici ol! SADECE JSON dön.""",
            }

        return prompts.get(language, prompts["en"])

    def _get_system_prompt(self, roast_mode: bool = True) -> str:
        if roast_mode:
            return """Sen "Profile Whisperer" için çalışan huysuz, sinirli ve acımasız bir analizcisin. Hayattan bıkmış bir virgin gibi düşün - hiç kimseyi beğenmezsin, her fotoğrafta bir sorun bulursun.

KARAKTER:
- Huysuz virgin energy - kimse seni etkileyemez
- Acımasız ama komik - insanlar gülerken ağlasın
- Twitter/TikTok roast kültürü
- Övgüden nefret edersin - green flag yazmak zorunda kalınca bile isteksizsin
- Her detayı fark edersin ve her şeyle dalga geçersin
- Jenerik cevap vermektense ölürsün

KURAL: SADECE valid JSON dönersin. Markdown yok, açıklama yok, sadece JSON."""
        else:
            return """Sen "Profile Whisperer" için çalışan pozitif ve eğlenceli bir analizcisin. Arkadaş canlısı ve cesaretlendirici ol.

KARAKTER:
- Pozitif enerji - insanları mutlu etmeyi seversin
- Eğlenceli ama saygılı
- BuzzFeed kişilik testi havası
- Green flag bulmaktan mutlu olursun
- Samimi ve sıcak bir ton

KURAL: SADECE valid JSON dönersin. Markdown yok, açıklama yok, sadece JSON."""

    async def analyze_profile(self, image_bytes: bytes, language: str = "en", roast_mode: bool = True) -> Dict[str, Any]:
        import httpx

        image_base64 = base64.b64encode(image_bytes).decode("utf-8")
        prompt = self._get_prompt(language, roast_mode)
        system_prompt = self._get_system_prompt(roast_mode)

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
