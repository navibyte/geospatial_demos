// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial_demos

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// An enum for common unit system types.
enum UnitSystem { metric, imperial }

/// A state proviver for a preference of the unit system.
final unitsPreference = StateProvider<UnitSystem>(
  // `metric` by default
  (ref) => UnitSystem.metric,
);
