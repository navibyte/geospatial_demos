// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial_demos

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geodata/geodata.dart' show GeoJSONFeatures, OGCAPIFeatures;

import 'earthquake_model.dart';
import 'earthquake_query.dart';

/// Returns an URL to the USGS earthquake service with the filter parameters
/// magnitude and past applied.
Uri _usgsEarthquakesUri(EarthquakeQuery query) => Uri.parse(
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/'
      '${query.magnitude.code}_${query.past.code}.geojson',
    );

// URL and collection name for the BGS earthquake service.
final _bgsEarthquakesUri = Uri.parse('https://ogcapi.bgs.ac.uk/');
const _bgsEarthquakesCollection = 'recentearthquakes';

/// A future provider to get earthquakes from USGS or BGS earthquake services.
///
/// This (Riverpod) future provider is setup with "autoDispose" mode and it
/// caches data for 15 minutes.
///
/// The returned Future wraps a list of `Earthquake` objects.
final earthquakeRepository =
    FutureProvider.autoDispose.family<List<Earthquake>, EarthquakeQuery>(
  (ref, query) async {
    // cache data for 15 minutes, NOTE: remove this as soon as cacheTime is back
    ref.cacheFor(const Duration(minutes: 15));

    switch (query.producer) {
      case EarthquakeProducer.usgs:
        return _fetchUsgsEarthquakes(query);
      case EarthquakeProducer.bgs:
        return _fetchBgsEarthquakes(query);
    }
  },

  // cache data for 15 minuts
  // cacheTime: const Duration(minutes: 15),
);

/// Fetches earthquakes as GeoJSON feature collection from the USGS earthquake
/// service (a RESTful API with custom API parameters, results are GeoJSON).
///
/// This implementation uses the HTTP Client for a GeoJSON data source provided
/// by the 'package:geodata/geojson_client.dart' library.
Future<List<Earthquake>> _fetchUsgsEarthquakes(EarthquakeQuery query) async {
  // create a feature source for the USGS earthquake service
  final location = _usgsEarthquakesUri(query);
  final source = GeoJSONFeatures.http(location: location);

  // ignore: avoid_print
  print('fetching earthquakes (custom GeoJSON service by USGS): $location');

  // fetch all features items from the source
  final items = await source.itemsAll();

  // map feature instances to Earthquake instances
  return items.collection.features
      .map(Earthquake.fromUSGS)
      .toList(growable: false);
}

/// Fetches earthquakes as GeoJSON feature collection from the BGS earthquake
/// service (the API is standardized OGC API Features, results are GeoJSON).
///
/// This implementation uses the OGC API Features Client provided
/// by the 'package:geodata/ogcapi_features_client.dart' library.
Future<List<Earthquake>> _fetchBgsEarthquakes(EarthquakeQuery query) async {
  // create an OGC API Features client for the BGS earthquake service
  final location = _bgsEarthquakesUri;
  final client = OGCAPIFeatures.http(endpoint: location);

  // check conformance
  final conformance = await client.conformance();
  if (!conformance.conformsToFeaturesCore(geoJSON: true)) {
    throw const FormatException('Not supporting OGC API Features / GeoJSON.');
  }

  // ignore: avoid_print
  print('fetching earthquakes (OGC API Features service by BGS): $location');

  // for OGC API Features service, get first a feature source for a collection
  final source = await client.collection(_bgsEarthquakesCollection);

  // then fetch all features items from the source
  final items = await source.itemsAll();

  // map feature instances to Earthquake instances
  return items.collection.features
      .map(Earthquake.fromBGS)
      .toList(growable: false);
}

// See https://github.com/rrousselGit/riverpod/issues/1664
// ignore: strict_raw_type
extension _AutoDisposeRefHack on AutoDisposeRef {
  // When invoked keeps your provider alive for [duration]
  void cacheFor(Duration duration) {
    final link = keepAlive();
    final timer = Timer(duration, link.close);
    onDispose(timer.cancel);
  }
}
