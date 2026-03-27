import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lunalist/pages/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart';
import 'config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("lunalist");
    setWindowMinSize(const Size(600, 500));
  }

  await dotenv.load(fileName: '.env');
  await AppConfig.load();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Default to system, if not saved
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString("brightnessMode") == null) {
    await prefs.setString("brightnessMode", "system");
  }

  if (prefs.getBool("experimentalMode") == null) {
    await prefs.setBool("experimentalMode", false);
  }

  if (prefs.getBool("checkUpdateOnStartup") == null) {
    await prefs.setBool("checkUpdateOnStartup", true);
  }

  if (prefs.getBool("cameraAccess") == null) {
    await prefs.setBool("cameraAccess", true);
  }

  if (prefs.getBool("useUserSpotifyTokens") == null) {
    await prefs.setBool("useUserSpotifyTokens", false);
  }

  if (prefs.getBool("enableSystemColorScheme") == null) {
    await prefs.setBool("enableSystemColorScheme", false);
  }

  runApp(MyApp(initialThemeMode: await _getSavedThemeMode(), enableSystemColorScheme: await _getColorSchemeMode()));
}

Future<ThemeMode> _getSavedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString("brightnessMode");
  if (saved == "light") return ThemeMode.light;
  if (saved == "dark") return ThemeMode.dark;
  return ThemeMode.system;
}

Future<bool> _getColorSchemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getBool("enableSystemColorScheme");
  if (saved == null) return false;
  return saved;
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final bool enableSystemColorScheme;
  const MyApp({super.key, required this.initialThemeMode, required this.enableSystemColorScheme});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;
  late bool _enableSystemColorScheme;

  ColorScheme? _cachedLight;
  ColorScheme? _cachedDark;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    _enableSystemColorScheme = widget.enableSystemColorScheme;
    
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        if (lightDynamic != null) _cachedLight = lightDynamic;
        if (darkDynamic != null) _cachedDark = darkDynamic;

       final lightScheme = _enableSystemColorScheme
        ? (_cachedLight ??
            ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light))
        : ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light);

      final darkScheme = _enableSystemColorScheme
        ? (_cachedDark ??
            ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark))
        : ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark);
      
        ThemeData makeTheme(ColorScheme scheme) {
          final base = ThemeData(useMaterial3: true, colorScheme: scheme);
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
          home: HomePage(setThemeMode: (mode) async {
            setState(() => _themeMode = mode);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString("brightnessMode", mode.name);
          }),
        );
      },
    );
  }
}