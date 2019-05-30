import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:klimatic/util/utils.dart' as util;

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {
  String _cityEntered;

  Future _goToNextScreen(BuildContext context) async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute<Map>(builder: (BuildContext context) {
      return new ChangeCity();
    }));
    _cityEntered = results['enter'];
//    if (results != null && results.containsKey('enter')) {
//      _cityEntered = results['enter'];
//    }
  }

  void showStuff() async {
    Map data = await getWeather(util.appId, util.defaultCity);
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("klimatic"),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.menu), onPressed: () => _goToNextScreen(context))
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset(
              'images/umbrella.png',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: Text(
              '${_cityEntered == null ? util.defaultCity : _cityEntered}',
              style: cityStyle(),
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
            child: Image.asset("images/light_rain.png"),
          ),
          updateTempWidget(_cityEntered),
//          Container(
//            alignment: Alignment.center,
//            child: updateTempWidget(_cityEntered),
//          ),
        ],
      ),
    );
  }

  Future<Map> getWeather(String appId, String city) async {
    String apiUrl = "http://api.openweathermap.org/data/2.5/weather"
        "?q=${city}"
        "&APPID=${appId}&units=metric";

    http.Response response = await http.get(apiUrl);

    return json.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    return FutureBuilder(
        future: getWeather(util.appId, city == null ? util.defaultCity : city),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          // get all the json data
          if (snapshot.hasData) {
            Map content = snapshot.data;
            return Container(
                margin: const EdgeInsets.fromLTRB(100.0, 250.0, 0.0, 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ListTile(
                        title: Text(
                          content['main']['temp'].toString() + " C°",
                          style: degreeStyle(),
                        ),
                        subtitle: ListTile(
                          title: Text(
                            'Humidity: ${content['main']['humidity'].toString()}\n'
                                'Min: ${content['main']['temp_min'].toString()}\n'
                                'Max: ${content['main']['temp_max'].toString()}',
                            style: extraDataStyle(),
                          ),
                        )),
                  ],
                ));
          } else {
            return Container();
          }
        });
  }
}

class ChangeCity extends StatelessWidget {
  final _cityFieldController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Change City'),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset('images/white_snow.png',
                width: 490.0, height: 1200.0, fit: BoxFit.fill),
          ),
          ListView(
            children: <Widget>[
              ListTile(
                  title: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter City',
                ),
                controller: _cityFieldController,
                keyboardType: TextInputType.text,
              )),
              ListTile(
                title: FlatButton(
                    onPressed: () => Navigator.pop(context, {
                          'enter': _cityFieldController.text,
                        }),
                    textColor: Colors.white70,
                    color: Colors.redAccent,
                    child: Text('Get Weather')),
              )
            ],
          )
        ],
      ),
    );
  }
}

TextStyle cityStyle() {
  return TextStyle(
    color: Colors.grey,
    fontSize: 22.9,
    fontStyle: FontStyle.italic,
  );
}

TextStyle degreeStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 49.9,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
  );
}

TextStyle extraDataStyle() {
  return TextStyle(
    color: Colors.white70,
    fontSize: 17.0,
    fontStyle: FontStyle.normal,
  );
}
