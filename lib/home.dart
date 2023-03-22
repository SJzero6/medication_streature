import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medication_structure/chart.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Homepage extends StatefulWidget {
  Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  ///URL//
  static const url = 'a3ic1k7itt4ynl-ats.iot.ap-northeast-1.amazonaws.com';

  static const port = 8883;

  String heartRate = "-";
  String o2 = '-';
  String bp = "-";
  String Btemp = "-";
  //String error = "ivalid";

  /// client id (AWS)///
  static const clientid = 'j_esp';

  final client = MqttServerClient.withPort(url, clientid, port);

  @override
  void initState() {
    _connectMQTT();
    // TODO: implement initState
  }

  _connectMQTT() async {
    await newAWSConnect();
  }

  @override
  Widget build(BuildContext context) {
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
                          title: 'Heart Rate\n$heartRate',
                          asset: 'assets/img/865969.png',
                          onTap: () {
                            print('heart rate');
                          }),
                      _cardmenu(
                          title: 'Oxygen Rate\n$o2',
                          asset: 'assets/img/3355512.png',
                          onTap: () {
                            print('O2 rate');
                          },
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

  ///AWS connection///

  Future<int> newAWSConnect() async {
    client.secure = true;

    client.keepAlivePeriod = 20;

    client.setProtocolV311();

    client.logging(on: true);

    final context = SecurityContext.defaultContext;

    /// add certificate from AWS///

    ByteData crctdata = await rootBundle.load(
        'assets/certificates/j_cert/5ffa4df05a3cb71787dbc1b41424489334f2ba19cecc8db6a3b5910e12b793ac-certificate.pem.crt');
    context.useCertificateChainBytes(crctdata.buffer.asUint8List());

    ByteData authorities =
        await rootBundle.load('assets/certificates/j_cert/AmazonRootCA1 .pem');
    context.setClientAuthoritiesBytes(authorities.buffer.asUint8List());

    ByteData keybyte = await rootBundle.load(
        'assets/certificates/j_cert/5ffa4df05a3cb71787dbc1b41424489334f2ba19cecc8db6a3b5910e12b793ac-private.pem.key');
    context.usePrivateKeyBytes(keybyte.buffer.asUint8List());
    client.securityContext = context;

    ///add certificate///

    final mess =
        MqttConnectMessage().withClientIdentifier('j_esp').startClean();
    client.connectionMessage = mess;

    try {
      print('MQTT client is connecting to AWS');
      await client.connect();
    } on Exception catch (e) {
      print('MQTT client exception - $e');
      client.disconnect();
    }
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('AWS iot connection succesfully done');

      ///Topic///

      const topic = 'esp32/pub';
      final maker = MqttClientPayloadBuilder();
      maker.addString('hELLO');

      client.publishMessage(topic, MqttQos.atLeastOnce, maker.payload!);

      client.subscribe(topic, MqttQos.atLeastOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final rcvmsg = c[0].payload as MqttPublishMessage;
        final pt =
            MqttPublishPayload.bytesToStringAsString(rcvmsg.payload.message);
        print(
            'Example::Change notification:: topic is<${c[0].topic}>, payload is <--$pt-->');

        var payloadJson = json.decode(pt);

        setState(() {
          heartRate = "${payloadJson["Pulse"]}";
          bp = "${payloadJson["BP"]}";
          Btemp = "${payloadJson["Temp"]}";
          o2 = "${payloadJson["SPO2"]}";
        });
      });
    } else {
      print(
          'ERROR MQTT client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
    }
    // print('died');
    // await MqttUtilities.asyncSleep(10);
    // print('Diconnectiong....');
    // client.disconnect();

    return 0;
  }
}
