import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/interceptors/get_modifiers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../entity/entity.dart';
import '../extensions/extensions.dart';
import '../lang/lang.dart';

import '../services/dialog/dialog_service.dart';
import '../services/snackbar/snackbar_service.dart';
export '../services/snackbar/snackbar_config.dart';

import 'upgrader/upgrader.dart';
import 'http/getxhttp.dart';
export 'http/getxhttp.dart';

part 'app_service.dart';
part 'app_settings.dart';
part 'app_getxapi.dart';
part 'app_credential.dart';

const String kSystemPath = 'assets/system';
const String kImagesPath = 'assets/images';
const String kSettingsFilePath = '$kSystemPath/settings.json';
const String kSettingsFilePathDebug = '$kSystemPath/settings.debug.json';
const String kSettingsFilePathStaging = '$kSystemPath/settings.staging.json';

final kStagingMode = _envVIQCoreBuild.split(';').contains('staging');
final kHuaweiAppGallery = _envVIQCoreBuild.split(';').contains('huawei');
const _envVIQCoreBuild = String.fromEnvironment("VIQCORE_BUILD");

// ignore: non_constant_identifier_names
AppService get App => Get.find();

class CoreMaterialApp extends StatelessWidget {
  CoreMaterialApp({
    Key? key,
    //this.designSize = ScreenUtil.defaultSize,
    // Widget home,
    // Widget login,
    //Map<String, WidgetBuilder> routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    //this.onGenerateRoute,
    //this.onGenerateInitialRoutes,
    //this.onUnknownRoute,
    //this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    //this.translationsKeys,
    Map<String, Map<String, String>>? translations,
    //String title = '',
    //this.onGenerateTitle,
    //Color color,
    // this.customTransition,
    this.onInit,
    this.onDispose,
    this.theme,
    this.darkTheme,
    //this.colorScheme = FlexScheme.blue,
    this.themeMode = ThemeMode.system,
    // this.locale,
    // this.localizationsDelegates,
    // this.localeListResolutionCallback,
    // this.localeResolutionCallback,
    // this.supportedLocales = const <Locale>[Locale('en', 'US')],
    // this.debugShowMaterialGrid = false,
    // this.showPerformanceOverlay = false,
    // this.checkerboardRasterCacheImages = false,
    // this.checkerboardOffscreenLayers = false,
    // this.showSemanticsDebugger = false,
    // this.debugShowCheckedModeBanner = false,
    // this.shortcuts,
    // this.smartManagement = SmartManagement.full,
    // this.initialBinding,
    // this.unknownRoute,
    this.routingCallback,
    // this.defaultTransition,
    // // this.actions,
    required this.getPages,
    // this.opaqueRoute,
    // this.enableLog,
    // this.popGesture,
    // this.transitionDuration,
    // this.defaultGlobalState,
    this.unknownRoute,
  })  : routeInformationProvider = null,
        routeInformationParser = null,
        routerDelegate = null,
        backButtonDispatcher = null,
        translationsKeys = appendTranslations(translations),
        super(key: key);

  //final Key? key;
  final Map<String, Map<String, String>>? translationsKeys;
  final TransitionBuilder? builder;
  final VoidCallback? onInit;
  final VoidCallback? onDispose;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;
  final void Function(Routing?)? routingCallback;
  final List<GetPage>? getPages;
  final GetPage? unknownRoute;
  //final FlexScheme colorScheme;

  // Navigator 1.0
  final String? initialRoute;
  // navigatorObservers = null,
  // navigatorKey = null,
  // onGenerateRoute = null,
  // home = null,
  // onGenerateInitialRoutes = null,
  // onUnknownRoute = null,
  // routes = null,
  // initialRoute = null

  // Navigator 2.0
  final RouteInformationProvider? routeInformationProvider;
  final RouteInformationParser<Object>? routeInformationParser;
  final RouterDelegate<Object>? routerDelegate;
  final BackButtonDispatcher? backButtonDispatcher;

  //Screen Utils
  // final Size designSize;

  CoreMaterialApp.router({
    Key? key,
    this.routeInformationProvider,
    required RouteInformationParser<Object> this.routeInformationParser,
    required RouterDelegate<Object> this.routerDelegate,
    this.backButtonDispatcher,
    this.builder,
    Map<String, Map<String, String>>? translations,
    //this.title = '',
    //this.onGenerateTitle,
    //this.color,
    this.theme,
    this.darkTheme,
    //this.colorScheme = FlexScheme.blue,
    //this.highContrastTheme,
    //this.highContrastDarkTheme,
    this.themeMode = ThemeMode.system,
    //this.locale,
    //this.localizationsDelegates,
    //this.localeListResolutionCallback,
    //this.localeResolutionCallback,
    //this.supportedLocales = const <Locale>[Locale('en', 'US')],
    //this.debugShowMaterialGrid = false,
    //this.showPerformanceOverlay = false,
    //this.checkerboardRasterCacheImages = false,
    //this.checkerboardOffscreenLayers = false,
    //this.showSemanticsDebugger = false,
    //this.debugShowCheckedModeBanner = true,
    //this.shortcuts,
    //this.actions,
    //this.customTransition,
    //this.translationsKeys,
    //this.translations,
    //this.textDirection,
    //this.fallbackLocale,
    this.routingCallback,
    //this.defaultTransition,
    //this.opaqueRoute,
    this.onInit,
    //this.onReady,
    this.onDispose,
    //this.enableLog,
    //this.logWriterCallback,
    //this.popGesture,
    //this.smartManagement = SmartManagement.full,
    //this.initialBinding,
    //this.transitionDuration,
    //this.defaultGlobalState,
    this.getPages,
    this.unknownRoute,
  })  : //navigatorObservers = null,
        //navigatorKey = null,
        //onGenerateRoute = null,
        //home = null,
        //onGenerateInitialRoutes = null,
        //onUnknownRoute = null,
        //routes = null,
        initialRoute = null,
        translationsKeys = appendTranslations(translations),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return routerDelegate != null
        ? GetMaterialApp.router(
            routeInformationParser: routeInformationParser!,
            routerDelegate: routerDelegate!,
            key: key,
            //supportedLocales: App.language.locales,
            locale: Get.deviceLocale,
            translationsKeys: translationsKeys,
            debugShowCheckedModeBanner: false,
            onInit: onInit,
            onDispose: onDispose,
            theme: theme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            routingCallback: routingCallback,
            getPages: getPages,
            unknownRoute: unknownRoute,
            builder: (BuildContext context, Widget? child) {
              /// make sure that loading can be displayed in front of all other widgets
              return UpgradeAlert(
                child: FlutterEasyLoading(
                    child: builder?.call(context, child) ?? child),
              );
            },
          )
        : GetMaterialApp(
            initialRoute: initialRoute,
            key: key,
            //supportedLocales: App.language.locales,
            locale: Get.deviceLocale,
            translationsKeys: translationsKeys,
            debugShowCheckedModeBanner: false,
            onInit: onInit,
            onDispose: onDispose,
            theme: theme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            routingCallback: routingCallback,
            getPages: getPages,
            unknownRoute: unknownRoute ??
                GetPage(
                  name: '/404',
                  page: () => Scaffold(
                    body: Text('not found'),
                  ),
                ),
            builder: (BuildContext context, Widget? child) {
              /// make sure that loading can be displayed in front of all other widgets
              return UpgradeAlert(
                child: FlutterEasyLoading(
                    child: builder?.call(context, child) ?? child),
              );
            },
          );
  }
}
