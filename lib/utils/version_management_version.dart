import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';

// import 'remote_config_parser.dart';

class VersionManagementService {
  // Singleton pattern
  static final VersionManagementService _instance =
      VersionManagementService._internal();
  factory VersionManagementService() => _instance;
  VersionManagementService._internal();

  // final RemoteConfigService _remoteConfigService = RemoteConfigService();

  // Version configuration
  late VersionConfig _versionConfig;

  // Getter for version configuration
  VersionConfig get versionConfig => _versionConfig;

  // Initialize version management
  Future<void> initialize() async {
    try {
      // Fetch version config from remote config
      // final versionConfigJson =
      // _remoteConfigService.getString('version_config');

      const versionConfigJson = '''
      {
  "version_config": {
    "latest_version": {
      "version": "1.3.0",
      "summary": "Major UI Overhaul and Performance Optimization",
      "detailed_changelog": [
        "Completely redesigned user dashboard with modern material design",
        "Reduced app startup time by 40%",
        "Implemented advanced caching mechanism",
        "Added dark mode support",
        "Enhanced error reporting and diagnostics"
      ]
    },
    "minimum_supported_version": {
      "version": "1.2.24",
      "summary": "Stability and Security Update",
      "detailed_changelog": [
        "Fixed critical security vulnerability in user authentication",
        "Improved database connection stability",
        "Optimized memory usage",
        "Resolved occasional crash on older devices"
      ]
    }
  }
}''';

      // Parse the version configuration
      final parsedConfig = json.decode(versionConfigJson);
      _versionConfig = VersionConfig.fromJson(parsedConfig['version_config']);
    } catch (e) {
      _logError('Error initializing version management', e);
      _setDefaultVersionConfig();
    }
  }

  // Set default version configuration if parsing fails
  void _setDefaultVersionConfig() {
    _versionConfig = VersionConfig(
      latestVersion: VersionDetails(
        version: '1.0.0',
        summary: 'Default Version',
        detailedChangelog: ['Initial release'],
      ),
      minimumSupportedVersion: VersionDetails(
        version: '1.0.0',
        summary: 'Minimum Supported Version',
        detailedChangelog: ['Base version'],
      ),
    );
  }

  // Check if update is recommended
  bool isUpdateRecommended(String currentVersion) {
    try {
      return _compareVersions(
              currentVersion, _versionConfig.latestVersion.version) <
          0;
    } catch (e) {
      _logError('Error checking update recommendation', e);
      return false;
    }
  }

  // Check if update is compulsory
  bool isUpdateCompulsory(String currentVersion) {
    try {
      return _compareVersions(
              currentVersion, _versionConfig.minimumSupportedVersion.version) <
          0;
    } catch (e) {
      _logError('Error checking update compulsion', e);
      return false;
    }
  }

  // Compare version strings
  @visibleForTesting
  int compareVersions(String v1, String v2) {
    return _compareVersions(v1, v2);
  }

  // Internal version comparison method
  int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < v1Parts.length && i < v2Parts.length; i++) {
      if (v1Parts[i] < v2Parts[i]) return -1;
      if (v1Parts[i] > v2Parts[i]) return 1;
    }

    return v1Parts.length.compareTo(v2Parts.length);
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

// Data models to represent version configuration
class VersionConfig {
  final VersionDetails latestVersion;
  final VersionDetails minimumSupportedVersion;

  VersionConfig({
    required this.latestVersion,
    required this.minimumSupportedVersion,
  });

  factory VersionConfig.fromJson(Map<String, dynamic> json) {
    return VersionConfig(
      latestVersion: VersionDetails.fromJson(json['latest_version'] ?? {}),
      minimumSupportedVersion:
          VersionDetails.fromJson(json['minimum_supported_version'] ?? {}),
    );
  }
}

class VersionDetails {
  final String version;
  final String summary;
  final List<String> detailedChangelog;

  VersionDetails({
    required this.version,
    required this.summary,
    required this.detailedChangelog,
  });

  factory VersionDetails.fromJson(Map<String, dynamic> json) {
    return VersionDetails(
      version: json['version'] ?? '1.0.0',
      summary: json['summary'] ?? 'No summary available',
      detailedChangelog: json['detailed_changelog'] != null
          ? List<String>.from(json['detailed_changelog'])
          : [],
    );
  }
}
