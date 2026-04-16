import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

class MapRegion {
  final String id;
  final String name;
  final String? parentName;
  final List<List<LatLng>> polygons;
  final LatLng centroid;

  MapRegion({
    required this.id,
    required this.name,
    this.parentName,
    required this.polygons,
    required this.centroid,
  });
}

class GeoJsonParser {
  static Future<List<MapRegion>> parseRwandaProvinces() async {
    return parse('assets/data/map/rwanda_adm1.geojson', isProvince: true);
  }

  static Future<List<MapRegion>> parseRwandaDistricts() async {
    return parse('assets/data/map/rwanda_adm2.geojson', 
      isProvince: false, 
      parentKeys: ['ADM1_EN', 'ADM1_RW', 'Province', 'PROVINCE']
    );
  }
  
  static Future<List<MapRegion>> parseRwandaSectors() async {
    return parse('assets/data/map/rwanda_adm3.geojson', 
      parentKeys: ['ADM2_EN', 'ADM2_RW', 'District', 'DISTRICT']
    );
  }

  static Future<List<MapRegion>> parse(String assetPath, {bool isProvince = false, List<String>? parentKeys}) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      return compute(_parseGeoJSONBytes, {'bytes': bytes, 'isProvince': isProvince, 'parentKeys': parentKeys});
    } catch (e) {
      debugPrint('Error loading $assetPath: $e');
      return [];
    }
  }

  static List<MapRegion> _parseGeoJSONBytes(Map<String, dynamic> params) {
    try {
      final Uint8List bytes = params['bytes'] as Uint8List;
      final bool isProvince = params['isProvince'] as bool;
      final List<String>? parentKeys = params['parentKeys'] as List<String>?;
      
      final String jsonString = utf8.decode(bytes);
      final Map<String, dynamic> data = json.decode(jsonString);

      final features = data['features'] as List;
      final List<MapRegion> regions = [];

      for (var f in features) {
        final props = f['properties'] as Map<String, dynamic>;
        
        String rawName = props['shapeName'] ?? 
                         props['ADM3_EN'] ?? 
                         props['ADM2_EN'] ?? 
                         props['ADM1_EN'] ?? 
                         props['Name'] ?? 
                         props['NAME'] ?? 
                         props['SECTOR'] ??
                         props['DISTRICT'] ??
                         props['PROVINCE'] ??
                         '';
                         
        String? parentName;
        if (parentKeys != null) {
          for (var key in parentKeys) {
            if (props[key] != null) {
              parentName = props[key];
              break;
            }
          }
        } 
        
        parentName ??= props['ADM2_EN'] ?? props['ADM1_EN'] ?? props['Parent'];
        String id = rawName;
        if (isProvince) {
             if (rawName.contains('Kigali')) id = 'RW.K';
             else if (rawName.contains('North')) id = 'RW.N';
             else if (rawName.contains('South')) id = 'RW.S';
             else if (rawName.contains('East')) id = 'RW.E';
             else if (rawName.contains('West')) id = 'RW.W';
        }

        final geometry = f['geometry'];
        if (geometry == null) continue;

        final type = geometry['type'];
        final coords = geometry['coordinates'] as List;
        final List<List<LatLng>> polygons = [];

        if (type == 'Polygon') {
          for (var ring in coords) {
            polygons.add(_parseRing(ring as List));
          }
        } else if (type == 'MultiPolygon') {
          for (var polygon in coords) {
             for (var ring in (polygon as List)) {
               polygons.add(_parseRing(ring as List));
             }
          }
        }

        if (polygons.isNotEmpty) {
           regions.add(MapRegion(
             id: id,
             name: rawName,
             parentName: parentName,
             polygons: polygons,
             centroid: _computeCentroid(polygons),
           ));
        }
      }
      return regions;
    } catch (e) {
      debugPrint('Error parsing GeoJSON in isolate: $e');
      return [];
    }
  }

  static LatLng _computeCentroid(List<List<LatLng>> polygons) {
     double sumLat = 0;
     double sumLon = 0;
     int count = 0;
     List<LatLng> mainRing = polygons[0];
     int maxLength = 0;
     for (var p in polygons) {
       if (p.length > maxLength) {
         maxLength = p.length;
         mainRing = p;
       }
     }
     for (var p in mainRing) {
       sumLat += p.latitude;
       sumLon += p.longitude;
       count++;
     }
     return LatLng(sumLat / count, sumLon / count);
  }

  static List<LatLng> _parseRing(List<dynamic> ring) {
    return ring.map((point) {
      final p = point as List;
      return LatLng(p[1].toDouble(), p[0].toDouble());
    }).toList();
  }
}
