
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task01/data/models/product/product_model.dart';
import 'core/preferences/preference_config.dart';
import 'presentations/app.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey();
BuildContext get appContext => navigatorKey.currentContext!;
ThemeData appTheme([BuildContext? context]) => Theme.of(context ?? appContext);
AppLocalizations appLanguage([BuildContext? context]) => AppLocalizations.of(context ?? appContext)!;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initPreferences();

  Hive.registerAdapter(ProductModelAdapter()); 
  Hive.registerAdapter(CategoryAdapter());     
  Hive.registerAdapter(RatingAdapter()); 
  

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );

}
