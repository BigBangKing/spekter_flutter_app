import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapAssessmentForSpekter(),
    );
  }
}

class MapAssessmentForSpekter extends StatefulWidget {
  @override
  State<MapAssessmentForSpekter> createState() => MapAssessmentState();
}

class MapAssessmentState extends State<MapAssessmentForSpekter> {
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> position_Markers = Set();
  final _formKey = GlobalKey<FormState>();
  MapType _currentMapType = MapType.hybrid;
  String current_coordinates;
  String nameText;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<bool> check_request_permission() async {
    Location location = new Location();
    // location.changeSettings(accuracy: LocationAccuracy.balanced);
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;
    // print("Hell0. Checking if loc service enabled.");
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      // print("Hell0. Loc Service is not enabled. Requesting to enable.");
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // print("Hell0. service is not enabled.");
        return true;
      }
      // print("Hell0. service is enabled.");
    }

    // print("Hell0. Checking for permission.");
    _permissionGranted = await location.hasPermission();
    // print("Hell0. Got perm: " + _permissionGranted.toString());
    if (_permissionGranted == PermissionStatus.granted) {
      // print("Hell0. permission granted.");
      _locationData = await location.getLocation();
      _addMarker(_locationData);
      _set_to_myPosition(_camPosition(_locationData));
      return true;
    } else if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == PermissionStatus.granted) {
        // print("Hell0. permission was denied and now it is granted.");
        _locationData = await location.getLocation();
        _set_to_myPosition(_camPosition(_locationData));
        _addMarker(_locationData);
        // print("Hell0. set loc.");
        return true;
      }
    }
  }

  CameraPosition _camPosition(LocationData position) {
    return CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 19.0);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: _currentMapType,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          check_request_permission();
        },
        markers: position_Markers,
      ),
    );
  }

  Future<void> _set_to_myPosition(CameraPosition cameraPosition) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  /*
  //if required to change MapType
  changeMapType(MapType type) {
    setState(() {
      //_currentMapType = type;
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }
  */

  void _addMarker(LocationData locationData) {
    setState(() {
      current_coordinates = "lat: " +
          locationData.latitude.toString() +
          ", long: " +
          locationData.longitude.toString();
      position_Markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(locationData.toString()),
        position: LatLng(locationData.latitude, locationData.longitude),
        infoWindow: InfoWindow(
          title: 'This is your location',
          snippet: 'Cool place. ' + current_coordinates,
        ),
        icon: BitmapDescriptor.defaultMarker,
        onTap: () {
          //marker tapped.
          showModalForInputs();
        },
      ));
    });
  }

  void showModalForInputs() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17.0),
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return Container(
            // color: Colors.black.withOpacity(0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      title: Text(current_coordinates),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter your name';
                        }
                        nameText = " name: " + value;
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RaisedButton(
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if
                          // the form is invalid.
                          if (_formKey.currentState.validate()) {
                            // Process data.
                            //As mentioned on requirement email, sending the required data to console.
                            print(current_coordinates + nameText);
                          }
                        },
                        child: Text('Send'),
                      ),
                    ),
                  ],
                ),
              ));
        });
  }
}
