import 'dart:convert';

import 'package:attend_ease/constants/url_constants.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/models/locationModel.dart';
import 'package:http/http.dart' as http;

class locationService {
  // set location
  Future<String> setLocation(String? latitude, String? longitude,
      String companyName, double radius) async {
    try {
      Uri url = Uri.parse(set_location_baseUrl);

      Locationmodel locationBody = Locationmodel(
          latitude: latitude,
          longitude: longitude,
          companyName: companyName,
          radius: radius);

      var res = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: locationBody.toJson());
      var body = jsonDecode(res.body);
      print(body);
      if (res.statusCode == 200) {
        print(body['message']);
        return "Stored";
      } else {
        print(body["message"]);
        return body['message'];
      }
    } catch (e) {
      return e.toString();
    }
  }

  // get location
  Future<String> getLocation(String? companyName) async {
    try {
      Uri url = Uri.parse(get_location_baseUrl);

      var body = {"companyName": companyName};

      var res = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body));

      var resBody = jsonDecode(res.body);
      var locationBody = resBody['message'];
      print("Locatiobody is ${locationBody}");
      print("Radius id ${locationBody['radius']}");

      if (res.statusCode == 200) {
        Latitude1 = double.parse(locationBody['latitude']);
        Longitude1 = double.parse(locationBody['longitude']);
        radius = locationBody['radius'];

        return "Success";
      } else {
        return resBody['message'];
      }
    } catch (e) {
      return e.toString();
    }
  }
}
