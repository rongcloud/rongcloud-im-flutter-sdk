import 'package:flutter/material.dart';
import '../im/util/http_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:developer' as developer;

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  String pageName = "example.LoginPage";
  TextEditingController _assount = TextEditingController();
  TextEditingController _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.get("phone");
    String password = prefs.get("password");

    _assount.text = phone;
    _password.text = password;
  }

  void _loginAction() {
    Map map = new Map();
    map["region"] = 86;
    map["phone"] = int.parse(_assount.text);
    map["password"] = _password.text;

    HttpUtil.post("http://api.sealtalk.im/user/login", (data) {
      if (data != null) {
        Map body = data;
        int errorCode = body["code"];
        if (errorCode == 200) {
          Map result = body["result"];
          String id = result["id"];
          String token = result["token"];
          _saveUserInfo(id, token);
          developer.log("Login Success, $map", name: pageName);
          Navigator.of(context).pushAndRemoveUntil(
              new MaterialPageRoute(builder: (context) => new HomePage()),
              (route) => route == null);
        } else if (errorCode == -1) {
          Fluttertoast.showToast(msg: "网络未连接，请连接网络重试");
        } else {
          Fluttertoast.showToast(msg: "服务器登录失败，errorCode： $errorCode");
        }
      } else {
        developer.log("data is null", name: pageName);
      }
    }, params: map);
  }

  void _saveUserInfo(String id, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("id", id);
    prefs.setString("token", token);
    prefs.setString("phone", _assount.text);
    prefs.setString("password", _password.text);
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

    final account = TextFormField(
      keyboardType: TextInputType.number,
      autofocus: false,
      controller: _assount,
      decoration: InputDecoration(
          hintText: 'SealTalk 账号',
          contentPadding: new EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final password = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: _password,
      decoration: InputDecoration(
          hintText: 'SealTalk 密码',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
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
          account,
          SizedBox(
            height: 8.0,
          ),
          password,
          SizedBox(
            height: 24.0,
          ),
          loginButton
        ],
      )),
    );
  }
}
