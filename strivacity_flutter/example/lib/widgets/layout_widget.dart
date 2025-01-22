import 'package:flutter/material.dart';

class LayoutWidget extends StatelessWidget {
  final String type;
  final List<Widget> children;

  const LayoutWidget({super.key, required this.type, required this.children});

  @override
  Widget build(BuildContext context) {
    if (type == 'horizontal') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    } else {
      return Column(children: children);
    }
  }
}
