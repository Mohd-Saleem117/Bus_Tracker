// ignore_for_file: prefer_const_constructors, library_prefixes, prefer_collection_literals
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LatLng destinationLatlng = LatLng(17.424143, 78.501748);

  LocationData? currentLocation;
  late LocationData destinationLocation;
  late Location location;
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    location = Location();
    setInitialLocation();
  }

  void setInitialLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    await location.getLocation().then((value) {
      currentLocation = value;
      setState(() {});
    });
    destinationLocation = LocationData.fromMap({
      "latitude": destinationLatlng.latitude,
      "longitude": destinationLatlng.longitude,
    });
    showPinsOnMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Maps")),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(currentLocation!.latitude ?? 0.0,
              currentLocation!.longitude ?? 0.0),
          zoom: 13.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/mohdsaleem/cl2be13l7001z14rv42y4hat2/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibW9oZHNhbGVlbSIsImEiOiJjbDJiY2I4ZHEwZGJxM2NvMnhpcGh2d2RmIn0.J2E66Ump9ciJeUG_GToJFQ",
            additionalOptions: {
              'accessToken':
                  'pk.eyJ1IjoibW9oZHNhbGVlbSIsImEiOiJjbDJiY2I4ZHEwZGJxM2NvMnhpcGh2d2RmIn0.J2E66Ump9ciJeUG_GToJFQ',
              'id': 'mapbox.mapbox-streets-v8'
            },
            attributionBuilder: (_) {
              return Text("© OpenStreetMap contributors");
            },
          ),
          MarkerLayerOptions(
            markers: _markers,
          ),
        ],
      ),
    );
  }

  void showPinsOnMap() {
    var sourcePosition = LatLng(
        currentLocation!.latitude ?? 0.0, currentLocation!.longitude ?? 0.0);

    var destinationPosition =
        LatLng(destinationLatlng.latitude, destinationLatlng.longitude);

    setState(() {
      _markers.add(Marker(
        point: sourcePosition,
        builder: (ctx) => Container(
          child: Icon(
            Icons.location_on,
            size: 40,
            color: Colors.red,
          ),
        ),
      ));

      _markers.add(Marker(
          point: destinationPosition,
          builder: (ctx) => Container(
                child: Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.blue,
                ),
              )));
      print(currentLocation!.latitude);
      print(currentLocation!.longitude);
    });
  }
}
