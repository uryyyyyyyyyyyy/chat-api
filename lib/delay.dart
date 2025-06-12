import 'dart:math';

//既読遅延
Map<String, dynamic> getReplyBehavior() {
  final now = DateTime.now();
  final hour = now.hour;
  final minute = now.minute;
  final totalMinutes = hour * 60 + minute;
  final random = Random();

  if (totalMinutes >= 360 && totalMinutes < 450) { // 6:00〜7:30
    return {'canReply': true, 'delay': random.nextInt(3) + 1};
  } else if (totalMinutes >= 450 && totalMinutes < 960) { // 7:30〜16:00
    return {'canReply': true, 'delay': random.nextInt(5) + 5};
  } else if (totalMinutes >= 960 && totalMinutes < 1080) { // 16:00〜18:00
    return {'canReply': random.nextBool(), 'delay': random.nextInt(11) + 10};
  } else if (totalMinutes >= 1080 && totalMinutes < 1140) { // 18:00〜19:00
    return {'canReply': true, 'delay': random.nextInt(5) + 2};
  } else if (totalMinutes >= 1140 && totalMinutes < 1260) { // 19:00〜21:00
    return {'canReply': true, 'delay': random.nextInt(3) + 1};
  } else if (totalMinutes >= 1260 && totalMinutes < 1560) { // 21:00〜24:00
    return {'canReply': true, 'delay': random.nextInt(3) + 10};
  } else if (totalMinutes >= 0 && totalMinutes < 180) { // 0:00〜2:00
      return {'canReply': true, 'delay': random.nextInt(5) + 5};
    }else {
    return {'canReply': random.nextInt(10) == 0, 'delay': random.nextInt(30) + 10};
  }
}


//返信時間把握関数
String classifyTime(DateTime time) {
  final hour = time.hour;

  if (hour >= 5 && hour < 9) return 'early_morning';
  if (hour >= 9 && hour < 12) return 'morning';
  if (hour >= 12 && hour < 17) return 'afternoon';
  if (hour >= 17 && hour < 21) return 'evening';
  if (hour >= 21 || hour < 1) return 'night';
  return 'midnight';
}




