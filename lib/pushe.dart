import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

///
/// Enum: Notification id type
/// @author Mahdi Malvandi
///
enum IdType { DeviceId, GoogleAdvertisingId, CustomId }
enum EventAction { custom, sign_up, login, purchase, achievement, level }

