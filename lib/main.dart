import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hitster_2/pages/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  AppConfig.load();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Default auf system, falls noch nichts gespeichert
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString("brightnessMode") == null) {
    await prefs.setString("brightnessMode", "system");
  }

  runApp(MyApp(initialThemeMode: await _getSavedThemeMode()));
}

Future<ThemeMode> _getSavedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString("brightnessMode");
  if (saved == "light") return ThemeMode.light;
  if (saved == "dark") return ThemeMode.dark;
  return ThemeMode.system;
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  const MyApp({super.key, required this.initialThemeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void setThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("brightnessMode", mode.name);
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightScheme = lightDynamic ??
            ColorScheme.fromSeed(seedColor: Colors.purple, brightness: Brightness.light);
        final darkScheme = darkDynamic ??
            ColorScheme.fromSeed(seedColor: Colors.purple, brightness: Brightness.dark);

        ThemeData makeTheme(ColorScheme scheme) {
          final base = ThemeData(
            useMaterial3: true,
            colorScheme: scheme,
          );

          return base.copyWith(
            scaffoldBackgroundColor: scheme.surface,
            canvasColor: scheme.surface,

            textTheme: GoogleFonts.robotoTextTheme(base.textTheme).copyWith(
              titleLarge: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: makeTheme(lightScheme),
          darkTheme: makeTheme(darkScheme),
          themeMode: _themeMode,
          home: HomePage(setThemeMode: setThemeMode),
        );
      },
    );
  }
}