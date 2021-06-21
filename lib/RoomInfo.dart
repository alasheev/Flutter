import 'package:flutter/material.dart';
import "package:scoped_model/scoped_model.dart";
import 'Connector.dart' as connector;
import "Model.dart" show FlutterChatModel, model;

class RoomInfo extends StatefulWidget {
  RoomInfo({Key key}) : super(key: key);
  @override
  _RoomInfo createState() => _RoomInfo();
}

class _RoomInfo extends State {
  List _users = [], _selectedUsers = [];

  bool _saved = false;

  @override
  void initState() {
    _users.add('Пользователи');
    for (int i = 0; i < model.userList.length; i++) {
      setState(() {
        _users.add(model.userList[i]['name']);
      });
    }
    for (int i = 0; i < model.currentRoomUsers.length; i++) {
      setState(() {
        _users.remove(model.currentRoomUsers[i]['name']);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Инфо: ' + model.currentRoomName),
        backgroundColor: Theme.of(context).accentColor,
      ),
      backgroundColor: model.isLightTheme ? Colors.white : Colors.grey[800],
      body: ScopedModel<FlutterChatModel>(
        model: model,
        child: ScopedModelDescendant<FlutterChatModel>(builder:
            (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Описание:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              model.currentRoomDescription == null
                  ? SizedBox()
                  : Container(
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
                        model.currentRoomDescription,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Создатель:',
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
                  model.currentRoomCreator == null
                      ? 'Неизвестен'
                      : model.currentRoomCreator['name'],
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Участники:',
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
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: model.currentRoomUsers.length,
                  itemBuilder: (context, inIndex) {
                    var user = model.currentRoomUsers[inIndex];
                    return GestureDetector(
                      onTap: () {
                        connector.userInfo(user['name']);
                        Navigator.pushNamed(context, '/UserInfo');
                      },
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child:
                            Text(user['name'], style: TextStyle(fontSize: 18)),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 15),
              (model.getRoom(model.currentRoomName)['private'])
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Пригласите участников в комнату',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          (_selectedUsers == null || _selectedUsers.length == 0)
                              ? SizedBox()
                              : Container(
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.only(top: 15),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context).accentColor,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: _selectedUsers.length,
                                    itemBuilder:
                                        (BuildContext inContext, int inIndex) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _selectedUsers[inIndex],
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          IconButton(
                                              icon: Icon(Icons.clear),
                                              onPressed: () {
                                                setState(() {
                                                  _selectedUsers.remove(
                                                      _selectedUsers[inIndex]);
                                                });
                                              })
                                        ],
                                      );
                                    },
                                  ),
                                ),
                          SizedBox(height: 15),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).accentColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: DropdownButton(
                                value: _users[0],
                                elevation: 0,
                                underline: SizedBox(),
                                icon: Icon(Icons.arrow_drop_down_circle),
                                iconSize: 40,
                                iconEnabledColor: Colors.white,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                                isExpanded: true,
                                dropdownColor: Theme.of(context).accentColor,
                                items: _users
                                    .map((item) => DropdownMenuItem<String>(
                                        child: Text(item), value: item))
                                    .toList(),
                                onChanged: (s) {
                                  setState(() {
                                    if (s != 'Пользователи' &&
                                        !_selectedUsers.contains(s)) {
                                      _selectedUsers.add(s);
                                    }
                                  });
                                }),
                          ),
                          SizedBox(height: 15),
                          (_selectedUsers != null && _selectedUsers.length != 0)
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).accentColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      side: BorderSide(
                                          color: Theme.of(context).accentColor,
                                          width: 2),
                                    ),
                                    minimumSize: Size(370, 60),
                                  ),
                                  child: Text(
                                    'Добавить',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  onPressed: () {
                                    connector.sendInvites(
                                        model.currentRoomName, _selectedUsers);
                                    setState(() {
                                      _selectedUsers.forEach((user) {
                                        model.currentRoomUsers
                                            .add({'name': user});
                                        _users.remove(user);
                                      });
                                      _selectedUsers.clear();
                                    });
                                  },
                                )
                              : SizedBox()
                        ],
                      ),
                    )
                  : SizedBox(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                          color: Theme.of(context).accentColor, width: 2),
                    ),
                    minimumSize: Size(300, 60),
                  ),
                  child: Text(
                    'Покинуть',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () {
                    connector.leaveRoom(model.currentRoomName);
                    model.leaveRoom(model.currentRoomName);
                    print('ливаю из ${model.currentRoomName}');
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        "/Lobby", ModalRoute.withName("/Lobby"));
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
