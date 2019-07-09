import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'flutter_refresh_loadmore.dart';

class RotateWidget extends StatefulWidget {

  double parentHeight;

  //松开手指的时候
  HeadStatus headStatus;
  RotateWidget({this.headStatus,this.parentHeight });

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

//    math.pi * 2  一圈 360度
    Tween<double> tween = Tween(begin: 0.0, end: math.pi * 2);
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


    if (!controller.isAnimating&&widget.headStatus==HeadStatus.FRESHING) {
      controller.forward();
    } else  if(widget.headStatus==HeadStatus.REFRESH_COMPLETE) {
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
    switch(widget.headStatus){

      case HeadStatus.IDLE:
      case HeadStatus.PULL_REFRESH:
      case HeadStatus.RELEASE_REFESH:
      return widget.parentHeight%(math.pi * 24)/12;
      case HeadStatus.FRESHING:
        if (!controller.isAnimating) {
          controller.forward();
        }
        return _value.value;
      case HeadStatus.REFRESH_COMPLETE:
        if (controller.isAnimating) {
          controller.forward();
        }
       return _value.value;
    }

    return _value.value;
  }
}


