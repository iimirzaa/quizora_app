import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/core/widgets/custom_bottom_nav.dart';
import 'package:quiz_app/features/Leaderboard/leaderboard.dart';
import 'package:quiz_app/features/dashboard/teacherdashboard/view/teacherDashboard.dart';
import 'package:quiz_app/features/profile/view/profileView.dart';
class AllQuiz extends StatefulWidget {
  final List stats;
  const AllQuiz({super.key,required this.stats});

  @override
  State<AllQuiz> createState() => _AllQuizState();
}

class _AllQuizState extends State<AllQuiz> {
  int _currentIndex = 1;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF667eea),
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Quizzes",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),

      body:SafeArea(child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Column(
             children: [
               ...(widget.stats ).asMap().entries.map(
                     (entry) => _buildQuizTile(entry.value, entry.key),
               ),
             ],
          ),
        ),
      )),
      
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
            builder: (_) => LeaderBoard(id:quiz['quizId'],title:quiz['title'],
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
}
