import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CascadingCarousel extends StatefulWidget {
  final List<String> carouselImages;

  const CascadingCarousel({super.key, required this.carouselImages});

  @override
  State<CascadingCarousel> createState() => _CascadingCarouselState();
}

class _CascadingCarouselState extends State<CascadingCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: widget.carouselImages.length,
      itemBuilder: (context, index, realIndex) {
        final bool active = index == _currentIndex;
        return _buildCarouselItem(widget.carouselImages[index], active);
      },
      options: CarouselOptions(
        height: 240,
        viewportFraction: 0.7,
        enlargeCenterPage: true,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
        scrollPhysics: const BouncingScrollPhysics(),
      ),
    );
  }

  Widget _buildCarouselItem(String imageUrl, bool active) {
    final double top = active ? 0 : 30;
    final double scale = active ? 1.0 : 0.85;
    final double opacity = active ? 1.0 : 0.7;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(top: top, bottom: 30),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
