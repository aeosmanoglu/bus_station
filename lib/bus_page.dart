import 'dart:convert';
import 'dart:typed_data';

import 'package:bustest/login_page.dart';
import 'package:bustest/my_obj.dart';
import 'package:bustest/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusPage extends StatefulWidget {
  final bool isAdmin;
  final bool isSuperAdmin;
  final String image;
  final String name;
  final String username;

  BusPage(this.isAdmin, this.isSuperAdmin, {this.image, this.name, this.username});

  @override
  _BusPageState createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> {
  int sortStyle;
  bool isHiding;
  bool isAdmin;
  bool isSuperAdmin;

  /// Get Shared Preferences
  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sortStyle = prefs.getInt("sortStyle") ?? 0;
    isHiding = prefs.getBool("isHiding") ?? false;
  }

  ///Main Scaffold that contains Drawer
  @override
  Widget build(BuildContext context) {
    getPrefs();
    isAdmin = widget.isAdmin;
    isSuperAdmin = widget.isSuperAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text("Araç Listesi"),
        actions: <Widget>[addUser(isSuperAdmin)],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            drawerHeader(isAdmin),
            ListTile(
              title: Text("Ayarlar"),
              subtitle: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  RadioListTile(
                    title: Text("Plakaya göre sırala"),
                    value: 0,
                    groupValue: sortStyle,
                    onChanged: (value) async {
                      setState(() {
                        sortStyle = value;
                      });
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setInt("sortStyle", value);
                    },
                  ),
                  RadioListTile(
                    title: Text("Güzergaha göre sırala"),
                    value: 1,
                    groupValue: sortStyle,
                    onChanged: (value) async {
                      setState(() {
                        sortStyle = value;
                      });
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setInt("sortStyle", value);
                    },
                  ),
                  RadioListTile(
                    title: Text("Araca göre sırala"),
                    value: 2,
                    groupValue: sortStyle,
                    onChanged: (value) async {
                      setState(() {
                        sortStyle = value;
                      });
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setInt("sortStyle", value);
                    },
                  ),
                  RadioListTile(
                    title: Text("Park yerine göre sırala"),
                    groupValue: sortStyle,
                    value: 3,
                    onChanged: (value) async {
                      setState(() {
                        sortStyle = value;
                      });
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setInt("sortStyle", value);
                    },
                  ),
                  SwitchListTile(
                    title: Text("Dolu veya Giden araçları gösterme"),
                    value: isHiding ?? false,
                    onChanged: (value) async {
                      setState(() {
                        isHiding = value;
                      });
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setBool("isHiding", value);
                    },
                  )
                ],
              ),
            ),
            Divider(),
            ListTile(
              title: Text("Bilgi"),
              subtitle: Wrap(
                spacing: 4,
                runSpacing: -12,
                children: <Widget>[
                  Chip(
                    label: Text("Geliyor"),
                    avatar: Icon(Icons.directions_bus, color: Colors.orange),
                  ),
                  Chip(
                    label: Text("Geldi"),
                    avatar: Icon(Icons.directions_bus, color: Colors.green),
                  ),
                  Chip(
                    label: Text("Doldu"),
                    avatar: Icon(Icons.directions_bus, color: Colors.red),
                  ),
                  Chip(
                    label: Text("Kalktı"),
                    avatar: Icon(Icons.directions_bus, color: Colors.grey),
                  ),
                  Chip(
                    label: Text("Park Alanı"),
                    avatar: CircleAvatar(backgroundColor: Colors.white70, foregroundColor: Colors.black, child: Text("1")),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: list(sortStyle),
      floatingActionButton: fab(isAdmin),
    );
  }

  ///AppBar Actions
  Widget addUser(isSuperAdmin) {
    return isSuperAdmin
        ? IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              print("add user button tapped");
            })
        : SizedBox();
  }

  ///Drawer header
  Widget drawerHeader(bool isAdmin) {
    Uint8List bytes;
    if (widget.image != null) {
      bytes = base64Decode(widget.image);
    }

    return isAdmin
        ? UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundImage: MemoryImage(bytes),
            ),
            otherAccountsPictures: <Widget>[
              IconButton(
                icon: Icon(Icons.add_a_photo, color: Colors.white),
                onPressed: () {
                  print("add photo button tapped");
                },
              ),
              IconButton(
                icon: Icon(Icons.lock_outline, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new LoginPage()));
                },
              ),
            ],
            accountName: Text(widget.name),
            accountEmail: Text(widget.username),
          )
        : UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              child: IconButton(
                icon: Icon(Icons.lock_open),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new LoginPage()));
                },
              ),
            ),
            otherAccountsPictures: <Widget>[
              IconButton(
                  icon: Icon(Icons.info_outline, color: Colors.white),
                  onPressed: () {
                    print("info button pressed");
                  })
            ],
            accountName: null,
            accountEmail: null,
          );
  }

  Widget list(int sortStyle) {
    return RefreshIndicator(child: futureBuilder(sortStyle), onRefresh: refresh);
  }

  Future<Null> refresh() async {
    await new Future.delayed(new Duration(milliseconds: 399));
    setState(() {});
    return null;
  }

  Widget futureBuilder(int sortStyle) {
    return FutureBuilder(
      future: getAll(sortStyle),
      builder: (BuildContext context, AsyncSnapshot<List<Bus>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              return Text(snapshot.error);
            } else if (snapshot.data.length == 0 || snapshot.data == null) {
              return Center(child: Text("Veri yok"));
            } else
              return listViewBuilder(snapshot.data);
        }
      },
    );
  }

  Widget listViewBuilder(List<Bus> snapshotData) {
    return ListView.builder(
      itemCount: snapshotData.length,
      itemBuilder: (BuildContext context, int index) {
        Bus bus = snapshotData[index];
        MaterialColor busColor;

        ///Setting Bus icon color
        ///Orange for on way and empty
        ///Green for park and empty
        ///Red for on way or park and full
        ///Grey for departed for all situations
        switch (bus.where) {
          case 0:
            {
              busColor = Colors.orange;
            }
            break;
          case 1:
            {
              busColor = Colors.green;
            }
            break;
        }
        if (bus.isFull) {
          busColor = Colors.red;
        }
        if (bus.where == 2) {
          busColor = Colors.grey;
        }

        return busCard(bus, busColor);
      },
    );
  }

  Future<List<Bus>> getAll(int sortStyle) async {
    var data = await BusDBProvider().getAll();
    List<Bus> busList = [];
    for (Map<String, dynamic> item in data) {
      if (isHiding) {
        if (item["where"] == 2 || item["isFull"]) {
          continue;
        } else {
          busList.add(
            Bus(
              id: item["_id"],
              plate: item["plate"],
              destination: item["destination"],
              where: item["where"],
              terminal: item["terminal"],
              isFull: item["isFull"],
            ),
          );
        }
      } else {
        busList.add(
          Bus(
            id: item["_id"],
            plate: item["plate"],
            destination: item["destination"],
            where: item["where"],
            terminal: item["terminal"],
            isFull: item["isFull"],
          ),
        );
      }
    }

    ///Sorting the List
    switch (sortStyle) {
      case 0:
        {
          busList.sort((a, b) => a.plate.compareTo(b.plate));
        }
        break;
      case 1:
        {
          busList.sort((a, b) => a.destination.compareTo(b.destination));
        }
        break;
      case 2:
        {
          busList.sort((a, b) => a.where.compareTo(b.where));
        }
        break;
      case 3:
        {
          busList.sort((a, b) => a.terminal.compareTo(b.terminal));
        }
        break;
    }

    return busList;
  }

  Widget busCard(Bus bus, MaterialColor busColor) {
    ///Delete for swipe
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: AlignmentDirectional.centerEnd,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 28, 0),
          child: Icon(
            Icons.delete_sweep,
            color: Colors.white,
          ),
        ),
      ),
      onDismissed: (direction) {
        BusDBProvider().deleteOne(bus.id);
        setState(() {});
      },

      ///Bus List
      child: Card(
        child: ListTile(
          title: Text(bus.plate.toString()),
          subtitle: Text(bus.destination),
          leading: Text(bus.terminal.toString()),
          trailing: trailing(bus, busColor, isAdmin),
        ),
      ),
    );
  }

  ///Card Trailing
  Widget trailing(Bus bus, MaterialColor busColor, bool isAdmin) {
    return isAdmin
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.directions_bus,
                color: busColor,
              ),
              busSettings(bus.id),
            ],
          )
        : Icon(
            Icons.directions_bus,
            color: busColor,
          );
  }

  ///PopUp Menu Widget
  Widget busSettings(id) {
    return PopupMenuButton<int>(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Text("Yolda"),
        ),
        PopupMenuItem(
          value: 2,
          child: Text("Park"),
        ),
        PopupMenuItem(
          value: 3,
          child: Text("Boş"),
        ),
        PopupMenuItem(
          value: 4,
          child: Text("Dolu"),
        ),
        PopupMenuItem(
          value: 5,
          child: Text("Çıktı"),
        ),
      ],
      onSelected: (value) {
        String fieldName;
        var fieldValue;
        switch (value) {
          case 1:
            {
              fieldName = "where";
              fieldValue = 0;
            }
            break;
          case 2:
            {
              fieldName = "where";
              fieldValue = 1;
            }
            break;
          case 3:
            {
              fieldName = "isFull";
              fieldValue = false;
            }
            break;
          case 4:
            {
              fieldName = "isFull";
              fieldValue = true;
            }
            break;
          case 5:
            {
              fieldName = "where";
              fieldValue = 2;
            }
            break;
        }
        BusDBProvider().update(id, fieldName, fieldValue);
        setState(() {});
      },
    );
  }

  ///Float Action Button
  Widget fab(bool isAdmin) {
    return isAdmin
        ? FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              await addBus(context);
              setState(() {});
            },
          )
        : null;
  }

  addBus(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        int plate;
        String destination;
        int terminal;
        return AlertDialog(
          title: Text("Yeni Araç Ekle"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Plaka",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      plate = int.tryParse(text);
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: "Güzergah",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      destination = text;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  DropdownButton(
                    value: terminal,
                    items: [
                      DropdownMenuItem(
                        value: 1,
                        child: Text("1. Bölge"),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text("2. Bölge"),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text("3. Bölge"),
                      ),
                    ],
                    isExpanded: true,
                    hint: Text("Park Yeri"),
                    onChanged: (value) {
                      setState(() {
                        terminal = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                if (plate != null && destination != null && terminal != null) {
                  BusDBProvider().insert(plate, destination, 0, terminal, false);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                "KAYDET",
                style: Theme.of(context).textTheme.button,
              ),
            ),
          ],
        );
      },
    );
  }
}
