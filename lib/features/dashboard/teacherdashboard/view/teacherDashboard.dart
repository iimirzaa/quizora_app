import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/core/services/token_service.dart';
import 'package:quiz_app/features/Leaderboard/leaderboard.dart';
import 'package:quiz_app/features/Quiz/allquiz/quizess.dart';
import 'package:quiz_app/features/Quiz/create_quiz/createQuiz.dart';
import 'package:quiz_app/features/dashboard/dashboard_bloc.dart';
import 'package:quiz_app/features/profile/view/profileView.dart';
import 'dart:async';
import 'dart:math';
import "package:jwt_decoder/jwt_decoder.dart";

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
   String ? name;
   String? email;
   String? role;
  Future <Map<String,dynamic>> getToken()async{
    final decodedtoken=await TokenService.getAccessToken()??"";
    final token=JwtDecoder.decode(decodedtoken);

    return token;
  }
  

  // ─── Teacher Stats ────────────────────────────────────────
  bool _statsLoading = true;
  late Map<String, dynamic> teacherStats = {
    'totalQuizzesCreated': 0,
    'totalAttempts': 0,
    'averageScore': 0,
    'passRate': 0,
    'quizzes': [],
  };

  // ─── Loader color ─────────────────────────────────────────
  late final Timer _colorTimer;
  Color _loaderColor = Colors.white;

  static Route<void> _createQuizRoute(BuildContext context, Object? arguments) {
    return MaterialPageRoute(builder: (_) => CreateQuiz());
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _colorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() => _loaderColor = _randomColor());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(TeacherStatsEvent());
    });
  }
  Future<void> _loadUser() async {
  final token = await getToken();
  print(token);

  if (!mounted) return;

  setState(() {
    name = token['name'];
    email = token['email'];
    role = token['role'];
  });
}


  @override
  void dispose() {
    _colorTimer.cancel();
    super.dispose();
  }

  Color _randomColor() {
    final r = Random();
    return Color.fromARGB(255, r.nextInt(256), r.nextInt(256), r.nextInt(256));
  }



  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is TeacherStatsState) {
          setState(() {
            teacherStats = state.teacherStats;
            _statsLoading = false;
          });
        }
        if (state is StartNowState) {
          Navigator.restorablePushReplacement(context, _createQuizRoute);
        }
        if (state is ErrorState) {
          setState(() => _statsLoading = false);
          showDialog(
            context: context,
            builder: (_) => _buildErrorDialog(state.message), 
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xfff4f6fb),

          body: Stack(
            children: [
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // ── Header ──────────────────────────
                    SliverToBoxAdapter(child: _buildHeader(name??'')),

                    // ── Create Quiz Card ─────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: _buildCreateQuizCard(),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 16.h)),

                    // ── Stats Row ────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: _buildStatsRow(),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 16.h)),

                    // // ── Top Performer ────────────────────
                    // SliverToBoxAdapter(
                    //   child: Padding(
                    //     padding: EdgeInsets.symmetric(horizontal: 18.w),
                    //     child: _buildTopPerformerCard(),
                    //   ),
                    // ),

                    SliverToBoxAdapter(child: SizedBox(height: 16.h)),

          
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: _buildRecentQuizzesCard(),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                  ],
                ),
              ),

              // ── Loading overlay (quiz search only) ────
              if (state is LoadingState)
                Container(
                  color: Colors.black.withOpacity(0.45),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _loaderColor,
                      strokeWidth: 3,
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
  //  HEADER
  // ──────────────────────────────────────────────────────────

  Widget _buildHeader(String name) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                Text(
                  name,
                  style: GoogleFonts.albertSans(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF764ba2),
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
          ),
          // notification bell placeholder
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: const Color(0xFF764ba2),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 10.w,),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfileView(name: name,email: email,role: role,)));
            },
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_2_outlined,
                color: const Color(0xFF764ba2),
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  CREATE QUIZ CARD
  // ──────────────────────────────────────────────────────────

  Widget _buildCreateQuizCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF764ba2).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create New Quiz",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Upload a file or build MCQs manually",
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF764ba2),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () =>
                      context.read<DashboardBloc>().add(StartNowClicked()),
                  child: Text(
                    "Start Now",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Text("📝", style: TextStyle(fontSize: 48.sp)),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  STATS ROW
  // ──────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    // Helper to safely format null or missing values
    String formatStat(dynamic value, {String suffix = ''}) {
      if (value == null) return '0$suffix';
      return '$value$suffix';
    }

    final stats = [
      {
        'icon': Icons.quiz_outlined,
        'label': 'Quizzes',
        'value': formatStat(teacherStats['totalQuizzesCreated']),
        'color': const Color(0xFF667eea),
      },
      {
        'icon': Icons.people_outline,
        'label': 'Attempts',
        'value': formatStat(teacherStats['totalAttempts']),
        'color': const Color(0xFF764ba2),
      },
      {
        'icon': Icons.bar_chart_rounded,
        'label': 'Avg Score',
        'value': formatStat(teacherStats['avgScore'], suffix: '%'),
        'color': const Color(0xFFf7971e),
      },
      {
        'icon': Icons.check_circle_outline,
        'label': 'Pass Rate',
        'value': formatStat(teacherStats['passRate'], suffix: '%'),
        'color': const Color(0xFF43b89c),
      },
    ];

    return Row(
      children: stats.asMap().entries.map((e) {
        final s = e.value;
        final isLast = e.key == stats.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8.w),
            child: _statsLoading
                ? _ShimmerBox(
              width: double.infinity,
              height: 72.h,
              radius: 12.r,
            )
                : _buildStatChip(
              icon: s['icon'] as IconData,
              label: s['label'] as String,
              value: s['value'] as String,
              color: s['color'] as Color,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14.sp),
          ),
          SizedBox(height: 5.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              color: const Color(0xFF1a1a2e),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  TOP PERFORMER
  // ──────────────────────────────────────────────────────────

  Widget _buildTopPerformerCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1a1a2e).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 54.w,
                height: 54.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFf7971e), Color(0xFFffd200)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFffd200).withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "E",
                    style: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: EdgeInsets.all(3.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1a1a2e),
                    shape: BoxShape.circle,
                  ),
                  child: Text("🥇", style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TOP PERFORMER",
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFffd200),
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Emma Watson",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    _scorePill(
                      Icons.star_rounded,
                      "98%",
                      const Color(0xFFffd200),
                    ),
                    SizedBox(width: 6.w),
                    _scorePill(
                      Icons.bolt_rounded,
                      "12 quizzes",
                      const Color(0xFF667eea),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text("🏆", style: TextStyle(fontSize: 32.sp)),
              Text(
                "#1",
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFffd200),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scorePill(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: color),
          SizedBox(width: 3.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  RECENT QUIZZES
  // ──────────────────────────────────────────────────────────

  Widget _buildRecentQuizzesCard() {
    final List quizzes = teacherStats['quizzes'] ?? [];
    final recent = quizzes.take(3).toList()??[];

    return Container(
      padding: EdgeInsets.all(16.r),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Quizzes",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                  color: const Color(0xFF1a1a2e),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>AllQuiz(stats:quizzes)));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF764ba2).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "View All",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF764BA2),
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (_statsLoading)
            Column(
              children: List.generate(
                2,
                (_) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _ShimmerBox(
                    width: double.infinity,
                    height: 68.h,
                    radius: 12.r,
                  ),
                ),
              ),
            )
          else if (recent.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 38.sp,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "No quizzes created yet",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...recent
                .asMap()
                .entries
                .map((e) => _buildQuizTile(e.value, e.key))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildQuizTile(dynamic quiz, int index) {
    final List<Color> accents = [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
      const Color(0xFFf7971e),
    ];

    final color = accents[index % accents.length];
    final String code = quiz['quizCode'] ?? '—';
    final String title = quiz['title'] ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LeaderBoard(id:quiz['quizId'],title:quiz['title']
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: const Color(0xfff8f9ff),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(width: 12.w),

            // Main content — title no longer shares a row with the popup menu,
            // so it gets real room to ellipsize instead of relying on a fixed spacer.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 6.h),
                   Row(
                  children: [
                   _metaPill(Icons.tag_rounded, code, Colors.grey.shade500),
                   SizedBox(width: 10.w),
                   ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "View Leaderboard",
                    style: GoogleFonts.poppins(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing column keeps the "⋮" menu and the arrow in the same
            // strip so they're actually aligned with each other, not with
            // unrelated parts of the card.
            SizedBox(
              height: 63.h, // roughly matches the content column's height
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 24.h,
                    width: 24.w,
                    child: PopupMenuButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.more_vert,
                        size: 18.sp,
                        color: Colors.grey.shade400,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: "share",
                          child: Row(
                            children: [
                              Icon(
                                Icons.share_outlined,
                                size: 16.sp,
                                color: const Color(0xFF764ba2),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Share Code",
                                style: GoogleFonts.poppins(fontSize: 13.sp),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "delete",
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 16.sp,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Delete",
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: color,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _metaPill(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11.sp, color: color),
        SizedBox(width: 3.w),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  //  ERROR DIALOG
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
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 40.sp,
              ),
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
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF764ba2),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  "OK",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
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
    _animation = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
      builder: (_, __) => Container(
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
      ),
    );
  }
}
