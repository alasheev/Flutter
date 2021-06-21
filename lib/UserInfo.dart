import 'package:flutter/material.dart';
import "package:scoped_model/scoped_model.dart";
import 'Connector.dart' as connector;
import "Model.dart" show FlutterChatModel, model;

class UserInfo extends StatelessWidget {
  bool _edit = false;

  @override
  Widget build(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context).settings;
    _edit = settings.arguments ?? false;
    return Scaffold(
      backgroundColor: model.isLightTheme ? Colors.white : Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        title: Text('Инфомация о пользователе'),
        actions: [
          _edit
              ? IconButton(
                  icon: Icon(Icons.edit),
                  tooltip: 'Изменить',
                  onPressed: () {},
                )
              : SizedBox()
        ],
      ),
      body: ScopedModel<FlutterChatModel>(
        model: model,
        child: ScopedModelDescendant<FlutterChatModel>(
          builder: (BuildContext inContext, Widget inChild,
              FlutterChatModel inModel) {
            return model.currentUser != null
                ? ListView(children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Имя:',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: model.isLightTheme
                              ? Theme.of(context).accentColor
                              : Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        model.currentUser['name'],
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Адрес эл. почты:',
                        style: TextStyle(
                            fontSize: 20,),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: model.isLightTheme
                              ? Theme.of(context).accentColor
                              : Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        model.currentUser['email'],
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Номер телефона:',
                        style: TextStyle(
                            fontSize: 20,),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: model.isLightTheme
                              ? Theme.of(context).accentColor
                              : Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        '+7 ' + model.currentUser['phone'],
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ])
                : SizedBox();
          },
        ),
      ),
    );
  }
}
