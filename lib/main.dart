import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:energy_media/helpers/scroll_behavior.dart';
import 'package:energy_media/internationalization/internationalization.dart';
import 'package:energy_media/router/router.dart';
import 'package:energy_media/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:energy_media/providers/user_provider.dart';
import 'package:energy_media/providers/visual_state_provider.dart';
import 'package:energy_media/providers/users_provider.dart';
import 'package:energy_media/providers/videos_provider.dart';
import 'package:energy_media/helpers/globals.dart';
import 'package:url_strategy/url_strategy.dart';

import 'package:energy_media/helpers/constants.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: anonKey,
    realtimeClientOptions: const RealtimeClientOptions(
      eventsPerSecond: 2,
    ),
  );

  supabaseML = SupabaseClient(supabaseUrl, anonKey, schema: 'media_library');

  await initGlobals();

  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(
            create: (context) => VisualStateProvider(context)),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => VideosProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('es');
  ThemeMode _themeMode = AppTheme.themeMode;

  void setLocale(Locale value) => setState(() => _locale = value);
  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        AppTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: MaterialApp.router(
        title: 'EnergyMedia Content Manager',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', 'US')],
        theme: ThemeData(
          brightness: Brightness.light,
          dividerColor: Colors.grey,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          dividerColor: Colors.grey,
        ),
        themeMode: _themeMode,
        routerConfig: router,
        scrollBehavior: MyCustomScrollBehavior(),
      ),
    );
  }
}
