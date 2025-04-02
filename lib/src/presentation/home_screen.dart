import 'package:family_bottom_sheet/src/custom_bottom_sheet/custom_bottom_sheet.dart';
import 'package:family_bottom_sheet/src/presentation/widgets/options_content.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: OutlinedButton(
          onPressed: () async {
            openModal(context);
          },
          child: const Text('Open Modal'),
        ),
      ),
    );
  }

  Future<void> openModal(BuildContext context) async {
    await FamilyModalSheet.show<void>(
      context: context,
      builder: (ctx) {
        return const OptionsContent();
      },
    );
  }
}
