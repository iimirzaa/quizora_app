import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildGradientButton({
  required String text,
  required double width,
  required double height,
  required VoidCallback onPressed,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) => Colors.transparent, // transparent for gradient
      ),
      shadowColor: WidgetStateProperty.resolveWith<Color>(
            (states) => Colors.transparent, // remove default shadow
      ),
    ),
    child: Ink(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}