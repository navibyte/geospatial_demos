// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial_demos

/*
Instructions to setup Google Maps for Flutter
https://pub.dev/packages/google_maps_flutter

Set the minSdkVersion to SDK 20
- android/app/build.gradle
    - android -> defaultConfig -> minSdkVersion 20
- android/app/src/main/AndroidManifest.xml
    - manifest -> application -> 
        <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="<YOUR-APIKEY>"/>  
- ios/Runner/AppDelegate.swift
    - import GoogleMaps
    - AppDelegate -> application
        GMSServices.provideAPIKey("<YOUR-APIKEY>")
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/src/map/map_view.dart';
import '/src/settings/settings_view.dart';

void main() {
  runApp(const EarthquakeMapApp());
}

/// The app widget showing the main view with a map.
class EarthquakeMapApp extends StatelessWidget {
  const EarthquakeMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// The `ProviderScope` is required by Riverpod for state management.
    return ProviderScope(
      child: MaterialApp(
        title: 'Earthquake Map',
        theme: ThemeData(),
        home: const AppView(),
      ),
    );
  }
}

/// The app view with simple appbar, a button on the appbar to show settings, 
/// and a map view showing world map and earthquakes as markers.
class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    // The settings view shows a selection for units and filter
                    // parameters for querying earthquakes.
                    return const SettingsView();
                  },
                ),
              );
            },
          ),
        ],
      ),
      // The map view showing Google Maps and earthquakes as markers. Data is 
      // retrieved from the USGS service (GeoJSON).
      body: const MapView(),
    );
  }
}
