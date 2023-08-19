// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial_demos

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geobase/coordinates.dart';
import 'package:intl/intl.dart';

import '/src/preferences/units.dart';
import '/src/utils/strings.dart';

import 'earthquake_model.dart';

/// An enum specifying the type of presentation.
enum PresentationKind { title, subtitle }

/// A formatter function to print [earthquake] as text.
///
/// Set [kind] to specify the type of presentation.
typedef FormatEarthquake = String Function(
  Earthquake earthquake, {
  required PresentationKind kind,
  UnitSystem? units,
});

/// A provider for a formatter function.
final earthquakeFormatter = Provider<FormatEarthquake>((ref) {
  // watch the current preference of an user for units (metric or imperial)
  final units = ref.watch(unitsPreference);

  // return a formatter function parametrized by the units preference
  return _formatEarthquakeDefault(units: units);
});

/// Returns a function that formats an earthquake as text.
///
/// With [units] set to `metric` the result is like:
/// * title: "M 5.1 (Sep 5 at 4:49 PM)"
/// * subtitle: "Near northern Mid-Atlantic Ridge. Depth 10.0 km."
///
/// With [units] set to `imperial` the result is like:
/// * title: "M 5.1 (Sep 5 at 4:49 PM)"
/// * subtitle: "Near northern Mid-Atlantic Ridge. Depth 6.2 mi."
FormatEarthquake _formatEarthquakeDefault({
  UnitSystem units = UnitSystem.metric,
}) {
  // store in named variable to ensure not hidden on actual function
  final defaultUnits = units;

  // return formatter function
  return (eq, {required kind, units}) {
    final buf = StringBuffer();
    switch (kind) {
      case PresentationKind.title:
        _writeMagnitude(buf, eq.magnitude);
        buf.write(' (');
        buf.write(_formatLocalDateFromUTC(eq.time));
        buf.write(')');
      case PresentationKind.subtitle:
        final place = eq.place;
        if (place != null && place.isNotEmpty) {
          if (!isDigit(place, 0)) {
            buf.write('Near ');
          }
          _writeEarthquakePlaceText(
            buf,
            place,
            units: units ?? defaultUnits,
          );
        } else {
          // format geographic coordinates using DMS (degrees-minutes-seconds)
          const dm = Dms.narrowSpace(type: DmsType.degMin);
          buf
            ..write('Near latitude ')
            ..write(eq.epicenter.latDms(dm))
            ..write('° longitude ')
            ..write(eq.epicenter.lonDms(dm))
            ..write('°');
        }
        final depth = eq.depthKM;
        if (depth != null) {
          buf.write('. Depth ');
          _writeDepth(buf, depth, units: units ?? defaultUnits);
          buf.write('.');
        }
    }

    return buf.toString();
  };
}

/// Formats earthquake magnitude like "M 5.3".
void _writeMagnitude(StringSink buf, num magn) => buf
  ..write('M ')
  ..write(magn.toStringAsFixed(1));

/// Formats earthquake depth like "2.1 km".
void _writeDepth(StringSink buf, num depth, {required UnitSystem units}) {
  if (units == UnitSystem.imperial) {
    buf
      ..write((depth / 1.609).toStringAsFixed(1))
      ..write(' mi');
  } else {
    buf
      ..write(depth.toStringAsFixed(1))
      ..write(' km');
  }
}

/// Format earthquake (by USGS) place [text] according to [units].
void _writeEarthquakePlaceText(
  StringSink buf,
  String text, {
  required UnitSystem units,
}) {
  if (units == UnitSystem.imperial) {
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

  final isThisYear = local.year == now.year;
  final isToday =
      isThisYear && local.month == now.month && local.day == now.day;

  if (isToday) {
    final f = DateFormat.jm();
    return 'Today ${f.format(local)}';
  }

  final f = DateFormat(isThisYear ? "MMM d 'at'" : "yyyy MMM d 'at'").add_jm();
  return f.format(local);
}
