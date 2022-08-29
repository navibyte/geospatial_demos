// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial_demos

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geobase/vector_data.dart';
import 'package:intl/intl.dart';

import '/src/preferences/units.dart';
import '/src/utils/strings.dart';

/// A formatter function to print the [earthquake] feature as text.
///
/// Set [short] to true when a short text represention is neeed. Otherwise text
/// representation can be a detailed description.
typedef FormatEarthquake = String Function(
  Feature earthquake, {
  bool? short,
  UnitSystem? units,
});

/// A provider for a formatter function.
final earthquakeFormatter = Provider<FormatEarthquake>((ref) {
  // watch the current preference of an user for units (metric or imperial)
  final units = ref.watch(unitsPreference);

  // return a formatter function parametrized by the units preference
  return _formatEarthquakeDefault(units: units);
});

/// Formats an earthquake as text.
///
/// With [units] set to `metric` the result is like:
/// * short: "M 5.2 Aug 23 at 7:29 PM"
/// * not short: "M 5.2 located 149 km SE of Pangai, Tonga at Aug 23 at 7:29 PM"
///
/// With [units] set to `imperial` the result is like:
/// * short: "M 5.2 Aug 23 at 7:29 PM"
/// * not short: "M 5.2 located 93 mi SE of Pangai, Tonga at Aug 23 at 7:29 PM"
FormatEarthquake _formatEarthquakeDefault({
  UnitSystem units = UnitSystem.metric,
}) {
  // store in named variable to ensure not hidden on actual function
  final defaultUnits = units;

  // return formatter function
  return (eq, {short, units}) {
    final buf = StringBuffer();
    _writeMagnitude(buf, eq.properties['mag'] as num);
    final long = !(short ?? false);
    if (long) {
      final place = eq.properties['place'] as String;
      if (place.isNotEmpty) {
        buf.write(isDigit(place, 0) ? ' located ' : ' near ');
        _writeEarthquakePlaceText(
          buf,
          place,
          units: units ?? defaultUnits,
        );
      }
      buf.write(' at ');
    } else {
      buf.write(' ');
    }

    final time = DateTime.fromMillisecondsSinceEpoch(
      eq.properties['time'] as int,
      isUtc: true,
    );
    buf.write(_formatLocalDateFromUTC(time));
    return buf.toString();
  };
}

/// Formats earthquake magnitude like "M 5.3".
void _writeMagnitude(StringSink buf, num magn) => buf
  ..write('M ')
  ..write(magn.toStringAsFixed(1));

/// Format earthquake (by USGS) place [text] according to [units].
void _writeEarthquakePlaceText(
  StringSink buf,
  String text, {
  UnitSystem? units,
}) {
  if ((units ?? UnitSystem.metric) == UnitSystem.imperial) {
    final i = text.indexOf('km ');
    if (i > 0 && i + 3 < text.length) {
      // transform "16km SE of Some Place"
      //    => "10 mi SE of Some Place" if imperial
      final str = double.tryParse(text.substring(0, i));
      final miles = str != null ? str / 1.609 : 0.0;
      buf
        ..write(miles.toStringAsFixed(0))
        ..write(' mi ')
        ..write(text.substring(i + 3));
      return;
    }
  }
  buf.write(text);
}

/// Formats [timeUTC] in a local tome system.
String _formatLocalDateFromUTC(DateTime timeUTC) {
  // see https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html

  final local = timeUTC.toLocal();
  final now = DateTime.now();

  final isToday = local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  if (isToday) {
    final f = DateFormat.jm();
    return 'Today ${f.format(local)}';
  }

  final f = DateFormat("MMM d 'at'").add_jm();
  return f.format(local);
}
