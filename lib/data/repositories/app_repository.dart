import '../models/fleet_job_summary.dart';
import '../models/job_offer.dart';
import '../models/mechanic_quote.dart';
import '../models/session.dart';
import '../models/team_member.dart';
import '../models/vehicle.dart';
import '../../core/constants/app_assets.dart';
import '../../features/categories/job_categories.dart';

abstract class AuthRepository {
  Future<Session?> getSession();
  Future<void> saveSession(Session session);
  Future<void> clearSession();
}

class MemoryAuthRepository implements AuthRepository {
  Session? _session;

  @override
  Future<void> clearSession() async {
    _session = null;
  }

  @override
  Future<Session?> getSession() async => _session;

  @override
  Future<void> saveSession(Session session) async {
    _session = session;
  }
}

abstract class JobRepository {
  List<JobOffer> mechanicJobsNearby();
  List<MechanicQuote> postedQuotes();
  List<FleetJobSummary> fleetActiveJobs();
  List<Vehicle> fleetVehicles();
  List<TeamMember> companyTeam();
}

class MemoryJobRepository implements JobRepository {
  @override
  List<TeamMember> companyTeam() => const [
        TeamMember(
          id: '1',
          name: 'James Cole',
          role: 'Lead Technician',
          email: 'james@swiftmechanics.co.uk',
          activeJobs: 2,
        ),
        TeamMember(
          id: '2',
          name: 'Alex Morgan',
          role: 'Roadside',
          email: 'alex@swiftmechanics.co.uk',
          activeJobs: 1,
        ),
      ];

  @override
  List<FleetJobSummary> fleetActiveJobs() => [
        FleetJobSummary(
          id: 'TF-8821',
          truck: 'Volvo FH · LD 882 TF',
          issue: 'Coolant leak · M6 northbound',
          status: 'EN ROUTE',
          urgency: 'HIGH',
          urgencyColorHex: 0xFFFB923C,
          urgencyBgHex: 0x33FB923C,
          statusColorHex: 0xFFFBBF24,
          statusBgHex: 0xFFFBBF24,
        ),
        FleetJobSummary(
          id: 'TF-8804',
          truck: 'Scania R450 · B12 XYZ',
          issue: 'Tyre replacement completed',
          status: 'ON SITE',
          urgency: 'MEDIUM',
          urgencyColorHex: 0xFFFBBF24,
          urgencyBgHex: 0x33FBBF24,
          statusColorHex: 0xFF4ADE80,
          statusBgHex: 0xFF4ADE80,
        ),
      ];

  @override
  List<Vehicle> fleetVehicles() => const [
        Vehicle(id: 'v1', label: 'Volvo FH16', plate: 'LD 882 TF', type: 'Tractor'),
        Vehicle(id: 'v2', label: 'Scania R450', plate: 'B12 XYZ', type: 'Tractor'),
        Vehicle(id: 'v3', label: 'Mercedes Actros', plate: 'KX19 ABC', type: 'Rigid'),
      ];

  @override
  List<JobOffer> mechanicJobsNearby() => JobFeedMock.mechanicNearby();

  @override
  List<MechanicQuote> postedQuotes() => [
        MechanicQuote(
          id: 'q1',
          name: 'James Mitchell',
          rating: 4.8,
          jobs: 211,
          verified: true,
          distance: '4.2 km',
          eta: '12 min',
          imageUrl: AppAssets.mechanicPortrait,
          labour: '£85',
          callout: '£35',
          parts: '£25',
          total: '£145',
          speciality: 'Tyres & Suspension',
          responded: '2 min ago',
        ),
        MechanicQuote(
          id: 'q2',
          name: 'Tom Stevens',
          rating: 4.7,
          jobs: 163,
          verified: true,
          distance: '7.8 km',
          eta: '22 min',
          imageUrl: AppAssets.mechanicPortrait,
          labour: '£80',
          callout: '£35',
          parts: '£20',
          total: '£135',
          speciality: 'Tyres & Axles',
          responded: '5 min ago',
        ),
        MechanicQuote(
          id: 'q3',
          name: 'Paul Davies',
          rating: 4.5,
          jobs: 98,
          verified: false,
          distance: '11 km',
          eta: '31 min',
          imageUrl: AppAssets.mechanicPortrait,
          labour: '£70',
          callout: '£30',
          parts: '£18',
          total: '£118',
          speciality: 'General HGV',
          responded: '9 min ago',
        ),
      ];
}
