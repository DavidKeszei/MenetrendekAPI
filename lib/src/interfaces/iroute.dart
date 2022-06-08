// ignore_for_file: unnecessary_this

import '../classes/station.dart';
import '../enums.dart';

abstract class IRoute {
  ///The additional price
  int additionalTicketPrice();

  ///Departure time
  DateTime departureTime();

  ///Arrival time
  DateTime arrivalTime();

  ///Start station or address information
  Station startStation();

  ///Target station or address information
  Station targetStation();

  ///Does the vehicle have WIFI?
  bool hasWIFI();

  ///Vehicle is high performance vehicle?
  bool highSpeedVehilce();

  ///We can buy eTicket for the travel?
  bool canBuyETicket();

  int getTicketPrice(TicketType ticketType);

  ///Distance of the travel
  double distance();

  ///Duration of the travel
  Duration durationOfTheArrival();
}
