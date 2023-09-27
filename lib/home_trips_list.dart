import 'dart:async';

import 'package:driver_app/commons.dart';
import 'package:driver_app/sub_main.dart';
import 'package:driver_app/trip_detail.dart';
import 'package:driver_app/widgets/trip_info.dart';
import 'package:flutter/material.dart';

import 'package:driver_app/widgets/constants.dart';
import 'package:driver_app/widgets/buttons_tabbar.dart';
import 'package:driver_app/widgets/trip_card.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_indicator/loading_indicator.dart';

const List<Color> _kDefaultRainbowColors = const [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

enum TripsListType {
  todayTrips,
  pastTrips,
}

class TripsListView extends StatefulWidget {
  final TripsListType listType;
  final int selectedIndex;
  final bool today;

  const TripsListView({
    Key? key,
    required this.listType,
    this.selectedIndex = 0,
    required this.today,
  }) : super(key: key);

  @override
  State<TripsListView> createState() => _TripsListViewState();
}

class _TripsListViewState extends State<TripsListView> {
  List<dynamic>? trips;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();
  final ScrollController _scrollController4 = ScrollController();
  final ScrollController _scrollController5 = ScrollController();

  // var marea = {};
  // var mcity = {};

  @override
  void initState() {
    Commons.isTrip = false;
    getTrips(true);
    super.initState();
    _scrollController.addListener(() {
      print('scroll11');
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('scroll11');
      }
    });
    _scrollController2.addListener(() {
      print('scroll11');
      if (_scrollController2.position.pixels ==
          _scrollController2.position.maxScrollExtent) {
        print('scroll11');
      }
    });
    _scrollController3.addListener(() {
      print('scroll11');
      if (_scrollController3.position.pixels ==
          _scrollController3.position.maxScrollExtent) {
        print('scroll11');
      }
    });
    _scrollController4.addListener(() {
      print('scroll11');
      if (_scrollController4.position.pixels ==
          _scrollController4.position.maxScrollExtent) {
        print('scroll11');
      }
    });
    _scrollController5.addListener(() {
      print('scroll11');
      if (_scrollController5.position.pixels ==
          _scrollController5.position.maxScrollExtent) {
        print('scroll11');
      }
    });
  }

  getCity() async {
    List<dynamic> cities;

    String url = "${Commons.baseUrl}city/";

    var response = await http.get(
      Uri.parse(url!),
    );
    Map<String, dynamic> responseJson = jsonDecode(response.body);
    if (response.statusCode == 200) {
      cities = responseJson['city'];
      developer.log("hahaha" + cities.toString());

      cities.forEach((city) {
        Commons.mcity[city['id']] = city['city_name_en'];
      });
      developer.log("this is city" + Commons.mcity.toString());
    }
    // return http.get(Uri.parse(url!),);
  }

  getArea() async {
    List<dynamic> cities;

    String url = "${Commons.baseUrl}area";

    var response = await http.get(
      Uri.parse(url!),
    );
    Map<String, dynamic> responseJson = jsonDecode(response.body);
    developer.log("kukukk" + responseJson.toString());
    if (response.statusCode == 200) {
      cities = responseJson['area'];
      cities.forEach((city) {
        Commons.marea[city['id']] = city['area_name_en'];
      });
      developer.log("this is area" + Commons.marea.toString());
    }
  }

  getTrips(bool today) async {
    // setToken();
    Map data = {
      'driver_name': "all",
      'supervisor': Commons.login_id,
    };
    Map<String, String> requestHeaders = {
      'Content-type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      "Connection": "Keep-Alive",
      'Cookie': Commons.cookie,
      // 'Authorization': Commons.token,
      'X-CSRF-TOKEN': Commons.token
    };

    String? url = null;
    if (today) {
      url = "${Commons.baseUrl}daily-trip/today";
    } else {
      url = "${Commons.baseUrl}daily-trip/last";
    }
    var response =
        await http.post(Uri.parse(url!), body: data, headers: requestHeaders);

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map<String, dynamic> responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      trips = responseJson['result'];
      int? cnt = trips?.length;
      print("msg7" + cnt.toString());
    } else {
      Fluttertoast.showToast(
          msg: "Server Error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.red,
          fontSize: 16.0);
    }
  }

  TripInfo getInfoModel(TripStatus type, dynamic trip) {
    return TripInfo(
      status: type,
      tripNo: trip['id'],
      company: CompanyInfo(
        companyName: trip['client_name'],
        tripName: trip['trip_name'],
      ),
      busNo: trip['bus_no'],
      passengers: trip['bus_size_id'],
      busLine: BusLineInfo(
        fromTime: DateTime(
            Commons.getYear(trip['start_date']),
            Commons.getMonth(trip['start_date']),
            Commons.getDay(trip['start_date']),
            Commons.getHour(trip['start_time']),
            Commons.getMinute(trip['start_time'])),
        toTime: DateTime(
            Commons.getYear(trip['end_date']),
            Commons.getMonth(trip['end_date']),
            Commons.getDay(trip['end_date']),
            Commons.getHour(trip['end_time']),
            Commons.getMinute(trip['end_time'])),
        // courseName: "${trip['origin_area']} - ${trip['destination_area']}",
        // cityName: trip['origin_city'],
        courseName: "${trip['origin_area'] ?? 'here'} ",
        courseEndName: "${trip['destination_area'] ?? 'here'} ",
        cityEndName: trip['destination_city'] ?? "here",
        cityName: trip['origin_city'] ?? "here",
      ),
    );
  }

  Widget displayTrips(String type) {
    List<Widget> list = <Widget>[];

    trips?.asMap().forEach((key, trip) {
      developer.log("zzzzzzzz" + trip.toString());

      if (trip['status'] == "1" || trip['status'] == "0") {
        list.add(TripCard(
            past: true,
            info: getInfoModel(TripStatus.pending, trip),
            trip: trip,
            onPressed: () {}));
      } else if (trip['status'] == "2") {
        //accept
        list.add(TripCard(
            past: true,
            trip: trip,
            info: getInfoModel(TripStatus.accepted, trip),
            onPressed: () {}));
      } else if (trip['status'] == "3") {
        //reject
        list.add(TripCard(
            past: true,
            trip: trip,
            info: getInfoModel(TripStatus.rejected, trip),
            onPressed: () {}));
      } else if (trip['status'] == "5") {
        //cancel
        list.add(TripCard(
            past: true,
            trip: trip,
            info: getInfoModel(TripStatus.canceled, trip),
            onPressed: () {}));
      } else if (trip['status'] == "4") {
        //start
        list.add(TripCard(
            past: true,
            trip: trip,
            info: getInfoModel(TripStatus.started, trip),
            onPressed: () {}));
      } else if (trip['status'] == "6") {
        //finish
        list.add(TripCard(
            past: true,
            trip: trip,
            info: getInfoModel(TripStatus.finished, trip),
            onPressed: () {}));
      } else if (trip['status'] == "7") {
        //fake
        list.add(TripCard(
            past: true,
            trip: trip,
            info: getInfoModel(TripStatus.fake, trip),
            onPressed: () {}));
      }
      list.add(
        const SizedBox(height: 15),
      );
    });
    if (trips?.length == 0) {
      return Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 20),
          child: Text(
            "No data to display",
            style: TextStyle(fontSize: 15, color: Colors.deepOrange),
          ));
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center, children: list);
  }

  Widget displaySubTrips(String type) {
    List<Widget> list = <Widget>[];

    trips?.asMap().forEach((key, trip) {
      // developer.log("zzzzzzzz" + Commons.getCity(trip['origin_city']).toString());

      if (type == "pending") {
        if (trip['status'] == "1" || trip['status'] == "0") {
          list.add(TripCard(
              past: true,
              trip: trip,
              info: getInfoModel(TripStatus.pending, trip),
              onPressed: () {
                TripDetail(
                  trip: trip,
                  avatar_url: "",
                );
              }));
        }
        list.add(
          const SizedBox(height: 20),
        );
      } else if (type == "accept") {
        if (trip['status'] == "2") {
          //accept
          list.add(TripCard(
              past: true,
              trip: trip,
              info: getInfoModel(TripStatus.accepted, trip),
              onPressed: () {}));
        }
        list.add(
          const SizedBox(height: 20),
        );
      } else if (type == "reject") {
        if (trip['status'] == "3") {
          //reject
          list.add(TripCard(
              past: true,
              trip: trip,
              info: getInfoModel(TripStatus.rejected, trip),
              onPressed: () {}));
        }
        list.add(
          const SizedBox(height: 20),
        );
      } else if (type == "cancel") {
        if (trip['status'] == "5") {
          //cancel
          list.add(TripCard(
              past: true,
              trip: trip,
              info: getInfoModel(TripStatus.canceled, trip),
              onPressed: () {}));
        }
        list.add(
          const SizedBox(height: 20),
        );
      } else if (type == "start") {
        if (trip['status'] == "4") {
          //start
          list.add(TripCard(
              past: true,
              trip: trip,
              info: getInfoModel(TripStatus.started, trip),
              onPressed: () {}));
        }
        list.add(
          const SizedBox(height: 20),
        );
      } else if (type == "finish") {
        if (trip['status'] == "6") {
          //finish
          list.add(TripCard(
              past: true,
              trip: trip,
              info: getInfoModel(TripStatus.finished, trip),
              onPressed: () {}));
        }
        list.add(
          const SizedBox(height: 1),
        );
      } else if (type == "fake") {
        if (trip['status'] == "7") {
          //fake
          list.add(TripCard(
              past: true,
              trip: trip,
              info: getInfoModel(TripStatus.fake, trip),
              onPressed: () {}));
        }
        list.add(
          const SizedBox(height: 15),
        );
      }
    });
    if (trips?.length == 0) {
      return Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 30),
          child: Text(
            "No data to display",
            style: TextStyle(fontSize: 15, color: Colors.deepOrange),
          ));
    }
    return Column(children: list);
  }

  RefreshIndicator getTab(String type) {
    return RefreshIndicator(
      onRefresh: () async {
        widget.today ? getTrips(true) : getTrips(false);
        setState(() {});
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(children: [
          // TripCard( past: true,info: testStarted, onPressed: () {}),
          // const SizedBox(height: 20),
          // TripCard( past: true,info: testStarted, onPressed: () {}),
          FutureBuilder<List<void>>(
            future: Future.wait([
              widget.today ? getTrips(true) : getTrips(false),
              getArea(),
              getCity()
            ]),
            builder:
                (BuildContext context, AsyncSnapshot<List<void>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                debugPrint("ConnectionState.waiting");
                return const SizedBox(
                  height: 100,
                  width: 100,
                  child: LoadingIndicator(
                      indicatorType: Indicator.ballRotateChase,
                      colors: _kDefaultRainbowColors,
                      strokeWidth: 4.0),
                );
              } else {
                if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text(
                        'A system error has occurred.',
                        style: TextStyle(color: Colors.red, fontSize: 32),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  debugPrint("! snapshot . hasData ${!snapshot.hasData}");
                  return CircularProgressIndicator();
                }
                return displaySubTrips(type);
              }
            },
          )
        ]),
      ),
    );
  }

  String _getTabTextFromID(int id) {
    if (id == 100) {
      return 'All';
    } else {
      return kTripStatusStrings[id];
    }
  }

  @override
  Widget build(BuildContext context) {
    getCity();
    getArea();
    getTrips(true);
    developer.log("isemptylist" + displayTrips("all").toString());

    SizeConfig().init(context);

    List<int> tabIDArray = [100, 1, 2, 3, 4, 5, 6, 7];
    var tabCount = 8;
    if (widget.listType == TripsListType.pastTrips) {
      tabIDArray = [100, 5, 6, 7];
      tabCount = 4;
    }

    return DefaultTabController(
      length: tabCount,
      child: Column(
        children: <Widget>[
          widget.listType == TripsListType.pastTrips
              ? Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  SingleChildScrollView(
                    controller: _scrollController2,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              left: 10, bottom: 10, top: 10, right: 3),
                          height: 61 * SizeConfig.scaleY,
                          child: Image.asset('assets/images/home_icon2.png'),
                        ),
                        ButtonsTabBar(
                          backgroundColor: kColorPrimaryBlue,
                          borderColor: kColorPrimaryBlue,
                          unselectedBackgroundColor: Colors.transparent,
                          unselectedBorderColor: const Color(0xFFB3B3B3),
                          borderWidth: 1,
                          height: 32,
                          radius: 100,
                          contentPadding: EdgeInsets.only(right: 0.5),
                          //height: 62 * SizeConfig.scaleX,
                          // contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                          labelStyle: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: Colors.white,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: Color(0xFFB3B3B3),
                          ),
                          tabs: tabIDArray
                              .map((t) => Tab(
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 150 * SizeConfig.scaleX,
                                      child: Text(
                                        _getTabTextFromID(t),
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 136, 135, 135),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ])
              : SingleChildScrollView(
                  controller: _scrollController3,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: 10, bottom: 10, top: 10, right: 3),
                        height: 61 * SizeConfig.scaleY,
                        child: Image.asset('assets/images/home_icon2.png'),
                      ),
                      ButtonsTabBar(
                        backgroundColor: kColorPrimaryBlue,
                        borderColor: kColorPrimaryBlue,
                        unselectedBackgroundColor: Colors.transparent,
                        unselectedBorderColor: const Color(0xFFB3B3B3),
                        contentPadding: EdgeInsets.only(right: 3),
                        borderWidth: 1,
                        height: 32,
                        radius: 100,
                        //height: 62 * SizeConfig.scaleX,
                        // contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                        labelStyle: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                        tabs: tabIDArray
                            .map((t) => Tab(
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 145 * SizeConfig.scaleX,
                                    child: Text(
                                      _getTabTextFromID(t),
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 136, 135, 135),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                RefreshIndicator(
                  onRefresh: () async {
                    widget.today ? getTrips(true) : getTrips(false);
                    setState(() {});
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController4,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // TripCard( past: true,info: testStarted, onPressed: () {}),
                          // const SizedBox(height: 20),
                          // TripCard( past: true,info: testStarted, onPressed: () {}),
                          FutureBuilder<List<void>>(
                            future: Future.wait([
                              widget.today ? getTrips(true) : getTrips(false),
                              getArea(),
                              getCity()
                            ]),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<void>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                debugPrint("ConnectionState.waiting");
                                return const Center(
                                    child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: LoadingIndicator(
                                      indicatorType: Indicator.ballRotateChase,
                                      colors: _kDefaultRainbowColors,
                                      strokeWidth: 4.0),
                                ));
                              } else {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'A system error has occurred.',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 32),
                                    ),
                                  );
                                }
                                if (!snapshot.hasData) {
                                  debugPrint(
                                      "! snapshot . hasData ${!snapshot.hasData}");
                                  return CircularProgressIndicator();
                                }
                                return displayTrips("all");
                              }
                            },
                          )
                        ]),
                  ),
                ),
                if (widget.today)
                  RefreshIndicator(
                    onRefresh: () async {
                      widget.today ? getTrips(true) : getTrips(false);
                      setState(() {});
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController5,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(children: [
                        // TripCard( past: true,info: testStarted, onPressed: () {}),
                        // const SizedBox(height: 20),
                        // TripCard( past: true,info: testStarted, onPressed: () {}),
                        FutureBuilder<List<void>>(
                          future: Future.wait([
                            widget.today ? getTrips(true) : getTrips(false),
                            getArea(),
                            getCity()
                          ]),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<void>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              debugPrint("ConnectionState.waiting");
                              return const SizedBox(
                                height: 100,
                                width: 100,
                                child: LoadingIndicator(
                                    indicatorType: Indicator.ballRotateChase,
                                    colors: _kDefaultRainbowColors,
                                    strokeWidth: 4.0),
                              );
                            } else {
                              if (snapshot.hasError) {
                                return Scaffold(
                                  body: Center(
                                    child: Text(
                                      'A system error has occurred.',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 32),
                                    ),
                                  ),
                                );
                              }
                              if (!snapshot.hasData) {
                                debugPrint(
                                    "! snapshot . hasData ${!snapshot.hasData}");
                                return LoadingIndicator(
                                    indicatorType: Indicator.ballRotateChase,
                                    colors: _kDefaultRainbowColors,
                                    strokeWidth: 4.0);
                              }
                              return displaySubTrips("pending");
                            }
                          },
                        )
                      ]),
                    ),
                  ),
                if (widget.today) getTab("accept"),
                if (widget.today) getTab("reject"),
                if (widget.today) getTab("start"),
                getTab("cancel"),
                getTab("finish"),
                getTab("fake"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
