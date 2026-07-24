import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/core/widgets/CustomInput.dart';
import 'package:quiz_app/core/widgets/custom_bottom_nav_student.dart';

import '../../dashboard/teacherdashboard/model/quizModel.dart';

class AllResultView extends StatefulWidget {

  const AllResultView({super.key,});

  @override
  State<AllResultView> createState() => _AllResultViewState();
}

class _AllResultViewState extends State<AllResultView> {
  int _currentIndex = 1;
  List<QuizModel> quizzes = [
    QuizModel(
      title: "Science Test",
      students: 45,
      status: "Published",
      completionRate: 78,
      createdAt: DateTime.now(),
    ),
    QuizModel(
      title: "Math Midterm",
      students: 32,
      status: "Draft",
      completionRate: 0,
      createdAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    QuizModel(
      title: "English Quiz",
      students: 50,
      status: "Published",
      completionRate: 64,
      createdAt: DateTime.now().subtract(Duration(days: 2)),
    ),
  ];
  QuizModel getMostRecentQuiz() {
    quizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return quizzes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "My Results",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Color(0xFF764ba2),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavStudent(
        currentIndex: 1,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0.h, horizontal: 18.w),
          child: Column(
            children: [
              CustomInput(hint: "Search Quiz"),
              SizedBox(height: 10.h,),
              buildResultCard(
                title: "Science Quiz",
                correct: 8,
                total: 10,
                timeTaken: 5,
                onTap: () {},
              ),
              

              buildResultCard(
                title: "Math Quiz",
                correct: 9,
                total: 10,
                timeTaken: 5,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
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
}
