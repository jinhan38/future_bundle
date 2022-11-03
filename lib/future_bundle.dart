library future_bundle;


class FutureBundle {

  static void set({
    required List<Future<dynamic>> futures,
    required Function(Map<int, dynamic> data) data,
    required Function(List<dynamic> results) complete,
    bool useMinDuration = false,
    bool useMaxDuration = false,
    int minDuration = 500,
    int maxDuration = 10000,
  }) {
    var results = List<dynamic>.filled(futures.length, null);
    final DateTime startTime = DateTime.now();
    bool eventComplete = false;
    bool timeOut = false;
    int count = 0;

    for (int i = 0; i < futures.length; i++) {
      futures[i].then((value) async {
        data({i: value});
        if (timeOut) return;
        count++;
        results[i] = value;
        if (count == futures.length) {
          if(useMinDuration){
            int dif = DateTime.now().difference(startTime).inMilliseconds;
            int duration = minDuration - dif;
            if (duration > 0) {
              await Future.delayed(Duration(milliseconds: duration.abs()));
            }
            eventComplete = true;
          }
          return complete(results);
        }
      });
    }
    
    if(useMaxDuration){
      Future.delayed(Duration(milliseconds: maxDuration)).then((value) {
        if (eventComplete) return;
        timeOut = true;
        return complete(results);
      });
    }

  }
}
