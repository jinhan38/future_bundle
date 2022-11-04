import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';

import 'package:future_bundle/future_bundle.dart';

void main() {
  
  Future<String> checkString(String result, int duration) async {
    await Future.delayed(Duration(milliseconds: duration));
    return result;
  }

  test('adds one to input values', () {
    FutureBundle().pack(
      futures: [
        checkString("first duration : 500", 500),
        checkString("second duration : 2000", 2000),
        checkString("third duration : 1000", 1000),
      ],
      data: (data) {
        log("data : $data");
      },
      complete: (results) {
        log("results : $results");
      },
    );
  });
}
