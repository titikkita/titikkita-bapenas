import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/pages/LoginView.dart';

class SuccessChangedPasswordView extends StatefulWidget {
  @override
  _SuccessChangedPasswordViewState createState() =>
      _SuccessChangedPasswordViewState();
}

class _SuccessChangedPasswordViewState
    extends State<SuccessChangedPasswordView> {
  TapGestureRecognizer tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        goToPage(context, LoginView());
      };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(top: 50, bottom: 400),
            padding: EdgeInsets.only(left: 60, right: 60, top: 40),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Berhasil mengganti kata sandi anda.',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Silahkan login kembali ",
                      style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 18,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none),
                      children: <TextSpan>[
                        TextSpan(
                          recognizer: tapGestureRecognizer,
                          text: "di sini .",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
