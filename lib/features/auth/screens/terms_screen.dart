import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/buttons.dart';

const List<Map<String, String>> termsSections = [
  {'heading': '1. DEFINITIONS', 'body': '"Fleet Operator" means any business or person using the Platform to request roadside, breakdown, diagnostic, inspection, repair or related services for a commercial vehicle or fleet. "Mechanic" means any independent mechanic, workshop, engineer, technician or service provider offering services through the Platform. "Job" means any breakdown request, repair request, roadside assistance request, inspection, diagnostic, call-out, recovery coordination or related task arranged through the Platform. "Platform Fee" means the fee charged by TruckFix for use of the Platform.'},
  {'heading': '2. MARKETPLACE STATUS', 'body': 'TruckFix is a technology marketplace that introduces Fleet Operators to independent Mechanics. TruckFix does not itself provide repair, maintenance, diagnostic, roadside assistance, recovery, engineering or towing services. Any contract for the actual performance of mechanical or roadside services is between the Fleet Operator and the Mechanic. TruckFix does not guarantee that a Mechanic will be available, will attend within any estimated timeframe, that any diagnosis will be accurate, or that any quoted price will remain unchanged where the facts on site differ materially from the original job description.'},
  {'heading': '3. BUSINESS USE & ELIGIBILITY', 'body': 'The Platform is intended primarily for business use. By using the Platform, you confirm that: (a) you are at least 18 years old; (b) you have authority to bind the business you represent, if applicable; (c) all information you provide is accurate and up to date. TruckFix may require identity checks, business verification, VAT details, insurance documents, certifications, trade credentials, and bank details. You are responsible for all activity carried out through your account and for keeping login credentials secure.'},
  {'heading': '4. FLEET OPERATOR OBLIGATIONS', 'body': 'Fleet Operators must provide accurate and complete information about each Job, including vehicle registration and details, exact location, breakdown symptoms or service requirement, access limitations, safety risks, load or cargo issues, and contact details for the responsible person on site. The Fleet Operator is responsible for ensuring the vehicle is lawfully accessible and reasonably safe for attendance. The Fleet Operator must not submit false, misleading, incomplete or fraudulent Job requests.'},
  {'heading': '5. MECHANIC OBLIGATIONS', 'body': 'Mechanics must hold and maintain all licences, trade qualifications, insurance, registrations and consents required by law; provide truthful profile, pricing and availability information; perform services using reasonable skill and care; and comply with all applicable laws, health and safety requirements and industry standards. Mechanics are solely responsible for workmanship, labour, tools, staff, subcontractors, tax, VAT, National Insurance, insurance, warranties, and the legality and safety of their work.'},
  {'heading': '6. INDEPENDENT CONTRACTOR STATUS', 'body': 'Mechanics are independent contractors and are not employees, workers, agents, franchisees or partners of TruckFix. Nothing in these Terms creates an employment, worker, agency, partnership or joint venture relationship between TruckFix and any Mechanic. Mechanics have no authority to make statements, promises or commitments on behalf of TruckFix.'},
  {'heading': '7. QUOTES, ESTIMATES & JOB ACCEPTANCE' ,'body' : 'Quotes submitted through the Platform may be fixed prices or estimates. Unless expressly marked as fixed, a quote is an estimate only and may change if: (a) the original job information was inaccurate or incomplete; (b) additional faults are discovered; (c) extra labour, parts, mileage, waiting time or specialist equipment is required; (d) site, traffic, weather or access conditions differ materially from what was described. A Job is only confirmed once accepted through the Platform.'},
  {'heading': '8. PAYMENTS', 'body': 'TruckFix may use card pre-authorisation, deposits, staged capture, full upfront payment, delayed capture, payout holds, partial refunds and other payment controls. By using the Platform, you authorise TruckFix and its Payment Provider to process payments, pre-authorisations, reversals, refunds, split payments, payout holds and related transactions. TruckFix may deduct from amounts collected: the Platform Fee; payment processing charges; refunds, reversals and chargebacks; credits and promotional discounts; agreed penalties; and sums owed to TruckFix. TruckFix may hold, delay, reverse or offset Mechanic payouts where there is a dispute, chargeback, suspected fraud, missing completion evidence, non-compliance, or breach of these Terms.'},
  {'heading': '9. PLATFORM FEES', 'body': 'TruckFix charges a 12% platform fee on Jobs, unless a different fee or subscription arrangement is agreed in writing or displayed in the Platform. Fees may be charged to Mechanics, Fleet Operators, or both. TruckFix may amend its pricing structure by giving notice through the Platform or by email.'},
  {'heading': '10. INVOICING & VAT', 'body': 'Each User is responsible for its own tax affairs, VAT compliance and accounting treatment. Mechanics are responsible for ensuring that any invoice they issue through the Platform is legally correct. Where TruckFix charges its own Platform Fee, TruckFix will issue the relevant invoice for that fee. VAT will be handled as applicable under UK law.'},
  {'heading': '11. CANCELLATIONS. NO-SHOWS & ABORTED JOBS', 'body': 'TruckFix may charge cancellation, attendance, call-out, diagnostic, mileage, parts-restocking or waiting-time fees where a Job is cancelled after acceptance or where attendance has already begun. If the Fleet Operator provides the wrong location, fails to provide access, is unavailable, or materially misdescribes the Job, charges may still apply. If a Mechanic fails to attend or abandons a Job without lawful cause, TruckFix may cancel the Job, reassign it, suspend the Mechanic and/or refund the Fleet Operator.'},
  {'heading': '12. OFF-PLATFORM DEALING & FEE AVOIDANCE', 'body': 'If a Fleet Operator and a Mechanic are introduced through the Platform, neither party may cancel a Job on the Platform and complete that Job privately; accept off-platform payment for a Platform-introduced Job; renegotiate a lower price off-platform; or encourage any User to bypass the Platform. Such conduct constitutes a material breach of these Terms. TruckFix may immediately suspend or permanently terminate that Users account, withhold any payout, and charge the Platform Fee that would have applied. This restriction applies for 12 months from the date of introduction through the Platform.'},
  {'heading': '13. COMPLETION. COMPLAINTS & DISPUTES', 'body': 'The Fleet Operator must inspect the service outcome as soon as reasonably practicable. Any dispute relating to workmanship, price, unauthorised extras, attendance, no-show, cancellation or completion should be raised through the Platform within 72 hours of the Job being marked complete. TruckFix may request evidence including photographs, diagnostics, job notes, messages, invoices, parts details and attendance records. TruckFixs dispute process is an administrative marketplace process only.'},
  {'heading': '14.  REFUNDS & CHARGEBACKS', 'body': 'Refunds are not automatic and depend on the specific facts, including attendance, time spent, diagnostics completed, parts ordered, approval records and evidence of workmanship issues. If a Fleet Operator raises a card chargeback without first using TruckFixs dispute process, TruckFix may suspend the account and recover associated fees, administrative costs and losses where legally permitted.'},
  {'heading': '15. PROHIBITED CONDUCT', 'body': 'Users must not: use the Platform unlawfully or fraudulently; submit false Jobs, false quotes or false evidence; impersonate another person or business; misuse another Users contact details or personal data; solicit off-platform payment for Platform-generated Jobs; harass, threaten or abuse another User; upload malicious code or interfere with the Platform; scrape, copy or commercially exploit Platform content without permission; or post defamatory, infringing, obscene or unlawful content.'},
  {'heading': '16. VERIFICATION & NO ENDORSEMENT', 'body': 'TruckFix may review licences, insurance, identity documents and other onboarding materials, but does not guarantee their authenticity, completeness or ongoing validity. Profile badges, ratings, labels and "verified" markers are provided for convenience only and are not guarantees or warranties by TruckFix.'},
  {'heading': '17. REVIEWS & USER  CONTENT', 'body': 'You grant TruckFix a non-exclusive, worldwide, royalty-free licence to use, host, reproduce, display, adapt and publish content you submit for the purpose of operating, improving, protecting and promoting the Platform. TruckFix may remove, edit or moderate content at its discretion. You warrant that any content you submit is lawful and does not infringe any third-party rights.'},
  {'heading': '18. DATA PROTECTION & PRIVACY', 'body': 'TruckFix processes personal data in accordance with applicable UK data protection law, including the UK GDPR and the Data Protection Act 2018. TruckFix may collect and use personal data, business information, vehicle information, location data, communications, device data and payment metadata for purposes including account creation, job matching, fraud prevention, payment processing, complaints handling, customer support, legal compliance, and service improvement. TruckFix may share relevant data with Mechanics, Fleet Operators, payment processors, identity-check providers, insurers, professional advisers, IT providers and authorities where reasonably necessary.'},
  {'heading': '19. SAFETY & EMERGENCIES', 'body': 'TruckFix is a commercial coordination platform and does not replace emergency services. In any accident, medical emergency, fire, road traffic danger, crime, violent incident, fuel spill or other urgent safety event, Users must first contact the appropriate emergency services, including 999 or 112, before or alongside using the Platform. TruckFix does not guarantee response times, roadside safety or repair outcomes.'},
  {'heading': '20. INTELLECTUAL PROPERTY',  'body': 'All intellectual property rights in the Platform, including software, workflows, branding, logos, text, graphics, databases and designs, belong to TruckFix or its licensors. Users receive a limited, revocable, non-exclusive, non-transferable right to use the Platform for its intended business purpose. Users must not copy, reverse engineer, extract, resell, republish or otherwise exploit the Platform except as permitted by law or with TruckFixs written consent.'},
  {'heading': '21. PLATFORM AVAILABILITY',  'body': 'TruckFix does not guarantee uninterrupted or error-free access to the Platform. The Platform may be unavailable due to maintenance, updates, outages, network failures, third-party service issues, cyber incidents or events beyond our reasonable control. TruckFix is not liable for losses caused by technical downtime, mapping errors, delayed notifications, payment-provider outages, GPS inaccuracies or mobile/network failures.'},
  {'heading': '22.  DISCLAIMER',  'body': 'The Platform is provided on an "as is" and "as available" basis. To the fullest extent permitted by law, TruckFix gives no representation or warranty regarding Mechanic quality or fitness, Fleet Operator solvency or conduct, the legality, safety or quality of any repair or part, uninterrupted platform access, or the accuracy of user-generated information, ETAs, quotes or diagnostics. Nothing in these Terms excludes any statutory rights that cannot lawfully be excluded.'},
  {'heading': '23. LIMITATION OF LIABILITY',  'body': 'Nothing in these Terms excludes or limits liability for: death or personal injury caused by negligence; fraud or fraudulent misrepresentation; or any other liability which cannot lawfully be excluded. Subject to those exceptions, TruckFixs total aggregate liability arising out of any claim shall not exceed the greater of: the Platform Fees actually retained by TruckFix in relation to the relevant Job; or £2,500. TruckFix shall not be liable for loss of profit, revenue, business, contracts, goodwill, business interruption, loss of anticipated savings, or indirect or consequential loss.'},
  {'heading': '24. INDEMNITY',  'body': 'Each User shall indemnify TruckFix, its officers, employees and contractors against all claims, losses, liabilities, damages, costs and expenses arising out of or in connection with: that Users breach of these Terms; that Users unlawful, fraudulent or negligent act or omission; defective workmanship or unsafe work carried out by a Mechanic; inaccurate job information supplied by a Fleet Operator; tax, VAT, employment or regulatory non-compliance by that User; or infringement of a third partys rights by that User.'},
  {'heading': '25.  SUSPENSION & TERMINATION',  'body': 'TruckFix may suspend, restrict or terminate any account or Job immediately where we reasonably believe there is fraud or attempted fraud, a chargeback risk, abusive behaviour, a safety risk, failure of verification, breach of these Terms, a legal or regulatory concern, or reputational harm to the Platform. A User may stop using the Platform at any time, but remains liable for outstanding fees, disputes, reversals, claims and obligations accrued before closure.'},
  {'heading': '26. CHANGES TO THESE TERMS',  'body': 'TruckFix may amend these Terms from time to time. Updated Terms will be published in the Platform or on the website with a revised "Last updated" date. Continued use of the Platform after updated Terms take effect constitutes acceptance of the revised Terms.'},
  {'heading': '27. GOVERNING LAW & JURISDICTION',  'body': 'These Terms are governed by the laws of England and Wales. The courts of England and Wales shall have exclusive jurisdiction, except that TruckFix may seek urgent interim relief in any court of competent jurisdiction.'},
  {'heading': '28. CONTACT ',  'body': 'TruckFix Ltd — For legal enquiries: legal@truckfix.co.uk — For support queries please use the Help & Support section inside the app.'},

];

class TermsScreen extends StatelessWidget {
  const TermsScreen({
    super.key,
    required this.onNavigate,
    this.nextRoute = 'fleet-dashboard',
    this.buttonLabel = 'Accept & Enter TruckFix →',
  });

  final void Function(String) onNavigate;
  final String nextRoute;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return _TermsBody(onNavigate: onNavigate, nextRoute: nextRoute, buttonLabel: buttonLabel);
  }
}

class _TermsBody extends StatefulWidget {
  const _TermsBody({required this.onNavigate, required this.nextRoute, required this.buttonLabel});

  final void Function(String) onNavigate;
  final String nextRoute;
  final String buttonLabel;

  @override
  State<_TermsBody> createState() => _TermsBodyState();
}

class _TermsBodyState extends State<_TermsBody> {
  bool _accepted = false;
  bool _scrolledToBottom = false;
  final _scrollController = ScrollController();
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () {
        // Placeholder: hook up to your actual Terms route / webview later.
      };
    _privacyTap = TapGestureRecognizer()
      ..onTap = () {
        // Placeholder: hook up to your actual Privacy route / webview later.
      };
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.offset >= _scrollController.position.maxScrollExtent - 50) {
      if (!_scrolledToBottom) setState(() => _scrolledToBottom = true);
    }
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.description, size: 20, color: Colors.black),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ONE LAST STEP', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
                          Text('Terms & Conditions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _scrolledToBottom ? AppColors.successBg : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _scrolledToBottom ? AppColors.success : AppColors.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(_scrolledToBottom ? Icons.check : Icons.keyboard_arrow_down, size: 16, color: _scrolledToBottom ? AppColors.success : AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _scrolledToBottom ? 'All terms read — tick the box below to accept' : 'Scroll down to read all terms before accepting',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _scrolledToBottom ? AppColors.success : AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: termsSections.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TRUCKFIX TERMS AND CONDITIONS', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
                          SizedBox(height: 4),
                          Text('Last updated: 9 March 2026', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                          SizedBox(height: 8),
                          Text(
                            'These Terms govern access to and use of the TruckFix website, mobile application, platform and related services. The Platform is operated by TruckFix Ltd, a company registered in England and Wales. By creating an account, accessing the Platform, requesting services, quoting for jobs, accepting jobs, making payments, or otherwise using the Platform, you agree to these Terms. If you do not agree, you must not use the Platform.',
                            style: TextStyle(color: AppColors.textGray, fontSize: 12, height: 1.5),
                          ),
                        ],
                      ),
                    );
                  }
                  if (index == termsSections.length + 1) return const SizedBox(height: 12);
                  final section = termsSections[index - 1];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(section['heading']!, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
                        const SizedBox(height: 8),
                        Text(section['body']!, style: const TextStyle(color: AppColors.textGray, fontSize: 12, height: 1.5)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _scrolledToBottom ? setState(() => _accepted = !_accepted) : null,
                    child: Opacity(
                      opacity: _scrolledToBottom ? 1 : 0.35,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: _accepted ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: _accepted ? AppColors.primary : AppColors.borderLight, width: 2),
                            ),
                            child: _accepted ? const Icon(Icons.check, size: 12, color: Colors.black) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                                children: [
                                  const TextSpan(text: 'I have read and agree to the TruckFix '),
                                  TextSpan(
                                    text: 'Terms & Conditions  ',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    recognizer: _termsTap,
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    recognizer: _privacyTap,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: widget.buttonLabel,
                    onPressed: _accepted ? () => widget.onNavigate(widget.nextRoute) : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
