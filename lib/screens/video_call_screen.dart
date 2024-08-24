import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallScreen extends StatefulWidget {
  final String CallID;
  final String Username;
  CallScreen({super.key, required this.CallID, required this.Username});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    final textScale = MediaQuery.of(context).textScaleFactor;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade500,
        toolbarHeight: responsiveContainerSize(60, width, height),
        centerTitle: true,
        title: Text(
          "Video Meet",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: responsiveContainerSize(22, width, height)),
        ),
      ),
      body: ZegoUIKitPrebuiltCall(
          appSign: appSignZEGO,
          appID: appIDZego,
          callID: widget.CallID,
          userID: "${widget.CallID}_${widget.Username}",
          userName: widget.Username,
          config: ZegoUIKitPrebuiltCallConfig.groupVideoCall()),
    ));
  }
}
