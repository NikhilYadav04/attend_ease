import 'package:attend_ease/constants/scale.dart';
import 'package:flutter/material.dart';

AppBar appBLoginCompany(double currentWidth, double currentHeight, double textScale,BuildContext context) {
  return AppBar(
    actions: [
      IconButton(onPressed: (){
        Navigator.pop(context);
      }, icon: Icon(Icons.exit_to_app))
    ],
    automaticallyImplyLeading: false,
    backgroundColor: Colors.white,
    title: Text(
      "Join Company as HR",
      style: TextStyle(
          color: Colors.black,
          fontFamily: "Tansek",
          fontWeight: FontWeight.w500,
          fontSize:
              responsiveFontSize(34, currentWidth, currentHeight, textScale)),
    ),
    toolbarHeight: responsiveContainerSize(75, currentWidth, currentHeight),
    elevation: 5,
    shadowColor: Colors.grey,
  );
}

Widget tileWidgetLoginCompany(double currentWidth, double currentHeight, double textScale) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
    child: ListTile(
      title: Text(
        "Lead Your Company's Group",
        style: TextStyle(
            fontFamily: "Tansek",
            fontSize:
                responsiveFontSize(28, currentWidth, currentHeight, textScale),
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800),
      ),
      subtitle: Text(
        "Monitor your staff's attendance",
        style: TextStyle(
            fontFamily: "Tansek",
            fontSize:
                responsiveFontSize(24, currentWidth, currentHeight, textScale),
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade800),
      ),
      trailing: CircleAvatar(
        backgroundColor: Colors.white,
        radius: responsiveBorderRadius(22, currentWidth, currentHeight),
        child: Icon(
          Icons.security_update_good,
          color: Colors.blue.shade800,
          size: responsiveContainerSize(26, currentWidth, currentHeight),
        ),
      ),
    ),
  );
}