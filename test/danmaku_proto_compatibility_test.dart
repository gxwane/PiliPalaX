import 'package:PiliPalaX/models/danmaku/dm.pb.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('danmaku request wire fields keep their protobuf numbers', () {
    const wireBytes = <int>[8, 1, 16, 123, 24, 1, 32, 2];

    final request = DmSegMobileReq.fromBuffer(wireBytes);

    expect(request.pid.toInt(), 1);
    expect(request.oid.toInt(), 123);
    expect(request.type, 1);
    expect(request.segmentIndex.toInt(), 2);
    expect(request.writeToBuffer(), wireBytes);
  });
}
