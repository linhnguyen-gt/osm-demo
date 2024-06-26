import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_example/misc/tile_providers.dart';
import 'package:flutter_map_example/widgets/drawer/floating_menu_button.dart';
import 'package:flutter_map_example/widgets/drawer/menu_drawer.dart';
import 'package:flutter_map_example/widgets/first_start_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

Future<List<dynamic>> fetchData() async {
  final url = Uri.parse('http://pinkapp.lol/api/v1/vehicle/list');
  final headers = {
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEiLCJyb2xlIjoxMCwiZW1haWwiOiJ1c2VyQGdtYWlsLmNvbSIsImlhdCI6MTcxOTI5MTcyMywiZXhwIjoxNzUwODQ5MzIzfQ.1Gsy-ojeHJn8Mfo2GZTFKcFbtj6ClK1aognp88o4Fwo'
  };

  final response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final metadata = jsonData['metadata'] as List<dynamic>;
    return metadata;
  } else {
    return [];
  }
}

class HomePage extends StatefulWidget {
  static const String route = '/';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic>? _data = [];

  @override
  void initState() {
    super.initState();
    showIntroDialogIfNeeded();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await fetchData();
    setState(() {
      _data = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(HomePage.route),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              // focus Nha Trang
              initialCenter: const LatLng(12.2388, 109.1967),
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
                  Marker(
                    point: const LatLng(12.242049, 109.187772),
                    width: 70,
                    height: 70,
                    child: Image.asset(
                      'assets/marker_location.png',
                    ),
                  ),
                  Marker(
                    point: const LatLng(12.230290, 109.164099),
                    width: 70,
                    height: 70,
                    child: Image.asset(
                      'assets/marker_location.png',
                    ),
                  ),
                  if (_data != null)
                    ..._data!.map((item) {
                      final double latitude = item['latitude'] as double;
                      final double longitude = item['longitude'] as double;
                      return Marker(
                        point: LatLng(latitude, longitude),
                        width: 40,
                        height: 40,
                        child: SvgPicture.asset(
                          'assets/ic_car.svg',
                          colorFilter: const ColorFilter.mode(
                              Colors.green, BlendMode.srcIn),
                        ),
                      );
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
}
