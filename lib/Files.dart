import "package:flutter/material.dart";
import 'package:scoped_model/scoped_model.dart';
import "Model.dart" show FlutterChatModel, model;
import 'Connector.dart' as connector;

class Files extends StatefulWidget {
  Files({Key key}) : super(key: key);
  @override
  _Files createState() => _Files();
}

class _Files extends State {
  var files;

  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";

  @override
  void initState() {
    files = model.fileList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder:
            (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
          return Scaffold(
            backgroundColor: model.isLightTheme? Colors.white: Colors.grey[800],
            appBar: AppBar(
              backgroundColor: Theme.of(context).accentColor,
              textTheme: Theme.of(context).appBarTheme.textTheme,
              leading: BackButton(),
              title: _isSearching ? _buildSearchField() : Text('Файлы'),
              actions: _buildActions(),
            ),
            body: Padding(
              padding: EdgeInsets.all(10),
              child: model.fileList.isEmpty
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Не удалось найти ни одного файла',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    )
                  : _isSearching ? ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: files.length,
                      itemBuilder: (BuildContext inContext, int inIndex) {
                        print('Файлычи $files');
                        var file = files[inIndex];
                        return ListTile(
                          onTap: () {
                            connector.downloadFile(file['name']);
                          },
                          leading: file['exists']
                              ? Icon(
                                  Icons.save,
                                  color: Theme.of(context).accentColor,
                                )
                              : Icon(Icons.file_download),
                          title: Text(file['name']),
                          subtitle: Text(file['description']),
                        );
                      },
                    ): ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: model.fileList.length,
                      itemBuilder: (BuildContext inContext, int inIndex) {
                        print('Файлычи $files');
                        var file = model.fileList[inIndex];
                        return ListTile(
                          onTap: () {
                            connector.downloadFile(file['name']);
                          },
                          leading: file['exists']
                              ? Icon(
                                  Icons.save,
                                  color: Theme.of(context).accentColor,
                                )
                              : Icon(Icons.file_download),
                          title: Text(file['name']),
                          subtitle: Text(file['description']),
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Имя или описание',
        hintStyle: TextStyle(color: Colors.white54),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    var _files = [];
    print(newQuery);
    for (int i = 0; i < model.fileList.length; i++) {
      if (model.fileList[i]['name'].indexOf(newQuery) != -1 ||
          model.fileList[i]['description'].indexOf(newQuery) != -1) {
        if (!_files.contains(model.fileList[i])) {
          _files.add(model.fileList[i]);
        }
      }
    }
    setState(() {
      files = _files;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }
}
