import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRForm extends StatefulWidget {
  @override
  QRFormState createState() {
    return QRFormState();
  }
}

// Form containing the QR scanner widget, handling the data after a
// QR code is successfully scanned.

class QRFormState extends State<QRForm> {
  String serverBaseURL =
      "http://192.168.0.45:8080/"; //TODO: change this to actual base url
  String infoText = "Please scan a course QR code to get started";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(body: Builder(builder: (BuildContext context) {
      return Container(
          alignment: Alignment.center,
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                  onPressed: () => scanQR(), child: Text('Start QR scan')),
              Text("$infoText", style: new TextStyle(
                fontSize: 20
              ),),
            ],
          ));
    })), debugShowCheckedModeBanner: false);
  }

  // Method that scans the code
  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    validateData(barcodeScanRes);
  }

  // validate the QR value we scanned, decide wether we send or not
  void validateData(String _data) async {
    String data = _data;
    // Regexp designed to check if our scanned code is
    // in following format : CVUFR!xxxxx?xxxxxx, where x are digits.
    // read them as CVUFR!{courseID}?{YYMMDD}
    RegExp regExp = new RegExp(r"^CVUFR!\d\d\d\d\d\?\d\d\d\d\d\d$");

    if (regExp.hasMatch(data)) {
      int courseID = int.parse(data.substring(6, 11));
      int date = int.parse(data.substring(12));

      setState(() {
        infoText = "QR code accepted. Fetching profile data.";
      });

      beamMeUpScotty(courseID.toString(), date);
    } else {
      setState(() {
        infoText = "Invalid QR code. Please try again.";
      });
    }
  }

  // Attempt to fetch profile data, then beam up that data
  void beamMeUpScotty(String courseID, int _date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      // Check if form is filled in persistent storage
      bool isFormFilled = prefs.getBool("isFormFilled") ?? false;

      if (isFormFilled) {
        // if it is, attempt to send data
        setState(() {
          infoText = "Sending your data...";
        });

        // Prepare the data

        String firstName = prefs.getString("firstName") ?? "";
        String lastName = prefs.getString("lastName") ?? "";
        String email = prefs.getString("email") ?? "";
        String studentCardNumber = prefs.getString("studentCardNumber") ?? "";

        // Remove the dashes that many people write into the card number
        studentCardNumber = studentCardNumber.replaceAll("-", "");
        // Reformat date
        String date = _date.toString();
        date = "20" + date.substring(0,2) + "-" + date.substring(2,4) + "-" + date.substring(4,6);

        Uri scottyURL = Uri.parse(serverBaseURL + "qrcodeinterface");

        // Attempt POST. If this fails, the outer catch will show the error
        // in the text information label.
        final response = await http.post(scottyURL, body: {
          "fn": firstName,
          "ln": lastName,
          "em": email,
          "sn": studentCardNumber,
          "ci": courseID,
          "dt": date,
        });

        if(response.statusCode == 200){ // Status code : OK
          setState(() {
          infoText = "Data sent! Have a good course.";
          });
        } else {
          setState(() {
            infoText = response.statusCode.toString();//"Error saving the data on the server. Please check your profile and try again.";
          });
        }

        
      } else {
        setState(() {
          infoText = "Error loading profile." +
              "Please save a profile in the second tab first";
        });
      }
    } catch (e) {
      setState(() {
        infoText = "Error : " + e.toString();
      });
    }
  }
}
