/// Condensed from AuthFlow.tsx TERMS_SECTIONS — full legal text can be loaded remotely later.
class TermsSection {
  const TermsSection({required this.heading, required this.body});
  final String heading;
  final String body;
}

const String termsPreamble = 'These Terms govern access to and use of the TruckFix '
    'website, mobile application, platform and related services. The Platform is '
    'operated by TruckFix Ltd, a company registered in England and Wales.';

List<TermsSection> get fleetTermsSections => const [
      TermsSection(
        heading: '1. Definitions',
        body: '"Fleet Operator" means any business or person using the Platform to request '
            'roadside, breakdown, diagnostic, inspection, repair or related services for a '
            'commercial vehicle or fleet. "Mechanic" means any independent mechanic, workshop, '
            'engineer, technician or service provider offering services through the Platform.',
      ),
      TermsSection(
        heading: '2. Marketplace Status',
        body: 'TruckFix is a technology marketplace that introduces Fleet Operators to '
            'independent Mechanics. TruckFix does not itself provide repair, maintenance or '
            'towing services. Any contract for the actual performance of services is between '
            'the Fleet Operator and the Mechanic.',
      ),
      TermsSection(
        heading: '3. Quotes & Payments',
        body: 'Quotes may be estimates unless marked fixed. TruckFix may use card '
            'pre-authorisation, deposits and staged capture. A platform fee may apply.',
      ),
      TermsSection(
        heading: '4. Cancellations',
        body: 'Fees may apply where a Job is cancelled after acceptance or where attendance '
            'has begun, depending on the facts.',
      ),
      TermsSection(
        heading: '5. Governing Law',
        body: 'These Terms are governed by the laws of England and Wales.',
      ),
    ];
