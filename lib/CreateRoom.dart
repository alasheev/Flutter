import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "Model.dart" show FlutterChatModel, model;
import "Connector.dart" as connector;

class CreateRoom extends StatefulWidget {
  CreateRoom({Key key}) : super(key: key);
  @override
  _CreateRoom createState() => _CreateRoom();
}

class _CreateRoom extends State {
  String _name;
  String _description;
  bool _private = false;

  List _users = [], _selectedUsers = [];

  final TextEditingController _nameController = TextEditingController(),
      _descController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _users.add('Добавить');
    for (int i = 0; i < model.userList.length; i++) {
      _users.add(model.userList[i]['name']);
    }
    super.initState();
  }

  Widget build(final BuildContext inContext) {
    // _users = model.userList;
    model.rootBuildContext = context;
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder:
            (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              // resizeToAvoidBottomInset : false, // Avoid problem of keyboard causing form fields to vanish.
              appBar: AppBar(
                title: Text('Создание комнаты'),
                backgroundColor: Theme.of(context).accentColor,
              ),
              backgroundColor:
                  model.isLightTheme ? Colors.white : Colors.grey[800],
              body: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextFormField(
                        cursorColor: model.isLightTheme
                            ? Theme.of(context).accentColor
                            : Colors.white,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        controller: _nameController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          fillColor: model.isLightTheme
                              ? Colors.white
                              : Colors.grey[800],
                          labelStyle: TextStyle(
                              color: model.isLightTheme
                                  ? Theme.of(context).accentColor
                                  : Colors.white),
                          labelText: 'Название',
                          prefixIcon: Icon(
                            Icons.subject,
                            color: model.isLightTheme
                                ? Theme.of(context).accentColor
                                : Colors.white,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: model.isLightTheme
                                  ? Theme.of(context).accentColor
                                  : Colors.white,
                            ),
                            onPressed: () {
                              _nameController.clear();
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
                        validator: (value) {
                          if (value.length == 0) {
                            return 'Поле не должно быть пустым';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        maxLines: 3,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        controller: _descController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: model.isLightTheme
                            ? Theme.of(context).accentColor
                            : Colors.white,
                        decoration: InputDecoration(
                          fillColor: model.isLightTheme
                              ? Colors.white
                              : Colors.grey[800],
                          labelStyle: TextStyle(
                              color: model.isLightTheme
                                  ? Theme.of(context).accentColor
                                  : Colors.white),
                          labelText: 'Описание',
                          prefixIcon: Icon(
                            Icons.description,
                            color: model.isLightTheme
                                ? Theme.of(context).accentColor
                                : Colors.white,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: model.isLightTheme
                                  ? Theme.of(context).accentColor
                                  : Colors.white,
                            ),
                            onPressed: () {
                              _descController.clear();
                            },
                          ),
                          enabledBorder: myBorder(context),
                          focusedBorder: myBorder(context),
                          errorBorder: myBorder(context),
                          focusedErrorBorder: myBorder(context),
                        ),
                        onSaved: (String inValue) {
                          setState(() {
                            _description = inValue;
                          });
                        },
                        validator: (value) {
                          if (value.length == 0) {
                            return 'Поле не должно быть пустым';
                          }
                          return null;
                        },
                      ),
                      ListTile(
                        title: Row(
                          children: [
                            Text(
                              "Закрытая     ",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Switch(
                              value: _private,
                              onChanged: (inValue) {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _private = inValue;
                                });
                              },
                              activeColor: Theme.of(context).accentColor,
                            )
                          ],
                        ),
                      ),
                      _private
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Пригласите участников в комнату',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                (_selectedUsers == null ||
                                        _selectedUsers.length == 0)
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
                                          itemCount: _selectedUsers.length,
                                          itemBuilder: (BuildContext inContext,
                                              int inIndex) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  _selectedUsers[inIndex],
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                ),
                                                IconButton(
                                                    icon: Icon(Icons.clear),
                                                    onPressed: () {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      setState(() {
                                                        _selectedUsers.remove(
                                                            _selectedUsers[
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
                                      value: _users[0],
                                      elevation: 0,
                                      underline: SizedBox(),
                                      icon: Icon(Icons.arrow_drop_down_circle),
                                      iconSize: 40,
                                      iconEnabledColor: Colors.white,
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                      isExpanded: true,
                                      dropdownColor:
                                          Theme.of(context).accentColor,
                                      items: _users
                                          .map((item) =>
                                              DropdownMenuItem<String>(
                                                  child: Text(item),
                                                  value: item))
                                          .toList(),
                                      onTap: () =>
                                          FocusScope.of(context).unfocus(),
                                      onChanged: (s) {
                                        setState(() {
                                          if (s != 'Добавить' &&
                                              !_selectedUsers.contains(s)) {
                                            _selectedUsers.add(s);
                                          }
                                        });
                                      }),
                                ),
                                SizedBox(height: 15),
                              ],
                            )
                          : SizedBox(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(
                              color: Theme.of(context).accentColor,
                              width: 2,
                            ),
                          ),
                          minimumSize: Size(100, 60),
                        ),
                        child: Text(
                          'Отправить',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if (!_formKey.currentState.validate()) {
                            return;
                          }
                          _formKey.currentState.save();
                          var users = [];
                          _selectedUsers.forEach((selectedUser) {
                            var _user = model.getUser(selectedUser);
                            if (_user != null) {
                              users.add(_user['_id']);
                            }
                          });
                          connector.newRoom(
                              _name, _description, _private, users);
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
      color: model.isLightTheme ? Theme.of(context).accentColor : Colors.white,
      width: 2,
    ),
  );
}
