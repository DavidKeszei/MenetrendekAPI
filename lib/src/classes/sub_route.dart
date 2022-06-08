import '../classes/station.dart';
import '../interfaces/iroute.dart';

import '../enums.dart';

///A sub route of the route
class SubRoute implements IRoute {
  //<--- Variables --->
  String _routeName = "";

  //Start date of the route
  late DateTime _startDate;
  //End date of the route
  late DateTime _arrivalDate;
  //Duration of the travel
  late Duration _durationOfArrival;

  //Stations
  late Station _start;
  late Station _target;

  //Distance of the start station
  //from the arrival station
  double _distance = 0.0;

  //Ticket price
  int _ticketPrice = 0;
  //Seat ticket price
  int _seatTicketPrice = 0;
  //Additional ticket price
  int _additionalTicketPrice = 0;

  //The route has any WIFI?
  late bool _hasWIFI;
  //The route is hight performace route
  late bool _isHighSpeedRoute;
  //This route agreed the eTicket?
  late bool _eTicket;
  //The route is risky
  late bool _riskyRoute;

  //Constructor
  SubRoute({
    required String name,
    required Station start,
    required Station target,
    required DateTime startDate,
    required DateTime arrivalDate,
    required Duration duration,
    required double distance,
    required int ticketPrice,
    required int additionalTicketPrice,
    required int seatTicketPrice,
    required bool hasWifi,
    required bool highSpeedVehilce,
    required bool eTicket,
    required bool risky,
  }) {
    _routeName = name;
    _start = start;
    _target = target;
    _startDate = startDate;
    _arrivalDate = arrivalDate;
    _durationOfArrival = duration;
    _distance = distance;
    _ticketPrice = ticketPrice;
    _additionalTicketPrice = additionalTicketPrice;
    _seatTicketPrice = seatTicketPrice;
    _hasWIFI = hasWifi;
    _isHighSpeedRoute = highSpeedVehilce;
    _eTicket = eTicket;
    _riskyRoute = risky;
  }

  ///The additional price
  @override
  int additionalTicketPrice() => _additionalTicketPrice;

  ///Departure time
  @override
  DateTime departureTime() => _startDate;

  ///Arrival time
  @override
  DateTime arrivalTime() => _arrivalDate;

  ///Start station or address information
  @override
  Station startStation() => _start;

  ///Target station or address information
  @override
  Station targetStation() => _target;

  ///Does the vehicle have WIFI?
  @override
  bool hasWIFI() => _hasWIFI;

  ///Vehicle is high performance vehicle
  @override
  bool highSpeedVehilce() => _isHighSpeedRoute;

  ///We can buy eTicket for the travel?
  @override
  bool canBuyETicket() => _eTicket;

  //Round the fare to store fare
  int _roundToStoreFare(int fare) {
    int lastNumber = int.parse(fare.toString()[fare.toString().length - 1]);

    if (lastNumber <= 2 || lastNumber >= 8) {
      String result = fare.toString();
      result = result.replaceRange(result.length - 1, null, "0");
      return int.parse(result);
    }

    if (lastNumber >= 3 || lastNumber <= 7) {
      String result = fare.toString();
      result = result.replaceRange(result.length - 1, null, "5");
      return int.parse(result);
    }

    return fare;
  }

  @override
  int getTicketPrice(TicketType ticketType) {
    late double fareRatio;

    switch (ticketType) {
      case TicketType.Student:
        fareRatio = 0.5;
        break;
      case TicketType.Ninty:
        fareRatio = 0.1;
        break;
      default:
        fareRatio = 0.0;
        break;
    }

    return _roundToStoreFare((_ticketPrice * fareRatio).round());
  }

  ///Distance of the travel
  double distance() => _distance;

  ///Duration of the travel
  Duration durationOfTheArrival() {
    int hour = 0;
    int minutes = 0;

    hour += _durationOfArrival.inHours.abs();
    minutes += _durationOfArrival.inMinutes.abs() - (hour * 60);

    return new Duration(days: 0, hours: hour, minutes: minutes);
  }
}
