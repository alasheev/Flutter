import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;
import "Model.dart" show model;

// String serverURL = "http://192.168.1.66:8000";
String serverURL = "http://serene-forest-01113.herokuapp.com";
// The one and only SocketIO instance.
Socket socket;

void connectToServer(Function callBack) {
  var isCalled = false;
  if (socket == null) {
    socket = io(serverURL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnect': true,
      'query': 'token=' + model.token
    });
    socket.connect();

    socket.onConnectError((data) => print('ConnectError $data'));

    socket.onConnect((_) {
      if (isCalled == false) {
        isCalled = true;
        callBack();
      }
      print('Подключился. Сокет: ${socket.id}');
    });

    socket.onReconnect((_) {
      model.snack('Соединение восстановлено', 1);
      join(model.userName, model.currentRoomName);
    });

    socket.onReconnectFailed((data) {
      model.snack('Не удалось переподключиться', 3);
    });

    socket.on('aboutMe', (inData) {
      print('on aboutMe: $inData');
      model.userSocketId = inData['_id'];
      model.userName = inData['name'];
      model.userEmail = inData['email'];
      model.userPhone = inData['phone'];
      print('мои комнатке ${inData['rooms']}');
      model.setMyRooms(inData['rooms']);
    });

    socket.on('invite', (inData) {
      print('мня пригласили в $inData');
      model.addMyRoom(inData);
    });

    socket.on('message', (inData) {
      print('on message: $inData');
      print('from ${inData['room_name']}');
      model.addMessage(inData['user'], inData['user_id'], inData['room_name'],
          inData['message'], inData['time']);
      print(inData);
    });

    socket.on('roomList', (inData) {
      print('on roomList: $inData');
      model.setRoomList(inData);
    });

    socket.on('roomUsers', (inData) {
      print('on roomUsers: $inData');
      model.setRoomUserList(inData);
    });

    socket.on('newRoom', (inData) {
      print('on newRoom: $inData');
      model.newRoom(inData);
    });

    socket.on('roomMessages', (inData) {
      print('on roomMessages: $inData');
      model.setMessages(inData['room'], inData['messages']);
    });

    socket.on('roomInfo', (inData) {
      model.currentRoomDescription = inData['description'];
      model.currentRoomCreator = inData['creator'];
      model.setCurrentRoomUserList(inData['users']);
    });

    socket.on('userList', (inData) {
      if (inData != null) {
        print(inData);
        model.setUserList(inData);
      }
    });

    socket.on('fileReceived', (inData) {
      if (inData == 'OK') {
        model.snack('Файл загружен на сервер', 2);
      } else {
        model.snack('Не удалось загрузить файл', 2, 'red');
      }
    });

    socket.on('newFile', (inData) {
      model.newFile(inData);
    });

    socket.onDisconnect((data) {
      model.snack('Соединение было разорвано', 3, 'red');
    });
  }
}

Future<String> login(user) async {
  String url = 'http://serene-forest-01113.herokuapp.com/user/login';
  // String url = 'http://192.168.1.66:8000/user/login';
  showPleaseWait();
  try {
    var res = await http.post(Uri.parse(url), body: user, headers: {
      "Access-Control-Allow-Origin": "*",
    });
    final body = jsonDecode(res.body);

    model.token = body['token'];
    hidePleaseWait();
    return body['message'];
  } catch (e) {
    return 'Нет соединения с сервером';
  }
}

Future<String> register(user) async {
  final url = 'http://serene-forest-01113.herokuapp.com/user/register';
  // final url = 'http://192.168.1.66:8000/user/register';
  try {
    var res = await http.post(
      Uri.parse(url),
      body: user,
    );

    final body = jsonDecode(res.body);

    return body['message'];
  } on SocketException {
    return 'Нет соединения с сервером';
  } on HttpException {
    return 'Нет соединения с сервером';
  } on ClientException {
    return 'Нет соединения с сервером';
  }
}

void join(final String inUserName, final String inRoomName) {
  socket.emit("joinRoom", {'username': inUserName, 'room': inRoomName});
} /* End join(). */

void newMessage(final String inMessage, String inRoom, String time) {
  socket.emitWithAck("chatMessage", {
    'message': inMessage,
    'room': inRoom,
    'time': time,
  }, ack: (data) {
    if (data == 'fail') {
      model.snack('Сообщение не было доставлено', 2);
    }
  });
}

void getUserList() {
  socket.emit('userList');
}

void roomInfo(String room) {
  socket.emit('roomInfo', {'room': room});
}

void userInfo(String name) {
  socket.emitWithAck('userInfo', {'name': name}, ack: (data) {
    model.setUserInfo(data);
  });
}

void leaveRoom(String room) {
  socket.emit('leaveRoom', {'room': room});
}

void sendInvites(String room, List users) {
  socket.emit('sendInvites', {'room': room, 'users': users});
}

void newRoom(String name, description, bool private, List users) {
  showPleaseWait();
  print(private);
  socket.emitWithAck('newRoom', {
    'name': name,
    'description': description,
    'private': private,
    'users': users
  }, ack: (data) {
    if (data == 'fail') {
      model.snack('Не удалось создать комнату', 2, 'red');
      hidePleaseWait();
    } else if (data == 'OK') {
      model.snack('Комната создана', 2);
      model.addMyRoom(name);
      hidePleaseWait();
    }
  });
}

void sendFile(fileObject) async {
  File file = fileObject['file'];
  String description = fileObject['description'];
  List rooms = fileObject['availableIn'];
  bool isPublic = fileObject['public'];

  final fullName = file.path.split('/').last;
  final name = fullName.split('.').first;
  final extension = fullName.split('.').last;

  final bytes = await file.readAsBytes();

  final byteChunks = [];
  // int chunkSize = 512000; //500kb
  // int chunkSize = 102400; //100kb
  int chunkSize = 10240; //10kb
  for (int i = 0; i < bytes.length; i += chunkSize) {
    if ((i + chunkSize) >= bytes.length) {
      byteChunks.add(bytes.sublist(i));
    } else {
      byteChunks.add(bytes.sublist(i, i + chunkSize));
    }
  }
  socket.emitWithAck('sendShreddedFile', {
    'name': name,
    'size': bytes.length,
    'extension': extension,
    'description': description,
    'public': isPublic,
    'availableIn': rooms
  }, ack: (data) async {
    print(byteChunks.length);
    model.fileUploading(name, extension, byteChunks.length);
    Timer.periodic(new Duration(milliseconds: 90), (timer) {
      int i = timer.tick - 1;
      if (i < byteChunks.length - 1) {
        model.updateUploading();
        socket.emitWithBinary(
            'sendFileSchunk', {'name': data, 'chunk': byteChunks[i]});
        print(timer.tick - 1);
      } else {
        socket.emitWithBinary(
            'sendFileSchunk', {'name': data, 'chunk': byteChunks[i]});
        print(timer.tick - 1);
        model.endUploading();
        timer.cancel();
      }
    });
  });
}
// void sendFile(File file, String description, List rooms,
//     [bool isPublic = false]) async {
//   final fullName = file.path.split('/').last;
//   final name = fullName.split('.').first;
//   final extension = fullName.split('.').last;

//   final bytes = await file.readAsBytes();
//   if (bytes.length > 1048576) {
//     final byteChunks = [];
//     for (int i = 0; i < 10; i++) {
//       if (i == 9) {
//         byteChunks.add(bytes.sublist(i * (bytes.length ~/ 10)));
//       } else {
//         byteChunks.add(bytes.sublist(
//             i * (bytes.length ~/ 10), (i + 1) * (bytes.length ~/ 10)));
//       }
//     }
//     socket.emitWithAck('sendShreddedFile', {
//       'name': name,
//       'extension': extension,
//       'description': description,
//       'public': isPublic,
//       'availableIn': rooms
//     }, ack: (data) async {
//       for (int i = 0; i < 10; i++) {
//         socket.emitWithAck(
//             'sendFileSchunk', {'name': data, 'chunk': byteChunks[i]},
//             ack: (data) {});
//       }
//     });
//   } else {
//     model.snack('Загрузка файла на сервер...', 3);
//     socket.emit('sendFile', {
//       'fileBytes': bytes,
//       'name': name,
//       'extension': extension,
//       'description': description,
//       'public': isPublic,
//       'availableIn': rooms
//     });
//   }
// }

void fileList() {
  socket.emitWithAck('fileList', null, ack: (data) {
    print(data);
    if (data != null) {
      model.setFileList(List.from(data));
    }
  });
}

void downloadFile(String name) async {
  final path = await model.getDownloadsPath();
  print(path);
  final file = File('$path/$name');
  if (file.existsSync()) {
    OpenFile.open('$path/$name');
  } else {
    model.snack('Загрузка файла...', 1);
    socket.emitWithAck('downloadFile', {'name': name}, ack: (data) async {
      if (data.runtimeType == String) {
        model.snack('Ошибка: возможно файл бы удалён с сервера', 3, 'red');
      } else {
        file.writeAsBytes(data, flush: true);
        model.setFile(name);
        model.snack('Файл сохранён: /Downloads/$name', 3);
      }
    });
  }
}

void showPleaseWait() {
  showDialog(
      context: model.rootBuildContext,
      barrierDismissible: false,
      builder: (BuildContext inDialogContext) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            width: 150,
            height: 150,
            alignment: AlignmentDirectional.center,
            child: Center(
                child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                        value: null, strokeWidth: 10))),
          ),
        );
      });
}

void hidePleaseWait() {
  Navigator.of(model.rootBuildContext).pop();
}
