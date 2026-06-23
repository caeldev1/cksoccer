import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ck_soccer/audio/audio.dart';
import 'package:ck_soccer/l10n/l10n.dart';
import 'package:ck_soccer/settings/settings.dart';

class _MockAudioController extends Mock implements AudioController {}

class _MockSettingsController extends Mock implements SettingsController {}

class _MockLeaderboardRepository extends Mock
    implements LeaderboardRepository {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    AudioController? audioController,
    SettingsController? settingsController,
    LeaderboardRepository? leaderboardRepository,
  }) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(
              value: audioController ?? _MockAudioController(),
            ),
            RepositoryProvider.value(
              value: settingsController ?? _MockSettingsController(),
            ),
            RepositoryProvider.value(
              value: leaderboardRepository ?? _MockLeaderboardRepository(),
            ),
          ],
          child: widget,
        ),
      ),
    );
  }
}
