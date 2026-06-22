import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_dash/game/game.dart';

class _TestGame extends FlameGame with HasKeyboardHandlerComponents {}

class _MockKeyUpEvent extends Mock implements KeyUpEvent {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '';
  }
}

class _MockKeyDownEvent extends Mock implements KeyDownEvent {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '';
  }
}

KeyDownEvent _mockKeyDown(LogicalKeyboardKey key) {
  final event = _MockKeyDownEvent();
  when(() => event.logicalKey).thenReturn(key);
  return event;
}

KeyUpEvent _mockKeyUp(LogicalKeyboardKey key) {
  final event = _MockKeyUpEvent();
  when(() => event.logicalKey).thenReturn(key);
  return event;
}

void main() {
  group('CameraDebugger', () {
    test('has the correct initial values', () {
      final cameraDebugger = CameraDebugger();
      expect(cameraDebugger.size, equals(Vector2.all(150)));
      expect(
        cameraDebugger.paint.color.value,
        equals(Colors.pink.withOpacity(0.5).value),
      );
      expect(cameraDebugger.priority, equals(100));
    });

    testWithGame(
      'moves up when W is pressed',
      _TestGame.new,
      (game) async {
        final cameraDebugger = CameraDebugger();
        await game.ensureAdd(cameraDebugger);

        final initialPosition = cameraDebugger.position.clone();

        final controller =
            cameraDebugger.firstChild<KeyboardListenerComponent>()!;

        controller.onKeyEvent(_mockKeyDown(LogicalKeyboardKey.keyW), {
          LogicalKeyboardKey.keyW,
        });

        cameraDebugger.update(0.1);

        final updatedPosition = cameraDebugger.position.clone();
        expect(updatedPosition.y, lessThan(initialPosition.y));

        // Should not move anymore when the key is released
        controller.onKeyEvent(_mockKeyUp(LogicalKeyboardKey.keyW), {
          LogicalKeyboardKey.keyW,
        });
        cameraDebugger.update(0.1);

        final finalPosition = cameraDebugger.position.clone();
        expect(finalPosition.y, equals(updatedPosition.y));
      },
    );

    testWithGame('moves down when S is pressed', _TestGame.new, (game) async {
      final cameraDebugger = CameraDebugger();
      await game.ensureAdd(cameraDebugger);

      final initialPosition = cameraDebugger.position.clone();

      final controller =
          cameraDebugger.firstChild<KeyboardListenerComponent>()!;

      controller.onKeyEvent(_mockKeyDown(LogicalKeyboardKey.keyS), {
        LogicalKeyboardKey.keyS,
      });

      cameraDebugger.update(0.1);

      final updatedPosition = cameraDebugger.position.clone();
      expect(updatedPosition.y, greaterThan(initialPosition.y));

      // Should not move anymore when the key is released
      controller.onKeyEvent(_mockKeyUp(LogicalKeyboardKey.keyS), {
        LogicalKeyboardKey.keyS,
      });
      cameraDebugger.update(0.1);

      final finalPosition = cameraDebugger.position.clone();
      expect(finalPosition.y, equals(updatedPosition.y));
    });

    testWithGame('moves left when A is pressed', _TestGame.new, (game) async {
      final cameraDebugger = CameraDebugger();
      await game.ensureAdd(cameraDebugger);

      final initialPosition = cameraDebugger.position.clone();

      final controller =
          cameraDebugger.firstChild<KeyboardListenerComponent>()!;

      controller.onKeyEvent(_mockKeyDown(LogicalKeyboardKey.keyA), {
        LogicalKeyboardKey.keyA,
      });

      cameraDebugger.update(0.1);

      final updatedPosition = cameraDebugger.position.clone();
      expect(updatedPosition.x, lessThan(initialPosition.x));

      // Should not move anymore when the key is released
      controller.onKeyEvent(_mockKeyUp(LogicalKeyboardKey.keyA), {
        LogicalKeyboardKey.keyA,
      });
      cameraDebugger.update(0.1);

      final finalPosition = cameraDebugger.position.clone();
      expect(finalPosition.x, equals(updatedPosition.x));
    });

    testWithGame('moves left when D is pressed', _TestGame.new, (game) async {
      final cameraDebugger = CameraDebugger();
      await game.ensureAdd(cameraDebugger);

      final initialPosition = cameraDebugger.position.clone();

      final controller =
          cameraDebugger.firstChild<KeyboardListenerComponent>()!;

      controller.onKeyEvent(_mockKeyDown(LogicalKeyboardKey.keyD), {
        LogicalKeyboardKey.keyD,
      });

      cameraDebugger.update(0.1);

      final updatedPosition = cameraDebugger.position.clone();
      expect(updatedPosition.x, greaterThan(initialPosition.x));

      // Should not move anymore when the key is released
      controller.onKeyEvent(_mockKeyUp(LogicalKeyboardKey.keyD), {
        LogicalKeyboardKey.keyD,
      });
      cameraDebugger.update(0.1);

      final finalPosition = cameraDebugger.position.clone();
      expect(finalPosition.x, equals(updatedPosition.x));
    });

    testWithGame('increases speed when M is pressed', _TestGame.new,
        (game) async {
      final cameraDebugger = CameraDebugger();
      await game.ensureAdd(cameraDebugger);

      final controller =
          cameraDebugger.firstChild<KeyboardListenerComponent>()!;

      controller.onKeyEvent(_mockKeyDown(LogicalKeyboardKey.keyM), {
        LogicalKeyboardKey.space,
      });

      cameraDebugger.update(0.1);

      expect(cameraDebugger.speed, equals(900));

      // Should not move anymore when the key is released
      controller.onKeyEvent(_mockKeyUp(LogicalKeyboardKey.keyM), {
        LogicalKeyboardKey.keyM,
      });
      cameraDebugger.update(0.1);

      expect(cameraDebugger.speed, equals(300));
    });
  });
}
