import 'package:pilipalaz/pages/video/introduction/widgets/action_row_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  testWidgets('ActionRowItem accepts a Font Awesome 11 icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionRowItem(
            icon: const FaIcon(FontAwesomeIcons.thumbsUp),
            loadingStatus: false,
            text: '赞',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byType(FaIcon), findsOneWidget);
  });
}
