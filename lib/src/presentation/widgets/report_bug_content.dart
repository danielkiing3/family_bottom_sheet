import 'package:family_bottom_sheet/src/presentation/widgets/family_bottom_sheet_shell.dart';
import 'package:flutter/material.dart';

class ReportBugContent extends StatelessWidget {
  const ReportBugContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyBottomSheetShell(
      text: 'Report a bug',
      children: [
        TextField(
          autofocus: true,
          maxLines: 1,
          decoration: InputDecoration(hintText: 'Subject'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            label: Text(
              'Describe the issue in more detail, including steps to reproduce',
            ),
          ),
        ),
      ],
    );
  }
}
