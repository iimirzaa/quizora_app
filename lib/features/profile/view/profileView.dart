import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quiz_app/features/Authentication/login/view/LoginView.dart';
import 'package:quiz_app/features/profile/profile_bloc.dart';
import 'dart:async';
import 'dart:math';
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final Timer timer;
  bool notificationEnabled = true;
  Color loaderColor = Colors.white;
  Color getColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 500), (_) {
      setState(() {
        loaderColor = getColor();
      });
    });

  }
  @override
  void dispose() {
    timer.cancel(); // ← cancel on dispose
    super.dispose();
  }
  // ── Logout Confirmation Dialog ─────────────────────────────────────────────
  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true, // tap outside = cancel
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          // Cancel
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),

          // Confirm logout
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    // Only fire the event if user tapped "Logout"
    if (confirmed == true && mounted) {
      context.read<ProfileBloc>().add(LogoutButtonClicked());
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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

            child:Stack(
              children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 18.w),
                child: Column(
                  children: [

                    SizedBox(height: 40.h),

                    buildProfileCard(),

                    SizedBox(height: 10.h),

                    Text(
                      "Emma Watson - Student",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "abc@gmail.com",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.sp,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    buildSettingCard(),
                    SizedBox(height: 10.h,),
                    if (state is ErrorState)
                      Container(

                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEAEA), // softer red
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.red.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 22.sp,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                state.msg,
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
                      ),
                  ],
                ),
              ),
                if (state is LoadingState) // show loader when loading
                  Container(
                    color: Colors.black.withOpacity(
                      0.5,
                    ), // semi-transparent background
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: loaderColor,
                        size: 70.sp,
                      ),
                    ),
                  ),
      ]
            ),
          ),
        );
      },
    );
  }

  Widget buildProfileCard() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 70.r,
          backgroundColor: Colors.deepPurple,
          child: Icon(
            Icons.person,
            size: 70.sp,
            color: Colors.white,
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: () {
              print("Edit profile picture");
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buildSettingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [

          /// Notification switch
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Color(0xFF764BA2)),
            title: const Text("Notifications"),
            value: notificationEnabled,
            onChanged: (value) {
              setState(() => notificationEnabled = value);
            },
          ),

          buildDivider(),

          buildSettingItem(
            icon: Icons.lock,
            title: "Change Password",
            onTap: () {
              print("Change Password Clicked");
            },
          ),

          buildDivider(),

          buildSettingItem(
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () {
              print("Help Clicked");
            },
          ),

          buildDivider(),

          // Logout — red tint, opens confirmation dialog first
          buildSettingItem(
            icon: Icons.logout,
            title: "Logout",
            isLogout: true,
            onTap: _showLogoutDialog, // dialog → then fires bloc event
          ),
        ],
      ),
    );
  }

  Widget buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : const Color(0xFF764BA2),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: isLogout ? Colors.red : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1),
    );
  }
}