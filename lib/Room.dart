import 'dart:async';

import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import 'Model.dart';
import 'Connector.dart' as connector;

class Room extends StatefulWidget {
  Room({Key key}) : super(key: key);
  @override
  _Room createState() => _Room();
}

class _Room extends State {
  String _postMessage;

  /// Controller for the message list ListView.
  final ScrollController _controller = ScrollController();

  /// Controller for post TextFields
  final TextEditingController _postEditingController = TextEditingController();

  Future<bool> willPopCallback() async {
    model.rootBuildContext = model.lobbyContext;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    model.rootBuildContext = context;
    model.controller = _controller;
    var _room = model.getRoom(model.currentRoomName);

    Timer(
      Duration(milliseconds: 350),
      () {
        _controller.animateTo(_controller.position.maxScrollExtent,
            duration: Duration(milliseconds: 200), curve: Curves.linear);
      },
    );

    return WillPopScope(
      onWillPop: () => willPopCallback(),
      child: ScopedModel<FlutterChatModel>(
        model: model,
        child: ScopedModelDescendant<FlutterChatModel>(
          builder: (BuildContext inContext, Widget inChild,
              FlutterChatModel inModel) {
            return Scaffold(
              backgroundColor:
                  model.isLightTheme ? Colors.white : Colors.grey[800],
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: Theme.of(context).accentColor,
                title: GestureDetector(
                  child: Text(
                    _room['name'],
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, "/RoomInfo");
                  },
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(2.5),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: _controller,
                        itemCount: _room['messages'].length,
                        itemBuilder: (inContext, inIndex) {
                          Map message = _room['messages'][inIndex];
                          return Padding(
                            padding: EdgeInsets.all(5),
                            child: Align(
                              alignment:
                                  message['user_id'] == model.userSocketId
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                    minWidth: 100, maxWidth: 200),
                                decoration: new BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius:
                                      new BorderRadius.all(Radius.circular(15)),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(top: 5, bottom: 5),
                                        child: Text(
                                          message['message'],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      message['user_id'] != model.userSocketId
                                          ? Column(
                                              children: [
                                                Text(
                                                  "${message['user']}",
                                                  style: TextStyle(
                                                    color: Colors.indigo[800],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : SizedBox(),
                                      Text(
                                        "${message['time']}",
                                        style: TextStyle(
                                          color: Colors.indigo[800],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: model.isLightTheme
                              ? Theme.of(context).accentColor
                              : Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(42),
                        ),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        children: [
                          Flexible(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              cursorColor: model.isLightTheme
                                  ? Theme.of(context).accentColor
                                  : Colors.white,
                              minLines: 1,
                              maxLines: 4,
                              controller: _postEditingController,
                              onChanged: (String inText) => setState(() {
                                _postMessage = inText;
                              }),
                              onTap: () {
                                Timer(
                                  Duration(milliseconds: 150),
                                  () {
                                    _controller.animateTo(
                                        _controller.position.maxScrollExtent,
                                        duration: Duration(milliseconds: 200),
                                        curve: Curves.linear);
                                  },
                                );
                              },
                              decoration: InputDecoration.collapsed(
                                  hintText: "Введите сообщение"),
                            ),
                          )),
                          Container(
                            margin: new EdgeInsets.fromLTRB(2, 0, 2, 0),
                            child: IconButton(
                              icon: Icon(
                                Icons.send_sharp,
                                size: 30,
                                color: model.isLightTheme
                                    ? Theme.of(context).accentColor
                                    : Colors.white,
                              ),
                              color: Theme.of(context).accentColor,
                              onPressed: () {
                                if (_postMessage.isNotEmpty) {
                                  DateTime _now = DateTime.now();
                                  var minute = _now.minute >= 10
                                      ? _now.minute
                                      : '0${_now.minute}';
                                  model.addMessage(
                                      model.userName,
                                      model.userSocketId,
                                      _room['name'],
                                      _postMessage,
                                      '${_now.hour}:$minute');

                                  connector.newMessage(_postMessage,
                                      _room['name'], '${_now.hour}:$minute');
                                      
                                  _postEditingController.clear();
                                  _postMessage = '';
                                  _controller.jumpTo(
                                      _controller.position.maxScrollExtent);
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
