// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial_demos

import 'package:equatable/equatable.dart';
import 'package:geobase/geobase.dart' show Feature, Geographic, Point;

/// The producer for earthquake data.
enum EarthquakeProducer {
  /// The United States Geological Survey
  usgs(
    supportsMagnitudeFilter: true,
    supportsPastFilter: true,
  ),

  /// The British Geological Survey
  bgs(
    supportsMagnitudeFilter: false,
    supportsPastFilter: false,
  );

  const EarthquakeProducer({
    required this.supportsMagnitudeFilter,
    required this.supportsPastFilter,
  });

  String get title => name.toUpperCase();

  final bool supportsMagnitudeFilter;
  final bool supportsPastFilter;
}

/// An earthquake entity as represented by a client-side repository.
///
/// Note: this class intentionally does not represent all properties available
/// for earthquake entities on data sources, only those needed by UI client.
///
/// This model class extends `Equatable` that implements `==` and `hashCode`.
class Earthquake extends Equatable {
  /// The producer for earthquake data.
  final EarthquakeProducer producer;

  /// An optional id for an earthquake event.
  final Object? id;

  /// The observed time when an earthquake event occurred.
  final DateTime time;

  /// The observed magnitude for an earthquake event.
  ///
  /// Typical value range is [-1.0, 10.0] according to USGS.
  final double magnitude;

  /// The geographic position (longitude, latitude) with an optional elevation
  /// for an earthquake event in the WGS84 reference frame.
  ///
  /// When available, elevations (in meters) are negative values for
  /// earthquakes.
  final Geographic epicenter;

  /// An optional depth (in kilometers) where the earthquake begins to rupture.
  ///
  /// Depths (in kilometers) are positive values and in the range [0, 1000].
  final double? depthKM;

  /// An optional place name or other desciption for a place near an earthquke
  /// event.
  final String? place;

  /// An earthquake entity as represented by a client-side repository.
  const Earthquake({
    this.id,
    required this.producer,
    required this.time,
    required this.magnitude,
    required this.epicenter,
    this.depthKM,
    this.place,
  });

  /// Creates an earthquake entity from GeoJSON [Feature] objected produced by
  /// USGS.
  factory Earthquake.fromUSGS(Feature eq) {
    final point = eq.geometry;
    if (point is Point) {
      // USGS writes position to feature's geometry field as a point geometry
      // with a position containg longitude, latitude, depth coordinates
      final position = point.position.asGeographic;

      // get depth ("km below sea") from a position produced by USGS
      final depth = position.elev;

      // positions have depth converted to elevation ("meters above sea")
      final positionWithElev = position.copyWith(z: -position.elev * 1000.0);

      // UTC time from milliseconds
      final time = DateTime.fromMillisecondsSinceEpoch(
        eq.properties['time'] as int,
        isUtc: true,
      );

      // create an entity
      return Earthquake(
        id: eq.id,
        producer: EarthquakeProducer.usgs,
        time: time,
        magnitude: (eq.properties['mag'] as num).toDouble(),
        epicenter: positionWithElev,
        depthKM: depth,
        place: eq.properties['place']?.toString(),
      );
    } else {
      throw const FormatException('earthquake expects point geometry');
    }
  }

  /// Creates an earthquake entity from GeoJSON [Feature] objected produced by
  /// BGS.
  factory Earthquake.fromBGS(Feature eq, {String? place}) {
    final point = eq.geometry;
    if (point is Point) {
      // BGS writes position to feature's geometry field as a point geometry
      // with a position containg longitude and latitude coordinates
      final position = point.position.asGeographic;

      // get depth ("km below sea") from a position produced by BGS
      // (BGS may has depth data also null)
      final depth = (eq.properties['depth'] as num?)?.toDouble();

      // positions have depth converted to elevation ("meters above sea")
      // (for those earthquakes that contain that depth)
      final positionMaybeWithElev = depth != null
          ? position.copyWith(z: -position.elev * 1000.0)
          : position;

      // UTC time from milliseconds
      final time = DateTime.parse(
        eq.properties['datetime'].toString(),
      );

      // create an entity
      return Earthquake(
        id: eq.id,
        producer: EarthquakeProducer.bgs,
        time: time,
        magnitude: (eq.properties['ml'] as num).toDouble(),
        epicenter: positionMaybeWithElev,
        depthKM: depth,
        place: place,
      );
    } else {
      throw const FormatException('earthquake expects point geometry');
    }
  }

  @override
  List<Object?> get props =>
      [id, producer, time, magnitude, epicenter, depthKM, place];
}
