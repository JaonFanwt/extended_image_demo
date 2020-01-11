import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum MoveDirection { Up, Down }

class GalleryWidget extends StatefulWidget {
  final List<String> imageUrls;
  final int index;

  GalleryWidget({this.imageUrls, this.index}) : assert(imageUrls != null);

  @override
  _GalleryWidgetState createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  AnimationController _animationController;
  Animation<double> _animation;
  Function animationListener;

  List<double> doubleTapScales = <double>[1.0, 2.0];

  MoveDirection _moveDirection;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
  }

  double initScale({Size imageSize, Size size, double initialScale}) {
    var n1 = imageSize.height / imageSize.width;
    var n2 = size.height / size.width;
    if (n1 > n2) {
      final FittedSizes fittedSizes =
          applyBoxFit(BoxFit.contain, imageSize, size);
      Size destinationSize = fittedSizes.destination;
      return size.width / destinationSize.width;
    } else if (n1 / n2 < 1 / 4) {
      final FittedSizes fittedSizes =
          applyBoxFit(BoxFit.contain, imageSize, size);
      Size destinationSize = fittedSizes.destination;
      return size.height / destinationSize.height;
    }

    return initialScale;
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedImageSlidePage(
      resetPageDuration: const Duration(milliseconds: 100),
      slidePageBackgroundHandler: (offset, size) {
        double distance = offset.dy * 0.001;
        double opacity = min(max(1.0 - distance, 0.1), 1.0);
        return Color(0xFF131415).withOpacity(opacity);
      },
      slideScaleHandler: (Offset offset) {
        double distance = offset.dy * 0.001;
        double scale = min(max(1.0 - distance, 0.8), 1.0);
        return scale;
      },
      slideOffsetHandler: (Offset offset) {
        if (_moveDirection == null && offset.dy <= 0.0) return Offset.zero;
        if (_moveDirection == null) {
          _moveDirection =
              offset.dy > 0.0 ? MoveDirection.Down : MoveDirection.Up;
        }
        return offset;
      },
      slideEndHandler: (Offset offset) {
        _moveDirection = null;
        return offset.dy > 70.0;
      },
      slideType: SlideType.onlyImage,
      child: Material(
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: _buildPageView(),
      ),
    );
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });

    _preloadImagesWithIndex(index);
  }

  void _preloadImagesWithIndex(int index) async {
    List<int> preloadIndexes = [-2, -1, 1, 2];
    for (int i = 0; i < preloadIndexes.length; i++) {
      int preloadIndex = preloadIndexes[i] + index;
      if (preloadIndex < 0) continue;
      if (preloadIndex >= widget.imageUrls.length) continue;

      var urlString = widget.imageUrls[preloadIndex];
      getNetworkImageData(urlString);
    }
  }

  Widget _buildPageView() {
    return ExtendedImageGesturePageView.builder(
      itemBuilder: (BuildContext context, int index) {
        var imageUrl = widget.imageUrls[index];
        Widget image = ExtendedImage.network(
          imageUrl,
          fit: BoxFit.contain,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: (state) {
            double initialScale = 1.0;

            if (state.extendedImageInfo != null &&
                state.extendedImageInfo.image != null) {
              initialScale = initScale(
                  size: MediaQuery.of(context).size,
                  initialScale: initialScale,
                  imageSize: Size(
                      state.extendedImageInfo.image.width.toDouble(),
                      state.extendedImageInfo.image.height.toDouble()));
            }
            return GestureConfig(
                initialAlignment: InitialAlignment.topCenter,
                inPageView: true,
                initialScale: initialScale,
                maxScale: max(initialScale, 5.0),
                animationMaxScale: max(initialScale, 5.0),
                cacheGesture: false);
          },
          enableSlideOutPage: true,
          heroBuilderForSlidingPage: (result) {
            if (index < min(9, widget.imageUrls.length)) {
              return Hero(
                tag: imageUrl,
                child: result,
                flightShuttleBuilder: (BuildContext flightContext,
                    Animation<double> animation,
                    HeroFlightDirection flightDirection,
                    BuildContext fromHeroContext,
                    BuildContext toHeroContext) {
                  final Hero hero = flightDirection == HeroFlightDirection.pop
                      ? fromHeroContext.widget
                      : toHeroContext.widget;
                  return hero.child;
                },
              );
            } else {
              return result;
            }
          },
          onDoubleTap: (ExtendedImageGestureState state) {
            var pointerDownPosition = state.pointerDownPosition;
            double begin = state.gestureDetails.totalScale;
            double end;

            // remove old
            _animation?.removeListener(animationListener);
            // stop pre
            _animationController.stop();
            // reset to use
            _animationController.reset();

            if (begin == doubleTapScales[0]) {
              end = doubleTapScales[1];
            } else {
              end = doubleTapScales[0];
            }

            animationListener = () {
              state.handleDoubleTap(
                  scale: _animation.value,
                  doubleTapPosition: pointerDownPosition);
            };
            _animation = _animationController
                .drive(Tween<double>(begin: begin, end: end));
            _animation.addListener(animationListener);
            _animationController.forward();
          },
        );
        Widget w = GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          behavior: HitTestBehavior.translucent,
          child: image,
        );
        return w;
      },
      itemCount: widget.imageUrls.length,
      onPageChanged: (int index) {
        currentIndex = index;
      },
      controller: PageController(initialPage: currentIndex),
      scrollDirection: Axis.horizontal,
    );
  }
}
