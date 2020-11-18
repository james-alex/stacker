import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacker/stacker.dart';

void main() {
  final containerA =
      Container(child: Text('A', textDirection: TextDirection.ltr));
  final containerB =
      Container(child: Text('B', textDirection: TextDirection.ltr));
  final containerC =
      Container(child: Text('C', textDirection: TextDirection.ltr));

  // Half the default transition duration.
  final wait = Duration(milliseconds: 120);

  testWidgets('StackSwapper', (WidgetTester tester) async {
    await tester
        .pumpWidget(StackSwapper(containerA, textDirection: TextDirection.ltr));

    expect(find.byWidget(containerA), findsOneWidget);

    await tester
        .pumpWidget(StackSwapper(containerB, textDirection: TextDirection.ltr));

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsNothing);

    await tester.pump(wait);

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsOneWidget);

    await tester.pumpAndSettle(wait);

    expect(find.byWidget(containerA), findsNothing);
    expect(find.byWidget(containerB), findsOneWidget);

    await tester
        .pumpWidget(StackSwapper(containerC, textDirection: TextDirection.ltr));

    expect(find.byWidget(containerB), findsOneWidget);
    expect(find.byWidget(containerC), findsNothing);

    await tester.pump(wait);

    expect(find.byWidget(containerB), findsOneWidget);
    expect(find.byWidget(containerC), findsOneWidget);

    await tester.pumpAndSettle(wait);

    expect(find.byWidget(containerB), findsNothing);
    expect(find.byWidget(containerC), findsOneWidget);
  });

  testWidgets('StackSwitcher', (WidgetTester tester) async {
    final containers = <Container>[containerA, containerB, containerC];

    await tester.pumpWidget(
        StackSwitcher(containers, child: 0, textDirection: TextDirection.ltr));

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsNothing);
    expect(find.byWidget(containerC), findsNothing);

    await tester.pumpWidget(
        StackSwitcher(containers, child: 1, textDirection: TextDirection.ltr));

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsNothing);
    expect(find.byWidget(containerC), findsNothing);

    await tester.pump(wait);

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsOneWidget);
    expect(find.byWidget(containerC), findsNothing);

    await tester.pumpAndSettle(wait);

    expect(find.byWidget(containerA), findsNothing);
    expect(find.byWidget(containerB), findsOneWidget);
    expect(find.byWidget(containerC), findsNothing);

    await tester.pumpWidget(
        StackSwitcher(containers, child: 2, textDirection: TextDirection.ltr));

    expect(find.byWidget(containerA), findsNothing);
    expect(find.byWidget(containerB), findsOneWidget);
    expect(find.byWidget(containerC), findsNothing);

    await tester.pump(wait);

    expect(find.byWidget(containerA), findsNothing);
    expect(find.byWidget(containerB), findsOneWidget);
    expect(find.byWidget(containerC), findsOneWidget);

    await tester.pumpAndSettle(wait);

    expect(find.byWidget(containerA), findsNothing);
    expect(find.byWidget(containerB), findsNothing);
    expect(find.byWidget(containerC), findsOneWidget);

    await tester.pumpWidget(
        StackSwitcher(containers, child: 0, textDirection: TextDirection.ltr));

    expect(find.byWidget(containerA), findsNothing);
    expect(find.byWidget(containerB), findsNothing);
    expect(find.byWidget(containerC), findsOneWidget);

    await tester.pump(wait);

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsNothing);
    expect(find.byWidget(containerC), findsOneWidget);

    await tester.pumpAndSettle(wait);

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsNothing);
    expect(find.byWidget(containerC), findsNothing);
  });

  testWidgets('Stacker', (WidgetTester tester) async {
    var started = 0;
    var completed = 0;
    final onComplete = () => completed++;

    final stacker = Stacker(
      containerA,
      textDirection: TextDirection.ltr,
      onSwitchStart: () => started++,
      onSwitchComplete: onComplete,
    );

    await tester.pumpWidget(stacker);

    expect(find.byWidget(containerA), findsOneWidget);

    stacker.build(containerB, onComplete: onComplete);

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsNothing);

    await tester.pumpFrames(stacker, wait);

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsOneWidget);

    await tester.pumpAndSettle(wait);

    expect(find.byWidget(containerA), findsNothing);
    expect(find.byWidget(containerB), findsOneWidget);

    expect(started, equals(1));
    expect(completed, equals(2));

    stacker.back(onComplete: onComplete);

    await tester.pumpFrames(stacker, wait);

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsOneWidget);

    await tester.pumpAndSettle(wait);

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsNothing);

    expect(started, equals(2));
    expect(completed, equals(4));

    stacker.forward(onComplete: onComplete);

    await tester.pumpFrames(stacker, wait);

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsOneWidget);

    await tester.pumpAndSettle(wait);

    expect(find.byWidget(containerA), findsNothing);
    expect(find.byWidget(containerB), findsOneWidget);

    expect(started, equals(3));
    expect(completed, equals(6));

    stacker.build(containerC, onComplete: onComplete);

    expect(find.byWidget(containerA), findsNothing);
    expect(find.byWidget(containerB), findsOneWidget);
    expect(find.byWidget(containerC), findsNothing);

    await tester.pumpFrames(stacker, wait);

    expect(find.byWidget(containerA), findsNothing);
    expect(find.byWidget(containerB), findsOneWidget);
    expect(find.byWidget(containerC), findsOneWidget);

    await tester.pumpAndSettle(wait);

    expect(find.byWidget(containerA), findsNothing);
    expect(find.byWidget(containerB), findsNothing);
    expect(find.byWidget(containerC), findsOneWidget);

    expect(started, equals(4));
    expect(completed, equals(8));

    stacker.root(onComplete: onComplete);

    await tester.pumpFrames(stacker, wait);

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsNothing);
    expect(find.byWidget(containerC), findsOneWidget);

    await tester.pumpAndSettle(wait);

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsNothing);
    expect(find.byWidget(containerC), findsNothing);

    expect(started, equals(5));
    expect(completed, equals(10));

    stacker.open(2, onComplete: onComplete);

    await tester.pumpFrames(stacker, wait);

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsNothing);
    expect(find.byWidget(containerC), findsOneWidget);

    await tester.pumpAndSettle(wait);

    expect(find.byWidget(containerA), findsNothing);
    expect(find.byWidget(containerB), findsNothing);
    expect(find.byWidget(containerC), findsOneWidget);

    expect(started, equals(6));
    expect(completed, equals(12));

    expect(stacker.currentChild, equals(2));
    expect(stacker.length, equals(3));

    stacker.pop(onComplete: onComplete);

    await tester.pumpFrames(stacker, wait);

    expect(stacker.length, equals(3));

    expect(find.byWidget(containerA), findsNothing);
    expect(find.byWidget(containerB), findsOneWidget);
    expect(find.byWidget(containerC), findsOneWidget);

    await tester.pumpAndSettle(wait);

    expect(find.byWidget(containerA), findsNothing);
    expect(find.byWidget(containerB), findsOneWidget);
    expect(find.byWidget(containerC), findsNothing);

    expect(started, equals(7));
    expect(completed, equals(14));

    expect(stacker.currentChild, equals(1));
    expect(stacker.length, equals(2));

    stacker.root(clearHistory: true, onComplete: onComplete);

    await tester.pumpFrames(stacker, wait);

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsOneWidget);
    expect(find.byWidget(containerC), findsNothing);

    await tester.pumpAndSettle(wait);

    expect(find.byWidget(containerA), findsOneWidget);
    expect(find.byWidget(containerB), findsNothing);
    expect(find.byWidget(containerC), findsNothing);

    expect(started, equals(8));
    expect(completed, equals(16));

    expect(stacker.currentChild, equals(0));
    expect(stacker.length, equals(1));
  });
}
