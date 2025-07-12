import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favorite_places/models/place.dart';
import 'dart:io';

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  void addPlace(String title, File image,PlaceLocation location) {
    final newplace = Place(title: title, image: image,location: location);
    state = [newplace, ...state];
  }
}

final userPlacesProvider = StateNotifierProvider<UserPlacesNotifier,List<Place>>(
  (ref) => UserPlacesNotifier(),
);
