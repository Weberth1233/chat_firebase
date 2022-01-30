import 'package:flutter/material.dart';

class Responsivo extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget web;

  const Responsivo(
      {required this.mobile, this.tablet, required this.web, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 1200) {
        return web;
      } else if (constraints.maxWidth >= 800) {
        Widget? resTablet = tablet;
        if (resTablet != null) {
          return tablet!;
        } else {
          return web;
        }
      } else {
        return mobile;
      }
    });
  }
}
