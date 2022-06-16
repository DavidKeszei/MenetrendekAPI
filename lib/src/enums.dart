enum RouteDirection {
  There,
  Back,
}

enum PartOfTheDay {
  Dawn,
  During_The_Day,
  Evening,
  None_Specified,
}

enum ExplanationType {
  Holidays,
  Normal,
}

enum StationType {
  Settlement,
  Station,
}

enum TicketType {
  Normal,
  Student,
  Ninty,
}

enum VehicleType {
  Bus,
  Train,
  Ship,
  LocalAndOutgoingBus,
  TrolleyBus,
  Tram,
  InterurbanTrain,
  Metro,
  TrainSubtationBus,
}

class VehicleTypeAdapter {
  int _bus = 1;
  int _train = 2;
  int _ship = 3;
  int _localBus = 10;
  int _trolleyBus = 11;
  int _tram = 12;
  int _interurbanTrain = 13;
  int _metro = 14;
  int _outgoingBus = 24;
  int _trainSubstutionBus = 25;

  //Singleton
  static VehicleTypeAdapter get Instance {
    return new VehicleTypeAdapter();
  }

  ///Return the vehicle type in string.
  String getVehicleTypeInString(int vehilceType) {
    switch (vehilceType) {
      case 2:
        return "Vonat";
      case 3:
        return "Hajó";
      case 10:
      case 24:
        return "Helyi és kijáró autóbusz";
      case 11:
        return "Trolibusz";
      case 12:
        return "Villamos";
      case 13:
        return "Helyiérdekü vonat";
      case 14:
        return "Metró";
      case 25:
        return "Vonatpotló autóbusz";
      default:
        return "Helyközi autóbusz";
    }
  }

  ///Return the vehicle type in integer.
  List<int> getVehicleTypeInInt(VehicleType vehilceType) {
    switch (vehilceType) {
      case VehicleType.Train:
        return [VehicleTypeAdapter.Instance._train];
      case VehicleType.Ship:
        return [VehicleTypeAdapter.Instance._ship];
      case VehicleType.LocalAndOutgoingBus:
        return [
          VehicleTypeAdapter.Instance._localBus,
          VehicleTypeAdapter.Instance._outgoingBus
        ];
      case VehicleType.TrolleyBus:
        return [VehicleTypeAdapter.Instance._trolleyBus];
      case VehicleType.Tram:
        return [VehicleTypeAdapter.Instance._tram];
      case VehicleType.InterurbanTrain:
        return [VehicleTypeAdapter.Instance._interurbanTrain];
      case VehicleType.Metro:
        return [VehicleTypeAdapter.Instance._metro];
      case VehicleType.TrainSubtationBus:
        return [VehicleTypeAdapter.Instance._trainSubstutionBus];
      default:
        return [VehicleTypeAdapter.Instance._bus];
    }
  }
}
