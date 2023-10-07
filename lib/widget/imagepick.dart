import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickedImage});
  final void Function(File pickedimage) onPickedImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? pickedImageFile;
  @override
  Widget build(BuildContext context) {
    void _pickImage() async {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 150,
      );
      if (pickedImage == null) {
        return;
      }
      setState(() {
        pickedImageFile = File(pickedImage.path);
      });

      widget.onPickedImage(pickedImageFile!);
    }

    return Column(
      children: [
        InkWell(
          onTap: _pickImage,
          child: CircleAvatar(
            
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundImage:
                pickedImageFile != null ? FileImage(pickedImageFile!) : null,
            child: Icon(Icons.person),
          ),
        ),
       
      ],
    );
  }
}