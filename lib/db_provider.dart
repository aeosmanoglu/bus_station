import 'package:mongo_dart/mongo_dart.dart';

class BusDBProvider {
  Db db = Db('mongodb://localhost:27017/local');
  String collection = "bus";

  getAll() async {
    DbCollection dbCollection = db.collection(collection);
    await db.open();
    var data = await dbCollection.find().toList();
    db.close();
    return data;
  }

  deleteOne(ObjectId id) async {
    DbCollection dbCollection = db.collection(collection);
    await db.open();
    await dbCollection.remove({"_id": id});
    db.close();
  }

  insert(int plate, String destination, int where, int terminal, bool isFull) async {
    DbCollection dbCollection = db.collection(collection);
    await db.open();
    await dbCollection.insert({
      "plate": plate,
      "destination": destination,
      "where": where,
      "terminal": terminal,
      "isFull": isFull
    });
    db.close();
  }

  update(ObjectId id, String field, value) async {
    DbCollection dbCollection = db.collection(collection);
    await db.open();
    await dbCollection.update(where.id(id), modify.set(field, value));
    db.close();
  }
}

class UserDBProvider {
  Db db = Db('mongodb://localhost:27017/local');
  String collection = "user";

  findUser(String userName, String pass) async {
    DbCollection dbCollection = db.collection(collection);
    await db.open();
    var data = dbCollection.find({"userName": userName, "pass": pass}).toList();
    //db.close();
    return data;
  }
}
