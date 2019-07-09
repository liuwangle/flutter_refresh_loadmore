# flutter_refresh_loadmore

A refresh loadmore listview package.

## Getting Started
Installing
 ```dart
flutter_refresh_loadmore: ^0.1.6
```

Import
 ```dart
import 'package:flutter_refresh_loadmore/flutter_refresh_loadmore.dart';
```

How To Use

 ```dart
    GlobalKey<ListViewRefreshLoadMoreWidgetState> _listViewKey = new GlobalKey();
    bool hasMoreData = true;
  
    Widget getList() {
      return ListViewRefreshLoadMoreWidget(
        key: _listViewKey,
        //listview  count
        itemCount: newsList.length,
  
        //listview 的item widget
        swrapInsideWidget: (buildContex, index) {
          return _widgetRow(index);
        },
        //下拉刷新
        refrshCallback: () async {
          await getNewsList(true, "", getCallbackAndSetData2(true));//获取数据 添加到newsList
          _listViewKey.currentState.changeData(newsList.length);
        },
        //加载更多
        loadMoreCallback: () async {
          await getNewsList(false, newsList.last.time, getCallbackAndSetData2(false)); //获取数据 添加到newsList
          _listViewKey.currentState.changeData(newsList.length,hasMoreData: hasMoreData);
        },
  
        /// 加载更多 用
        hasMoreData: hasMoreData,
  //    ///footer widget 非必须传有默认
  //    footerWidget: (statusStr){
  //      return null;
  //    },
  //    //head widget 非必传有默认
  //    headWidget: (headstate,currentHeight){
  //    return null;
  //    ;
  //    },
      );
    }
 ```


下拉默认刷新效果

![image](https://github.com/liuwangle/flutter_refresh_loadmore/blob/master/demon_gif/refresh.gif)


加载默认更多效果

![image](https://github.com/liuwangle/flutter_refresh_loadmore/blob/master/demon_gif/loadmore.gif)