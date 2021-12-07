import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core_web/firebase_core_web.dart';

import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/trace.dart';
import 'src/interop/performance.dart' as performance_interop;

/// Web implementation for [FirebasePerformancePlatform]
class FirebasePerformanceWeb extends FirebasePerformancePlatform {
  /// Stub initializer to allow the [registerWith] to create an instance without
  /// registering the web delegates or listeners.
  FirebasePerformanceWeb._()
      : _webPerformance = null,
        super(appInstance: null);

  /// Instance of Performance from the web plugin.
  performance_interop.Performance? _webPerformance;

  /// Lazily initialize [_webRemoteConfig] on first method call
  performance_interop.Performance get _delegate {
    return _webPerformance ??= performance_interop.getPerformanceInstance();
  }

  /// Builds an instance of [FirebasePerformanceWeb]
  /// Performance web currently only supports the default app instance
  FirebasePerformanceWeb() : super();

  /// Initializes a stub instance to allow the class to be registered.
  static FirebasePerformanceWeb get instance {
    return FirebasePerformanceWeb._();
  }

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseCoreWeb.registerService('performance');
    FirebasePerformancePlatform.instance = FirebasePerformanceWeb.instance;
  }

  @override
  FirebasePerformancePlatform delegateFor({required FirebaseApp app}) {
    return FirebasePerformanceWeb();
  }

  @visibleForTesting
  // ignore: avoid_setters_without_getters
  set mockDelegate(performance_interop.Performance performance) {
    _webPerformance = performance;
  }

  @override
  Future<bool> isPerformanceCollectionEnabled() async {
    return _delegate.dataCollectionEnabled;
  }

  @override
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    _delegate.setPerformanceCollection(enabled);
  }

  @override
  TracePlatform newTrace(String name) {
    return TraceWeb(_delegate.trace(name));
  }

  @override
  HttpMetricPlatform newHttpMetric(String url, HttpMethod httpMethod) {
    throw PlatformException(
      code: 'non-existent',
      message:
          "Performance Web does not currently support 'HttpMetric' (custom network tracing).",
    );
  }
}
