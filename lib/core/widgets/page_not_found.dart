import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

class PageNotFound extends StatelessWidget {
  const PageNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(t.page_not_found.title),
      ),
    );
  }
}
