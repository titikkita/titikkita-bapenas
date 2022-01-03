import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:titikkita/state/indivivual_provider.dart';
import 'package:titikkita/util/generateToken.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/forms/inputPhoneNumber.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/views/pages/DashboardView.dart';
import 'package:provider/provider.dart' as provider;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  TapGestureRecognizer registerRecognizer;
  String errorMessage;
  bool isError = false;
  bool _initialized = false;
  bool _error = false;
  bool _isLoading = false;
  bool isServerError = false;
  bool isOnline = true;
  bool isLoggedIn = false;
  bool rememberMe = true;
  bool isFamilyLogin = false;
  AnimationController _controller;
  bool isSubmitLoading = false;
  Map<String, String> loginInputValue = {};

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initState() {
    // getLoginInfo();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    initializeFlutterFire();
    registerRecognizer = TapGestureRecognizer()
      ..onTap = () {
        goToPage(
            context,
            RegisterForm(
              isForgetPassword: false,
            ));
      };
    checkLocalStorage();
    super.initState();
  }

  void checkLocalStorage() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // final String userId = prefs.getString('userLoginId');
      final String token = prefs.getString('token');
      final String password = prefs.getString('password');
      final String nik = prefs.getString('nik');
      if (nik != null && token != null) {
        setState(() {
          loginInputValue['loginId'] = nik;
          loginInputValue['password'] = password;
        });
        await onSubmitIndividualLogin().then((value) {
          prefs.setString('nik', loginInputValue['loginId']);
          prefs.setString('password', loginInputValue['password']);
        });
      } else {
        final String nikInStorage = prefs.getString('nik');
        final String passwordInStorage = prefs.getString('password');
        if (nikInStorage != null) {
          setState(() {
            loginInputValue['password'] = passwordInStorage;
            loginInputValue['loginId'] = nikInStorage;
          });
        }

        setState(() {
          isLoggedIn = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  Future<void> onSubmitIndividualLogin() async {
    print('0===========');
    try {
      setState(() {
        isSubmitLoading = true;
      });
      await generateToken(context).then((value) async {
        print('1===========');
        if (value != null) {
          await CmdbuildController.findCardWithFilter(
              context: context,
              cardName: 'app_citizen',
              filter: 'equal',
              key: 'Code',
              value: loginInputValue['loginId']).then((data) async{
            if (data['data'].length != 0) {
              await CmdbuildController.getUserAuthenticationData(
                  context: context, value: loginInputValue['loginId'])
                  .then((value) async {
                print('2===========');
                if (value['data'].length != 0) {
                  provider.Provider.of<LocalProvider>(context, listen: false)
                      .updatePrincipalConstraint(value);
                  var bytes = utf8.encode(loginInputValue['password']);
                  var hashPassword = sha1.convert(bytes);

                  if (value['data'][0]['Password'] == hashPassword.toString()) {
                    if (data['success'] == true && data['data'].length != 0) {
                      if (data['data'][0]['_StatusDalamKeluarga_code'] ==
                          'Kepala Keluarga') {
                        print('3===========');
                        await onSubmitFamilyLogin(
                            data['data'][0]['_Keluarga_code']);
                      } else {
                        provider.Provider.of<IndividualProvider>(context,
                            listen: false)
                            .updateIsIndividualLogin();
                        provider.Provider.of<IndividualProvider>(context,
                            listen: false)
                            .updateIndividualData(data['data'][0]);
                        final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                        if (rememberMe) {
                          prefs.setString('nik', loginInputValue['loginId']);
                          prefs.setString(
                              'password', loginInputValue['password']);
                        } else {
                          prefs.remove('nik');
                          prefs.remove('password');
                        }
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                              return DashboardView(
                                isCitizen: isFamilyLogin,
                              );
                            }));
                      }
                    } else {
                      if (data['success'] == true && data['data'].length == 0) {
                        setState(() {
                          isError = true;
                          errorMessage = '*NIK tidak terdaftar';
                          isSubmitLoading = false;
                        });
                      }
                    }
                  } else {
                    setState(() {
                      isError = true;
                      errorMessage = '* Password dengan No NIK tidak sesuai';
                      isSubmitLoading = false;
                    });
                  }
                } else {
                  setState(() {
                    isError = true;
                    errorMessage =
                    '*Akun belum terdaftar, silahkan mendaftar terlebih dahulu!';
                    isSubmitLoading = false;
                  });
                }
              }).catchError((e) {
                print('======$e');
                setState(() {
                  isError = true;
                  errorMessage = '$e';
                  isSubmitLoading = false;
                });
              });
            } else {
              setState(() {
                isError = true;
                errorMessage =
                '* No Identitas yang anda masukkan tidak ditemukan';
                isSubmitLoading = false;
              });
            }
          });
        }
      });
    } catch (e) {
      setState(() {
        isSubmitLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(ShowPopupNotification.showSnackBar(
          content:
          'Jaringan tidak ditemukan. Sepertinya anda belum terhubung kejaringan atau server sedang offline.'));
      print('Error to getDataFamily on login view. $e');
    }
  }

  Future<void> onSubmitFamilyLogin(familyId) async {
    print('4===========');
    try {
      setState(() {
        isSubmitLoading = true;
      });
      await CmdbuildController.getFamilyData(familyId, context)
          .then((value) async {
        if (value['data'].length != 0) {
          if (value['success'] == true && value['data'].length != 0) {
            await provider.Provider.of<LocalProvider>(context, listen: false)
                .updateFamilyData(value['data'][0]);

            final SharedPreferences prefs =
            await SharedPreferences.getInstance();
            if (rememberMe) {
              prefs.setString('nik', loginInputValue['loginId']);
              prefs.setString('password', loginInputValue['password']);
            } else {
              prefs.remove('nik');
              prefs.remove('password');
            }

            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
                  return DashboardView(
                    // isCitizen: isFamilyLogin,
                    isCitizen: true,
                  );
                }));
          } else {
            if (value['success'] == true && value['data'].length == 0) {
              setState(() {
                isError = true;
                errorMessage = '*NIK tidak terdaftar';
                isSubmitLoading = false;
              });
            }
          }
        } else {
          setState(() {
            isError = true;
            errorMessage = '* No KK yang anda masukkan tidak ditemukan';
            isSubmitLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        isSubmitLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(ShowPopupNotification.showSnackBar(
          content:
          'Jaringan tidak ditemukan. Sepertinya anda belum terhubung kejaringan atau server sedang offline.'));
      print('Error to getDataFamily on login view. $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? Center(
          child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                    alignment: Alignment.center, child: Text('Loading...')
                  // ScaleTransition(
                  //   scale: CurvedAnimation(
                  //       parent: _controller, curve: Curves.bounceInOut),
                  //   child:   Image.asset("assets/images/bapenas.png",
                  //     height: 170,width: 170,),
                  // ),
                ),
              )))
          : Container(
        color: Colors.blue,
        // padding: EdgeInsets.only(top: 20),
        child: Center(
          child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  top: 30,
                  bottom: 25,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/bapenas.png",
                      height: 70,
                      width: 100,
                    ),
                    // Image.asset(
                    //   "assets/images/logo_sumedang.png",
                    //   height: 60,
                    // )
                  ],
                ),
              ),
              Center(
                child: Container(
                  // padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "BAPPENAS",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                  ),
                ),
              ),
              // Center(
              //   child: Container(
              //     padding: EdgeInsets.only(bottom: 20),
              //     child: Text(
              //       "Sumedang",
              //       style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 20,
              //           fontStyle: FontStyle.normal,
              //           fontWeight: FontWeight.bold,
              //           decoration: TextDecoration.none),
              //     ),
              //   ),
              // ),
              Center(
                child: Container(
                  padding: EdgeInsets.only(bottom: 30, top: 10),
                  child: Text(
                    "Aplikasi Titik Kita",
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 20,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 40, left: 40),
                child: Column(
                  children: <Widget>[
                    InputTextForm.textInputFieldWithBorderAndBGColor(
                      obscureText: false,
                      initialValue: loginInputValue['loginId'],
                      hintText: 'NIK',
                      action: (attribute, val) {
                        setState(() {
                          isError = false;
                          loginInputValue['loginId'] = val;
                        });
                      },
                      attributeName: 'loginId',
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InputTextForm.textInputFieldWithBorderAndBGColor(
                      initialValue: loginInputValue['password'],
                      obscureText: true,
                      hintText: 'Password',
                      action: (attribute, val) {
                        setState(() {
                          isError = false;
                          loginInputValue[attribute] = val;
                        });
                      },
                      attributeName: 'password',
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.only(left: 0),
                        title: Text(
                          'Ingat saya',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        value: rememberMe,
                        onChanged: (bool value) {
                          setState(() {
                            rememberMe = value;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.only(top: 10, bottom: 20),
                        child: GestureDetector(
                          onTap: () {
                            goToPage(
                                context,
                                RegisterForm(
                                  isForgetPassword: true,
                                ));
                          },
                          child: Text(
                            "Lupa Kata Sandi ?",
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: GestureDetector(
                        onTap: isFamilyLogin
                            ? onSubmitFamilyLogin
                            : onSubmitIndividualLogin,
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xff0C74F2),
                            borderRadius:
                            BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Center(
                            child: isSubmitLoading
                                ? SpinKitFadingCircle(
                              color: Colors.white,
                              size: 40.0,
                            )
                                : Text(
                              "Login",
                              style: TextStyle(
                                  height: 1.0,
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none),
                            ),
                          ),
                        ),
                      ),
                    ),
                    isError == true
                        ? Container(
                      child: Text(
                        errorMessage,
                        style: TextStyle(
                            color: Colors.red[700], fontSize: 14),
                      ),
                    )
                        : Container(),
                  ],
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 30, bottom: 20),
                  child: RichText(
                    text: TextSpan(
                      text: "Belum punya akun ? ",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none),
                      children: <TextSpan>[
                        TextSpan(
                          recognizer: registerRecognizer,
                          text: " Daftar",
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
