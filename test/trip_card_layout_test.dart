import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/a_list_screen.dart';
import 'package:mid_project_template/widgets.dart';

void main() {
  for (final vertical in [false, true]) {
    testWidgets(
      '${vertical ? 'grid' : 'list'} card keeps photo clear and actions beside title',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        var opened = 0;
        var favorites = 0;
        var deletions = 0;
        const item = Item(
          id: 7,
          title: 'A long travel title that must fit on a narrow card',
          subtitle: '2000.01.01 – 01.03 · Tokyo',
          image: '',
          destination: 'Tokyo',
          tags: ['일본', '도시 여행', '휴가'],
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 284,
                  height: vertical ? 300 : null,
                  child: TripCard(
                    item: item,
                    vertical: vertical,
                    onTap: () => opened++,
                    onFavorite: () => favorites++,
                    onDelete: () => deletions++,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final favorite = find.byKey(const ValueKey('favorite-7'));
        final delete = find.byKey(const ValueKey('delete-7'));
        final title = find.text(item.title);
        expect(find.text('TRIP MEMORY'), findsNothing);
        final photoBottom = tester.getBottomLeft(find.byType(NetImage)).dy;
        expect(
          tester.getTopLeft(favorite).dy,
          greaterThanOrEqualTo(photoBottom),
        );
        expect(tester.getTopLeft(delete).dy, greaterThanOrEqualTo(photoBottom));
        expect(
          tester.getCenter(favorite).dy,
          closeTo(tester.getCenter(title).dy, 1),
        );
        expect(
          tester.getTopLeft(favorite).dx,
          greaterThanOrEqualTo(tester.getTopRight(title).dx),
        );
        expect(
          tester.getTopLeft(find.text(item.subtitle)).dy,
          greaterThan(tester.getBottomLeft(title).dy),
        );
        await tester.tap(favorite);
        await tester.tap(delete);
        await tester.pumpAndSettle();
        expect(favorites, 1);
        expect(deletions, 1);
        expect(opened, 0);
        await tester.tap(title);
        expect(opened, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
