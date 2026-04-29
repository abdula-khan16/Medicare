import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get data of pateint all
  Future<Map<String, dynamic>?> getPatientData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

//update profile
  Future<void> updatePatientProfile({
    required String uid,
    String? name,
    String? phone,
    String? dob,
    String? address,
    String? allergies,
    String? bloodGroup,
    String? emergencyContact,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (dob != null) updateData['dob'] = dob;
      if (address != null) updateData['address'] = address;
      if (allergies != null) updateData['allergies'] = allergies;
      if (bloodGroup != null) updateData['bloodGroup'] = bloodGroup;
      if (emergencyContact != null) updateData['emergencyContact'] = emergencyContact;

      await _firestore.collection('users').doc(uid).set(updateData, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  //book appointment
  Future<Map<String, dynamic>> bookAppointment({
    required String patientId,
    required String doctorId,
    required String sessionId,
    required String date,
    required String time,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        DocumentReference sessionRef = _firestore.collection('sessions').doc(sessionId);
        DocumentSnapshot sessionSnap = await transaction.get(sessionRef);

        if (!sessionSnap.exists) throw "Session not found";

        int totalSlots = sessionSnap['totalSlots'] ?? 0;
        int bookedSlots = sessionSnap['bookedSlots'] ?? 0;

        if (bookedSlots >= totalSlots) throw "Session is full";

        int nextToken = bookedSlots + 1;
        String checkupId = 'CHK-${nextToken.toString().padLeft(3, '0')}';

        DocumentReference appRef = _firestore.collection('appointments').doc();
        transaction.set(appRef, {
          'patientId': patientId,
          'doctorId': doctorId,
          'sessionId': sessionId,
          'date': date,
          'time': time,
          'tokenNumber': nextToken,
          'checkupId': checkupId,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.update(sessionRef, {'bookedSlots': nextToken});

        return {
          'checkupId': checkupId,
          'tokenNumber': nextToken.toString(),
        };
      });
    } catch (e) {
      rethrow;
    }
  }

//cancel appointment
  Future<void> cancelAppointment(String appointmentId, String sessionId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference appRef = _firestore.collection('appointments').doc(appointmentId);
        DocumentReference sessionRef = _firestore.collection('sessions').doc(sessionId);
        
        DocumentSnapshot sessionSnap = await transaction.get(sessionRef);
        if (sessionSnap.exists) {
          int currentBooked = sessionSnap['bookedSlots'] ?? 0;
          if (currentBooked > 0) {
            transaction.update(sessionRef, {'bookedSlots': currentBooked - 1});
          }
        }
        transaction.delete(appRef);
      });
    } catch (e) {
      rethrow;
    }
  }


  Future<List<Map<String, dynamic>>> getPatientAppointments(String patientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .get();

      List<Map<String, dynamic>> appointments = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        
        DocumentSnapshot docSnap = await _firestore.collection('users').doc(data['doctorId']).get();
        if (docSnap.exists) {
          data['doctorName'] = docSnap['name'] ?? 'Unknown Doctor';
          data['specialization'] = docSnap['specialization'] ?? 'Specialist';
        }

        appointments.add({'id': doc.id, ...data});
      }

      appointments.sort((a, b) {
        Timestamp t1 = a['createdAt'] ?? Timestamp.now();
        Timestamp t2 = b['createdAt'] ?? Timestamp.now();
        return t2.compareTo(t1); // Descending
      });

      return appointments;
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPatientPrescriptions(
      String patientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('prescriptions')
          .where('patientId', isEqualTo: patientId)
          .get();

      final prescriptions = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      prescriptions.sort((a, b) {
        final aDate = a['date'] is Timestamp ? a['date'] as Timestamp : Timestamp(0, 0);
        final bDate = b['date'] is Timestamp ? b['date'] as Timestamp : Timestamp(0, 0);
        return bDate.compareTo(aDate);
      });

      return prescriptions;
    } catch (e) {
      print('Error fetching prescriptions: $e');
      return [];
    }
  }
}
