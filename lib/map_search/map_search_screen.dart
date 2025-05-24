// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:map_search_places/constants/app_constants.dart';
import 'package:map_search_places/map_search/widgets/bottom_content_widget.dart';
import 'package:map_search_places/map_search/widgets/header_widget.dart';
import 'package:map_search_places/theme/app_colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Relationship {
  int id;
  String name;

  Relationship({
    required this.id,
    required this.name,
  });
}

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  LatLng? _currentPosition;
  late GoogleMapController _currentMapController;
  Set<Marker> markers = {};
  late final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: AppConstants.kGoogleApiKey);
  List<Prediction> _predictions = [];
  late String _mapTheme;
  bool _isSaveLocation = false;
  List<Relationship> _relationshipList = [];
  int _selectedRelationship = 0;

  @override
  void initState() {
    _loadMapStyle();
    _mapPreProcessing();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _relationshipList = [
      Relationship(id: 1, name: "home"),
      Relationship(id: 2, name: "work"),
      Relationship(id: 3, name: "friend"),
      Relationship(id: 4, name: "restaurant"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          _searchController.text.isNotEmpty ? false : true,
      body: Skeletonizer(
        enabled: _currentPosition == null,
        enableSwitchAnimation: true,
        child: SafeArea(
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _currentPosition?.latitude ?? 23,
                    _currentPosition?.longitude ?? 47,
                  ),
                  zoom: 13,
                ),
                onMapCreated: _onMapCreated,
                onTap: (argument) {
                  markers.clear();
                  markers.add(
                    Marker(
                      markerId: const MarkerId("1"),
                      position: LatLng(argument.latitude, argument.longitude),
                    ),
                  );
                  _changeLocation(
                    10,
                    LatLng(argument.latitude, argument.longitude),
                  );

                  setState(() async {
                    List<Placemark> placemarks = await placemarkFromCoordinates(
                      argument.latitude ?? 23,
                      argument.longitude ?? 47,
                    );

                    Placemark place = placemarks.first;

                    String fullAddress =
                        ' ${place.locality}, ${place.administrativeArea}, ${place.country}';
                    // setState(() {
                    _addressController.text = fullAddress;
                  });
                },
                markers: markers,
                // mapType: MapType.terrain,
              ),
              Positioned(
                top: 30,
                right: 10,
                left: 10,
                child: HeaderWidget(
                  predictions: _predictions,
                  searchController: _searchController,
                  getPredictions: (value) async {
                    await Future.delayed(const Duration(seconds: 2));
                    _addressController.text = value;
                    _getPredictions(value).then((predictionsList) {
                      debugPrint('Predictions: $predictionsList');
                      setState(() {
                        _predictions = predictionsList;
                      });
                    });
                  },
                  clearSearch: () {
                    _searchController.clear();
                    setState(() {
                      _predictions.clear();
                    });
                  },
                ),
              ),
              if (_predictions.isNotEmpty)
                Positioned(
                  top: 125,
                  right: 10,
                  left: 10,
                  child: Container(
                    color: Colors.white,
                    height: 150,
                    child: ListView.builder(
                      itemCount: _predictions.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            _predictions[index].description!,
                            style: const TextStyle(color: Colors.black),
                          ),
                          onTap: () async {
                            PlacesDetailsResponse response =
                                await _places.getDetailsByPlaceId(
                              _predictions[index].placeId!,
                            );
                            //ToDO : ADD Address To Location Controller

                            _addressController.text =
                                _predictions[index].description!;
                            if (response.isOkay) {
                              double lat =
                                  response.result.geometry!.location.lat;
                              double lng =
                                  response.result.geometry!.location.lng;
                              _changeLocation(10, LatLng(lat, lng));
                              _predictions.clear();
                              setState(() {});
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomContentWidget(
                  currentPosition: _currentPosition,
                  addressController: _addressController,
                  isSaveLocation: _isSaveLocation,
                  onSaveLocation: (bool value) {
                    setState(() {
                      _isSaveLocation = value;
                    });
                  },
                  onContinue: ({
                    required String address,
                    required bool isSaveLocation,
                    required String relationship,
                  }) {
                    //TODO : API CALL
                  },
                  relationship: _relationshipList,
                  relationshipIndex: _selectedRelationship,
                  onRelationshipChanged: (int index) {
                    setState(() {
                      _selectedRelationship = index;
                    });
                  },
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                left: 0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: const CircleBorder(),
                  ),
                  onPressed: () {
                    _determinePosition(context).then((value) {
                      if (value != null) {
                        _changeLocation(
                          13,
                          LatLng(value.latitude, value.longitude),
                        );
                      }
                    });
                  },
                  child: const Icon(
                    Icons.my_location,
                    color: AppColors.background,
                    size: 24,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _loadMapStyle() {
    DefaultAssetBundle.of(context)
        .loadString('assets/map_theme/map_theme.json')
        .then((mapTheme) {
      _mapTheme = mapTheme;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    Completer<GoogleMapController> gmCompleter = Completer();
    gmCompleter.complete(controller);
    gmCompleter.future.then((gmController) {
      _currentMapController = gmController;
      _currentMapController.setMapStyle(_mapTheme);
    });
  }

  void _setCurrentLocation(LatLng currentPosition) {
    _currentPosition = currentPosition;
    setState(() {});
  }

  void _addMarkerToMap(LatLng currentPosition) {
    markers.add(
      Marker(
        markerId: const MarkerId("1"),
        position: LatLng(currentPosition.latitude, currentPosition.longitude),
      ),
    );
  }

  void _mapPreProcessing() async {
    try {
      Position? currentPosition = await _determinePosition(context);
      _setCurrentLocation(
        LatLng(
          currentPosition?.latitude ?? 23,
          currentPosition?.longitude ?? 47,
        ),
      );
      _addMarkerToMap(
        LatLng(
          currentPosition?.latitude ?? 23,
          currentPosition?.longitude ?? 47,
        ),
      );
    } catch (e) {
      _setCurrentLocation(LatLng(23, 47));
      _addMarkerToMap(LatLng(23, 47));
      _changeLocation(10, LatLng(23, 47));
    }
  }

  Future<List<Prediction>> _getPredictions(String query) async {
    PlacesAutocompleteResponse response = await _places.autocomplete(query);
    if (response.isOkay) {
      return response.predictions;
    } else {
      return [];
    }
  }

  void _changeLocation(double zoom, LatLng latLng) {
    double newZoom = zoom > 13 ? zoom : 13;
    _currentPosition = latLng;
    setState(() {
      _currentMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: newZoom)));
      markers.clear();
      _currentPosition = latLng;
      markers.add(
        Marker(markerId: const MarkerId('1'), position: latLng),
      );
    });
  }

  Future<Position?> _determinePosition(context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error(
          'Location services are disabled. Please enable them.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Navigator.pop(context);
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Navigator.pop(context);
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    // ✅ Get address from coordinates
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks.first;

    String fullAddress =
        ' ${place.locality}, ${place.administrativeArea}, ${place.country}';
    // setState(() {
    _addressController.text = fullAddress;
    // });
    return position;
  }
}
