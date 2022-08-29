// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial_demos

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geobase/vector_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'earthquake_filter.dart';
import 'earthquake_presentation.dart';
import 'earthquake_source.dart';

/// A provider providing a view model with a set of earthquake marker objects.
/// 
/// The state provided is a function returning `Set<Marker>` with `BuildContext`
/// as a parameter (allowing markers shown on a map to be customized by a state
/// of UI too).
final earthquakeMarkers =
    Provider.autoDispose<Set<Marker> Function(BuildContext)>((ref) {
  // watch the filter for query parameters (customizable in settings)
  final filter = ref.watch(earthquakeFilter);

  // get earthquakes (as feature items) from the feature source using the filter
  final result = ref.watch(earthquakeSource(filter));

  // watch also a provider for formatting earthquake objects
  final formatter = ref.watch(earthquakeFormatter);

  // return a function that returns `Set<Marker> as a function of `BuildContext`
  return (context) => result.when(
        loading: () => {
          // show empty markers when loading
        },
        error: (err, stack) => {
          // show empty markers when error
          // (todo: dispay an error message to an user)
        },
        data: (earthquakes) {
          // got earthquake data from a future provider, convert GeoJSON
          // Feature objects to Marker object recognized by Google Maps.
          final markers = <Marker>{};
          for (final eq in earthquakes.collection.features) {
            //print('${eq.id} ${eq.properties['place']}');
            final point = eq.geometry;
            if (point is Point) {
              // get position of the point geometry as Geographic position
              final position = point.position.asGeographic;
  
              // format title/subtitle texts and create a new Marker
              final title = formatter.call(eq, short: true);
              final subtitle = formatter.call(eq);
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
          return markers;
        },
      );
});
