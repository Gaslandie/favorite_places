// 📦 Imports nécessaires
import 'package:flutter/material.dart'; // Package Flutter de base
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Package pour afficher Google Maps dans l’app

import 'package:favorite_places/models/place.dart'; // Modèle des lieux favoris

// 📌 Widget MapScreen : écran qui affiche une carte Google Maps
class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,

    // Position par défaut si aucune position n’est passée
    this.location = const PlaceLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: '',
    ),

    // Mode sélection activé ou pas (true = on peut cliquer sur la carte)
    this.isSelecting = true,
  });

  final PlaceLocation location; // Position initiale à afficher
  final bool isSelecting;        // Booléen pour activer/désactiver sélection

  @override
  State<MapScreen> createState() {
    return _MapScreen(); // Crée l’état associé
  }
}

// 📌 Classe d’état de MapScreen
class _MapScreen extends State<MapScreen> {
  // Variable pour stocker la position choisie par l'utilisateur
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Titre de l'appbar qui dépend du mode sélection ou pas
        title: Text(
          widget.isSelecting ? 'Pick your location' : 'Your location',
        ),
        actions: [
          // Si en mode sélection : bouton save actif
          if (widget.isSelecting)
            IconButton(
              onPressed: () {
                // Quand on clique sur save → retourne la position choisie
                Navigator.of(context).pop(_pickedLocation);
              },
              icon: const Icon(Icons.save),
            ),
        ],
      ),

      // 📌 Corps de la page : GoogleMap
      body: GoogleMap(
        // Si mode sélection actif : on gère le clic sur la carte
        onTap: !widget.isSelecting
            ? null
            : (position) {
                setState(() {
                  // Stocke la position choisie dans _pickedLocation
                  _pickedLocation = position;
                });
              },

        // 📌 Position initiale de la caméra au démarrage
        initialCameraPosition: CameraPosition(
          // Cible (latitude / longitude) : position passée en paramètre
          target: LatLng(widget.location.latitude, widget.location.longitude),
          zoom: 16, // Niveau de zoom initial
        ),

        // 📌 Marqueurs à afficher sur la carte
        markers: (_pickedLocation == null && widget.isSelecting)
            // Si aucune position choisie et en mode sélection : aucun marqueur
            ? {}
            : {
                // Sinon : affiche un marqueur
                Marker(
                  markerId: const MarkerId('m1'),
                  // Position du marqueur : celle choisie ou la position initiale
                  position: _pickedLocation ??
                      LatLng(
                        widget.location.latitude,
                        widget.location.longitude,
                      ),
                ),
              },
      ),
    );
  }
}
