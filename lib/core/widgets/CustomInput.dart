import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomInput extends StatefulWidget {
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final  TextInputType? type;

  const CustomInput({
    super.key,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.type,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  late bool _isObscure;
  bool _isFocused = false;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: Colors.blue.withOpacity(0.20),
              blurRadius: 8.sp,
              spreadRadius: 1.sp,
            )
        ],
      ),
      child: TextFormField(
        keyboardType: widget.type,
        focusNode: _focusNode,
        controller: widget.controller,
        validator: widget.validator,
        obscureText: _isObscure,
        onChanged: widget.onChanged,
        style: TextStyle(fontSize: 14.sp),
        // smaller text
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(fontSize: 14.sp),
          filled: true,
          fillColor: Colors.grey.shade100,

          // 👇 Reduced padding (THIS makes it slim)
          contentPadding:
           EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),

          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, size: 20.sp)
              : null,

          suffixIcon: widget.obscureText
              ? IconButton(
            icon: Icon(
              _isObscure
                  ? Icons.visibility_off
                  : Icons.visibility,
              size: 20.sp,
            ),
            onPressed: () {
              setState(() {
                _isObscure = !_isObscure;
              });
            },
          )
              : null,

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1.2.w,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:  BorderSide(
              color: Color(0xFF212680),
              width: 1.5.w,
            ),
          ),
        ),
      ),
    );
  }
}