import 'package:flutter/material.dart';
import "Model.dart";
import 'Connector.dart' as connector;

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);
  @override
  _Login createState() => _Login();
}

class _Login extends State {
  String _email, _password;

  bool _hidePass = true;

  final TextEditingController _emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    model.rootBuildContext = context;
    return Scaffold(
      backgroundColor: model.isLightTheme? Colors.white: Colors.grey[800],
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Вход'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(height: 150),
              TextFormField(
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    labelText: 'Эл. почта',
                    prefixIcon: Icon(
                      Icons.person,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _emailController.text = '';
                      },
                    ),
                    enabledBorder: myBorder(context),
                    focusedBorder: myBorder(context),
                    errorBorder: myBorder(context),
                    focusedErrorBorder: myBorder(context),
                  ),
                  onSaved: (String inValue) {
                    setState(() {
                      _email = inValue;
                    });
                  }),
              SizedBox(height: 15),
              TextFormField(
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
                  obscureText: _hidePass,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    labelText: "Пароль",
                    prefixIcon: Icon(
                      Icons.vpn_key,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _hidePass ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _hidePass = !_hidePass;
                        });
                      },
                    ),
                    enabledBorder: myBorder(context),
                    focusedBorder: myBorder(context),
                    errorBorder: myBorder(context),
                    focusedErrorBorder: myBorder(context),
                  ),
                  onSaved: (String inValue) {
                    setState(() {
                      _password = inValue;
                    });
                  }),
              SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                          color: Theme.of(context).accentColor, width: 2),
                    ),
                    minimumSize: Size(100, 60)),
                child: Text(
                  'Отправить',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  _formKey.currentState.save();
                  var result = await connector.login({
                    'email': _email,
                    'password': _password,
                  });
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Сообщение'),
                        content: Text(result),
                        actions: [
                          TextButton(
                            child: Text(
                              'OK',
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () {
                              if (result == 'Добро пожаловать!') {
                                connector.connectToServer(() =>
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil("/Lobby",
                                            ModalRoute.withName("/Lobby")));
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder myBorder(context) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(20),
    ),
    borderSide: BorderSide(
      color: Theme.of(context).accentColor,
      width: 2,
    ),
  );
}
