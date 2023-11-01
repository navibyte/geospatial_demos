// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial_demos

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/src/data/earthquakes/earthquake_model.dart';
import '/src/data/earthquakes/earthquake_query.dart';
import '/src/preferences/units.dart';

/// The settings view shows a selection for units and filter parameters for
/// querying earthquakes.
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch for parameters that can be customized by the settings view
    final filter = ref.watch(earthquakeFilter);
    final units = ref.watch(unitsPreference);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          // each item on the settings views as a card with a list tile
          // containing an icon, a title and a dropdown button for selections
          children: [
            // The `units` selection.
            Card(
              child: ListTile(
                leading: const Icon(Icons.pin),
                title: const Text('Units'),
                subtitle: DropdownButton<UnitSystem>(
                  value: units,
                  // `unitsPreference` is `StateProvider`, just update the value
                  onChanged: (value) =>
                      ref.read(unitsPreference.notifier).state = value!,
                  // get selectable items from the `UnitSystem` enum
                  items: [
                    for (final units in UnitSystem.values)
                      DropdownMenuItem(
                        value: units,
                        child: Text(units.name),
                      ),
                  ],
                ),
              ),
            ),

            // The "earthquake data producer" or "data source" selection.
            Card(
              child: ListTile(
                leading: const Icon(Icons.api),
                title: const Text('Earthquake data source'),
                subtitle: DropdownButton<EarthquakeProducer>(
                  value: filter.producer,
                  // `earthquakeFilter` is `StateNotifierProvider`, use a
                  // dedicated method on it's notifier to update the value
                  onChanged: (value) => ref
                      .read(earthquakeFilter.notifier)
                      .updateProducer(value!),
                  // get selectable items from the `EarthquakeProducer` enum
                  items: [
                    for (final producer in EarthquakeProducer.values)
                      DropdownMenuItem(
                        value: producer,
                        child: Text(producer.title),
                      ),
                  ],
                ),
              ),
            ),

            // The minimum `magnitude` selection (supported by some producers).
            if (filter.producer.supportsMagnitudeFilter)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.crisis_alert),
                  title: const Text('Minimum magnitude'),
                  subtitle: DropdownButton<Magnitude>(
                    value: filter.magnitude,
                    // `earthquakeFilter` is `StateNotifierProvider`, use a
                    // dedicated method on it's notifier to update the value
                    onChanged: (value) => ref
                        .read(earthquakeFilter.notifier)
                        .updateMagnitude(value!),
                    // get selectable items from the `Magnitude` enum
                    // (here limitied to 3 first: significant, m45plus, m25plus)
                    items: [
                      for (final magnitude in Magnitude.values.take(3))
                        DropdownMenuItem(
                          value: magnitude,
                          child: Text(magnitude.code),
                        ),
                    ],
                  ),
                ),
              ),

            // The "time period" selection (supported by some producers).
            if (filter.producer.supportsPastFilter)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.timelapse),
                  title: const Text('Time period'),
                  subtitle: DropdownButton<Past>(
                    value: filter.past,
                    // `earthquakeFilter` is `StateNotifierProvider`, use a
                    // dedicated method on it's notifier to update the value
                    onChanged: (value) =>
                        ref.read(earthquakeFilter.notifier).updatePast(value!),
                    // get selectable items from the `Past` enum
                    items: [
                      for (final past in Past.values)
                        DropdownMenuItem(
                          value: past,
                          child: Text(past.code),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
