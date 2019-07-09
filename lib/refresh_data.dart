import 'package:flutter/material.dart';

class RefreshDataWidget extends InheritedWidget {
  final double normalHeight;
  final double minHeight;

  final Widget child;

  RefreshDataWidget({this.child, this.minHeight, this.normalHeight})
      : super(child: child);

  @override
  bool updateShouldNotify(RefreshDataWidget oldWidget) {
    return oldWidget.normalHeight != normalHeight;
  }

  static RefreshDataWidget of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(RefreshDataWidget);
  }
}
