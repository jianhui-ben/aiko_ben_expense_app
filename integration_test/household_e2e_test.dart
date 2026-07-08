import 'package:aiko_ben_expense_app/main.dart' as app;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// End-to-end tests for the shared-household experience.
///
/// These run the REAL app against the Firebase Emulator Suite. Start the
/// emulators first, then run with the USE_EMULATOR flag:
///
///   firebase emulators:start
///   flutter test integration_test/household_e2e_test.dart \
///       -d "iPhone 17 Pro" --dart-define=USE_EMULATOR=true
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Ignore cosmetic layout warnings (a tiny RenderFlex overflow in the legacy
  // screens) so they don't fail these behavioural E2E tests. Real errors still
  // propagate. The overflow is tracked for the Phase 3 UI redesign.
  final defaultOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
      return;
    }
    defaultOnError?.call(details);
  };

  // Always end signed out so the next test starts on the sign-in screen.
  tearDown(() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
  });

  testWidgets(
    'sign up -> create household -> add transaction -> household settings -> logout',
    (tester) async {
      await _launchApp(tester);

      final email = _uniqueEmail('owner');
      await _signUp(tester, email: email, password: 'test1234', name: 'Alice E2E');

      // New user is gated into household setup.
      await _pumpUntilFound(tester, find.text('Set up your household'));

      await _createHousehold(tester, 'Ben & Aiko');

      // Landed in the main app.
      await _pumpUntilFound(tester, find.text('Insights'));

      await _addTransaction(tester, amountDigits: '50', comment: 'E2E Coffee');

      // Back on Home after submitting.
      await _pumpUntilFound(tester, find.text('Insights'));

      // Verify the write reached Firestore through the real rules.
      final householdId = await _householdIdForCurrentUser();
      final txns = await FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .collection('transactions')
          .get();
      expect(txns.docs, isNotEmpty,
          reason: 'transaction should be written under the household');
      expect(txns.docs.first.data()['createdByName'], 'Alice E2E',
          reason: 'transaction should carry attribution');

      // Household settings shows the invite code.
      await _openTab(tester, 'Settings');
      await _tap(tester, find.text('Household'));
      await _pumpUntilFound(tester, find.text('Invite code'));
      expect(find.text('Members'), findsOneWidget);
      await _tap(tester, find.byType(BackButton));

      // Logout returns to the sign-in screen.
      await _pumpUntilFound(tester, find.widgetWithText(TextButton, 'Log Out'));
      await _tap(tester, find.widgetWithText(TextButton, 'Log Out'));
      await _pumpUntilFound(tester, find.text('Welcome back'));
    },
  );

  testWidgets(
    'second member joins via invite code, shares the ledger, and 2-member cap holds',
    (tester) async {
      await _launchApp(tester);

      // Owner creates a household.
      await _signUp(tester,
          email: _uniqueEmail('owner2'), password: 'test1234', name: 'Owner');
      await _pumpUntilFound(tester, find.text('Set up your household'));
      await _createHousehold(tester, 'Shared Home');
      await _pumpUntilFound(tester, find.text('Insights'));

      final ownerHouseholdId = await _householdIdForCurrentUser();
      final inviteCode = await _inviteCodeFor(ownerHouseholdId);
      await _logoutViaUi(tester);

      // Second member joins with the code.
      await _signUp(tester,
          email: _uniqueEmail('member'), password: 'test1234', name: 'Member');
      await _pumpUntilFound(tester, find.text('Set up your household'));
      await _joinHousehold(tester, inviteCode);
      await _pumpUntilFound(tester, find.text('Insights'));

      // The joiner is now in the SAME household.
      final memberHouseholdId = await _householdIdForCurrentUser();
      expect(memberHouseholdId, ownerHouseholdId);
      final members = await FirebaseFirestore.instance
          .collection('households')
          .doc(ownerHouseholdId)
          .collection('members')
          .get();
      expect(members.size, 2);
      await _logoutViaUi(tester);

      // A third member is rejected by the 2-member cap.
      await _signUp(tester,
          email: _uniqueEmail('third'), password: 'test1234', name: 'Third');
      await _pumpUntilFound(tester, find.text('Set up your household'));
      await _joinHousehold(tester, inviteCode);
      await _pumpUntilFound(tester, find.textContaining('full'));
    },
  );
}

// ---------------------------------------------------------------------------
// Flow helpers
// ---------------------------------------------------------------------------

Future<void> _launchApp(WidgetTester tester) async {
  await app.main();
  await _pumpUntilFound(tester, find.text('Welcome back'));
}

Future<void> _signUp(
  WidgetTester tester, {
  required String email,
  required String password,
  required String name,
}) async {
  // Toggle from sign-in to the register screen.
  await _tap(tester, find.widgetWithText(TextButton, 'Sign up'));
  await _pumpUntilFound(tester, find.text('Create account'));

  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), email);
  await tester.enterText(fields.at(1), password);
  await tester.enterText(fields.at(2), name);
  await tester.pump();

  await _tap(tester, find.widgetWithText(FilledButton, 'Sign up'));
}

Future<void> _createHousehold(WidgetTester tester, String householdName) async {
  await _tap(tester, find.text('Create household')); // the chooser card
  await _pumpUntilFound(tester, find.widgetWithText(FilledButton, 'Create household'));
  await tester.enterText(find.byType(TextField).first, householdName);
  await tester.pump();
  await _tap(tester, find.widgetWithText(FilledButton, 'Create household'));
}

Future<void> _joinHousehold(WidgetTester tester, String code) async {
  await _tap(tester, find.text('Join with code')); // the chooser card
  await _pumpUntilFound(tester, find.widgetWithText(FilledButton, 'Join household'));
  await tester.enterText(find.byType(TextField).first, code);
  await tester.pump();
  await _tap(tester, find.widgetWithText(FilledButton, 'Join household'));
}

Future<void> _addTransaction(
  WidgetTester tester, {
  required String amountDigits,
  required String comment,
}) async {
  // Grocery (id 1) is the only shopping_cart icon shown on Home.
  await _tap(tester, find.byIcon(Icons.shopping_cart));
  await _pumpUntilFound(tester, find.widgetWithText(ElevatedButton, 'Submit'));

  for (final digit in amountDigits.split('')) {
    await _tap(tester, find.widgetWithText(TextButton, digit));
  }
  // Second TextField in the sheet is the description.
  await tester.enterText(find.byType(TextField).at(1), comment);
  await tester.pump();

  await _tap(tester, find.widgetWithText(ElevatedButton, 'Submit'));
}

Future<void> _logoutViaUi(WidgetTester tester) async {
  await _openTab(tester, 'Settings');
  await _pumpUntilFound(tester, find.widgetWithText(TextButton, 'Log Out'));
  await _tap(tester, find.widgetWithText(TextButton, 'Log Out'));
  await _pumpUntilFound(tester, find.text('Welcome back'));
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await _tap(tester, find.text(label));
}

// ---------------------------------------------------------------------------
// Firestore assertions
// ---------------------------------------------------------------------------

Future<String> _householdIdForCurrentUser() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return doc.data()!['householdId'] as String;
}

Future<String> _inviteCodeFor(String householdId) async {
  final doc = await FirebaseFirestore.instance
      .collection('households')
      .doc(householdId)
      .get();
  return doc.data()!['inviteCode'] as String;
}

// ---------------------------------------------------------------------------
// Low-level helpers
// ---------------------------------------------------------------------------

String _uniqueEmail(String prefix) =>
    '${prefix}_${DateTime.now().microsecondsSinceEpoch}@test.com';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _pumpUntilFound(tester, finder);
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
  await tester.pump();
}

/// Pumps frames until [finder] matches or the timeout elapses. Unlike
/// [WidgetTester.pumpAndSettle] this tolerates indefinite animations such as
/// the loading spinner shown during async fetches.
Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 150));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for: ${finder.description}');
}
