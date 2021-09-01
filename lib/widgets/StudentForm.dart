import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentForm extends StatefulWidget {
  @override
  StudentFormState createState() {
    return StudentFormState();
  }

  Future<bool> isFormFilled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isFormFilled") ?? false;
  }
}

class StudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();
  final model =
      FormModel(firstName: "", lastName: "", email: "", studentCardNumber: "");

  // Controllers to allow filling in the loaded values after
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final cardNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => tryLoadFields());
  }

  // Method that shows the confirmation dialog
  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Your profile was saved successfully.'),
                Text('You can now scan course QR codes.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Profile'),
        ),
        body: new Container(
            padding: new EdgeInsets.all(20.0),
            child: new Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    // Here we define all text fields with their
                    // validators and associated labels and hints
                    new TextFormField(
                        onSaved: (value) {
                          model.firstName = value!;
                        },
                        controller: firstNameController,
                        keyboardType: TextInputType.name,
                        decoration: new InputDecoration(
                            hintText: 'Your First Name',
                            labelText: 'First Name'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your first name.';
                          }
                          return null;
                        }),
                    new TextFormField(
                        onSaved: (value) {
                          model.lastName = value!;
                        },
                        controller: lastNameController,
                        keyboardType: TextInputType.name,
                        decoration: new InputDecoration(
                            hintText: 'Your Last Name', labelText: 'Last Name'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your last name.';
                          }
                          return null;
                        }),
                    new TextFormField(
                        onSaved: (value) {
                          model.email = value!;
                        },
                        controller: emailController,
                        keyboardType: TextInputType
                            .emailAddress, // Use email input type for emails.
                        decoration: new InputDecoration(
                            hintText: 'you@unifr.ch',
                            labelText: 'E-mail Address'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'A valid E-mail address is required!';
                          }
                          return null;
                        }),
                    new TextFormField(
                        onSaved: (value) {
                          model.studentCardNumber = value!;
                        },
                        controller: cardNumberController,
                        keyboardType: TextInputType.number,
                        decoration: new InputDecoration(
                            hintText: 'xx-xxx-xxx',
                            labelText: 'Student Number on your card'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'A student card number is required!';
                          }
                          return null;
                        }),
                    new ElevatedButton(
                        onPressed: trySaveForm,
                        child: new Text("Save my profile")),
                  ],
                ))));
  }

  // Attempt loading the form data from peristent storage
  Future<void> tryLoadFields() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String? fieldValue = "";

      fieldValue = prefs.getString("firstName");
      firstNameController.text = fieldValue ??= "";
      model.firstName = fieldValue;

      fieldValue = prefs.getString("lastName");
      lastNameController.text = fieldValue ??= "";
      model.lastName = fieldValue;

      fieldValue = prefs.getString("email");
      emailController.text = fieldValue ??= "";
      model.email = fieldValue;

      fieldValue = prefs.getString("studentCardNumber");
      cardNumberController.text = fieldValue ??= "";
      model.studentCardNumber = fieldValue;
    } catch (e) {
      debugPrint("Error : " + e.toString());
    }
  }

  // Attempt saving the form data into the persistent storage
  Future<void> trySaveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        prefs.setBool("isFormFilled", true);
        prefs.setString("firstName", model.firstName);
        prefs.setString("lastName", model.lastName);
        prefs.setString("email", model.email);
        prefs.setString("studentCardNumber", model.studentCardNumber);
        
        _showSuccessDialog();

      } catch (e) {
        debugPrint("Error : " + e.toString());
      }
    } else {
      AlertDialog(content: Text("Invalid profile. Please complete it."));
    }
  }
}

// Model representing the data for a student
class FormModel {
  String firstName = "";
  String lastName = "";
  String email = "";
  String studentCardNumber = "";
  FormModel(
      {required this.firstName,
      required this.lastName,
      required this.email,
      required this.studentCardNumber});
}
