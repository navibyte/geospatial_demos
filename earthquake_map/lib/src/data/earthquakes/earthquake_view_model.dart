// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial_demos

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'earthquake_presentation.dart';
import 'earthquake_query.dart';
import 'earthquake_repository.dart';

/// The view model containing items to be shown on a map view layer.
class MapLayerModel extends Equatable {
  /// When true, at least some portions of items for this layer still loading.
  final bool isLoading;

  /// Optional map markers currently available to be shown on a map layer.
  final Set<Marker>? markers;

  // NOTE: here could be other items like polylines and polygons to be shown too

  const MapLayerModel({this.isLoading = false, this.markers});

  @override
  List<Object?> get props => [isLoading, markers];
}

/// A provider for map layer with earthquakes.
///
/// The state provided is a function returning `MapLayerModel` with
/// `BuildContext` as a parameter (allowing markers shown on a map to be
/// customized by a state of UI too).
final earthquakeLayer =
    Provider.autoDispose<MapLayerModel Function(BuildContext)>((ref) {
  // watch the filter for query parameters (customizable in settings)
  final filter = ref.watch(earthquakeFilter);

  // get a list of Earthquake objects from the repository using the filter
  // (result is AsyncValue<List<Earthquake>> as repository is future provider)
  final earthquakes = ref.watch(earthquakeRepository(filter));

  // watch also a provider for formatting earthquake objects
  final formatter = ref.watch(earthquakeFormatter);

  // return a function that returns a layer model as a function of BuildContext
  return (context) {
    Set<Marker>? markers;
    if (earthquakes.hasValue) {
      // got earthquake data from a future provider, convert Earthquake
      // entity objects to Marker objects recognized by Google Maps.
      markers = <Marker>{};
      for (final eq in earthquakes.value!) {
        // get position of the point geometry as Geographic position
        final position = eq.epicenter;

        // use watched formatter to format title/subtitle texts
        final title = formatter.call(eq, kind: PresentationKind.title);
        final subtitle = formatter.call(eq, kind: PresentationKind.subtitle);

        // create a new Marker with id, position and an info window
        markers.add(
          Marker(
            markerId: MarkerId((eq.id ?? '?').toString()),
            position: LatLng(position.lat, position.lon),
            infoWindow: InfoWindow(
              title: title,
              snippet: subtitle,
            ),
          ),
        );
      }
    }
    return MapLayerModel(
      isLoading: earthquakes.isLoading,
      markers: markers,
    );
  };
});
