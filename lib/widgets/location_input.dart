import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'package:favorite_places/models/place.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  //google map static
  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:S%7C40.702147,-74.015794&markers=color:green%7Clabel:G%7C40.711614,-74.012318&markers=color:red%7Clabel:C%7C$lat,$lng&key=YOUR_API_KEY&signature=YOUR_SIGNATURE';
  }

  //fonction asynchrone pour recuperer la position actuelle de l'utilisateur
  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled; //var pour savoir si GPS est activé
    PermissionStatus
    permissionGranted; //var pour verifier si permission accordée
    LocationData locationData; //var pour stocker la position

    //verifie le GPS si activé
    serviceEnabled = await location.serviceEnabled();
    //si pas activé, demande au user
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      //si refuse on quitte la fonction
      if (!serviceEnabled) {
        return;
      }
    }

    //verifie si l'app à la permission de localisation
    permissionGranted = await location.hasPermission();
    //si refusée, demander au user
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      //si refus on quitte la fonction
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      _isGettingLocation = true;
    });
    //si tout est ok, service et permissions, on recupere la position GPS actuelle
    //du user sous forme de LocationData, qui contient: latitude, longitude, altitude, vitesse...
    locationData = await location.getLocation();

    //convertir nos coordonnées en adresse

    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=YOUR_API_KEY', //remplacer Your api key par le vrai key
    );

    final response = await http.get(url);
    final resData = json.decode(response.body);
    //address après conversion
    final address = resData['results'][0]['formatted_address'];

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: lat,
        longitude: lng,
        address: address,
      );
      _isGettingLocation = false;
    });
    widget.onSelectLocation(_pickedLocation!);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );

    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_isGettingLocation) {
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
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current location'),
              onPressed: _getCurrentLocation,
            ),
            TextButton.icon(
              icon: Icon(Icons.map),
              label: const Text('Select on map'),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
