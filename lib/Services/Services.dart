// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService{
  void deleteSelectedDocuments(List<String> documentIds) async {
    final batch = FirebaseFirestore.instance.batch();
    final collectionRef = FirebaseFirestore.instance.collection('Todos');

    for (final id in documentIds) {
      final docRef = collectionRef.doc(id);
      batch.delete(docRef);
    }
    await batch.commit();
    print('Selected documents deleted successfully!');
  }

}


