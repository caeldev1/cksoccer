import 'package:flutter/material.dart';
import 'package:ck_soccer/game_intro/widgets/chicken_hero_slide.dart';

/// Full-screen horizontal carousel of chicken hero images.
class ChickenCarousel extends StatefulWidget {
  const ChickenCarousel({
    required this.onPageChanged,
    super.key,
  });

  final ValueChanged<int> onPageChanged;

  @override
  State<ChickenCarousel> createState() => _ChickenCarouselState();
}

class _ChickenCarouselState extends State<ChickenCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: chickenHeroSlides.length,
      onPageChanged: widget.onPageChanged,
      itemBuilder: (context, index) {
        final slide = chickenHeroSlides[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Align(
                alignment: const Alignment(0, -0.15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: slide.image.image(fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 48,
              left: 0,
              right: 0,
              child: Text(
                slide.watermark,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withValues(alpha: 0.06),
                  letterSpacing: 4,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Colorful page dots for the chicken carousel.
class CarouselPageIndicator extends StatelessWidget {
  const CarouselPageIndicator({
    required this.count,
    required this.currentIndex,
    super.key,
  });

  final int count;
  final int currentIndex;

  static const _activeColor = Color(0xFF6EE7A0);
  static const _inactiveColor = Color(0x44FFFFFF);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isActive ? _activeColor : _inactiveColor,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _activeColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
