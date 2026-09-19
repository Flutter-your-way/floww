import 'dart:async';
import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Duration speed;
  final VoidCallback? onFinished;
  final bool start;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.speed = const Duration(milliseconds: 15),
    this.onFinished,
    this.start = true,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  int _displayedCharacterCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.start) _startTyping();
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    final textChanged = oldWidget.text != widget.text;
    final justEnabled = !oldWidget.start && widget.start;
    if (widget.start && (textChanged || justEnabled)) {
      _startTyping();
    }
  }

  void _startTyping() {
    _timer?.cancel();
    _displayedCharacterCount = 0;

    if (widget.text.isEmpty) {
      widget.onFinished?.call();
      return;
    }

    _timer = Timer.periodic(widget.speed, (timer) {
      if (_displayedCharacterCount < widget.text.length) {
        setState(() {
          _displayedCharacterCount++;
        });
      } else {
        _timer?.cancel();
        widget.onFinished?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: widget.textAlign ?? TextAlign.start,
      text: TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: widget.text.substring(0, _displayedCharacterCount)),
          TextSpan(
            text: widget.text.substring(_displayedCharacterCount),
            style: const TextStyle(color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}
