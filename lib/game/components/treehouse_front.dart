import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:ck_soccer/game/ck_soccer.dart';

typedef TreeHouseFrontRender = void Function(
  Canvas canvas,
  CameraComponent camera,
);

class TreeHouseFront extends PositionComponent with HasGameRef<CKSoccer> {
  TreeHouseFront({
    required this.renderFront,
  }) : super(priority: 1000, position: Vector2(0, 0));

  final TreeHouseFrontRender renderFront;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    renderFront(canvas, gameRef.camera);
  }
}
