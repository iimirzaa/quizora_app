import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
Widget buildContainer(
    String heading,
    String count,
    ){
  return Container(
    padding: EdgeInsets.all(5.r),
    height: 50.h,
    width: 150.w,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.r),
      color: Colors.white,
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(

          heading,
          overflow:TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w700,


          ),),
        Text(count ,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
              color: Color(0xFF764BA2),
              fontWeight: FontWeight.w600
          ),)

      ],
    ),

  );
}