// ignore_for_file: unnecessary_new

import 'dart:convert';

import '../src/classes/route.dart';
import '../src/enums.dart';
import '../src/classes/sub_route.dart';
import 'package:http/http.dart' as HTTP;

import '../src/classes/station.dart';

class MenetrendAPI {
  //Base authory & authory path
  final String _baseURL = "menetrendek.hu";
  final String _basePath = "/menetrend/interface/index.php";

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
    int? hours = null, //The start hour
    int? minutes = null, //The minutes of the start hour
    DateTime? searchDate = null, //Start date of the search
    bool backAndForth = false, //This route go there & back?
    bool getAllResult = false, //Get all route, regardless of the time of day
    RouteDirection routeDirection =
        RouteDirection.There, //Target route direction
  }) async {
    //The result(s)
    List<Route> routes = [];

    late PartOfTheDay partOfTheDay;
    late Map<String, dynamic> parameters;

    //Init the variables (date - hour - minutes)
    String date =
        "${DateTime.now().year}-${DateTime.now().month < 10 ? "0${DateTime.now().month}" : DateTime.now().month}-${DateTime.now().day < 10 ? "0${DateTime.now().day}" : DateTime.now().day}";

    String hour = DateTime.now().hour < 10
        ? "0${DateTime.now().hour}"
        : "${DateTime.now().hour}";

    String minute = DateTime.now().minute < 10
        ? "0${DateTime.now().minute}"
        : "${DateTime.now().minute}";

    //Check any parameters for null value
    if (searchDate != null) {
      date =
          "${searchDate.year}-${searchDate.month < 10 ? "0${searchDate.month}" : searchDate.month}-${searchDate.day < 10 ? "0${searchDate.day}" : searchDate.day}";
    }

    if (hours != null) {
      hour = "${hours}";
    }

    if (minutes != null) {
      minute = "${minutes}";
    }

    //Set the part of the day value by hours variable
    if (!getAllResult) {
      switch ((hours! / 8).floor()) {
        case 1:
          partOfTheDay = PartOfTheDay.During_The_Day;
          break;
        case 2:
          partOfTheDay = PartOfTheDay.Evening;
          break;
        default:
          partOfTheDay = PartOfTheDay.Dawn;
          break;
      }

      parameters = {
        "datum": date,
        "hour": hour,
        "min": minute,
        "naptipus": 0,
        "preferencia": 0,
        "keresztul": through,
        "napszak": "${partOfTheDay.index + 1}",
        "maxwalk": walkDistanceInMeters,
        "maxatszallas": "${transferCount}",
        "maxvar": "${waitInMinutes}",
        "rendezes": 1,
        "honnan": from,
        "hova": to,
      };
    } else {
      parameters = {
        "datum": date,
        "hour": hour,
        "min": minute,
        "naptipus": 0,
        "preferencia": 0,
        "keresztul": through,
        "maxwalk": walkDistanceInMeters,
        "maxatszallas": "${transferCount}",
        "maxvar": "${waitInMinutes}",
        "rendezes": 1,
        "honnan": from,
        "hova": to,
      };
    }

    //The query parameters

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
    if (all_results.values.contains("error")) {
      throw new Exception(
        all_results["errMsg"],
      );
    }

    Map<String, dynamic> stationResults = all_results["results"]["talalatok"];

    //Set all routes
    for (int i = 0; i < stationResults.length; i++) {
      List<SubRoute> subRoutes = [];

      List<dynamic> nativeInformations =
          stationResults["${i + 1}"]["nativeData"];

      for (int j = 0; j < nativeInformations.length; j++) {
        String _routeName = nativeInformations[j]["DomainCompanyName"];

        int _ticketPrice = nativeInformations[j]["Fare"];
        int _additionaltPrice = nativeInformations[j]["FareExtra"];
        int _seatPrice = nativeInformations[j]["FareSeatRes"];
        int _duration = nativeInformations[j]["ArrivalTime"];

        double _distance = (nativeInformations[j]["Distance"] as int) / 1000;

        bool _wifi = nativeInformations[j]["Wifi"] != 0;
        bool _highSpeed = nativeInformations[j]["HighSpeed"] != 0;
        bool _lowFloor = nativeInformations[j]["LowFloor"] != 0;
        bool _preBuy = nativeInformations[j]["Prebuy"] != 0;

        int hour = ((nativeInformations[j]["DepartureTime"] / 60) as double)
            .floor()
            .abs();

        int minutess = ((nativeInformations[j]["DepartureTime"] / 60) as double)
            .floor()
            .abs();

        minutess =
            ((nativeInformations[j]["DepartureTime"] as int) - (hour * 60))
                .floor();

        DateTime _startDate = searchDate ??
            new DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day, hour, minutess);

        hour = ((nativeInformations[j]["ArrivalTime"] / 60) as double).floor();

        minutess = ((((nativeInformations[j]["ArrivalTime"] / 60) -
                    ((nativeInformations[j]["ArrivalTime"] / 60) as double)
                        .round()) *
                60) as double)
            .floor();

        DateTime _arrivalDate = searchDate ??
            new DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day, hour, minutess);

        if (searchDate != null) {
          _startDate = new DateTime(searchDate.year, searchDate.month,
              searchDate.day, hour, minutess);
        }

        Station _startStation = new Station(
          nativeInformations[j]["DepStationName"],
          nativeInformations[j]["DepartureStation"],
          nativeInformations[j]["FromSettle"],
          nativeInformations[j]["DepartureSettle"],
          StationType.Station,
        );

        Station _arrivalStation = new Station(
          nativeInformations[j]["ArrStationName"],
          nativeInformations[j]["ArrivalStation"],
          nativeInformations[j]["ToSettle"],
          nativeInformations[j]["ArrivalSettle"],
          StationType.Station,
        );

        SubRoute subRoute = new SubRoute(
          start: _startStation,
          target: _arrivalStation,
          name: _routeName,
          startDate: _startDate,
          arrivalDate: _arrivalDate,
          duration: _startDate.difference(_arrivalDate),
          distance: _distance,
          ticketPrice: _ticketPrice,
          additionalTicketPrice: _additionaltPrice,
          seatTicketPrice: _seatPrice,
          hasWifi: _wifi,
          highSpeedVehilce: _highSpeed,
          eTicket: _preBuy,
          risky: false,
        );

        subRoutes.add(subRoute);
      }

      routes.add(new Route(subRoutes));
    }

    return routes;
  }

  Future<List<Station>> getStationOrAddrByText(
      {required String stateName, String searchIn = "stations"}) async {
    List<Station> result = [];

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
        new Station(
          item["lsname"],
          item["ls_id"],
          item["settlement_name"],
          item["settlement_id"] is String
              ? int.parse(item["settlement_id"])
              : item["settlement_id"],
          item["type"] as String == "telepules"
              ? StationType.Settlement
              : StationType.Station,
        ),
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
