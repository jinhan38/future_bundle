library future_bundle;

import 'dart:async';
import 'dart:developer';

class FutureBundle {
  final DateTime _startTime = DateTime.now();
  final Map<int, dynamic> _dataMap = {};
  List<dynamic> _resultList = [];
  bool _eventComplete = false;
  bool _timeOut = false;
  bool _flag = false;
  int _count = 0;
  int _timeOutDuration = 1000;

  Future<List<dynamic>?> pack({
    required List<Future<dynamic>> futures,
    Function(List<dynamic> results)? complete,
    Function(Map<int, dynamic> data)? data,
    int checkDuration = 10,
    bool useTimeOut = true,
    int? timeOutDuration,
  }) async {
    if (timeOutDuration != null) _timeOutDuration = timeOutDuration;
    if (_eventComplete) return _resultValue();
    if (_timeOut) return _timeOutValue();
    _callData(futures, complete, data);
    _checkTimeOut(useTimeOut, _timeOutDuration);
    await Future.delayed(Duration(milliseconds: checkDuration));
    return await pack(
        futures: futures,
        complete: complete,
        data: data,
        useTimeOut: useTimeOut,
        timeOutDuration: _timeOutDuration);
  }

  _callData(
      List<Future<dynamic>> futures,
      Function(List<dynamic> results)? complete,
      Function(Map<int, dynamic> data)? data,
      ) {
    if (_flag) return;
    _flag = true;
    for (int i = 0; i < futures.length; i++) {
      futures[i].then((value) async {
        if (_timeOut) return;
        data?.call({i: value});
        _dataMap[i] = value;
        _count++;
        if (_count == futures.length) {
          _resultList = _dataMap.entries.map((e) => e).toList();
          _resultList.sort((a, b) => a.key.compareTo(b.key));
          complete?.call(_resultList);
          _eventComplete = true;
          return;
        }
      });
    }
  }

  /// return resultList with time log.
  List<dynamic> _resultValue() {
    log("FutureBundle pack duration milliseconds : ${DateTime.now().difference(_startTime).inMilliseconds}");
    return _resultList;
  }

  /// check timeOut
  _checkTimeOut(bool useMaxDuration, int maxDuration) {
    if (!useMaxDuration) return;
    int dif = DateTime.now().difference(_startTime).inMilliseconds;
    int duration = maxDuration - dif;
    if (duration < 0) _timeOut = true;
  }

  List<String> _timeOutValue() {
    return [
      "TimeOut($_timeOutDuration) occurred. If you don't want TimeOut, set useTimeOut to false "
    ];
  }
}
