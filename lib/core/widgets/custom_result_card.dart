import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
Widget buildQuizResultCard(List<dynamic> quizzes) {
  return Container(
    padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.r),
      color: Colors.white,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Result",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.sp),
            ),
            Text(
              "View All",
              style: GoogleFonts.poppins(color: Color(0xFF764BA2), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        ...quizzes.map((quiz) => _QuizResultRow(quiz: quiz)).toList(),
      ],
    ),
  );
}

class _QuizResultRow extends StatefulWidget {
  final Map<String, dynamic> quiz;
  const _QuizResultRow({required this.quiz});

  @override
  State<_QuizResultRow> createState() => _QuizResultRowState();
}

class _QuizResultRowState extends State<_QuizResultRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _barAnim;

  Color get _scoreColor {
    final pct = widget.quiz['percentage'] as int;
    if (pct >= 80) return Color(0xFF1D9E75);
    if (pct >= 60) return Color(0xFFEF9F27);
    return Color(0xFFD85A30);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _barAnim = Tween<double>(
      begin: 0,
      end: (widget.quiz['percentage'] as int) / 100,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 100), () => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // handle tap — navigate to quiz detail
      },
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.quiz['quizTitle'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  "${widget.quiz['percentage']}%",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    color: _scoreColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),

            SizedBox(height: 6.h),
            AnimatedBuilder(
              animation: _barAnim,
              builder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: _barAnim.value,
                  minHeight: 4.h,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(_scoreColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}