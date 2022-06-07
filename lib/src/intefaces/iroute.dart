import 'package:menetrendek_api/src/classes/station.dart';

abstract class IRoute {
  ///The price without discount
  int get TicketPrice;

  ///The additional price
  int get AdditionalTicketPrice;

  ///Duration of the travel
  Duration get DurationOfTheArrival;

  ///Distance of the travel
  double get Distance;

  ///Departure time
  DateTime get DepartureTime;

  ///Arrival time
  DateTime get ArrivalTime;

  ///Start station or address information
  Station get StartStation;

  ///Target station or address information
  Station get TargetStation;

  ///Does the vehicle have WIFI?
  bool get HasWIFI;

  ///Vehicle is high performance vehicle?
  bool get HighSpeedVehilce;

  ///We can buy eTicket for the travel?
  bool get CanBuyETicket;
}
