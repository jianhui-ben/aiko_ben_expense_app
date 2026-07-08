import 'package:aiko_ben_expense_app/core/theme/app_theme.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/wrapper.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// When true, the app talks to the local Firebase Emulator Suite instead of
/// the live project. Enable with `--dart-define=USE_EMULATOR=true` (used by the
/// end-to-end integration tests).
const bool useEmulator = bool.fromEnvironment('USE_EMULATOR');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Guard so repeated app launches (e.g. between integration tests in one
  // process) don't re-initialize Firebase or re-point the emulators.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (useEmulator) {
      await _connectToEmulators();
    }
  }

  await _configureLocalTimeZone();
  // Skip notification setup under the emulator: the iOS permission dialog can
  // stall automated test runs.
  if (!useEmulator) {
    await NotificationService().initNotification();
  }

  runApp(const MyApp());
}

Future<void> _connectToEmulators() async {
  // On the iOS/Android simulator, the host machine is reachable on localhost.
  const host = String.fromEnvironment('EMULATOR_HOST', defaultValue: 'localhost');
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  try {
    final localZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localZone.identifier));
  } catch (_) {
    // Fall back to a sane default if the platform can't report a zone.
    tz.setLocalLocation(tz.getLocation('America/Los_Angeles'));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: Consumer<User?>(
        builder: (context, user, _) {
          // Reset the navigator when the active household changes so pushed
          // routes (e.g. HouseholdSettingsScreen) don't cover the setup gate.
          return MaterialApp(
            key: ValueKey(user?.householdId ?? 'no-household'),
            theme: AppTheme.light,
            home: const Wrapper(),
          );
        },
      ),
    );
  }
}
