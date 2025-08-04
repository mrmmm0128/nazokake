import 'package:flutter/material.dart';
import 'package:nazokake/pages/TimelineScreen.dart';

class TermsAgreementDialog extends StatelessWidget {
  final VoidCallback onAgreed;
  const TermsAgreementDialog({super.key, required this.onAgreed});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return AlertDialog(
      backgroundColor: secondaryColor,
      title: Text("利用規約への同意", style: TextStyle(color: primaryColor)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "以下の利用規約に同意いただく必要があります：\n\n"
              "・不適切ななぞかけは禁止です。\n"
              "・誹謗中傷、わいせつ、暴力的な内容は禁止です。\n"
              "・不適切ななぞかけを確認した際には通報ボタンより報告お願いいたします。\n"
              "・違反が確認された場合、対象となるなぞかけを削除させていただきます。\n\n"
              "これらの規約に同意のうえ、なぞかけSNSをお楽しみください。",
              style: TextStyle(color: primaryColor, fontSize: 14),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onAgreed,
          child: Text("同意する", style: TextStyle(color: primaryColor)),
        ),
      ],
    );
  }
}
