// Imports des providers (gestion d’état), écrans et widgets nécessaires
import 'package:favorite_places/providers/user_places.dart';
import 'package:favorite_places/screens/add_place.dart';
import 'package:favorite_places/widgets/places_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Widget principal de l'écran qui utilise Riverpod
// ConsumerStatefulWidget : équivalent de StatefulWidget mais avec accès au ref de Riverpod
class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() {
    return _PlacesScreenState(); // Crée l'état associé à ce widget
  }
}

// Classe de l'état de PlacesScreen
class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  // Déclare une variable Future qui va contenir le chargement des lieux
  late Future<void> _placesFuture;

  // Méthode qui s'exécute une seule fois à la création du widget
  @override
  void initState() {
    super.initState();
    // On charge les lieux enregistrés via le provider
    _placesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
  }

  // Méthode build : construit l'interface de l'écran
  @override
  Widget build(BuildContext context) {
    // ref.watch : permet de "surveiller" le provider et reconstruire le widget si sa valeur change
    final userPlaces = ref.watch(userPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'), // Titre de l'app bar
        actions: [
          // Bouton pour naviguer vers l'écran d'ajout de lieu
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(
                builder: (ctx) => AddPlaceScreen(), // Navigation vers AddPlaceScreen
              ));
            },
            icon: Icon(Icons.add), // Icône +
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Marge interne autour du corps
        child: 
        // FutureBuilder : widget spécial de Flutter qui permet de gérer des opérations asynchrones (Future)
        // et de construire un widget en fonction de l'état de ce Future (chargement, terminé, erreur…)
        FutureBuilder(
          // future : le Future qu'on veut surveiller ici (chargement des lieux depuis la base locale)
          future: _placesFuture,

          // builder : fonction appelée automatiquement à chaque changement d’état du Future
          builder: (context, snapshot) =>
              // snapshot : objet qui contient l’état actuel du Future et sa valeur (data ou erreur)
              // Il possède plusieurs propriétés comme : connectionState, hasData, hasError, data, error…
              snapshot.connectionState == ConnectionState.waiting
              ? const Center(
                  child: CircularProgressIndicator(), // Si en attente : affiche un loader circulaire au centre
                )
              : PlacesList(
                  places: userPlaces, // Sinon : affiche la liste des lieux via PlacesList
                ),
        ),
      ),
    );
  }
}
