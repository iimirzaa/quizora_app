import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quiz_app/core/widgets/CustomInput.dart';
import 'package:quiz_app/core/widgets/FloatingBubbles.dart';
import 'package:quiz_app/core/widgets/GradientButton.dart';
import 'package:quiz_app/features/Authentication/auth_bloc.dart';
import 'package:quiz_app/features/Authentication/login/view/LoginView.dart';
import 'dart:math';



import '../../../../core/validators/validator.dart';

class VerifyOtpView extends StatefulWidget {
  final String email;
  final String role;
  const VerifyOtpView({super.key,required this.email,required this.role});

  @override
  State<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  TextEditingController otpController = TextEditingController();


  late final Timer timer;
  final _formKey = GlobalKey<FormState>();
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

  @override
  void dispose() {
    _controller.dispose();
    timer.cancel(); // dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSuccessState) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoginView()),
          );
        }

      },
      builder: (context, state) {
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
                  child: isPortrait
                      ? SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(18.0.r),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [_buildSignUpLogo(70.sp, 30.sp)],
                            ),
                            Text(
                              "Enter Otp you have received on your gmail ${widget.email}",
                              style: GoogleFonts.poppins(

                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            CustomInput(
                              hint: "Enter your Otp",
                              prefixIcon: Icons.security_outlined,
                              type: TextInputType.number,
                              controller: otpController,
                              validator: AppValidator.otp,
                            ),

                            SizedBox(height: 10.h),
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
                                        state.message,
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

                            SizedBox(height: 10.h,),
                            buildGradientButton(
                              text: "Verify",
                              width: 150.sp,
                              height: 50.sp,
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                  VerifyButtonClicked(
                                    key: _formKey.currentState!
                                        .validate(),
                                    email:widget.email,
                                    otp: otpController.text.trim().toString(),
                                    role:widget.role.toLowerCase()
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
                        child: Form(
                          key: _formKey,
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
                                hint: "Enter your email",
                                prefixIcon: Icons.email,
                                controller: otpController,
                                validator: AppValidator.email,
                              ),


                              SizedBox(height: 15.h),


                              SizedBox(height: 15.h),
                              buildGradientButton(
                                text: "Verify",
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
