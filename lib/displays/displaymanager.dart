import 'dart:convert'; // Import the dart:convert package for JSON operations
import 'package:flutter/services.dart';

class DisplayManager {
  static const MethodChannel _channel = MethodChannel('presentation_displays_plugin');
late EventChannel? _displayEventChannel;
final _displayEventChannelId = "presentation_displays_plugin_events";

DisplayManager() {
    
    _displayEventChannel = EventChannel(_displayEventChannelId);
  }


  Future<List<Display>> getDisplays() async {
    // The result is expected to be a JSON string representing a list
    final String result = await _channel.invokeMethod('listDisplay');
    
    // Decode the JSON string to a List<dynamic>
    final List<dynamic> list = json.decode(result);
    
    // Map each item to a Display object
    return list.map((item) => Display.fromJson(item)).toList();
  }

  Future<void> showSecondaryDisplay({required String displayId, required String routerName}) async {
    await _channel.invokeMethod('showPresentation', {
      'displayId': displayId,
      'routerName': routerName,
    });
  }

  Future<bool?>? hideSecondaryDisplay({required String displayId}) async {
    const _hidePresentation = "hidePresentation";

    return await _channel?.invokeMethod<bool?>(
        _hidePresentation,
        "{"
        "\"displayId\": $displayId"
        "}");
  }

  
Future<String?> getNameById(String index, {String? category}) async {
  List<Display> displays = await getDisplays();
  String? name;
  int? idx = int.tryParse(index);

  if (idx != null && idx >= 0 ) {
    for(Display display in displays)
    {
      if(display.a==index)
      name=display.d;
    }
  }

  return name;
}


  Future<void> transferDataToPresentation(dynamic data) async {
    await _channel.invokeMethod('transferDataToPresentation', data);
  }

  Stream<int?>? get connectedDisplaysChangedStream {
    final _displayEventChannelId = "presentation_displays_plugin_events";
    return _displayEventChannel?.receiveBroadcastStream().cast();
  }

}

class Display {
  final String a;
  final String b;
  final String c;
  final String d;

  Display(this.a, this.b, this.c, this.d);

  factory Display.fromJson(Map<String, dynamic> json) {
    return Display(
      json['a'].toString(),
      json['b'].toString(),
      json['c'].toString(),
      json['d'].toString(),
    );
  }
}