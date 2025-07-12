// 📦 Imports des packages nécessaires
import 'package:flutter/material.dart'; // Package Flutter UI de base
import 'package:image_picker/image_picker.dart'; // Package pour prendre des photos avec l'appareil photo
import 'dart:io'; // Package pour manipuler les fichiers locaux (File)

// 📌 Widget ImageInput : permet à l’utilisateur de prendre une photo avec son appareil photo
class ImageInput extends StatefulWidget {
  const ImageInput({
    super.key,

    // Fonction callback qu'on va exécuter quand une image est prise (pour la transmettre au parent)
    required this.onPickImage,
  });

  final void Function(File image) onPickImage; // Fonction passée depuis le parent

  @override
  State<ImageInput> createState() {
    return _ImageInputState(); // Associe l’état correspondant
  }
}

// 📌 Classe d’état pour le widget ImageInput
class _ImageInputState extends State<ImageInput> {
  // Variable pour stocker l’image sélectionnée
  File? _selectedImage;

  // 📌 Méthode pour prendre une photo avec l'appareil photo
  void _takePicture() async {
    // Crée une instance de ImagePicker
    final imagePicker = ImagePicker();

    // Ouvre l’appareil photo et récupère l’image sélectionnée (maxWidth limite la taille)
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    // Si aucune image prise → on quitte la fonction
    if (pickedImage == null) {
      return;
    }

    // Si une image est prise, on convertit le chemin en objet File et on le stocke
    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    // On exécute la fonction callback du parent avec l’image sélectionnée
    widget.onPickImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    // Par défaut : bouton pour ouvrir l’appareil photo
    Widget content = TextButton.icon(
      icon: const Icon(Icons.camera),
      label: const Text('Take a picture'),
      onPressed: _takePicture, // Appelle la fonction de prise de photo
    );

    // Si une image a été prise → affiche l’image au lieu du bouton
    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _takePicture, // Permet de reprendre une photo en tapant dessus
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover, // Remplit le conteneur sans déformer l’image
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    // 📌 Conteneur avec une bordure pour afficher le contenu (bouton ou image)
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: content, // Le bouton ou l’image selon l’état
    );
  }
}
