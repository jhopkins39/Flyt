import 'package:myapp/services/authentication.dart';
import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';

class Provider extends InheritedWidget {
  final Auth auth;
  final db;

  Provider({Key key, Widget child, this.auth, this.db}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static Provider of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<Provider>());
}
