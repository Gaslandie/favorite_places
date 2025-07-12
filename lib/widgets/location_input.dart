import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  Location? _pickedLocation;
  var _isGettingLocation = false;
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

    setState(() {
      _isGettingLocation = false;
    });
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
