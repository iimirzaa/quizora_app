import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/features/dashboard/studentDashboard/view/studentDashboardView.dart';


class ResultView extends StatelessWidget {
  final int score;
  final int percentage;
  final int total;
  final List<dynamic> breakdown;

  const ResultView({
    super.key,
    required this.score,
    required this.percentage,
    required this.total,
    required this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    final bool passed = percentage >= 50;

    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, passed),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                itemCount: breakdown.length,
                itemBuilder: (_, i) => _buildBreakdownCard(breakdown[i], i),
              ),
            ),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  HEADER
  // ──────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, bool passed) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // result icon
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              passed ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded,
              color: Colors.white,
              size: 44.sp,
            ),
          ),
          SizedBox(height: 16.h),

          Text(
            passed ? 'Well Done!' : 'Better Luck Next Time',
            style: GoogleFonts.poppins(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),

          Text(
            'You scored $score out of $total',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          SizedBox(height: 24.h),

          // score ring + stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statChip('Score', '$percentage%'),
              _scoreDial(percentage, passed),
              _statChip('Result', passed ? 'Pass' : 'Fail'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreDial(int percentage, bool passed) {
    return SizedBox(
      width: 90.w,
      height: 90.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 90.w,
            height: 90.w,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 7,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                passed ? Colors.greenAccent : Colors.redAccent,
              ),
            ),
          ),
          Text(
            '$percentage%',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.75),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  //  BREAKDOWN CARDS
  // ──────────────────────────────────────────────────────────

  Widget _buildBreakdownCard(dynamic item, int index) {
    final bool isCorrect = item['isCorrect'] == true;
    final int? selected = item['selected'];
    final int correctIndex = item['correctIndex'];
    final List options = item['options'] ?? [];
    final String explanation = item['explanation'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCorrect
              ? Colors.green.withOpacity(0.4)
              : Colors.red.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // question header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.withOpacity(0.07)
                  : Colors.red.withOpacity(0.07),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12.r,
                  backgroundColor: isCorrect ? Colors.green : Colors.red,
                  child: Icon(
                    isCorrect ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 14.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Q${index + 1}. ${item['question']}',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // options
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              children: List.generate(options.length, (i) {
                final bool isThisCorrect = i == correctIndex;
                final bool isThisSelected = i == selected;

                Color bgColor = const Color(0xfff8f9ff);
                Color borderColor = Colors.transparent;
                Widget? trailingIcon;

                if (isThisCorrect) {
                  bgColor = Colors.green.withOpacity(0.08);
                  borderColor = Colors.green;
                  trailingIcon = const Icon(Icons.check_circle, color: Colors.green, size: 18);
                } else if (isThisSelected && !isThisCorrect) {
                  bgColor = Colors.red.withOpacity(0.08);
                  borderColor = Colors.red;
                  trailingIcon = const Icon(Icons.cancel, color: Colors.red, size: 18);
                }

                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 11.r,
                        backgroundColor: const Color(0xff764ba2),
                        child: Text(
                          options[i]['label'],
                          style: TextStyle(color: Colors.white, fontSize: 11.sp),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          options[i]['text'],
                          style: GoogleFonts.poppins(fontSize: 13.sp),
                        ),
                      ),
                      if (trailingIcon != null) trailingIcon,
                    ],
                  ),
                );
              }),
            ),
          ),

          // explanation
          if (explanation.isNotEmpty)
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xff764ba2).withOpacity(0.06),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: const Color(0xff764ba2).withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: const Color(0xff764ba2), size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      explanation,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
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

  // ──────────────────────────────────────────────────────────
  //  BOTTOM BUTTON
  // ──────────────────────────────────────────────────────────

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff764ba2),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboardView()),
                (route) => false,
          ),
          child: Text(
            'Back to Dashboard',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    );
  }
}