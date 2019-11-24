import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nottptn/models/product_all_model.dart';

class ListProduct extends StatefulWidget {
  final int index;
  ListProduct({Key key, this.index}) : super(key: key);

  @override
  _ListProductState createState() => _ListProductState();
}

class _ListProductState extends State<ListProduct> {
  // Explicit
  int myIndex;
  List<ProductAllModel> productAllModels = List(); // set array
  int amountListView = 6;
  ScrollController scrollController = ScrollController();

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
          if (amountListView > productAllModels.length) {
            amountListView = productAllModels.length;
          }
        });
      }
    });
  }

  Future<void> readData() async {
    String url = 'http://ptnpharma.com/app/json_allproduct.php';
    if (myIndex != 0) {
      url =
          'http://ptnpharma.com/app/json_allproduct.php?product_mode=$myIndex';
    }

    Response response = await get(url);
    var result = json.decode(response.body);
    print('result = $result');

    var itemProducts = result['itemsProduct'];

    for (var map in itemProducts) {
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);
      setState(() {
        productAllModels.add(productAllModel);
      });
    }
  }

  Widget showName(int index) {
    return Text(productAllModels[index].title);
  }

  Widget showStock(int index) {
    return Text(productAllModels[index].stock);
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
      child: Image.network(productAllModels[index].photo),
    );
  }

  Widget showProductItem() {
    return Expanded(
          child: ListView.builder(
        controller: scrollController,
        itemCount: amountListView,
        itemBuilder: (BuildContext buildContext, int index) {
          return Row(
            children: <Widget>[
              showImage(index),
              showText(index),
            ],
          );
        },
      ),
    );
  }

  Widget showProgressIndicate() {
    return Center(child: CircularProgressIndicator());
  }

  Widget myLayout() {
    return Column(
      children: <Widget>[searchForm(),showProductItem(),],
    );
  }

  Widget searchForm() {
    return Container(
      margin: EdgeInsets.only(left: 40.0,right: 40.0),
      child: TextField(
        decoration: InputDecoration(hintText: 'Search'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List product'),
      ),
      body: productAllModels.length == 0
          ? showProgressIndicate()
          : myLayout(),
    );
  }
}
