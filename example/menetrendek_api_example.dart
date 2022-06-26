import 'package:menetrendek_api/menetrendek_api.dart';
import 'package:menetrendek_api/src/classes/route.dart';
import 'package:menetrendek_api/src/classes/station.dart';
import 'package:menetrendek_api/src/enums.dart';

void main() {
  runAsync();
}

void runAsync() async {
  //Return all station by input
  //Example:
  //  - stateName: "Székesfehérvár, autóbusz-állomás"
  //  - local: false
  //Result: 1db station
  List<Station> _stations = await MenetrendAPI.Instance.getStationOrAddrByText(
      stateName: "Szeged, autóbusz-állomás", local: false);

  //Return all station by input
  //Example:
  //  - stateName: "Aba, Hösök tere"
  //  - local: false
  //Result: 1db station
  List<Station> _stations2 = await MenetrendAPI.Instance.getStationOrAddrByText(
      stateName: "Székesfehérvár, autóbusz-állomás", local: false);

  //Query all route
  //Example:
  //  - from: from the search
  //  - to: from the search
  //
  //Result: 14 db route
  List<Route> _routes = await MenetrendAPI.Instance.getActualRoutes(
    from: _stations[0],
    to: _stations2[0],
    searchDate: new DateTime(2022, 06, 20),
  );

  //Query all route, by one station
  //Example:
  //  - from: from search
  //  - date: 2022-06-20
  //  - maximum result count: 11 (first number is the 0)
  //Result:
  List<Route> _timeTable = await MenetrendAPI.Instance.getTimeTable(
    from: _stations[0],
    maxResult: 10,
  );

  //Debug
  print(
      "Route: ${_routes[0].subRoutes()[0].startStation().StationName} -> ${_routes[0].subRoutes()[0].targetStation().StationName}");
  print("Deperture time: ${_routes[0].departureTime()}");
  print("Arrival time: ${_routes[0].arrivalTime()}");
  print(
      "Price: ${_routes[0].getTicketPrice(TicketType.Student)}Ft (${TicketType.Student.name})");
  print("Distance: ${_routes[0].distance()}km");
  print("Subroute Count: ${_routes[0].subRoutes().length}");
}
