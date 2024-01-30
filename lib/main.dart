import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trtc_demo/page/trtcmeetingdemo/index.dart';
import 'package:trtc_demo/page/trtcmeetingdemo/meeting.dart';
import 'package:trtc_demo/page/trtcmeetingdemo/member_list.dart';
import 'package:trtc_demo/page/trtcmeetingdemo/test_api.dart';
import 'package:trtc_demo/models/meeting.dart';
import 'package:trtc_demo/page/trtcmeetingdemo/texture_render.dart';
import 'package:trtc_demo/page/trtcmeetingdemo/test_web.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MeetingModel(),
      child: MaterialApp(
        routes: {
          "/": (context) => IndexPage(),
          "/index": (context) => IndexPage(),
          "/video": (context) => MeetingPage(),
          "/textureRender": (context) => TextureRenderPage(),
          "/memberList": (context) => MemberListPage(),
          "/test": (context) => TestPage(),
          "/testweb": (context) => TestWebPage()
        },
      ),
    );
  }
}
