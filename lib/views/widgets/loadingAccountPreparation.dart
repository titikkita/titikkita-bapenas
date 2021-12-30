import 'package:flutter/material.dart';
import 'package:titikkita/views/pages/LoginView.dart';
import 'package:titikkita/views/widgets/appBar.dart';

class LoadingAccountPreparation extends StatefulWidget {
  @override
  _LoadingAccountPreparationState createState() =>
      _LoadingAccountPreparationState();
}

class _LoadingAccountPreparationState extends State<LoadingAccountPreparation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.grey[200],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.blue,
              size: 80,
            ),
            SizedBox(
              height: 40,
            ),
            Center(
              child: Text(
                'Berhasil registrasi. Silahkan login',
                style: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 16,
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                  return LoginView();
                }));
              },
              child: Center(
                child: Text(
                  'di sini!',
                  style: TextStyle(
                    color: Colors.blue[400],
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
