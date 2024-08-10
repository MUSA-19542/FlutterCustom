import 'package:flutter/material.dart';
import 'displays/secondary_display.dart';

import 'displays/displaymanager.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const DisplayManagerScreen());
    case 'presentation':
      return MaterialPageRoute(builder: (_) => const SecondaryScreen());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

void main() {
  debugPrint('first main');
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void secondaryDisplayMain() {
  debugPrint('second main');
  runApp(const MySecondApp());
}

class MySecondApp extends StatelessWidget {
  const MySecondApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: 'presentation',
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}

class Button extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const Button({Key? key, required this.title, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(

      color: Colors.black,
      margin: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
           backgroundColor: Color(0xFFDFAE32), 
        ),
        
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(fontSize: 15,color: Colors.white),
        ),
      ),
    );
  }
}

/// Main Screen
class DisplayManagerScreen extends StatefulWidget {
  const DisplayManagerScreen({Key? key}) : super(key: key);

  @override
  _DisplayManagerScreenState createState() => _DisplayManagerScreenState();
}

class _DisplayManagerScreenState extends State<DisplayManagerScreen> {
  DisplayManager displayManager = DisplayManager();
  List<Display?> displays = [];

  final TextEditingController _indexToShareController = TextEditingController();
 
  final TextEditingController _dataToTransferController =
      TextEditingController();

  final TextEditingController _nameOfIdController = TextEditingController();
  String _nameOfId = "";
  final TextEditingController _nameOfIndexController = TextEditingController();
  String _nameOfIndex = "";
@override
  void initState() {
    displayManager.connectedDisplaysChangedStream?.listen(
      (event) {
        debugPrint("connected displays changed: $event");
      },
    );
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(child: const Text('Plugin example app',style: TextStyle(color: Color(0xFFAB060F),),textAlign:TextAlign.center,)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //auto detects and connect to secondary display
              _autodetectandConnect(),
              _getDisplays(),
              _showPresentation(),
              _transferData(),
              _hidePresentation(),
              _getDisplayById(),

              ],
          ),
        ),
      ),
    );
  }

  Widget _getDisplays() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Button(
            title: "Get Displays",
            onPressed: () async {
              final values = await displayManager.getDisplays();
              displays.clear();
              setState(() {
                displays.addAll(values!);
              });
            }),
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: displays.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 50,
                child: Center(
                    child: Text(
                        ' ${displays[index]?.a} ${displays[index]?.d}',style: TextStyle(color: Colors.white))),
              );
            }),
        const Divider()
      ],
    );
  }

  Widget _hidePresentation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            style: TextStyle(color: Colors.white),
            controller: _indexToShareController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Index to hide screen',
              labelStyle: TextStyle(color: Colors.white)
            ),
          ),
        ),
        Button(
            title: "Hide presentation",
            onPressed: () async {
              String? displayId = _indexToShareController.text.toString();
              if (displayId != null) {
                for (final display in displays) {
                  if (display?.a == displayId) {
                    displayManager.hideSecondaryDisplay(displayId: displayId.toString());
                  }
                }
              }
            }),
        const Divider(),
      ],
    );
  }


  Widget _autodetectandConnect() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("New Feature For POs it Auto Detects Secondary Display and Connects ",style: TextStyle(color: Colors.white),),

        Button( 
            title: "Auto Detect & Connect To Screen ",
            onPressed: () async {
           final values = await displayManager.getDisplays();
    displays.addAll(values! as Iterable<Display?>);
    if (displays.length > 1) {
      String? x = displays[1]!.a;
      displayManager.showSecondaryDisplay(
        displayId: x ?? "0",
        routerName: "presentation",
      );
    }
            }),
        const Divider(),
      ],
    );
  }



  Widget _showPresentation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _indexToShareController,
            style: TextStyle(color: Colors.white),
            decoration: const InputDecoration(
            labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
              labelText: 'Index to share screen',
            ),
          ),
        ),
        Button(
            title: "Show presentation",
            onPressed: () async {
              String? displayId = _indexToShareController.text.toString();
              if (displayId != null) {
                for (final display in displays) {
                  if (display?.a == displayId) {
                    displayManager.showSecondaryDisplay(
                        displayId: displayId.toString(), routerName: "presentation");
                  }
                }
              }
            }),
        const Divider(),
      ],
    );
  }

  Widget _getDisplayById() {
 
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _nameOfIndexController,
            style: TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Index',
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Button(
            title: "NameById",
            onPressed: () async {
              int? index = int.tryParse(_nameOfIndexController.text);
              if (index != null) {
                final value = await displayManager.getNameById(index.toString());
                setState(() {
                  _nameOfIndex = value ?? "";
                });
              }
            }),
        SizedBox(
          height: 50,
          child: Center(child: Text(_nameOfIndex)),
        ),
        const Divider(),
      ],
    );
  }


  

  Widget _transferData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _dataToTransferController,
            style: TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Data to transfer',
              
            labelStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Button(
            title: "TransferData",
            onPressed: () async {
              String data = _dataToTransferController.text;
              await displayManager.transferDataToPresentation(data);
            }),
        const Divider(),
      ],
    );
  }



}

/// UI of Presentation display
class SecondaryScreen extends StatefulWidget {
  const SecondaryScreen({Key? key}) : super(key: key);

  @override
  _SecondaryScreenState createState() => _SecondaryScreenState();
}

class _SecondaryScreenState extends State<SecondaryScreen> {
  String value = "How Beautiful Is the Day Dont Worry?";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SecondaryDisplay(
      callback: (dynamic argument) {
        setState(() {
          value = argument;
        });
      },
      child: Container(
        color: Colors.white,
        child: Center(
          child: Text(value),
        ),
      ),
    ));
  }
}