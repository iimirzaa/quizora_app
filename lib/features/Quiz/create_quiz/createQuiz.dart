import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quiz_app/core/validators/validator.dart';
import 'package:quiz_app/core/widgets/CustomInput.dart';
import 'package:quiz_app/core/widgets/GradientButton.dart';
import 'package:quiz_app/features/Quiz/quiz_bloc.dart';
import 'dart:async';
import 'dart:math';

import 'package:quiz_app/features/dashboard/teacherdashboard/view/teacherDashboard.dart';

class CreateQuiz extends StatefulWidget {
  const CreateQuiz({super.key});

  @override
  State<CreateQuiz> createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {
  bool showMcq = false;
  final TextEditingController _titleController = TextEditingController();

  // replace List<int> questions = [0]; with these
  final List<TextEditingController> _questionControllers = [
    TextEditingController(),
  ];
  final List<List<TextEditingController>> _optionControllers = [
    [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ],
  ];
  bool _validateManualQuestions() {
    for (int i = 0; i < _questionControllers.length; i++) {
      if (_questionControllers[i].text.trim().isEmpty &&
          _questionControllers[i].text.trim().length < 10) {
        _showValidationError("Question ${i + 1} is not valid");
        return false;
      }
      for (int j = 0; j < _optionControllers[i].length; j++) {
        if (_optionControllers[i][j].text.trim().isEmpty &&
            _optionControllers[i][j].text.trim().length < 3) {
          _showValidationError(
            "Question ${i + 1} — Option ${String.fromCharCode(65 + j)} is not valid",
          );
          return false;
        }
      }
      if (_optionControllers[i][4].text.trim().isEmpty) {
        _showValidationError("Question ${i + 1} — Correct answer is empty");
        return false;
      }

      final correct = _optionControllers[i][4].text.trim().toUpperCase();
      if (!['A', 'B', 'C', 'D'].contains(correct)) {
        _showValidationError(
          "Question ${i + 1} — Correct answer must be A, B, C, or D",
        );
        return false;
      }
    }
    return true;
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Incomplete Question",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4a2c73),
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
                    backgroundColor: Color(0xFF764ba2),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    "Fix it",
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
      ),
    );
  }

  void _showPublishMessage(String code) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.publish_outlined,
                  color: Colors.green,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Quiz Published",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4a2c73),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "${"Quiz code is "}$code",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => TeacherDashboard()),
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF764ba2),
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
      ),
    );
  }

  List<dynamic> generatedMcqs = [];
  final _formKey = GlobalKey<FormState>();
  late final Timer timer;
  Color loaderColor = Colors.white;

  Color getColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 500), (_) {
      setState(() {
        loaderColor = getColor();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _titleController.dispose();

    for (var c in _questionControllers) {
      c.dispose();
    }
    for (var opts in _optionControllers) {
      for (var c in opts) {
        c.dispose();
      }
    }
    super.dispose();
  }

  int maxQuestions = 25;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is McqSuccessState) {
          setState(() {
            generatedMcqs = state.mcq;
          });
        }
        if (state is PublishedState) {
          _showPublishMessage(state.quizCode);
        }
        if (state is ConfirmNewUploadState) {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 40.sp,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      "Upload new file?",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4a2c73),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      "Your generated MCQs will be lost if you upload a new file.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Row(
                      children: [
                        // cancel
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              side: BorderSide(color: Color(0xFF764ba2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                color: Color(0xFF764ba2),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // confirm
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                generatedMcqs = []; // clear old mcqs
                              });
                              context.read<QuizBloc>().add(
                                ConfirmNewUploadConfirmed(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF764ba2),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              "Yes, upload",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is ErrorState) {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // icon
                    Container(
                      padding: EdgeInsets.all(16),
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

                    // title
                    Text(
                      "Something went wrong",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4a2c73),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // message
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF764ba2),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Try Again",
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
            ),
          );
        }
      },

      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 5.h,
                    horizontal: 18.w,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Create New Quiz",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF764ba2),
                            fontSize: 20.sp,
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10.h),
                                _buildQuizDetailCard(),
                                SizedBox(height: 10.h),
                                _buildUploadAiCard(state),
                                SizedBox(height: 10.h),
                                buildManualQuestionCard(),
                                SizedBox(height: 10.h),

                                buildGradientButton(
                                  text: "Publish",
                                  width: double.infinity,
                                  height: 40.h,
                                  onPressed: () {
                                    if (!_formKey.currentState!.validate())
                                      return;

                                    // check if manual questions have ANY input — if yes, validate them
                                    final bool hasManualInput =
                                        _questionControllers.any(
                                          (c) => c.text.trim().isNotEmpty,
                                        );

                                    if (hasManualInput &&
                                        !_validateManualQuestions())
                                      return;

                                    // combine generated + manual mcqs
                                    List<dynamic> allMcqs = [...generatedMcqs];

                                    if (hasManualInput) {
                                      for (
                                        int i = 0;
                                        i < _questionControllers.length;
                                        i++
                                      ) {
                                        allMcqs.add({
                                          "question": _questionControllers[i]
                                              .text
                                              .trim(),
                                          "options": List.generate(
                                            4,
                                            (j) => {
                                              "label": String.fromCharCode(
                                                65 + j,
                                              ),
                                              "text": _optionControllers[i][j]
                                                  .text
                                                  .trim(),
                                            },
                                          ),
                                          "answer": _optionControllers[i][4]
                                              .text
                                              .trim()
                                              .toUpperCase(),
                                          "explanation": "",
                                        });
                                      }
                                    }

                                    // must have at least 1 question total
                                    if (allMcqs.isEmpty) {
                                      _showValidationError(
                                        "Please generate MCQs or add at least one manual question",
                                      );
                                      return;
                                    }

                                    context.read<QuizBloc>().add(
                                      PublishButtonClicked(
                                        title: _titleController.text.trim(),
                                        mcq: allMcqs, // combined list
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 30.h),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (state is LoadingState) // show loader when loading
                  Container(
                    color: Colors.black.withOpacity(
                      0.5,
                    ), // semi-transparent background
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: loaderColor,
                        size: 70.sp,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizDetailCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quiz Details",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Color(0xFF764ba2),
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 10.h),
          CustomInput(
            hint: "Enter Quiz title",
            controller: _titleController,
            validator: AppValidator.quizTitle,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildUploadAiCard(QuizState state) {
    final bool fileUploaded = state is FileSelectedState;
    final bool mcqGenerated = generatedMcqs.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF764ba2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      mcqGenerated
                          ? Icons.auto_awesome
                          : Icons.upload_file_rounded,
                      color: const Color(0xFF764ba2),
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    mcqGenerated ? "Generated MCQs" : "AI Generation",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF764ba2),
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
              if (mcqGenerated)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "${generatedMcqs.length} MCQs",
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: 16.h),

          // ── Upload zone (no file selected, no mcqs) ──────
          if (!fileUploaded && !mcqGenerated)
            GestureDetector(
              onTap: () => context.read<QuizBloc>().add(UploadFileClicked()),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 28.h),
                decoration: BoxDecoration(
                  color: const Color(0xfff6f0fb),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: const Color(0xFF764ba2).withOpacity(0.3),
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF764ba2).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        color: const Color(0xFF764ba2),
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Tap to upload PDF or Word",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: const Color(0xFF764ba2),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "AI will generate MCQs from your file",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _formatChip(Icons.picture_as_pdf_outlined, "PDF"),
                        SizedBox(width: 8.w),
                        _formatChip(Icons.description_outlined, "DOCX"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // ── File selected — preview ───────────────────────
          if (fileUploaded) ...[
            InkWell(
              onTap: () => context.read<QuizBloc>().add(
                PreviewFileClicked(fileName: state.fileName, file: state.file),
              ),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xfff3e8ff),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: Colors.deepPurple,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.fileName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                            ),
                          ),
                          Text(
                            "Tap to preview",
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          context.read<QuizBloc>().add(RemoveFileClicked()),
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.read<QuizBloc>().add(
                  GenerateMcqClicked(
                    fileName: state.fileName,
                    file: state.file,
                  ),
                ),
                icon: Icon(
                  Icons.auto_awesome,
                  size: 16.sp,
                  color: Colors.white,
                ),
                label: Text(
                  "Generate MCQs with AI",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF764ba2),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],

          // ── MCQs generated ────────────────────────────────
          if (mcqGenerated) ...[
            // replace all button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.read<QuizBloc>().add(UploadFileClicked()),
                icon: Icon(
                  Icons.refresh,
                  color: const Color(0xFF764ba2),
                  size: 16.sp,
                ),
                label: Text(
                  "Replace all — upload new file",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF764ba2),
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  side: BorderSide(
                    color: const Color(0xFF764ba2).withOpacity(0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // MCQ cards
            ...generatedMcqs.asMap().entries.map((entry) {
              final i = entry.key;
              final mcq = entry.value;
              return _buildGeneratedMcqCard(
                index: i,
                question: mcq['question'],
                options: (mcq['options'] as List)
                    .map((o) => Map<String, String>.from(o))
                    .toList(),
                answer: mcq['answer'],
                explanation: mcq['explanation'],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _formatChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF764ba2).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13.sp, color: const Color(0xFF764ba2)),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: const Color(0xFF764ba2),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedMcqCard({
    required int index,
    required String question,
    required List<Map<String, String>> options,
    required String answer,
    required String explanation,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xfff6f0fb),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF764ba2).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Question header ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF764ba2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  "Q${index + 1}",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4a2c73),
                  ),
                ),
              ),
              // delete button
              GestureDetector(
                onTap: () {
                  setState(() => generatedMcqs.removeAt(index));
                },
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // ── Options ──────────────────────────────────
          ...options.map((opt) {
            final isCorrect = opt['label'] == answer;
            return Container(
              margin: EdgeInsets.only(bottom: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.withOpacity(0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isCorrect
                      ? Colors.green
                      : const Color(0xFF764ba2).withOpacity(0.12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green
                          : const Color(0xFF764ba2).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        opt['label']!,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.sp,
                          color: isCorrect
                              ? Colors.white
                              : const Color(0xFF764ba2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      opt['text']!,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
                ],
              ),
            );
          }),

          SizedBox(height: 8.h),

          // ── Explanation ──────────────────────────────
          if (explanation.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: const Color(0xFF764ba2).withOpacity(0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: const Color(0xFF764ba2),
                    size: 15.sp,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      explanation,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: const Color(0xFF4a2c73),
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

  Widget buildManualQuestionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF764ba2).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Manual Questions",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Color(0xFF764ba2),
              fontSize: 16.sp,
            ),
          ),

          SizedBox(height: 10),

          // question forms
          ...List.generate(
            _questionControllers.length,
            (index) => buildQuestionForm(index),
          ),

          SizedBox(height: 10),

          Row(
            children: [
              // add button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_questionControllers.length < maxQuestions) {
                      setState(() {
                        _questionControllers.add(TextEditingController());
                        _optionControllers.add([
                          TextEditingController(),
                          TextEditingController(),
                          TextEditingController(),
                          TextEditingController(),
                          TextEditingController(),
                        ]);
                      });
                    }
                  },
                  icon: Icon(Icons.add, size: 18),
                  label: Text("Add Question"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF764ba2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // remove button — only show if more than 1 question
              if (_questionControllers.length > 1)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _questionControllers.removeLast().dispose();
                        _optionControllers.removeLast().forEach(
                          (c) => c.dispose(),
                        );
                      });
                    },
                    icon: Icon(Icons.remove, size: 18),
                    label: Text("Remove Last"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // show question count
          SizedBox(height: 8.h),
          Text(
            "${_questionControllers.length}/$maxQuestions questions",
            style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget buildQuestionForm(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xfff9f9fa),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Question ${index + 1}",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
              // question number indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Color(0xFF764ba2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  "${index + 1}/$maxQuestions",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Color(0xFF764ba2),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          CustomInput(
            hint: "Enter question",
            controller: _questionControllers[index],
          ),

          SizedBox(height: 8.h),

          ...List.generate(
            4,
            (optIndex) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: CustomInput(
                hint: "Option ${String.fromCharCode(65 + optIndex)}",
                controller: _optionControllers[index][optIndex],
              ),
            ),
          ),
          CustomInput(
            hint: "Correct Option",
            controller: _optionControllers[index][4],
          ),
        ],
      ),
    );
  }
}
