import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

void main() async {
  print(await getData());
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          hintColor: Colors.amber,
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white))))));
}

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=ac65939d";

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function function) {
  print(controller);
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25),
    onChanged: function,
    keyboardType: TextInputType.number,
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final euroController = TextEditingController();
  final dollarController = TextEditingController();

  double _dollar;
  double _euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black54,
        appBar: AppBar(
          title: Text("\$ Conversor \$"),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text("Carregando dados...",
                        style: TextStyle(color: Colors.amber, fontSize: 25),
                        textAlign: TextAlign.center),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Erro ao carregar dados...",
                          style: TextStyle(color: Colors.amber, fontSize: 25),
                          textAlign: TextAlign.center),
                    );
                  } else {
                    _dollar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    _euro =
                        snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.monetization_on,
                              size: 150, color: Colors.amber),
                          buildTextField(
                              "Reais", "R\$", realController, _realChange),
                          Divider(),
                          buildTextField("Dolares", "R\$", dollarController,
                              _dollarChange),
                          Divider(),
                          buildTextField(
                              "Euros", "€", euroController, _euroChange)
                        ],
                      ),
                    );
                  }
              }
            }));
  }

  void _dollarChange(String text) {
    if (text.isEmpty) {
      _resetFields();
      return;
    }
    double dollars = double.parse(text);
    realController.text = (dollars * this._dollar).toStringAsFixed(2);
    euroController.text = (dollars * this._dollar / _euro).toStringAsFixed(2);
  }

  void _euroChange(String text) {
    if (text.isEmpty) {
      _resetFields();
      return;
    }
    double euros = double.parse(text);
    realController.text = (euros * this._euro).toStringAsFixed(2);
    dollarController.text = (euros * this._euro / _dollar).toStringAsFixed(2);
  }

  void _realChange(String text) {
    if (text.isEmpty) {
      _resetFields();
      return;
    }
    double real = double.parse(text);
    dollarController.text = (real / _dollar).toStringAsFixed(2);
    euroController.text = (real / _euro).toStringAsFixed(2);
  }

  void _resetFields() {
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
  }
}
