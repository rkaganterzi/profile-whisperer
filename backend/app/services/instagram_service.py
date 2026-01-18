import re
import json
import httpx
from typing import Optional, List
from dataclasses import dataclass


@dataclass
class InstagramProfile:
    username: str
    full_name: Optional[str]
    bio: Optional[str]
    profile_pic_url: Optional[str]
    profile_pic_bytes: Optional[bytes]
    post_images: List[bytes]
    follower_count: Optional[int]
    following_count: Optional[int]
    post_count: Optional[int]
    is_private: bool
    error: Optional[str] = None


class InstagramScraper:
    """
    Multi-strategy Instagram profile scraper.
    """

    @staticmethod
    def extract_username(url_or_username: str) -> Optional[str]:
        """Extract username from Instagram URL or return as-is."""
        text = url_or_username.strip().strip("@").rstrip("/")

        # Handle URLs
        match = re.search(r"instagram\.com/([a-zA-Z0-9_.]+)", text)
        if match:
            username = match.group(1)
            if username.lower() not in ['p', 'reel', 'reels', 'stories', 'explore', 'accounts', 'direct']:
                return username

        # Bare username
        if re.match(r"^[a-zA-Z0-9_.]+$", text):
            return text

        return None

    async def fetch_profile(self, url_or_username: str) -> InstagramProfile:
        """Fetch Instagram profile using multiple methods."""
        username = self.extract_username(url_or_username)

        if not username:
            return self._error_profile("", "invalid_username")

        print(f"[Instagram] Fetching profile: @{username}")

        # Try methods in order
        methods = [
            self._try_web_profile_info,
            self._try_graphql_api,
            self._try_mobile_page,
            self._try_desktop_page,
        ]

        for method in methods:
            try:
                result = await method(username)
                if result and not result.error:
                    print(f"[Instagram] Success with {method.__name__}")
                    return result
                elif result and result.error:
                    print(f"[Instagram] {method.__name__} failed: {result.error}")
            except Exception as e:
                print(f"[Instagram] {method.__name__} error: {e}")
                continue

        return self._error_profile(username, "all_methods_failed")

    async def _try_web_profile_info(self, username: str) -> Optional[InstagramProfile]:
        """Try Instagram's web_profile_info endpoint."""
        url = f"https://www.instagram.com/api/v1/users/web_profile_info/?username={username}"

        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/121.0.0.0 Safari/537.36",
            "Accept": "*/*",
            "Accept-Language": "en-US,en;q=0.9",
            "X-IG-App-ID": "936619743392459",
            "X-Requested-With": "XMLHttpRequest",
            "Referer": f"https://www.instagram.com/{username}/",
        }

        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(url, headers=headers)

            if response.status_code != 200:
                return None

            data = response.json()
            user = data.get("data", {}).get("user")

            if not user:
                return self._error_profile(username, "user_not_found")

            profile_pic_url = user.get("profile_pic_url_hd") or user.get("profile_pic_url")
            is_private = user.get("is_private", False)

            # Download profile pic
            profile_pic_bytes = await self._download_image(client, profile_pic_url)

            # Get post images if public
            post_images = []
            if not is_private:
                edges = user.get("edge_owner_to_timeline_media", {}).get("edges", [])
                for edge in edges[:3]:
                    img_url = edge.get("node", {}).get("display_url")
                    if img_url:
                        img_bytes = await self._download_image(client, img_url)
                        if img_bytes:
                            post_images.append(img_bytes)

            if not profile_pic_bytes and not post_images:
                return self._error_profile(username, "no_images_found")

            return InstagramProfile(
                username=username,
                full_name=user.get("full_name"),
                bio=user.get("biography"),
                profile_pic_url=profile_pic_url,
                profile_pic_bytes=profile_pic_bytes,
                post_images=post_images,
                follower_count=user.get("edge_followed_by", {}).get("count"),
                following_count=user.get("edge_follow", {}).get("count"),
                post_count=user.get("edge_owner_to_timeline_media", {}).get("count"),
                is_private=is_private,
                error=None
            )

    async def _try_graphql_api(self, username: str) -> Optional[InstagramProfile]:
        """Try Instagram's GraphQL endpoint."""
        # First get user ID from the page
        page_url = f"https://www.instagram.com/{username}/"

        headers = {
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/121.0.0.0 Safari/537.36",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        }

        async with httpx.AsyncClient(timeout=10.0, follow_redirects=True) as client:
            response = await client.get(page_url, headers=headers)

            if response.status_code != 200:
                return None

            html = response.text

            # Try to find shared data JSON
            match = re.search(r'window\._sharedData\s*=\s*({.+?});</script>', html)
            if match:
                try:
                    shared_data = json.loads(match.group(1))
                    user = shared_data.get("entry_data", {}).get("ProfilePage", [{}])[0].get("graphql", {}).get("user")
                    if user:
                        return await self._parse_user_data(client, username, user)
                except:
                    pass

            # Try additional data JSON
            match = re.search(r'"user":\s*({[^}]+?"username":\s*"' + username + '"[^}]+})', html)
            if match:
                try:
                    user_json = match.group(1)
                    # This is partial, try to extract what we can
                    pic_match = re.search(r'"profile_pic_url(?:_hd)?":"([^"]+)"', html)
                    if pic_match:
                        pic_url = pic_match.group(1).replace("\\u0026", "&")
                        pic_bytes = await self._download_image(client, pic_url)
                        if pic_bytes:
                            return InstagramProfile(
                                username=username,
                                full_name=None,
                                bio=None,
                                profile_pic_url=pic_url,
                                profile_pic_bytes=pic_bytes,
                                post_images=[],
                                follower_count=None,
                                following_count=None,
                                post_count=None,
                                is_private='"is_private":true' in html,
                                error=None
                            )
                except:
                    pass

        return None

    async def _try_mobile_page(self, username: str) -> Optional[InstagramProfile]:
        """Try mobile Instagram page."""
        url = f"https://www.instagram.com/{username}/"

        headers = {
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148 Safari/604.1",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
        }

        async with httpx.AsyncClient(timeout=10.0, follow_redirects=True) as client:
            response = await client.get(url, headers=headers)

            if response.status_code != 200:
                return None

            html = response.text
            return await self._extract_from_html(client, username, html)

    async def _try_desktop_page(self, username: str) -> Optional[InstagramProfile]:
        """Try desktop Instagram page with various extraction methods."""
        url = f"https://www.instagram.com/{username}/"

        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/121.0.0.0 Safari/537.36",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
            "Cache-Control": "no-cache",
        }

        async with httpx.AsyncClient(timeout=10.0, follow_redirects=True) as client:
            response = await client.get(url, headers=headers)

            if response.status_code != 200:
                return None

            html = response.text
            return await self._extract_from_html(client, username, html)

    async def _extract_from_html(self, client: httpx.AsyncClient, username: str, html: str) -> Optional[InstagramProfile]:
        """Extract profile data from HTML using multiple patterns."""

        # Check for login wall
        if 'loginForm' in html.lower() or '"require_login":true' in html:
            return self._error_profile(username, "login_required")

        # Check for 404
        if "Sorry, this page" in html or "Page Not Found" in html:
            return self._error_profile(username, "user_not_found")

        is_private = "This account is private" in html or '"is_private":true' in html

        # Try multiple patterns for profile pic
        profile_pic_url = None
        profile_pic_patterns = [
            r'<meta property="og:image" content="([^"]+)"',
            r'"profile_pic_url_hd":"([^"]+)"',
            r'"profile_pic_url":"([^"]+)"',
            r'profilePicUrl["\']?\s*[:=]\s*["\']([^"\']+)["\']',
        ]

        for pattern in profile_pic_patterns:
            match = re.search(pattern, html)
            if match:
                profile_pic_url = match.group(1).replace("\\u0026", "&").replace("\\/", "/")
                break

        if not profile_pic_url:
            return self._error_profile(username, "no_profile_pic")

        # Download profile pic
        profile_pic_bytes = await self._download_image(client, profile_pic_url)

        if not profile_pic_bytes:
            return self._error_profile(username, "download_failed")

        # Try to get post images
        post_images = []
        if not is_private:
            post_patterns = [
                r'"display_url":"([^"]+)"',
                r'"src":"(https://[^"]*cdninstagram[^"]*\.jpg[^"]*)"',
            ]

            found_urls = set()
            for pattern in post_patterns:
                for match in re.finditer(pattern, html):
                    url = match.group(1).replace("\\u0026", "&").replace("\\/", "/")
                    if "150x150" not in url and "s150x150" not in url and url not in found_urls:
                        found_urls.add(url)
                        if len(found_urls) >= 3:
                            break
                if len(found_urls) >= 3:
                    break

            for url in list(found_urls)[:3]:
                img_bytes = await self._download_image(client, url)
                if img_bytes:
                    post_images.append(img_bytes)

        # Extract metadata
        full_name = None
        name_match = re.search(r'<meta property="og:title" content="([^"]+)"', html)
        if name_match:
            full_name = name_match.group(1)
            full_name = re.sub(r'\s*[•\|@].*$', '', full_name).strip()

        bio = None
        bio_match = re.search(r'<meta property="og:description" content="([^"]+)"', html)
        if bio_match:
            bio = bio_match.group(1)

        return InstagramProfile(
            username=username,
            full_name=full_name,
            bio=bio,
            profile_pic_url=profile_pic_url,
            profile_pic_bytes=profile_pic_bytes,
            post_images=post_images,
            follower_count=None,
            following_count=None,
            post_count=None,
            is_private=is_private,
            error=None
        )

    async def _parse_user_data(self, client: httpx.AsyncClient, username: str, user: dict) -> InstagramProfile:
        """Parse user data from GraphQL response."""
        profile_pic_url = user.get("profile_pic_url_hd") or user.get("profile_pic_url")
        is_private = user.get("is_private", False)

        profile_pic_bytes = await self._download_image(client, profile_pic_url)

        post_images = []
        if not is_private:
            edges = user.get("edge_owner_to_timeline_media", {}).get("edges", [])
            for edge in edges[:3]:
                img_url = edge.get("node", {}).get("display_url")
                if img_url:
                    img_bytes = await self._download_image(client, img_url)
                    if img_bytes:
                        post_images.append(img_bytes)

        if not profile_pic_bytes and not post_images:
            return self._error_profile(username, "no_images_found")

        return InstagramProfile(
            username=username,
            full_name=user.get("full_name"),
            bio=user.get("biography"),
            profile_pic_url=profile_pic_url,
            profile_pic_bytes=profile_pic_bytes,
            post_images=post_images,
            follower_count=user.get("edge_followed_by", {}).get("count"),
            following_count=user.get("edge_follow", {}).get("count"),
            post_count=user.get("edge_owner_to_timeline_media", {}).get("count"),
            is_private=is_private,
            error=None
        )

    async def _download_image(self, client: httpx.AsyncClient, url: Optional[str]) -> Optional[bytes]:
        """Download image from URL."""
        if not url:
            return None

        try:
            headers = {
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                "Accept": "image/avif,image/webp,image/apng,image/*,*/*;q=0.8",
                "Referer": "https://www.instagram.com/",
            }
            response = await client.get(url, headers=headers, timeout=10.0)
            if response.status_code == 200 and len(response.content) > 1000:
                return response.content
        except Exception as e:
            print(f"[Instagram] Image download failed: {e}")

        return None

    def _error_profile(self, username: str, error: str) -> InstagramProfile:
        """Create an error profile."""
        return InstagramProfile(
            username=username,
            full_name=None,
            bio=None,
            profile_pic_url=None,
            profile_pic_bytes=None,
            post_images=[],
            follower_count=None,
            following_count=None,
            post_count=None,
            is_private=True,
            error=error
        )


# Singleton
_instagram_scraper: Optional[InstagramScraper] = None


def get_instagram_scraper() -> InstagramScraper:
    global _instagram_scraper
    if _instagram_scraper is None:
        _instagram_scraper = InstagramScraper()
    return _instagram_scraper
