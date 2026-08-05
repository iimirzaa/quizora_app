import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/features/Quiz/quiz_bloc.dart';

class LeaderBoard extends StatefulWidget {
  final String id;
  final String? title;
  const LeaderBoard({super.key, required this.id, this.title});

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  Map<String, dynamic> leaderboardData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizBloc>().add(LeaderBoardEvent(id: widget.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is LeaderBoardLoaded) {
          setState(() {
            leaderboardData = state.leaderboardData;
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is! LeaderBoardLoaded;

        final List<dynamic> students =
            (leaderboardData['leaderboard'] as List<dynamic>?) ?? [];
        final totalAttempts = leaderboardData['totalAttempts'] ?? 0;
        final averageScore = leaderboardData['averageScore'] ?? 0;
        final highestScore = leaderboardData['highestScore'] ?? 0;

        // sort by percentage descending so rank order (index 0 = 1st place) is correct
        final sortedStudents = [...students]
          ..sort((a, b) =>
              (b['percentage'] as num).compareTo(a['percentage'] as num));

        return Scaffold(
          backgroundColor: const Color(0xffF6F8FC),
          appBar: AppBar(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF667eea),
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Leaderboard",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF667eea),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 55.sp,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      leaderboardData['quizTitle']?.toString() ??
                          widget.title ??
                          '',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: isLoading
                          ? statCardShimmer()
                          : statCard("Attempts", "$totalAttempts"),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: isLoading
                          ? statCardShimmer()
                          : statCard("Average", "$averageScore%"),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: isLoading
                          ? statCardShimmer()
                          : statCard("Highest", "$highestScore%"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: isLoading
                    ? ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: 6,
                  itemBuilder: (context, index) =>
                      leaderboardCardShimmer(),
                )
                    : sortedStudents.isEmpty
                    ? Center(
                  child: Text(
                    "No attempts yet",
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 15.sp,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: sortedStudents.length,
                  itemBuilder: (context, index) {
                    final student = sortedStudents[index]
                    as Map<String, dynamic>;

                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.only(bottom: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(14.w),
                        leading: CircleAvatar(
                          radius: 22.r,
                          backgroundColor: index == 0
                              ? Colors.amber
                              : index == 1
                              ? Colors.grey
                              : index == 2
                              ? Colors.brown
                              : Colors.deepPurple.shade100,
                          child: Text(
                            "${index + 1}",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          student["studentName"]?.toString() ??
                              "Unknown",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: Text(
                            "Score ${student["score"]}/${student["total"]}",
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "${student["percentage"]}%",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget statCard(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget statCardShimmer() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _ShimmerBox(width: 40.w, height: 20.h, radius: 6),
          SizedBox(height: 8.h),
          _ShimmerBox(width: 55.w, height: 12.h, radius: 4),
        ],
      ),
    );
  }

  Widget leaderboardCardShimmer() {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            _ShimmerBox(width: 44.r, height: 44.r, radius: 22),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 110.w, height: 14.h, radius: 4),
                  SizedBox(height: 8.h),
                  _ShimmerBox(width: 80.w, height: 12.h, radius: 4),
                ],
              ),
            ),
            _ShimmerBox(width: 48.w, height: 26.h, radius: 30),
          ],
        ),
      ),
    );
  }
}

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