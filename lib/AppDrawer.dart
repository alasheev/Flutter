import 'dart:io';
import "package:scoped_model/scoped_model.dart";
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'Connector.dart' as connector;
import "Model.dart" show FlutterChatModel, model;

class AppDrawer extends StatelessWidget {
  String ext, name, path;

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder:
            (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
          return Drawer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ignore: missing_required_param
                DrawerHeader(
                    decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: [
                        ListTile(
                          leading: FlutterLogo(size: 56.0),
                          title: Text(model.userName),
                          subtitle: Text(model.userEmail),
                          onTap: () {
                            connector.userInfo('me');
                            Navigator.pushNamed(context, '/UserInfo',
                                arguments: true);
                          },
                        ),
                        SizedBox(height: 15),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            primary: Theme.of(context).accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(
                                  color: Theme.of(context).accentColor,
                                  width: 2),
                            ),
                            minimumSize: Size(300, 60),
                          ),
                          child: Text(
                            'Загрузить файл',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/UploadFile');
                          },
                        ),
                        SizedBox(height: 15),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            primary: Theme.of(context).accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(
                                  color: Theme.of(context).accentColor,
                                  width: 2),
                            ),
                            minimumSize: Size(300, 60),
                          ),
                          child: Text(
                            'Файлы',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          onPressed: () {
                            connector.fileList();
                            Navigator.pushNamed(context, '/Files');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => model.switchTheme(),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(model.isLightTheme ? 'Светлая тема ' : 'Темная тема ', style: TextStyle(fontSize: 14),),
                          model.isLightTheme
                              ? Icon(
                                  Icons.brightness_1,
                                  color: Colors.yellow,
                                  size: 30,
                                )
                              : Icon(
                                  Icons.brightness_2,
                                  color: Theme.of(context).accentColor,
                                  size: 30,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
