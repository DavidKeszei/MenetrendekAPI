import 'package:menetrendek_api/menetrendek_api.dart';
import 'package:menetrendek_api/src/enums.dart';
import 'package:menetrendek_api/src/route.dart';

void main() {
  runAsync();
}

void runAsync() async {
  //Return all station by input
  //Example:
  //  - stateName: "Székesfehérvár, autóbusz-állomás"
  //Result: 1db stations
  List<Map<String, dynamic>> _stations =
      await MenetrendAPI.Instance.getStationOrAddrByText(
          stateName: "Székesfehérvár, autóbusz-állomás");

  //Query all route
  //Example:
  //  - from: "Aba, Hősök tere"
  //  - fromID: 399
  //  - to: "Székesfehérvár, autóbusz-állomás"
  //  - toID: _stations[0]["ls_id"] (from the search)
  //  - partOfTheDay: PartOfTheDay.Evening
  //  - Result: 14 db
  List<Route> _routes = await MenetrendAPI.Instance.getActualRoutes(
    from: "Aba, Hősök tere",
    fromID: 399,
    to: "Székesfehérvár, autóbusz-állomás",
    toID: _stations[0]["ls_id"],
    partOfTheDay: PartOfTheDay.Evening,
  );
}
