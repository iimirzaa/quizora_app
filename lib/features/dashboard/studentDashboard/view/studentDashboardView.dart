import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quiz_app/core/widgets/CustomInput.dart';
import 'package:quiz_app/core/widgets/customContainer.dart';
import 'dart:math';
import 'package:quiz_app/core/widgets/custom_bottom_nav_student.dart';
import 'package:quiz_app/features/Quiz/attempt_quiz/view/attemptQuizView.dart';
import 'package:quiz_app/features/allResult/View/allResultView.dart';
import 'package:quiz_app/features/dashboard/dashboard_bloc.dart';
import 'package:quiz_app/features/profile/view/profileView.dart';
import 'package:quiz_app/features/studentResultDetail/view/studentResultDetail.dart';
import 'dart:async';

class StudentDashboardView extends StatefulWidget {
  const StudentDashboardView({super.key});

  @override
  State<StudentDashboardView> createState() => _StudentDashboardViewState();
}

class _StudentDashboardViewState extends State<StudentDashboardView> {
  final TextEditingController _searchController = TextEditingController();
  late final Timer timer;
  Color loaderColor = Colors.white;

  // ─── User Stats ───────────────────────────────────────────
  bool _statsLoading = true;
   Map<String, dynamic> _userStats = {
    'totalAttempted': 0,
    'averageScore': 0,
    'bestScore': 0,
    'recentAttempts': [],
  };

  int _currentIndex = 0;

  Color getColor() {
    final random = Random();
    return Color.fromARGB(255, random.nextInt(256), random.nextInt(256), random.nextInt(256));
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() => loaderColor = getColor());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(UserStatsEvent());
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────
  //  BUILD
  // ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is UserStatsState) {
          setState(() {
            _userStats=state.userStats;
            _statsLoading = false;
          });
        }

        if (state is ErrorState) {
          // stats failed — stop skeleton, show zeros
          setState(() => _statsLoading = false);
          showDialog(
            context: context,
            builder: (_) => _buildErrorDialog(state.message),
          );
        }

        if (state is SearchQuizSuccess) {
          showDialog(
            context: context,
            builder: (_) => _buildQuizFoundDialog(state.data),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: CustomBottomNavStudent(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
              if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => AllResultView()));
              if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileView()));
            },
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 18.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(height: 5.h),
                      Text(
                        "Welcome back 👨‍🎓",
                        style: GoogleFonts.albertSans(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF764ba2),
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      buildStartQuizCard(),
                      SizedBox(height: 10.h),

                      // ── Stats Row ──────────────────────────
                      Scrollbar(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _statsLoading
                                  ? _buildStatSkeleton()
                                  : buildContainer("Quiz Attempted", _userStats['totalAttempted'].toString()),
                              SizedBox(width: 10.w),
                              _statsLoading
                                  ? _buildStatSkeleton()
                                  : buildContainer("Avg Score", _userStats['averageScore'].toString()),
                              SizedBox(width: 10.w),
                              _statsLoading
                                  ? _buildStatSkeleton()
                                  : buildContainer("Best Score", _userStats['bestScore'].toString()),
                              SizedBox(width: 10.w),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // ── Recent Results ─────────────────────
                      Expanded(
                        child: _statsLoading
                            ? _buildRecentSkeleton()
                            : _userStats['recentAttempts'].isEmpty
                            ? _buildEmptyResults()
                            : SingleChildScrollView(

                              child: Column(
                                children: List.generate(
                              _userStats['recentAttempts'].length,
                                  (index) {
                                final quiz = _userStats['recentAttempts'][index];

                                return buildResultCard(
                                  title: quiz['quizTitle'] ?? 'Quiz',
                                  correct: quiz['score'] ?? 0,
                                  total: quiz['total'] ?? 1,
                                  timeTaken: quiz['timeTaken'] ?? 0,
                                  onTap: () {
                                    Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=> StudentResultDetailView(quiz:quiz)));
                                  },
                                );
                              },
                                                      ),
                                                    ),
                            ),
                      )
                    ],
                  ),
                ),
              ),

              // ── Quiz search loading overlay ────────────────
              if (state is LoadingState)
                Container(
                  color: Colors.black.withOpacity(0.5),
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
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────
  //  SKELETONS
  // ──────────────────────────────────────────────────────────

  Widget _buildStatSkeleton() {
    return _ShimmerBox(width: 100.w, height: 70.h, radius: 12.r);
  }

  Widget _buildRecentSkeleton() {
    return Column(
      children: List.generate(
        2,
            (_) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _ShimmerBox(width: double.infinity, height: 70.h, radius: 12.r),
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.quiz_outlined, size: 40.sp, color: Colors.grey.shade300),
          SizedBox(height: 8.h),
          Text(
            "No quizzes attempted yet",
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  DIALOGS
  // ──────────────────────────────────────────────────────────

  Widget _buildErrorDialog(String message) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, color: Colors.red, size: 40.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              "Something went wrong",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4a2c73),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF764ba2),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  "OK",
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizFoundDialog(Map<String, dynamic> data) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.quiz, color: Color(0xff764ba2)),
          SizedBox(width: 10),
          Text("Quiz Found"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['title'],
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
              color: const Color(0xff764ba2),
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                '${data['duration']} minutes',
                style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey),
              ),
              SizedBox(width: 12.w),
              const Icon(Icons.quiz_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                '${data['totalQuestions']} questions',
                style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "Do you want to attempt this quiz?",
            style: GoogleFonts.poppins(fontSize: 13.sp),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff764ba2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => QuizAttemptView(data: data)),
                  (route) => false,
            );
          },
          icon: const Icon(Icons.play_arrow, color: Colors.white),
          label: Text("Start Quiz", style: GoogleFonts.poppins(color: Colors.white)),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  //  QUIZ CODE CARD
  // ──────────────────────────────────────────────────────────

  Widget buildStartQuizCard() {
    return Container(
      padding: EdgeInsets.all(10.r),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter Quiz Code",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            "Join quiz using code from your teacher",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.sp),
          ),
          SizedBox(height: 5.h),
          CustomInput(hint: "Enter quiz code", controller: _searchController),
          SizedBox(height: 5.h),
          ElevatedButton(
            style: ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size(90.w, 40.h)),
            ),
            onPressed: () {
              context.read<DashboardBloc>().add(
                SearchQuizClicked(code: _searchController.text.trim()),
              );
            },
            child: Text(
              "Start Quiz",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
//  SHIMMER BOX
// ──────────────────────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
            ),
          ),
        );
      },
    );
  }
}
Widget buildResultCard({
  required String title,
  required int correct,
  required int total,
  required int timeTaken,
  required VoidCallback onTap,
}) {
  double percentage = (correct / total) * 100;

  String status;
  IconData icon;
  Color color;

  if (percentage >= 85) {
    status = "Excellent";
    icon = Icons.emoji_events;
    color = Colors.amber;
  } else if (percentage >= 70) {
    status = "Good";
    icon = Icons.star;
    color = Colors.green;
  } else if (percentage >= 50) {
    status = "Average";
    icon = Icons.thumb_up;
    color = Colors.orange;
  } else {
    status = "Needs Improvement";
    icon = Icons.warning;
    color = Colors.red;
  }

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12.r),
    child: Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE + STATUS ICON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  SizedBox(width: 4.w),
                  Text(
                    status,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 10.h),

          /// SCORE ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$correct / $total Correct",
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey[700],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF764BA2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${percentage.toStringAsFixed(0)}%",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF764BA2),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          /// PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(Color(0xFF764BA2)),
            ),
          ),

          SizedBox(height: 10.h),

          /// FOOTER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    "$timeTaken min",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Text(
                    "View Full Result",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF764BA2),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Color(0xFF764BA2),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

