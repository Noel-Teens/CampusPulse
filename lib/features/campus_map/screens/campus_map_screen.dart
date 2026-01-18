import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../issue_reporting/screens/report_issue_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/directions_service.dart';

enum MarkerCategory { all, academic, admin, hostel, important }

class CampusMarker {
  final String id;
  final LatLng position;
  final String title;
  final String description;
  final MarkerCategory category;

  CampusMarker({
    required this.id,
    required this.position,
    required this.title,
    required this.description,
    required this.category,
  });
}

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(12.866444, 80.220694);

  MarkerCategory _selectedCategory = MarkerCategory.all;
  Set<Polyline> _polylines = {};

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Please enable the services',
            ),
          ),
        );
      }
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, we cannot request permissions.',
            ),
          ),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _startNavigation(CampusMarker marker) async {
    debugPrint("Navigation requested for: ${marker.title}");

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text("Getting your location and route..."),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }

    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      debugPrint("Location permission denied or services disabled.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location permission is required for navigation"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      debugPrint("Fetching current position...");
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      debugPrint(
        "Current position: ${position.latitude}, ${position.longitude}",
      );

      final origin = LatLng(position.latitude, position.longitude);
      final destination = marker.position;

      // Fetch real directions from Google Directions API
      debugPrint("Fetching directions from Google Directions API...");
      final directionsService = DirectionsService();
      final routePoints = await directionsService.getDirections(
        origin,
        destination,
      );

      final details = await directionsService.getDirectionsDetails(
        origin,
        destination,
      );

      debugPrint("Route has ${routePoints.length} points");

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            points: routePoints,
            color: AppColors.deepBlue,
            width: 6,
            geodesic: true,
          ),
        };
      });

      debugPrint("Drawing route and moving camera.");

      // Calculate bounds from all route points
      if (routePoints.length >= 2) {
        double minLat = routePoints.first.latitude;
        double maxLat = routePoints.first.latitude;
        double minLng = routePoints.first.longitude;
        double maxLng = routePoints.first.longitude;

        for (var point in routePoints) {
          if (point.latitude < minLat) minLat = point.latitude;
          if (point.latitude > maxLat) maxLat = point.latitude;
          if (point.longitude < minLng) minLng = point.longitude;
          if (point.longitude > maxLng) maxLng = point.longitude;
        }

        // Add padding to bounds (15% on each side)
        double latPadding = (maxLat - minLat) * 0.15;
        double lngPadding = (maxLng - minLng) * 0.15;

        LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(minLat - latPadding, minLng - lngPadding),
          northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
        );

        // Animate camera to show the route
        await mapController.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50),
        );
      }

      if (mounted) {
        final distanceText =
            details['distanceText'] ??
            '${(details['distance'] as int? ?? 0)} m';
        final durationText =
            details['durationText'] ??
            '${((details['duration'] as int? ?? 0) / 60).toStringAsFixed(0)} min';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Route to ${marker.title}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.directions_walk,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$distanceText • $durationText",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            backgroundColor: AppColors.deepBlue,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: "Clear",
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  _polylines = {};
                });
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error during navigation: $e");
      if (mounted) {
        String errorMessage = "Error starting navigation";
        if (e.toString().contains("timeout")) {
          errorMessage = "Location request timed out. Please try again.";
        } else if (e.toString().contains("disabled")) {
          errorMessage = "Please enable location services in settings";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  final List<CampusMarker> _allMarkers = [
    CampusMarker(
      id: 'campus_center',
      position: const LatLng(12.866444, 80.220694),
      title: 'Jeppiaar Engineering College',
      description: 'Main Campus Admin Center',
      category: MarkerCategory.important,
    ),
    CampusMarker(
      id: 'cse_block',
      position: const LatLng(12.865797849002329, 80.22010272264627),
      title: 'CSE Block',
      description: 'Computer Science Department',
      category: MarkerCategory.academic,
    ),
    CampusMarker(
      id: 'first_year_block',
      position: const LatLng(12.866393178690839, 80.21951478362632),
      title: 'First Year Block',
      description: 'Freshers & Science/Humanities',
      category: MarkerCategory.academic,
    ),
    CampusMarker(
      id: 'admin_block',
      position: const LatLng(12.866307593992929, 80.22252903311089),
      title: 'Admin Block',
      description: 'Campus Administration & JPR Auditorium',
      category: MarkerCategory.admin,
    ),
    CampusMarker(
      id: 'auditorium',
      position: const LatLng(12.866438854707432, 80.21920633872459),
      title: 'JPR Auditorium',
      description: 'Events & Functions',
      category: MarkerCategory.important,
    ),
    CampusMarker(
      id: 'mech_dept',
      position: const LatLng(12.8671639874172, 80.21938267567725),
      title: 'Mechanical Dept',
      description: 'Mechanical Engineering Labs',
      category: MarkerCategory.academic,
    ),
    CampusMarker(
      id: 'computer_lab',
      position: const LatLng(12.866779386021467, 80.22004330240617),
      title: 'Computer Lab',
      description: 'Central Computing Facility',
      category: MarkerCategory.academic,
    ),
    CampusMarker(
      id: 'it_dept',
      position: const LatLng(12.86566942394621, 80.22106060563193),
      title: 'IT Dept',
      description: 'Information Technology Department',
      category: MarkerCategory.academic,
    ),
    CampusMarker(
      id: 'boys_hostel',
      position: const LatLng(12.86748703572417, 80.22232984065128),
      title: 'Boys Hostel',
      description: 'Men\'s Residential Block',
      category: MarkerCategory.hostel,
    ),
    CampusMarker(
      id: 'girls_hostel',
      position: const LatLng(12.868285232789084, 80.22134090878063),
      title: 'Girls Hostel',
      description: 'Women\'s Residential Block',
      category: MarkerCategory.hostel,
    ),
  ];

  double _getHueForCategory(MarkerCategory category) {
    switch (category) {
      case MarkerCategory.academic:
        return BitmapDescriptor.hueBlue;
      case MarkerCategory.admin:
        return BitmapDescriptor.hueOrange;
      case MarkerCategory.hostel:
        return BitmapDescriptor.hueGreen;
      case MarkerCategory.important:
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  Set<Marker> _getFilteredMarkers() {
    return _allMarkers
        .where(
          (m) =>
              _selectedCategory == MarkerCategory.all ||
              m.category == _selectedCategory,
        )
        .map(
          (m) => Marker(
            markerId: MarkerId(m.id),
            position: m.position,
            infoWindow: InfoWindow(title: m.title),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getHueForCategory(m.category),
            ),
            onTap: () => _showMarkerDetails(m),
          ),
        )
        .toSet();
  }

  void _showMarkerDetails(CampusMarker marker) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          marker.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          marker.category.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                marker.description,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.navigation),
                      label: const Text("Navigate"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _startNavigation(marker);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.report_problem,
                        color: AppColors.error,
                      ),
                      label: const Text("Report Issue"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReportIssueScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Campus Map")),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 17.5),
            markers: _getFilteredMarkers(),
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.hybrid,
            padding: const EdgeInsets.only(bottom: 80), // Padding for buttons
          ),

          // Category Filter
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: MarkerCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat.name.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = cat);
                      },
                      selectedColor: AppColors.deepBlue.withOpacity(0.2),
                      checkmarkColor: AppColors.deepBlue,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Find Nearest Buttons
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(
                  Icons.school,
                  "Nearest Lab",
                  MarkerCategory.academic,
                ),
                _buildQuickAction(
                  Icons.admin_panel_settings,
                  "Nearest Admin",
                  MarkerCategory.admin,
                ),
              ],
            ),
          ),

          // Tap Instruction
          Positioned(
            bottom: 75,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Tap markers for more details",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),

          // Legend Overlay
          Positioned(
            right: 16,
            top: 70,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Legend",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  _buildLegendItem(Colors.red, "Important"),
                  _buildLegendItem(Colors.blue, "Academic"),
                  _buildLegendItem(Colors.orange, "Admin"),
                  _buildLegendItem(Colors.green, "Hostel"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, MarkerCategory cat) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.deepBlue,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () {
        setState(() => _selectedCategory = cat);
        // Center on the first one of that category found
        final first = _allMarkers.firstWhere(
          (m) => m.category == cat,
          orElse: () => _allMarkers[0],
        );
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(first.position, 18.5),
        );
      },
    );
  }
}
