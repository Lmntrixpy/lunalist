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

  // Default to system, if not saved
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late ThemeMode _themeMode;
  int _dynamicKey = 0;

  ColorScheme? _cachedLight;
  ColorScheme? _cachedDark;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => _dynamicKey++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      key: ValueKey(_dynamicKey),
      builder: (lightDynamic, darkDynamic) {
        // update cache of current colorscheme
        if (lightDynamic != null) _cachedLight = lightDynamic;
        if (darkDynamic != null) _cachedDark = darkDynamic;

        final lightScheme =
            _cachedLight ??
            lightDynamic ??
            ColorScheme.fromSeed(seedColor: Colors.purple, brightness: Brightness.light);

        final darkScheme =
            _cachedDark ??
            darkDynamic ??
            ColorScheme.fromSeed(seedColor: Colors.purple, brightness: Brightness.dark);

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