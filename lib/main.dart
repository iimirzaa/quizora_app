
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/features/Quiz/quiz_bloc.dart';
import 'package:quiz_app/features/dashboard/dashboard_bloc.dart';
import 'package:quiz_app/features/getstarted/view/getstarted_view.dart';
import 'package:quiz_app/features/profile/profile_bloc.dart';

import 'features/Authentication/auth_bloc.dart';


void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (BuildContext context) => AuthBloc(),
        ),
        BlocProvider<DashboardBloc>(
          create: (BuildContext context) => DashboardBloc(),
        ),
        BlocProvider<ProfileBloc>(
            create: (BuildContext context)=>ProfileBloc()),
        BlocProvider<QuizBloc>(
            create: (BuildContext context)=>QuizBloc())
      ],
      child: const QuizApp(),
    ),
  );
}



class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      // Base design size (width x height)
      minTextAdapt: true,
      // Scale text automatically
      splitScreenMode: false,
      // Handles split screen
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.grey.shade300,
          ),
          home: child,
        );
      },
      child:GetstartedView(),
    );
  }
}