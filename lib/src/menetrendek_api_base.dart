// ignore_for_file: unnecessary_new, prefer_conditional_assignment, avoid_init_to_null

//Core library
import 'dart:convert';

//The created classes
import '../src/classes/route.dart';
import '../src/enums.dart';
import '../src/classes/sub_route.dart';
import '../src/classes/station.dart';

//HTTPS library
import 'package:http/http.dart' as HTTP;

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
    required Station from, //Start station or state
    required Station to, //End station or state
    Station? through = null, //Through station(s) or state(s)
    int walkDistanceInMeters = 0, //Max distance to next station
    int transferCount = 0, //Max transfer count in bus
    int maxWaitTime = 0, //Max wait limit
    DateTime? searchDate = null, //Start date of the search
    bool backAndForth = false, //This route go there & back?
    PartOfTheDay partOfTheDay = PartOfTheDay
        .None_Specified, //Get all route, regardless of the time of day
    RouteDirection routeDirection =
        RouteDirection.There, //Target route direction
  }) async {
    //Check the vehicle type of the stations is the same
    if (from.Vehilce_Type != to.Vehilce_Type) {
      throw new Exception("A jármüvek típusa nem egyezzik!");
    }

    //The result(s)
    List<Route> routes = [];

    //Set common parameters
    Map<String, dynamic> parameters = _initCommonInfo(searchDate);

    //Set the part of the day value by hours variable
    if (partOfTheDay == PartOfTheDay.None_Specified) {
      PartOfTheDay _partOfTheDay =
          _setPartOFTheDay(int.tryParse(parameters["hour"]));

      //Set all parameters
      parameters.addAll(
        {
          "networks": [
            from.Vehilce_Type,
          ],
          "naptipus": 0,
          "preferencia": 0,
          "keresztul": through,
          "napszak": "${_partOfTheDay.index + 1}",
          "maxwalk": walkDistanceInMeters,
          "maxatszallas": "${transferCount}",
          "maxvar": "${maxWaitTime}",
          "rendezes": 1,
          "honnan": from.StationName,
          "hova": to.StationName,
        },
      );
    } else {
      parameters.addAll(
        {
          "naptipus": 0,
          "preferencia": 0,
          "keresztul": through,
          "maxwalk": walkDistanceInMeters,
          "maxatszallas": "${transferCount}",
          "maxvar": "${maxWaitTime}",
          "rendezes": 1,
          "honnan": from.StationName,
          "hova": to.StationName,
        },
      );
    }

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

    //Set the report date
    DateTime _resultDate = DateTime.parse(all_results["results"]["date_got"]);

    //Iterate until the end of the result objects
    for (int i = 0; i < stationResults.length; i++) {
      //Sub routes
      List<SubRoute> subRoutes = [];

      List<dynamic> nativeInformations =
          stationResults["${i + 1}"]["nativeData"];

      for (int j = 0; j < nativeInformations.length; j++) {
        String _routeName = nativeInformations[j]["DomainCompanyName"];

        int _ticketPrice = nativeInformations[j]["Fare"] as int;
        int _additionaltPrice = nativeInformations[j]["FareExtra"] as int;
        int _seatPrice = nativeInformations[j]["FareSeatRes"] as int;
        int _duration = nativeInformations[j]["ArrivalTime"] as int;

        double _distance = (nativeInformations[j]["Distance"]) / 1000;

        bool _wifi = nativeInformations[j]["Wifi"] != 0;
        bool _highSpeed = nativeInformations[j]["HighSpeed"] != 0;
        bool _lowFloor = nativeInformations[j]["LowFloor"] != 0;
        bool _preBuy = nativeInformations[j]["Prebuy"] != 0;

        DateTime _startDate = new DateTime(_resultDate.year, _resultDate.month,
            _resultDate.day, 0, nativeInformations[j]["DepartureTime"] as int);

        DateTime _arrivalDate = new DateTime(
            _resultDate.year,
            _resultDate.month,
            _resultDate.day,
            0,
            nativeInformations[j]["ArrivalTime"] as int);

        Station _startStation = new Station(
          nativeInformations[j]["DepStationName"],
          nativeInformations[j]["DepartureStation"],
          nativeInformations[j]["NetworkId"],
          nativeInformations[j]["FromSettle"],
          nativeInformations[j]["DepartureSettle"],
          nativeInformations[j]["LocalDomainCode"] != "",
          StationType.Station,
        );

        Station _arrivalStation = new Station(
          nativeInformations[j]["ArrStationName"],
          nativeInformations[j]["ArrivalStation"],
          nativeInformations[j]["NetworkId"],
          nativeInformations[j]["ToSettle"],
          nativeInformations[j]["ArrivalSettle"],
          nativeInformations[j]["LocalDomainCode"] != "",
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

  ///Search the stations or adressess by input
  Future<List<Station>> getStationOrAddrByText({
    required String stateName,
    String searchIn = "stations", //The search area
    List<VehicleType> vehicles = const [], //The specified vehicles
    bool local = false, //Search local stations?
  }) async {
    List<Station> result = [];
    List<int> vehiclesInInt = [];

    //Convert the vehicles to integer identifiers
    if (!vehicles.isEmpty) {
      for (VehicleType item in vehicles) {
        vehiclesInInt
            .addAll(VehicleTypeAdapter.Instance.getVehicleTypeInInt(item));
      }
    }

    //Query parameters
    Map<String, dynamic> parameters = {
      "inputText": stateName,
      "searchIn": searchIn,
      "networks": vehiclesInInt,
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
    for (Map<String, dynamic> item in temp["results"]) {
      //If the local parameters is false
      if (item.containsValue("Helyi autóbusz -") && !local) {
        continue;
      }

      Station station = new Station(
        item["lsname"],
        item["ls_id"],
        item["network_id"],
        item["settlement_name"],
        item["settlement_id"] is String
            ? int.parse(item["settlement_id"])
            : item["settlement_id"],
        item.containsValue("Helyi autóbusz -"),
        item["type"] as String == "telepules"
            ? StationType.Settlement
            : StationType.Station,
      );

      result.add(station);
    }

    return result;
  }

  ///Search all routes, wich starting from the input
  Future<List<Route>> getTimeTable({
    required Station from,
    DateTime? date = null,
    int maxWaitTime = 0,
    int maxWalkDistance = 0,
    int maxTransferCount = 0,
    int interval = 24,
    int maxResult = 10,
    PartOfTheDay partOfTheDay = PartOfTheDay.None_Specified,
    RouteDirection direction = RouteDirection.There,
  }) async {
    //The routes
    List<Route> _routes = [];

    //Set the primary parameters
    Map<String, dynamic> parameters = _initCommonInfo(date);

    //Set the part of the day value by hours variable
    if (partOfTheDay != PartOfTheDay.None_Specified) {
      PartOfTheDay _partOfTheDay =
          _setPartOFTheDay(int.tryParse(parameters["hour"]));

      //Set all parameters
      parameters.addAll(
        {
          "networks": [
            from.Vehilce_Type,
          ],
          "naptipus": 0,
          "preferencia": "0",
          "napszak": "${_partOfTheDay.index + 1}",
          "maxwalk": maxWalkDistance,
          "maxatszallas": "${maxTransferCount}",
          "maxvar": "${maxWaitTime}",
          "rendezes": 1,
          "maxCount": maxResult,
          "helyi": "No",
          "erk_stype": "megallo",
          "utirany": "oda",
          "interval": interval * 60,
          "honnan": from.StationName,
          "honnan_ls_id": from.StationID,
        },
      );
    } else {
      parameters.addAll(
        {
          "networks": [
            from.Vehilce_Type,
          ],
          "naptipus": 0,
          "preferencia": "0",
          "maxwalk": maxWalkDistance,
          "maxatszallas": "${maxTransferCount}",
          "maxvar": "${maxWaitTime}",
          "rendezes": 1,
          "maxCount": maxResult,
          "helyi": "No",
          "erk_stype": "megallo",
          "utirany": "oda",
          "interval": interval * 60,
          "honnan": from.StationName,
          "honnan_ls_id": from.StationID,
        },
      );
    }

    //Convert to JSON body
    String body = _toJSON(parameters, "getTimeTableC");

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

    //Get the necessary map object
    Map<String, dynamic> stationResults = all_results["results"]["talalatok"];

    //Set the report date
    DateTime _resultDate = DateTime.parse(all_results["results"]["date_got"]);

    //Iterate until the end of the result objects
    for (int i = 0; i < stationResults.length; i++) {
      //Sub routes
      List<SubRoute> subRoutes = [];

      //The native datas of current report object
      List<dynamic> nativeInformations =
          stationResults["${i + 1}"]["nativeData"];

      for (int j = 0; j < nativeInformations.length; j++) {
        //All informations of the route
        String _routeName = nativeInformations[j]["DomainCompanyName"];

        int _ticketPrice = nativeInformations[j]["Fare"] as int;
        int _additionaltPrice = nativeInformations[j]["FareExtra"] as int;
        int _seatPrice = nativeInformations[j]["FareSeatRes"] as int;
        int _arrivalTime = nativeInformations[j]["ArrivalTime"] as int;
        int _depTime = nativeInformations[j]["DepartureTime"] as int;

        double _distance = (nativeInformations[j]["Distance"] as int) / 1000;

        bool _wifi = nativeInformations[j]["Wifi"] != 0;
        bool _highSpeed = nativeInformations[j]["HighSpeed"] != 0;
        bool _lowFloor = nativeInformations[j]["LowFloor"] != 0;
        bool _preBuy = nativeInformations[j]["Prebuy"] != 0;

        //If exist this element: "StartStaion", than the departure place equal
        //the start station place
        if (nativeInformations[j].containsKey("StartStation")) {
          int _startTime = nativeInformations[j]["StartTime"] as int;

          DateTime _startDate = new DateTime(_resultDate.year,
              _resultDate.month, _resultDate.day, 0, _startTime);

          DateTime _arrivalDate = new DateTime(_resultDate.year,
              _resultDate.month, _resultDate.day, 0, _arrivalTime);

          //Create Staion objects
          Station _arrivalStation = new Station(
            nativeInformations[j]["ArrStationName"],
            nativeInformations[j]["ArrivalStation"],
            nativeInformations[j]["NetworkId"],
            nativeInformations[j]["ToSettle"],
            nativeInformations[j]["ArrivalSettle"],
            nativeInformations[j]["LocalDomainCode"] != "",
            StationType.Station,
          );

          Station _startStation = new Station(
            nativeInformations[j]["StartStationName"],
            nativeInformations[j]["StartStation"],
            nativeInformations[j]["NetworkId"],
            nativeInformations[j]["StartSettleName"],
            nativeInformations[j]["StartSettle"],
            nativeInformations[j]["LocalDomainCode"] != "",
            StationType.Station,
          );

          //Create the SubRoute objects
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

          //Add the sub route
          subRoutes.add(subRoute);

          continue;
        }

        //Departure / Start time
        DateTime _deptDate = new DateTime(
            _resultDate.year, _resultDate.month, _resultDate.day, 0, _depTime);

        //Arrival time
        DateTime _arrivalDate = new DateTime(_resultDate.year,
            _resultDate.month, _resultDate.day, 0, _arrivalTime);

        //Create Staion objects
        Station _depStation = new Station(
          nativeInformations[j]["DepStationName"],
          nativeInformations[j]["DepartureStation"],
          nativeInformations[j]["NetworkId"],
          nativeInformations[j]["FromSettle"],
          nativeInformations[j]["DepartureSettle"],
          nativeInformations[j]["LocalDomainCode"] != "",
          StationType.Station,
        );

        Station _arrivalStation = new Station(
          nativeInformations[j]["ArrStationName"],
          nativeInformations[j]["ArrivalStation"],
          nativeInformations[j]["NetworkId"],
          nativeInformations[j]["ToSettle"],
          nativeInformations[j]["ArrivalSettle"],
          nativeInformations[j]["LocalDomainCode"] != "",
          StationType.Station,
        );

        //Create the SubRoute objects
        SubRoute subRoute = new SubRoute(
          start: _depStation,
          target: _arrivalStation,
          name: _routeName,
          startDate: _deptDate,
          arrivalDate: _arrivalDate,
          duration: _deptDate.difference(_arrivalDate),
          distance: _distance,
          ticketPrice: _ticketPrice,
          additionalTicketPrice: _additionaltPrice,
          seatTicketPrice: _seatPrice,
          hasWifi: _wifi,
          highSpeedVehilce: _highSpeed,
          eTicket: _preBuy,
          risky: false,
        );

        //Add the sub route
        subRoutes.add(subRoute);
      }

      _routes.add(new Route(subRoutes));
    }

    return _routes;
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
        for (int i = 0; i < elements.length - 1; i++) {
          //Detect the variables runType
          switch (elements.values.elementAt(i).runtimeType) {
            case int:
              result +=
                  "\"${elements.keys.elementAt(i)}\":${elements.values.elementAt(i)}${i != elements.length - 2 ? "," : ""}";
              break;
            case String:
              result +=
                  "\"${elements.keys.elementAt(i)}\":\"${elements.values.elementAt(i)}\"${i != elements.length - 2 ? "," : ""}";
              break;
            case List:
              result += "\"networks\":[";
              for (var item in elements.values.elementAt(i)) {
                result += item.toString();
              }
              result += "]${i != elements.length - 2 ? "," : ""}";
              break;
          }

          //If this variables the next, break the loop
          if (elements.keys.elementAt(i + 1) == "honnan" ||
              elements.keys.elementAt(i + 1) == "hova") {
            break;
          }
        }

        result +=
            "\"searchInput\":{\"from\":{\"ls_id\":${elements["honnan_ls_id"]}},\"to\":{\"ls_id\":${elements["hova_ls_id"]}},\"through\":${null.toString()}}}}";
        return result;

      //getStationOrAddrByText
      case "getStationOrAddrByText":
        result +=
            "\"params\":{\"inputText\":\"${elements["inputText"]}\", \"searchIn\":[\"${elements["searchIn"]}\"]}}";

        return result;

      case "getTimeTableC":
        result +=
            "\"params\":{\"honnan_ls_id\":\"${elements["honnan_ls_id"]}\",";

        //Convert all elemenets
        for (int i = 0; i < elements.length - 1; i++) {
          //Detect the variables runType
          switch (elements.values.elementAt(i).runtimeType) {
            case int:
              result +=
                  "\"${elements.keys.elementAt(i)}\":${elements.values.elementAt(i)}${i != elements.length - 2 ? "," : ""}";
              break;
            case String:
              result +=
                  "\"${elements.keys.elementAt(i)}\":\"${elements.values.elementAt(i)}\"${i != elements.length - 2 ? "," : ""}";
              break;
            case List:
              result += "\"networks\":[";
              for (var item in elements.values.elementAt(i)) {
                result += item.toString();
              }
              result += "]${i != elements.length - 2 ? "," : ""}";
              break;
          }

          //If this variable the next, break the loop
          if (elements.keys.elementAt(i + 1) == "honnan_ls_id") {
            break;
          }
        }

        result += "}}";
        return result;

      default:
        //If the method name is bad or the method is not exist
        throw new Exception(
            "This method is not exist! Method name: ${method}. Existing methods: \"getRoutes\", \"getStationOrAddrByText\"");
    }
  }

  //Set the part of the day
  PartOfTheDay _setPartOFTheDay(int? hours) {
    if (hours == null) hours = DateTime.now().hour;

    switch ((hours / 8).floor()) {
      case 1:
        return PartOfTheDay.During_The_Day;
      case 2:
        return PartOfTheDay.Evening;
      default:
        return PartOfTheDay.Dawn;
    }
  }

  //Set all common infos
  Map<String, dynamic> _initCommonInfo(DateTime? searchDate) {
    //Check any parameters for null value
    if (searchDate != null) {
      String date =
          "${searchDate.year}-${searchDate.month < 10 ? "0${searchDate.month}" : searchDate.month}-${searchDate.day < 10 ? "0${searchDate.day}" : searchDate.day}";

      String hour =
          searchDate.hour < 10 ? "0${searchDate.hour}" : "${searchDate.hour}";

      String minute = searchDate.minute < 10
          ? "0${searchDate.minute}"
          : "${searchDate.minute}";

      return {"datum": date, "hour": hour, "min": minute};
    }

    //Init the variables (date - hour - minutes)
    String date =
        "${DateTime.now().year}-${DateTime.now().month < 10 ? "0${DateTime.now().month}" : DateTime.now().month}-${DateTime.now().day < 10 ? "0${DateTime.now().day}" : DateTime.now().day}";

    String hour = DateTime.now().hour < 10
        ? "0${DateTime.now().hour}"
        : "${DateTime.now().hour}";

    String minute = DateTime.now().minute < 10
        ? "0${DateTime.now().minute}"
        : "${DateTime.now().minute}";

    return {
      "datum": date,
      "hour": hour,
      "min": minute,
    };
  }
}
