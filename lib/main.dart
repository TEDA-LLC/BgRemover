import 'package:bg_crops/providers/app_config_provider.dart';
import 'package:bg_crops/providers/images_provider.dart';
import 'package:bg_crops/screens/main_screen.dart';
import 'package:bg_crops/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => AppConfigProvider()),
    ChangeNotifierProvider(create: (context) => ImagesProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var isInit = false;

  @override
  Future<void> didChangeDependencies() async {
    if (!isInit) {
      final provider = Provider.of<AppConfigProvider>(context, listen: false);

      if (mounted) {
        provider.toggleTheme();
        final prefs = await SharedPreferences.getInstance();
        final darkTheme = prefs.getBool('darkTheme');
        if (darkTheme != null) {
          provider.setTheme(toDarkTheme: darkTheme);
        }
      }

      isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final darkTheme = Provider.of<AppConfigProvider>(context).darkTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Background Remover',
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('vi', ''),
      ],
      theme: ThemeData(
        brightness: darkTheme ? Brightness.dark : Brightness.light,
      ),
      routes: {
        SettingsScreen.routeName: (ctx) => const SettingsScreen(),
      },
      home: const MainScreen(),
    );
  }
}
