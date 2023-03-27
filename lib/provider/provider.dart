import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:medication_structure/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:mqtt_client/mqtt_client.dart";
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:medication_structure/home.dart';

class Mqttprovider with ChangeNotifier {
  static const url = 'a3ic1k7itt4ynl-ats.iot.ap-northeast-1.amazonaws.com';

  static const port = 8883;

  static const clientid = 'j_esp';

  final client = MqttServerClient.withPort(url, clientid, port);

  Map<String, dynamic> _logData = {};
  Map<String, dynamic> _dataList = {};

  set logData(data) {
    logData = data;
    notifyListeners();
  }

  set graphdata(gdata) {
    graphdata = gdata;
    notifyListeners();
  }

  Map<String, dynamic> get logData => _logData;
  Map<String, dynamic> get graphdata => _dataList;

  String _rawLogData = "{}";
  String _rawLogDataList = "";

  set rawLogData(data) {
    _rawLogData = data;
    notifyListeners();
  }

  set rawgraphData(gdata) {
    _rawLogDataList = "";
    _rawLogDataList = gdata ?? "";

    for (int i = 0; i < 150; i++) {
      _rawLogDataList += '460,';
    }
    _rawLogDataList += '0';

    notifyListeners();
  }

  String get rawLogData => _rawLogData;
  String get rawgraphdata => _rawLogDataList;

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

      //client.publishMessage(topic, MqttQos.atLeastOnce, maker.payload!);

      client.subscribe(topic, MqttQos.atLeastOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final rcvmsg = c[0].payload as MqttPublishMessage;
        final pt =
            MqttPublishPayload.bytesToStringAsString(rcvmsg.payload.message);
        print(
            'Example::Change notification:: topic is<${c[0].topic}>, payload is <--$pt-->');

        //logData = json.decode(pt);
        rawLogData = pt;
        rawgraphData = json.decode(pt)["ECG"];

        // heartRate = "${payloadJson["Pulse"]}";
        // bp = "${payloadJson["BP"]}";
        // Btemp = "${payloadJson["Temp"]}";
        // o2 = "${payloadJson["SPO2"]}";
        // _ecg = "${payloadJson["ECG"]}";
      });
    } else {
      print(
          'ERROR MQTT client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
    }
    return 0;
  }
}
