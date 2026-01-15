import 'dart:math';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeCreator {
  static int  qrCodes = 0;
  static int cardCounter = 0;
  static List<int> cardNumbers = [];
  static int cardNumber = 0;

  void load(cardCount) {
    for (cardCounter = 0; cardCounter <= cardCount; cardCounter++) { // loop from 0 to cardCount
      cardNumbers.add(cardCounter);
      
      }
    print(cardNumbers);
    }
  }