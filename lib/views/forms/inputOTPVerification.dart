import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:titikkita/views/forms/inputPassword.dart';
import 'package:titikkita/views/forms/inputPhoneNumber.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPVerification extends StatefulWidget {
  OTPVerification({
    this.phoneNumber,
    this.familyIdNumber,
    this.verifiedId,
    this.isForgetPassword,
    this.email,
    this.data,
  });
  final String phoneNumber;
  final String familyIdNumber;
  final String verifiedId;
  final bool isForgetPassword;
  final String email;
  final dynamic data;

  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  String number = "";
  String familyId;
  String otpNumber = '';
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isInvalid = false;
  String verifiedId;
  bool isLoading = false;
  bool isLoadingSubmit = false;
  bool startCount = true;
  TextEditingController textEditingController = TextEditingController();

  void initState() {
    familyId = widget.familyIdNumber;
    for (var i = 0; i <= widget.phoneNumber.length - 1; i++) {
      if (i <= widget.phoneNumber.length - 4) {
        number = number + '*';
      } else {
        number = number + widget.phoneNumber[i];
      }
    }

    sendOTPNumber(widget.phoneNumber);
    super.initState();
  }

  sendOTPNumber(no) async {
    try {
      setState(() {
        isLoading = true;
      });
      await auth.verifyPhoneNumber(
        phoneNumber: no,
        timeout: const Duration(seconds: 59),
        verificationCompleted: (PhoneAuthCredential credential) async {
          PhoneAuthCredential phoneAuthCredential =
              PhoneAuthProvider.credential(
                  verificationId: verifiedId, smsCode: otpNumber);
          await auth.signInWithCredential(credential).then((user) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return InputPasswordForm(
                familyIdNumber: familyId,
                isForgetPassword: widget.isForgetPassword,
                phoneNumber: widget.phoneNumber,
                email: widget.email,
                data: widget.data,
              );
            }));
          }).catchError((e) {
            ShowPopupNotification.errorNotification(
                context: context,
                content: 'Terjadi error. Coba lagi nanti!',
                action: () {
                    Navigator.pop(context);
                });
            setState(() {
              isInvalid = true;
              isLoading = false;
            });
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print('==========$e');
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          } else {
            print(e);
          }
          setState(() {
            isInvalid = true;
          });
          ShowPopupNotification.errorNotification(
              context: context,
              content:'$e',
              action: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => RegisterForm(
                  isForgetPassword: false)));
              });
          return 'error';
        },
        codeSent: (String verificationId, int resendToken) {

          verifiedId = verificationId;
          setState(() {
            isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verifiedId = verificationId;
        },
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error. Coba lagi nanti!',
          action: (){});
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarCustom.buildAppBarCustom(title: "Daftar", context: context),
      body: isLoading
          ? Center(
              child: LoadingIndicator.containerSquareLoadingIndicator(),
            )
          : Center(
              child: Container(
                color: Colors.grey[200],
                child: Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(top: 30, bottom: 200),
                  padding:
                      EdgeInsets.only(left: 50, right: 50, top: 30, bottom: 30),
                  child: ListView(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Kode vefirikasi telah dikirim melalui SMS ke no:',
                          style:
                              TextStyle(color: Colors.blue[900], fontSize: 14),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '$number',
                          style:
                              TextStyle(color: Colors.blue[900], fontSize: 14),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        obscuringCharacter: '*',
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                          inactiveColor: Colors.blue,
                          // selectedColor: Colors.black,
                          selectedFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        // animationDuration: Duration(milliseconds: 300),
                        // backgroundColor: Colors.blue.shade50,
                        enableActiveFill: true,
                        // errorAnimationController: errorController,
                        controller: textEditingController,
                        onCompleted: (v) {
                          print("Completed");
                        },
                        onChanged: (value) {
                          print(value);
                          setState(() {
                            otpNumber = value;
                          });
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      startCount ?
                      TweenAnimationBuilder(
                        tween: Tween(begin: 59.0, end: 0),
                        duration: Duration(seconds: 59),
                        builder: (context, value, child) => Text(
                          'Kode akan berakhir dalam waktu 00:${value.toInt()}',
                          style: TextStyle(color: Colors.black45),

                        ),
                        onEnd: () {
                          setState(() {
                            startCount = false;
                          });
                        },
                      ): Container(),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: RichText(
                          text: TextSpan(
                            text: "Tidak menerima kode aktivasi ? ",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none),
                            children: <TextSpan>[
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      isLoading = true;
                                      startCount = true;
                                    });
                                    sendOTPNumber(widget.phoneNumber);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                text: " Kirim ulang",
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.normal,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      isInvalid
                          ? Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Text(
                                '* Kode OTP yang anda masukkan salah !',
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar:
      isLoadingSubmit? BottomNavigation.buildContainerBottomLoading() : !isLoading ?
      BottomNavigation.buildContainerBottom1Navigation(
          title: 'Lanjutkan',
          action: () async {
            setState(() {
              isLoadingSubmit = true;
            });
            PhoneAuthCredential phoneAuthCredential =
                PhoneAuthProvider.credential(
                    verificationId: verifiedId, smsCode: otpNumber);
            await auth.signInWithCredential(phoneAuthCredential).then((user) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return InputPasswordForm(
                  familyIdNumber: familyId,
                  isForgetPassword: widget.isForgetPassword,
                  phoneNumber: widget.phoneNumber,
                  email: widget.email,
                  data: widget.data,
                );
              }));
              setState(() {
                isLoadingSubmit = false;
              });
            }).catchError((e) {
              // ShowPopupNotification.errorNotification(
              //     context: context,
              //     content: 'Terjadi error. Coba lagi nanti!',
              //     action: () {
              //       Navigator.pop(context);
              //     });
              setState(() {
                isLoadingSubmit= false;
                isInvalid = true;
              });
            });
          }) : null
    );
  }
}
