import 'dart:convert';
import 'dart:math';

import 'package:menetrendek_api/src/enums.dart';
import 'package:menetrendek_api/src/route.dart';
import 'package:http/http.dart' as HTTP;

class MenetrendAPI {
  //Base authory & authory path
  String _baseURL = "menetrendek.hu";
  String _basePath = "/menetrend/interface/index.php";

  //One instance for query (singleton pattern)
  static MenetrendAPI get Instance {
    return new MenetrendAPI();
  }

  ///Query all actual routes in two stations.
  Future<List<Route>> getActualRoutes({
    required String from, //Start station or state
    required String to, //End station or state
    required int fromID, //Start station or state ID
    required int toID, //End station or state ID
    String through = "", //Through station(s) or state(s)
    int walkDistanceInMeters = 1000, //Max distance to next station
    int transferCount = 5, //Max transfer count in bus
    int waitInMinutes = 240, //Max wait limit
    bool backAndForth = false, //This route go there & back?
    RouteDirection routeDirection =
        RouteDirection.There, //Target route direction
    PartOfTheDay partOfTheDay =
        PartOfTheDay.During_The_Day, //Part of the day in query
  }) async {
    //The result(s)
    List<Route> routes = [];

    //The query parameters
    Map<String, dynamic> parameters = {
      "datum":
          "${DateTime.now().year}-${DateTime.now().month < 10 ? "0${DateTime.now().month}" : DateTime.now().month}-${DateTime.now().day < 10 ? "0${DateTime.now().day}" : DateTime.now().day}",
      "hour": DateTime.now().hour < 10
          ? "0${DateTime.now().hour}"
          : "${DateTime.now().hour}",
      "min": DateTime.now().minute < 10
          ? "0${DateTime.now().minute}"
          : "${DateTime.now().minute}",
      "naptipus": 0,
      "preferencia": 0,
      "keresztul": through,
      "napszak": "${partOfTheDay.index + 1}",
      "maxwalk": walkDistanceInMeters,
      "maxatszallas": "${transferCount}",
      "maxvar": "${waitInMinutes}",
      "honnan": from,
      "hova": to,
    };

    //Convert to JSON body
    String body = _toJSON(parameters, "getRoutes");

    //Set the url
    Uri url = Uri.https(_baseURL, _basePath);

    //Send the request
    HTTP.Response response = await HTTP.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    //Decode the JSON
    Map<String, dynamic> all_results = jsonDecode(response.body);

    //If have any problem, throw a exception with the error messange
    if (all_results.values.contains("error"))
      throw new Exception(
        all_results["errMsg"],
      );

    Map<String, dynamic> stationResults = all_results["results"]["talalatok"];

    //Set all routes
    for (int i = 0; i < stationResults.length; i++) {
      //Set all parameters (See more route.dart file)
      Map<String, dynamic> start = {
        "departureCity": stationResults["${i + 1}"]["departureCity"],
        "departureStation": stationResults["${i + 1}"]["departureStation"],
      };

      Map<String, dynamic> target = {
        "arrivalCity": stationResults["${i + 1}"]["arrivalCity"],
        "arrivalStation": stationResults["${i + 1}"]["arrivalStation"],
      };

      String name =
          stationResults["${i + 1}"]["jaratinfok"]["0"]["vonalnev"] as String;

      double distance =
          stationResults["${i + 1}"]["jaratinfok"]["0"]["distance"] as double;

      int transferCount =
          stationResults["${i + 1}"]["atszallasok_szama"] as int;

      int ticketPrice =
          stationResults["${i + 1}"]["jaratinfok"]["0"]["fare"] as int;

      int seatTicketPrice = stationResults["${i + 1}"]["jaratinfok"]["0"]
          ["seat_ticket_price"] as int;

      int additionalTicketPrice = stationResults["${i + 1}"]["jaratinfok"]["0"]
          ["additional_ticket_price"] as int;

      bool hasWifi =
          stationResults["${i + 1}"]["jaratinfok"]["0"]["wifi"] as int == 1;

      bool isHighSpeedVehilce = stationResults["${i + 1}"]["jaratinfok"]["0"]
              ["nagysebessegu"] as int ==
          1;

      bool eTicketIsAvailable = stationResults["${i + 1}"]["jaratinfok"]["0"]
              ["internetes_jegy"] as int ==
          1;

      bool isRisky = stationResults["${i + 1}"]["riskyTransfer"] as bool;

      int year = int.parse(
          all_results["results"]["date_got"].toString().split('-')[0]);
      int month = int.parse(
          all_results["results"]["date_got"].toString().split('-')[1]);
      int day = int.parse(
          all_results["results"]["date_got"].toString().split('-')[2]);

      int hour = int.parse(
          stationResults["${i + 1}"]["indulasi_ido"].toString().split(':')[0]);
      int minutes = int.parse(
          stationResults["${i + 1}"]["indulasi_ido"].toString().split(':')[1]);

      DateTime startDate = new DateTime(year, month, day, hour, minutes);

      hour = int.parse(
          stationResults["${i + 1}"]["erkezesi_ido"].toString().split(':')[0]);
      minutes = int.parse(
          stationResults["${i + 1}"]["erkezesi_ido"].toString().split(':')[1]);

      DateTime arrivalDate = new DateTime(year, month, day, hour, minutes);

      hour = int.parse(
          stationResults["${i + 1}"]["osszido"].toString().split(':')[0]);
      minutes = int.parse(
          stationResults["${i + 1}"]["osszido"].toString().split(':')[1]);

      Duration duration = new Duration(days: 0, hours: hour, minutes: minutes);

      routes.add(
        new Route(
            startLocation: start,
            targetLocation: target,
            name: name,
            startDate: startDate,
            arrivalDate: arrivalDate,
            duration: duration,
            transferCount: transferCount,
            distance: distance,
            ticketPrice: ticketPrice,
            additionalTicketPrice: additionalTicketPrice,
            seatTicketPrice: seatTicketPrice,
            hasWifi: hasWifi,
            highSpeedVehilce: isHighSpeedVehilce,
            eTicket: eTicketIsAvailable,
            risky: isRisky),
      );
    }

    return routes;
  }

  Future<List<Map<String, dynamic>>> getStationOrAddrByText(
      {required String stateName, String searchIn = "stations"}) async {
    List<Map<String, dynamic>> result = [];

    //Query parameters
    Map<String, dynamic> parameters = {
      "inputText": stateName,
      "searchIn": searchIn,
    };

    //Convert to JSON body
    String body = _toJSON(parameters, "getStationOrAddrByText");

    //Set the url
    Uri url = Uri.https(_baseURL, _basePath);

    //Send the request
    HTTP.Response response = await HTTP.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    //Decode the response JSON
    Map<String, dynamic> temp = jsonDecode(response.body);

    //Set the return
    for (Map item in temp["results"]) {
      result.add(
        {
          "lsname": item["lsname"],
          "ls_id": item["ls_id"],
          "site_code": item["site_code"],
          "settlement_id": item["settlement_id"] is String
              ? int.parse(item["settlement_id"])
              : item["settlement_id"],
        },
      );
    }

    return result;
  }

  //Return a JSON String
  String _toJSON(Map<String, dynamic> elements, String method) {
    String result = "{\"func\":\"${method}\",";

    //Select the specified method fot the convert
    switch (method) {
      //getRoutes
      case "getRoutes":
        result +=
            "\"params\":{\"honnan\":\"${elements["honnan"]}\",\"hova\":\"${elements["hova"]}\",";

        //Convert all elemenets
        for (int i = 0; i < elements.length; i++) {
          if (elements.keys.elementAt(i) == "honnan" ||
              elements.keys.elementAt(i) == "hova") {
            break;
          }

          switch (elements.values.elementAt(i).runtimeType) {
            case int:
              result +=
                  "\"${elements.keys.elementAt(i)}\":${elements.values.elementAt(i)},";
              continue;
            case String:
              result +=
                  "\"${elements.keys.elementAt(i)}\":\"${elements.values.elementAt(i)}\",";
              continue;
          }
        }

        result +=
            "\"searchInput\":{\"from\":{\"ls_id\":399},\"to\":{\"ls_id\":599},\"through\":null}}}";
        return result;

      //getStationOrAddrByText
      case "getStationOrAddrByText":
        result +=
            "\"params\":{\"inputText\":\"${elements["inputText"]}\", \"searchIn\":[\"${elements["searchIn"]}\"]}}";

        return result;

      default:
        //If the method name is bad or the method is not exist
        throw new Exception(
            "This method is not exist! Method name: ${method}. Existing methods: \"getRoutes\", \"getStationOrAddrByText\"");
    }
  }
}
