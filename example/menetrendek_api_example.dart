import 'package:menetrendek_api/menetrendek_api.dart';
import 'package:menetrendek_api/src/classes/route.dart';
import 'package:menetrendek_api/src/classes/station.dart';

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
      stateName: "Székesfehérvár, autóbusz-állomás", local: false);

  //Return all station by input
  //Example:
  //  - stateName: "Aba, Hösök tere"
  //  - local: false
  //Result: 1db station
  List<Station> _stations2 = await MenetrendAPI.Instance.getStationOrAddrByText(
      stateName: "Aba, Hösök tere", local: false);

  //Query all route
  //Example:
  //  - from: from the search
  //  - fromID: from the search
  //  - to: from the search
  //  - toID: from the search
  //
  //Result: 14 db route
  List<Route> _routes = await MenetrendAPI.Instance.getActualRoutes(
    from: _stations2[0],
    to: _stations[0],
    searchDate: new DateTime(2022, 6, 19, 0, 0),
  );

  //Query all route, by one station
  //Example:
  //  - from: from search
  //  - date: 2022-06-12
  //  - maximum result count: 11 (10 + 1)
  //Result:
  List<Route> _timeTable = await MenetrendAPI.Instance.getTimeTable(
    from: _stations[0],
    date: new DateTime(2022, 6, 12, 0, 0),
    maxResult: 10,
  );
}
