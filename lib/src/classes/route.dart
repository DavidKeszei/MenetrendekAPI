import '../classes/station.dart';
import '../classes/sub_route.dart';
import '../enums.dart';
import '../interfaces/iroute.dart';

///Represents a bus, train, etc. route with all sub route
class Route implements IRoute {
  //Sub-routes of the tarvel
  List<SubRoute> _subRoutes = [];

  Map<String, Duration> _availableTime = {};

  //Constructor
  Route(List<SubRoute> subRoutes) {
    _subRoutes = subRoutes;

    //Calculate the available time between all sub route
    for (int i = 0; i < subRoutes.length - 1; i++) {
      _availableTime.addAll(
        {
          "${i}=>${i + 1}": subRoutes[i]
              .departureTime()
              .difference(subRoutes[i + 1].departureTime())
        },
      );
    }
  }

  //<--- Methods --->

  ///All sub routes of the travel
  List<SubRoute> subRoutes() => _subRoutes;

  ///The available times between all sub routes
  Map<String, Duration> getAllAvailableTime() {
    return _availableTime;
  }

  ///Start date of the route
  @override
  DateTime arrivalTime() {
    return _subRoutes.first.arrivalTime();
  }

  ///End date of the route
  @override
  DateTime departureTime() {
    return _subRoutes.last.departureTime();
  }

  ///Total distance between destination and starting point
  @override
  double distance() {
    double allDistance = 0.0;

    for (SubRoute subRoute in _subRoutes) {
      allDistance += subRoute.distance();
    }

    return allDistance;
  }

  ///Total travel time between destination and starting point
  @override
  Duration durationOfTheArrival() {
    int hour = 0;
    int minutes = 0;

    for (SubRoute route in _subRoutes) {
      hour += route.durationOfTheArrival().inHours.abs();
      minutes += route.durationOfTheArrival().inMinutes.abs() - (hour * 60);
    }

    return new Duration(days: 0, hours: hour, minutes: minutes);
  }

  ///Total ticket price between destination and starting point by ticket type
  @override
  int getTicketPrice(TicketType ticketType) {
    int allFare = 0;

    for (SubRoute route in _subRoutes) {
      allFare += route.getTicketPrice(ticketType);
    }

    return allFare;
  }

  @override
  bool hasWIFI() {
    return !_subRoutes.where((element) => element.hasWIFI()).isEmpty;
  }

  @override
  bool canBuyETicket() {
    return !_subRoutes.where((element) => element.canBuyETicket()).isEmpty;
  }

  @override
  bool highSpeedVehilce() {
    return !_subRoutes.where((element) => element.highSpeedVehilce()).isEmpty;
  }

  ///Start station of the route
  @override
  Station startStation() {
    return _subRoutes.first.startStation();
  }

  ///Arrival station of the route
  @override
  Station targetStation() {
    return _subRoutes.first.targetStation();
  }

  @override
  int additionalTicketPrice() {
    int allFare = 0;

    for (SubRoute route in _subRoutes) {
      allFare += route.additionalTicketPrice();
    }

    return allFare;
  }
}
