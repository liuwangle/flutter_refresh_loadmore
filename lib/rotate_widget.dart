import 'package:flutter/material.dart';
import 'dart:math' as math;

class RotateWidget extends StatefulWidget {
  bool isStartAnimation;

  RotateWidget({this.isStartAnimation});

  @override
  State<StatefulWidget> createState() {
    return _RotateWidget();
  }
}

class _RotateWidget extends State<RotateWidget> with TickerProviderStateMixin {
  AnimationController controller;
  Animation _value;


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  void initState() {
    controller = AnimationController(
        duration: Duration(milliseconds: 800), vsync: this);
    Tween tween = Tween(begin: 0, end: math.pi * 2);
    _value = tween.animate(controller);
    controller.addListener(() {
      if(controller.value==1){
        controller.value=0;
      }
      setState(() {});
    });
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
//        controller.value = 0;
//        controller.forward();
      }
    });

    super.initState();
//    controller.forward();
//    Matrix4.rotate(Vector3(25,25,25), controller.value)
  }

  @override
  Widget build(BuildContext context) {
//    if(widget.mykey.currentContext.size!=null){
//      if(widget.mykey.currentContext.size.height>0&&!controller.isAnimating){
//
//      }
//    }
    if (!controller.isAnimating && widget.isStartAnimation) {
      controller.forward();
    } else if (!widget.isStartAnimation && controller.isAnimating) {
      controller.stop(canceled: true);
    }


    Transform transform=Transform.rotate(
      //旋转90度 pi/2
      angle: _getValue(),
      child: Image.asset(

        'loading.png',
        package:"flutter_refresh_loadmore",
        width: 25.0,
        height: 25.0,
        fit: BoxFit.fitWidth,

      ));
//    print("xxxxxxxxxxxxxxxxxx1 \n  ${transform.transform}");
//    print("xxxxxxxxxxxxxxxxxx2 \n  ${Matrix4.identity()..rotateZ(_getValue())}");
    var mwidget =

     Container(
       width: 25.0,
       height: 25.0,

      child:transform,

    );
//    Container(
//
//      alignment: Alignment.center,
//      width: 50.0,
//      height: 50.0,
//
//      child: Image.asset(
//        'images/loading_11.png',
//        width: 50.0,
//        height: 50.0,
//        fit: BoxFit.cover,
//      ),
//    ) ;

    return mwidget;
  }

  double _getValue() {
    return double.parse(_value.value.toString());
  }
}
