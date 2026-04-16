import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/location/utils/geojson_parser.dart';

class AdministrativeMap extends StatefulWidget {
  final String? selectedProvince;
  final String? selectedDistrict;

  const AdministrativeMap({
    super.key,
    this.selectedProvince,
    this.selectedDistrict,
  });

  @override
  State<AdministrativeMap> createState() => _AdministrativeMapState();
}

class _AdministrativeMapState extends State<AdministrativeMap> {
  final MapController _mapController = MapController();
  List<MapRegion> _provinces = [];
  List<MapRegion> _districts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    final results = await Future.wait([
      GeoJsonParser.parseRwandaProvinces(),
      GeoJsonParser.parseRwandaDistricts(),
    ]);
    if (mounted) {
      setState(() {
        _provinces = results[0];
        _districts = results[1];
        _isLoading = false;
      });
      _fitBounds();
    }
  }

  @override
  void didUpdateWidget(AdministrativeMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedProvince != oldWidget.selectedProvince ||
        widget.selectedDistrict != oldWidget.selectedDistrict) {
      _fitBounds();
    }
  }

  void _fitBounds() {
    if (_isLoading) return;

    MapRegion? target;
    double zoom = 9.2;

    if (widget.selectedDistrict != null) {
      target = _districts.firstWhere(
        (d) => d.name.toLowerCase() == widget.selectedDistrict!.toLowerCase(),
        orElse: () => _districts[0],
      );
      zoom = 11.0;
    } else if (widget.selectedProvince != null) {
      target = _provinces.firstWhere(
        (p) => p.name.toLowerCase() == widget.selectedProvince!.toLowerCase(),
        orElse: () => _provinces[0],
      );
      zoom = 10.0;
    }

    if (target != null) {
      _mapController.move(target.centroid, zoom);
    } else {
      _mapController.move(const LatLng(-1.9403, 30.05), 9.2);
    }
  }

  Color _getFillColor(MapRegion region) {
    final name = region.name.toLowerCase();
    final isProvinceMatch = widget.selectedProvince?.toLowerCase() == name;
    final isDistrictMatch = widget.selectedDistrict?.toLowerCase() == name;

    if (isDistrictMatch) return Colors.green.withOpacity(0.5);
    if (isProvinceMatch) return Colors.green.withOpacity(0.2);
    
    return Colors.grey.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(-1.9403, 30.05),
            initialZoom: 9.2,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            PolygonLayer(
              polygons: _provinces.expand((region) => region.polygons.map((points) => Polygon(
                points: points,
                color: _getFillColor(region),
                borderColor: Colors.green,
                borderStrokeWidth: 1,
              ))).toList(),
            ),
            if (widget.selectedProvince != null)
              PolygonLayer(
                polygons: _districts
                    .where((d) => d.parentName?.toLowerCase() == widget.selectedProvince?.toLowerCase())
                    .expand((region) => region.polygons.map((points) => Polygon(
                  points: points,
                  color: _getFillColor(region),
                  borderColor: Colors.green.withOpacity(0.5),
                  borderStrokeWidth: 0.5,
                ))).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
