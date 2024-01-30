import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:trtc_demo/models/meeting.dart';
import 'package:provider/provider.dart';
import 'package:trtc_demo/page/trtcmeetingdemo/tool.dart';

/// Member list page
class MemberListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MemberListPageState();
}

class MemberListPageState extends State<MemberListPage> {
  late TRTCCloud trtcCloud;
  var meetModel;
  var userInfo;
  List micList = [];
  var micMap = {};
  @override
  initState() {
    super.initState();
    initRoom();
    meetModel = context.read<MeetingModel>();
    userInfo = meetModel.getUserInfo();
    micList = meetModel.getList();
  }

  initRoom() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
  }

  @override
  dispose() {
    super.dispose();
    micList = [];
    micMap = {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member List'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromRGBO(14, 25, 44, 1),
      ),
      body: Container(
        color: Color.fromRGBO(14, 25, 44, 1),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Consumer<MeetingModel>(
                builder: (context, meet, child) {
                  List newList = [];
                  meet.userList.forEach((item) {
                    if (item['type'] == 'video') {
                      newList.add(item);
                    }
                  });
                  micList = newList;
                  return ListView(
                    children: newList
                        .map<Widget>((item) => Container(
                              key: ValueKey(item['userId']),
                              height: 50,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(item['userId'],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16)),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Offstage(
                                      offstage:
                                          item['userId'] == userInfo['userId'],
                                      child: IconButton(
                                          icon: Icon(
                                            micMap[item['userId']] == null
                                                ? Icons.mic
                                                : Icons.mic_off,
                                            color: Colors.white,
                                            size: 36.0,
                                          ),
                                          onPressed: () {
                                            if (micMap[item['userId']] ==
                                                null) {
                                              micMap[item['userId']] = true;
                                              trtcCloud.muteRemoteAudio(
                                                  item['userId'], true);
                                            } else {
                                              micMap.remove(item['userId']);
                                              trtcCloud.muteRemoteAudio(
                                                  item['userId'], false);
                                            }
                                            this.setState(() {});
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ),
            new Align(
                child: new Container(
                  // grey box
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(
                                color: Color.fromRGBO(245, 108, 108, 1))),
                        onPressed: () {
                          trtcCloud.muteAllRemoteAudio(true);
                          MeetingTool.toast('Total silence', context);
                          for (var i = 0; i < micList.length; i++) {
                            micMap[micList[i]['userId']] = true;
                          }
                          this.setState(() {});
                        },
                        child: Text('Total silence',
                            style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(
                                color: Color.fromRGBO(64, 158, 255, 1))),
                        onPressed: () {
                          trtcCloud.muteAllRemoteAudio(false);
                          MeetingTool.toast('Lift all bans', context);
                          this.setState(() {
                            micMap = {};
                          });
                        },
                        child: Text('Lift all bans',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  height: 50.0,
                ),
                alignment: Alignment.bottomCenter),
          ],
        ),
      ),
    );
  }
}
