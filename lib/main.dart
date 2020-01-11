import 'package:extended_image_demo/gallery_fade_route.dart';
import 'package:extended_image_demo/gallery_view.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: DemoHome(),
    );
  }
}

class DemoHome extends StatefulWidget {
  @override
  _DemoHomeState createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  List<String> _imageUrls;

  @override
  void initState() {
    super.initState();

    _imageUrls = [
      'https://www.wubaui.com/upload/2019/0906/1567761093775.jpg',
      'https://img3.doubanio.com/view/photo/l/public/p2534887502.webp',
      'https://img3.doubanio.com/view/photo/l/public/p2534642457.webp',
      'https://img3.doubanio.com/view/photo/l/public/p2526680131.webp',
      'https://img3.doubanio.com/view/photo/l/public/p2526680118.webp',
      'https://img3.doubanio.com/view/photo/l/public/p2526680111.webp',
      'https://img3.doubanio.com/view/photo/l/public/p2526680102.webp',
      'https://img3.doubanio.com/view/photo/l/public/p2526680095.webp',
      'https://img3.doubanio.com/view/photo/l/public/p2526680078.webp',
      'https://img3.doubanio.com/view/photo/l/public/p2526680050.webp'
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Wrap(
        alignment: WrapAlignment.start,
        direction: Axis.horizontal,
        spacing: 7,
        runSpacing: 7,
        children: _imageUrls.take(9).map((urlString) {
          return Hero(
            tag: urlString,
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
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    GalleryFadeRoute(GalleryWidget(
                      imageUrls: _imageUrls,
                      index: _imageUrls.indexOf(urlString),
                    )));
              },
              child: ExtendedImage.network(
                urlString,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }
}
