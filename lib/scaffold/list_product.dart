import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nottptn/models/product_all_model.dart';
import 'package:nottptn/utility/my_style.dart';

import 'detail.dart';

class ListProduct extends StatefulWidget {
  final int index;
  ListProduct({Key key, this.index}) : super(key: key);

  @override
  _ListProductState createState() => _ListProductState();
}

//class
class Debouncer {
  // delay เวลาให้มีการหน่วง เมื่อ key searchview

  //Explicit
  final int milliseconds;
  VoidCallback action;
  Timer timer;

  //constructor
  Debouncer({this.milliseconds});
  run(VoidCallback action) {
    if (timer != null) {
      timer.cancel();
    }
    timer = Timer(Duration(microseconds: milliseconds), action);
  }
}

class _ListProductState extends State<ListProduct> {
  // Explicit
  int myIndex;
  List<ProductAllModel> productAllModels = List(); // set array
  List<ProductAllModel> filterProductAllModels = List();

  int amountListView = 6;
  ScrollController scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 500); // ตั้งค่า เวลาที่จะ delay
  bool statusStart = true;

  // Method
  @override
  void initState() {
    // auto load
    super.initState();
    myIndex = widget.index;

    readData(); // read  ข้อมูลมาแสดง

    createController(); // เมื่อ scroll to bottom
  }

  void createController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        print('in the end');

        setState(() {
          amountListView = amountListView + 2;
          if (amountListView > filterProductAllModels.length) {
            amountListView = filterProductAllModels.length;
          }
        });
      }
    });
  }

  Future<void> readData() async {
    String url = MyStyle().readAllProduct;
    if (myIndex != 0) {
      url = '${MyStyle().readProductWhereMode}$myIndex';
    }

    Response response = await get(url);
    var result = json.decode(response.body);
    print('result = $result');

    var itemProducts = result['itemsProduct'];

    for (var map in itemProducts) {
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);
      setState(() {
        productAllModels.add(productAllModel);
        filterProductAllModels = productAllModels;
      });
    }
  }

  Widget showName(int index) {
    return Text(filterProductAllModels[index].title);
  }

  Widget showStock(int index) {
    return Text(filterProductAllModels[index].stock);
  }

  Widget showText(int index) {
    return Container(
      height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[showName(index), showStock(index)],
      ),
    );
  }

  Widget showImage(int index) {
    return Container(
      padding: EdgeInsets.all(5.0),
      width: MediaQuery.of(context).size.width * 0.4,
      child: Image.network(filterProductAllModels[index].photo),
    );
  }

  Widget showProductItem() {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: amountListView,
        itemBuilder: (BuildContext buildContext, int index) {
          return GestureDetector(
            child: Row(
              children: <Widget>[
                showImage(index),
                showText(index),
              ],
            ),
            onTap: () {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return Detail(productAllModel: filterProductAllModels[index],);
              });
              Navigator.of(context).push(materialPageRoute);
            },
          );
        },
      ),
    );
  }

  Widget showProgressIndicate() {
    return Center(
      child:
          statusStart ? CircularProgressIndicator() : Text('Search not found'),
    );
  }

  /*
  Widget myLayout() {
    return Column(
      children: <Widget>[
        searchForm(),
        showProductItem(),
      ],
    );
  }
  */

  Widget searchForm() {
    return Container(
      // color: Colors.grey,
      padding:
          EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0, bottom: 20.0),
      child: TextField(
        decoration: InputDecoration(hintText: 'Search'),
        onChanged: (String string) {
          statusStart = false;
          debouncer.run(() {
            setState(() {
              filterProductAllModels =
                  productAllModels.where((ProductAllModel productAllModel) {
                return (productAllModel.title
                    .toLowerCase()
                    .contains(string.toLowerCase()));
              }).toList();
              amountListView = filterProductAllModels.length;
            });
          });
        },
      ),
    );
  }

  Widget showContent() {
    return filterProductAllModels.length == 0
        ? showProgressIndicate()
        : showProductItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List product'),
      ),
      // body: filterProductAllModels.length == 0
      //     ? showProgressIndicate()
      //     : myLayout(),

      body: Column(
        children: <Widget>[
          searchForm(),
          showContent(),
        ],
      ),
    );
  }
}
