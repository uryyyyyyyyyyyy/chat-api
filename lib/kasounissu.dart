import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<int> getVirtualDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('virtual_day') ?? 1;
  }

  Future<void> incrementVirtualDay() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('virtual_day') ?? 1;
    await prefs.setInt('virtual_day', current + 1);
  }

  DateTime getVirtualDate(int day) {
    final start = DateTime(2022, 4, 8);
    return start.add(Duration(days: day - 1));
  }

  Future<String> fetchMemoryForToday() async {
    int day = await getVirtualDay();
    DateTime virtualDate = getVirtualDate(day);
    String docId = virtualDate.toIso8601String().split('T')[0]; // e.g., "2025-04-09"

    final doc = await FirebaseFirestore.instance
        .collection('character_memory')
        .doc(docId)
        .get();

    if (doc.exists && doc.data()!.containsKey('memory')) {
      return doc['memory'];
    } else {
      return ''; // データがない日は空文字を返す
    }
  }