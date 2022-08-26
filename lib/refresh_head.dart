import 'package:flutter/material.dart';

import 'flutter_refresh_loadmore.dart';
import 'rotate_widget.dart';

////高度回调
//typedef HeightsCallBack = double Function();
class CustomHead extends StatefulWidget {
  late final double? currentHeight;
  final HeadRefreshWidget? child;
  late final HeadStatus? headStatus;

  CustomHead(
      {Key? key,
      this.currentHeight,
      this.child,
      this.headStatus = HeadStatus.IDLE})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CustomHeadState();
  }

  updateHeight({double? height, HeadStatus? headStatus}) {
    this.currentHeight = height;
    this.headStatus = headStatus;
  }
}

CommonHeadWidget? rotateWidget;

class CustomHeadState extends State<CustomHead> {
  @override
  Widget build(BuildContext context) {
    String statusStr = getText();
    return Container(
      color: Colors.white,
      height: widget.currentHeight,
      child: SingleChildScrollView(
          child: new Container(
//            alignment: Alignment.bottomCenter,
        height: widget.currentHeight,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Positioned(
              left: 0.0,
              right: 0.0,
              child: Align(
//                  alignment: Alignment.bottomCenter,
                  child: new Container(
//                    color: Colors.deepOrange,
//                    alignment: Alignment.bottomCenter,
                height: normalHeight,
                child: _getChildWidget(statusStr),
              )),
            )
          ],
        ),
      )),
    );
  }

  CommonHeadWidget? _commonHeadWidget;
  HeadStatus? lastHeadStatus;
  _getChildWidget(String statusStr) {
    if (widget.child != null) {
      return widget.child!(widget.headStatus, widget.currentHeight);
    }
    if (_commonHeadWidget == null || lastHeadStatus != widget.headStatus) {
      lastHeadStatus = widget.headStatus;
      _commonHeadWidget = CommonHeadWidget(
        headStatus: widget.headStatus,
        parentHeight: widget.currentHeight,
      );
    }
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _commonHeadWidget!,
        SizedBox(
          width: 10,
        ),
        Text(
          statusStr,
          style: TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
        )
      ],
    );
  }

  String getText() {
    String statu = "";
    switch (widget.headStatus!) {
      case HeadStatus.IDLE:
        statu = "下拉刷新";
        break;
      case HeadStatus.PULL_REFRESH:
        statu = "下拉刷新";
        break;
      case HeadStatus.RELEASE_REFESH:
        statu = "松开刷新";
        break;
      case HeadStatus.FRESHING:
        statu = "正加载中";
        break;
      case HeadStatus.REFRESH_COMPLETE:
        statu = "加载完成";
        break;
    }
    return statu;
  }
}
