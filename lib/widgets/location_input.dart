// 📦 Imports nécessaires
import 'dart:convert'; // Pour convertir les données JSON

import 'package:flutter/material.dart'; // Widgets et UI Flutter
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Pour manipuler Google Maps
import 'package:http/http.dart' as http; // Pour faire des requêtes HTTP
import 'package:location/location.dart'; // Pour accéder à la géolocalisation native

import 'package:favorite_places/screens/map.dart'; // Notre écran de sélection sur carte
import 'package:favorite_places/models/place.dart'; // Le modèle PlaceLocation qu'on a défini

// 📌 Widget LocationInput : permet de récupérer une localisation et l’afficher via Google Static Maps
class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  // Callback pour envoyer la localisation sélectionnée au parent
  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

// 📌 État associé à LocationInput
class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation; // Stocke la localisation sélectionnée
  var _isGettingLocation = false; // Booléen pour afficher le loader

  // 📌 Getter pour récupérer une image statique de Google Maps
  String get locationImage {
    // Si pas de position choisie, retourne une chaîne vide
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;

    // Retourne l’URL de la Static Map en intégrant latitude et longitude
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:S%7C40.702147,-74.015794&markers=color:green%7Clabel:G%7C40.711614,-74.012318&markers=color:red%7Clabel:C%7C$lat,$lng&key=YOUR_API_KEY&signature=YOUR_SIGNATURE';
  }

  // 📌 Sauvegarde de l’adresse correspondant aux coordonnées
  void _savePlace(double latitude, double longitude) async {
    // URL de l’API Google Geocoding
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=YOUR_API_KEY',
    );

    // On exécute la requête HTTP GET
    final response = await http.get(url);

    // On décode le JSON reçu
    final resData = json.decode(response.body);

    // Récupère l’adresse formatée du premier résultat
    final address = resData['results'][0]['formatted_address'];

    // Met à jour l’état avec la nouvelle localisation
    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      _isGettingLocation = false;
    });

    // Appelle le callback pour transmettre au parent
    widget.onSelectLocation(_pickedLocation!);
  }

  // 📌 Fonction pour obtenir la position actuelle via GPS
  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    // Vérifie si le service GPS est activé
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Si non, demande à l’activer
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Vérifie si la permission est accordée
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      // Si non, demande la permission
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Active l’état de chargement
    setState(() {
      _isGettingLocation = true;
    });

    // Récupère les coordonnées GPS actuelles
    locationData = await location.getLocation();

    final lat = locationData.latitude;
    final lng = locationData.longitude;

    // Si pas de coordonnées, on quitte
    if (lat == null || lng == null) {
      return;
    }

    // Sinon, on sauvegarde le lieu
    _savePlace(lat, lng);
  }

  // 📌 Fonction pour ouvrir MapScreen et récupérer le point sélectionné
  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(
      context,
    ).push<LatLng>(
      MaterialPageRoute(builder: (ctx) => const MapScreen()),
    );

    // Si rien sélectionné, on quitte
    if (pickedLocation == null) {
      return;
    }

    // Sinon, on sauvegarde le lieu choisi sur la carte
    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    // 📌 Contenu par défaut : message si aucune position choisie
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );

    // Si une localisation a été choisie → on affiche la carte statique
    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // Si en train de récupérer la localisation → afficher loader
    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    // 📌 Rendu final du widget
    return Column(
      children: [
        // 📌 Preview de la carte ou du message ou du loader
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: previewContent,
        ),
        // 📌 Deux boutons d’action (GPS et Map)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current location'),
              onPressed: _getCurrentLocation,
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Select on map'),
              onPressed: _selectOnMap,
            ),
          ],
        ),
      ],
    );
  }
}
