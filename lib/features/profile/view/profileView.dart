import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quiz_app/core/services/token_service.dart';
import 'package:quiz_app/features/Authentication/login/view/LoginView.dart';
import 'package:quiz_app/features/profile/profile_bloc.dart';

class ProfileView extends StatefulWidget {
  final String? name;
  final String? email;
  final String? role;
  const ProfileView({super.key,this.name,this.email,this.role});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  
  static const Color kPrimary = Color(0xFF6C4FD1);
  static const Color kPrimaryTint = Color(0xFFEEEDFE);

  static const double kBannerHeight = 150;
  static const double kAvatarSize = 96;
  static const double kAvatarOverlap = kAvatarSize / 2; // how much the avatar hangs below the banner

  bool notificationEnabled = true;

  // ── Logout Confirmation Dialog ─────────────────────────────────────────
  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<ProfileBloc>().add(LogoutButtonClicked());
    }
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is LogoutSuccessState) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
          );
        }
      },
      builder: (context, state) {

        return Scaffold(
          backgroundColor: const Color(0xFFF6F6F6),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeader(),
                      // Only the small gap between avatar bottom and name is
                      // needed now — the header widget itself already
                      // reserves space for the overlapping avatar.
                      SizedBox(height: 12.h),
                      Text(
                        widget.name??'',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${widget.email ?? ''}    ${widget.role ?? ''}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 15.sp),
                      ),
                      SizedBox(height: 26.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel("ACCOUNT"),
                            SizedBox(height: 10.h),
                            _buildAccountCard(),
                            SizedBox(height: 22.h),
                            _buildLogoutCard(),
                            if (state is ErrorState) ...[
                              SizedBox(height: 14.h),
                              _buildErrorBanner(state.msg),
                            ],
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (state is LoadingState)
                  Container(
                    color: Colors.black.withOpacity(0.45),
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.white,
                        size: 60.sp,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header: colored banner + overlapping avatar ─────────────────────
  //
  // Previously the avatar was Positioned(bottom: -48) inside a Stack whose
  // *size* was only the 130.h banner — Positioned children don't add to a
  // Stack's size, so the avatar's bottom half hung outside the header and
  // overlapped the name/email text below it. Wrapping the Stack in a
  // SizedBox tall enough to fit "banner + half the avatar" fixes that: the
  // Column below now starts after the avatar, not underneath it.

  Widget _buildHeader() {
    return SizedBox(
      height: kBannerHeight.h + kAvatarOverlap.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            height: kBannerHeight.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimary, kPrimary.withOpacity(0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28.r),
                bottomRight: Radius.circular(28.r),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Text(
                  "PROFILE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: kBannerHeight.h - kAvatarOverlap.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: kAvatarSize.r,
                  height: kAvatarSize.r,
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: kPrimaryTint,
                    child: Icon(Icons.person, size: 44.sp, color: kPrimary),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => debugPrint("Edit profile picture"),
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 14.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11.sp,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    );
  }

  // ── Account settings card ────────────────────────────────────────────

  Widget _buildAccountCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _settingRow(
            icon: Icons.notifications_none,
            title: "Notifications",
            trailing: Switch(
              value: notificationEnabled,
              activeColor: kPrimary,
              onChanged: (value) => setState(() => notificationEnabled = value),
            ),
            showChevron: false,
          ),
          _divider(),
          _settingRow(
            icon: Icons.lock_outline,
            title: "Change password",
            onTap: () => debugPrint("Change Password Clicked"),
          ),
          _divider(),
          _settingRow(
            icon: Icons.help_outline,
            title: "Help and support",
            onTap: () => debugPrint("Help Clicked"),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: _settingRow(
        icon: Icons.logout,
        title: "Logout",
        isDestructive: true,
        onTap: _showLogoutDialog,
        showChevron: false,
      ),
    );
  }

  // iconContainer(34.r) + horizontal padding(14.w) + gap(12.w) = 60 —
  // kept in sync with _divider()'s left inset so the divider lines up
  // under the row title, not the icon.
  Widget _settingRow({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
    bool showChevron = true,
  }) {
    final Color iconColor = isDestructive ? Colors.redAccent : kPrimary;
    final Color iconBg = isDestructive ? const Color(0xFFFCEBEB) : kPrimaryTint;

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 34.r,
              height: 34.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10.r)),
              child: Icon(icon, size: 18.sp, color: iconColor),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.redAccent : Colors.black87,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else if (showChevron)
              Icon(Icons.chevron_right, size: 18.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.only(left: 60.w),
      child: Divider(height: 1, color: Colors.black.withOpacity(0.06)),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAEA),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade800,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}