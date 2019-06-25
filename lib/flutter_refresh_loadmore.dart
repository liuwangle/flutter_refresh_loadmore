import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

import 'rotate_widget.dart';
import 'refresh_head.dart';

typedef SwrapInsideWidget = Widget Function(BuildContext context, int index);

typedef RefrshCallback = Future Function();
typedef LoadMoreCallback = Future<void> Function();

class RefreshLoadMoreWidget extends StatefulWidget {
  //listview 的item  widget
  SwrapInsideWidget swrapInsideWidget;

  //headviw
  SwrapHeadWidget swrapHeadWidget;

  //刷新的回调  不传或者 传null  则关闭刷新
  RefrshCallback refrshCallback;

  //加载更多回调  不传或者 传null  则关闭加载更多
  LoadMoreCallback loadMoreCallback;
  bool hasMoreData = true;
  int itemCount;
  SwrapFooterWidget swrapFooterWidget;

  RefreshLoadMoreWidget(
      {Key key,
        @required this.swrapInsideWidget,
        this.refrshCallback,
        this.loadMoreCallback,
        this.swrapHeadWidget,
        this.swrapFooterWidget,
        @required this.hasMoreData,
        @required this.itemCount}):super(key:key);

  @override
  State<StatefulWidget> createState() {
    return RefreshLoadMoreState();
  }
}

class RefreshLoadMoreState extends State<RefreshLoadMoreWidget> {
  ScrollController controller = ScrollController();

  /**
   * realse  动画
   */
  AnimationController _positionController;

  @override
  void dispose() {
    if (_positionController != null) {
      _positionController.dispose();
    }

    super.dispose();
  }

  updateUi(int itemCount,bool hasMoredata){
    widget.itemCount=itemCount;
    widget.hasMoreData=hasMoredata;
    setState(() {

    });
  }

  //是否正在加载更多
  bool isLoadingMore = false;

  //刷新widget 高度
  double headHeight = 60;

  @override
  void initState() {
    controller.addListener(() {
      //总长  减去  当时的长度  35 是loadmore 的高度
      var offset =
          controller.position.maxScrollExtent - controller.position.pixels;

//      if (offset >= 0 &&
//          offset <= 35 &&
//          !isLoadingMore &&
//          widget.loadMoreCallback() != null &&
//          widget.hasMoreData) {
//        setState(() {
//          isLoadingMore = true;
//        });
//        widget.loadMoreCallback().whenComplete(() {
//          setState(() {
//            isLoadingMore = false;
//          });
//        });
//      }
    });
    WidgetsBinding widgetsBinding = WidgetsBinding.instance;
    //第一帧 绘制完毕
    widgetsBinding.addPostFrameCallback((callback) {});
    super.initState();
  }

  bool isRefreshing=false;

  //回调刷新  然后继续执行动画
  _refresh() async {
    if(isRefreshing){
      return;
    }
    isRefreshing=true;

    widget.refrshCallback().whenComplete(() {
      isRefreshing=false;
      _odelta = headHeight;
      _isLoadingHead = false;
      _positionController.value = 0;
      _positionController.duration = Duration(milliseconds: 300);
      _positionController.forward();
    });
  }

  static double _odelta = 0;

  bool _handleScrollNotification(ScrollNotification notification) {
    if(isRefreshing){
      return true;
    }
    //listview 列表滑动
    if (notification is ScrollUpdateNotification) {}
    //listview  滑动到尽头 继续滑动
    if (notification is OverscrollNotification) {
      if (!_positionController.isAnimating) {
        _odelta -= notification.overscroll / 2;
        if (notification.metrics.pixels == 0) {
          if (headKey.currentState != null) {

            //head 高度变化
            headKey.currentState.setState(() {});
          }
        }
      }
    }
    //end 滑动结束
    if (notification is ScrollEndNotification) {}

    //滑动状态改变
    if (notification is UserScrollNotification) {
      //滑动空闲状态 或者 方向状态 执行动画（手指抬起 或者 反向）
      if ((notification.direction == ScrollDirection.idle && _odelta > 0) ||
          (notification.direction == ScrollDirection.reverse &&
              notification.metrics.pixels == 0 &&
              _odelta > 0)) {
        _isUseAnimationValue = true;

        if (_odelta > headHeight) {
          _isLoadingHead = true;
        } else {
          _isLoadingHead = false;
        }

        if (_positionController.isAnimating) {
          _odelta = _odelta * _positionController.value;
          _positionController.stop(canceled: true);
        } else {
          _positionController.value = 0;
        }

        _positionController.duration = Duration(milliseconds: 400);
        _positionController.forward();
      }
    }

    //如果headview 显示   listview 不可滑动
    if (_odelta > 0) {
      if (_scrollPhysics != const RefreshScrollPhysics()) {
        _scrollPhysics = const RefreshScrollPhysics();
        setState(() {});
      }
    } else {
      if (_scrollPhysics != const RefreshAlwaysScrollPhysics()) {
        _scrollPhysics = const RefreshAlwaysScrollPhysics();
        setState(() {});
      }
      ;
    }
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    return true;
  }

  //headwidget 是否正在加载中
  static bool _isLoadingHead = false;

  //head view  的高度是否 用 动画的值
  bool _isUseAnimationValue = false;

  //获取head widget  高度
  double _getHeight() {
    //正在执行动画的时候 head widget的高度
    if (_isUseAnimationValue) {
      double h = (1 - _positionController.value) * _odelta;
      if (_isLoadingHead) {
        h = (1 - _positionController.value) * (_odelta - headHeight) +
            headHeight;
      } else {
        h = (1 - _positionController.value) * _odelta;
      }

      return h;
    }
    if (_odelta < 0) {
      return 0;
    }
    return _odelta;
  }

  Widget buildLoadMore() {

    if(widget.swrapFooterWidget!=null){
      return widget.swrapFooterWidget(widget.hasMoreData?"加载中...":"暂无更多数据");
    }
    return Padding(
      padding: EdgeInsets.all(10),
      child: Align(
          alignment: Alignment.center,
          child: widget.hasMoreData
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RotateWidget(
                isStartAnimation: true,
              ),
              SizedBox(
                width: 15,
              ),
              Text(
                "加载中...",
                style: TextStyle(fontSize: 18, color: Color(0Xff222222)),
              )
            ],
          )
              : Text(
            "暂无更多数据",
            style: TextStyle(color: Color(0xff999999)),
          )),
    );
  }

  //listview  控制是否可滑动
  ScrollPhysics _scrollPhysics = const RefreshAlwaysScrollPhysics();

  //Headwidget
  DefaultHead defaultHead;
  GlobalKey<State> listKey = new GlobalKey();
  GlobalKey<State> notifKey = new GlobalKey();

  GlobalKey<State> headKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    defaultHead = DefaultHead(
      key: headKey,
      heightsCallBack: _getHeight,
      getAnimationController: (controller) {
        _positionController = controller;
      },
      oneceAnimationComplete: () {
        _odelta = headHeight;
        _refresh();
      },
      headAnimationComplete: () {
        //最后的动画
        _odelta = 0;
        _isUseAnimationValue = false;
        _scrollPhysics = const RefreshAlwaysScrollPhysics();
        setState(() {});
      },
      normalHeight: headHeight,
      swrapHeadWidget: widget.swrapHeadWidget,
    );

    ListView mylistview = ListView.builder(
      physics: _scrollPhysics,
//      padding: const EdgeInsets.all(8.0),
      controller: controller,
      itemCount: widget.loadMoreCallback == null
          ? widget.itemCount
          : widget.itemCount + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == (widget.itemCount) && widget.loadMoreCallback != null) {
          if ((!isLoadingMore )&&(widget.loadMoreCallback != null )&&(widget.hasMoreData)) {
            isLoadingMore = true;
            widget.loadMoreCallback().whenComplete(() {
              isLoadingMore = false;
            });
          }

          return buildLoadMore();
        }
        return widget.swrapInsideWidget(context, index);
      },
    );
    Widget mynotification = NotificationListener<ScrollNotification>(
        key: notifKey,
        onNotification: _handleScrollNotification,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: _handleGlowNotification,
          child: ScrollConfiguration(
            behavior: MyBehavior(false, false, Colors.red),
            child: mylistview,
          ),
        ));

    return Column(
      children: <Widget>[
        widget.refrshCallback == null ? Container() : defaultHead,
        new Expanded(
          child: mynotification,
          flex: 1,
        )
      ],
    );
  }
}

///切记 继承ScrollPhysics  必须重写applyTo，，在NeverScrollableScrollPhysics类里面复制就可以
///出现反向滑动时用此ScrollPhysics
class RefreshScrollPhysics extends ScrollPhysics {
  const RefreshScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  RefreshScrollPhysics applyTo(ScrollPhysics ancestor) {
    return new RefreshScrollPhysics(parent: buildParent(ancestor));
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

  //重写这个方法为了减缓ListView滑动速度
  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (offset < 0.0) {
      return 0.00000000000001;
    }
    if (offset == 0.0) {
      return 0.0;
    }
    return offset / 2;
  }

  //此处返回null时为了取消惯性滑动
  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    return null;
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
