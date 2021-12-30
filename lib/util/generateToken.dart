
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> generateToken(context) async {
  String token;
  try {
    await CmdbuildController.getAdminToken().then((value){
      token = value;

    });
    // await provider.Provider.of<LocalProvider>(context,listen: false).updateAdminToken(token);

    final SharedPreferences prefs =
    await SharedPreferences.getInstance();
    prefs.setString(
        'token',token);
  } catch (e) {
    throw new Error();
  }
  return token;
}