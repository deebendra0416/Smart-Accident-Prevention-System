import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vechicle_tracking/device/api/auth.dart';

class MapsReceiver extends StatefulWidget {
  final String deviceid;
  MapsReceiver({Key key, @required this.deviceid}) : super(key: key);
  @override
  State createState() => MapsReceiverState();
}

class MapsReceiverState extends State<MapsReceiver> {
  static final databaseReference = FirebaseDatabase.instance.reference();

  static double currentLatitude;
  static double currentLongitude;
  static double checkLatitude;
  static double checkLongitude;
  static double toLatitude;
  static double toLongitude;
  static String name = '';
  static String carry = '';
  static String type = '';
  static String phone = '';

  LatLng pinPosition;
  double pinPillPosition = -100;
  static GoogleMapController mapController;
  BitmapDescriptor pinLocationIcon1;
  BitmapDescriptor pinLocationIcon2;
  BitmapDescriptor pinLocationIcon3;
  StreamSubscription subscription;

  Map<String, double> currentLocation = new Map();

  StreamSubscription<Map<String, double>> locationSubcription;
  Set<Marker> _markers = {};

  Location location = new Location();
  String error;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    setCustomMapPin1();
    setCustomMapPin2();
    setCustomMapPin3();
    subscription = FirebaseDatabase.instance
        .reference()
        .child(widget.deviceid)
        .onValue
        .listen((event) {
      setState(() {
        checkLatitude = event.snapshot.value['checklatitude'];
        checkLongitude = event.snapshot.value['checklongitude'];
        toLatitude = event.snapshot.value['tolatitude'];
        toLongitude = event.snapshot.value['tolongitude'];
        currentLatitude = event.snapshot.value['latitude'];
        currentLongitude = event.snapshot.value['longitude'];
        carry = event.snapshot.value['carry'];
        name = event.snapshot.value['name'];
        type = event.snapshot.value['type'];
        phone = event.snapshot.value['number'];
        _markers.add(Marker(
          markerId: MarkerId('1'),
          icon: pinLocationIcon1,
          infoWindow: InfoWindow(
            title: "CARRYING :\t" + carry.toUpperCase(),
            snippet: "VECHICLE NAME :\t" + type.toUpperCase(),
          ),
          position: LatLng(currentLatitude, currentLongitude),
        ));
        _markers.add(Marker(
          markerId: MarkerId('2'),
          icon: pinLocationIcon2,
          position: LatLng(checkLatitude, checkLongitude),
        ));
        _markers.add(Marker(
          markerId: MarkerId('3'),
          icon: pinLocationIcon3,
          position: LatLng(toLatitude, toLongitude),
        ));
      });
      try {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(event.snapshot.value['latitude'],
                    event.snapshot.value['longitude']),
                zoom: 17),
          ),
        );
      } catch (e) {
        print(e);
      }
    });
  }

  void setCustomMapPin3() async {
    pinLocationIcon3 = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }

  void setCustomMapPin2() async {
    pinLocationIcon2 = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/check.png');
  }

  void setCustomMapPin1() async {
    pinLocationIcon1 = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    if ((currentLatitude != null) & (currentLongitude != null)) {
      pinPosition = LatLng(currentLatitude, currentLongitude);
      CameraPosition initialLocation =
          CameraPosition(zoom: 16, bearing: 30, target: pinPosition);

      return Scaffold(
        body: Stack(children: [
          GoogleMap(
              markers: _markers,
              initialCameraPosition: initialLocation,
              onMapCreated: _onMapCreated),
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.78,
              ),
              Container(
                margin: EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height / 9.6,
                decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.all(Radius.circular(90)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          blurRadius: 20,
                          offset: Offset.zero,
                          color: Colors.black.withOpacity(0.5))
                    ]),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(left: 20),
                          width: 50,
                          height: 70,

// this Container’s child will be a ClipOval,
// which in turn contains an Image as a child.
// A ClipOval is used so it can crop
// the image into a circle
                          child: ClipOval(
                              child: Icon(
                            Icons.person,
                            size: 45,
                            color: Colors.grey,
                          ))), // first widget
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("NAME :\t" + name.toUpperCase(),
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            Text("MOBILE :\t" + phone,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold)),
                            // Text("CARRYING :\t" + carry.toUpperCase(),
                            //     style: TextStyle(
                            //         fontSize: 15,
                            //         color: Colors.black87,
                            //         fontWeight: FontWeight.bold)),
                            // Text("VECHICLE NAME :\t" + type.toUpperCase(),
                            //     style: TextStyle(
                            //         fontSize: 15,
                            //         color: Colors.black87,
                            //         fontWeight: FontWeight.bold))
                          ], // end of Column Widgets
                        ), // end of Column
                      )), // second widget
                    ]),
              ),
            ],
          )
        ]),
      );
    } else {
      return Center(
          child: Center(child: Container(child: CircularProgressIndicator())));
    }
  }
}
