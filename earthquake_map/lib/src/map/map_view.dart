// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial_demos

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/src/data/earthquakes/earthquake_view_model.dart';

/// The map view showing Google Maps and earthquakes as markers. Data is
/// retrieved from the USGS service (GeoJSON).
class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  final Completer<GoogleMapController> _controller = Completer();

  static const _initialPosition = CameraPosition(
    target: LatLng(22.0, -91.0),
    zoom: 4.0,
  );

  @override
  Widget build(BuildContext context) {
    // watch for earthquake markers (as a factory function) shown on the map
    // (the map is updated when markers are changed)
    final markers = ref.watch(earthquakeMarkers);

    return GoogleMap(
      // configure with the `hybrid` background map and an initial position
      mapType: MapType.hybrid,
      initialCameraPosition: _initialPosition,

      // this is called "when the map is ready to be used"
      onMapCreated: _controller.complete,

      // get markers from a factory function taking the context as an argument
      markers: markers(context),
    );
  }
}
