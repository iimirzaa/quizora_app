import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/core/controllers/auth_controller.dart';
import 'package:quiz_app/core/services/token_service.dart';
import 'package:quiz_app/core/widgets/FloatingBubbles.dart';
import 'package:quiz_app/core/widgets/GradientButton.dart';
import 'package:quiz_app/features/Authentication/login/view/LoginView.dart';
import 'package:quiz_app/features/dashboard/studentDashboard/view/studentDashboardView.dart';
import 'package:quiz_app/features/dashboard/teacherdashboard/view/teacherDashboard.dart';


class GetstartedView extends StatefulWidget {
  const GetstartedView({super.key});

  @override
  State<GetstartedView> createState() => _GetstartedViewState();
}

class _GetstartedViewState extends State<GetstartedView>
    with SingleTickerProviderStateMixin {

  late AnimationController _logoController;
  late Animation<double>   _logoAnimation;
  final AuthController     _authController = AuthController();

  /// True while the token check is in-flight.
  /// When true, only the branded splash is shown — the full "Get Started"
  /// UI is never rendered for users who already have a valid session.
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();

    // ── Logo float animation ─────────────────────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _logoAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // ── Token check after first frame ────────────────────────────────────────
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndNavigate());
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  // ── Navigation Logic ───────────────────────────────────────────────────────

  Future<void> _checkAndNavigate() async {
    final destination = await _resolveDestination();

    if (!mounted) return;

    if (destination is LoginView) {
      // No valid session — reveal the full "Get Started" screen
      setState(() => _isChecking = false);
    } else {
      // Valid session — jump straight to the dashboard, never show splash UI
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    }
  }

  Future<Widget> _resolveDestination() async {
    // 1️⃣ Access token valid (JWT exp check — offline safe, instant)
    if (await TokenService.isAccessTokenValid()) {
      return _homeForRole();
    }

    // 2️⃣ Access token expired — check refresh token locally first
    if (await TokenService.isRefreshTokenValid()) {
      final refreshed = await _authController.refreshToken();
      if (refreshed) return _homeForRole();
    }

    // 3️⃣ Both expired or refresh failed → force login
    await TokenService.clearTokens();
    return const LoginView();
  }

  Future<Widget> _homeForRole() async {
    final role = await TokenService.getRole();
    return switch (role) {
      'student' => const StudentDashboardView(),
      'teacher' => const TeacherDashboard(),
      _         => const LoginView(),
    };
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // While checking tokens, show only the branded splash.
    // Logged-in users never see the "Get Started" button/text at all.
    if (_isChecking) return _buildSplash();

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final logoSize = isPortrait
              ? constraints.maxWidth * 0.35
              : constraints.maxHeight * 0.50;
          final titleFont = isPortrait
              ? constraints.maxWidth * 0.08
              : constraints.maxHeight * 0.08;
          final sloganFont = isPortrait
              ? constraints.maxWidth * 0.045
              : constraints.maxHeight * 0.045;
          final buttonWidth = isPortrait
              ? constraints.maxWidth * 0.6
              : constraints.maxHeight * 0.5;
          final buttonHeight = isPortrait
              ? constraints.maxHeight * 0.07
              : constraints.maxHeight * 0.12;

          return Stack(
            children: [
              // ── Background bubbles ─────────────────────────────────────────
              const Positioned(
                top: -40, right: -40,
                child: FloatingBubbles(size: 100, color: Color(0xffa6b3ea)),
              ),
              const Positioned(
                bottom: -40, left: -40,
                child: FloatingBubbles(size: 100, color: Color(0xffc3a5e1)),
              ),

              // ── Main content ───────────────────────────────────────────────
              Center(
                child: isPortrait
                    ? _buildPortrait(constraints, logoSize, titleFont,
                    sloganFont, buttonWidth, buttonHeight)
                    : _buildLandscape(constraints, logoSize, titleFont,
                    sloganFont, buttonWidth, buttonHeight),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Branded Splash (shown only during token check) ─────────────────────────
  Widget _buildSplash() {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: -40, right: -40,
            child: FloatingBubbles(size: 100, color: Color(0xffa6b3ea)),
          ),
          const Positioned(
            bottom: -40, left: -40,
            child: FloatingBubbles(size: 100, color: Color(0xffc3a5e1)),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _logoAnimation,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, -_logoAnimation.value),
                child: child,
              ),
              child: Image.asset("assets/img.png", width: 120, height: 120),
            ),
          ),
        ],
      ),
    );
  }

  // ── Portrait Layout ────────────────────────────────────────────────────────
  Widget _buildPortrait(
      BoxConstraints constraints,
      double logoSize, double titleFont,
      double sloganFont, double buttonWidth, double buttonHeight,
      ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogo(logoSize),
        SizedBox(height: constraints.maxHeight * 0.01),
        _buildTitle(titleFont),
        SizedBox(height: constraints.maxHeight * 0.015),
        _buildSlogan(sloganFont),
        SizedBox(height: constraints.maxHeight * 0.05),
        _buildButton(buttonWidth, buttonHeight),
      ],
    );
  }

  // ── Landscape Layout ───────────────────────────────────────────────────────
  Widget _buildLandscape(
      BoxConstraints constraints,
      double logoSize, double titleFont,
      double sloganFont, double buttonWidth, double buttonHeight,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogo(logoSize),
        SizedBox(width: constraints.maxWidth * 0.05),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTitle(titleFont),
            SizedBox(height: constraints.maxHeight * 0.015),
            _buildSlogan(sloganFont, bold: true),
            SizedBox(height: constraints.maxHeight * 0.05),
            _buildButton(buttonWidth, buttonHeight),
          ],
        ),
      ],
    );
  }

  // ── Reusable Widgets ───────────────────────────────────────────────────────

  Widget _buildLogo(double size) {
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -_logoAnimation.value),
        child: child,
      ),
      child: Image.asset("assets/img.png", width: size, height: size),
    );
  }

  Widget _buildTitle(double fontSize) {
    return Text(
      "Quizora",
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSlogan(double fontSize, {bool bold = false}) {
    return Text(
      "Learn. Compete. Conquer.",
      style: GoogleFonts.albertSans(
        fontSize: fontSize,
        fontStyle: FontStyle.italic,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildButton(double width, double height) {
    return buildGradientButton(
      text: "Get Started",
      width: width,
      height: height,
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      ),
    );
  }
}