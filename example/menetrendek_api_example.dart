import 'package:menetrendek_api/menetrendek_api.dart';
import 'package:menetrendek_api/src/classes/route.dart';
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
      stateName: "Székesfehérvár, autóbusz-állomás");

  //Query all route
  //Example:
  //  - from: "Aba, Hősök tere"
  //  - fromID: 399
  //  - to: from the search
  //  - toID: from the search
  //  - Result: 14 db
  List<Route> _routes = await MenetrendAPI.Instance.getActualRoutes(
    from: "Aba, Hösök tere",
    fromID: 599,
    to: _stations[0].SettlementName,
    toID: _stations[0].StationID,
    hours: 00,
    minutes: 00,
  );
}
