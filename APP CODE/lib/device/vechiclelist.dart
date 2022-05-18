import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:vechicle_tracking/device/maps/maploc.dart';

class ChooseDevice extends StatefulWidget {
  @override
  State createState() => ChooseDeviceState();
}

class ChooseDeviceState extends State<ChooseDevice> {
  var refreshkey = GlobalKey<RefreshIndicatorState>();

  static final databaseReference = FirebaseDatabase.instance.reference();

  static double currentLatitude = 0.0;
  static double currentLongitude = 0.0;

  StreamSubscription subscription;

  Map<String, double> currentLocation = new Map();
  StreamSubscription<Map<String, double>> locationSubcription;
  String error;

  String deviceid = 'Unknown';

  List<String> list = [];

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    databaseReference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        setState(() {
          list.add(key);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Track'),
          backgroundColor: Colors.blue[800],
        ),
        body: RefreshIndicator(
          key: refreshkey,
          child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MapsReceiver(deviceid: list[index])),
                    );
                  },
                  child: Card(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[400],
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(3, 3),
                            color: Colors.black12,
                            blurRadius: 1,
                          ),
                          BoxShadow(
                            offset: Offset(-3, -3),
                            color: Colors.white,
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(8.0),
                      height: MediaQuery.of(context).size.height / 9,
                      width: MediaQuery.of(context).size.width / 6,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.airport_shuttle,
                                size: 60,
                                color: Colors.black87,
                              ),
                              Text(
                                '\t\t\t\t\tVechicle NO\t: ' + list[index],
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  databaseReference.child(list[index]).remove();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: list.length),
          onRefresh: refreshlist,
        ));
  }

  Future<Null> refreshlist() async {
    refreshkey.currentState?.show(
        atTop:
            true); // change atTop to false to show progress indicator at bottom
    await Future.delayed(Duration(seconds: 2)); //wait here for 2 second
    setState(() {
      list = [];
      databaseReference.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
          setState(() {
            list.add(key);
          });
        });
      });
    });
  }
}
