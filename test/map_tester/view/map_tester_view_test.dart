// ignore_for_file: prefer_const_constructors

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ck_soccer/audio/audio.dart';
import 'package:ck_soccer/game/ck_soccer.dart';
import 'package:ck_soccer/map_tester/map_tester.dart';
import 'package:ck_soccer/settings/settings_controller.dart';

import '../../helpers/helpers.dart';

class _MockAudioController extends Mock implements AudioController {}

class _MockSettingsController extends Mock implements SettingsController {}

void main() {
  group('MapTesterView', () {
    late SettingsController settingsController;

    setUp(() {
      settingsController = _MockSettingsController();
      when(() => settingsController.muted).thenReturn(ValueNotifier(true));
      when(() => settingsController.musicOn).thenReturn(ValueNotifier(false));
      when(() => settingsController.soundsOn).thenReturn(ValueNotifier(false));
    });

    testWidgets('renders', (tester) async {
      await tester.pumpSubject(
        () async => '',
        settingsController: settingsController,
      );

      expect(find.byType(MapTesterView), findsOneWidget);
    });

    testWidgets('allows to select a game folder', (tester) async {
      tester.setViewSize();

      Future<String> getDirectoryPath() async => '.';

      await tester.pumpSubject(
        getDirectoryPath,
        settingsController: settingsController,
      );

      await tester.tap(find.text('Load'));
      await tester.pump();

      expect(
        find.byType(GameWidget<CKSoccer>),
        findsOneWidget,
      );
    });

    testWidgets('can unload the game', (tester) async {
      tester.setViewSize();
      Future<String> getDirectoryPath() async => '.';

      await tester.pumpSubject(
        getDirectoryPath,
        settingsController: settingsController,
      );

      await tester.tap(find.text('Load'));
      await tester.pump();

      expect(
        find.byType(GameWidget<CKSoccer>),
        findsOneWidget,
      );

      await tester.tap(find.text('Unload'));
      await tester.pump();

      expect(
        find.byType(GameWidget<CKSoccer>),
        findsNothing,
      );
    });

    testWidgets('allows to reload a game', (tester) async {
      tester.setViewSize();
      Future<String> getDirectoryPath() async => '.';

      await tester.pumpSubject(
        getDirectoryPath,
        settingsController: settingsController,
      );

      await tester.tap(find.text('Load'));
      await tester.pump();

      var widget = tester.widget<GameWidget<CKSoccer>>(
        find.byType(GameWidget<CKSoccer>),
      );

      final originalGame = widget.game;
      expect(originalGame, isNotNull);

      await tester.tap(find.text('Reload'));
      await tester.pumpAndSettle();

      widget = tester.widget<GameWidget<CKSoccer>>(
        find.byType(GameWidget<CKSoccer>),
      );

      final updatedGame = widget.game;
      expect(updatedGame, isNotNull);
      expect(updatedGame, isNot(originalGame));
    });
  });
}

extension on WidgetTester {
  Future<void> pumpSubject(
    Future<String> Function() getDirectoryPath, {
    AudioController? audioController,
    SettingsController? settingsController,
  }) async {
    await pumpApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(
            value: audioController ?? _MockAudioController(),
          ),
          RepositoryProvider.value(
            value: settingsController ?? _MockSettingsController(),
          ),
        ],
        child: MapTesterView(
          selectGameFolder: getDirectoryPath,
          timer: Future.value,
        ),
      ),
    );
  }
}
