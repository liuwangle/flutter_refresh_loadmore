import 'package:flutter/material.dart';
class RefreshDataWidget extends InheritedWidget{

  double normalHeight;
  double minHeight;

  Widget child;
  RefreshDataWidget({this.child,this.minHeight,this.normalHeight}):super(child:child);

  @override
  bool updateShouldNotify(RefreshDataWidget oldWidget) {
    return oldWidget.normalHeight!=normalHeight;
  }
  static RefreshDataWidget of(BuildContext context){

    return context.inheritFromWidgetOfExactType(RefreshDataWidget);
  }

}