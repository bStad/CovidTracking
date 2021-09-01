import 'package:appli_tb/widgets/QRForm.dart';
import 'package:appli_tb/widgets/StudentForm.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(CVUFR());
}

class CVUFR extends StatelessWidget {
  // Defining the forms we will use in our TabController
  final QRForm qrForm = new QRForm();
  final StudentForm studentForm = new StudentForm();

  // Building the main form of the app, essentially contaning a tabcontroller
  //  with our forms in it
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.qr_code_scanner)),
                Tab(icon: Icon(Icons.account_box)),
              ],
            ),
            title: Text('UniFR Covid-prevention'),
          ),
          body: TabBarView(
            children: [
              qrForm,
              studentForm,
            ],
          ),
        ),
        initialIndex: 0, // Start out on QR tab
      ),
    debugShowCheckedModeBanner: false,);
  }
}
