import 'package:flutter/material.dart';

class ContainerWidget extends StatelessWidget {
  final List<Widget> children;

  const ContainerWidget({required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
        child: Column(children: children),
      ),
    );
  }
}
