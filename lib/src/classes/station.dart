import 'package:menetrendek_api/src/enums.dart';

///Represent stations or settlements
class Station {
  //<--- Variables --->
  //The station identifier
  late int _stationID;
  //Indentifier of a settlement to which it belongs
  late int _settlementID;
  //Name of the settlement
  late String _settlementName;
  //The station name
  late String _stationName;
  //Route a local route?
  late bool _local;
  //Station type (Settlement or Station of a settlement)
  late StationType _type;

  //<--- Properties --->
  ///The station identifier
  int get StationID => _stationID;

  ///Indentifier of a settlement to which it belongs
  int get SettlementID => _settlementID;

  ///Name of the settlement
  String get SettlementName => _settlementName;

  ///The station name
  String get StationName => _stationName;

  ///Station type (Settlement or Station of a settlement)
  StationType get Type => _type;

  //<--- Methods --->
  Station(String stationName, int stationID, String settlementName,
      int settlementID, bool local, StationType type) {
    _stationName = stationName;
    _stationID = stationID;
    _settlementName = settlementName;
    _settlementID = settlementID;
    _local = local;
    _type = type;
  }
}
