import 'dart:convert';
import '../models/dynamics/result.dart';
import '../models/dynamics/up.dart';
import '../utils/wbi_sign.dart';
import 'index.dart';

class DynamicsHttp {
  static Future followDynamic({
    String? type,
    String? offset,
    int? mid,
  }) async {
    Map<String, dynamic> data = {
      'type': type ?? 'all',
      'timezone_offset': '-480',
      'offset': offset,
      'features': 'itemOpusStyle'
    };

    if (mid != -1) {
      data['host_mid'] = mid;
      data.remove('timezone_offset');
    }

    // pgc 类型不需要 Wbi 签名
    if (type == 'pgc') {
      data.remove('offset'); // 维持原有的移除 offset 逻辑（如果有的话）
    }

    // 只有非 pgc 类型需要 Wbi 签名
    Map<String, dynamic> signedData = type == 'pgc' ? data : await WbiSign().makSign(data);

    var res = await Request().get(Api.followDynamic, data: signedData);
    if (res.data['code'] == 0) {
      try {
        return {
          'status': true,
          'data': DynamicsDataModel.fromJson(res.data['data']),
        };
      } catch (err, stackTrace) {
        print("====== DYNAMICS PARSING ERROR ======");
        print(err.toString());
        print(stackTrace);
        print("====== RAW DATA ======");
        String rawData = jsonEncode(res.data['data']);
        print(rawData.length > 1000 ? rawData.substring(0, 1000) : rawData);
        return {
          'status': false,
          'data': [],
          'msg': err.toString(),
        };
      }
    } else {
      print("====== DYNAMICS API ERROR ======");
      print("Error code: ${res.data['code']}");
      print("Message: ${res.data['message']}");

      // 特殊处理：4101132 表示账号被限制访问该类型动态
      String errorMsg = res.data['message'];
      if (res.data['code'] == 4101132 && type == 'pgc') {
        errorMsg = '当前账号无法访问番剧动态，可能被平台限制';
      }

      return {
        'status': false,
        'data': [],
        'msg': errorMsg,
      };
    }
  }

  static Future followUp() async {
    var res = await Request().get(Api.followUp);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': FollowUpModel.fromJson(res.data['data']),
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  // 动态点赞
  static Future likeDynamic({
    required String? dynamicId,
    required int? up,
  }) async {
    var res = await Request().post(
      Api.likeDynamic,
      queryParameters: {
        'dynamic_id': dynamicId,
        'up': up,
        'csrf': await Request.getCsrf(),
      },
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  //
  static Future dynamicDetail({
    String? id,
  }) async {
    var res = await Request().get(Api.dynamicDetail, data: {
      'timezone_offset': -480,
      'id': id,
      'features': 'itemOpusStyle',
    });
    if (res.data['code'] == 0) {
      try {
        return {
          'status': true,
          'data': DynamicItemModel.fromJson(res.data['data']['item']),
        };
      } catch (err) {
        return {
          'status': false,
          'data': [],
          'msg': err.toString(),
        };
      }
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }
}
