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
    // watch for earthquake changes
    final layer = ref.watch(earthquakeLayer);

    // state is calculated as function of context
    final state = layer.call(context);

    // get earthquake markers
    final markers = state.markers;

    return Stack(
      children: <Widget>[
        // `hybrid` background map with earthquakes markers
        GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: _initialPosition,
          markers: markers ?? {},

          // this is called "when the map is ready to be used"
          onMapCreated: _controller.complete,
        ),

        // a simple loading indicator over the map
        if (state.isLoading)
          const Positioned(
            top: 30,
            left: 30,
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
