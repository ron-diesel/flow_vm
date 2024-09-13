import 'dart:math';

class RandomMessage{
  RandomMessage._();
 static const allMessages =  [
    "Well done!",
    "Good job!",
    "Let's try again!",
    "One more time!",
  ];

 static String get(){
   final random = Random();
    return allMessages[random.nextInt(allMessages.length)];
  }
}