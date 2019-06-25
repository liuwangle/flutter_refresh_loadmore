import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'rotate_widget.dart';

//高度回调
typedef HeightsCallBack = double Function();

//animationcontroller 回调
typedef GetAnimationController = void Function(AnimationController controller);

//head  动画执行完成回调
typedef DefaultHeadAnimationComplete = void Function();

typedef SwrapHeadWidget = Widget Function(String statusStr);
typedef SwrapFooterWidget = Widget Function(String statusStr);

class DefaultHead extends StatefulWidget {
  HeightsCallBack heightsCallBack;
  GetAnimationController getAnimationController;
  DefaultHeadAnimationComplete oneceAnimationComplete;
  DefaultHeadAnimationComplete headAnimationComplete;

  double normalHeight;
  GlobalKey key;
  SwrapHeadWidget swrapHeadWidget;

  DefaultHead(
      {this.key,
      this.heightsCallBack,
      this.getAnimationController,
      this.oneceAnimationComplete,
      this.headAnimationComplete,
      this.swrapHeadWidget,
      this.normalHeight})
      : super(key: key);

  _DefaultHeadState __defaultHeadState;

  @override
  State<StatefulWidget> createState() {
    if (__defaultHeadState == null) {
      __defaultHeadState = _DefaultHeadState();
    }

    return __defaultHeadState;
  }
}

class _DefaultHeadState extends State<DefaultHead>
    with TickerProviderStateMixin {
  AnimationController positionController;

//  AnimationController controller;
//  CurvedAnimation curved;
//  Animation  rotate;

  _DefaultHeadState();

  @override
  void initState() {
//    controller = AnimationController( duration: const Duration(milliseconds: 1000),vsync: this);
    positionController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);

//    curved = new CurvedAnimation(parent: controller, curve:Interval(0.1, 0.3,curve:  Curves.linear),);
//    rotate=Tween<double>(begin: 0, end: 10,).animate(controller);
    positionController.addListener(() {
      setState(() {});
    });
    positionController.addStatusListener((status) {
      if (AnimationStatus.completed == status) {
        if (widget.heightsCallBack() > 0) {
          widget.oneceAnimationComplete();
        } else {
          widget.headAnimationComplete();
          lastStatu = "";
        }
      }
    });
    widget.getAnimationController(positionController);

    super.initState();
//    controller.repeat();
  }

  RotateWidget rotateWidget;

  bool shouldIsRotate = false;

  @override
  Widget build(BuildContext context) {
    rotateWidget = RotateWidget(
      isStartAnimation: shouldIsRotate,
    );
    print("fffffffffffffff  ${shouldIsRotate}");
    return Container(
      color: Colors.black12,
      height: widget.heightsCallBack(),
      child: widget.swrapHeadWidget == null
          ? Container(
              margin: EdgeInsets.only(bottom: 20),
              height: widget.normalHeight,
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  rotateWidget,
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    getText(),
                    style: TextStyle(fontSize: 15),
                  )
                ],
              ))
          : widget.swrapHeadWidget(getText()),
    );
  }

  String lastStatu = "";

  String getText() {
    String statu = "";
    if (widget.heightsCallBack() > widget.normalHeight) {
      if (positionController.isAnimating) {
        statu = "正加载中";
      } else {
        statu = "松开刷新";
      }
    } else if (widget.heightsCallBack() == widget.normalHeight) {
      statu = "正加载中";
    } else {
      if (lastStatu == "加载完成" || lastStatu == "正加载中") {
        statu = "加载完成";
      } else {
        statu = "下拉刷新";
      }
    }

    lastStatu = statu;
    if ("正加载中" == statu) {
      shouldIsRotate = true;
    } else {
      shouldIsRotate = false;
    }
    return statu;
  }
}
