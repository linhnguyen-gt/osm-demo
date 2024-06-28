import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_example/misc/tile_providers.dart';
import 'package:flutter_map_example/plugins/my_login.dart';
import 'package:flutter_map_example/widgets/drawer/floating_menu_button.dart';
import 'package:flutter_map_example/widgets/drawer/menu_drawer.dart';
import 'package:flutter_map_example/widgets/first_start_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

Future<List<dynamic>> fetchData(String token) async {
  final url = Uri.parse('http://pinkapp.lol/api/v1/vehicle/list');
  final headers = {'Authorization': 'Bearer $token'};

  final response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final metadata = jsonData['metadata'] as List<dynamic>;
    return metadata;
  } else {
    return [];
  }
}

Future<List<dynamic>> fetchDataPoint(String token) async {
  final url = Uri.parse('http://pinkapp.lol/api/v1/point/user');
  final headers = {'Authorization': 'Bearer $token'};

  final response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final metadata = jsonData['metadata'] as List<dynamic>;
    return metadata;
  } else {
    return [];
  }
}

Future<void> showBookCarDialog(BuildContext context) async {
  final double screenWidth = MediaQuery.of(context).size.width;
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'ĐẶT XE THÀNH CÔNG',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SvgPicture.asset(
                'assets/ic_success.svg',
                width: 100,
                height: 100,
                colorFilter:
                    const ColorFilter.mode(Colors.green, BlendMode.srcIn),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 167, 111),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: Size(screenWidth, 50),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Xác nhận',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showDetailCar(BuildContext context, dynamic item) {
  final double screenWidth = MediaQuery.of(context).size.width;

  var typeCar = '';
  var assetsTypeCar = '';

  final String customerName = (item['customer_name'] != null)
      ? item['customer_name'] as String
      : 'Chưa có khách';
  final int unitPrice =
      (item['unit_price'] != null) ? item['unit_price'] as int : 0;
  final int totalPrice =
      (item['total_price'] != null) ? item['total_price'] as int : 0;
  final int rentalDuration =
      (item['rental_duration'] != null) ? item['rental_duration'] as int : 0;

  Color backgroundColorPin = const Color.fromARGB(255, 214, 241, 232);
  Color textColorPin = const Color.fromARGB(255, 0, 120, 103);

  void setTypeCar(int type) {
    switch (type) {
      case 0:
        typeCar = 'Vinfast VF e34';
        assetsTypeCar = 'assets/type_car/vf.png';
      case 1:
        typeCar = 'Tesla Model S';
        assetsTypeCar = 'assets/type_car/testla_model_s.png';
      case 2:
        typeCar = 'Kia Soul EV';
        assetsTypeCar = 'assets/type_car/kia_soul_ev.png';
      case 3:
        typeCar = 'MG ZS EV';
        assetsTypeCar = 'assets/type_car/mg_zs_ev.png';
      case 4:
        typeCar = 'Volkswagen ID.3';
        assetsTypeCar = 'assets/type_car/volkswagen_id3.png';
      case 5:
        typeCar = 'Hyundai Kona Electric';
        assetsTypeCar = 'assets/type_car/hyundai_kona_electric.png';
      case 6:
        typeCar = 'Honda E';
        assetsTypeCar = 'assets/type_car/honda_e.png';
      case 7:
        typeCar = 'Nissan Leaf';
        assetsTypeCar = 'assets/type_car/nissan_leaf.png';
      case 8:
        typeCar = 'Peugeot E-208';
        assetsTypeCar = 'assets/type_car/peugeot_e208.png';
      case 9:
        typeCar = 'Polestar 2';
        assetsTypeCar = 'assets/type_car/polestar_2.png';
      default:
        typeCar = 'Tesla Model 3';
        assetsTypeCar = 'assets/type_car/tesla_model_3.png';
    }
  }

  void setColorPin(int pinPercent) {
    if (pinPercent >= 80) {
      backgroundColorPin = const Color.fromARGB(255, 214, 241, 232);
      textColorPin = const Color.fromARGB(255, 0, 120, 103);
    } else if (pinPercent > 20) {
      backgroundColorPin = const Color.fromARGB(255, 218, 233, 253);
      textColorPin = const Color.fromARGB(255, 72, 116, 197);
    } else {
      backgroundColorPin = const Color.fromARGB(255, 255, 228, 222);
      textColorPin = const Color.fromARGB(255, 183, 29, 24);
    }
  }

  setTypeCar(item['vehicle_type'] as int);
  setColorPin(item['battery_status'] as int);

  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Container(
          width: screenWidth,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          color: Colors.white30,
          child: Column(
            children: [
              Text(
                customerName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
              ),
              Row(
                children: [
                  const Text(
                    'Pin: ',
                    style: TextStyle(
                        fontSize: 18, color: Color.fromARGB(255, 98, 97, 97)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: backgroundColorPin,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${item['battery_status']}%',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColorPin),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: screenWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final label in [
                      'Đơn giá: $unitPrice',
                      'Tổng giá: $totalPrice',
                      'Thời gian thuê: $rentalDuration',
                      typeCar
                    ])
                      Text(
                        label,
                        style: const TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 98, 97, 97)),
                      ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Image.asset(assetsTypeCar, height: 200),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showBookCarDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 167, 111),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(80, 40),
                ),
                child: const Text(
                  'Đặt xe',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class HomePage extends StatefulWidget {
  static const String route = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';
  Location _locationController = new Location();

  bool _mapCentered = false;
  StreamSubscription<LocationData>? _locationSubscription;

  List<dynamic>? _data = [];
  List<dynamic>? _dataPoint = [];

  LatLng? _currentP = null;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    showIntroDialogIfNeeded();
    _fetchData();
    _fetchDataPoint();
    timer = Timer.periodic(const Duration(seconds: 15), (Timer t) {
      _fetchData();
    });
    getLocationUpdates().then(
      (_) => {},
    );
  }

  Future<void> _fetchData() async {
    final token = MyLogin.instance.token;
    final data = await fetchData(token);
    setState(() {
      _data = data;
    });
  }

  Future<void> _fetchDataPoint() async {
    final token = MyLogin.instance.token;
    final dataPoint = await fetchDataPoint(token);
    setState(() {
      _dataPoint = dataPoint;
    });
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final camera = mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    // Note this method of encoding the target destination is a workaround.
    // When proper animated movement is supported (see #1263) we should be able
    // to detect an appropriate animated movement event which contains the
    // target zoom/center.
    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription = _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (!_mapCentered &&
          currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        _animatedMapMove(
            LatLng(currentLocation.latitude!, currentLocation.longitude!), 15);
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _mapCentered = true;
        });
        _locationSubscription?.cancel();
        _locationSubscription = null;
      }
    });
  }

  final mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(HomePage.route),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              // focus Nha Trang
              initialCenter: _currentP ?? const LatLng(12.1888, 109.1467),
              initialZoom: 14,
              cameraConstraint: CameraConstraint.contain(
                // focus Nha Trang
                bounds: LatLngBounds(
                  const LatLng(12.1888, 109.1467),
                  const LatLng(12.2888, 109.2467),
                ),
              ),
            ),
            children: [
              openStreetMapTileLayer,
              RichAttributionWidget(
                popupInitialDisplayDuration: const Duration(seconds: 5),
                animationConfig: const ScaleRAWA(),
                showFlutterMapAttribution: false,
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () async => launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright'),
                    ),
                  ),
                  const TextSourceAttribution(
                    'This attribution is the same throughout this app, except '
                    'where otherwise specified',
                    prependCopyright: false,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (_currentP != null)
                    Marker(
                      point: LatLng(_currentP!.latitude, _currentP!.longitude),
                      width: 70,
                      height: 70,
                      child: Image.asset(
                        'assets/marker_location.png',
                      ),
                    ),
                  if (_dataPoint != null)
                    ..._dataPoint!.map((item) {
                      final double latitude = item['latitude'] is double
                          ? item['latitude'] as double
                          : 0.0;
                      final double longitude = item['longitude'] is double
                          ? item['longitude'] as double
                          : 0.0;

                      return Marker(
                          point: LatLng(latitude, longitude),
                          child: InkWell(
                            onTap: () {},
                            child: SvgPicture.asset(
                              'assets/ic_energy.svg',
                              colorFilter: const ColorFilter.mode(
                                  Colors.orange, BlendMode.srcIn),
                            ),
                          ));
                    }),
                  if (_data != null)
                    ..._data!.map((item) {
                      final double latitude = item['latitude'] is double
                          ? item['latitude'] as double
                          : 0.0;
                      final double longitude = item['longitude'] is double
                          ? item['longitude'] as double
                          : 0.0;

                      return Marker(
                          point: LatLng(latitude, longitude),
                          width: 40,
                          height: 40,
                          child: InkWell(
                            onTap: () {
                              showDetailCar(context, item);
                            },
                            child: Visibility(
                              visible: item['status'] as int == 1 &&
                                  item['battery_status'] as int > 10,
                              child: Stack(
                                children: [
                                  SvgPicture.asset(
                                    'assets/ic_car.svg',
                                    colorFilter: const ColorFilter.mode(
                                        Colors.green, BlendMode.srcIn),
                                  ),
                                  Visibility(
                                    visible:
                                        item['battery_status'] as int <= 10,
                                    child: const Align(
                                      alignment: Alignment.topRight,
                                      child: Icon(
                                        Icons.report_problem,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ));
                    }),
                ],
              ),
            ],
          ),
          const FloatingMenuButton()
        ],
      ),
    );
  }

  void showIntroDialogIfNeeded() {
    const seenIntroBoxKey = 'seenIntroBox(a)';
    if (kIsWeb && Uri.base.host.trim() == 'demo.fleaflet.dev') {
      SchedulerBinding.instance.addPostFrameCallback(
        (_) async {
          final prefs = await SharedPreferences.getInstance();
          if (prefs.getBool(seenIntroBoxKey) ?? false) return;

          if (!mounted) return;

          await showDialog<void>(
            context: context,
            builder: (context) => const FirstStartDialog(),
          );
          await prefs.setBool(seenIntroBoxKey, true);
        },
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
