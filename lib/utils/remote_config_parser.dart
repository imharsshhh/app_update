import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';

class RemoteConfigService {
  // Singleton pattern
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Initialize remote config
  Future<void> initialize({
    Duration fetchTimeout = const Duration(seconds: 10),
    Duration minimumFetchInterval = Duration.zero,
  }) async {
    try {
      // Set up remote config settings
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: fetchTimeout,
        minimumFetchInterval: minimumFetchInterval,
      ));

      // Fetch and activate the latest configuration
      await _remoteConfig.fetchAndActivate();
    } on PlatformException catch (exception, stackTrace) {
      _logError('Platform Exception in Remote Config', exception, stackTrace);
    } catch (exception, stackTrace) {
      _logError('Unable to fetch remote config', exception, stackTrace);
    }
  }

  // Get a string value from remote config
  String getString(String key, {String defaultValue = ''}) {
    try {
      return _remoteConfig.getString(key);
    } catch (e) {
      _logError('Error getting string for key: $key', e);
      return defaultValue;
    }
  }

  // Get a bool value from remote config
  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _remoteConfig.getBool(key);
    } catch (e) {
      _logError('Error getting bool for key: $key', e);
      return defaultValue;
    }
  }

  // Get an int value from remote config
  int getInt(String key, {int defaultValue = 0}) {
    try {
      return _remoteConfig.getInt(key);
    } catch (e) {
      _logError('Error getting int for key: $key', e);
      return defaultValue;
    }
  }

  // Get a double value from remote config
  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return _remoteConfig.getDouble(key);
    } catch (e) {
      _logError('Error getting double for key: $key', e);
      return defaultValue;
    }
  }

  // Centralized logging method
  void _logError(String message, Object exception, [StackTrace? stackTrace]) {
    log(
      message,
      error: exception,
      stackTrace: stackTrace,
    );
  }
}
