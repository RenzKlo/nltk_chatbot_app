import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nltk_chatbot_app/theme.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
  });
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            const BackgroundScreen(),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.menu),
                color: Colors.white,
              )
            ]),
            Align(
              alignment: Alignment.bottomCenter,
              child: MainContainer(),
            ),
          ],
        ),
      ),
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({
    super.key,
  });

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  TextEditingController emailMessageController = TextEditingController();
  String spamValue = 'unknown';
  Future<void> submitMessage() async {
    try {
      String emailMessage = emailMessageController.text;
      if (emailMessage.isEmpty) {
        throw Exception('Email message is empty');
      }
      print(emailMessage);

      var response = await http.post(
        Uri.https('renzklo.pythonanywhere.com',
            '/detect'), // replace with your API URL
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
        setState(() {
          spamValue = jsonResponse['spamValue'];
        });

        // Update emailColorIndicator and emailStatus based on spamValue
        // setState(() {
        //   if (spamValue == 'spam') {
        //     // emailColorIndicator = Colors.red;
        //     // emailStatus = 'Email status: Spam';
        //   } else if (spamValue == 'not spam') {
        //     // emailColorIndicator = Colors.green;
        //     // emailStatus = 'Email status: Safe';
        //   } else {
        //     // emailColorIndicator = Colors.black;
        //     // emailStatus = 'Input Text First';
        //   }
        // });
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.

        throw Exception(
            'Failed to send email message. Status Code: ${response.statusCode}');
      }
    } on http.ClientException {
      // If an exception was thrown, update emailColorIndicator and emailStatus
      Fluttertoast.showToast(
          msg: 'Unable to connect to server. Check your internet connection.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.pink,
          textColor: Colors.white,
          fontSize: 16.0);
    } on Exception catch (e) {
      // If an exception was thrown, update emailColorIndicator and emailStatus

      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.pink,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 30, 30, 30),
          child: Column(
            children: [
              const SizedBox(height: 30),
              HeaderLabelContainer(spamStatus: spamValue),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    ButtonSelectors(
                      onSubmit: submitMessage,
                      onClear: () {
                        emailMessageController.clear();
                        setState(() {
                          spamValue = 'unknown';
                        });
                      },
                      onPaste: () async {
                        final clipboardData =
                            await Clipboard.getData('text/plain');
                        if (clipboardData?.text != null) {
                          setState(() {
                            emailMessageController.text = clipboardData!.text!;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: emailMessageController,
                      textAlign: TextAlign.start,
                      maxLines:
                          null, // This allows the TextField to expand indefinitely
                      minLines: 8,
                      keyboardType: TextInputType.multiline,
                      scrollPhysics: ScrollPhysics(), // This enables scrolling
                      decoration: const InputDecoration(
                        hintText: 'Enter email contents:',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ButtonSelectors extends StatefulWidget {
  final Function() onSubmit;
  final Function() onClear;
  final Function() onPaste;
  const ButtonSelectors({
    super.key,
    required this.onSubmit,
    required this.onClear,
    required this.onPaste,
  });

  @override
  State<ButtonSelectors> createState() => _ButtonSelectorsState();
}

class _ButtonSelectorsState extends State<ButtonSelectors> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      InkWell(
        onTap: widget.onSubmit,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 11),
            child: Text(
              'Detect',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: widget.onClear,
            style: OutlinedButton.styleFrom(
              side:
                  BorderSide(color: Color.fromARGB(255, 219, 51, 0), width: 2),
              foregroundColor: Color.fromARGB(255, 219, 51, 0),
              backgroundColor: Colors.white,
            ),
            child: Text('Clear'),
          ),
          SizedBox(width: 20),
          InkWell(
            onTap: widget.onPaste,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Icon(
                    Icons.paste_rounded,
                    color: Colors.white,
                  )),
            ),
          ),
        ],
      )
    ]);
  }
}

class HeaderLabelContainer extends StatefulWidget {
  HeaderLabelContainer({
    super.key,
    required this.spamStatus,
  });

  String spamStatus;

  @override
  State<HeaderLabelContainer> createState() => _HeaderLabelContainerState();
}

class _HeaderLabelContainerState extends State<HeaderLabelContainer> {
  String textStatus = 'Enter \nmessage \nbelow...';
  IconData iconStatus = Icons.message;

  @override
  void didUpdateWidget(HeaderLabelContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spamStatus != oldWidget.spamStatus) {
      // Perform your state change here
      // For example, you might want to update textStatus and iconStatus based on the new spamStatus
      setState(() {
        if (widget.spamStatus == 'spam') {
          textStatus = 'The \nmessage is \nSpam!';
          iconStatus = Icons.warning_rounded;
          // emailColorIndicator = Colors.red;
          // emailStatus = 'Email status: Spam';
        } else if (widget.spamStatus == 'not spam') {
          textStatus = 'The \nmessage is \nHam!';
          iconStatus = Icons.warning_rounded;
          // emailColorIndicator = Colors.green;
          // emailStatus = 'Email status: Safe';
        } else {
          textStatus = 'Enter \nmessage \nbelow...';
          iconStatus = Icons.message;
          // emailColorIndicator = Colors.black;
          // emailStatus = 'Input Text First';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(138, 85, 84, 84),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            gradient: gradient),
        height: 200,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconStatus,
                size: 90,
                color: Colors.white,
              ),
              SizedBox(width: 20),
              Text(
                textStatus,
                softWrap: true,
                style: TextStyle(
                  fontFamily: 'Roboto ',
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                ),
              )
            ],
          ),
        ));
  }
}

class BackgroundScreen extends StatelessWidget {
  const BackgroundScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: gradient),
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
    );
  }
}
