import 'package:flutter/material.dart';
import 'package:titikkita/views/widgets/changePasswordSuccessIndicator.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:titikkita/views/widgets/loadingAccountPreparation.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputPasswordForm extends StatefulWidget {
  InputPasswordForm(
      {this.familyIdNumber,
      this.isForgetPassword,
      this.phoneNumber,
      this.email,
      this.data});
  final String familyIdNumber;
  final bool isForgetPassword;
  final String phoneNumber;
  final String email;
  final dynamic data;
  @override
  _InputPasswordFormState createState() => _InputPasswordFormState();
}

class _InputPasswordFormState extends State<InputPasswordForm> {
  // final _password = TextEditingController(text: '');
  // final _passwordVerification = TextEditingController(text: '');

  String password = "";
  String passwordVerification = "";
  bool _validatePassword = false;
  bool _validatePasswordVerififcation = false;
  String familyId;
  bool isPasswordVerify = false;
  bool isForgetPassword;
  bool isSubmitLoading = false;

  @override
  void initState() {
    familyId = widget.familyIdNumber;
    isForgetPassword = widget.isForgetPassword;
    super.initState();
  }

  void dispose() {
    TextEditingController().dispose();
    // _passwordVerification.dispose();
    super.dispose();
  }

  void onChangedValue(key, value) {
    setState(() {
      if (key == 'password') {
        _validatePassword = false;
        password = value;
      }
      if (key == 'passwordVerify') {
        setState(() {
          passwordVerification = value;
          _validatePasswordVerififcation = false;
          if (password == passwordVerification) {
            isPasswordVerify = true;
          } else {
            isPasswordVerify = false;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar:
          AppBarCustom.buildAppBarCustom(title: "Kata Sandi", context: context),
      body: Center(
        child: Container(
          color: Colors.grey[200],
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(top: 30, bottom: 180),
            padding: EdgeInsets.only(left: 50, right: 50, top: 30, bottom: 30),
            child: ListView(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                isForgetPassword == false
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Tinggal selangkah lagi untuk aktifkan akun anda.',
                            style: TextStyle(
                                color: Colors.blue[900], fontSize: 16),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          InputTextForm.buildContainerInputVertical(
                            title: 'Kata Sandi',
                            // controllerInput: _password,
                            controllerInputText: password,
                            obscureText: true,
                            validate: _validatePassword,
                            action: onChangedValue,
                            key: 'password',
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          InputTextForm.buildContainerInputVertical(
                            title: 'Konfirmasi Kata Sandi',
                            // controllerInput: _passwordVerification,
                            controllerInputText: passwordVerification,
                            obscureText: true,
                            validate: _validatePasswordVerififcation,
                            isPasswordVerified: isPasswordVerify,
                            action: onChangedValue,
                            key: 'passwordVerify',
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Text(
                            'Masukkan kata sandi baru anda !',
                            style: TextStyle(
                                color: Colors.blueGrey[700], fontSize: 20),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          InputTextForm.buildContainerInputVertical(
                            title: 'Kata Sandi Baru',
                            // controllerInput: _password,
                            controllerInputText: password,
                            obscureText: true,
                            validate: _validatePassword,
                            action: onChangedValue,
                            key: 'password',
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          InputTextForm.buildContainerInputVertical(
                            title: 'Konfirmasi Kata Sandi Baru',
                            // controllerInput: _passwordVerification,
                            controllerInputText: passwordVerification,
                            obscureText: true,
                            validate: _validatePasswordVerififcation,
                            isPasswordVerified: isPasswordVerify,
                            action: onChangedValue,
                            key: 'passwordVerify',
                          )
                        ],
                      )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: isSubmitLoading
          ? BottomNavigation.buildContainerBottomLoading()
          : BottomNavigation.buildContainerBottom1Navigation(
              title: 'Lanjutkan',
              action: () async {
                setState(() {
                  isSubmitLoading = true;

                  if (password.length == 0) {
                    _validatePassword = true;
                    isSubmitLoading = false;
                  } else {
                    _validatePassword = false;
                  }
                  if (passwordVerification.length == 0) {
                    _validatePasswordVerififcation = true;
                    isSubmitLoading = false;
                  } else {
                    _validatePasswordVerififcation = false;
                  }
                });
                if (_validatePassword == false &&
                    _validatePasswordVerififcation == false &&
                    password == passwordVerification) {
                  try {
                    await CmdbuildController.getAdminToken();
                    var bytes = utf8.encode(password);
                    var hashPassword = sha1.convert(bytes);
                    var data;
                    if (widget.isForgetPassword) {
                      await CmdbuildController.findCardWithFilter(
                              context: context,
                              cardName: 'mtr_authentification',
                              filter: 'equal',
                              key: 'Code',
                              value: widget.data['userId'])
                          .then((value) async {
                        data = await CmdbuildController.commitEditCardById(
                            value['data'][0]['_id'],
                            {'Password': hashPassword.toString()},
                            "mtr_authentification",
                            context);
                      });
                    } else {
                      var dataToAdd;

                      if (widget.data['isResident']) {
                        dataToAdd = {
                          'Password': hashPassword.toString(),
                          'Telepon': widget.phoneNumber,
                          'Email': widget.email,
                          'IsResident': widget.data['isResident'],
                          'Desa': widget.data['villageId'],
                          'Code': widget.data['userId'],
                          'Description': widget.data['fullName'],
                          'Keluarga': widget.data['familyId'],
                        };
                      } else if (!widget.data['isResident']) {
                        dataToAdd = {
                          'Password': hashPassword.toString(),
                          'Telepon': widget.phoneNumber,
                          'Email': widget.email,
                          'IsResident': widget.data['isResident'],
                          'Desa': widget.data['villageId'],
                          'Code': widget.data['userId'],
                          'Description': widget.data['fullName'],
                          'NonWarga': widget.data['nonCitizenId']
                        };
                      }

                      print(dataToAdd);
                      print(widget.data['isResident']);

                      data = await CmdbuildController.commitNewRegister(
                          dataToAdd, context);
                    }
                    if (data['success']) {
                      final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                      prefs.remove('token');
                      Navigator.pop(context);

                      widget.isForgetPassword == false
                          ? goToPage(context, LoadingAccountPreparation())
                          : goToPage(context, SuccessChangedPasswordView());
                    } else {
                      ShowPopupNotification.errorNotification(
                          context: context,
                          content: 'Terjadi error. Coba lagi nanti!',
                          action: () {
                            setState(() {
                              Navigator.of(context, rootNavigator: true).pop();
                            });
                          });
                    }
                    setState(() {
                      isSubmitLoading = false;
                    });
                  } catch (e) {
                    setState(() {
                      isSubmitLoading = false;
                    });
                    ShowPopupNotification.errorNotification(
                        context: context,
                        content: 'Terjadi error. Coba lagi nanti!',
                        action: () {
                          setState(() {
                            Navigator.of(context, rootNavigator: true).pop();
                          });
                        });
                    print(
                        'This error happened when try to submmit final register form in inputPassword.dart');
                    print('Error: $e');
                  }
                }
              }),
    );
  }
}
