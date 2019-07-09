import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'flutter_refresh_loadmore.dart';
import 'rotate_widget.dart';

import 'refresh_data.dart';

////高度回调
//typedef HeightsCallBack = double Function();
class CustomHead extends StatefulWidget {
  double currentHeight;
  final HeadRefreshWidget child;
  HeadStatus headStatus;

  CustomHead(
      {Key key,
      this.currentHeight,
      this.child,
      this.headStatus = HeadStatus.IDLE})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CustomHeadState();
  }

  updateHeight({double height, HeadStatus headStatus}) {
    this.currentHeight = height;
    this.headStatus = headStatus;
  }
}

RotateWidget rotateWidget;

class CustomHeadState extends State<CustomHead> {
  double normalHeight = 0;

  @override
  Widget build(BuildContext context) {
    normalHeight = RefreshDataWidget.of(context).normalHeight;
    String statusStr = getText();
    return Container(
      color: Colors.black12,
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

  _getChildWidget(String statusStr) {
    if (widget.child != null) {
      return widget.child(widget.headStatus, widget.currentHeight);
    }
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        RotateWidget(
          headStatus: widget.headStatus,
          parentHeight: widget.currentHeight,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          statusStr,
          style: TextStyle(fontSize: 15),
        )
      ],
    );
  }

  String getText() {
    String statu = "";
    switch (widget.headStatus) {
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
