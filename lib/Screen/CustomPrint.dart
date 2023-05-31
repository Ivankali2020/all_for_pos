import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../Screen/HomeScreen.dart';
import 'package:path/path.dart';

class CustomPrint extends StatefulWidget {
  const CustomPrint({super.key});

  @override
  State<CustomPrint> createState() => _CustomPrintState();
}

class _CustomPrintState extends State<CustomPrint> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  late bool isConnect = false;
  BluetoothDevice? device;
  String message = ' Bluetooth Toggle';
  bool isSearchDevice = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initScan();
    });
  }

  Future _initScan() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 2));

    bool isConneted = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((event) {
      switch (event) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            isConnect = true;
            message = 'No Devices Found';
          });
          print('coneected');
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            isConnect = true;
            message = 'No Devices Found';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;
    print(isConneted);
    if (isConneted) {
      setState(() {
        isConnect = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Print'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).popUntil((route) => route.isFirst);
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () =>
              bluetoothPrint.startScan(timeout: const Duration(seconds: 2)),
          child: ListView(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Divider(),
              StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothPrint.scanResults,
                initialData: [],
                builder: (ctx, snapshot) => Column(
                  children: snapshot.data!
                      .map((e) => ListTile(
                            onTap: () {
                              setState(() {
                                device = e;
                              });
                            },
                            leading: const Icon(Icons.print_sharp),
                            title: Text('${e.name}'),
                            subtitle: Text('${e.address}'),
                            trailing: device != null
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.lightGreen,
                                  )
                                : null,
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: bluetoothPrint.isScanning,
        initialData: false,
        builder: (ctx, snapshop) => snapshop.data == true
            ? FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: () {
                  bluetoothPrint.stopScan();
                  setState(() {
                    isSearchDevice = !isSearchDevice;
                  });
                },
                child: const Icon(
                  Icons.stop,
                  color: Color.fromARGB(255, 255, 255, 255),
                ))
            : FloatingActionButton(
                onPressed: () {
                  bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
                  setState(() {
                    isSearchDevice = !isSearchDevice;
                  });
                },
                child: const Icon(
                  Icons.search,
                  color: Color.fromARGB(255, 255, 255, 255),
                )),
      ),
    );
  }
}
