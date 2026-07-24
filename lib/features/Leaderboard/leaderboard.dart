import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  final List<Map<String, dynamic>> leaderboard = [
    {
      "name": "Ali Ahmed",
      "score": 19,
      "total": 20,
      "percentage": 95,
    },
    {
      "name": "Hamza",
      "score": 18,
      "total": 20,
      "percentage": 90,
    },
    {
      "name": "Sara",
      "score": 17,
      "total": 20,
      "percentage": 85,
    },
    {
      "name": "Ahmad",
      "score": 16,
      "total": 20,
      "percentage": 80,
    },
    {
      "name": "Bilal",
      "score": 15,
      "total": 20,
      "percentage": 75,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      appBar: AppBar(
        backgroundColor: Color(0xFF667eea),
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
                  "Flutter Basics Quiz",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "45 Attempts",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(child: statCard("Attempts", "45")),
                SizedBox(width: 10.w),
                Expanded(child: statCard("Average", "78%")),
                SizedBox(width: 10.w),
                Expanded(child: statCard("Highest", "95%")),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final student = leaderboard[index];

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
                      student["name"],
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
}