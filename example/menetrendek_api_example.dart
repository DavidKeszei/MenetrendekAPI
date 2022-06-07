import 'package:menetrendek_api/menetrendek_api.dart';
import 'package:menetrendek_api/src/classes/route.dart';
import 'package:menetrendek_api/src/enums.dart';
import 'package:menetrendek_api/src/classes/sub_route.dart';
import 'package:menetrendek_api/src/classes/station.dart';

void main() {
  runAsync();

  //TODO
  //Befejezni a duration paramétert
  //Kommentezni
  //Tovább dolgozni :)
}

void runAsync() async {
  //Return all station by input
  //Example:
  //  - stateName: "Székesfehérvár, autóbusz-állomás"
  //Result: 1db stations
  List<Station> _stations = await MenetrendAPI.Instance.getStationOrAddrByText(
      stateName: "Veszprém, autóbusz-állomás");

  //Query all route
  //Example:
  //  - from: "Aba, Hősök tere"
  //  - fromID: 399
  //  - to: "Székesfehérvár, autóbusz-állomás"
  //  - toID: _stations[0]["ls_id"] (from the search)
  //  - partOfTheDay: PartOfTheDay.Evening
  //  - Result: 14 db
  List<Route> _routes = await MenetrendAPI.Instance.getActualRoutes(
    from: "Székesfehérvár, autóbusz-állomás",
    fromID: 599,
    to: _stations[0].SettlementName,
    toID: _stations[0].StationID,
    hours: 00,
    minutes: 00,
    partOfTheDay: PartOfTheDay.Evening,
  );

  print(_routes[1].DurationOfTheArrival);
}
