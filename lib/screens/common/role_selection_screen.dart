import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/user_role.dart';
import '../../core/utils/role_manager.dart';
import '../../core/utils/storage_util.dart';
import '../auth/login_screen.dart';
import '../auth/official_login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  static const String routeName = '/role-selection';

  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  UserRole? _selectedRole;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeController.forward();
        _scaleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Stack(
          children: [
            _buildDecorativeElements(),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight:
                        size.height - MediaQuery.of(context).padding.top),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildHeader(),
                      ),
                      const SizedBox(height: 40),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildRoleCards(),
                      ),
                      const SizedBox(height: 50),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildContinueButton(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeElements() {
    return Stack(
      children: [
        // Top right decoration
        Positioned(
          top: 100,
          right: -20,
          child: Transform.rotate(
            angle: 0.3,
            child: Icon(
              Icons.sailing,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
        ),

        // Left side decoration
        Positioned(
          top: 180,
          left: -10,
          child: Icon(
            Icons.waves,
            size: 35,
            color: AppColors.accent.withValues(alpha: 0.12),
          ),
        ),

        // Bottom decorations
        Positioned(
          bottom: 150,
          right: 20,
          child: Transform.rotate(
            angle: -0.2,
            child: Icon(
              Icons.anchor,
              size: 30,
              color: AppColors.primaryDark.withValues(alpha: 0.1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
            children: const [
              TextSpan(text: 'Choose your role\n'),
              TextSpan(text: 'below'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCards() {
    return Column(
      children: [
        _buildRoleCard(
          role: UserRole.citizen,
          icon: Icons.notifications_active_rounded,
          title: 'Citizen',
          subtitle: 'Report maritime hazards\n& receive alerts',
          color: const Color(0xFF7C3AED),
          illustration: Icons.person_rounded,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'or',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF666666),
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        _buildRoleCard(
          role: UserRole.official,
          icon: Icons.admin_panel_settings_rounded,
          title: 'Maritime Official',
          subtitle: 'Manage reports &\ncoordinate responses',
          color: const Color(0xFF8B5CF6),
          illustration: Icons.assessment_rounded,
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required IconData illustration,
  }) {
    final bool isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => _selectRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 160,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A1A1A) : color,
            width: isSelected ? 3 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: isSelected ? 20 : 15,
              offset: Offset(0, isSelected ? 8 : 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background wave pattern
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                Icons.waves,
                size: 120,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          illustration,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 20,
                    color: color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _selectedRole != null ? _handleRoleSelection : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedRole != null
              ? const Color(0xFF1A1A1A)
              : const Color(0xFFD0D0D0),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFD0D0D0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: _selectedRole != null ? 4 : 0,
          shadowColor: Colors.black.withValues(alpha: 0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Get started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Setting up your role...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectRole(UserRole role) {
    if (_isLoading) return;
    setState(() => _selectedRole = role);

    // Haptic feedback would be nice here
    // HapticFeedback.lightImpact();
  }

  Future<void> _handleRoleSelection() async {
    if (_selectedRole == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      await StorageUtil.saveUserRole(_selectedRole!);
      await RoleManager.setUserRole(_selectedRole!);

      if (!mounted) return;

      // Maritime Officials need special login credentials
      // Citizens use Firebase authentication
      final routeName = _selectedRole == UserRole.official
          ? OfficialLoginScreen.routeName
          : LoginScreen.routeName;

      Navigator.of(context).pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set role: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
