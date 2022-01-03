import 'package:flutter/material.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/forms/inputOTPVerification.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';

class RegisterForm extends StatefulWidget {
  RegisterForm({this.isForgetPassword});
  final bool isForgetPassword;
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _familyId = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  List countryCode;
  String familyId;
  String phone;
  String email;
  String passwordVerification;
  bool isLoading = true;
  String validatePhone = 'No.Telepon tidak boleh kosong';
  bool authorized = false;
  bool isLoadingSubmit = false;
  bool isAlreadyRegister = false;
  bool isCitizen;
  List itemList = ['NKK', 'NIK'];
  Map<String, String> placeData = {};
  Map<String, bool> isValidated = {};
  Map<String, String> validationNote = {};
  Map<String, String> changedValue = {};
  Map<String, String> changedDropdown = {};
  Map<String, List> areaList = {};
  Map<String, List> areaListFilter = {};
  Map<String, dynamic> areaListDetails = {};

  @override
  void initState() {
    isLoading = true;
    getCountryCode();
    isValidated['id'] = false;
    isValidated['phoneNumber'] = false;
    isValidated['email'] = false;
    changedDropdown['userCountryCode'] = "+62";
    changedDropdown['idType'] = "NKK";
    getAreaList();

    super.initState();
  }

  void getCountryCode() async {
    try {
      var data = await CmdbuildController.getCountryCode(context);

      if (data['data'].length != 0) {
        var code = data['data'].map((e) {
          return e['Code'];
        }).toList();
        setState(() {
          countryCode = code;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      ShowPopupNotification.errorNotification(
          context: context,
          content: '$e',
          action: () {
            Navigator.of(context, rootNavigator: true).pop();
          });
    }
  }

  void getAreaList() async {
    try {
      Map<String, dynamic> data = await CmdbuildController.getAreaList(context);

      areaListDetails = data;
      data.forEach((key, value) {
        areaList['$key'] = [];
        value.forEach((e) {
          // if(e['Description'] == 'Padasuka'){
          //   print('=====$e}');
          // }
          areaList['$key'].add(e['Description']);
        });
      });
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  void setItemValue(
    attribute,
    value,
    key,
  ) {
    setState(() {
      if (key == 'Provinsi') {
        areaListFilter['Desa'] = [];
        areaListFilter['Kecamatan'] = [];
        areaListFilter['Kabupaten'] = [];
        placeData['Desa'] = null;
        placeData['Kecamatan'] = null;
        placeData['Kabupaten'] = null;
        areaListDetails['Kabupaten'].forEach((e) {
          if (e['_Propinsi_description'] == value) {
            areaListFilter['Kabupaten'].add(e['Description']);
          }
        });
      }
      if (key == 'Kabupaten') {
        areaListFilter['Desa'] = [];
        areaListFilter['Kecamatan'] = [];
        placeData['Desa'] = null;
        placeData['Kecamatan'] = null;
        areaListDetails['Kecamatan'].forEach((e) {
          if (e['_Kabupaten_description'] == value) {
            areaListFilter['Kecamatan'].add(e['Description']);
          }
        });
      }
      if (key == 'Kecamatan') {
        areaListFilter['Desa'] = [];
        placeData['Desa'] = null;
        areaListDetails['Desa'].forEach((e) {
          if (e['_Kecamatan_description'] == value) {
            areaListFilter['Desa'].add(e['Description']);
          }
        });
      }
      placeData['$key'] = value;
    });
  }

  void onSubmitted() async {
    setState(() {
      isLoadingSubmit = true;
    });
    setState(() {
      if (changedValue['id'] == null || changedValue['id'].length == 0) {
        isValidated['id'] = true;
        validationNote['id'] = 'Nomor ID tidak boleh kosong';
        isLoadingSubmit = false;
      } else {
        isValidated['id'] = false;
      }
      if (changedValue['phoneNumber'] == null ||
          changedValue['phoneNumber'].length == 0) {
        isValidated['phoneNumber'] = true;
        validationNote['phoneNumber'] = 'No.Telepon tidak boleh kosong';
        isLoadingSubmit = false;
      } else {
        isValidated['phoneNumber'] = false;
      }
      // if (changedValue['email'] == null ||
      //     changedValue['email'].length == 0) {
      //   isValidated['email'] =
      //       widget.isForgetPassword == true ? false : true;
      //   validationNote['email'] = 'Email tidak boleh kosong';
      //   isLoadingSubmit = false;
      // } else {
      //   isValidated['email'] = false;
      // }
    });

    if (changedValue['phoneNumber'] != null) {
      setState(() {
        isLoadingSubmit = true;
      });
      if (changedValue['phoneNumber'][0] == '0') {
        setState(() {
          isLoadingSubmit = false;
          isValidated['phoneNumber'] = true;
          validationNote['phoneNumber'] = 'Format nomor telepon salah';
        });
      }
    }
    if (
        // isValidated['email'] == false &&
        isValidated['id'] == false && isValidated['phoneNumber'] == false) {
      setState(() {
        isLoadingSubmit = true;
      });
      var getFamilyId =
          await CmdbuildController.getFamilyData(changedValue['id'], context);
      if (getFamilyId['success'] == true && getFamilyId['data'].length != 0) {
        if (widget.isForgetPassword) {
          if (changedDropdown['phoneNumber'] == null) {
            setState(() {
              changedDropdown['phoneNumber'] = '+62';
            });
          }
          if (getFamilyId['data'][0]['Telepon'] ==
              '${changedDropdown['phoneNumber']}${changedValue['phoneNumber']}') {
            setState(() {
              isLoadingSubmit = false;
            });
            Navigator.pop(context);
            goToPage(
                context,
                OTPVerification(
                  phoneNumber:
                      '${changedDropdown['phoneNumber']}${changedValue['phoneNumber']}',
                  familyIdNumber: changedValue['id'],
                  isForgetPassword: widget.isForgetPassword,
                ));
          } else {
            setState(() {
              isLoadingSubmit = false;
              isValidated['phoneNumber'] = true;
              validationNote['phoneNumber'] = 'No telepon tidak terdaftar';
            });
          }
        } else {
          if (getFamilyId['data'][0]['Password'] == null) {
            setState(() {
              isLoadingSubmit = false;
            });
            Navigator.pop(context);
            goToPage(
                context,
                OTPVerification(
                  phoneNumber: changedDropdown['phoneNumber'] == null
                      ? '+62${changedValue['phoneNumber']}'
                      : '${changedDropdown['phoneNumber']}${changedValue['phoneNumber']}',
                  familyIdNumber: changedValue['id'],
                  isForgetPassword: widget.isForgetPassword,
                  email: changedValue['email'],
                ));
          } else {
            setState(() {
              isLoadingSubmit = false;
              isAlreadyRegister = true;
            });
          }
        }
      }
      if (getFamilyId['success'] == true && getFamilyId['data'].length == 0) {
        setState(() {
          isLoadingSubmit = false;
          isValidated['id'] = true;
          validationNote['id'] = 'Nomor KK tidak ditemukan';
        });
      }
    } else {
      setState(() {
        isLoadingSubmit = false;
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _familyId.dispose();
    super.dispose();
  }

  void dropdownAction(key, value) {
    setState(() {
      changedDropdown['$key'] = value;
    });
  }

  void onChangeValue(key, value) {
    setState(() {
      isValidated['$key'] = false;
      changedValue['$key'] = value;
      print(changedValue);
    });
  }

  void onDataSubmitted() async {
    setState(() {
      isLoadingSubmit = true;
    });

    setState(() {
      if (changedValue['id'] == null || changedValue['id'].length == 0) {
        isValidated['id'] = true;
        validationNote['id'] = 'Nomor NIK tidak boleh kosong';
        isLoadingSubmit = false;
        print(changedValue['id']);
      } else {
        isValidated['id'] = false;
      }
      if (changedValue['phoneNumber'] == null ||
          changedValue['phoneNumber'].length == 0) {
        isValidated['phoneNumber'] = true;
        validationNote['phoneNumber'] = 'No.Telepon tidak boleh kosong';
        isLoadingSubmit = false;
      } else {
        isValidated['phoneNumber'] = false;
      }
    });

    if (changedValue['phoneNumber'] != null) {
      setState(() {
        isLoadingSubmit = true;
      });
      if (changedValue['phoneNumber'][0] == '0') {
        setState(() {
          isLoadingSubmit = false;
          isValidated['phoneNumber'] = true;
          validationNote['phoneNumber'] = 'Format nomor telepon salah';
        });
      }
    }
    if (
        isValidated['id'] == false && isValidated['phoneNumber'] == false) {
      setState(() {
        isLoadingSubmit = true;
      });
      var getFamilyId = await CmdbuildController.getDataIdForRegister(
          'app_citizen', changedValue['id'], context);
      if (getFamilyId['success'] == true && getFamilyId['data'].length != 0) {
        if (widget.isForgetPassword) {
          if (changedDropdown['phoneNumber'] == null) {
            setState(() {
              changedDropdown['phoneNumber'] = '+62';
            });
          }
          await CmdbuildController.findCardWithFilter(
              context: context,
              cardName: 'mtr_authentification',
              filter: 'equal',
              key: 'Code',
              value: changedValue['id']).then((data) {
            if (data['data'][0]['Telepon'] ==
                '${changedDropdown['phoneNumber']}${changedValue['phoneNumber']}') {
              setState(() {
                isLoadingSubmit = false;
              });
              Navigator.pop(context);
              goToPage(
                  context,
                  OTPVerification(
                    phoneNumber:
                    '${changedDropdown['phoneNumber']}${changedValue['phoneNumber']}',
                    familyIdNumber: changedValue['id'],
                    isForgetPassword: widget.isForgetPassword,
                    data: {
                      'userId': changedValue['id'],
                    },
                  ));
            } else {
              setState(() {
                isLoadingSubmit = false;
                isValidated['phoneNumber'] = true;
                validationNote['phoneNumber'] = 'No telepon tidak terdaftar';
              });
            }
          });
        } else {
          await CmdbuildController.findCardWithFilter(
                  context: context,
                  cardName: 'mtr_authentification',
                  filter: 'equal',
                  key: 'Code',
                  value: changedValue['id'])
              .then((value) {
            if (value['data'].length == 0) {
              var findVillageId;

              areaListDetails['Desa'].forEach((e) {
                if (e['Description'] == placeData['Desa']) {
                  setState(() {
                    findVillageId = e['_id'];
                  });
                }
              });
              var data;

              if (getFamilyId['data'][0]['_type'] == 'app_nonlocalcitizen') {
                data = {
                  'userId': changedValue['id'],
                  'fullName': getFamilyId['data'][0]['Description'],
                  'phoneNumberx': changedDropdown['phoneNumber'] == null
                      ? '+62${changedValue['phoneNumber']}'
                      : '${changedDropdown['phoneNumber']}${changedValue['phoneNumber']}',
                  'email': changedValue['email'],
                  'isResident': false,
                  'villageId': findVillageId,
                  'nonCitizenId': getFamilyId['data'][0]['_id']
                };
              } else if (getFamilyId['data'][0]['_type'] ==
                  'app_localcitizen') {
                data = {
                  'userId': changedValue['id'],
                  'fullName': getFamilyId['data'][0]['Description'],
                  'phoneNumberx': changedDropdown['phoneNumber'] == null
                      ? '+62${changedValue['phoneNumber']}'
                      : '${changedDropdown['phoneNumber']}${changedValue['phoneNumber']}',
                  'email': changedValue['email'],
                  'isResident': true,
                  'villageId': findVillageId,
                  'familyId': getFamilyId['data'][0]['Keluarga']
                };
              }

              setState(() {
                isLoadingSubmit = false;
              });

              Navigator.pop(context);
              goToPage(
                  context,
                  OTPVerification(
                      phoneNumber: changedDropdown['phoneNumber'] == null
                          ? '+62${changedValue['phoneNumber']}'
                          : '${changedDropdown['phoneNumber']}${changedValue['phoneNumber']}',
                      familyIdNumber: changedValue['id'],
                      isForgetPassword: widget.isForgetPassword,
                      email: changedValue['email'],
                      data: data));
            } else {
              setState(() {
                isLoadingSubmit = false;
                isAlreadyRegister = true;
              });
            }
          }).catchError((e) {
            print(e);
          });
        }
      }
      if (getFamilyId['success'] == true && getFamilyId['data'].length == 0) {
        setState(() {
          isLoadingSubmit = false;
          isValidated['id'] = true;
          validationNote['id'] = 'Nomor Identitas tidak ditemukan';
        });
      }
    } else {
      setState(() {
        isLoadingSubmit = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBarCustom.buildAppBarCustom(
            title:
                widget.isForgetPassword == false ? 'Register' : 'Lupa Password',
            context: context),
        body: isLoading
            ? Center(child: LoadingIndicator.containerSquareLoadingIndicator())
            : Container(
                // width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        !widget.isForgetPassword
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InputTextForm.dropdownInputFieldWithBorder(
                                      lookupName: 'Provinsi',
                                      attributeName: 'Provinsi',
                                      title: 'Provinsi',
                                      itemList: areaList,
                                      action: setItemValue,
                                      initialValue: null),
                                  InputTextForm.dropdownInputFieldWithBorder(
                                      lookupName: 'Kabupaten',
                                      attributeName: 'Kabupaten',
                                      title: 'Kabupaten',
                                      itemList: areaListFilter,
                                      action: setItemValue,
                                      initialValue: placeData['Kabupaten']),
                                  InputTextForm.dropdownInputFieldWithBorder(
                                      lookupName: 'Kecamatan',
                                      attributeName: 'Kecamatan',
                                      title: 'Kecamatan',
                                      itemList: areaListFilter,
                                      action: setItemValue,
                                      initialValue: placeData['Kecamatan']),
                                  InputTextForm.dropdownInputFieldWithBorder(
                                      lookupName: 'Desa',
                                      attributeName: 'Desa',
                                      title: 'Desa',
                                      itemList: areaListFilter,
                                      action: setItemValue,
                                      initialValue: placeData['Desa']),
                                ],
                              )
                            : Container(),
                        InputTextForm.textInputFieldWithBorder(
                          title: 'NIK',
                          keyboardType: TextInputType.text,
                          action: onChangeValue,
                          attributeName: 'id',
                          isValidate: isValidated['id'],
                          validation: validationNote['id'],
                        ),
                        InputTextForm.textWithDrowdownFieldWithBorder(
                            context: context,
                            title: 'No. HP',
                            key: "phoneNumber",
                            itemList: countryCode,
                            actionDropdown: dropdownAction,
                            actionValueChange: onChangeValue,
                            textFieldController: _phone,
                            isValidate: isValidated['phoneNumber'],
                            validation: validationNote['phoneNumber'],
                            validationException: null,
                            hint: '8xxxxxxxxxx'),
                        !widget.isForgetPassword
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InputTextForm.textInputFieldWithBorder(
                                    attributeName: 'email',
                                    title: 'Email',
                                    keyboardType: TextInputType.text,
                                    action: onChangeValue,
                                  ),
                                  isAlreadyRegister
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 58.0),
                                            child: Text(
                                              '*No Identitas sudah terdaftar, silahkan login.',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        )
                                      : Container()
                                ],
                              )
                            : SizedBox(height: 20.0)
                      ]),
                ),
              ),
        bottomNavigationBar: isLoadingSubmit
            ? BottomNavigation.buildContainerBottomLoading()
            : BottomNavigation.buildContainerBottom1Navigation(
                title: 'Lanjutkan', action: onDataSubmitted));
  }
}
