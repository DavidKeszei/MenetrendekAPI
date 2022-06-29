<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->
**Unofficial** API for query (bus, train, etc..) route from Menetrend.hu

## Features

* [Query all route between 2 station](#getActualRoute)
* [Get a station by name](#getStationOrAddrByText)
* [Query the time table of the station](#getTimeTable)

## getActualRoute

#### Description
Retrieve a list, which contains all routes by input

#### Required Parameters
* **from** - departure station
* **to** - target station

#### Not Neccessary Parameters
* **through** - station between 2 station
* **date** - date of the query
* **maxWalkDistance** - max. distance from a station in walk 
* **transferCount** - max. collision points count of the route
* **maxWaitTime** - max. time for a wait a route (in minute)
* **routeDirection** - direction of the route
* **partOfTheDay** - routes in a specific part of the day

#### Example
```dart
List<Route> _routes = await MenetrendAPI.Instance.getActualRoutes(
  from: _stations[0],
  to: _stations2[0],
  searchDate: new DateTime(2022, 06, 20),
);
```

## getStationOrAddrByText

#### Description
Query station by input.

**Return:** Retrieve a list, which contains all stations or addresses by input. If the input not correct (example: not exist), then the result is a empty list.

#### Required Parameters
* **stateName** - searched station or address

#### Not Neccessary Parameters
* **searchIn** - search input type (station or address)
* **vehicleType** - vehicle type(s) of the station or address
* **local** - The station is local station? (With addresses not work.)

#### Example
```dart
List<Station> _stations = await MenetrendAPI.Instance.getStationOrAddrByText(stateName: "Székesfehérvár, autóbusz-állomás", local: false);
```

## getTimeTable

#### Description
Query a station time table by input.

**Return:** Retrieve a list, which contains all the routes that start on it. If the input not correct (example: not found route), then throw a expection with the server error message.

#### Required Parameters
* **from** - start station

#### Not Neccessary Parameters
* **interval** - search interval
* **date** - date of the query
* **maxWalkDistance** - max. distance from a station in walk 
* **transferCount** - max. collision points count of the route
* **maxWaitTime** - max. time for a wait a route (in minute)
* **routeDirection** - direction of the route
* **partOfTheDay** - routes in a specific part of the day
* **maxCount** - max. result element count of the query

#### Example
```dart
List<Route> _timeTable = await MenetrendAPI.Instance.getTimeTable(
  from: _stations[0],
  maxResult: 10,
);
```

## Additional information

This library not **official** API from [Menetrend.hu](https://menetrendek.hu). This project was created for the purpose of **learning and obtaining free information**. 
(At the very least, I think this information is not a state secret to be protected). If you have any questions, contact me :) (daviidkesze@gmail.com) 
