import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/menu_item.dart';
import '../models/tenant.dart';

/// Service untuk mengambil data tenant dan menu dari Supabase.
class TenantMenuService {
  // Client Supabase yang sudah diinisialisasi di main.dart
  final SupabaseClient _client = Supabase.instance.client;

  /// Mengambil SATU tenant berdasarkan id-nya.
  Future<Tenant> getTenantById(String tenantId) async {
    final data = await _client
        .from('tenants')
        .select()
        .eq('id', tenantId)
        .single();

    return Tenant.fromJson(data);
  }

  /// Mengambil SEMUA menu milik satu tenant, diurutkan berdasarkan nama.
  Future<List<MenuItem>> getMenusByTenant(String tenantId) async {
    final data = await _client
        .from('menus')
        .select()
        .eq('tenant_id', tenantId)
        .order('name');

    return data.map((json) => MenuItem.fromJson(json)).toList();
  }
}
