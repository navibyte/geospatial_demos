# Earthquake map

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

This a demo [Flutter](https://flutter.dev/) app coded in
[Dart](https://dart.dev/) for showing earthquakes on a map.

The project is a part of the
[geospatial_demos](https://github.com/navibyte/geospatial_demos) that
is a companion demo code repository for the 
[Geospatial tools for Dart](https://github.com/navibyte/geospatial).

Edits for this sample app:
* 📅 2022-08-29 (the first version)
* ✍️ 2022-12-03 (last updated)

## :sparkles: Introduction

<img src="assets/screenshots/map_view.jpg" align="right" width="40%" title="Earthquake Map - Map View" />

Shows earthquakes on a basic map view with data fetched from the 
[GeoJSON feed](https://earthquake.usgs.gov/earthquakes/feed/)
provided by USGS (the United States Geological Survey) and 
[OGC API Feature service](https://ogcapi.bgs.ac.uk/collections/recentearthquakes?f=html)
provided by BGS (the British Geological Survey).

Coding topics:
* **State management** (settings, query filters, repositories and fecthing data from APIs, presentation formatters, map view markers).
* Using **API clients to fetch geospatial data** ([GeoJSON](https://geojson.org/)) from a custom REST service or a standardized [OGC API Features](https://ogcapi.ogc.org/features/) service.
* Visualizing earthquakes (that are geospatial feature entities with point geometries) as **map markers on a map view**.

Notes:
* The UI of this sample app is very basic. The app focuses on a clean demonstration of the topics mentioned above.
* To run this demo, you need to obtain and configure an API key for Google Maps.
* Supported platforms: only iOS and Android

Dart packages utilized:
* [equatable](https://pub.dev/packages/equatable): equality and hash utils
* [geobase](https://pub.dev/packages/geobase): geospatial data structures and vector data support for GeoJSON
* [geodata](https://pub.dev/packages/geodata): fetching geospatial data from GeoJSON REST and OGC API Features services
* [intl](https://pub.dev/packages/intl): localized date formatting
* [state_notifier](https://pub.dev/packages/state_notifier): helps manipulating a state object with multiple ways to update it 

Flutter packages utilized:
* [flutter_riverpod](https://pub.dev/packages/flutter_riverpod): an efficient and straightforward state management library (see also [Riverpod](https://riverpod.dev/) docs)
* [google_maps_flutter](https://pub.dev/packages/google_maps_flutter): a map view widget for iOS and Android platforms (Note: an API key must be configured)

<img src="assets/screenshots/settings_view.png" width="40%" title="Earthquake Map - Settings View" />

## ⚙️ Setup

The demo app requires at least [Dart](https://dart.dev/) SDK 2.17 and [Flutter](https://flutter.dev/) SDK 3.0.

Check instructions to setup [Google Maps for Flutter](https://pub.dev/packages/google_maps_flutter). At least you must change API keys on:

- android/app/src/main/AndroidManifest.xml
    - manifest -> application
        - `<meta-data android:name="com.google.android.geo.API_KEY" android:value="<YOUR-APIKEY>"/>`
- ios/Runner/AppDelegate.swift
    - AppDelegate -> application
        - `GMSServices.provideAPIKey("<YOUR-APIKEY>")`

## 🌐 Fetching geospatial data

This sample uses the [geodata](https://pub.dev/packages/geodata) package that
has following features:
* 🌐 The [GeoJSON](https://geojson.org/) client to read features from static web resources and local files
* 🌎 The [OGC API Features](https://ogcapi.ogc.org/features/) client to access metadata and feature items from a compliant geospatial Web API providing GeoJSON data

There are two online data sources used by this app, both providing earthquakes:
* [GeoJSON feed](https://earthquake.usgs.gov/earthquakes/feed/) provided by USGS
* [OGC API Feature service](https://ogcapi.bgs.ac.uk/collections/recentearthquakes?f=html)
provided by BGS

These data sources represent earthquake entites as GeoJSON `Feature` objects
with `Point` geometries, but properties are based on different data models. So
it would be difficult to use any code generation tool to map a JSON data model
to a domain specific data model in Dart.

In the repository and UI of this sammple earthquake entities are represented by
a model defined in
[earthquake_model.dart](lib/src/data/earthquakes/earthquake_model.dart):

```dart
enum EarthquakeProducer { usgs, bgs }

class Earthquake extends Equatable {
  final EarthquakeProducer producer;
  final Object? id;
  final DateTime time;
  final double magnitude;
  final Geographic epicenter;
  final double? depthKM;
  final String? place;

  // ...
}
```

Here the `epicenter` field is defined as `Geographic` that is a geographic
position from the [geobase](https://pub.dev/packages/geobase) package.

To support decoding data both from USGS and BGS originated GeoJSON `Feature`
instances (with different data models) we need (not-so-simple) factory methods
like:

```dart
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
```

Both `Feature` and `Point` classes on this code snippet are also defined by the
[geobase](https://pub.dev/packages/geobase) package.

There is also a similar constructor for BGS originated `Feature` objects.

API queries are parametrized by a query class that is defined in
[earthquake_query.dart](lib/src/data/earthquakes/earthquake_query.dart):

```dart
class EarthquakeQuery extends Equatable {
  final EarthquakeProducer producer;
  final Magnitude magnitude;
  final Past past;
```

On the same file there is also a state object for the query filter state as a 
`StateNotifierProvider` (a provider type from the 
[flutter_riverpod](https://pub.dev/packages/flutter_riverpod) package). The
state can be modified by an user on the settings page. See 
[settings_view.dart](lib/src/settings/settings_view.dart) for details.

Geospatial API requests are implemented in 
[earthquake_repository.dart](lib/src/data/earthquakes/earthquake_repository.dart).

First there are private functions to fetch data from both USGS and BGS data
sources that are based on different geospatial API protocols. Fetching
implementations use geospatial feature source and API client classes provided by
the [geodata](https://pub.dev/packages/geodata) package as demonstrated below.

Fetch GeoJSON data from USGS service (a custom REST API):

```dart
/// Fetches earthquakes as GeoJSON feature collection from the USGS earthquake
/// service (a RESTful API with custom API parameters, results are GeoJSON).
///
/// This implementation uses the HTTP Client for a GeoJSON data source provided
/// by the 'package:geodata/geojson_client.dart' library.
Future<List<Earthquake>> _fetchUsgsEarthquakes(EarthquakeQuery query) async {
  // create a feature source for the USGS earthquake service
  final location = _usgsEarthquakesUri(query);
  final source = GeoJSONFeatures.http(location: location);

  // fetch all features items from the source
  final items = await source.itemsAll();

  // map feature instances to Earthquake instances
  return items.collection.features
      .map(Earthquake.fromUSGS)
      .toList(growable: false);
}
```

Fetch GeoJSON data from BGS service (a standardized OGC API Features service):

```dart
/// Fetches earthquakes as GeoJSON feature collection from the BGS earthquake
/// service (the API is standardized OGC API Features, results are GeoJSON).
///
/// This implementation uses the OGC API Features Client provided
/// by the 'package:geodata/ogcapi_features_client.dart' library.
Future<List<Earthquake>> _fetchBgsEarthquakes(EarthquakeQuery query) async {
  // create an OGC API Features client for the BGS earthquake service
  final location = _bgsEarthquakesUri;
  final client = OGCAPIFeatures.http(endpoint: location);

  // for OGC API Features service, get first a feature source for a collection
  final source = await client.collection(_bgsEarthquakesCollection);

  // then fetch all features items from the source
  final items = await source.itemsAll();

  // map feature instances to Earthquake instances
  return items.collection.features
      .map(Earthquake.fromBGS)
      .toList(growable: false);
}
```

Finally we define a `FutureProvider` (once again from Riverpod) that uses one of
fetch functions described above depending on the query filter state (here
delivered as a "family" parameter).

```dart
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
```

## 🌎 Visualizing earthquakes as markers

This sample app presents data on a map with following simple steps:
* background map based on the [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) plugin
* earthquake entities are visualized as map markers
* map markers also show an info window when clicked

The view model is implemented in 
[earthquake_view_model.dart](lib/src/data/earthquakes/earthquake_view_model.dart).
It has a provider called `earthquakeLayer` that watches the query filter state
and uses the repository described in the previous section. Earthquake objects
received from the repository are converted to `Marker` objects supported by
the Google Maps plugin.

The view model implementation watches also on the (text) presentation logic
implemented in
[earthquake_presentation.dart](lib/src/data/earthquakes/earthquake_presentation.dart).
It provides logic to format earthquake model objects to text strings used by
info windows of map markers. This presentation logic could be consumed in other
UI elements too. 

See details on code links above.

The map UI with markers is provided by code in
[map_view.dart](lib/src/map/map_view.dart):

```dart
@override
  Widget build(BuildContext context) {
    // watch for earthquake changes
    final layer = ref.watch(earthquakeLayer);

    // state is calculated as function of context
    final state = layer.call(context);

    // get earthquake markers
    final markers = state.markers;

    return Stack(
      children: <Widget>[
        // `hybrid` background map with earthquakes markers
        GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: _initialPosition,
          markers: markers ?? {},

          // this is called "when the map is ready to be used"
          onMapCreated: _controller.complete,
        ),

        // a simple loading indicator over the map
        if (state.isLoading)
          const Positioned(
            top: 30,
            left: 30,
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
```

## 📚 Code files

* lib/
  * src/
    * data/earthquakes/
      * [earthquake_model.dart](lib/src/data/earthquakes/earthquake_model.dart) (the earthquake entity class as represented by a client-side repository, also factory methods from USGS and BGS feature object models)  
      * [earthquake_presentation.dart](lib/src/data/earthquakes/earthquake_presentation.dart) (the provider for a formatter function producing text representations of earthquakes) 
      * [earthquake_query.dart](lib/src/data/earthquakes/earthquake_query.dart) (the query model class and enums, and the state notifier provider for query filters)      
      * [earthquake_repository.dart](lib/src/data/earthquakes/earthquake_repository.dart) (the future provider to access feature items from the USGS and BGS earthquake services)
      * [earthquake_view_model.dart](lib/src/data/earthquakes/earthquake_view_model.dart) (the provider providing a view model for an earthquake layer with a set of map markers)
    * map/
      * [map_view.dart](lib/src/map/map_view.dart) (the map view showing Google Maps and earthquakes as markers)
    * preferences/
      * [units.dart](lib/src/preferences/units.dart) (the state proviver for a preference of the unit system)
    * settings/
      * [settings_view.dart](lib/src/settings/settings_view.dart) (the settings view shows a selection for units and filter parameters)
    * utils/
      * [strings.dart](lib/src/utils/strings.dart) (utility functions for String manipulation)
  * [main.dart](lib/main.dart) (the app widget showing the main view with a map)

## :house_with_garden: Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial_demos](https://github.com/navibyte/geospatial_demos) repository
from GitHub. 

## :copyright: License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial_demos/blob/main/LICENSE).