import 'dart:async';
import 'dart:math';

// ─────────────────────────────────────────────
// MODEL LOKASI
// ─────────────────────────────────────────────
class MitraLocation {
  final double lat, lng;
  final double accuracy;   // meter
  final DateTime timestamp;

  const MitraLocation({
    required this.lat,
    required this.lng,
    this.accuracy = 10.0,
    required this.timestamp,
  });

  MitraLocation copyWith({double? lat, double? lng}) => MitraLocation(
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    accuracy: accuracy,
    timestamp: DateTime.now(),
  );

  // Format koordinat untuk display
  String get formatted =>
      '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
}

// ─────────────────────────────────────────────
// LOCATION SERVICE
// Stub yang siap diganti dengan geolocator nyata
// ─────────────────────────────────────────────
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // State
  bool _isOnline = false;
  bool _isSharingLocation = false;
  MitraLocation? _currentLocation;
  Timer? _locationTimer;
  final _random = Random();

  // Stream controllers
  final _locationController =
      StreamController<MitraLocation>.broadcast();
  final _onlineStatusController = StreamController<bool>.broadcast();

  // Getters
  bool get isOnline => _isOnline;
  bool get isSharingLocation => _isSharingLocation;
  MitraLocation? get currentLocation => _currentLocation;
  Stream<MitraLocation> get locationStream => _locationController.stream;
  Stream<bool> get onlineStatusStream => _onlineStatusController.stream;

  // Lokasi awal simulasi (Bogor)
  static const _baseLat = -6.5971;
  static const _baseLng = 106.8060;

  // ── Toggle Online/Offline ──
  Future<bool> goOnline() async {
    // TODO: Ganti dengan permission check nyata:
    // final permission = await Geolocator.requestPermission();
    // if (permission == LocationPermission.denied) return false;

    // Simulasi delay request izin
    await Future.delayed(const Duration(milliseconds: 800));

    _isOnline = true;
    _onlineStatusController.add(true);

    // Start simulasi lokasi
    _startLocationSimulation();

    return true;
  }

  Future<void> goOffline() async {
    _isOnline = false;
    _isSharingLocation = false;
    _onlineStatusController.add(false);
    _stopLocationSimulation();
  }

  // ── Share lokasi saat order aktif ──
  void startSharingLocation() {
    if (!_isOnline) return;
    _isSharingLocation = true;
    // TODO: Upload lokasi ke backend secara periodik:
    // _uploadToBackend(_currentLocation!);
  }

  void stopSharingLocation() {
    _isSharingLocation = false;
  }

  // ── Simulasi pergerakan GPS ──
  void _startLocationSimulation() {
    _currentLocation = MitraLocation(
      lat: _baseLat, lng: _baseLng,
      timestamp: DateTime.now(),
    );
    _locationController.add(_currentLocation!);

    _locationTimer = Timer.periodic(
        const Duration(seconds: 3), (_) {
      if (!_isOnline) return;

      // Simulasi pergerakan kecil (±0.0002 derajat ~ 20 meter)
      final newLat = _currentLocation!.lat +
          (_random.nextDouble() - 0.5) * 0.0004;
      final newLng = _currentLocation!.lng +
          (_random.nextDouble() - 0.5) * 0.0004;

      _currentLocation = MitraLocation(
        lat: newLat, lng: newLng,
        accuracy: 8 + _random.nextDouble() * 5,
        timestamp: DateTime.now(),
      );
      _locationController.add(_currentLocation!);

      // TODO: Kirim ke backend saat isSharingLocation:
      // if (_isSharingLocation) _uploadToBackend(_currentLocation!);
    });
  }

  void _stopLocationSimulation() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _currentLocation = null;
  }

  // TODO: Implementasi upload ke backend
  // Future<void> _uploadToBackend(MitraLocation loc) async {
  //   await http.post(Uri.parse('$baseUrl/mitra/location'), body: {
  //     'lat': loc.lat.toString(),
  //     'lng': loc.lng.toString(),
  //     'timestamp': loc.timestamp.toIso8601String(),
  //   });
  // }

  void dispose() {
    _stopLocationSimulation();
    _locationController.close();
    _onlineStatusController.close();
  }
}
