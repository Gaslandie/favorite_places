import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart'
    as syspaths; //obtenir les dossier du systemes de fichiers
import 'package:path/path.dart'
    as path; //manipuler les chemins de fichiers/dossier
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import 'package:favorite_places/models/place.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();

  //Ouvre ou crée si elle n'existe pas, une base de données places.db dans ce dossier
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)',
      );
    },
    version: 1, //permet de gerer les mises à jour de la base
  );
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query('user_places');
    final places = data
        .map(
          (row) => Place(
            id: row['id'] as String,
            title: row['title'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
              latitude: row['lat'] as double,
              longitude: row['lng'] as double,
              address: row['address'] as String,
            ),
          ),
        )
        .toList();

    state = places;
  }

  void addPlace(String title, File image, PlaceLocation location) async {
    //recupere le dossier de l'application sur l'appareil
    final appDir = await syspaths.getApplicationDocumentsDirectory();

    //Extrait le nom du fichier à partir du chemin complet de l'image
    final filename = path.basename(image.path);

    //copie le fichier image original dans le dossier documents avec son nom de fichier
    final copiedImage = await image.copy('${appDir.path}/$filename');

    final newplace = Place(title: title, image: image, location: location);

    final db = await _getDatabase();
    //insère une nouvelle ligne dans la table user_places
    db.insert('user_places', {
      'id': newplace.id,
      'title': newplace.title,
      'image': newplace.image.path,
      'lat': newplace.location.latitude,
      'lng': newplace.location.longitude,
      'address': newplace.location.address,
    });

    state = [newplace, ...state];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
      (ref) => UserPlacesNotifier(),
    );
