// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial_demos

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geodata/geojson_client.dart';

import 'earthquake_model.dart';
import 'earthquake_query.dart';

/// Returns an URL to the USGS earthquake service with the filter parameters
/// magnitude and past applied.
Uri _geoJsonUriToUsgs(EarthquakeQuery query) => Uri.parse(
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/'
      '${query.magnitude.code}_${query.past.code}.geojson',
    );

/// A future provider to access feature items from the USGS earthquake service.
///
/// The USGS earthquake service used in this sample provides GeoJSON data with
/// earthquakes as features, and filtered by [EarthquakeQuery].
///
/// This implementation uses the HTTP Client for a GeoJSON data source provided
/// by the 'package:geodata/geojson_client.dart' library.
///
/// This (Riverpod) future provider is setup with "autoDispose" mode and it
/// caches data for 15 minutes.
///
/// The returned Future wraps a `FeatureItems` object that contains
/// `FeatureCollection` with `Feature` objects representing geospatial features
/// (with id, geometry and properties as members).
final earthquakeRepository =
    FutureProvider.autoDispose.family<List<Earthquake>, EarthquakeQuery>(
  (ref, query) async {
    // create a feature source for the USGS earthquake service
    final location = _geoJsonUriToUsgs(query);
    final source = geoJsonHttpClient(
      location: _geoJsonUriToUsgs(query),
    );

    // ignore: avoid_print
    print('fetching earthquakes: $location');

    // fetch all features items from the source - returned as a future
    final items = await source.itemsAll();

    return items.collection.features
        .map<Earthquake>(Earthquake.fromUSGS)
        .toList(growable: false);
  },

  // cache data for 15 minuts
  cacheTime: const Duration(minutes: 15),
);
