// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial_demos

import 'package:equatable/equatable.dart';

/// A minimum earthquake magnitude used by an earthquake filter.
enum Magnitude {
  significant,
  m45plus,
  m25plus,
  m10plus,
  all;

  /// An identifier used by the USGS service (not equals with the enum [name]).
  String get code {
    switch (this) {
      case Magnitude.significant:
        return 'significant';
      case Magnitude.m45plus:
        return '4.5';
      case Magnitude.m25plus:
        return '2.5';
      case Magnitude.m10plus:
        return '1.0';
      case Magnitude.all:
        return 'all';
    }
  }
}

/// A time period ("past from now") used by an earthquake filter.
enum Past {
  hour,
  day,
  week,
  month;

  /// An identifier used by the USGS service (equals with the enum [name]).
  String get code => name;
}

/// A query to filter earthquakes when requesting data from a data source.
///
/// This model class extends `Equatable` that implements `==` and `hashCode`.
class EarthquakeQuery extends Equatable {
  /// A minimum earthquake magnitude.
  final Magnitude magnitude;

  /// A time period ("past from now").
  final Past past;

  /// A query to filter earthquakes when requesting data from a data source.
  const EarthquakeQuery({required this.magnitude, required this.past});

  /// Copies this query as a new instance with optional [magnitude] and [past].
  EarthquakeQuery copyWith({Magnitude? magnitude, Past? past}) =>
      EarthquakeQuery(
        magnitude: magnitude ?? this.magnitude,
        past: past ?? this.past,
      );

  /// Returns an URL to the USGS earthquake service with the filter parameters 
  /// [magnitude] and [past] applied.
  Uri toUri() => Uri.parse(
        'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/'
        '${magnitude.code}_${past.code}.geojson',
      );

  @override
  List<Object?> get props => [magnitude, past];
}
