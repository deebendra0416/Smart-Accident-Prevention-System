import 'package:flutter/material.dart';
import 'package:vechicle_tracking/device/device.dart';
import 'auth/loginScreen.dart';
import 'device/api/auth.dart';

void main() => runApp(Stromloop());

class Stromloop extends StatefulWidget {
  @override
  _StromloopState createState() => _StromloopState();
}

class _StromloopState extends State<Stromloop> {
  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future getUserInfo() async {
    await getUser();
    setState(() {});
    // print(uid);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stromloop',
      home:
          (uid != null && authSignedIn != false) ? ChooseDevice() : LoginPage(),
    );
  }
}
