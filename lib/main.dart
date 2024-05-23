import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:nltk_chatbot_app/landing_page.dart'; // for json support

void main() {
  runApp(const NewMainApp());
}


class NewMainApp extends StatefulWidget {
  const NewMainApp({super.key});

  @override
  State<NewMainApp> createState() => _NewMainAppState();
}

class _NewMainAppState extends State<NewMainApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );
  }
}


class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();

}

class _MainAppState extends State<MainApp> {
  String emailStatus = 'Email status: Not checked';
  Color emailColorIndicator = Colors.grey;
  TextEditingController emailMessageController = TextEditingController();

  Future<void> submitMessage() async {
    try {
      String emailMessage = emailMessageController.text;
      print(emailMessage);
      var response = await http.post(
        Uri.https('renzklo.pythonanywhere.com', '/detect'), // replace with your API URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'emailMessage': emailMessage,
        }),
      );

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Extract the spamValue from the JSON response
        String spamValue = jsonResponse['spamValue'];

        // Update emailColorIndicator and emailStatus based on spamValue
        setState(() {
          if (spamValue == 'spam') {
            emailColorIndicator = Colors.red;
            emailStatus = 'Email status: Spam';
          } else if (spamValue == 'not spam') {
            emailColorIndicator = Colors.green;
            emailStatus = 'Email status: Safe';
          } else {
            emailColorIndicator = Colors.black;
            emailStatus = 'Input Text First';
          }
        });
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        print(response.statusCode);
        throw Exception('Failed to send email message');
      }
    } catch (e) {
      print(e.toString());
      // If an exception was thrown, update emailColorIndicator and emailStatus
      setState(() {
        emailColorIndicator = Colors.black;
        emailStatus = 'Email status: Failed to connect to server';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50.0),
                const Center(
                  child: Text(
                    'Email Spam Detector',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  height:
                      220.0, // Change this to control the visible height of the TextField
                  child: TextField(
                    controller: emailMessageController,
                    textAlign: TextAlign.start,
                    maxLines:
                        null, // This allows the TextField to expand indefinitely
                    minLines: 8,
                    keyboardType: TextInputType.multiline,
                    scrollPhysics: ScrollPhysics(), // This enables scrolling
                    decoration: const InputDecoration(
                      hintText: 'Enter email contents:',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: submitMessage, child: const Text("Submit")),
                    const SizedBox(width: 20.0),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            emailMessageController.clear();
                            emailColorIndicator = Colors.grey;
                            emailStatus = 'Email status: Not checked';
                          });
                        },
                        child: const Text("Clear")),
                  ],
                ),
                const SizedBox(height: 20.0),
                Container(
                  decoration: BoxDecoration(
                    color: emailColorIndicator,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  height: 50.0,
                  child: Center(
                    child: Text(
                      emailStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
