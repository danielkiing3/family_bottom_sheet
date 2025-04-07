import 'package:flutter/material.dart';

class SmallDivider extends StatelessWidget {
  const SmallDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(padding: EdgeInsets.only(left: 45), child: Divider());
  }
}
