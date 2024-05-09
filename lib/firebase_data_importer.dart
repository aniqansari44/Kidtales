import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataImporter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> importJsonData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/fyp_stories.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      for (var item in jsonData) {
        await _firestore.collection('stories').add(item);
      }

      print('Data imported successfully');
      return true; // Indicate success
    } catch (e) {
      print('Error during import: $e');
      return false; // Indicate failure
    }
  }
}

