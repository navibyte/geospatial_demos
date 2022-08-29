# :compass: Geospatial demos for Dart 

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/navibyte.svg?style=social&label=Follow%20%40navibyte)](https://twitter.com/navibyte) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis) 

<a title="Stefan Kühn (Fotograf), CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Azimutalprojektion-schief_kl-cropped.png"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/projections/azimutal/Azimutalprojektion-schief_kl-cropped.png" align="right"></a>

**Geospatial** demo and sample apps for [Dart](https://dart.dev/) and 
[Flutter](https://flutter.dev/).

This is a companion demo code repository for the 
[Geospatial tools for Dart](https://github.com/navibyte/geospatial) repository
that contains Dart packages providing coordinates, geometries, feature objects, 
metadata, projections, tiling schemes, vector data models and formats, and
gespatial Web APIs.

[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/) [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)

## :sparkles: Code samples

[earthquake_map](earthquake_map)
* Shows earthquakes fetched from the [USGS web service](https://earthquake.usgs.gov/earthquakes/feed/) on a basic map view.
* Coding topics
  * **State management** (settings, query filters, Web API data access, presentation formatters, map view markers).
  * Using a **Web API client to access geospatial data** formatted as [GeoJSON](https://geojson.org/) feature and geometry objects.
  * Visualizing earthquakes (that are geospatial feature entities with point geometries) as **map markers on a map view**.
* Notes
  * The UI of this sample app is very basic. The app focuses on a clean demonstration of the topics mentioned above.
  * To run this demo, you need to obtain and configure an API key for Google Maps.
  * Supported platforms: only iOS and Android
* Dart packages utilized
  * [equatable](https://pub.dev/packages/equatable): equality and hash utils
  * [geobase](https://pub.dev/packages/geobase): geospatial data structures and vector data support for GeoJSON
  * [geodata](https://pub.dev/packages/geodata): fetching a Web API with GeoJSON data
  * [intl](https://pub.dev/packages/intl): localized date formatting
  * [state_notifier](https://pub.dev/packages/state_notifier): helps manipulating a state object with multiple ways to update it 
* Flutter packages utilized
  * [flutter_riverpod](https://pub.dev/packages/flutter_riverpod): an efficient and straightforward state management library (see also [Riverpod](https://riverpod.dev/) docs)
  * [google_maps_flutter](https://pub.dev/packages/google_maps_flutter): a map view widget for iOS and Android platforms (Note: an API key must be configured)

## :newspaper_roll: News

2022-08-29
* The first version of the [earthquake_map](earthquake_map) sample demonstrating state management, Web APIs for geospatial data and visualizing markers on a map view.

## :house_with_garden: Authors

This project is authored by [Navibyte](https://navibyte.com).

## :copyright: License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the [LICENSE](LICENSE).