import 'dart:convert';

import 'package:favorite_place/models/place.dart';
import 'package:favorite_place/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;


  String get locationImage {
    if(_pickedLocation == null){
      return '';
    }
    // final lat = _pickedLocation!.latitude;
    // final lng = _pickedLocation!.longitude;
    final lat = 23.7516833;
    final lng = 90.3856833;
    return 'https://maps.geoapify.com/v1/staticmap?style=osm-bright-smooth&width=600&height=400&center=lonlat:$lng,$lat&zoom=14&apiKey=ba67c02940cd40dc9249de686c079016';
  }

  Future<void> _savePlace(double latitude, double longitude) async {

    //final url = Uri.parse('https://api.geoapify.com/v1/geocode/reverse?lat=$latitude&lon=$longitude&apiKey=ba67c02940cd40dc9249de686c079016');
    final url = Uri.parse('https://api.geoapify.com/v1/geocode/reverse?lat=24.3746&lon=88.6004&apiKey=ba67c02940cd40dc9249de686c079016');
    final response = await http.get(url);
    final resData = json.decode(response.body);
    print("-------------------------------------");
    print(resData);
    final address = resData['features'][0]['properties']['formatted'];
    print(address);

    setState(() {
      _pickedLocation = PlaceLocation(latitude: latitude, longitude: latitude, address: address);
      _isGettingLocation = false;
    });

    widget.onSelectLocation(_pickedLocation!);

  }



  void _getCurrentLocation() async{

    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;

    print(locationData.latitude);
    print(locationData.longitude);

    if(lat == null || lng == null){
      ///showing error
      return;
    }
    _savePlace(lat, lng);
  }

  void _selectOnMap() async {
   final pickedLocation =  await Navigator.of(context).push<LatLng>(MaterialPageRoute(builder: (ctx) => MapScreen()));
   if(pickedLocation == null){
     return;
   }
   _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }


  @override
  Widget build(BuildContext context) {

    Widget previewContent = Text("No location chosen",textAlign: TextAlign.center,style: Theme.of(context).textTheme.bodyLarge!.copyWith(
      color: Theme.of(context).colorScheme.onBackground,
    ),);

    if(_pickedLocation!=null){
      previewContent = Image.network(locationImage,fit: BoxFit.cover,width: double.infinity,height: double.infinity,);
    }
    if(_isGettingLocation){
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.location_on),
                label: const Text("Get Current Location"),
            ),

            TextButton.icon(
              onPressed: _selectOnMap,
              icon: const Icon(Icons.map),
              label: const Text("Select on Map"),
            ),
          ],
        )
      ],
    );
  }

}

