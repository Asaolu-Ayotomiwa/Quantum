import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestFirestoreConnection extends StatelessWidget {
  const TestFirestoreConnection({super.key});

  Future<void> testWrite() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      print('🔵 Testing Firestore write...');
      print('🔵 User ID: ${user.uid}');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'email': user.email,
        'username': 'Test User ${DateTime.now().millisecondsSinceEpoch}',
        'bio': 'Testing Firestore connection',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
        'isOnline': true,
        'profilePicUrl': null,
      });

      print('✅ Write successful!');
      print('✅ Check Firebase Console → Firestore → users collection');
    } catch (e) {
      print('❌ Write failed: $e');
    }
  }

  Future<void> testRead() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      print('🔵 Testing Firestore read...');

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        print('✅ Read successful!');
        print('📄 Data: ${doc.data()}');
      } else {
        print('⚠️ Document does not exist');
        print('💡 Try running TEST WRITE first');
      }
    } catch (e) {
      print('❌ Read failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Firestore'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_done,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              'Firestore Connection Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Test Write Button
            ElevatedButton.icon(
              onPressed: testWrite,
              icon: const Icon(Icons.upload),
              label: const Text('TEST WRITE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Test Read Button
            ElevatedButton.icon(
              onPressed: testRead,
              icon: const Icon(Icons.download),
              label: const Text('TEST READ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Check your console for test results',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}