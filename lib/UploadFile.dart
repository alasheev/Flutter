import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:scoped_model/scoped_model.dart';

import 'Connector.dart' as connector;
import "Model.dart" show FlutterChatModel, model;

class UploadFile extends StatefulWidget {
  UploadFile({Key key}) : super(key: key);
  @override
  _UploadFile createState() => _UploadFile();
}

class _UploadFile extends State {
  bool _isFilePicked;
  String _fileName, _fileDescription;
  List _selectedRooms = [];
  File _file;
  List _rooms = [];
  bool _public = false;

  final TextEditingController _descController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _isFilePicked = false;
    _rooms.add('Группы');
    for (int i = 0; i < model.myRooms.length; i++) {
      if (!_rooms.contains(model.myRooms[i])) {
        _rooms.add(model.myRooms[i]);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: model.isLightTheme ? Colors.white : Colors.grey[800],
        appBar: AppBar(
          backgroundColor: Theme.of(context).accentColor,
          textTheme: Theme.of(context).appBarTheme.textTheme,
          title: Text(
            'Загрузка файла',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    children: [
                      Text(
                        _isFilePicked ? _fileName : 'Выберите файл',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
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
                          'Выбрать файл',
                          style: TextStyle(fontSize: 18),
                        ),
                        onPressed: () async {
                          FilePickerResult result =
                              await FilePicker.platform.pickFiles();

                          if (result != null) {
                            _file = File(result.files.single.path);
                            setState(() {
                              _isFilePicked = true;
                              _fileName = result.files.single.name;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _descController,
                        cursorColor: model.isLightTheme? Theme.of(context).accentColor: Colors.white,
                        decoration: InputDecoration(
                          fillColor: model.isLightTheme? Colors.white: Colors.grey[800],
                          labelStyle: TextStyle(color: model.isLightTheme? Theme.of(context).accentColor: Colors.white),
                          labelText: 'Описание',
                          prefixIcon: Icon(
                            Icons.description,
                            color: model.isLightTheme? Theme.of(context).accentColor: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            color: model.isLightTheme? Theme.of(context).accentColor: Colors.white,
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              _descController.text = '';
                            },
                          ),
                          enabledBorder: myBorder(context),
                          focusedBorder: myBorder(context),
                          errorBorder: myBorder(context),
                          focusedErrorBorder: myBorder(context),
                        ),
                        onSaved: (String inValue) {
                          setState(() {
                            _fileDescription = inValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value == '') {
                            return ('Описание обязательно');
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      SizedBox(height: 15),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Публичный     ",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Switch(
                              value: _public,
                              onChanged: (inValue) {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _public = inValue;
                                });
                              },
                              activeColor: Colors.greenAccent[700],
                            )
                          ],
                        ),
                      ),
                      !_public
                          ? Column(
                              children: [
                                Text(
                                  'Выберите группы, у которых будет доступ к файлу',
                                  style: TextStyle(fontSize: 20),
                                ),
                                (_selectedRooms == null ||
                                        _selectedRooms.length == 0)
                                    ? SizedBox()
                                    : Container(
                                        padding: EdgeInsets.all(10),
                                        margin: EdgeInsets.only(top: 15),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                Theme.of(context).accentColor,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          itemCount: _selectedRooms.length,
                                          itemBuilder: (BuildContext inContext,
                                              int inIndex) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  _selectedRooms[inIndex],
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                IconButton(
                                                    icon: Icon(Icons.clear),
                                                    onPressed: () {
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                      setState(() {
                                                        _selectedRooms.remove(
                                                            _selectedRooms[
                                                                inIndex]);
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
                                      value: _rooms[0],
                                      elevation: 0,
                                      underline: SizedBox(),
                                      icon: Icon(Icons.arrow_drop_down_circle),
                                      iconSize: 40,
                                      iconEnabledColor: Colors.white,
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      isExpanded: true,
                                      dropdownColor:
                                          Theme.of(context).accentColor,
                                      items: _rooms
                                          .map((item) =>
                                              DropdownMenuItem<String>(
                                                  child: Text(item),
                                                  value: item))
                                          .toList(),
                                      onTap: () => FocusManager
                                          .instance.primaryFocus
                                          ?.unfocus(),
                                      onChanged: (s) {
                                        setState(() {
                                          if (s != 'Группы' &&
                                              !_selectedRooms.contains(s)) {
                                            _selectedRooms.add(s);
                                          }
                                        });
                                      }),
                                ),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(height: 15),
                      ElevatedButton(
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
                          'Загрузить файл',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (!_isFilePicked) {
                            model.snack('Выберите файл', 2, 'red');
                            return;
                          }
                          if (!_formKey.currentState.validate()) {
                            return;
                          }
                          if (_selectedRooms.length == 0 && !_public) {
                            model.snack('Выберите группы', 2, 'red');
                            return;
                          }
                          _formKey.currentState.save();
                          var rooms = [];
                          _selectedRooms.forEach((selectedRoom) {
                            var _room = model.getRoom(selectedRoom);
                            if (_room != null) {
                              rooms.add({
                                'room_id': _room['_id'],
                                'room_name': _room['name']
                              });
                            }
                          });
                          connector.sendFile({
                            'file': _file,
                            'description': _fileDescription,
                            'availableIn': rooms,
                            'public': _public
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              ScopedModel<FlutterChatModel>(
                model: model,
                child: ScopedModelDescendant<FlutterChatModel>(builder:
                    (BuildContext inContext, Widget inChild,
                        FlutterChatModel inModel) {
                  return model.isFileUploading
                      ? Column(
                          children: [
                            Text('Загрузка ${model.fileName}'),
                            LinearProgressIndicator(
                              value: model.uploadedChunks / model.fileChunks,
                            ),
                          ],
                        )
                      : SizedBox();
                }),
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
      color: model.isLightTheme? Theme.of(context).accentColor: Colors.white,
      width: 2,
    ),
  );
}
