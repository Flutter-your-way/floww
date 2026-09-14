import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:floww/core/health/models/health_snapshot.dart';
import 'package:floww/core/health/providers/health_provider.dart';
import 'package:floww/core/health/services/health_service.dart';

class _FakeHealthService extends HealthService {
  _FakeHealthService({
    this.supported = true,
    this.granted = true,
    this.snapshot = HealthSnapshot.empty,
    this.fetchFails = false,
  });

  final bool supported;
  final bool granted;
  final HealthSnapshot snapshot;
  final bool fetchFails;

  int requestCount = 0;
  int fetchCount = 0;

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<bool> requestPermissions() async {
    requestCount++;
    return granted;
  }

  @override
  Future<HealthSnapshot> fetchTodaySnapshot() async {
    fetchCount++;
    if (fetchFails) throw HealthServiceException('boom');
    return snapshot;
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('snapshot summary formats steps, sleep and resting heart rate', () {
    const snapshot = HealthSnapshot(
      steps: 8432,
      activeCaloriesKcal: 412,
      restingHeartRate: 54,
      sleepMinutes: 432,
      workoutCount: 1,
      syncedAt: null,
    );

    expect(snapshot.stepsLabel, '8,432');
    expect(snapshot.sleepLabel, '7h 12m');
    expect(snapshot.summaryLabel, '8,432 steps · 7h 12m sleep · 54 bpm resting');
  });

  test('connect grants access, syncs and persists the connection', () async {
    final service = _FakeHealthService(
      snapshot: const HealthSnapshot(
        steps: 1200,
        activeCaloriesKcal: 90,
        restingHeartRate: null,
        sleepMinutes: 0,
        workoutCount: 0,
        syncedAt: null,
      ),
    );
    final provider = HealthProvider(service);

    await provider.connect();

    expect(provider.status, HealthConnectionStatus.connected);
    expect(provider.snapshot.steps, 1200);
    expect(service.fetchCount, 1);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(HealthProvider.connectedKey), isTrue);
  });

  test('denied access leaves the provider disconnected with a message', () async {
    final provider = HealthProvider(_FakeHealthService(granted: false));

    await provider.connect();

    expect(provider.status, HealthConnectionStatus.disconnected);
    expect(provider.errorMessage, isNotNull);
  });

  test('unsupported platform reports unavailable', () async {
    final provider = HealthProvider(_FakeHealthService(supported: false));

    await provider.connect();

    expect(provider.status, HealthConnectionStatus.unavailable);
  });

  test('a failed sync surfaces an error but keeps the connection', () async {
    final provider = HealthProvider(_FakeHealthService(fetchFails: true));

    await provider.connect();

    expect(provider.isConnected, isTrue);
    expect(provider.errorMessage, 'boom');
  });

  test('disconnect clears the snapshot and the persisted flag', () async {
    final provider = HealthProvider(
      _FakeHealthService(
        snapshot: const HealthSnapshot(
          steps: 500,
          activeCaloriesKcal: 0,
          restingHeartRate: null,
          sleepMinutes: 0,
          workoutCount: 0,
          syncedAt: null,
        ),
      ),
    );

    await provider.connect();
    await provider.disconnect();

    expect(provider.isConnected, isFalse);
    expect(provider.snapshot.steps, 0);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(HealthProvider.connectedKey), isFalse);
  });

  test('restore reconnects from the persisted flag and refreshes', () async {
    SharedPreferences.setMockInitialValues({
      HealthProvider.connectedKey: true,
    });
    final service = _FakeHealthService();
    final provider = HealthProvider(service);

    await provider.restore();

    expect(provider.isConnected, isTrue);
    expect(service.requestCount, 0);
    expect(service.fetchCount, 1);
  });
}
