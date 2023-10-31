import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'flutter_refresh_loadmore.dart';

class CommonHeadWidget extends StatefulWidget {
  final double? parentHeight;

  //松开手指的时候
  final HeadStatus? headStatus;

  CommonHeadWidget({this.headStatus, this.parentHeight});

  @override
  State<StatefulWidget> createState() {
    return _RotateWidget();
  }
}

class _RotateWidget extends State<CommonHeadWidget>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

//    math.pi * 2  一圈 360度
    super.initState();
//    Matrix4.rotate(Vector3(25,25,25), controller.value)
  }

  @override
  Widget build(BuildContext context) {
    //旋转90度 pi/2
    return _getWidget();
  }

  Widget _getWidget() {
    switch (widget.headStatus!) {
      case HeadStatus.IDLE:
      case HeadStatus.PULL_REFRESH:
        return Icon(Icons.arrow_downward, color: Colors.black45);
      case HeadStatus.RELEASE_REFESH:
        animationController!.reset();
        animationController!.forward();
        return AnimatedBuilder(
          animation: animationController!,
          builder: (BuildContext context, Widget? child) {
            return Transform.rotate(
              angle: -animationController!.value * math.pi,
              child: child,
            );
          },
          child: Icon(
            Icons.arrow_downward,
            color: Colors.black45,
          ),
        );
      case HeadStatus.FRESHING:
        return CupertinoActivityIndicator();
      case HeadStatus.REFRESH_COMPLETE:
        return Icon(
          Icons.check,
          color: Colors.black45,
        );

//          Transform.rotate(angle: (1-animationController.value )*(math.pi/2),child : Icon(Icons.arrow_downward ),);
    }

    return Icon(
      Icons.arrow_downward,
      color: Colors.black45,
    );
  }
}
