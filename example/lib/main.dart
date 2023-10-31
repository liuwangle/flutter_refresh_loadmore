import 'package:flutter/material.dart';
import 'package:flutter_refresh_loadmore/flutter_refresh_loadmore.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: const Text("title"),
          ),
          body: const MyExample(),
        ));
  }
}

class MyExample extends StatefulWidget {
  const MyExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyExampleState();
  }
}

class _MyExampleState extends State<MyExample> {
  @override
  void initState() {
    list!.add("a");
    list!.add("a");
    list!.add("a");
    list!.add("a");
    list!.add("a");
    list!.add("a");
    list!.add("a");
    list!.add("a");
    list!.add("a");
    list!.add("a");
    list!.add("a");
    list!.add("a");
    list!.add("a");
    list!.add("a");
    list!.add("a");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getList();
  }

  final GlobalKey<ListViewRefreshLoadMoreWidgetState> _listViewKey =
      GlobalKey();
  bool hasMoreData = true;

  List<String>? list;

  Widget getList() {
    return ListViewRefreshLoadMoreWidget(
      key: _listViewKey,
      //listview  count
      itemCount: list!.length,

      //listview 的item widget
      swrapInsideWidget: (buildContext, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          color: Colors.black38,
          height: 50,
          child: Center(
            child: Text("${list![index]}  $index"),
          ),
        );
      },
      //下拉刷新
      refrshCallback: () async {
        await Future.delayed(const Duration(milliseconds: 1000), () {
          // list =  List();
          list!.add("b");
          list!.add("b");
          list!.add("a");
          list!.add("a");
          list!.add("a");
          list!.add("a");
          list!.add("a");
          list!.add("vvvv");
          list!.add("a");
          list!.add("a");
          list!.add("vvvv");
          list!.add("a");
          list!.add("a");
          list!.add("vvvv");
          list!.add("a");
          list!.add("a");
          list!.add("vvvv");
        }); //获取数据 添加到list
        _listViewKey.currentState!.changeData(list!.length);
      },
      //加载更多
      loadMoreCallback: () async {
        await Future.delayed(const Duration(milliseconds: 1000), () {
          list!.add("a");
          list!.add("a");
          list!.add("a");
          list!.add("a");
          list!.add("a");
          list!.add("a");
          list!.add("a");
          list!.add("a");
          list!.add("a");
          list!.add("a");
          //如果加载完毕 hasMoreData设置为true
        }); //获取数据 添加到list
        _listViewKey.currentState!
            .changeData(list!.length, hasMoreData: hasMoreData);
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
}
