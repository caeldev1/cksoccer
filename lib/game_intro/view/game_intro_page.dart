import 'dart:ui';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ck_soccer/constants/constants.dart';
import 'package:ck_soccer/game/game.dart';
import 'package:ck_soccer/game_intro/game_intro.dart';
import 'package:ck_soccer/gen/assets.gen.dart';
import 'package:ck_soccer/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

const _homeBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF1A3D3A),
    Color(0xFF2D5E4E),
    Color(0xFF1E4840),
  ],
);

const _playButtonGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF6EE7A0),
    Color(0xFF3CB371),
  ],
);

class GameIntroPage extends StatefulWidget {
  const GameIntroPage({super.key});

  @override
  State<GameIntroPage> createState() => _GameIntroPageState();
}

class _GameIntroPageState extends State<GameIntroPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final slide in chickenHeroSlides) {
      precacheImage(slide.image.provider(), context);
    }
  }

  void _onDownload() {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    launchUrl(Uri.parse(isAndroid ? Urls.playStoreLink : Urls.appStoreLink));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: _homeBackgroundGradient),
        child: isMobileWeb
            ? _MobileWebNotAvailableIntroPage(onDownload: _onDownload)
            : const _IntroPage(),
      ),
    );
  }

  bool get isMobileWeb =>
      kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}

class _IntroPage extends StatefulWidget {
  const _IntroPage();

  @override
  State<_IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<_IntroPage> {
  int _currentSlide = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slide = chickenHeroSlides[_currentSlide];

    return Stack(
      children: [
        Positioned.fill(
          child: ChickenCarousel(onPageChanged: _onSlideChanged),
        ),
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              _HeroTopBar(initials: slide.initials),
              const Spacer(),
              CarouselPageIndicator(
                count: chickenHeroSlides.length,
                currentIndex: _currentSlide,
              ),
              const SizedBox(height: 12),
              ChickenHeroInfoPanel(
                slide: slide,
                playLabel: l10n.gameIntroPagePlayButtonText,
                onPlay: () => Navigator.of(context).push(Game.route()),
              ),
              const _PlayfulBottomBar(),
            ],
          ),
        ),
      ],
    );
  }

  void _onSlideChanged(int index) {
    setState(() => _currentSlide = index);
  }
}

class _HeroTopBar extends StatelessWidget {
  const _HeroTopBar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Assets.images.gameLogo.image(width: 48, height: 48),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: Container(
              key: ValueKey(initials),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A843).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                initials,
                style: const TextStyle(
                  color: Color(0xFF2A1A10),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _PlayfulBottomBar extends StatelessWidget {
  const _PlayfulBottomBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white24),
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AudioButton(),
                  LeaderboardButton(),
                  InfoButton(),
                  HowToPlayButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileWebNotAvailableIntroPage extends StatelessWidget {
  const _MobileWebNotAvailableIntroPage({
    required this.onDownload,
  });

  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: Column(
            children: [
              const Spacer(),
              Assets.images.gameLogo.image(width: 200),
              const Spacer(flex: 2),
              Text(
                l10n.downloadAppMessage,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              GameElevatedButton.icon(
                label: l10n.downloadAppLabel,
                icon: const Icon(
                  Icons.download,
                  color: Colors.white,
                ),
                gradient: _playButtonGradient,
                onPressed: onDownload,
              ),
              const Spacer(),
              const BottomBar(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
