import 'dart:convert';
import 'package:flutter/services.dart';

const destinationAsset = 'assets/data/destinations.json';

class DestinationInfo {
  const DestinationInfo(
    this.countryCode,
    this.countryName,
    this.aliases, {
    required this.photoUrl,
    this.cityId,
    this.latitude,
    this.longitude,
  });

  final String countryCode;
  final String countryName;
  final List<String> aliases;
  final String photoUrl;
  final double? latitude;
  final double? longitude;
  String get cityName => aliases[1];
  bool get hasCoordinates => latitude != null && longitude != null;
  // Regions/islands have no city ID and do not inflate visited city counts.
  final String? cityId;
  String? get cityKey => cityId == null ? null : '$countryCode/$cityId';
}

/// Validates the bundled JSON once; lookups remain synchronous and exact.
class DestinationCatalog {
  DestinationCatalog._(this.defaultPhotoUrl, this.entries, this._byAlias);

  final String defaultPhotoUrl;
  final List<DestinationInfo> entries;
  final Map<String, DestinationInfo> _byAlias;

  DestinationInfo? resolve(String value) => _byAlias[_normalize(value)];

  factory DestinationCatalog.parse(String source) {
    final data = jsonDecode(source);
    if (data is! Map<String, dynamic> || data['schemaVersion'] != 1) {
      throw const FormatException('Unsupported destination catalog schema');
    }
    final fallback = _photo(data['defaultPhotoUrl']);
    final entries = <DestinationInfo>[];
    final byAlias = <String, DestinationInfo>{};
    final ids = <String>{};
    final countries = <String, String>{};
    for (final section in ['cities', 'regions']) {
      for (final row in _list(data[section])) {
        if (row is! Map<String, dynamic> || row['names'] is! Map) {
          throw const FormatException('Destination names must be an object');
        }
        final code = _text(row['countryCode']);
        final country = _text(row['countryName']);
        final id = _text(row['id']);
        if (!RegExp(r'^[A-Z]{2}$').hasMatch(code) ||
            !RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(id) ||
            !ids.add('$code/$id') ||
            (countries.containsKey(code) && countries[code] != country)) {
          throw const FormatException(
            'Invalid or duplicate destination identity',
          );
        }
        countries[code] = country;
        final names = row['names'] as Map;
        final aliases = [
          for (final language in ['en', 'ko', 'zh']) _text(names[language]),
          for (final alias in _list(row['aliases'] ?? [])) _text(alias),
        ];
        final latitude = row['latitude'];
        final longitude = row['longitude'];
        if ((latitude != null || longitude != null) &&
            (latitude is! num ||
                longitude is! num ||
                !latitude.isFinite ||
                !longitude.isFinite ||
                latitude < -90 ||
                latitude > 90 ||
                longitude < -180 ||
                longitude > 180)) {
          throw const FormatException('Invalid destination coordinates');
        }
        final destination = DestinationInfo(
          code,
          country,
          List.unmodifiable(aliases),
          latitude: (latitude as num?)?.toDouble(),
          longitude: (longitude as num?)?.toDouble(),
          cityId: section == 'cities' ? id : null,
          photoUrl: row.containsKey('photoUrl')
              ? _photo(row['photoUrl'])
              : fallback,
        );
        for (final alias in aliases) {
          final key = _normalize(alias);
          if (byAlias.containsKey(key) && byAlias[key] != destination) {
            throw FormatException('Ambiguous destination alias: $alias');
          }
          byAlias[key] = destination;
        }
        entries.add(destination);
      }
    }
    return DestinationCatalog._(
      fallback,
      List.unmodifiable(entries),
      Map.unmodifiable(byAlias),
    );
  }
}

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'[,，\s]+'), ' ');

String _text(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    throw const FormatException('Destination text must not be empty');
  }
  return value.trim();
}

List<dynamic> _list(Object? value) {
  if (value is! List) throw const FormatException('Expected destination array');
  return value;
}

String _photo(Object? value) {
  final text = _text(value);
  final uri = Uri.tryParse(text);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    throw const FormatException('Destination photos require an HTTPS URL');
  }
  return text;
}

DestinationCatalog? _catalog;
DestinationCatalog get _loaded =>
    _catalog ??
    (throw StateError('Call loadDestinations before starting the app'));

Future<void> loadDestinations() async {
  final source = await rootBundle.loadString(destinationAsset);
  // Keep any previously valid catalog intact if validation fails.
  _catalog = DestinationCatalog.parse(source);
}

String get defaultTripPhoto => _loaded.defaultPhotoUrl;
DestinationInfo? resolveDestination(String value) => _loaded.resolve(value);
