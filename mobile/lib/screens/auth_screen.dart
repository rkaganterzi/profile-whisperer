import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/seductive_colors.dart';
import '../widgets/core/glow_button.dart';
import '../widgets/core/neon_text.dart';
import '../widgets/effects/light_leak.dart';
import '../animations/page_transitions.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
    HapticFeedback.selectionClick();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.lightImpact();
    final authProvider = context.read<AuthProvider>();

    bool success;
    if (_isLogin) {
      success = await authProvider.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      success = await authProvider.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    }

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        SeductivePageRoute(page: const HomeScreen()),
      );
    } else if (!success && mounted) {
      _showError(authProvider.errorMessage ?? 'Bir hata olustu');
    }
  }

  Future<void> _signInWithGoogle() async {
    HapticFeedback.lightImpact();
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        SeductivePageRoute(page: const HomeScreen()),
      );
    } else if (!success && mounted) {
      _showError(authProvider.errorMessage ?? 'Google ile giris basarisiz');
    }
  }

  Future<void> _continueAsGuest() async {
    HapticFeedback.lightImpact();
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.continueAsGuest();

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        SeductivePageRoute(page: const HomeScreen()),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SeductiveColors.dangerRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: SeductiveColors.voidBlack,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: LightLeak(
          topLeft: true,
          bottomRight: true,
          intensity: 0.2,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: SeductiveColors.primaryGradient,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: SeductiveColors.neonGlow(
                          color: SeductiveColors.neonMagenta,
                          blur: 25,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.psychology_rounded,
                          size: 50,
                          color: SeductiveColors.lunarWhite,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Center(
                    child: GradientText(
                      'Profile Whisperer',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _isLogin ? 'Tekrar hos geldin!' : 'Hesap olustur',
                      style: const TextStyle(
                        fontSize: 16,
                        color: SeductiveColors.silverMist,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_isLogin) ...[
                          _buildTextField(
                            controller: _nameController,
                            label: 'Ad Soyad',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lutfen adinizi girin';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        _buildTextField(
                          controller: _emailController,
                          label: 'E-posta',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lutfen e-posta girin';
                            }
                            if (!value.contains('@')) {
                              return 'Gecerli bir e-posta girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Sifre',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: SeductiveColors.dustyRose,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lutfen sifre girin';
                            }
                            if (value.length < 6) {
                              return 'Sifre en az 6 karakter olmali';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_isLogin) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showForgotPasswordDialog(),
                        child: const Text(
                          'Sifremi Unuttum',
                          style: TextStyle(color: SeductiveColors.neonMagenta),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Submit button
                  GlowButton(
                    text: _isLogin ? 'Giris Yap' : 'Kayit Ol',
                    isLoading: authProvider.isLoading,
                    onPressed: _submitForm,
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: SeductiveColors.smokyViolet,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'veya',
                          style: TextStyle(color: SeductiveColors.dustyRose),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: SeductiveColors.smokyViolet,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Google sign in
                  _buildSocialButton(
                    text: 'Google ile devam et',
                    icon: 'G',
                    onPressed: _signInWithGoogle,
                    isLoading: authProvider.isLoading,
                  ),
                  const SizedBox(height: 12),
                  // Guest mode
                  _buildOutlinedButton(
                    text: 'Misafir olarak devam et',
                    onPressed: _continueAsGuest,
                    isLoading: authProvider.isLoading,
                  ),
                  const SizedBox(height: 32),
                  // Toggle login/signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin ? 'Hesabin yok mu?' : 'Zaten hesabin var mi?',
                        style: const TextStyle(color: SeductiveColors.silverMist),
                      ),
                      TextButton(
                        onPressed: _toggleMode,
                        child: Text(
                          _isLogin ? 'Kayit Ol' : 'Giris Yap',
                          style: const TextStyle(
                            color: SeductiveColors.neonMagenta,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: SeductiveColors.lunarWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: SeductiveColors.dustyRose),
        prefixIcon: Icon(icon, color: SeductiveColors.dustyRose),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: SeductiveColors.obsidianDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SeductiveColors.neonMagenta, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SeductiveColors.dangerRed, width: 1),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required String icon,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: SeductiveColors.velvetPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SeductiveColors.smokyViolet),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  color: SeductiveColors.lunarWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SeductiveColors.neonMagenta.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: SeductiveColors.neonMagenta,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SeductiveColors.velvetPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Sifre Sifirla',
          style: TextStyle(color: SeductiveColors.lunarWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'E-posta adresinize sifre sifirlama baglantisi gonderecegiz.',
              style: TextStyle(color: SeductiveColors.silverMist),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: SeductiveColors.lunarWhite),
              decoration: InputDecoration(
                labelText: 'E-posta',
                labelStyle: const TextStyle(color: SeductiveColors.dustyRose),
                filled: true,
                fillColor: SeductiveColors.obsidianDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Iptal',
              style: TextStyle(color: SeductiveColors.dustyRose),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final authProvider = context.read<AuthProvider>();
                final success = await authProvider.sendPasswordResetEmail(
                  emailController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Sifre sifirlama e-postasi gonderildi!'
                          : 'E-posta gonderilemedi.',
                    ),
                    backgroundColor:
                        success ? SeductiveColors.successGreen : SeductiveColors.dangerRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Gonder',
              style: TextStyle(color: SeductiveColors.neonMagenta),
            ),
          ),
        ],
      ),
    );
  }
}
