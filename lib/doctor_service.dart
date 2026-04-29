import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DoctorService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createDoctorAccount({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String specialization,
    required String experience,
    required String location,
    required String about,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'doctor',
        'specialization': specialization,
        'experience': int.tryParse(experience) ?? 0,
        'location': location,
        'about': about,
        'createdAt': DateTime.now(),
        'profilePhoto': '',
      });

      print('Doctor account created successfully!');
    } catch (e) {
      print('Error creating doctor account: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getDoctorData(String uid) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting doctor data: $e');
      return null;
    }
  }

  Future<void> updateDoctorProfile({
    required String uid,
    String? name,
    String? specialization,
    String? experience,
    String? location,
    String? about,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (specialization != null) updateData['specialization'] = specialization;
      if (experience != null) updateData['experience'] = int.tryParse(experience) ?? 0;
      if (location != null) updateData['location'] = location;
      if (about != null) updateData['about'] = about;

      await _firestore.collection('users').doc(uid).set(
        updateData,
        SetOptions(merge: true),
      );

      print('Doctor profile updated successfully!');
    } catch (e) {
      print('Error updating doctor profile: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    try {
      QuerySnapshot snapshot =
      await _firestore.collection('users').where('role', isEqualTo: 'doctor').get();

      return snapshot.docs.map((doc) => {
        'uid': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Error getting all doctors: $e');
      return [];
    }
  }

  Future<String?> createSession({
    required String doctorId,
    required String title,
    required String description,
    required DateTime date,
    required String startTime,
    required String endTime,
    required int gapBetweenPatients,
    required bool isRecurring,
  }) async {
    try {
      int totalSlots = _calculateTotalSlots(startTime, endTime, gapBetweenPatients);

      DocumentReference docRef =
      await _firestore.collection('sessions').add({
        'doctorId': doctorId,
        'title': title,
        'description': description,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'gapBetweenPatients': gapBetweenPatients,
        'totalSlots': totalSlots,
        'bookedSlots': 0,
        'isRecurring': isRecurring,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      return docRef.id;
    } catch (e) {
      print('Error creating session: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDoctorSessions(String doctorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('sessions')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      List<Map<String, dynamic>> sessions = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();

      sessions.sort((a, b) => (a['date'] as Timestamp).compareTo(b['date'] as Timestamp));

      return sessions;
    } catch (e) {
      print('Error getting doctor sessions: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDoctorPatients(String doctorId) async {
    try {
      QuerySnapshot appointmentSnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      Set<String> patientIds = {};
      for (var doc in appointmentSnapshot.docs) {
        patientIds.add(doc['patientId']);
      }

      List<Map<String, dynamic>> patients = [];
      for (String patientId in patientIds) {
        DocumentSnapshot patientDoc = await _firestore
            .collection('users')
            .doc(patientId)
            .get();

        if (patientDoc.exists) {
          patients.add({
            'uid': patientId,
            ...patientDoc.data() as Map<String, dynamic>,
          });
        }
      }

      return patients;
    } catch (e) {
      print('Error getting doctor patients: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPatientData(String patientId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(patientId)
          .get();

      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting patient data: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getTodayAppointments(
      String doctorId) async {
    try {
      final String today = DateFormat('MMM dd, yyyy').format(DateTime.now());

      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isEqualTo: today)
          .get();

      List<Map<String, dynamic>> appointments = [];

      DocumentSnapshot doctorDoc =
          await _firestore.collection('users').doc(doctorId).get();
      final String doctorName =
          (doctorDoc.data() as Map<String, dynamic>?)?['name'] ?? 'Doctor';

      for (var doc in snapshot.docs) {
        Map<String, dynamic> appointment =
        doc.data() as Map<String, dynamic>;

        String patientId = appointment['patientId'];

        DocumentSnapshot patientDoc = await _firestore
            .collection('users')
            .doc(patientId)
            .get();
        final patientData = patientDoc.data() as Map<String, dynamic>?;

        appointments.add({
          'appointmentId': doc.id,
          'patientData': patientData,
          'patientId': patientId,
          'doctorId': doctorId,
          'doctorName': doctorName,
          'patientName': patientData?['name'] ?? 'Patient',
          ...appointment,
        });
      }

      appointments.sort((a, b) {
        final int aToken = (a['tokenNumber'] ?? 99999) as int;
        final int bToken = (b['tokenNumber'] ?? 99999) as int;
        return aToken.compareTo(bToken);
      });

      return appointments;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> writePrescription({
    required String appointmentId,
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String patientName,
    required List<Map<String, String>> medicines,
    required String notes,
  }) async {
    await _firestore.collection('prescriptions').add({
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentId': appointmentId,
      'doctorName': doctorName,
      'patientName': patientName,
      'medicines': medicines,
      'notes': notes,
      'date': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': 'completed'});
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': 'cancelled'});
  }

  Future<void> completeAppointment(String appointmentId) async {
    await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': 'completed'});
  }




  //helper function
  int _parseTimeToMinutes(String time) {
    bool isPm = time.toUpperCase().contains('PM');
    bool isAm = time.toUpperCase().contains('AM');

    String cleanTime = time.replaceAll(RegExp(r'[a-zA-Z\s]'), '');
    List<String> parts = cleanTime.split(':');

    int hour = int.parse(parts[0]);
    int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

    if (isPm && hour < 12) hour += 12;
    if (isAm && hour == 12) hour = 0;

    return (hour * 60) + minute;
  }

  int _calculateTotalSlots(
      String startTime, String endTime, int gapMinutes) {
    int startMin = _parseTimeToMinutes(startTime);
    int endMin = _parseTimeToMinutes(endTime);
    if (endMin <= startMin) endMin += 24 * 60;
    return (endMin - startMin) ~/ gapMinutes;
  }

  Future<int> getDoctorTotalPatients(String doctorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'completed')
          .get();

      Set<String> uniquePatients = {};
      for (var doc in snapshot.docs) {
        uniquePatients.add(doc['patientId']);
      }
      return uniquePatients.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getTodayPatientCount(String doctorId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('createdAt', isLessThanOrEqualTo: endOfDay)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}