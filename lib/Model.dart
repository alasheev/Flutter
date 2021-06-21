import 'dart:async';
import "dart:io";
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import 'dart:math';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:path_provider/path_provider.dart';

class FlutterChatModel extends Model {
  bool isLightTheme = true;

  void switchTheme() {
    isLightTheme = !isLightTheme;
    setTheme();
    notifyListeners();
  }

  ThemeData setTheme() {
    if (isLightTheme) {
      return FlexColorScheme.light(
        colors: FlexColor.schemes[FlexScheme.brandBlue].light,
      ).toTheme;
    } else {
      return FlexColorScheme.dark(
        colors: FlexColor.schemes[FlexScheme.brandBlue].light,
      ).toTheme;
    }
  }

  ScaffoldMessengerState scaffoldMessenger;

  BuildContext rootBuildContext;

  BuildContext lobbyContext;

  ScrollController controller;

  String token;

  String userSocketId;

  String userName;

  String userEmail;

  String userPhone;

  String currentRoomName;

  Map currentUser;

  String currentRoomDescription;

  Map currentRoomCreator;

  List currentRoomUsers = [];

  bool currentRoomEnabled = false;

  List currentRoomMessages = [];

  List roomList = [];

  List userList = [];

  List fileList = [];

  List matchFileList = [];

  bool creatorFunctionsEnabled = false;

  Map roomInvites = {};

  List myRooms = [];

  bool isFileUploading = false;

  String fileName;

  int fileChunks;

  int uploadedChunks = 1;

  void setMyRooms(rooms) {
    for (int i = 0; i < rooms.length; i++) {
      myRooms.add(rooms[i]['room_name']);
    }
    notifyListeners();
  }

  void addMyRoom(room) {
    myRooms.add(room);
    notifyListeners();
  }

  void leaveRoom(name) {
    print(myRooms);
    myRooms.remove(name);
    print(myRooms);
    final _room = getRoom(model.currentRoomName);
    _room['messages'] = [];
    notifyListeners();
  }

  void setUserInfo(user) {
    currentUser = user;
    notifyListeners();
  }

  void fileUploading(String name, String extension, int chunks) {
    fileName = name + '.' + extension;
    isFileUploading = true;
    fileChunks = chunks;
    notifyListeners();
  }

  void updateUploading() {
    uploadedChunks++;
    notifyListeners();
  }

  void endUploading() {
    isFileUploading = false;
    fileName = null;
    fileChunks = 0;
    uploadedChunks = 1;
    notifyListeners();
  }

  Color setColor(String roomname) {
    var room = getRoom(roomname);
    if (room['color'] != null) {
      return room['color'];
    }
    var random = Random();
    int X = random.nextInt(8);
    Color color;
    switch (X) {
      case 0:
        color = Colors.blue;
        break;
      case 1:
        color = Colors.amber;
        break;
      case 2:
        color = Colors.cyan;
        break;
      case 3:
        color = Colors.deepOrange;
        break;
      case 4:
        color = Colors.deepPurple[300];
        break;
      case 5:
        color = Colors.greenAccent[700];
        break;
      case 6:
        color = Colors.red;
        break;
      case 7:
        color = Colors.yellow[800];
        break;
    }
    room['color'] = color;
    notifyListeners();
    return room['color'];
  }

  void setUserName(final String inUserName) {
    userName = inUserName;
    notifyListeners();
  }

  void setCurrentRoomName(final String inRoomName) {
    currentRoomName = inRoomName;
    notifyListeners();
  }

  void setCreatorFunctionsEnabled(final bool inEnabled) {
    creatorFunctionsEnabled = inEnabled;
    notifyListeners();
  }

  void setCurrentRoomEnabled(final bool inEnabled) {
    currentRoomEnabled = inEnabled;
    notifyListeners();
  }

  dynamic getRoom(String name) {
    var _room;
    for (int i = 0; i < roomList.length; i++) {
      if (roomList[i]['name'] == name) {
        _room = roomList[i];
        return _room;
      }
    }
    return null;
  }

  dynamic getUser(String name) {
    var _user;
    for (int i = 0; i < userList.length; i++) {
      if (userList[i]['name'] == name) {
        _user = userList[i];
        return _user;
      }
    }
    return null;
  }

  void addMessage(
      String user, String user_id, String room, String message, String time) {
    var _room = getRoom(room);
    if (_room['messages'] == null) {
      _room['messages'] = [];
    }
    _room['messages'].add(
        {"user": user, 'user_id': user_id, "message": message, "time": time});
    Timer(
      Duration(milliseconds: 350),
      () {
        controller.animateTo(controller.position.maxScrollExtent,
            duration: Duration(milliseconds: 200), curve: Curves.linear);
      },
    );
    notifyListeners();
  }

  void setMessages(String room, List messages) {
    print('room $room');
    var _room = getRoom(room);
    _room['messages'] = messages;
    notifyListeners();
  }

  void newRoom(Map inRoom) {
    roomList.add(inRoom);
    notifyListeners();
  }

  void setRoomList(List inRoomList) {
    roomList = inRoomList;
    roomList.forEach((room) {
      room['messages'] = [];
    });
    notifyListeners();
  }

  // void setMyRooms(List inRoomList) {
  //   inRoomList.forEach((room) {
  //     var _room = getRoom(room['name']);
  //     _room['iamhere'] = true;
  //   });
  //   notifyListeners();
  // }

  void setRoomUserList(Map inData) {
    var room = getRoom(inData['room']);
    room['users'] = inData['users'];
    notifyListeners();
  }

  void setUserList(inData) {
    userList = inData;
    notifyListeners();
  }

  void setFileList(List files) async {
    model.fileList = [];

    for (int i = 0; i < files.length; i++) {
      var pieces = files[i].split('&&&&&');
      bool exists = await isFileExists(pieces.first);
      model.fileList.add(
          {'name': pieces.first, 'description': pieces.last, 'exists': exists});
    }
    notifyListeners();
  }

  void newFile(file) async {
    var pieces = file.split('&&&&&');
    bool exists = await isFileExists(pieces.first);
    model.fileList.add(
        {'name': pieces.first, 'description': pieces.last, 'exists': exists});
    notifyListeners();
  }

  void setFile(String name) {
    for (int i = 0; i < model.fileList.length; i++) {
      if (model.fileList[i]['name'] == name) {
        model.fileList[i]['exists'] = true;
        notifyListeners();
        break;
      }
    }
  }

  void setCurrentRoomUserList(List inUserList) {
    currentRoomUsers = inUserList;
    notifyListeners();
  }

  void addRoomInvite(final String inRoomName) {
    roomInvites[inRoomName] = true;
  }

  void removeRoomInvite(final String inRoomName) {
    roomInvites.remove(inRoomName);
  }

  void clearCurrentRoomMessages() {
    currentRoomMessages = [];
  }

  void snack(String msg, int duration, [String color = 'green']) {
    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color == 'red' ? Colors.red : Colors.green,
          duration: Duration(seconds: duration),
          content: Text(msg),
        ),
      );
  }

  Future<String> getDownloadsPath() async {
    final dirList =
        await getExternalStorageDirectories(type: StorageDirectory.downloads);
    return dirList[0].path;
  }

  Future<bool> isFileExists(String name) async {
    final path = await getDownloadsPath();
    final file = File('$path/$name');
    if (file.existsSync()) {
      return true;
    } else {
      return false;
    }
  }
}

FlutterChatModel model = FlutterChatModel();
