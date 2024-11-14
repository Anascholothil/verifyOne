import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';

enum LocationStatus {
  initial,
  loading,
  success,
  serviceDisabled,
  permissionDenied,
  error
}

class LocationData {
  final String name;
  final double? latitude;
  final double? longitude;
  final LocationStatus status;
  final String? error;

  LocationData({
    required this.name,
    this.latitude,
    this.longitude,
    this.status = LocationStatus.initial,
    this.error,
  });

  LocationData copyWith({
    String? name,
    double? latitude,
    double? longitude,
    LocationStatus? status,
    String? error,
  }) {
    return LocationData(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

class LocationProvider extends ChangeNotifier {
  LocationData _locationData = LocationData(
    name: 'Initializing...',
    status: LocationStatus.initial,
  );
  final Location _location = Location();
  bool _isProcessing = false;

  LocationData get locationData => _locationData;

  LocationProvider() {
    getCurrentLocationAndSave();
  }

  Future<void> getCurrentLocationAndSave() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      _updateState(
        name: 'Fetching location...',
        status: LocationStatus.loading,
      );

      // Check location service
      final serviceEnabled = await _checkLocationService();
      if (!serviceEnabled) {
        _updateState(
          name: 'Please enable location services',
          status: LocationStatus.serviceDisabled,
        );
        return;
      }

      // Check permissions
      final permissionGranted = await _checkLocationPermission();
      if (!permissionGranted) {
        _updateState(
          name: 'Please allow location permission',
          status: LocationStatus.permissionDenied,
        );
        return;
      }

      // Get location
      final currentLocation = await _getLocationData();
      if (currentLocation == null) return;

      // Get address
      await _getAddressFromLocation(currentLocation);

    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
    } finally {
      _isProcessing = false;
    }
  }

  Future<bool> _checkLocationService() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
    }
    return serviceEnabled;
  }

  Future<bool> _checkLocationPermission() async {
    var permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }
    return permissionGranted == PermissionStatus.granted;
  }

  Future<LocationData?> _getLocationData() async {
    final currentLocation = await _location.getLocation();

    if (currentLocation.latitude == null || currentLocation.longitude == null) {
      _updateState(
        name: 'Unable to get location',
        status: LocationStatus.error,
        error: 'Invalid location data received',
      );
      return null;
    }

    return LocationData(
      name: 'Location obtained',
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
      status: LocationStatus.success,
    );
  }

  Future<void> _getAddressFromLocation(LocationData location) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        location.latitude!,
        location.longitude!,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final locationString = _formatAddress(place);

        _updateState(
          name: locationString,
          latitude: location.latitude,
          longitude: location.longitude,
          status: LocationStatus.success,
        );
      } else {
        _updateState(
          name: 'Location found but address unknown',
          latitude: location.latitude,
          longitude: location.longitude,
          status: LocationStatus.success,
        );
      }
    } catch (e) {
      _updateState(
        name: 'Address lookup failed',
        latitude: location.latitude,
        longitude: location.longitude,
        status: LocationStatus.success,
        error: e.toString(),
      );
    }
  }

  String _formatAddress(geo.Placemark place) {
    final parts = <String>[];

    if (place.locality?.isNotEmpty == true) {
      parts.add(place.locality!);
    }
    if (place.administrativeArea?.isNotEmpty == true) {
      parts.add(place.administrativeArea!);
    }

    if (parts.isEmpty) {
      parts.addAll([
        if (place.subLocality?.isNotEmpty == true) place.subLocality!,
        if (place.street?.isNotEmpty == true) place.street!,
      ]);
    }

    return parts.isEmpty ? 'Location Found' : parts.join(', ');
  }

  void _handleError(Object error, StackTrace stackTrace) {
    debugPrint('Location error: $error');
    debugPrint('Stack trace: $stackTrace');

    final errorMessage = error.toString().toLowerCase();
    if (errorMessage.contains('permission_denied')) {
      _updateState(
        name: 'Location permission denied',
        status: LocationStatus.permissionDenied,
        error: error.toString(),
      );
    } else if (errorMessage.contains('location_disabled')) {
      _updateState(
        name: 'Please enable location services',
        status: LocationStatus.serviceDisabled,
        error: error.toString(),
      );
    } else {
      _updateState(
        name: 'Unable to get location',
        status: LocationStatus.error,
        error: error.toString(),
      );
    }
  }

  void _updateState({
    String? name,
    double? latitude,
    double? longitude,
    LocationStatus? status,
    String? error,
  }) {
    _locationData = _locationData.copyWith(
      name: name,
      latitude: latitude,
      longitude: longitude,
      status: status,
      error: error,
    );
    notifyListeners();
  }
}