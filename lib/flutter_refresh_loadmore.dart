import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'refresh_data.dart';
import 'refresh_head.dart';
import 'rotate_widget.dart';

typedef SwrapInsideWidget = Widget Function(BuildContext context, int index);

typedef RefrshCallback = Future Function();
typedef LoadMoreCallback = Future Function();

typedef HeadRefreshWidget = Widget Function(
    HeadStatus headStatus, double height);

typedef FooterRefreshWidget = Widget Function(String str);

enum HeadStatus {
  ///下拉刷新
  PULL_REFRESH,

  ///松开刷新
  RELEASE_REFESH,

  ///刷新中
  FRESHING,

  ///刷新完成
  REFRESH_COMPLETE,

  ///闲置
  IDLE,
}

class ListViewRefreshLoadMoreWidget extends StatefulWidget {
//listview 的item  widget
  SwrapInsideWidget swrapInsideWidget;

  //headviw
  HeadRefreshWidget headWidget;

  //刷新的回调  不传或者 传null  则关闭刷新
  RefrshCallback refrshCallback;

  //加载更多回调  不传或者 传null  则关闭加载更多
  LoadMoreCallback loadMoreCallback;
  bool hasMoreData = true;
  int itemCount;
  FooterRefreshWidget footerWidget;

  ListViewRefreshLoadMoreWidget(
      {Key key,
      @required this.swrapInsideWidget,
      this.refrshCallback,
      this.loadMoreCallback,
      this.headWidget,
      this.footerWidget,
      @required this.hasMoreData = true,
      @required this.itemCount = 0})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ListViewRefreshLoadMoreWidgetState();
  }
}

class ListViewRefreshLoadMoreWidgetState
    extends State<ListViewRefreshLoadMoreWidget> with TickerProviderStateMixin {
  double normalHeight = 60;
  double currentHeight = 0;
  double minHeight = 0.00001;

  @override
  void initState() {
    currentHeight = minHeight;
    positonAnimationController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    endAnimationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    WidgetsBinding widgetsBinding = WidgetsBinding.instance;
    //第一帧 绘制完毕
    widgetsBinding.addPostFrameCallback((callback) {
//      animationController.forward();
    });

//    Future.delayed(Duration(milliseconds: 15000),(){
//      controller.jumpTo(1000);
//      print("iiiiiiiiiiiiii   yyyyyyyyyyyy");
//    });

    endAnimationController.addListener(() {
      currentHeight = endAnimation.value;
      _update();
    });
    endAnimationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        currentHeadStatus = HeadStatus.IDLE;
        _updateAlwaysScrollable();
      }
    });

    positonAnimationController.addListener(() {
      currentHeight = positonAnimation.value;
      currentHeadStatus = HeadStatus.FRESHING;
      _update();
    });
    positonAnimationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        widget.refrshCallback().whenComplete(() {
          currentHeadStatus = HeadStatus.REFRESH_COMPLETE;
          _realseEnd();
        });
      }
    });

    controller.addListener(() {
      //总长  减去  当时的长度  35 是loadmore 的高度
      var offset =
          controller.position.maxScrollExtent - controller.position.pixels;


      if (offset >= 0 && offset <= 35) {
        if (widget.loadMoreCallback != null && !isLoadingMore && widget.hasMoreData) {
           isLoadingMore = true ;
          widget.loadMoreCallback().whenComplete(() {
            setState(() {
              isLoadingMore = false;
            });
          });
        }
      }
    });
    super.initState();
  }
  bool isLoadingMore=false;

  ScrollController controller = ScrollController();
  ScrollPhysics physics = const RefreshAlwaysScrollPhysics();

  AnimationController positonAnimationController;
  Animation<double> positonAnimation;

  AnimationController endAnimationController;
  Animation<double> endAnimation;

  GlobalKey<CustomHeadState> headGlobalKey = new GlobalKey();
  CustomHead customHead;

  @override
  void dispose() {
    positonAnimationController.dispose();
    endAnimationController.dispose();

    super.dispose();
  }

  GlobalKey<State> _listViewKey = new GlobalKey();
//  _listViewUpdate(){
//    if(_listViewKey.currentState!=null){
//
//      _listViewKey.currentState.setState((){});
//    }
//  }

  changeData(int itemCount){
    widget.itemCount=itemCount;
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    if (customHead == null) {
      customHead = CustomHead(
        child: widget.headWidget,
        currentHeight: currentHeight,
        key: headGlobalKey,
      );
    } else {
      customHead.updateHeight(
          height: currentHeight, headStatus: currentHeadStatus);
    }

    ListView listView = ListView.builder(
        key: _listViewKey,
        physics: physics,
        itemCount: widget.itemCount + 2,
        controller: controller,
        itemBuilder: (buildContext, index) {
          if (index == 0) {
            return customHead;
          }
          //最后一个
          if (index == (widget.itemCount + 1)) {
            if (index == 1) {
              return Container();
            }
            return buildLoadMore();
          }

          return widget.swrapInsideWidget(buildContext, index - 1);
        });
    return RefreshDataWidget(
      normalHeight: normalHeight,
      minHeight: minHeight,
      child: Listener(
        onPointerMove: (event) {
          if (endAnimationController.isAnimating ||
              positonAnimationController.isAnimating ||
              currentHeight == normalHeight) {
            return;
          }
          if (currentHeight > minHeight &&
              physics == const NeverScrollableScrollPhysics()) {
            currentHeight = currentHeight + event.delta.dy / 3;
            _update();
            _changeStatus();
          }
          if (currentHeight == minHeight) {
            _updateAlwaysScrollable();
          }
        },
        onPointerUp: (event) {
          _realseLoading();
        },
        onPointerCancel: (event) {
          _realseLoading();
        },
        child: NotificationListener<Notification>(
          onNotification: _handNotifications,
          child: ScrollConfiguration(
            behavior: MyBehavior(false, false, Colors.white),
            child: listView,
          ),
        ),
      ),
    );
  }

  _changeStatus() {
    if (currentHeight >= normalHeight) {
      currentHeadStatus = HeadStatus.RELEASE_REFESH;
    } else {
      currentHeadStatus = HeadStatus.PULL_REFRESH;
    }
  }

  _realseLoading() {
    if (positonAnimationController.isAnimating) {
      return;
    }
    if (currentHeight > normalHeight) {
      positonAnimation = Tween(end: normalHeight, begin: currentHeight)
          .animate(positonAnimationController);

      positonAnimationController.reset();
      positonAnimationController.forward();
    } else {
      _realseEnd();
    }
  }

  _realseEnd() {
    if (currentHeight < 10) {
      currentHeight = minHeight;
      currentHeadStatus = HeadStatus.IDLE;
      _update();
      _updateAlwaysScrollable();
      return;
    }
    if (currentHeight == minHeight || endAnimationController.isAnimating)
      return;

    endAnimation = null;
    endAnimation = Tween(end: minHeight, begin: currentHeight)
        .animate(endAnimationController);
    endAnimationController.reset();
    endAnimationController.forward();
  }

  bool _handNotifications(notification) {
    if (endAnimationController.isAnimating ||
        positonAnimationController.isAnimating ||
        currentHeight == normalHeight) {
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      if (notification.dragDetails == null) return false;
      if (currentHeight > minHeight) {
        _updateNeverScrollable();
        currentHeight = currentHeight + notification.dragDetails.delta.dy / 3;
        _update();
        _changeStatus();
      } else {
        _updateAlwaysScrollable();
      }
    } else if (notification is OverscrollNotification) {
      if (notification.dragDetails == null) return false;
      currentHeight = currentHeight + notification.dragDetails.delta.dy / 3;
      _update();
      _changeStatus();
    } else if (notification is ScrollEndNotification) {
//          currentHeight = minHeight;
//          _update();
    } else if (notification is ScrollStartNotification) {
//          currentHeight = minHeight;
    } else {
    }
  }

  HeadStatus currentHeadStatus;

  _update() {
    if (currentHeight <= minHeight) {
      currentHeight = minHeight;
      if (endAnimationController.isAnimating) {
        endAnimationController.stop();
      }
    }

    customHead.updateHeight(
        height: currentHeight, headStatus: currentHeadStatus);
    if (headGlobalKey != null && headGlobalKey.currentState != null) {
      headGlobalKey.currentState.setState(() {});
    }


  }

  _updateAlwaysScrollable() {
    if (physics != const RefreshAlwaysScrollPhysics()) {
      physics = const RefreshAlwaysScrollPhysics();
      setState(() {});
    }
  }

  _updateNeverScrollable() {
    if (physics != const NeverScrollableScrollPhysics()) {
      physics = const NeverScrollableScrollPhysics();
      setState(() {});
    }
  }

  Widget buildLoadMore() {
    if (widget.footerWidget != null) {
      return widget.footerWidget(widget.hasMoreData ? "加载中..." : "暂无更多数据");
    }
    return Container(
      height: 35,
      margin: EdgeInsets.all(10),
      child: Align(
          alignment: Alignment.center,
          child: widget.hasMoreData
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "加载中...",
                      style: TextStyle(fontSize: 15, color: Color(0Xff222222)),
                    )
                  ],
                )
              : Text(
                  "暂无更多数据",
                  style: TextStyle(color: Color(0xff999999)),
                )),
    );
  }
}

///可去掉过度滑动时ListView顶部的蓝色光晕效果
class MyBehavior extends ScrollBehavior {
  final bool isShowLeadingGlow;
  final bool isShowTrailingGlow;
  final Color _kDefaultGlowColor;

  MyBehavior(
      this.isShowLeadingGlow, this.isShowTrailingGlow, this._kDefaultGlowColor);

  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    //如果头部或底部有一个 不需要 显示光晕时 返回GlowingOverscrollIndicator
    if (!isShowLeadingGlow || !isShowTrailingGlow) {
      return new GlowingOverscrollIndicator(
        showLeading: isShowLeadingGlow,
        showTrailing: isShowTrailingGlow,
        child: child,
        axisDirection: axisDirection,
        color: _kDefaultGlowColor,
      );
    } else {
      //都需要光晕时  返回系统默认
      return super.buildViewportChrome(context, child, axisDirection);
    }
  }
}

///切记 继承ScrollPhysics  必须重写applyTo，，在NeverScrollableScrollPhysics类里面复制就可以
///此类用来控制IOS过度滑动出现弹簧效果
class RefreshAlwaysScrollPhysics extends AlwaysScrollableScrollPhysics {
  const RefreshAlwaysScrollPhysics({ScrollPhysics parent})
      : super(parent: parent);

  @override
  RefreshAlwaysScrollPhysics applyTo(ScrollPhysics ancestor) {
    return new RefreshAlwaysScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return true;
  }

  ///防止ios设备上出现弹簧效果
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    assert(() {
      if (value == position.pixels) {
        throw FlutterError(
            '$runtimeType.applyBoundaryConditions() was called redundantly.\n'
            'The proposed new position, $value, is exactly equal to the current position of the '
            'given ${position.runtimeType}, ${position.pixels}.\n'
            'The applyBoundaryConditions method should only be called when the value is '
            'going to actually change the pixels, otherwise it is redundant.\n'
            'The physics object in question was:\n'
            '  $this\n'
            'The position object in question was:\n'
            '  $position\n');
      }
      return true;
    }());
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) // underscroll
      return value - position.pixels;
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) // overscroll
      return value - position.pixels;
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) // hit top edge
      return value - position.minScrollExtent;
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) // hit bottom edge
      return value - position.maxScrollExtent;
    return 0.0;
  }

  ///防止ios设备出现卡顿
  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (position.outOfRange) {
      double end;
      if (position.pixels > position.maxScrollExtent)
        end = position.maxScrollExtent;
      if (position.pixels < position.minScrollExtent)
        end = position.minScrollExtent;
      assert(end != null);
      return ScrollSpringSimulation(spring, position.pixels,
          position.maxScrollExtent, math.min(0.0, velocity),
          tolerance: tolerance);
    }
    if (velocity.abs() < tolerance.velocity) return null;
    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent)
      return null;
    if (velocity < 0.0 && position.pixels <= position.minScrollExtent)
      return null;
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      tolerance: tolerance,
    );
  }
}
