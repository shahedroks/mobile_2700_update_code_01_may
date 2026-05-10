import '../../data/models/job_offer.dart';
import 'job_taxonomy.dart';

/// Help & support ticket categories (mirrors TruckFixFeatures / modals).
abstract final class HelpCategories {
  static const List<(String id, String label)> supportTopics = [
    ('payment', 'Payment & billing'),
    ('job', 'Job or quote issue'),
    ('account', 'Account verification'),
    ('safety', 'Safety concern'),
    ('other', 'Other'),
  ];
}

abstract final class JobCategories {
  static const List<String> postJobIssueHints = [
    'Engine / cooling',
    'Brakes / air system',
    'Tyres / wheels',
    'Electrical',
    'Recovery',
    'Other',
  ];

  /// Job category picker (`PostJob` / `check.tsx` — `JOB_TYPES`).
  static const List<(String emoji, String label)> postJobCategories = [
    ('🛞', 'Flat / Damaged Tyre'),
    ('🔋', 'Battery Failure / Jump Start'),
    ('🔑', "Engine Won't Start"),
    ('🚧', 'Breakdown (Unknown Issue)'),
    ('🌡️', 'Overheating'),
    ('🛑', 'Brake Problem'),
    ('⚡', 'Electrical Issue'),
    ('⛽', 'Fuel Issue (Wrong Fuel / Empty)'),
    ('🚛', 'Vehicle Recovery / Towing'),
    ('🔧', 'Diagnostic Check'),
    ('🔒', 'Locked Out of Vehicle'),
    ('📋', 'Other (Describe in Notes)'),
  ];

  /// `POST /jobs` `issueType` — backend expects SCREAMING_SNAKE enums (see job create response), not UI labels.
  static const Map<String, String> _apiIssueTypeByLabel = {
    'Flat / Damaged Tyre': 'TYRES',
    'Battery Failure / Jump Start': 'BATTERY_FAILURE_JUMP_START',
    "Engine Won't Start": 'ENGINE_WONT_START',
    'Breakdown (Unknown Issue)': 'BREAKDOWN_UNKNOWN',
    'Overheating': 'OVERHEATING',
    'Brake Problem': 'BRAKE_PROBLEM',
    'Electrical Issue': 'ELECTRICAL_ISSUE',
    'Fuel Issue (Wrong Fuel / Empty)': 'FUEL_ISSUE',
    'Vehicle Recovery / Towing': 'VEHICLE_RECOVERY',
    'Diagnostic Check': 'DIAGNOSTIC_CHECK',
    'Locked Out of Vehicle': 'LOCKED_OUT',
    'Other (Describe in Notes)': 'OTHER',
  };

  static String apiIssueTypeForLabel(String label) {
    final key = label.trim();
    if (key.isEmpty) return 'OTHER';
    return _apiIssueTypeByLabel[key] ?? 'OTHER';
  }
}

abstract final class JobFeedMock {
  static List<JobOffer> mechanicNearby() => [
        JobOffer(
          id: 'TF-8821',
          truck: 'Tautliner · CA 456-789',
          issue: 'Engine overheating — coolant leak suspected',
          distanceMi: 2.1,
          urgency: JobUrgency.high,
          pay: '£185',
          posted: '4 min ago',
          quotes: 2,
        ),
        JobOffer(
          id: 'TF-8823',
          truck: 'Rigid 8T · GP 331-876',
          issue: 'Complete electrical failure, hazard lights not working',
          distanceMi: 4.8,
          urgency: JobUrgency.critical,
          pay: '£240+',
          posted: '7 min ago',
          quotes: 0,
        ),
        JobOffer(
          id: 'TF-8818',
          truck: 'Tanker · KZN 44-221',
          issue: 'Air brake fault, vehicle stranded on motorway',
          distanceMi: 9.3,
          urgency: JobUrgency.critical,
          pay: '£310+',
          posted: '12 min ago',
          quotes: 1,
        ),
        JobOffer(
          id: 'TF-8809',
          truck: 'Flatbed · WC 678-123',
          issue: 'Right rear dual tyre blowout, need roadside change',
          distanceMi: 12.6,
          urgency: JobUrgency.medium,
          pay: '£95',
          posted: '28 min ago',
          quotes: 4,
        ),
        JobOffer(
          id: 'TF-8801',
          truck: 'Semi · NW 901-445',
          issue: 'Starter motor failure, vehicle won\'t crank',
          distanceMi: 14.2,
          urgency: JobUrgency.low,
          pay: '£120',
          posted: '1 hr ago',
          quotes: 6,
        ),
      ];
}
