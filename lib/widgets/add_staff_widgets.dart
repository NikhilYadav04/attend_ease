import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:flutter/material.dart';

AppBar appBStaff(double currentWidth, double currentHeight, double textScale,
    BuildContext context) {
  return AppBar(
    actions: [
      IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.exit_to_app))
    ],
    automaticallyImplyLeading: false,
    backgroundColor: Colors.white,
    title: Text(
      "Add Employee Details",
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

Widget textFieldStaff(
    double currentWidth,
    double currentHeight,
    double textScale,
    String label,
    String title,
    TextEditingController textCOntroller,
    String value) {
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

Widget multipleWidget(
    double currentWidth, double currentHeight, double textScale) {
  return Container(
    height: responsiveContainerSize(60, currentWidth, currentHeight),
    decoration: BoxDecoration(
        color: BUTTON_COLOR_2, borderRadius: BorderRadius.circular(6)),
    child: Center(
      child: Text(
        "Now Add Multiple Staff using Attend Ease App",
        style: TextStyle(
            color: BUTTON_COLOR_1,
            fontSize:
                responsiveFontSize(17, currentWidth, currentHeight, textScale),
            fontWeight: FontWeight.bold),
      ),
    ),
  );
}

Widget numberFieldStaff(
    double currentWidth,
    double currentHeight,
    double textScale,
    String label,
    String title,
    TextEditingController textCOntroller,
    String value) {
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
      Row(
        children: [
          Container(
            height: responsiveContainerSize(57, currentWidth, currentHeight),
            width: responsiveContainerSize(70, currentWidth, currentHeight),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade500)),
            child: Center(
              child: Text(
                "+91 ",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontFamily: "Tansek",
                  fontSize: responsiveFontSize(
                      32, currentWidth, currentHeight, textScale),
                ),
              ),
            ),
          ),
          SizedBox(
            width: responsiveContainerSize(20, currentWidth, currentHeight),
          ),
          Expanded(
            child: FormField(builder: (context) {
              return TextField(
                controller: textCOntroller,
                decoration: InputDecoration(
                  label: Text(
                    label,
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: responsiveContainerSize(
                            17, currentWidth, currentHeight)),
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
            }),
          ),
        ],
      )
    ],
  );
}

Widget addText(double currentWidth, double currentHeight, double textScale) {
  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.contacts_rounded,
          color: BUTTON_COLOR_1,
          size: responsiveContainerSize(28, currentWidth, currentHeight),
        ),
        Text(
          "  Add from Contacts",
          style: TextStyle(
            color: BUTTON_COLOR_1,
            fontWeight: FontWeight.bold,
            fontSize:
                responsiveFontSize(22, currentWidth, currentHeight, textScale),
          ),
        ),
      ],
    ),
  );
}

Widget addEmployeeButton(void Function() onTap, double width, double height,
    double textScaleFactor, BuildContext context) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin:
          EdgeInsets.symmetric(horizontal: 0 * horizontalPaddingFactor(width)),
      padding: EdgeInsets.symmetric(
          horizontal: 5 * horizontalPaddingFactor(width),
          vertical: 5 * verticalPaddingFactor(height)),
      height: responsiveContainerSize(55, width, height),
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(responsiveBorderRadius(6, width, height)),
          color: BUTTON_COLOR_1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Add Employee",
            style: TextStyle(
                color: Colors.white,
                fontSize:
                    responsiveFontSize(22, width, height, textScaleFactor),
                fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_circle_right,
              color: Colors.white,
              size: responsiveContainerSize(30, width, height),
            ),
            onPressed: () {},
          )
        ],
      ),
    ),
  );
}