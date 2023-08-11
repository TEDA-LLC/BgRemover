import 'package:flutter/material.dart';
import 'dart:io';

class PreviewScreen extends StatelessWidget {

  const PreviewScreen({required this.picture, Key? key}) : super(key: key);
  final File picture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.file(File(picture.path), fit: BoxFit.cover, width: 250),
          const SizedBox(height: 24),
          Text(picture.path),
        ]),
      ),
    );
  }
}