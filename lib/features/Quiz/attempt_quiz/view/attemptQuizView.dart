import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quiz_app/features/studentResultDetail/view/resultView.dart';
import 'package:screen_protector/screen_protector.dart';

import '../../quiz_bloc.dart';

class QuizAttemptView extends StatefulWidget {
  final Map<String, dynamic> data;
  const QuizAttemptView({super.key, required this.data});

  @override
  State<QuizAttemptView> createState() => _QuizAttemptViewState();
}

class _QuizAttemptViewState extends State<QuizAttemptView>
    with WidgetsBindingObserver {

  // ─── Quiz State ───────────────────────────────────────────
  bool started = false;
  int currentQuestion = 0;
  int timeLeft = 0;
  List<int?> answers = [];
  Map<String, dynamic>? currentQuestionData; // fetched from backend one by one

  // ─── Quiz Meta (from widget.data) ─────────────────────────
  late final String quizId;
  late final String attemptId;
  late final int totalQuestions;

  // ─── Timers ───────────────────────────────────────────────
  Timer? quizTimer;
  Timer? loaderColorTimer;

  // ─── Loader Color ─────────────────────────────────────────
  Color loaderColor = Colors.white;

  // ──────────────────────────────────────────────────────────
  //  LIFECYCLE
  // ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ScreenProtector.preventScreenshotOn();

    quizId = widget.data['quizId'];
    attemptId = widget.data['attemptId'];
    totalQuestions = widget.data['totalQuestions'];
    timeLeft = widget.data['duration'] * 60;
    answers = List.generate(totalQuestions, (_) => null);

    _startLoaderColorCycle();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (started && state == AppLifecycleState.paused) {
      _submitQuiz(auto: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    quizTimer?.cancel();
    loaderColorTimer?.cancel();
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────
  //  LOADER COLOR CYCLE
  // ──────────────────────────────────────────────────────────

  void _startLoaderColorCycle() {
    loaderColorTimer = Timer.periodic(
      const Duration(milliseconds: 500),
          (_) => setState(() => loaderColor = _randomColor()),
    );
  }

  Color _randomColor() {
    final r = Random();
    return Color.fromARGB(255, r.nextInt(256), r.nextInt(256), r.nextInt(256));
  }

  // ──────────────────────────────────────────────────────────
  //  QUIZ CONTROLS
  // ──────────────────────────────────────────────────────────

  void _startQuiz() {
    setState(() => started = true);

    // fetch first question from backend
    context.read<QuizBloc>().add(
      FetchQuestionEvent(quizId: quizId, index: 0),
    );

  }

  void _onAnswerSelected(int optionIndex) {
    setState(() => answers[currentQuestion] = optionIndex);

    // auto-save silently — never blocks UI
    context.read<QuizBloc>().add(
      SaveAnswerEvent(
        quizId: quizId,
        attemptId: attemptId,
        questionIndex: currentQuestion,
        selectedIndex: optionIndex,
      ),
    );
  }

  void _goToNext() {
    final nextIndex = currentQuestion + 1;

    // fire both in parallel — save current + fetch next
    context.read<QuizBloc>().add(
      SaveAnswerEvent(
        quizId: quizId,
        attemptId: attemptId,
        questionIndex: currentQuestion,
        selectedIndex: answers[currentQuestion],
      ),
    );

    context.read<QuizBloc>().add(
      FetchQuestionEvent(quizId: quizId, index: nextIndex),
    );

    setState(() {
      currentQuestion = nextIndex;
      currentQuestionData = null; // clear while next loads
    });
  }

  void _goToPrevious() {
    // re-fetch previous question from backend
    context.read<QuizBloc>().add(
      FetchQuestionEvent(quizId: quizId, index: currentQuestion - 1),
    );

    setState(() {
      currentQuestion--;
      currentQuestionData = null;
    });
  }

  void _submitQuiz({required bool auto}) {
    quizTimer?.cancel();

    // no client-side scoring — backend does it
    context.read<QuizBloc>().add(
      SubmitQuizEvent(
        quizId: quizId,
        attemptId: attemptId,
        answers: answers,
        autoSubmit: auto,
      ),
    );
  }

  String _formatTime() {
    final min = timeLeft ~/ 60;
    final sec = timeLeft % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  // ──────────────────────────────────────────────────────────
  //  BUILD
  // ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is QuestionLoadedState) {
          setState(() => currentQuestionData = state.question);

          // start timer only on first question load
          if (state.index == 0 && quizTimer == null) {
            quizTimer = Timer.periodic(const Duration(seconds: 1), (_) {
              setState(() => timeLeft--);
              if (timeLeft <= 0) _submitQuiz(auto: true);
            });
          }
        }

        if (state is QuizSubmittedState) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => ResultView(
                score: state.score,
                percentage: state.percentage,
                total: state.total,
                breakdown: state.breakdown,
              ),
            ),
                (route) => false,
          );
        }

        if (state is QuizErrorState && state.isFatal) {
          _showErrorDialog(state.message);
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            _buildScaffold(),
            if (state is LoadingState) _buildLoadingOverlay(),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded, color: Colors.red, size: 40.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                'Something went wrong',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4a2c73),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF764ba2),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'OK',
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

  Widget _buildScaffold() {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: started ? _buildQuiz() : _buildInstructions(),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: loaderColor,
          size: 70.sp,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  INSTRUCTIONS SCREEN
  // ──────────────────────────────────────────────────────────

  Widget _buildInstructions() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Instructions',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xff764ba2),
              ),
            ),
            SizedBox(height: 20.h),
            _rule('Total Questions: $totalQuestions'),
            _rule('Time Limit: ${widget.data['duration']} minutes'),
            _rule('No screenshot/screen recording allowed'),
            _rule('Leaving app auto submits quiz'),
            _rule('Each question carries 1 mark'),
            SizedBox(height: 25.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff764ba2),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                onPressed: _startQuiz,
                child: Text('Start Quiz', style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rule(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xff764ba2)),
          SizedBox(width: 10.w),
          Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 13.sp))),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  QUIZ SCREEN
  // ──────────────────────────────────────────────────────────

  Widget _buildQuiz() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuizHeader(),
        SizedBox(height: 20.h),
        _buildProgressRow(),
        SizedBox(height: 20.h),
        _buildQuestionCard(),
        const Spacer(),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildQuizHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.data['title'],
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xff764ba2),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '⏱ ${_formatTime()}',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question ${currentQuestion + 1} of $totalQuestions',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
        SizedBox(height: 10.h),
        LinearProgressIndicator(
          value: (currentQuestion + 1) / totalQuestions,
          color: const Color(0xff764ba2),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    // show skeleton while question is loading
    if (currentQuestionData == null) {
      return Container(
        height: 200.h,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xff764ba2)),
        ),
      );
    }

    final question = currentQuestionData!;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question['question'],
            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 20.h),
          ...List.generate(
            (question['options'] as List).length,
                (i) => _buildOptionTile(question, i),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(Map question, int index) {
    final bool selected = answers[currentQuestion] == index;

    return GestureDetector(
      onTap: () => _onAnswerSelected(index), // auto-save on tap
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? const Color(0xff764ba2) : Colors.transparent,
          ),
          color: const Color(0xfff8f9ff),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14.r,
              backgroundColor: const Color(0xff764ba2),
              child: Text(
                question['options'][index]['label'],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                question['options'][index]['text'],
                style: GoogleFonts.poppins(fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final bool isLast = currentQuestion == totalQuestions - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: currentQuestion == 0 ? null : _goToPrevious,
          child: const Text('Previous'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff764ba2)),
          onPressed: currentQuestionData == null
              ? null // disable Next while question is loading
              : () {
            if (isLast) {
              _submitQuiz(auto: false);
            } else {
              _goToNext();
            }
          },
          child: Text(
            isLast ? 'Submit' : 'Next',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      ],
    );
  }
}