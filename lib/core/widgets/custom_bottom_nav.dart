import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      shape: const CircularNotchedRectangle(),
      child: Container(
        height: 65.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            _buildItem(Icons.home_rounded, "Home", 0),
            _buildItem(Icons.assignment_outlined, "Quizzes", 1),
            _buildItem(Icons.settings_rounded, "Settings", 2),

          ],
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, int index) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22.sp,
            color: isSelected ? const Color(0xFF764BA2) : Colors.grey,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: isSelected ? const Color(0xFF764BA2) : Colors.grey,
              fontWeight:
              isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}