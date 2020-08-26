import 'package:flutter/material.dart';

const kBackgroundColor = const Color(0xFF0A0E21);

const kCardActive = const Color(0xFF1D1E33);
const kCardInactive = const Color(0xFF0A0E21);

const kLabelStyle = const TextStyle(fontSize: 18.0, color: Color(0xFF8D8E98));
const kNumberStyle =
const TextStyle(fontSize: 50.0, fontWeight: FontWeight.w900);
const kNumberStyle2 =
const TextStyle(fontSize: 65.0, fontWeight: FontWeight.w900);
const TextStyle ubuntu = const TextStyle(
    color: Colors.white,
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic);

const InputDecoration kTextFieldInputDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  icon: Icon(
    Icons.location_city,
    color: Colors.white,
  ),
  hintText: 'Enter city name',
  hintStyle: TextStyle(color: Colors.grey),
  border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide.none
  ),
);

const kTempTextStyle = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 100.0,
);

const kMessageTextStyle = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 60.0,
);

const kButtonTextStyle = TextStyle(
  fontSize: 30.0,
  fontFamily: 'Spartan MB',
);

const kConditionTextStyle = TextStyle(
  fontSize: 100.0,
);

const kPersonMinHeight = 120.0;
const kPersonMaxHeight = 240.0;
const kPersonMinWeight = 5.0;
const kPersonMaxWeight = 300.0;
const kPersonMinAge = 1.0;
const kPersonMaxAge = 130.0;

// region Chat App Constants
const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const kInputDecoration = InputDecoration(
  hintText: '',
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide:
    BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide:
    BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);
// endregion


