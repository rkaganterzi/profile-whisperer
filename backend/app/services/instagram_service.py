import re
import json
import httpx
import random
import asyncio
from typing import Optional, List
from dataclasses import dataclass


# Rotating User Agents
USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:122.0) Gecko/20100101 Firefox/122.0",
]

APP_IDS = [
    "936619743392459",
    "1217981644879628",
    "124024574287414",
]


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
    # Deep analysis fields
    post_captions: List[str] = None
    post_like_counts: List[int] = None
    post_comment_counts: List[int] = None

    def __post_init__(self):
        if self.post_captions is None:
            self.post_captions = []
        if self.post_like_counts is None:
            self.post_like_counts = []
        if self.post_comment_counts is None:
            self.post_comment_counts = []


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

    async def fetch_profile_deep(self, url_or_username: str, max_posts: int = 9) -> InstagramProfile:
        """Fetch Instagram profile with deep analysis data (6-9 posts with metadata)."""
        username = self.extract_username(url_or_username)

        if not username:
            return self._error_profile("", "invalid_username")

        print(f"[Instagram] Deep fetching profile: @{username} (max {max_posts} posts)")

        # Try multiple methods for deep fetch
        methods = [
            (self._try_web_profile_info_deep, "web_profile_info_deep"),
            (self._try_mobile_api_deep, "mobile_api_deep"),
            (self._try_graphql_deep, "graphql_deep"),
            (self._try_html_scrape_deep, "html_scrape_deep"),
        ]

        for method, name in methods:
            try:
                print(f"[Instagram] Trying {name}...")
                result = await method(username, max_posts)
                if result and not result.error and len(result.post_images) >= 3:
                    print(f"[Instagram] Deep fetch success with {name}: {len(result.post_images)} posts")
                    return result
                elif result and result.error:
                    print(f"[Instagram] {name} failed: {result.error}")
            except Exception as e:
                print(f"[Instagram] {name} error: {e}")
                continue

        # Fallback to regular fetch if deep fetch fails
        print("[Instagram] Deep fetch failed, falling back to regular fetch")
        return await self.fetch_profile(url_or_username)

    async def _try_mobile_api_deep(self, username: str, max_posts: int = 9) -> Optional[InstagramProfile]:
        """Try Instagram Mobile API for deep analysis."""
        url = f"https://i.instagram.com/api/v1/users/web_profile_info/?username={username}"

        user_agent = "Instagram 275.0.0.27.98 Android (33/13; 420dpi; 1080x2400; samsung; SM-G991B; o1s; exynos2100; en_US; 458229237)"

        headers = {
            "User-Agent": user_agent,
            "Accept": "*/*",
            "Accept-Language": "en-US,en;q=0.9",
            "Accept-Encoding": "gzip, deflate",
            "X-IG-App-ID": "567067343352427",
            "X-IG-Device-ID": "android-" + ''.join(random.choices('0123456789abcdef', k=16)),
            "X-IG-Android-ID": "android-" + ''.join(random.choices('0123456789abcdef', k=16)),
            "X-FB-HTTP-Engine": "Liger",
            "Connection": "keep-alive",
        }

        await asyncio.sleep(random.uniform(0.5, 1.5))

        async with httpx.AsyncClient(timeout=20.0, follow_redirects=True) as client:
            try:
                response = await client.get(url, headers=headers)
                print(f"[Instagram] Mobile API response: {response.status_code}")

                if response.status_code == 429:
                    print("[Instagram] Mobile API rate limited")
                    return None

                if response.status_code != 200:
                    return None

                data = response.json()
                user = data.get("data", {}).get("user")

                if not user:
                    return None

                profile_pic_url = user.get("profile_pic_url_hd") or user.get("profile_pic_url")
                is_private = user.get("is_private", False)

                # Download profile pic
                await asyncio.sleep(random.uniform(0.2, 0.5))
                profile_pic_bytes = await self._download_image(client, profile_pic_url)

                post_images = []
                post_captions = []
                post_like_counts = []
                post_comment_counts = []

                if not is_private:
                    edges = user.get("edge_owner_to_timeline_media", {}).get("edges", [])
                    for i, edge in enumerate(edges[:max_posts]):
                        node = edge.get("node", {})
                        img_url = node.get("display_url")

                        if img_url:
                            if i > 0:
                                await asyncio.sleep(random.uniform(0.2, 0.4))

                            img_bytes = await self._download_image(client, img_url)
                            if img_bytes:
                                post_images.append(img_bytes)

                                caption_edges = node.get("edge_media_to_caption", {}).get("edges", [])
                                caption = caption_edges[0].get("node", {}).get("text", "") if caption_edges else ""
                                post_captions.append(caption)

                                like_count = node.get("edge_liked_by", {}).get("count", 0) or node.get("edge_media_preview_like", {}).get("count", 0)
                                post_like_counts.append(like_count)

                                comment_count = node.get("edge_media_to_comment", {}).get("count", 0) or node.get("edge_media_preview_comment", {}).get("count", 0)
                                post_comment_counts.append(comment_count)

                print(f"[Instagram] Mobile API deep: {len(post_images)} posts")

                if len(post_images) < 3:
                    return None

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
                    error=None,
                    post_captions=post_captions,
                    post_like_counts=post_like_counts,
                    post_comment_counts=post_comment_counts,
                )
            except Exception as e:
                print(f"[Instagram] Mobile API exception: {e}")
                return None

    async def _try_graphql_deep(self, username: str, max_posts: int = 9) -> Optional[InstagramProfile]:
        """Try Instagram GraphQL API for deep analysis."""
        # First get user ID from profile page
        profile_url = f"https://www.instagram.com/{username}/"
        user_agent = random.choice(USER_AGENTS)

        headers = {
            "User-Agent": user_agent,
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
            "Accept-Encoding": "gzip, deflate, br",
            "Connection": "keep-alive",
        }

        await asyncio.sleep(random.uniform(0.5, 1.0))

        async with httpx.AsyncClient(timeout=20.0, follow_redirects=True) as client:
            try:
                # Get profile page to extract user_id
                response = await client.get(profile_url, headers=headers)
                print(f"[Instagram] GraphQL profile page: {response.status_code}")

                if response.status_code != 200:
                    return None

                html = response.text

                # Try to extract user_id from various patterns
                user_id = None
                id_patterns = [
                    r'"user_id"\s*:\s*"(\d+)"',
                    r'"profilePage_(\d+)"',
                    r'"id"\s*:\s*"(\d+)".*?"username"\s*:\s*"' + username + '"',
                    r'logging_page_id["\']?\s*:\s*["\']?profilePage_(\d+)',
                ]

                for pattern in id_patterns:
                    match = re.search(pattern, html)
                    if match:
                        user_id = match.group(1)
                        print(f"[Instagram] Found user_id: {user_id}")
                        break

                # Extract data from shared data in page
                shared_data_match = re.search(
                    r'<script type="application/json" data-sjs>(\{.*?"require".*?\})</script>',
                    html,
                    re.DOTALL
                )

                profile_pic_url = None
                bio = None
                full_name = None
                is_private = False
                follower_count = None
                following_count = None
                post_count = None

                # Extract from meta tags as backup
                og_image = re.search(r'<meta property="og:image" content="([^"]+)"', html)
                if og_image:
                    profile_pic_url = og_image.group(1)

                og_desc = re.search(r'<meta property="og:description" content="([^"]+)"', html)
                if og_desc:
                    desc = og_desc.group(1)
                    # Parse "X Followers, Y Following, Z Posts - BIO"
                    stats_match = re.search(r'([\d,KMB.]+)\s*Follower', desc, re.IGNORECASE)
                    if stats_match:
                        follower_str = stats_match.group(1).replace(',', '')
                        if 'K' in follower_str.upper():
                            follower_count = int(float(follower_str.upper().replace('K', '')) * 1000)
                        elif 'M' in follower_str.upper():
                            follower_count = int(float(follower_str.upper().replace('M', '')) * 1000000)
                        else:
                            try:
                                follower_count = int(follower_str)
                            except:
                                pass
                    bio_match = re.search(r'Posts?\s*[-–]\s*(.+)$', desc)
                    if bio_match:
                        bio = bio_match.group(1).strip()

                og_title = re.search(r'<meta property="og:title" content="([^"]+)"', html)
                if og_title:
                    title = og_title.group(1)
                    name_match = re.search(r'^([^(@]+)', title)
                    if name_match:
                        full_name = name_match.group(1).strip()

                # Check if private
                if 'This Account is Private' in html or '"is_private":true' in html:
                    is_private = True

                # Find all image URLs
                image_urls = []

                # Pattern for display URLs in JSON
                display_patterns = [
                    r'"display_url"\s*:\s*"([^"]+)"',
                    r'"src"\s*:\s*"(https://[^"]*cdninstagram[^"]*)"',
                    r'"display_resources".*?"src"\s*:\s*"([^"]+)"',
                ]

                for pattern in display_patterns:
                    matches = re.findall(pattern, html)
                    for match in matches:
                        clean_url = match.replace('\\u0026', '&').replace('\\/', '/')
                        if clean_url not in image_urls and 'cdninstagram' in clean_url:
                            image_urls.append(clean_url)

                # Also try to find caption data
                caption_pattern = r'"edge_media_to_caption":\{"edges":\[\{"node":\{"text":"([^"]+)"\}\}\]\}'
                captions_found = re.findall(caption_pattern, html)

                # Download profile pic
                profile_pic_bytes = None
                if profile_pic_url:
                    await asyncio.sleep(random.uniform(0.2, 0.5))
                    profile_pic_bytes = await self._download_image(client, profile_pic_url)

                # Download post images
                post_images = []
                post_captions = []
                post_like_counts = []
                post_comment_counts = []

                # Remove duplicates and profile pic from images
                unique_images = []
                for url in image_urls:
                    if url not in unique_images:
                        unique_images.append(url)

                for i, img_url in enumerate(unique_images[:max_posts]):
                    if i > 0:
                        await asyncio.sleep(random.uniform(0.2, 0.4))

                    img_bytes = await self._download_image(client, img_url)
                    if img_bytes and len(img_bytes) > 10000:  # Skip small images
                        post_images.append(img_bytes)

                        # Add caption if available
                        if i < len(captions_found):
                            post_captions.append(captions_found[i])
                        else:
                            post_captions.append("")

                        post_like_counts.append(0)
                        post_comment_counts.append(0)

                print(f"[Instagram] GraphQL deep: {len(post_images)} posts")

                if not profile_pic_bytes and len(post_images) < 3:
                    return self._error_profile(username, "insufficient_data")

                return InstagramProfile(
                    username=username,
                    full_name=full_name,
                    bio=bio,
                    profile_pic_url=profile_pic_url,
                    profile_pic_bytes=profile_pic_bytes,
                    post_images=post_images,
                    follower_count=follower_count,
                    following_count=following_count,
                    post_count=post_count,
                    is_private=is_private,
                    error=None,
                    post_captions=post_captions,
                    post_like_counts=post_like_counts,
                    post_comment_counts=post_comment_counts,
                )
            except Exception as e:
                print(f"[Instagram] GraphQL deep exception: {e}")
                return None

    async def _try_html_scrape_deep(self, username: str, max_posts: int = 9) -> Optional[InstagramProfile]:
        """Try scraping Instagram HTML page for deep analysis data."""
        url = f"https://www.instagram.com/{username}/"

        user_agent = random.choice(USER_AGENTS)
        headers = {
            "User-Agent": user_agent,
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
            "Accept-Encoding": "gzip, deflate, br",
            "Connection": "keep-alive",
            "Upgrade-Insecure-Requests": "1",
            "Sec-Fetch-Dest": "document",
            "Sec-Fetch-Mode": "navigate",
            "Sec-Fetch-Site": "none",
            "Sec-Fetch-User": "?1",
            "Cache-Control": "max-age=0",
            "Cookie": "ig_did=; ig_nrcb=1; csrftoken=; mid=;",  # Empty cookie structure
        }

        await asyncio.sleep(random.uniform(0.5, 1.5))

        async with httpx.AsyncClient(timeout=20.0, follow_redirects=True) as client:
            try:
                response = await client.get(url, headers=headers)
                print(f"[Instagram] HTML scrape response: {response.status_code}")

                if response.status_code != 200:
                    return None

                html = response.text

                # Try to find JSON data in the page
                # Look for _sharedData or similar patterns
                patterns = [
                    r'<script type="application/ld\+json"[^>]*>(\{.*?"@type"\s*:\s*"Person".*?\})</script>',
                    r'window\._sharedData\s*=\s*(\{.*?\});</script>',
                    r'"ProfilePage":\[(\{.*?\})\]',
                ]

                user_data = None
                for pattern in patterns:
                    match = re.search(pattern, html, re.DOTALL)
                    if match:
                        try:
                            user_data = json.loads(match.group(1))
                            print(f"[Instagram] Found user data via pattern")
                            break
                        except json.JSONDecodeError:
                            continue

                # Extract basic info from meta tags
                bio = None
                full_name = None
                profile_pic_url = None

                # Meta description often contains bio
                meta_desc = re.search(r'<meta name="description" content="([^"]*)"', html)
                if meta_desc:
                    bio = meta_desc.group(1)

                # OG image for profile pic
                og_image = re.search(r'<meta property="og:image" content="([^"]+)"', html)
                if og_image:
                    profile_pic_url = og_image.group(1)

                # OG title for name
                og_title = re.search(r'<meta property="og:title" content="([^"]+)"', html)
                if og_title:
                    title = og_title.group(1)
                    name_match = re.search(r'^([^(@]+)', title)
                    if name_match:
                        full_name = name_match.group(1).strip()

                # Look for image URLs in the HTML
                image_urls = []
                # Find Instagram CDN image URLs
                cdn_patterns = [
                    r'"display_url"\s*:\s*"([^"]+)"',
                    r'"src"\s*:\s*"(https://[^"]*instagram[^"]*\.jpg[^"]*)"',
                    r'"thumbnail_src"\s*:\s*"([^"]+)"',
                ]

                for pattern in cdn_patterns:
                    matches = re.findall(pattern, html)
                    for match in matches:
                        clean_url = match.replace('\\u0026', '&').replace('\\/', '/')
                        if 'instagram' in clean_url and clean_url not in image_urls:
                            image_urls.append(clean_url)

                if not profile_pic_url and not image_urls:
                    return self._error_profile(username, "no_images_found")

                # Download images
                profile_pic_bytes = None
                if profile_pic_url:
                    await asyncio.sleep(random.uniform(0.2, 0.5))
                    profile_pic_bytes = await self._download_image(client, profile_pic_url)

                post_images = []
                post_captions = []
                post_like_counts = []
                post_comment_counts = []

                # Download post images (skip first as it might be profile pic)
                for i, img_url in enumerate(image_urls[:max_posts + 1]):
                    if i > 0:
                        await asyncio.sleep(random.uniform(0.2, 0.4))
                    img_bytes = await self._download_image(client, img_url)
                    if img_bytes and len(img_bytes) > 5000:  # Skip tiny images
                        post_images.append(img_bytes)
                        post_captions.append("")  # No captions from HTML scrape
                        post_like_counts.append(0)
                        post_comment_counts.append(0)

                        if len(post_images) >= max_posts:
                            break

                print(f"[Instagram] HTML scrape: {len(post_images)} posts found")

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
                    is_private=False,
                    error=None,
                    post_captions=post_captions,
                    post_like_counts=post_like_counts,
                    post_comment_counts=post_comment_counts,
                )
            except Exception as e:
                print(f"[Instagram] HTML scrape exception: {e}")
                return None

    async def _try_web_profile_info_deep(self, username: str, max_posts: int = 9) -> Optional[InstagramProfile]:
        """Try Instagram's web_profile_info endpoint for deep analysis."""
        url = f"https://www.instagram.com/api/v1/users/web_profile_info/?username={username}"

        # Rotate headers for each request
        user_agent = random.choice(USER_AGENTS)
        app_id = random.choice(APP_IDS)

        headers = {
            "User-Agent": user_agent,
            "Accept": "*/*",
            "Accept-Language": "en-US,en;q=0.9,tr;q=0.8",
            "Accept-Encoding": "gzip, deflate, br",
            "X-IG-App-ID": app_id,
            "X-ASBD-ID": "129477",
            "X-IG-WWW-Claim": "0",
            "X-Requested-With": "XMLHttpRequest",
            "Sec-Fetch-Dest": "empty",
            "Sec-Fetch-Mode": "cors",
            "Sec-Fetch-Site": "same-origin",
            "Sec-Ch-Ua": '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
            "Sec-Ch-Ua-Mobile": "?0",
            "Sec-Ch-Ua-Platform": '"Windows"',
            "Referer": f"https://www.instagram.com/{username}/",
            "Origin": "https://www.instagram.com",
        }

        # Add small random delay to seem more human
        await asyncio.sleep(random.uniform(0.5, 1.5))

        async with httpx.AsyncClient(timeout=20.0, follow_redirects=True) as client:
            try:
                response = await client.get(url, headers=headers)
                print(f"[Instagram] Deep API response: {response.status_code}")

                if response.status_code == 429:
                    print("[Instagram] Rate limited, waiting...")
                    await asyncio.sleep(3)
                    return None

                if response.status_code != 200:
                    return None

                data = response.json()
                user = data.get("data", {}).get("user")

                if not user:
                    return self._error_profile(username, "user_not_found")

                profile_pic_url = user.get("profile_pic_url_hd") or user.get("profile_pic_url")
                is_private = user.get("is_private", False)

                # Download profile pic with delay
                await asyncio.sleep(random.uniform(0.3, 0.8))
                profile_pic_bytes = await self._download_image(client, profile_pic_url)

                # Initialize deep analysis data
                post_images = []
                post_captions = []
                post_like_counts = []
                post_comment_counts = []

                if not is_private:
                    edges = user.get("edge_owner_to_timeline_media", {}).get("edges", [])
                    for i, edge in enumerate(edges[:max_posts]):
                        node = edge.get("node", {})

                        # Get image URL
                        img_url = node.get("display_url")
                        if img_url:
                            # Small delay between image downloads
                            if i > 0:
                                await asyncio.sleep(random.uniform(0.2, 0.5))

                            img_bytes = await self._download_image(client, img_url)
                            if img_bytes:
                                post_images.append(img_bytes)

                                # Get caption
                                caption_edges = node.get("edge_media_to_caption", {}).get("edges", [])
                                caption = ""
                                if caption_edges:
                                    caption = caption_edges[0].get("node", {}).get("text", "")
                                post_captions.append(caption)

                                # Get like count
                                like_count = node.get("edge_liked_by", {}).get("count", 0)
                                if like_count == 0:
                                    like_count = node.get("edge_media_preview_like", {}).get("count", 0)
                                post_like_counts.append(like_count)

                                # Get comment count
                                comment_count = node.get("edge_media_to_comment", {}).get("count", 0)
                                if comment_count == 0:
                                    comment_count = node.get("edge_media_preview_comment", {}).get("count", 0)
                                post_comment_counts.append(comment_count)

                if not profile_pic_bytes and not post_images:
                    return self._error_profile(username, "no_images_found")

                print(f"[Instagram] Deep fetch: {len(post_images)} posts, {len(post_captions)} captions")

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
                    error=None,
                    post_captions=post_captions,
                    post_like_counts=post_like_counts,
                    post_comment_counts=post_comment_counts,
                )
            except Exception as e:
                print(f"[Instagram] Deep fetch exception: {e}")
                return None

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
