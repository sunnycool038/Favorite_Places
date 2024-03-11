//import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
//import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectedLocation});
  final void Function(PlaceLacation lacation) onSelectedLocation;
  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLacation? _pickedLocation;

  String get locationImage {
    if (_pickedLocation == null) {
      return "";
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyDLcwxUggpPZoBIcbH0TB4Crq5SJjtj4ag';
  }

  var _isGettingLocation = false;
  void _getCurrentLocation() async {
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
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyDLcwxUggpPZoBIcbH0TB4Crq5SJjtj4ag');

    //final response = await http.get(url);

    if (lat == null || lng == null) {
      return;
    }

    final response = {
      "results": [
        {
          "address_components": [
            {
              "long_name": "277",
              "short_name": "277",
              "types": ["street_number"]
            },
            {
              "long_name": "Bedford Avenue",
              "short_name": "Bedford Ave",
              "types": ["route"]
            },
            {
              "long_name": "Williamsburg",
              "short_name": "Williamsburg",
              "types": ["neighborhood", "political"]
            },
            {
              "long_name": "Brooklyn",
              "short_name": "Brooklyn",
              "types": ["sublocality", "political"]
            },
            {
              "long_name": "Kings",
              "short_name": "Kings",
              "types": ["administrative_area_level_2", "political"]
            },
            {
              "long_name": "New York",
              "short_name": "NY",
              "types": ["administrative_area_level_1", "political"]
            },
            {
              "long_name": "United States",
              "short_name": "US",
              "types": ["country", "political"]
            },
            {
              "long_name": "11211",
              "short_name": "11211",
              "types": ["postal_code"]
            }
          ],
          "formatted_address": "277 Bedford Avenue, Brooklyn, NY 11211, USA",
          "geometry": {
            "location": {"lat": 40.714232, "lng": -73.9612889},
            "location_type": "ROOFTOP",
            "viewport": {
              "northeast": {"lat": 40.7155809802915, "lng": -73.9599399197085},
              "southwest": {"lat": 40.7128830197085, "lng": -73.96263788029151}
            }
          },
          "place_id": "ChIJd8BlQ2BZwokRAFUEcm_qrcA",
          "types": ["street_address"]
        }
      ]
    };

    final resdata = json.decode(response.toString());
    final address = resdata['results'][0]['formatted_address'];

    setState(() {
      _pickedLocation =
          PlaceLacation(latitude: lat, longitude: lng, address: address);
      _isGettingLocation = false;
    });

    widget.onSelectedLocation(_pickedLocation!);
  }

  @override
  Widget build(BuildContext context) {
    Widget prieviewContent = Text(
      "No location choosen",
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.onBackground),
    );
    if (_pickedLocation != null) {
      prieviewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    if (_isGettingLocation == true) {
      prieviewContent = const CircularProgressIndicator();
    }
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: Theme.of(context).colorScheme.primary),
          ),
          child: prieviewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              label: const Text("Get current location"),
              icon: const Icon(Icons.location_on),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.map),
              label: const Text("select the map"),
            ),
          ],
        )
      ],
    );
  }
}
