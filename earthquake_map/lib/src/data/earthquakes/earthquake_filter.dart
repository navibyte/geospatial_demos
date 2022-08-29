// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial_demos

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'earthquake_model.dart';

/// The state notifier provider for an query used to filter earthquakes.
/// 
/// This is used `earthquakeMarkers` to get a filter for earthquakes. Filter
/// parameters can be customized on the settings view.
final earthquakeFilter =
    StateNotifierProvider<EarthquakeFilterNotifier, EarthquakeQuery>(
  (ref) => EarthquakeFilterNotifier(),
);

/// The state notifier class for an query used to filter earthquakes.
class EarthquakeFilterNotifier extends StateNotifier<EarthquakeQuery> {
  EarthquakeFilterNotifier()
      : super(
          // The default query filters earthquakes with a magnitude above 4.5
          // for the past week.
          const EarthquakeQuery(
            magnitude: Magnitude.m45plus,
            past: Past.week,
          ),
        );

  /// Updates the minimum [magnitude] selection on this filter.
  void updateMagnitude(Magnitude magnitude) {
    if (magnitude != state.magnitude) {
      state = state.copyWith(magnitude: magnitude);
    }
  }

  /// Updates the time period or [past] selection on this filter.
  void updatePast(Past past) {
    if (past != state.past) {
      state = state.copyWith(past: past);
    }
  }
}
