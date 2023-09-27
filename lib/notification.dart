// ignore_for_file: avoid_print

import 'package:driver_app/commons.dart';
import 'package:driver_app/trip_detail.dart';
import 'package:driver_app/widgets/notification_panel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:collection/collection.dart';
import 'package:grouped_list/grouped_list.dart';

const List<Color> _kDefaultRainbowColors = const [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});
  // const NotificationPage({Key? key}) : super(key: key);

  // Move the variable declaration here:

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int page = 0;
  late String todayDate = "01-01-2022";
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  List notifications = List.empty(growable: true);

  Future<dynamic> getTrip(String tripId) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Cookie': Commons.cookie,
    };

    final response = await http.get(
        Uri.parse(
            'http://167.86.102.230/alnabali/public/android/daily-trip/${tripId}'),
        // Send authorization headers to the backend.
        headers: requestHeaders);

    Map<String, dynamic> responseJson = jsonDecode(response.body);

    var trip = responseJson["result"];
    return trip;
  }

  void setTodayDate() {
    // DateTime now = DateTime.now();
    // todayDate = "${now.day}-${now.day}-${now.year}";
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    todayDate = '${DateFormat('dd/MM/yyyy').format(today)}';
  }

  @override
  void initState() {
    setTodayDate();
    Commons.isTrip = false;
    _getMoreNotifications(page);
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreNotifications(page);
      }
    });
  }

  void _markNotificationAsRead(String notificationId) async {
    String url = "${Commons.baseUrl}notification/mark-read/$notificationId";
    var response = await http.post(Uri.parse(url), body: {}, headers: {
      'Content-type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Cookie': Commons.cookie,
      'X-CSRF-TOKEN': Commons.token
    });

    developer.log("updateImage" + response.body.toString());
  }

  void _getMoreNotifications(int index) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
        notifications.clear();
      });
      // _buildList();
      String url =
          // "${Commons.baseUrl}notification/all/${Commons.login_id}?page=$page";
          "${Commons.baseUrl}notification/all/supervisor_${Commons.login_id}";
      // "${Commons.baseUrl}notification/today";
      var response = await http.get(
        Uri.parse(url),
      );
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      print(responseJson);

      if (response.statusCode == 200) {
        if (responseJson['result'].length < 1) {
          setState(() {
            isLoading = false;
          });
          return;
        }
        for (int i = 0; i < responseJson['result'].length; i++) {
          notifications.add(responseJson['result'][i]);
        }
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
      setState(() {
        isLoading = false;
        page++;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/bg_notification.png"),
                        fit: BoxFit.fill)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).size.height / 4,
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 12),
                        child: _buildList(),
                      ),
                      Container(
                          alignment: Alignment.bottomCenter,
                          margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height / 100,
                            left: MediaQuery.of(context).size.width / 20,
                            right: MediaQuery.of(context).size.width / 20,
                          ),
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height / 13.5,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            color: Color.fromRGBO(244, 130, 34, 1),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/main');
                                },
                                child: Container(
                                    child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      start: MediaQuery.of(context).size.width *
                                          0.08,
                                      top: 20,
                                      bottom: 15),
                                  child:
                                      Image.asset("assets/navbar_track2.png"),
                                )),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/trip');
                                },
                                child: Container(
                                    child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      start: MediaQuery.of(context).size.width *
                                          0.08,
                                      top: 20,
                                      bottom: 15),
                                  child: Image.asset("assets/navbar_trip.png"),
                                )),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.38,
                                height: MediaQuery.of(context).size.height,
                                // margin: EdgeInsets.only(
                                //     left: 20, top: 10, bottom: 10, right: 5),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 7),
                                child: TextField(
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                      enabled: false,
                                      prefixIcon: Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: 5, top: 10, bottom: 10),
                                        child: Image.asset(
                                          "assets/navbar_notification2.png",
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.only(right: 5),
                                      hintText: "notification".tr(),
                                      hintStyle: const TextStyle(
                                        color: Color.fromRGBO(244, 130, 34, 1),
                                        fontSize: 12,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50)))),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/profile');
                                },
                                child: Container(
                                    child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      start: MediaQuery.of(context).size.width *
                                          0.002,
                                      top: 20,
                                      bottom: 15),
                                  child: Image.asset("assets/navbar_user.png"),
                                )),
                              ),
                            ],
                          ))
                    ]))));
  }

  Widget _buildList() {
    // create map to group notifications by date
    Map<String, List<dynamic>> groupedNotifications = {};

    notifications.forEach((notif) {
      final trip_id = notif['disp_trip_id'];
      final dateCon = trip_id.toString().split('-');
      final dateString = dateCon[0].substring(0, 4) +
          "-" +
          dateCon[0].substring(4, 6) +
          "-" +
          dateCon[0].substring(6, 8) +
          "" +
          dateCon[0].substring(8, dateCon[0].length);
      final date = DateTime.parse(dateString);
      final valueDate = DateTime(date.year, date.month, date.day);
      final today = DateTime.now();
      final to_day = DateTime(today.year, today.month, today.day);
      final yesterday = DateTime(today.year, today.month, today.day - 1);
      final todayFormatted = DateFormat('yyyy-MM-dd').format(today);
      String dateKey = '';
      if (valueDate == to_day) {
        dateKey = 'Today, ${DateFormat('dd/MM/yyyy').format(date)}';
      } else if (valueDate == yesterday) {
        dateKey = 'Yesterday, ${DateFormat('dd/MM/yyyy').format(date)}';
      } else {
        dateKey = DateFormat('EEE, dd/MM/yyyy').format(date);
      }

      // add notification to relevant date group
      if (!groupedNotifications.containsKey(dateKey)) {
        groupedNotifications[dateKey] = [notif];
      } else if (!groupedNotifications[dateKey]!.contains(notif)) {
        groupedNotifications[dateKey]!.add(notif);
      }
    });

    // get sorted list of date keys
    List<String> dateKeys = groupedNotifications.keys.toList();
    // dateKeys.sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));
    if (notifications.length == 0) {
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
      return RefreshIndicator(
        onRefresh: () async {
          page = 0;
          notifications.clear();
          _getMoreNotifications(0);
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: dateKeys.length,
          padding: const EdgeInsets.only(top: 40),
          itemBuilder: (BuildContext context, int index) {
            String dateKey = dateKeys[index];
            List<dynamic> notifs = groupedNotifications[dateKey]!;

            // build header for each date group
            Widget header = Container(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.black,
                    height: 1,
                    width: MediaQuery.of(context).size.width / 4,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    dateKey,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    color: Colors.black,
                    height: 1,
                    width: MediaQuery.of(context).size.width / 4,
                  ),
                ],
              ),
            );

            // build list of notifications for each date group
            Widget notificationList = ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifs.length,
              itemBuilder: (BuildContext context, int index) {
                String time = notifs[index]['updated_at']
                    .toString()
                    .split("T")[1]
                    .substring(0, 5);
                String tripType = "";
                switch (notifs[index]['status']) {
                  case 0:
                    tripType = "pending";
                    break;
                  case 1:
                    tripType = "pending";
                    break;
                  case 2:
                    tripType = "accept";
                    break;
                  case 3:
                    tripType = "reject";
                    break;
                  case 4:
                    tripType = "start";
                    break;
                  case 6:
                    tripType = "finish";
                    break;
                  case 5:
                    tripType = "cancel";
                    break;
                  case 7:
                    tripType = "fake";
                    break;
                  default:
                    break;
                }

                return Container(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          _markNotificationAsRead(
                              notifs[index]["id"].toString());
                          getTrip(notifs[index]["daily_trip_id"].toString())
                              .then((value) {
                            return Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TripDetail(
                                      avatar_url: value["client_avatar"],
                                      trip: value),
                                ));
                          });
                        },
                        child: NotificationPanel(
                          tripID: "#${notifs[index]["disp_trip_id"]}",
                          tripName: notifs[index]['trip_name'],
                          tripType: tripType,
                          message: notifs[index]['message'],
                          avatar_url: notifs[index]['client_avatar'],
                          viewed: notifs[index]['viewed'],
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width / 12,
                            top: 6,
                            bottom: 6),
                        child: Text(
                          "${time}",
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            );

            // combine header and list for each date group
            List<Widget> children = [header, notificationList];

            // add loading indicator at the end of the last date group
            if (index == dateKeys.length - 1 && dateKeys.isNotEmpty) {
              // children.add(_buildProgressIndicator());
            }

            return Column(children: children);
          },
        ),
      );
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10),
      child: const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
