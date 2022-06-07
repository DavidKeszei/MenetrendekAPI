import 'package:menetrendek_api/src/classes/station.dart';
import 'package:menetrendek_api/src/intefaces/iroute.dart';

class SubRoute implements IRoute {
  //<--- Variables --->

  late Station _start;
  late Station _arrival;

  //The route name
  String _lineName = "";

  //Start date of the route
  late DateTime _startDate;
  //End date of the route
  late DateTime _arrivalDate;
  //Duration of the travel
  late Duration _durationOfArrival;

  //Transfer count
  int _transferCount = 0;
  //Distance of the start station from the arrival station
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

  //<--- Properties --->

  @override
  Station get StartStation => _start;

  @override
  Station get TargetStation => _start;

  @override
  DateTime get ArrivalTime => _arrivalDate;

  @override
  DateTime get DepartureTime => _startDate;

  ///Name of the route
  String get RouteName => _lineName;

  ///The start date of the route
  DateTime get StartDate => _startDate;

  ///The arrival date of the route to target location
  DateTime get ArrivalDate => _arrivalDate;

  Duration get DurationOfTheArrival => _durationOfArrival;

  ///Transfer count of the travel
  int get TravelCount => _transferCount;

  ///Distance of the travel
  double get Distance => _distance;

  int get TicketPrice => _ticketPrice;

  ///The additional price
  int get AdditionalTicketPrice => _additionalTicketPrice;

  ///The seat price
  int get SeatTicketPrice => _seatTicketPrice;

  ///Does the vehicle have WIFI?
  bool get HasWIFI => _hasWIFI;

  ///Vehicle is high performance vehicle?
  bool get HighSpeedVehilce => _isHighSpeedRoute;

  ///We can buy eTicket for the travel?
  bool get CanBuyETicket => _eTicket;

  ///Risky this route?
  bool get Risky => _riskyRoute;

  //<--- Methods --->

  //Constructor
  SubRoute({
    required Station startLocation,
    required Station targetLocation,
    required String name,
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
    this._start = startLocation;
    this._arrival = startLocation;
    this._lineName = name;
    this._startDate = startDate;
    this._arrivalDate = arrivalDate;
    this._durationOfArrival = duration;
    this._distance = distance;
    this._ticketPrice = ticketPrice;
    this._additionalTicketPrice = additionalTicketPrice;
    this._seatTicketPrice = seatTicketPrice;
    this._hasWIFI = hasWifi;
    this._isHighSpeedRoute = highSpeedVehilce;
    this._eTicket = eTicket;
    this._riskyRoute = risky;
  }
}
