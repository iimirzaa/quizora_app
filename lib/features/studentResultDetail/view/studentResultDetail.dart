import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/core/widgets/GradientButton.dart';
import 'package:quiz_app/core/widgets/customContainer.dart';

class StudentResultDetailView extends StatefulWidget {
  final Map<String,dynamic> quiz;
  const StudentResultDetailView({super.key,required this.quiz});

  @override
  State<StudentResultDetailView> createState() =>
      _StudentResultDetailViewState();
}

class _StudentResultDetailViewState extends State<StudentResultDetailView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0.h, horizontal: 18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Quiz Result", style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade700,
              ),),
              Text(widget.quiz['quizTitle'],
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF764ba2),
                ),),
              Container(
                padding: EdgeInsets.all(10.r),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Text("Your Score",style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp
                    ),),
                    Text("${widget.quiz["score"]}/${widget.quiz['total']}",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp
                        )),
                    Text("${widget.quiz["percentage"]}% Correct",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp
                        )),
                  ],
                ),
              ),
              SizedBox(height: 10.h,),
              Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      buildContainer("Correct", widget.quiz["score"].toString()),
                      SizedBox(width: 10.h),
                      buildContainer("Wrong", (widget.quiz['total']-widget.quiz["score"]).toString()),
                      SizedBox(width: 10.h),
                      buildContainer("Time", "12"),
                      SizedBox(width: 10.h),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h,),
              buildRankCard(),
              SizedBox(height: 10.h,),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
              
              ...List.generate(widget.quiz['breakdown'].length, (index){
                final q=widget.quiz['breakdown'][index];
                return buildAnswerReviewCard(
                  question: q['question'],
                  options: [
                    q["options"][0]["text"],
                    q["options"][1]["text"],
                    q["options"][2]["text"],
                  q["options"][3]["text"],
                  ],
                  correctIndex:q["selected"],
                  selectedIndex:  widget.quiz['answers'][index],
                );
              }),
                ],),
            ),
          ),

              SizedBox(height: 10.h,),
              buildGradientButton(text: "View Leaderboard", width: double.infinity, height: 40.h, onPressed: (){})
            ],

          ),
        ),
      ),
    );
  }
  Widget buildRankCard(){
    return Container(
      width:double.infinity,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your Rank",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700
              ),),
              Text("Among 42 Students")
            ],
          ),
          Container(
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              color: Color(0XFF764ba2),
              borderRadius: BorderRadius.circular(10.r)
            ),
            child: Text("#3 🏆",
            style: GoogleFonts.albertSans(
              color: Colors.white
            ),),
          )
        ],
      ),
    );
  }
  Widget buildAnswerReviewCard({
    required String question,
    required List<String> options,
    required int correctIndex,
    required int selectedIndex,
  }) {

    bool isCorrect = correctIndex == selectedIndex;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Question + result icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 20,
              )
            ],
          ),

          SizedBox(height: 12.h),

          /// Options
          Column(
            children: List.generate(options.length, (index) {

              Color bgColor = Colors.grey.shade50;
              Color borderColor = Colors.transparent;
              IconData? icon;

              /// Correct answer
              if (index == correctIndex) {
                bgColor = Colors.green.withOpacity(0.08);
                borderColor = Colors.green;
                icon = Icons.check;
              }

              /// Wrong selected
              if (index == selectedIndex && selectedIndex != correctIndex) {
                bgColor = Colors.red.withOpacity(0.08);
                borderColor = Colors.red;
                icon = Icons.close;
              }

              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(10.r),

                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: borderColor),
                ),

                child: Row(
                  children: [

                    Expanded(
                      child: Text(
                        options[index],
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    if (icon != null)
                      Icon(
                        icon,
                        color: borderColor,
                        size: 18,
                      )
                  ],
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}
