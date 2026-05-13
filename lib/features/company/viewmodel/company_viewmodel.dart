import 'package:flutter/foundation.dart';

import '../../../data/repositories/app_repository.dart';
import '../../../data/repositories/api_auth_repository.dart';
import '../../../data/services/company_api_service.dart';

// ─── Model ──────────────────────────────────────────────────────────────────

class CompanyQuote {
  const CompanyQuote({
    required this.quoteId,
    required this.jobBackendId,
    required this.jobCode,
    required this.vehicle,
    required this.issueTitle,
    required this.notes,
    required this.location,
    required this.distanceKm,
    required this.amount,
    required this.currency,
    required this.status,
    required this.statusLabel,
    required this.statusTone,
    required this.summaryLine,
    required this.canOpenActiveJob,
    required this.canAmend,
    required this.canWithdraw,
    required this.canResubmit,
    required this.createdAt,
    required this.quotedAgoLabel,
    required this.assignedMechanicId,
  });

  final String quoteId;
  final String jobBackendId;
  final String jobCode;

  /// e.g. "Scania R450"
  final String vehicle;

  /// Job title from `job.title` — main grey line under vehicle.
  final String issueTitle;

  /// Quote notes from API; optional second grey line under [issueTitle].
  final String notes;
  final String location;
  final double? distanceKm;
  final num amount;
  final String currency;
  final String status;
  final String statusLabel;
  final String statusTone;
  final String summaryLine;
  final bool canOpenActiveJob;
  final bool canAmend;
  final bool canWithdraw;
  final bool canResubmit;
  final DateTime? createdAt;

  /// Pre-formatted `"2 hrs ago"` from API (`quotedAgoLabel`).
  final String quotedAgoLabel;

  /// `job.assignedMechanic`: id string when assigned, otherwise null.
  final String? assignedMechanicId;

  // ── Derived display helpers ──────────────────────────────────────────────

  String get amountDisplay {
    final sym = switch (currency.toUpperCase()) {
      'GBP' => '£',
      'USD' => r'$',
      'EUR' => '€',
      _ => '',
    };
    return '$sym${amount.round()}';
  }

  String get timeSubmittedLabel =>
      quotedAgoLabel.trim().isNotEmpty ? quotedAgoLabel : _fallbackTimeAgo();

  bool get showsAssignMechanicBanner =>
      status.toUpperCase() == 'ACCEPTED' && assignedMechanicId == null;

  String _fallbackTimeAgo() {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    if (diff.inDays == 1) return '1 day ago';
    return '${diff.inDays} days ago';
  }

  factory CompanyQuote.fromJson(Map<String, dynamic> json) {
    final job = (json['job'] is Map<String, dynamic>)
        ? json['job'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final vehicleMap = (job['vehicle'] is Map<String, dynamic>)
        ? job['vehicle'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final locationMap = (job['location'] is Map<String, dynamic>)
        ? job['location'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final statusUi = (json['statusUi'] is Map<String, dynamic>)
        ? json['statusUi'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final actions = (json['actions'] is Map<String, dynamic>)
        ? json['actions'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final make = (vehicleMap['make'] as String?) ?? '';
    final model = (vehicleMap['model'] as String?) ?? '';
    final vehicleStr = [make, model].where((s) => s.isNotEmpty).join(' ');

    final title = ((job['title'] as String?) ?? '').trim();
    final notesRaw = ((json['notes'] as String?) ?? '').trim();

    final addr = (locationMap['address'] as String?) ?? '';

    final assignRaw = job['assignedMechanic'];
    String? mechanicId;
    if (assignRaw is String && assignRaw.isNotEmpty) {
      mechanicId = assignRaw;
    } else if (assignRaw is Map<String, dynamic>) {
      mechanicId = assignRaw['_id'] as String?;
    }

    DateTime? createdAt;
    try {
      final raw = json['createdAt'] as String?;
      if (raw != null) createdAt = DateTime.parse(raw);
    } catch (_) {}

    final dist = json['distanceKm'];
    double? distanceKm;
    if (dist is num) distanceKm = dist.toDouble();

    return CompanyQuote(
      quoteId: (json['_id'] as String?) ?? '',
      jobBackendId: (job['_id'] as String?) ?? '',
      jobCode: (job['jobCode'] as String?) ?? '',
      vehicle: vehicleStr,
      issueTitle: title,
      notes: notesRaw,
      location: addr,
      distanceKm: distanceKm,
      amount: (json['amount'] as num?) ?? 0,
      currency: (json['currency'] as String?) ?? 'GBP',
      status: (json['status'] as String?) ?? '',
      statusLabel: ((statusUi['label'] as String?) ?? '').trim(),
      statusTone: ((statusUi['tone'] as String?) ?? '').trim().toLowerCase(),
      summaryLine: ((json['summaryLine'] as String?) ?? '').trim(),
      canOpenActiveJob: (actions['canOpenActiveJob'] as bool?) ?? false,
      canAmend: (actions['canAmend'] as bool?) ?? false,
      canWithdraw: (actions['canWithdraw'] as bool?) ?? false,
      canResubmit: (actions['canResubmit'] as bool?) ?? false,
      createdAt: createdAt,
      quotedAgoLabel: ((json['quotedAgoLabel'] as String?) ?? '').trim(),
      assignedMechanicId: mechanicId,
    );
  }
}

// ─── Dashboard (GET /api/v1/company/dashboard) ─────────────────────────────

class CompanyRecentActivityRow {
  const CompanyRecentActivityRow({
    required this.title,
    required this.detail,
    required this.relativeTimeLabel,
    required this.icon,
    this.createdAt,
  });

  final String title;
  final String detail;
  /// API `relativeTime`, e.g. "26 min ago".
  final String relativeTimeLabel;
  final String icon;
  final DateTime? createdAt;

  factory CompanyRecentActivityRow.fromJson(Map<String, dynamic> json) {
    DateTime? createdAt;
    try {
      final raw = json['createdAt'] as String?;
      if (raw != null) createdAt = DateTime.parse(raw).toLocal();
    } catch (_) {}
    return CompanyRecentActivityRow(
      title: ((json['title'] as String?) ?? '').trim(),
      detail: ((json['detail'] as String?) ?? '').trim(),
      relativeTimeLabel: ((json['relativeTime'] as String?) ?? '').trim(),
      icon: ((json['icon'] as String?) ?? '').trim(),
      createdAt: createdAt,
    );
  }

  String get displayTimeLabel {
    if (relativeTimeLabel.isNotEmpty) return relativeTimeLabel;
    final d = createdAt;
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return '1 day ago';
    return '${diff.inDays} days ago';
  }
}

class CompanyDashboardData {
  const CompanyDashboardData({
    required this.companyName,
    required this.contactName,
    required this.phone,
    required this.activeJobs,
    required this.mechanics,
    required this.onlineMechanics,
    required this.monthRevenue,
    required this.monthRevenueChangePercent,
    required this.averageRating,
    required this.ratingReviewCount,
    required this.pendingInvites,
    required this.unassignedJobsCount,
    required this.recentActivity,
  });

  final String companyName;
  final String contactName;
  final String phone;
  final int activeJobs;
  final int mechanics;
  final int onlineMechanics;
  final int monthRevenue;
  final int monthRevenueChangePercent;
  final double averageRating;
  final int ratingReviewCount;
  final int pendingInvites;
  final int unassignedJobsCount;
  final List<CompanyRecentActivityRow> recentActivity;

  /// Assigned active jobs (`active − unassigned`, clamped to ≥ 0).
  int get assignedActiveJobs {
    if (activeJobs <= 0) return 0;
    final assigned = activeJobs - unassignedJobsCount;
    return assigned < 0 ? 0 : assigned;
  }

  static CompanyDashboardData? tryParse(dynamic root) {
    if (root is! Map<String, dynamic>) return null;
    Map<String, dynamic> data = root;
    if (root.containsKey('data')) {
      final inner = root['data'];
      if (inner is! Map<String, dynamic>) return null;
      data = inner;
    }
    final company = (data['company'] is Map<String, dynamic>)
        ? data['company'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final cards = (data['cards'] is Map<String, dynamic>)
        ? data['cards'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final quick = (data['quickActions'] is Map<String, dynamic>)
        ? data['quickActions'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final uaList = data['unassignedJobs'];
    int unassigned = (data['unassignedJobsCount'] as num?)?.toInt() ?? 0;
    if ((unassigned == 0 || data['unassignedJobsCount'] == null) && uaList is List<dynamic>) {
      unassigned = uaList.length;
    }

    final rawAct = data['recentActivity'];
    final activity = <CompanyRecentActivityRow>[];
    if (rawAct is List<dynamic>) {
      for (final e in rawAct) {
        if (e is Map<String, dynamic>) {
          activity.add(CompanyRecentActivityRow.fromJson(e));
        }
      }
    }

    return CompanyDashboardData(
      companyName: ((company['companyName'] as String?) ?? '').trim(),
      contactName: ((company['contactName'] as String?) ?? '').trim(),
      phone: ((company['phone'] as String?) ?? '').trim(),
      activeJobs: (cards['activeJobs'] as num?)?.toInt() ?? 0,
      mechanics: (cards['mechanics'] as num?)?.toInt() ?? 0,
      onlineMechanics: (cards['onlineMechanics'] as num?)?.toInt() ?? 0,
      monthRevenue: (cards['monthRevenue'] as num?)?.toInt() ?? 0,
      monthRevenueChangePercent: (cards['monthRevenueChangePercent'] as num?)?.toInt() ?? 0,
      averageRating: (cards['averageRating'] as num?)?.toDouble() ?? 0,
      ratingReviewCount: (cards['ratingReviewCount'] as num?)?.toInt() ?? 0,
      pendingInvites: (quick['pendingInvites'] as num?)?.toInt() ?? 0,
      unassignedJobsCount: unassigned,
      recentActivity: activity,
    );
  }
}

/// Formats whole-currency GBP revenue for dashboard cards (`18400` → `£18.4k`).
String formatCompanyMonthRevenueGbp(int amount) {
  if (amount.abs() >= 1000000) {
    final v = amount / 1000000;
    return '£${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1)}M';
  }
  if (amount.abs() >= 1000) {
    final k = amount / 1000;
    return '£${k.toStringAsFixed(k == k.roundToDouble() ? 0 : 1)}k';
  }
  return '£$amount';
}

// ─── Company job feed `/api/v1/company/feed` ────────────────────────────────

class CompanyFeedMeta {
  const CompanyFeedMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.activeCount,
  });

  final int page;
  final int limit;
  final int total;
  final int activeCount;

  static CompanyFeedMeta? maybeParse(Map<String, dynamic>? meta) {
    if (meta == null) return null;
    return CompanyFeedMeta(
      page: (meta['page'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? 20,
      total: (meta['total'] as num?)?.toInt() ?? 0,
      activeCount: (meta['activeCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class CompanyFeedJob {
  const CompanyFeedJob({
    required this.jobBackendId,
    required this.jobCode,
    required this.title,
    required this.description,
    required this.urgency,
    required this.vehicleLine,
    required this.locationAddress,
    required this.postedAgoLabel,
    this.fleetRating,
    this.distanceMiles,
    this.estimatedPayout,
    this.currency,
  });

  final String jobBackendId;
  final String jobCode;
  final String title;
  final String description;
  final String urgency;
  final String vehicleLine;
  final String locationAddress;
  final String postedAgoLabel;
  final double? fleetRating;
  final double? distanceMiles;
  final num? estimatedPayout;
  final String? currency;

  /// Card line under bold vehicle (`title`; falls back to `description`).
  String get subtitleLine =>
      title.isNotEmpty ? title : (description.isNotEmpty ? description : '—');

  String distanceMilesDisplay() {
    final d = distanceMiles;
    if (d == null) return '—';
    if (d == d.roundToDouble()) return '${d.round()} miles';
    return '${d.toStringAsFixed(1)} miles';
  }

  factory CompanyFeedJob.fromJson(Map<String, dynamic> j) {
    final vehicle = (j['vehicle'] is Map<String, dynamic>)
        ? j['vehicle'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final location = (j['location'] is Map<String, dynamic>)
        ? j['location'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final fleet = (j['fleet'] is Map<String, dynamic>)
        ? j['fleet'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final make = (vehicle['make'] as String?) ?? '';
    final model = (vehicle['model'] as String?) ?? '';
    final vehicleLine = [make, model].where((s) => s.trim().isNotEmpty).join(' ');

    double? dm;
    final dmRaw = j['distanceMiles'];
    if (dmRaw is num) dm = dmRaw.toDouble();

    double? rating;
    final rt = fleet['rating'];
    if (rt is num) rating = rt.toDouble();

    return CompanyFeedJob(
      jobBackendId: (j['_id'] as String?) ?? '',
      jobCode: (j['jobCode'] as String?) ?? '',
      title: ((j['title'] as String?) ?? '').trim(),
      description: ((j['description'] as String?) ?? '').trim(),
      urgency: ((j['urgency'] as String?) ?? 'MEDIUM').trim().toUpperCase(),
      vehicleLine: vehicleLine,
      locationAddress: ((location['address'] as String?) ?? '').trim(),
      postedAgoLabel: ((j['postedAgoLabel'] as String?) ?? '').trim(),
      fleetRating: rating,
      distanceMiles: dm,
      estimatedPayout: j['estimatedPayout'] as num?,
      currency: j['currency'] as String?,
    );
  }
}

// ─── ViewModel ──────────────────────────────────────────────────────────────

class CompanyViewModel extends ChangeNotifier {
  CompanyViewModel({AuthRepository? auth, CompanyApiService? api})
      : _auth = auth ?? ApiAuthRepository(),
        _api = api ?? CompanyApiService();

  final AuthRepository _auth;
  final CompanyApiService _api;

  String screen = 'company-dashboard';

  // My Quotes
  List<CompanyQuote> myQuotes = [];
  bool myQuotesLoading = false;
  String? myQuotesError;

  /// Company job feed (`/api/v1/company/feed`).
  List<CompanyFeedJob> feedJobs = [];
  CompanyFeedMeta? feedMeta;
  bool feedLoading = false;
  String? feedError;

  /// Company dashboard (`/api/v1/company/dashboard`).
  CompanyDashboardData? dashboard;
  bool dashboardLoading = false;
  String? dashboardError;

  int get jobsTabBadge =>
      dashboard == null ? 0 : dashboard!.unassignedJobsCount;

  void setScreen(String s) {
    screen = s;
    notifyListeners();
  }

  String get bottomResolved {
    if (screen == 'company-earnings' || screen == 'company-edit-profile') return 'company-profile';
    return screen;
  }

  Future<void> loadDashboard() async {
    dashboardLoading = true;
    dashboardError = null;
    notifyListeners();
    try {
      final session = await _auth.getSession();
      final token = session?.accessToken;
      if (token == null || token.isEmpty) throw Exception('Not authenticated');
      final body = await _api.fetchDashboard(accessToken: token);
      dashboard = CompanyDashboardData.tryParse(body);
      if (dashboard == null) throw Exception('Invalid dashboard response');
    } catch (e) {
      dashboardError = e.toString();
    } finally {
      dashboardLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCompanyFeed({int page = 1, int limit = 20}) async {
    feedLoading = true;
    feedError = null;
    notifyListeners();
    try {
      final session = await _auth.getSession();
      final token = session?.accessToken;
      if (token == null || token.isEmpty) throw Exception('Not authenticated');
      final body = await _api.fetchCompanyFeed(accessToken: token, page: page, limit: limit);
      final raw = body['data'];
      final rows = raw is List<dynamic>
          ? raw
              .whereType<Map<String, dynamic>>()
              .map(CompanyFeedJob.fromJson)
              .toList()
          : <CompanyFeedJob>[];
      feedJobs = rows;
      feedMeta =
          CompanyFeedMeta.maybeParse(body['meta'] is Map<String, dynamic> ? body['meta'] as Map<String, dynamic> : null);
    } catch (e) {
      feedError = e.toString();
    } finally {
      feedLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyQuotes() async {
    myQuotesLoading = true;
    myQuotesError = null;
    notifyListeners();
    try {
      final session = await _auth.getSession();
      final token = session?.accessToken;
      if (token == null || token.isEmpty) throw Exception('Not authenticated');
      final body = await _api.fetchMyQuotes(accessToken: token, limit: 100);
      final raw = (body['quotes'] is List)
          ? body['quotes'] as List<dynamic>
          : (body['data'] is List)
              ? body['data'] as List<dynamic>
              : <dynamic>[];
      myQuotes = raw
          .whereType<Map<String, dynamic>>()
          .map(CompanyQuote.fromJson)
          .toList();
    } catch (e) {
      myQuotesError = e.toString();
    } finally {
      myQuotesLoading = false;
      notifyListeners();
    }
  }
}
