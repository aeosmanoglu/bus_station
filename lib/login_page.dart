import 'package:bustest/bus_page.dart';
import 'package:bustest/db_provider.dart';
import 'package:bustest/my_obj.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    String userName;
    String pass;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 40),
            ListTile(
              title: Text("Kullanıcı Adı"),
              subtitle: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) {
                  userName = text;
                },
              ),
            ),
            ListTile(
              title: Text("Parola"),
              subtitle: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) {
                  pass = text;
                },
              ),
            ),
            SizedBox(height: 40),
            RaisedButton(
              color: Colors.purple,
              textColor: Colors.white,
              child: Text("GİRİŞ YAP"),
              onPressed: () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                List<Map<String, dynamic>> data = await UserDBProvider().findUser(userName, pass);
                userCheck(data, context);
              },
            ),
            FlatButton(
              child: Text(
                "GİRİŞ YAPMADAN DEVAM ET",
                style: Theme.of(context).textTheme.caption,
              ),
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new BusPage(false, false)));
              },
            )
          ],
        ),
      ),
    );
  }

  userCheck(List<Map<String, dynamic>> data, BuildContext context) {
    if (data.length != 0) {
      for (Map<String, dynamic> item in data) {
        User user = User(
          id: item["id"],
          image: item["image"],
          name: item["name"],
          userName: item["userName"],
          pass: item["pass"],
          isAdmin: item["isAdmin"],
          isSuperAdmin: item["isSuperAdmin"],
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => new BusPage(
              user.isAdmin,
              user.isSuperAdmin,
              image: user.image,
              name: user.name,
              username: user.userName,
            ),
          ),
        );
      }
    } else {
      wrongUser(context);
    }
  }

  wrongUser(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Kullanıcı adı veya Parola hatalı"),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "DEVAM ET",
                  style: Theme.of(context).textTheme.button,
                ),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new BusPage(false, false)));
                },
              ),
              FlatButton(
                child: Text(
                  "İPTAL",
                  style: Theme.of(context).textTheme.button,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
