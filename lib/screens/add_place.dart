// 📦 Imports nécessaires
import 'dart:io'; // Pour manipuler des fichiers locaux (images)

import 'package:favorite_places/models/place.dart'; // Modèle de données Place
import 'package:favorite_places/widgets/image_input.dart'; // Widget pour prendre une photo
import 'package:favorite_places/widgets/location_input.dart'; // Widget pour récupérer la localisation
import 'package:flutter/material.dart'; // Package de base Flutter
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod pour la gestion d’état

import 'package:favorite_places/providers/user_places.dart'; // Provider des lieux favoris

// 📌 Widget de l'écran d'ajout de lieu qui utilise Riverpod pour accéder aux providers
class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() {
    return _AddPlaceScreen(); // Crée l’état associé
  }
}

// 📌 Classe d’état de AddPlaceScreen
class _AddPlaceScreen extends ConsumerState<AddPlaceScreen> {
  // Contrôleur pour récupérer le texte saisi dans le champ de texte
  final _titleController = TextEditingController();

  // Variables pour stocker l’image et la localisation choisies par l’utilisateur
  File? _selectedImage;
  PlaceLocation? _selectedLocation;

  // 📌 Fonction pour sauvegarder un lieu
  void _savePlace() {
    final enteredText = _titleController.text;

    // Vérifie si tout est bien rempli avant d’enregistrer
    if (enteredText.isEmpty || _selectedImage == null || _selectedLocation == null) {
      return;
    }

    // Ajoute le lieu via le provider en passant le titre, l'image et la localisation
    ref.read(userPlacesProvider.notifier).addPlace(
          enteredText,
          _selectedImage!,
          _selectedLocation!,
        );

    // Revient à l'écran précédent après l'ajout
    Navigator.of(context).pop();
  }

  // 📌 Libère le contrôleur mémoire quand l’écran est détruit
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // 📌 Méthode build : construit l’interface utilisateur
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add new Place')), // Titre de l’appbar

      // Corps de la page avec du contenu scrollable (pour éviter les débordements clavier)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12), // Marge autour du contenu
        child: Column(
          children: [
            // 📌 Champ de texte pour saisir le titre du lieu
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              controller: _titleController, // Associe le contrôleur
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),

            const SizedBox(height: 10), // Espacement vertical

            // 📌 Widget pour prendre une image
            ImageInput(
              onPickImage: (image) {
                _selectedImage = image; // Stocke l'image choisie
              },
            ),

            const SizedBox(height: 10),

            // 📌 Widget pour choisir une localisation
            LocationInput(
              onSelectLocation: (location) {
                _selectedLocation = location; // Stocke la localisation choisie
              },
            ),

            const SizedBox(height: 16),

            // 📌 Bouton pour sauvegarder le lieu
            ElevatedButton.icon(
              onPressed: _savePlace, // Quand on clique → appelle _savePlace
              icon: const Icon(Icons.add), // Icône +
              label: Text('Add Place'),
            ),
          ],
        ),
      ),
    );
  }
}
