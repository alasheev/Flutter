import 'dart:ui';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'Room.dart';
import 'Connector.dart' as connector;
import "Model.dart";
import 'Lobby.dart';
import 'CreateRoom.dart';
import 'Register.dart';
import 'Login.dart';
import 'RoomInfo.dart';
import 'UploadFile.dart';
import 'Files.dart';
import 'UserInfo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    model.rootBuildContext = context;
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder:
            (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
          return MaterialApp(
              theme: model.setTheme(),
              initialRoute: "/",
              routes: {
                '/Register': (screenContext) => Register(),
                '/Login': (screenContext) => Login(),
                "/Room": (screenContext) => Room(),
                '/Lobby': (screenContext) => Lobby(),
                '/CreateRoom': (screenContext) => CreateRoom(),
                '/RoomInfo': (screenContext) => RoomInfo(),
                '/UploadFile': (screenContext) => UploadFile(),
                '/Files': (screenContext) => Files(),
                '/UserInfo': (screencontext) => UserInfo(),
              },
              home: Home());
        },
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('тема ${Theme.of(context).textTheme}');
    model.scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        textTheme: Theme.of(context).appBarTheme.textTheme,
        title: Text(
          'Messenger',
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: new BoxDecoration(
            color: Theme.of(context).accentColor,
            border: Border.all(color: Theme.of(context).accentColor, width: 2),
            borderRadius: new BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          child: Container(
            width: 200,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/Login");
                  },
                  child: Text(
                    'Логин',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/Register");
                  },
                  child: Text(
                    'Регистрация',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
