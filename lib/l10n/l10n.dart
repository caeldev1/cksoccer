import 'package:flutter/widgets.dart';
import 'package:ck_soccer/l10n/arb/app_localizations.dart';

export 'package:ck_soccer/l10n/arb/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
