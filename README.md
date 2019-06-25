# flutter_refresh_loadmore

A refresh loadmore listview package.

## Getting Started
Installing
flutter_refresh_loadmore: ^0.0.9

Import
import 'package:flutter_refresh_loadmore/flutter_refresh_loadmore.dart';


How To Use

 ```dart
     bool hasLoadMore=true;

   //模拟刷新
   Future _refresh() async{
     await Future.delayed(Duration(milliseconds: 1000),(){
       length=15;
       hasLoadMore=true;
     });
     _globalKey.currentState.updateUi(length, hasLoadMore);

   }
   //模拟加载更多
   Future _loadmore() async {
       await Future.delayed(Duration(milliseconds: 1000),(){
         //模拟 没有更多数据
         if(length>=30){
           hasLoadMore=false;
         }else{
           //正常加载
           length=length+5;
         }

       });
       _globalKey.currentState.updateUi(length, hasLoadMore);
   }

   int length=15;
   GlobalKey<RefreshLoadMoreState> _globalKey=new GlobalKey();
   @override
   Widget build(BuildContext context) {
     return Scaffold(

       appBar: AppBar(
         centerTitle: true,
         title: Text("test"),
       ),
       body: Center(
         child: RefreshLoadMoreWidget(

           key: _globalKey,
           //必传
           swrapInsideWidget: (context, index) {
             return Container(
               alignment: Alignment.center,
               margin: EdgeInsets.only(top: 10),
               color: Colors.deepOrange,
               child: Text("$index"),
               width: 100,
               height: 50,
             );
           },
           //必传 加载更多是否还有数据
           hasMoreData: hasLoadMore,

           //不传 默认没有上拉刷新功能 必须有async  await
           refrshCallback: () async {
            await _refresh();
           },
           //必传
           itemCount: length,

           //不传 默认没有加载更多功能     必须有async  await
           loadMoreCallback: () async {
             await _loadmore();
           },
 //          //不传有默认的  自定义自己的footer  str  值有两个  加载中...  和 暂无更多数据
 //          swrapFooterWidget:(str){
 //           return Center(
 //             child: Text(str),
 //           );
 //          } ,
 //          //不传有默认的 自定义自己的head  statu  值有4个  正加载中     加载完成 下拉刷新  松开刷新
 //          swrapHeadWidget: (statu){
 //            return SpinKitFadingCircle(color: Colors.black38,size: 30,);
 //          },

         ),
       ),
     );
   }
 ```


下拉默认刷新效果
https://github.com/liuwangle/flutter_refresh_loadmore/blob/master/demon_gif/refresh.gif



加载默认更多效果
https://github.com/liuwangle/flutter_refresh_loadmore/blob/master/demon_gif/loadmore.gif