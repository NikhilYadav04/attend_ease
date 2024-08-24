import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:flutter/material.dart';

AppBar appBEmployee(double currentWidth, double currentHeight, double textScale,BuildContext context) {
  return AppBar(
    actions: [
      IconButton(onPressed: (){
        Navigator.pop(context);
      }, icon: Icon(Icons.exit_to_app))
    ],
    automaticallyImplyLeading: false,
    backgroundColor: Colors.white,
    title: Text(
      "Join Company Account",
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

Widget tileWidgetEmployee(double currentWidth, double currentHeight, double textScale) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
    child: ListTile(
      title: Text(
        "Join Your Company's Group",
        style: TextStyle(
            fontFamily: "Tansek",
            fontSize:
                responsiveFontSize(28, currentWidth, currentHeight, textScale),
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800),
      ),
      subtitle: Text(
        "Monitor your attendance digitally",
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

Widget textFieldEmployee(double currentWidth, double currentHeight, double textScale,
    String label, String title,TextEditingController textCOntroller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize:
              responsiveFontSize(16, currentWidth, currentHeight, textScale),
        ),
      ),
      SizedBox(
        height: responsiveContainerSize(10, currentWidth, currentHeight),
      ),
      FormField(builder: (context) {
        return TextField(
          controller: textCOntroller,
          decoration: InputDecoration(
            label: Text(
              label,
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize:
                      responsiveContainerSize(17, currentWidth, currentHeight)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade500),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: BUTTON_COLOR_1),
            ),
          ),
        );
      })
    ],
  );
}