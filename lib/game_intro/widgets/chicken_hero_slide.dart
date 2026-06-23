import 'dart:ui';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:ck_soccer/gen/assets.gen.dart';

/// Metadata for one chicken hero carousel slide.
class ChickenHeroSlide {
  const ChickenHeroSlide({
    required this.image,
    required this.initials,
    required this.watermark,
    required this.leftStat,
    required this.rightStat,
    required this.score,
    required this.title,
    required this.description,
  });

  final AssetGenImage image;
  final String initials;
  final String watermark;
  final String leftStat;
  final String rightStat;
  final String score;
  final String title;
  final String description;
}

/// All hero slides shown on the home screen carousel.
final chickenHeroSlides = [
  ChickenHeroSlide(
    image: Assets.images.ck1,
    initials: 'ST',
    watermark: 'STRIKER',
    leftStat: 'SPD',
    rightStat: 'KCK',
    score: '4.7',
    title: 'Striker',
    description: 'The ultimate goal scorer on the pitch.',
  ),
  ChickenHeroSlide(
    image: Assets.images.ck2,
    initials: 'CP',
    watermark: 'CAPTAIN',
    leftStat: 'PWR',
    rightStat: 'DEF',
    score: '4.9',
    title: 'Captain',
    description: 'Leads the flock to victory every time.',
  ),
  ChickenHeroSlide(
    image: Assets.images.ck3,
    initials: 'FL',
    watermark: 'FLASH',
    leftStat: 'SPD',
    rightStat: 'AGI',
    score: '4.5',
    title: 'Flash',
    description: 'Fastest chicken feet in the league.',
  ),
  ChickenHeroSlide(
    image: Assets.images.ck4,
    initials: 'CH',
    watermark: 'CHAMP',
    leftStat: 'KCK',
    rightStat: 'PWR',
    score: '5.0',
    title: 'Champion',
    description: 'Unstoppable soccer legend of the coop.',
  ),
];

/// Glowing score badge inspired by the reference card UI.
class HeroScoreBadge extends StatelessWidget {
  const HeroScoreBadge({
    required this.score,
    super.key,
  });

  final String score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFB347),
            Color(0xFFFF6B4A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B4A).withValues(alpha: 0.55),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        score,
        style: const TextStyle(
          color: Color(0xFF2A1A10),
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

/// Bottom glass info panel for the active hero slide.
class ChickenHeroInfoPanel extends StatelessWidget {
  const ChickenHeroInfoPanel({
    required this.slide,
    required this.playLabel,
    required this.onPlay,
    super.key,
  });

  final ChickenHeroSlide slide;
  final String playLabel;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A22).withValues(alpha: 0.82),
            border: Border.all(color: Colors.white12),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        child: Text(
                          slide.leftStat,
                          key: ValueKey('left_${slide.leftStat}'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: HeroScoreBadge(
                        key: ValueKey('score_${slide.score}'),
                        score: slide.score,
                      ),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        child: Text(
                          slide.rightStat,
                          key: ValueKey('right_${slide.rightStat}'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: Column(
                    key: ValueKey(slide.title),
                    children: [
                      Text(
                        slide.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        slide.description,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white60,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GameElevatedButton(
                  label: playLabel,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6EE7A0),
                      Color(0xFF3CB371),
                    ],
                  ),
                  onPressed: onPlay,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
