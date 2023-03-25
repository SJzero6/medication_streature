import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medication_structure/chart.dart';
import 'package:medication_structure/provider/provider.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var heartRate = 0;
  var o2 = 0;
  String bp = "-";
  String Btemp = "-";
  //String error = "ivalid";
  ///URL//
  void initState() {
    Mqttprovider mqttProvider =
        Provider.of<Mqttprovider>(context, listen: false);
    mqttProvider.newAWSConnect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Mqttprovider mqttProvider = Provider.of<Mqttprovider>(context);

    Map<String, dynamic> log = json.decode(mqttProvider.rawLogData);

    heartRate = log["Pulse"] ?? 0;
    o2 = log["SPO2"] ?? -1;
    bp = log["BP"] ?? '-';
    Btemp = log["Temp"] ?? '-';
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: Container(
        margin: EdgeInsets.only(left: 10, top: 19, bottom: 5, right: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'HI..! Welcome',
                  style:
                      GoogleFonts.aclonica(fontSize: 20, color: Colors.indigo),
                ),
                Container(
                  height: 40,
                  width: 40,
                  child: Image.asset(
                    'assets/img/4003833.png',
                  ),
                )
              ],
            ),
            Expanded(
                child: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                Center(
                    child: Container(
                        margin: EdgeInsets.only(left: 70),
                        height: 300,
                        width: 300,
                        child: Image.asset('assets/img/strchr.png'))),
                Center(
                  child: Text('SMART STRETCHER',
                      style: GoogleFonts.aclonica(
                          fontSize: 20, color: Colors.indigo)),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CHECK-UP\'S',
                        style: GoogleFonts.abel(
                            textStyle: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      RotatedBox(
                          quarterTurns: 135,
                          child: Icon(
                            Icons.bar_chart_rounded,
                            size: 28,
                          ))
                    ],
                  ),
                ),
                SizedBox(
                  height: 28,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _cardmenu(
                          title: 'Heart Rate\n $heartRate',
                          asset: 'assets/img/865969.png',
                          onTap: () {
                            print('heart rate');
                          }),
                      _cardmenu(
                          title: 'Oxygen Rate\n$o2',
                          asset: 'assets/img/3355512.png',
                          onTap: () {},
                          color: Colors.indigoAccent,
                          fontcolor: Colors.white),
                    ]),
                SizedBox(
                  height: 10,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _cardmenu(
                          onTap: () {
                            print('blood pressure');
                          },
                          title: 'Blood Pressure\n$bp',
                          asset: 'assets/img/1934385.png',
                          color: Colors.indigoAccent,
                          fontcolor: Colors.white),
                      _cardmenu(
                          onTap: () {
                            print('body temp');
                          },
                          title: 'Body Temprature\n$Btemp',
                          asset: 'assets/img/Thermometer_icon.png'),
                    ]),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => linechart(),
                        ));
                    print('graph');
                  },
                  child: Container(
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23)),
                      child: Column(
                        children: [
                          Container(
                              height: 80,
                              width: 40,
                              child: Image.asset('assets/img/2865022.png')),
                          SizedBox(height: 1),
                          Text(
                            'E C G ',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                ))
              ],
            ))
          ],
        ),
      ),
    ));
  }

  Widget _cardmenu(
      {required String title,
      required asset,
      VoidCallback? onTap,
      Color color = Colors.white,
      Color fontcolor = Colors.grey}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 36),
        width: 156,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24), color: color),
        child: Column(children: [
          Container(
            height: 60,
            width: 60,
            child: Image.asset(
              asset,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: fontcolor,
            ),
          )
        ]),
      ),
    );
  }
}
