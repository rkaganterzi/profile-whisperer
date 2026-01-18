import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Client-side Instagram profile fetcher
/// Uses the user's own IP to avoid server-side blocking
class InstagramClientService {
  static final InstagramClientService _instance = InstagramClientService._internal();
  factory InstagramClientService() => _instance;
  InstagramClientService._internal();

  final Random _random = Random();

  // User-Agent rotation for better success rate
  final List<String> _userAgents = [
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1',
    'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Mozilla/5.0 (Linux; Android 13; SM-S918B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Instagram 312.0.0.34.111 Android (33/13; 420dpi; 1080x2340; samsung; SM-G998B; p3s; exynos2100)',
  ];

  String get _randomUserAgent => _userAgents[_random.nextInt(_userAgents.length)];

  /// Extract username from URL or return as-is
  String? extractUsername(String urlOrUsername) {
    final text = urlOrUsername.trim().replaceAll('@', '').replaceAll(RegExp(r'/$'), '');

    // Handle URLs
    final urlMatch = RegExp(r'instagram\.com/([a-zA-Z0-9_.]+)').firstMatch(text);
    if (urlMatch != null) {
      final username = urlMatch.group(1)!;
      final reserved = ['p', 'reel', 'reels', 'stories', 'explore', 'accounts', 'direct', 'tv'];
      if (!reserved.contains(username.toLowerCase())) {
        return username;
      }
    }

    // Bare username validation
    if (RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(text) && text.length <= 30) {
      return text;
    }

    return null;
  }

  /// Fetch Instagram profile photo client-side
  /// Returns a File with the downloaded image, or null if failed
  Future<InstagramClientResult> fetchProfilePhoto(String urlOrUsername) async {
    final username = extractUsername(urlOrUsername);
    if (username == null) {
      return InstagramClientResult.error('invalid_username', 'Geçersiz kullanıcı adı');
    }

    debugPrint('[InstagramClient] Fetching profile: @$username');

    // Try multiple methods
    final methods = [
      () => _tryMobilePage(username),
      () => _tryDesktopPage(username),
      () => _tryWebProfileInfo(username),
    ];

    for (final method in methods) {
      try {
        final result = await method();
        if (result != null && result.imageFile != null) {
          debugPrint('[InstagramClient] Success with ${method.toString()}');
          return result;
        }
      } catch (e) {
        debugPrint('[InstagramClient] Method failed: $e');
        continue;
      }
    }

    return InstagramClientResult.error('all_methods_failed', 'Instagram erişimi engellendi');
  }

  /// Try fetching via mobile page (usually has less restrictions)
  Future<InstagramClientResult?> _tryMobilePage(String username) async {
    final url = 'https://www.instagram.com/$username/';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': _userAgents[_random.nextInt(2)], // Mobile user agents
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9,tr;q=0.8',
        'Cache-Control': 'no-cache',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      debugPrint('[InstagramClient] Mobile page status: ${response.statusCode}');
      return null;
    }

    return _parseHtmlAndDownload(username, response.body);
  }

  /// Try fetching via desktop page
  Future<InstagramClientResult?> _tryDesktopPage(String username) async {
    final url = 'https://www.instagram.com/$username/';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      return null;
    }

    return _parseHtmlAndDownload(username, response.body);
  }

  /// Try web_profile_info API endpoint
  Future<InstagramClientResult?> _tryWebProfileInfo(String username) async {
    final url = 'https://www.instagram.com/api/v1/users/web_profile_info/?username=$username';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': _randomUserAgent,
        'Accept': '*/*',
        'Accept-Language': 'en-US,en;q=0.9',
        'X-IG-App-ID': '936619743392459',
        'X-Requested-With': 'XMLHttpRequest',
        'Referer': 'https://www.instagram.com/$username/',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      return null;
    }

    try {
      // Extract profile pic URL from JSON response
      final body = response.body;
      final hdMatch = RegExp(r'"profile_pic_url_hd"\s*:\s*"([^"]+)"').firstMatch(body);
      final normalMatch = RegExp(r'"profile_pic_url"\s*:\s*"([^"]+)"').firstMatch(body);

      var picUrl = hdMatch?.group(1) ?? normalMatch?.group(1);
      if (picUrl != null) {
        picUrl = picUrl.replaceAll(r'\u0026', '&').replaceAll(r'\/', '/');
        final imageFile = await _downloadImage(picUrl);
        if (imageFile != null) {
          // Check if private
          final isPrivate = body.contains('"is_private":true');
          return InstagramClientResult.success(username, imageFile, isPrivate: isPrivate);
        }
      }
    } catch (e) {
      debugPrint('[InstagramClient] API parse error: $e');
    }

    return null;
  }

  /// Parse HTML and extract + download profile image
  Future<InstagramClientResult?> _parseHtmlAndDownload(String username, String html) async {
    // Check for login wall
    if (html.contains('loginForm') || html.contains('"require_login":true')) {
      debugPrint('[InstagramClient] Login required detected');
      return InstagramClientResult.error('login_required', 'Instagram giriş istiyor');
    }

    // Check for 404
    if (html.contains("Sorry, this page") || html.contains("Page Not Found")) {
      return InstagramClientResult.error('user_not_found', '@$username bulunamadı');
    }

    // Check if private
    final isPrivate = html.contains("This account is private") || html.contains('"is_private":true');

    // Try multiple patterns for profile pic
    final patterns = [
      RegExp(r'<meta property="og:image" content="([^"]+)"'),
      RegExp(r'"profile_pic_url_hd"\s*:\s*"([^"]+)"'),
      RegExp(r'"profile_pic_url"\s*:\s*"([^"]+)"'),
      RegExp(r'profilePicUrl["\x27]?\s*[:=]\s*["\x27]([^"\x27]+)["\x27]'),
    ];

    String? profilePicUrl;
    for (final pattern in patterns) {
      final match = pattern.firstMatch(html);
      if (match != null) {
        profilePicUrl = match.group(1)!
            .replaceAll(r'\u0026', '&')
            .replaceAll(r'\/', '/');
        break;
      }
    }

    if (profilePicUrl == null) {
      debugPrint('[InstagramClient] No profile pic URL found');
      return null;
    }

    debugPrint('[InstagramClient] Found profile pic URL');

    // Download the image
    final imageFile = await _downloadImage(profilePicUrl);
    if (imageFile == null) {
      return InstagramClientResult.error('download_failed', 'Görsel indirilemedi');
    }

    return InstagramClientResult.success(username, imageFile, isPrivate: isPrivate);
  }

  /// Download image and save to temp file
  Future<File?> _downloadImage(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': _randomUserAgent,
          'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
          'Referer': 'https://www.instagram.com/',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 && response.bodyBytes.length > 1000) {
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${tempDir.path}/instagram_$timestamp.jpg');
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('[InstagramClient] Image saved: ${file.path} (${response.bodyBytes.length} bytes)');
        return file;
      }
    } catch (e) {
      debugPrint('[InstagramClient] Image download error: $e');
    }
    return null;
  }
}

/// Result of client-side Instagram fetch
class InstagramClientResult {
  final bool success;
  final String? username;
  final File? imageFile;
  final bool isPrivate;
  final String? errorCode;
  final String? errorMessage;

  InstagramClientResult._({
    required this.success,
    this.username,
    this.imageFile,
    this.isPrivate = false,
    this.errorCode,
    this.errorMessage,
  });

  factory InstagramClientResult.success(String username, File imageFile, {bool isPrivate = false}) {
    return InstagramClientResult._(
      success: true,
      username: username,
      imageFile: imageFile,
      isPrivate: isPrivate,
    );
  }

  factory InstagramClientResult.error(String code, String message) {
    return InstagramClientResult._(
      success: false,
      errorCode: code,
      errorMessage: message,
    );
  }
}
