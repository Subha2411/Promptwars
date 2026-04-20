import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class RealtimeSyncService {
  final SupabaseService _supabaseService;
  
  RealtimeSyncService(this._supabaseService);

  RealtimeChannel? _zonesChannel;
  RealtimeChannel? _membersChannel;
  RealtimeChannel? _alertsChannel;
  RealtimeChannel? _meetPointsChannel;

  /// Starts listening to Postgres changes.
  void startSubscriptions({
    required Function(Map<String, dynamic>) onZoneUpdate,
    required Function(Map<String, dynamic>) onMemberUpdate,
    required Function(Map<String, dynamic>) onAlertInsert,
    required Function(Map<String, dynamic>) onMeetPointUpdate,
  }) {
    if (!_supabaseService.isReady) return;
    
    final client = Supabase.instance.client;

    _zonesChannel = client.channel('public:venue_zones').onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'venue_zones',
      callback: (payload) => onZoneUpdate(payload.newRecord),
    )..subscribe();

    _membersChannel = client.channel('public:group_members').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'group_members',
      callback: (payload) => onMemberUpdate(payload.newRecord),
    )..subscribe();

    _alertsChannel = client.channel('public:smart_alerts').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'smart_alerts',
      callback: (payload) => onAlertInsert(payload.newRecord),
    )..subscribe();
    
    _meetPointsChannel = client.channel('public:meet_points').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'meet_points',
      callback: (payload) => onMeetPointUpdate(payload.newRecord),
    )..subscribe();
  }

  void stopSubscriptions() {
    _zonesChannel?.unsubscribe();
    _membersChannel?.unsubscribe();
    _alertsChannel?.unsubscribe();
    _meetPointsChannel?.unsubscribe();
  }
}
