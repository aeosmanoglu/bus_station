import 'package:mongo_dart/mongo_dart.dart';

class Bus {
  final ObjectId id;
  final int plate;
  final String destination;
  final int where; // 0:onWay, 1:boarding, 2:left
  final int terminal;
  final bool isFull;

  Bus({this.id, this.plate, this.destination, this.where, this.terminal, this.isFull});
}

class User {
  final ObjectId id;
  final String image;
  final String name;
  final String userName;
  final String pass;
  final bool isAdmin;
  final bool isSuperAdmin;

  User({this.id, this.image, this.name, this.userName, this.pass, this.isAdmin, this.isSuperAdmin});
}
