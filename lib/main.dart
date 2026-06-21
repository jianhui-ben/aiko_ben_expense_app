import 'package:aiko_ben_expense_app/core/theme/app_theme.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/wrapper.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _configureLocalTimeZone();
  await NotificationService().initNotification();

  runApp(const MyApp());
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
      child: MaterialApp(
          theme: AppTheme.light,
          home: Wrapper()
      ),
    );
  }
}
