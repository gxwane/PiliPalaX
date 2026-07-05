import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:html/dom.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart';
import 'index.dart';

class HtmlHttp {
  // article
  static Future reqHtml(id, dynamicType) async {
    var response = await Request().get(
      "https://www.bilibili.com/opus/$id",
      extra: {'ua': 'pc'},
    );

    if (response.data.contains('Redirecting to')) {
      RegExp regex = RegExp(r'//([\w\.]+)/(\w+)/(\w+)');
      Match? match = regex.firstMatch(response.data);
      if (match != null) {
        String matchedString = match.group(0)!;
        response = await Request().get(
          'https:$matchedString/',
          extra: {'ua': 'pc'},
        );
      }
    }
    try {
      var html = response.data.toString();
      RegExp initialStateRegex = RegExp(r'window\.__INITIAL_STATE__\s*=\s*(\{.*?\});', dotAll: true);
      var match = initialStateRegex.firstMatch(html);
      if (match != null) {
        String jsonStr = match.group(1)!;
        var json = jsonDecode(jsonStr);
        var detail = json['detail'] ?? json['fallback'];
        
        String avatar = '';
        String uname = '';
        String updateTime = '';
        String opusContent = '';
        
        if (detail['modules'] != null) {
          for (var module in detail['modules']) {
            if (module['module_type'] == 'MODULE_TYPE_AUTHOR') {
              var author = module['module_author'];
              avatar = author?['face'] ?? '';
              uname = author?['name'] ?? '';
              updateTime = author?['pub_time'] ?? '';
            } else if (module['module_type'] == 'MODULE_TYPE_CONTENT') {
              var content = module['module_content'];
              if (content != null && content['paragraphs'] != null) {
                for (var para in content['paragraphs']) {
                  if (para['para_type'] == 1) {
                    if (para['text'] != null && para['text']['nodes'] != null) {
                      for (var node in para['text']['nodes']) {
                        if (node['type'] == 'TEXT_NODE_TYPE_WORD') {
                          opusContent += node['word']['words'];
                        }
                      }
                      opusContent += '<br/>';
                    }
                  } else if (para['para_type'] == 2) {
                    if (para['pic'] != null && para['pic']['pics'] != null) {
                      for (var pic in para['pic']['pics']) {
                        opusContent += '<img src="${pic['url']}"><br/>';
                      }
                    }
                  }
                }
              }
            } else if (module['module_type'] == 'MODULE_TYPE_DYNAMIC') {
               var desc = module['module_dynamic']?['desc'];
               if (desc != null && desc['text'] != null) {
                 opusContent += desc['text'];
               }
            }
          }
        } else {
          // fallback for old structure
          var author = detail?['module_author'];
          var desc = detail?['module_dynamic']?['desc'];
          var major = detail?['module_dynamic']?['major'];
          var opus = major?['opus'];
          var article = major?['article'];
          avatar = author?['face'] ?? '';
          uname = author?['name'] ?? '';
          updateTime = author?['pub_time'] ?? '';
          opusContent = desc?['text'] ?? '';
          String cover = '';
          if (opus != null) {
            opusContent = opusContent.isEmpty ? (opus['summary']?['text'] ?? '') : opusContent;
            cover = opus['pics']?.isNotEmpty == true ? opus['pics'][0]['url'] : '';
          } else if (article != null) {
            opusContent = opusContent.isEmpty ? (article['desc'] ?? '') : opusContent;
            cover = article['covers']?.isNotEmpty == true ? article['covers'][0] : '';
          }
          if (cover.isNotEmpty) cover = '<img src="$cover">';
          opusContent = cover + opusContent;
        }

        if (avatar.isNotEmpty) avatar = avatar.replaceFirst('http:', 'https:');
        String commentIdStr = detail?['basic']?['comment_id_str'] ?? id.toString();
        
        return {
          'status': true,
          'avatar': avatar,
          'uname': uname,
          'updateTime': updateTime,
          'content': opusContent,
          'commentId': int.parse(commentIdStr)
        };
      }
    } catch (err) {
      print('err: $err');
    }
  }

  // read
  static Future reqReadHtml(id, dynamicType) async {
    var response = await Request().get(
      "https://www.bilibili.com/$dynamicType/$id/",
      options: Options(headers: {
        HttpHeaders.userAgentHeader: 'Mozilla/5.0',
        HttpHeaders.refererHeader: 'https://www.bilibili.com/',
        HttpHeaders.cookieHeader: 'opus-goback=1',
      }),
    );
    Document rootTree = parse(response.data);
    Element body = rootTree.body!;
    Element appDom = body.querySelector('#app')!;
    Element authorHeader = appDom.querySelector('.up-left')!;
    // 头像
    // String avatar =
    //     authorHeader.querySelector('.bili-avatar-img')!.attributes['data-src']!;
    // 正则寻找形如"author":{"mid":\d+,"name":".*","face":"xxxx"的匹配项
    String avatar = RegExp(r'"author":\{"mid":\d+?,"name":".+?","face":"(.+?)"')
        .firstMatch(response.data)!
        .group(1)!
        .replaceAll(r'\u002F', '/')
        .split('@')[0];
    print("avatar: $avatar");
    String uname = authorHeader.querySelector('.up-name')!.text.trim();
    print("uname: $uname");
    // 动态详情
    Element opusDetail = appDom.querySelector('.article-content')!;
    // 发布时间
    // String updateTime =
    //     opusDetail.querySelector('.opus-module-author__pub__text')!.text;
    // print(updateTime);

    //
    String opusContent =
        opusDetail.querySelector('#read-article-holder')?.innerHtml ?? '';
    print("opusContent: $opusContent");
    if (opusContent.isEmpty) {
      // 查找形如"dyn_id_str":"(\d+)"的id
      String opusid =
          RegExp(r'"dyn_id_str":"(\d+)"').firstMatch(response.data)!.group(1)!;
      print("opusid: $opusid");
      if (opusid == id.toString()) {
        return {'status': false, 'data': null};
      }
      return await reqHtml(opusid, 'opus');
    }
    RegExp digitRegExp = RegExp(r'\d+');
    Iterable<Match> matches = digitRegExp.allMatches(id);
    String number = matches.first.group(0)!;
    return {
      'status': true,
      'avatar': avatar,
      'uname': uname,
      'updateTime': '',
      'content': opusContent,
      'commentId': int.parse(number)
    };
  }
}
