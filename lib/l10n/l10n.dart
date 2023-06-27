import "package:flutter/widgets.dart";
import "package:photos/generated/l10n.dart";
import "package:shared_preferences/shared_preferences.dart";

extension AppLocalizationsX on BuildContext {
  S get l10n => S.of(this);
}

// list of locales which are enabled for auth app.
// Add more language to the list only when at least 90% of the strings are
// translated in the corresponding language.
const List<Locale> appSupportedLocales = <Locale>[
  Locale('en'),
  Locale('es'),
  Locale('de'),
  Locale('it'),
  Locale("nl"),
  Locale("zh", "CN"),
];

Locale localResolutionCallBack(locales, supportedLocales) {
  for (Locale locale in locales) {
    if (appSupportedLocales.contains(locale)) {
      return locale;
    }
  }
  // if device language is not supported by the app, use en as default
  return const Locale('en');
}

Future<Locale> getLocale() async {
  final String? savedValue =
      (await SharedPreferences.getInstance()).getString('locale');
  // if savedLocale is not null and is supported by the app, return it
  if (savedValue != null) {
    late Locale savedLocale;
    if (savedValue.contains('_')) {
      final List<String> parts = savedValue.split('_');
      savedLocale = Locale(parts[0], parts[1]);
    } else {
      savedLocale = Locale(savedValue);
    }
    if (appSupportedLocales.contains(savedLocale)) {
      return savedLocale;
    }
  }
  return const Locale('en');
}

Future<void> setLocale(Locale locale) async {
  if (!appSupportedLocales.contains(locale)) {
    throw Exception('Locale $locale is not supported by the app');
  }
  final StringBuffer out = StringBuffer(locale.languageCode);
  if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
    out.write('_');
    out.write(locale.countryCode);
  }
  await (await SharedPreferences.getInstance())
      .setString('locale', out.toString());
}
