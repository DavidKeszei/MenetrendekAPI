import 'package:menetrendek_api/src/classes/station.dart';
import 'package:menetrendek_api/src/classes/sub_route.dart';
import 'package:menetrendek_api/src/intefaces/iroute.dart';

class Route implements IRoute {
  //Sub-routes of the tarvel
  List<SubRoute> _subRoutes = [];

  List<SubRoute> get SubRoutes => _subRoutes;

  @override
  DateTime get ArrivalTime => _subRoutes.last.ArrivalDate;

  @override
  bool get CanBuyETicket =>
      !_subRoutes.where((element) => element.CanBuyETicket).isEmpty;

  @override
  DateTime get DepartureTime => _subRoutes.first.StartDate;

  @override
  double get Distance {
    double distance = 0;

    for (SubRoute route in _subRoutes) {
      distance += route.Distance;
    }

    return distance;
  }

  @override
  bool get HasWIFI => !_subRoutes.where((element) => element.HasWIFI).isEmpty;

  @override
  bool get HighSpeedVehilce =>
      !_subRoutes.where((element) => element.HighSpeedVehilce).isEmpty;

  @override
  Station get StartStation => _subRoutes.first.StartStation;

  @override
  Station get TargetStation => _subRoutes.last.TargetStation;

  @override
  int get TicketPrice {
    int price = 0;

    for (SubRoute route in _subRoutes) {
      price += route.TicketPrice;
    }

    return price;
  }

  @override
  Duration get DurationOfTheArrival {
    int hour = 0;
    int minutes = 0;

    for (SubRoute route in _subRoutes) {
      hour += route.DurationOfTheArrival.inHours.abs();
      minutes += route.DurationOfTheArrival.inMinutes.abs();
    }

    return new Duration(days: 0, hours: hour, minutes: minutes);
  }

  ///The price with 50% discount
  int get StudentTicketPrice => (TicketPrice * 0.5).round();

  ///The price with 90% discount
  int get NintyTicketPrice => (TicketPrice * 0.9).round();

  ///All additional price of the route
  int get AdditionalTicketPrice {
    int price = 0;

    for (SubRoute route in _subRoutes) {
      price += route.AdditionalTicketPrice;
    }

    return price;
  }

  Route(List<SubRoute> subRoutes) {
    _subRoutes = subRoutes;
  }
}
