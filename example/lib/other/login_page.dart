import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../user_data.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  String pageName = "example.LoginPage";
  TextEditingController _id = TextEditingController();
  TextEditingController _token = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("id") ?? CurrentUserId;
    String token = prefs.getString("token") ?? RongIMToken;

    _id.text = id;
    _token.text = token;
  }

  void _loginAction() async {
    String id = _id.text;
    String token = _token.text;
    await _saveUserInfo(id, token);
    Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (context) => new HomePage()), (route) => false);
  }

  Future<void> _saveUserInfo(String id, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("id", id);
    prefs.setString("token", token);
  }

  @override
  Widget build(BuildContext context) {
    final logo = new Hero(
      tag: 'hero',
      child: Container(
        width: 100,
        height: 100,
        child: Image.asset('assets/images/logo.png'),
      ),
    );

    final id = TextFormField(
      keyboardType: TextInputType.text,
      autofocus: false,
      controller: _id,
      decoration: InputDecoration(
        hintText: 'User Id',
        contentPadding: new EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );

    final token = TextFormField(
      keyboardType: TextInputType.text,
      autofocus: false,
      controller: _token,
      decoration: InputDecoration(
        hintText: 'User Token',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: MaterialButton(
        minWidth: 200.0,
        height: 42.0,
        onPressed: () {
          _loginAction();
        },
        color: Colors.lightBlueAccent,
        child: Text(
          '登 录',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
          child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        children: <Widget>[
          logo,
          SizedBox(height: 48.0),
          id,
          SizedBox(
            height: 8.0,
          ),
          token,
          SizedBox(
            height: 24.0,
          ),
          loginButton
        ],
      )),
    );
  }
}
