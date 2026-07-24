import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quiz_app/core/validators/validator.dart';
import 'package:quiz_app/core/widgets/CustomInput.dart';
import 'package:quiz_app/core/widgets/FloatingBubbles.dart';
import 'package:quiz_app/core/widgets/GradientButton.dart';
import 'package:quiz_app/features/Authentication/auth_bloc.dart';
import 'package:quiz_app/features/Authentication/login/view/LoginView.dart';
import 'dart:math';
import 'dart:async';

import 'package:quiz_app/features/Authentication/otp/view/verifyOtp.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final _initialFormKey = GlobalKey<FormState>();
  String selectedValue = "Student";

  final List<String> items = ["Teacher", "Student"];
  late final Timer timer;
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
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true); // repeat back and forth

    // Tween to move image slightly up and down
    _animation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _clearControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }
  @override
  void dispose() {
    timer.cancel();
    _controller.dispose();
    // ✅ Dispose all text controllers
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is SignUpSuccessState) {
            if (mounted) {
              // ✅ Capture email BEFORE clearing
              final email = emailController.text.trim();
              final role  = selectedValue;
              _clearControllers();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => VerifyOtpView(email: email, role: role),
                ),
              );
            }
          }
        },
      builder: (context, state) {
        final errorMessage = state is ErrorState ? state.message : null;
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -40,
                  right: -40,
                  child: const FloatingBubbles(
                    size: 100,
                    color: Color(0xffa6b3ea),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: -40,
                  child: const FloatingBubbles(
                    size: 100,
                    color: Color(0xffc3a5e1),
                  ),
                ),
                Center(
                  child: state is NextClickedState
                      ? isPortrait
                            ? SingleChildScrollView(
                                child: Padding(
                                  padding: EdgeInsets.all(18.0.r),
                                  child: Form(
                                    key: _initialFormKey,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _buildSignUpLogo(70.sp, 30.sp),
                                          ],
                                        ),

                                        CustomInput(
                                          hint: "Enter your password",
                                          prefixIcon: Icons.key_sharp,
                                          obscureText: true,
                                          controller: passwordController,
                                          validator: AppValidator.password,
                                        ),

                                        SizedBox(height: 15.h),

                                        CustomInput(
                                          hint: "Confirm your password",
                                          prefixIcon: Icons.key_sharp,
                                          obscureText: true,
                                          controller: confirmPasswordController,
                                          validator: (value) {
                                            if (value !=
                                                passwordController.text
                                                    .trim()) {
                                              return "Password does not match";
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 10.h),

// ✅ ADD THIS
                                        if (errorMessage != null)
                                          Container(
                                            padding: EdgeInsets.all(12.r),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFEAEA),
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
                                                Icon(Icons.error_outline, color: Colors.red, size: 22.sp),
                                                SizedBox(width: 10.w),
                                                Expanded(
                                                  child: Text(
                                                    errorMessage,
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


                                        SizedBox(height: 10.h),
                                        buildGradientButton(
                                          text: "Sign Up",
                                          width: 150.sp,
                                          height: 50.sp,
                                          onPressed: () {
                                            context.read<AuthBloc>().add(
                                              SignUpEvent(
                                                formkey: _initialFormKey
                                                    .currentState!
                                                    .validate(),
                                                name: nameController.text
                                                    .trim(),
                                                email: emailController.text
                                                    .trim(),
                                                password:
                                                    confirmPasswordController
                                                        .text
                                                        .trim(),
                                                role: selectedValue.toLowerCase(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 200.0.r,
                                      vertical: 30.sp,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _buildSignUpLogo(30.sp, 10.sp),
                                          ],
                                        ),
                                        CustomInput(
                                          hint: "Enter your password",
                                          prefixIcon: Icons.key_sharp,
                                          controller: nameController,
                                          obscureText: true,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Username cannot be empty";
                                            }
                                            return null;
                                          },
                                        ),

                                        SizedBox(height: 15.h),

                                        CustomInput(
                                          hint: "Confirm your password",
                                          prefixIcon: Icons.key_sharp,
                                          obscureText: true,
                                          controller: emailController,
                                        ),

                                        SizedBox(height: 15.h),

// ✅ ADD THIS
                                        if (errorMessage != null)
                                          Container(
                                            padding: EdgeInsets.all(12.r),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFEAEA),
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
                                                Icon(Icons.error_outline, color: Colors.red, size: 22.sp),
                                                SizedBox(width: 10.w),
                                                Expanded(
                                                  child: Text(
                                                    errorMessage,
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



                                        SizedBox(height: 15.h,),
                                        buildGradientButton(
                                          text: "SignUp",
                                          width: 150.sp,
                                          height: 20.sp,
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                      : isPortrait
                      ? SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(18.0.r),
                            child: Form(
                              key: _initialFormKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [_buildSignUpLogo(70.sp, 30.sp)],
                                  ),
                                  SizedBox(height: 10.h),
                                  DropdownButtonFormField<String>(
                                    value: selectedValue,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey.shade100,

                                      // 👇 Reduced padding (THIS makes it slim)
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),

                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1.2.w,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        borderSide: BorderSide(
                                          color: Color(0xFF212680),
                                          width: 1.5.w,
                                        ),
                                      ),
                                    ),
                                    items: items.map((String item) {
                                      return DropdownMenuItem<String>(
                                        value: item,
                                        child: SizedBox(
                                          width: 200.h, // 👈 forces full width
                                          child: Text(item),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedValue = newValue!;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 10.h),
                                  CustomInput(
                                    hint: "Enter your name",
                                    prefixIcon: Icons.person,
                                    controller: nameController,
                                    validator: AppValidator.name,
                                  ),

                                  SizedBox(height: 15.h),

                                  CustomInput(
                                    hint: "Enter your email",
                                    prefixIcon: Icons.email,
                                    obscureText: false,
                                    controller: emailController,
                                    validator: AppValidator.email,
                                  ),
                                  SizedBox(height: 15.h),
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginView()));
                                    },
                                    child: Text(
                                      "Already has account?",
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w600,

                                        fontSize: 14.sp,
                                        color: Colors.green,
                                        decoration: TextDecoration.underline,
                                        decorationStyle:
                                            TextDecorationStyle.solid,
                                        decorationThickness: 2.sp,
                                        decorationColor: Colors.green,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),

// ✅ ADD THIS
                                  if (errorMessage != null)
                                    Container(
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEAEA),
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
                                          Icon(Icons.error_outline, color: Colors.red, size: 22.sp),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Text(
                                              errorMessage,
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

                                  SizedBox(height: 15.h),


                                  SizedBox(height: 15.h),
                                  buildGradientButton(
                                    text: "Next",
                                    width: 150.sp,
                                    height: 50.sp,
                                    onPressed: () {
                                      if (_initialFormKey.currentState!
                                          .validate()) {
                                        context.read<AuthBloc>().add(
                                          NextButtonClickedEvent(),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 200.0.r,
                                vertical: 30.sp,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [_buildSignUpLogo(30.sp, 10.sp)],
                                  ),
                                  CustomInput(
                                    hint: "Enter your name",
                                    prefixIcon: Icons.person,
                                    controller: nameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Username cannot be empty";
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: 15.h),

                                  CustomInput(
                                    hint: "Enter your email",
                                    prefixIcon: Icons.email,
                                    obscureText: false,
                                    controller: emailController,
                                  ),
                                  SizedBox(height: 15.h),
                                  Text(
                                    "Already has account?",
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w600,

                                      fontSize: 8.sp,
                                      color: Colors.green,
                                      decoration: TextDecoration.underline,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                      decorationThickness: 1.sp,
                                      decorationColor: Colors.green,
                                    ),
                                  ),

                                  SizedBox(height: 15.h),
                                  buildGradientButton(
                                    text: "Next",
                                    width: 150.sp,
                                    height: 20.sp,
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignUpLogo(double imageSize, double fontSize) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value), // moves up and down
          child: child,
        );
      },
      child: Row(
        children: [
          Image.asset("assets/img.png", width: imageSize, height: imageSize),
          Text(
            "Quizora",
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
