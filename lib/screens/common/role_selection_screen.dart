import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/enums/user_role.dart';
import '../../core/utils/role_manager.dart';
import '../../core/utils/storage_util.dart';
import '../citizen/citizen_home_screen.dart';
import '../official/official_dashboard_screen.dart';

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

  late AnimationController _slideController;
  late AnimationController _cardController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.fastOutSlowIn),
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
        _cardController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundDecoration(),

            // Scrollable content to fix overflow
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SlideTransition(position: _slideAnimation, child: _buildHeader()),
                  const SizedBox(height: 40),
                  ScaleTransition(scale: _cardAnimation, child: _buildRoleCards()),
                  const SizedBox(height: 32),
                  SlideTransition(position: _slideAnimation, child: _buildBottomSection()),
                ],
              ),
            ),

            if (_isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          AppStrings.selectYourRole,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.roleSelectionDescription,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.gray,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRoleCards() {
    return Column(
      children: [
        _buildRoleCard(
          role: UserRole.citizen,
          icon: Icons.person_rounded,
          title: AppStrings.citizenRole,
          description:
              "Report hazards, receive alerts, and access emergency services",
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        const SizedBox(height: 20),
        _buildRoleCard(
          role: UserRole.official,
          icon: Icons.admin_panel_settings_rounded,
          title: AppStrings.officialRole,
          description:
              "Manage reports, analyze data, and coordinate emergency responses",
          gradient: const LinearGradient(
            colors: [AppColors.accent, AppColors.accentLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required IconData icon,
    required String title,
    required String description,
    required LinearGradient gradient,
  }) {
    final bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => _selectRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.gray.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.white.withOpacity(0.2) : AppColors.lightGray,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: isSelected ? AppColors.white : AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: isSelected ? AppColors.white : AppColors.primaryDark, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? AppColors.white.withOpacity(0.9) : AppColors.gray,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 60 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedRole != null ? _handleRoleSelection : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _selectedRole != null ? AppColors.primary : AppColors.gray.withOpacity(0.3),
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: _selectedRole != null ? 8 : 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("Continue"),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "You can change your role later in settings",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray.withOpacity(0.8),
                fontSize: 13,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  void _selectRole(UserRole role) {
    if (_isLoading) return;
    setState(() => _selectedRole = role);
  }

  Future<void> _handleRoleSelection() async {
    if (_selectedRole == null || _isLoading) return;
    setState(() => _isLoading = true);

    await StorageUtil.saveUserRole(_selectedRole!);
    await RoleManager.setUserRole(_selectedRole!);

    final routeName =
        _selectedRole == UserRole.citizen ? CitizenHomeScreen.routeName : OfficialDashboardScreen.routeName;

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => false);
  }
}
