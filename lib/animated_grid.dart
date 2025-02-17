library animated_grid;

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// AnimatedGrid: A widget that displays a grid of items with staggered animations.
class AnimatedGridView extends StatefulWidget {
  /// The list of child widgets to display in the grid.
  final List<Widget> children;

  /// The number of columns in the grid. Defaults to 2.
  final int crossAxisCount;

  /// The spacing between grid items. Defaults to 16.
  final double spacing;

  /// The duration for the staggered animation delay between items. Defaults to 100 milliseconds.
  final Duration staggerDuration;

  /// The duration for the animation of each grid item. Defaults to 500 milliseconds.
  final Duration animationDuration;

  /// The initial offset for the slide animation. Defaults to 50.0.
  final double initialSlideOffset;

  /// The color of the placeholder shown while images are loading. Defaults to grey[500].
  final Color? placeholderColor;

  /// The BoxFit for the images. Defaults to BoxFit.cover.
  final BoxFit imageFit;

  /// The BorderRadius for the grid items. Defaults to 12.
  final double borderRadius;

  /// The shadow color and blur radius for the grid items.  Defaults to black with opacity 0.2, blurRadius 15, and offset (0, 4).
  final Color shadowColor;
  final double shadowBlurRadius;
  final Offset shadowOffset;

  const AnimatedGridView({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spacing = 16,
    this.staggerDuration = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 500),
    this.initialSlideOffset = 50.0,
    this.placeholderColor,
    this.imageFit = BoxFit.cover,
    this.borderRadius = 12.0,
    this.shadowColor = Colors.black,
    this.shadowBlurRadius = 15.0,
    this.shadowOffset = const Offset(0, 4),
  });

  @override
  AnimatedGridViewState createState() => AnimatedGridViewState();
}

class AnimatedGridViewState extends State<AnimatedGridView> {
  bool isAnimationReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() => isAnimationReady = true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(15),
      crossAxisCount: widget.crossAxisCount,
      mainAxisSpacing: widget.spacing,
      crossAxisSpacing: widget.spacing,
      children: List.generate(widget.children.length, (index) {
        Widget child = widget.children[index];
        
        // Handle different types of images
        if (child is Image) {
          if (child.image is NetworkImage) {
            // Handle network images with caching
            child = CachedNetworkImage(
              imageUrl: (child.image as NetworkImage).url,
              fit: widget.imageFit,
              placeholder: (context, url) => Container(
                color: widget.placeholderColor ?? Colors.grey[500],
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            );
          } else if (child.image is AssetImage || child.image is FileImage) {
            // Handle local images (assets or file system)
            child = Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: child.image,
                  fit: widget.imageFit,
                ),
              ),
            );
          }
        }

        return AnimationGridItem(
          delay: Duration(
              microseconds: index * widget.staggerDuration.inMicroseconds),
          duration: widget.animationDuration,
          isReadyToAnimation: isAnimationReady,
          child: child,
          initialSlideOffset: widget.initialSlideOffset,
          borderRadius: widget.borderRadius,
          shadowColor: widget.shadowColor,
          shadowBlurRadius: widget.shadowBlurRadius,
          shadowOffset: widget.shadowOffset,
        );
      }),
    );
  }
}

class AnimationGridItem extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final bool isReadyToAnimation;
  final double initialSlideOffset;
  final double borderRadius;
  final Color shadowColor;
  final double shadowBlurRadius;
  final Offset shadowOffset;

  const AnimationGridItem({
    super.key,
    required this.child,
    required this.delay,
    required this.duration,
    required this.isReadyToAnimation,
    required this.initialSlideOffset,
    required this.borderRadius,
    required this.shadowColor,
    required this.shadowBlurRadius,
    required this.shadowOffset,
  });

  @override
  AnimationGridItemState createState() => AnimationGridItemState();
}

class AnimationGridItemState extends State<AnimationGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _slideAnimation = Tween<double>(begin: widget.initialSlideOffset, end: 0.0)
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut)));

    _blurAnimation = Tween<double>(begin: 10.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));
  }

  @override
  void didUpdateWidget(AnimationGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReadyToAnimation && !_hasAnimated) {
      _hasAnimated = true;
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                  sigmaX: _blurAnimation.value, sigmaY: _blurAnimation.value),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: widget.shadowColor.withOpacity(0.2),
                      blurRadius: widget.shadowBlurRadius,
                      offset: widget.shadowOffset,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}