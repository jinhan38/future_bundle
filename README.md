<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

You can use the PageView keeping position of items in Android and IOS.

## Usage

You can get data of Future Functions. The data function is called when each function call is complete. It is sent as a return value as map<int,
dynamic). Int(key) is the index of the Future function list, and dynamic(value) is the return value.

```dart 
    FutureBundle().pack(
      futures: [
        Future.delayed(const Duration(milliseconds: 100)),
        Future.delayed(const Duration(milliseconds: 300)),
        Future.delayed(const Duration(milliseconds: 500)),
        Future.delayed(const Duration(milliseconds: 700)),
      ],
      data: (data) {
        // Data is Map<int, dynamic>.
        // Key(int) is index of future.
        // Value(dynamic) is value = future .
      },
      complete: (results) {
        // Results is List<dynamic>.
        // If you uses three Future Function, List.length is 3.
        // Value is return value of future.
      },
    );
```

Also, you can use FutureBundle().pack() as Future Function. The return value of FutureBundle().pack() is Future<List<dynamic>?>. The order of the list
is not the order in which the calls were completed, but the order of the futures entered. If you want to immediately receive and process the data that
has been called, process it in the data function.

```dart
  Future getData() async {
  var result = await FutureBundle().pack(futures: [
    Future.delayed(const Duration(milliseconds: 100)),
    Future.delayed(const Duration(milliseconds: 300)),
    Future.delayed(const Duration(milliseconds: 500)),
    Future.delayed(const Duration(milliseconds: 700)),
  ]);

  FutureBundle().pack(futures: [
    Future.delayed(const Duration(milliseconds: 100)),
    Future.delayed(const Duration(milliseconds: 300)),
    Future.delayed(const Duration(milliseconds: 500)),
    Future.delayed(const Duration(milliseconds: 700)),
  ]).then((value) {
    // Value is List<dynamic>.
  });
}
```

The timeout function is set by default. The default time is 10 seconds, if you don't want to use it, set the useTimeOut value to false. If you want to
increase the TimeOut time, change the timeOutDuration value.

                              


## Example code

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:future_bundle/future_bundle.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _first = "";
  String _second = "";
  String _third = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const SizedBox(height: 50),
          _text("first : $_first"),
          _text("second : $_second"),
          _text("third : $_third"),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () async {
                  var bundleData = await FutureBundle().pack(
                    futures: [
                      _checkString("first 500", 500),
                      _checkString("second 2000", 2000),
                      _checkString("third 1000", 1000),
                    ],
                    data: (data) {
                      // for (var key in data.keys) {
                      //   var value = data[key];
                      //   switch (key) {
                      //     case 0:
                      //       _first = value;
                      //       break;
                      //     case 1:
                      //       _second = value;
                      //       break;
                      //     case 2:
                      //       _third = value;
                      //       break;
                      //   }
                      //   setState(() {});
                      // }
                    },
                    complete: (results) {
                      // setState(() {
                      //   _first = results[0];
                      //   _second = results[1];
                      //   _third = results[2];
                      // });
                    },
                  );

                  setState(() {
                    _first = bundleData[0];
                    _second = bundleData[1];
                    _third = bundleData[2];
                  });
                },
                child: const Text("call FutureBundle")),
          ),
        ],
      ),
    );
  }

  Widget _text(String value) {
    return SizedBox(
        height: 50, child: Text(value, style: const TextStyle(fontSize: 20)));
  }

  Future<String> _checkString(String result, int duration) async {
    await Future.delayed(Duration(milliseconds: duration));
    return result;
  }
}
```