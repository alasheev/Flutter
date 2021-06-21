import 'package:flutter/material.dart';
import "package:scoped_model/scoped_model.dart";
import 'Connector.dart' as connector;
import "Model.dart" show FlutterChatModel, model;
import "AppDrawer.dart";

class Lobby extends StatelessWidget {
  Lobby({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    model.lobbyContext = context;
    model.rootBuildContext = model.lobbyContext;
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder:
            (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
          return Scaffold(
            drawer: AppDrawer(),
            appBar: AppBar(
              backgroundColor: Theme.of(context).accentColor,
              textTheme: Theme.of(context).appBarTheme.textTheme,
              title: Text(
                'Messenger',
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, "/CreateRoom");
              },
            ),
            backgroundColor:
                model.isLightTheme ? Colors.white : Colors.grey[800],
            body: model.roomList.isEmpty
                ? Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Не удалось найти ни одного чата',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: model.roomList.length,
                    itemBuilder: (BuildContext inContext, int inIndex) {
                      Map room = model.roomList[inIndex];
                      return GestureDetector(
                        onTap: () {
                          if (!room['private'] ||
                              model.myRooms.contains(room['name'])) {
                            connector.join(model.userName, room['name']);
                            model.currentRoomName = room['name'];
                            if (!model.myRooms.contains(room['name'])) {
                              model.addMyRoom(room['name']);
                            }
                            connector.roomInfo(room['name']);
                            Navigator.pushNamed(context, "/Room");
                          } else {
                            model.snack(
                                'У Вас нет доступа к комнате', 3, 'red');
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 7, right: 7, top: 10),
                          child: Container(
                            height: 180,
                            decoration: new BoxDecoration(
                              color: Theme.of(context).accentColor,
                              // color: model.setColor(room['name']),
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(15)),
                              boxShadow: [
                                BoxShadow(
                                  color: model.isLightTheme
                                      ? Colors.grey[700]
                                      : Colors.black,
                                  offset: Offset(1.0, 1.5), //(x,y)
                                  blurRadius: 16.0,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        room['name'],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 30),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Icon(
                                        model.myRooms.contains(room['name'])
                                            ? Icons.check
                                            : room['private'] == true
                                                ? Icons.lock
                                                : Icons.lock_open,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    room['description'],
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  (room['messages'] == null ||
                                          room['messages'].isEmpty ||
                                          !model.myRooms.contains(room['name']))
                                      ? SizedBox()
                                      : Text(
                                          '${room['messages'].last['user']}: ${room['messages'].last['message']}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
          );
        },
      ),
    );
  }

//   ListView buildListView(BuildContext context) {
//     return ListView.builder(
//         itemCount: model.roomList.length,
//         itemBuilder: (BuildContext inContext, int inIndex) {
//           Map room = model.roomList[inIndex];
//           print(
//               'ласт ${room['messages'].last['user']}: ${room['messages'].last['message']}');
//           return GestureDetector(
//             onTap: () {
//               if (room['users'].length < room['max'] ||
//                   room['imHere'] == true) {
//                 model.currentRoomName = room['name'];
//                 Navigator.pushNamed(context, "/Room");
//                 if (room['imHere'] != true) {
//                   connector.join(model.userName, room['name']);
//                   room['imHere'] = true;
//                 }
//               } else {
//                 ScaffoldMessenger.of(inContext).showSnackBar(
//                   SnackBar(
//                     backgroundColor: Colors.red,
//                     duration: Duration(seconds: 2),
//                     content: Text("Комната заполнена"),
//                   ),
//                 );
//               }
//             },
//             child: Padding(
//               padding: EdgeInsets.all(15),
//               child: Container(
//                 height: 150,
//                 decoration: new BoxDecoration(
//                   color: model.setColor(room['name']),
//                   borderRadius: new BorderRadius.all(Radius.circular(15)),
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(10),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         room['name'],
//                         style: TextStyle(color: Colors.white, fontSize: 30),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       Text(
//                         room['description'],
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       Text(
//                         '${room['messages'].last['user']}: ${room['messages'].last['message']}',
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.person,
//                             color: room['users'].length >= room['max']
//                                 ? Colors.red
//                                 : Colors.white,
//                             size: 16,
//                           ),
//                           Text(
//                             room['users'].length.toString() + '/',
//                             style: TextStyle(color: Colors.white, fontSize: 15),
//                           ),
//                           Text(
//                             room['max'].toString(),
//                             style: TextStyle(color: Colors.white, fontSize: 15),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         });
//   }

}
