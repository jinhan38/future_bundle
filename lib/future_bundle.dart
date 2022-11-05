import 'dart:developer';

class FutureBundle {
  final DateTime _startTime = DateTime.now();
  final Map<int, dynamic> _dataMap = {};
  bool _eventComplete = false;
  int _timeOutDuration = 10000;
  bool _timeOut = false;
  bool _flag = false;
  int _count = 0;

  Future<List<dynamic>> pack({
    required List<Future<dynamic>> futures,
    Function(List<dynamic> results)? complete,
    Function(Map<int, dynamic> data)? data,
    int checkDuration = 10,
    bool useTimeOut = true,
    int? timeOutDuration,
    bool useMinTime = false,
    int minDuration = 100,
  }) async {
    if (timeOutDuration != null) _timeOutDuration = timeOutDuration;
    if (_eventComplete && useMinTime) {
      await _checkMinTime(useMinTime, minDuration);
    }
    if (_eventComplete) return _resultValue();
    if (_timeOut) return _timeOutValue();
    _callData(futures, complete, data,
        useMinTime: useMinTime, minDuration: minDuration);
    _checkTimeOut(useTimeOut, _timeOutDuration);
    await Future.delayed(Duration(milliseconds: checkDuration));
    return await pack(
      futures: futures,
      complete: complete,
      data: data,
      useTimeOut: useTimeOut,
      timeOutDuration: _timeOutDuration,
      useMinTime: useMinTime,
      minDuration: minDuration,
    );
  }

  _callData(
      List<Future<dynamic>> futures,
      Function(List<dynamic> results)? complete,
      Function(Map<int, dynamic> data)? data, {
        bool useMinTime = false,
        int minDuration = 300,
      }) {
    if (_flag) return;
    _flag = true;
    for (int i = 0; i < futures.length; i++) {
      futures[i].then((value) async {
        if (_timeOut) return;
        data?.call({i: value});
        _dataMap[i] = value;
        _count++;
        if (_count == futures.length) {
          await _checkMinTime(useMinTime, minDuration);
          complete?.call(_resultValue());
          _eventComplete = true;
          return;
        }
      });
    }
  }

  /// return resultList with time log.
  List<dynamic> _resultValue() {
    log("FutureBundle pack duration milliseconds : ${DateTime.now().difference(_startTime).inMilliseconds}");
    List<MapEntry> temp = _dataMap.entries.map((e) => e).toList();
    temp.sort((a, b) => a.key.compareTo(b.key));
    return temp.map((e) => e.value).toList();
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

  Future<void> _checkMinTime(bool useMinTime, int minDuration) async {
    if (!useMinTime) return;
    int dif = DateTime.now().difference(_startTime).inMilliseconds;
    int duration = minDuration - dif;
    if (duration > 0) {
      log("Minimum time delay : ${duration.abs()}");
      await Future.delayed(Duration(milliseconds: duration.abs()));
    }
  }
}
