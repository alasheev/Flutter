import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "Model.dart";
import 'Connector.dart' as connector;

class Register extends StatefulWidget {
  Register({Key key}) : super(key: key);
  @override
  _Register createState() => _Register();
}

class _Register extends State {
  String _name, _email, _phone, _password;

  bool _hidePass = true;

  final TextEditingController _nameController = TextEditingController(),
      _emailController = TextEditingController(),
      _phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    model.rootBuildContext = context;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: model.isLightTheme? Colors.white: Colors.grey[800],
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Регистрация'),
        ),
        body: Form(
          key: _formKey,
          child: Container(
            color: Theme.of(context).canvasColor,
            child: Container(
              padding: EdgeInsets.all(12),
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: 'Имя',
                      hintText: 'Фамилия Имя Отчество',
                      prefixIcon: Icon(
                        Icons.person,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _nameController.text = '';
                        },
                      ),
                      enabledBorder: myBorder(context),
                      focusedBorder: myBorder(context),
                      errorBorder: myBorder(context),
                      focusedErrorBorder: myBorder(context),
                    ),
                    onSaved: (String inValue) {
                      setState(() {
                        _name = inValue;
                      });
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: "Электронная почта",
                      prefixIcon: Icon(
                        Icons.mail,
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
                    validator: (String inValue) {
                      if (inValue.length == 0) {
                        return 'Введите email';
                      }

                      bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(inValue);

                      if (!emailValid) {
                        return 'Некорректный email';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (String inValue) {
                      setState(() {
                        _email = inValue;
                      });
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelText: "Номер телефона",
                        prefixIcon: Icon(
                          Icons.phone,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _phoneController.text = '';
                          },
                        ),
                        enabledBorder: myBorder(context),
                        focusedBorder: myBorder(context),
                        errorBorder: myBorder(context),
                        focusedErrorBorder: myBorder(context),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (String inValue) {
                        if (inValue.length == 10) {
                          return null;
                        }
                        return 'Номер должен содержать 10 цифр';
                      },
                      onSaved: (String inValue) {
                        setState(() {
                          _phone = inValue;
                        });
                      }),
                  SizedBox(height: 15),
                  TextFormField(
                    obscureText: _hidePass,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: "Пароль",
                      prefixIcon: Icon(
                        Icons.vpn_key,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_hidePass
                            ? Icons.visibility
                            : Icons.visibility_off),
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
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(
                              color: Theme.of(context).accentColor, width: 2),
                        ),
                        minimumSize: Size(100, 60)),
                    child: Text(
                      'Отправить',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (!_formKey.currentState.validate()) {
                        return;
                      }
                      _formKey.currentState.save();
                      String result = await connector.register({
                        'name': _name,
                        'phone': _phone,
                        'email': _email,
                        'password': _password
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
                                    if (result ==
                                        'Регистрация прошла успешно') {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              "/", ModalRoute.withName("/"));
                                    }
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          });
                    },
                  ),
                ],
              ),
            ),
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
