// Import du modèle Place
import 'package:favorite_places/models/place.dart';
// Import de l'écran de détail d'un lieu
import 'package:favorite_places/screens/places_detail.dart';
// Import des widgets Flutter de base
import 'package:flutter/material.dart';

// Widget stateless qui affiche la liste des lieux favoris
class PlacesList extends StatelessWidget {
  const PlacesList({super.key, required this.places});

  // Liste des lieux à afficher passée depuis le parent
  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    // Si la liste est vide, on affiche un message centré
    if (places.isEmpty) {
      return const Center(child: Text('No places added yet'));
    }

    // Sinon on retourne une ListView.builder qui génère les items de manière paresseuse
    return ListView.builder(
      itemCount: places.length, // Nombre d'éléments dans la liste
      itemBuilder: (ctx, index) => ListTile( // Construit chaque élément de la liste
        leading: CircleAvatar( // Petit rond avec l'image du lieu
          radius: 26,
          backgroundImage: FileImage(places[index].image), // Image du lieu
        ),
        title: Text(
          places[index].title, // Titre du lieu
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface, // Couleur du texte selon le thème
          ),
        ),
        subtitle: Text(
          places[index].location.address, // Adresse du lieu en sous-texte
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurface, // Couleur du texte
          ),
        ),
        onTap: () {
          // Quand on clique sur un lieu, on ouvre l'écran de détail via Navigator
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => PlaceDetailScreen(place: places[index]),
            ),
          );
        },
      ),
    );
  }
}
