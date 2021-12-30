
import 'package:titikkita/util/generateToken.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getToken(context) async {
  String result;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String token = prefs.getString('token');

  if (token != null) {
    result = token;
  } else {
    print('get token tidak ada token try get another token');
    await generateToken(context).then((value) {
      result = value;
    });

    // Navigator.pushReplacement(context,
    //     MaterialPageRoute(builder: (context) {
    //       return LoginView();
    //     }));
    // try {
    //   var newToken = await generateToken(context);
    //   result= newToken;
    // } catch (e) {
    //
    //   ShowPopupNotification.errorNotification(
    //       context: context,
    //       content:'Jaringan tidak ditemukan. Sepertinya anda belum terhubung kejaringan',
    //       action: () {
    //       });
    //
    //   if (e['Error'] == 'Network is unreachable') {
    //     ShowPopupNotification.errorNotification(
    //         context: context,
    //         content: 'Jaringan tidak ditemukan.',
    //         action:(){});
    //   }
    // }
  }

  return result;
}
