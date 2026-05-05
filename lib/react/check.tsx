import React, { useState, useRef } from 'react';
import {
  Wrench, Eye, EyeOff, Check, Clock, ChevronRight, ChevronLeft,
  Truck, User, Shield, CheckCircle, Circle, AlertCircle, Phone,
  Mail, Lock, Building2, MapPin, Star, ArrowRight, Camera,
  DollarSign, Zap, Plus, ChevronDown, FileText, Briefcase, X, Info
} from 'lucide-react';

interface NavProps { onNavigate: (s: string) => void; }

function Input({ label, placeholder, type = 'text', icon }: any) {
  const [show, setShow] = useState(false);
  const isPass = type === 'password';
  return (
    <div className="space-y-1.5">
      {label && <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">{label}</label>}
      <div className="relative flex items-center">
        {icon && <div className="absolute left-3.5 text-gray-600">{icon}</div>}
        <input
          type={isPass && show ? 'text' : type}
          placeholder={placeholder}
          className={`w-full bg-[#111] border border-[#2a2a2a] rounded-xl py-3.5 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm transition-colors ${icon ? 'pl-10 pr-4' : 'px-4'}`}
        />
        {isPass && (
          <button onClick={() => setShow(!show)} className="absolute right-3.5 text-gray-600">
            {show ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
          </button>
        )}
      </div>
    </div>
  );
}

function Select({ label, options }: any) {
  return (
    <div className="space-y-1.5">
      {label && <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">{label}</label>}
      <select className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3.5 text-gray-400 focus:outline-none focus:border-yellow-400/60 text-sm appearance-none">
        {options.map((o: string) => <option key={o}>{o}</option>)}
      </select>
    </div>
  );
}

function PrimaryBtn({ children, onClick }: any) {
  return (
    <button onClick={onClick} className="w-full bg-yellow-400 text-black py-4 rounded-xl font-black text-sm tracking-widest uppercase active:scale-[0.98] transition-transform">
      {children}
    </button>
  );
}

function GhostBtn({ children, onClick }: any) {
  return (
    <button onClick={onClick} className="w-full border border-[#2a2a2a] text-gray-400 py-3.5 rounded-xl font-semibold text-sm tracking-wide hover:border-yellow-400/40 transition-colors">
      {children}
    </button>
  );
}

// ─── Splash ─────────────────────────────────────────────────────────────────────
function SplashScreen({ onNavigate }: NavProps) {
  return (
    <div className="h-full bg-[#080808] flex flex-col relative overflow-hidden">
      {/* Warning stripe bg */}
      <div className="absolute inset-0 opacity-[0.035]" style={{
        backgroundImage: 'repeating-linear-gradient(45deg, #FBBF24 0, #FBBF24 2px, transparent 0, transparent 28px)',
        backgroundSize: '40px 40px'
      }} />
      {/* Top glow */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[300px] h-[200px] bg-yellow-400 opacity-5 rounded-full blur-[80px]" />

      <div className="flex-1 flex flex-col items-center justify-center relative z-10 px-8">
        <div className="relative mb-8">
          <div className="absolute inset-0 bg-yellow-400 rounded-3xl blur-[20px] opacity-30" />
          <div className="relative w-24 h-24 bg-yellow-400 rounded-3xl flex items-center justify-center shadow-xl">
            <Wrench className="w-12 h-12 text-black" strokeWidth={2.5} />
          </div>
        </div>
        <h1 className="text-white font-black tracking-tight mb-1" style={{ fontSize: 52, lineHeight: 1 }}>
          TRUCK<span className="text-yellow-400">FIX</span>
        </h1>
        <div className="flex items-center gap-3 mb-6">
          <div className="h-px w-14 bg-yellow-400/50" />
          <span className="text-yellow-400 text-[11px] font-bold tracking-[4px] uppercase">Pro</span>
          <div className="h-px w-14 bg-yellow-400/50" />
        </div>
        <p className="text-gray-300 text-center text-[13px] leading-relaxed max-w-[260px]">
          Emergency breakdown assistance. Connect instantly with certified mechanics.
        </p>
      </div>

      <div className="relative z-10 px-8 pb-10 space-y-3">
        <PrimaryBtn onClick={() => onNavigate('login')}>
          Get Started <ArrowRight className="inline w-4 h-4 ml-1" />
        </PrimaryBtn>
        <button onClick={() => onNavigate('login')} className="w-full text-gray-400 text-sm py-2">
          Already registered?{' '}
          <span className="text-yellow-400 font-semibold">Login</span>
        </button>
      </div>
    </div>
  );
}

// ─── Terms ───────────────────────────────────────────────────────────────────────
const TERMS_SECTIONS = [
  { heading: '1. Definitions', body: '"Fleet Operator" means any business or person using the Platform to request roadside, breakdown, diagnostic, inspection, repair or related services for a commercial vehicle or fleet. "Mechanic" means any independent mechanic, workshop, engineer, technician or service provider offering services through the Platform. "Job" means any breakdown request, repair request, roadside assistance request, inspection, diagnostic, call-out, recovery coordination or related task arranged through the Platform. "Platform Fee" means the fee charged by TruckFix for use of the Platform.' },
  { heading: '2. Marketplace Status', body: 'TruckFix is a technology marketplace that introduces Fleet Operators to independent Mechanics. TruckFix does not itself provide repair, maintenance, diagnostic, roadside assistance, recovery, engineering or towing services. Any contract for the actual performance of mechanical or roadside services is between the Fleet Operator and the Mechanic. TruckFix does not guarantee that a Mechanic will be available, will attend within any estimated timeframe, that any diagnosis will be accurate, or that any quoted price will remain unchanged where the facts on site differ materially from the original job description.' },
  { heading: '3. Business Use & Eligibility', body: 'The Platform is intended primarily for business use. By using the Platform, you confirm that: (a) you are at least 18 years old; (b) you have authority to bind the business you represent, if applicable; (c) all information you provide is accurate and up to date. TruckFix may require identity checks, business verification, VAT details, insurance documents, certifications, trade credentials, and bank details. You are responsible for all activity carried out through your account and for keeping login credentials secure.' },
  { heading: '4. Fleet Operator Obligations', body: 'Fleet Operators must provide accurate and complete information about each Job, including vehicle registration and details, exact location, breakdown symptoms or service requirement, access limitations, safety risks, load or cargo issues, and contact details for the responsible person on site. The Fleet Operator is responsible for ensuring the vehicle is lawfully accessible and reasonably safe for attendance. The Fleet Operator must not submit false, misleading, incomplete or fraudulent Job requests.' },
  { heading: '5. Mechanic Obligations', body: 'Mechanics must hold and maintain all licences, trade qualifications, insurance, registrations and consents required by law; provide truthful profile, pricing and availability information; perform services using reasonable skill and care; and comply with all applicable laws, health and safety requirements and industry standards. Mechanics are solely responsible for workmanship, labour, tools, staff, subcontractors, tax, VAT, National Insurance, insurance, warranties, and the legality and safety of their work.' },
  { heading: '6. Independent Contractor Status', body: 'Mechanics are independent contractors and are not employees, workers, agents, franchisees or partners of TruckFix. Nothing in these Terms creates an employment, worker, agency, partnership or joint venture relationship between TruckFix and any Mechanic. Mechanics have no authority to make statements, promises or commitments on behalf of TruckFix.' },
  { heading: '7. Quotes, Estimates & Job Acceptance', body: 'Quotes submitted through the Platform may be fixed prices or estimates. Unless expressly marked as fixed, a quote is an estimate only and may change if: (a) the original job information was inaccurate or incomplete; (b) additional faults are discovered; (c) extra labour, parts, mileage, waiting time or specialist equipment is required; (d) site, traffic, weather or access conditions differ materially from what was described. A Job is only confirmed once accepted through the Platform.' },
  { heading: '8. Payments', body: 'TruckFix may use card pre-authorisation, deposits, staged capture, full upfront payment, delayed capture, payout holds, partial refunds and other payment controls. By using the Platform, you authorise TruckFix and its Payment Provider to process payments, pre-authorisations, reversals, refunds, split payments, payout holds and related transactions. TruckFix may deduct from amounts collected: the Platform Fee; payment processing charges; refunds, reversals and chargebacks; credits and promotional discounts; agreed penalties; and sums owed to TruckFix. TruckFix may hold, delay, reverse or offset Mechanic payouts where there is a dispute, chargeback, suspected fraud, missing completion evidence, non-compliance, or breach of these Terms.' },
  { heading: '9. Platform Fees', body: 'TruckFix charges a 12% platform fee on Jobs, unless a different fee or subscription arrangement is agreed in writing or displayed in the Platform. Fees may be charged to Mechanics, Fleet Operators, or both. TruckFix may amend its pricing structure by giving notice through the Platform or by email.' },
  { heading: '10. Invoicing & VAT', body: 'Each User is responsible for its own tax affairs, VAT compliance and accounting treatment. Mechanics are responsible for ensuring that any invoice they issue through the Platform is legally correct. Where TruckFix charges its own Platform Fee, TruckFix will issue the relevant invoice for that fee. VAT will be handled as applicable under UK law.' },
  { heading: '11. Cancellations, No-Shows & Aborted Jobs', body: 'TruckFix may charge cancellation, attendance, call-out, diagnostic, mileage, parts-restocking or waiting-time fees where a Job is cancelled after acceptance or where attendance has already begun. If the Fleet Operator provides the wrong location, fails to provide access, is unavailable, or materially misdescribes the Job, charges may still apply. If a Mechanic fails to attend or abandons a Job without lawful cause, TruckFix may cancel the Job, reassign it, suspend the Mechanic and/or refund the Fleet Operator.' },
  { heading: '12. Off-Platform Dealing & Fee Avoidance', body: 'If a Fleet Operator and a Mechanic are introduced through the Platform, neither party may cancel a Job on the Platform and complete that Job privately; accept off-platform payment for a Platform-introduced Job; renegotiate a lower price off-platform; or encourage any User to bypass the Platform. Such conduct constitutes a material breach of these Terms. TruckFix may immediately suspend or permanently terminate that User\'s account, withhold any payout, and charge the Platform Fee that would have applied. This restriction applies for 12 months from the date of introduction through the Platform.' },
  { heading: '13. Completion, Complaints & Disputes', body: 'The Fleet Operator must inspect the service outcome as soon as reasonably practicable. Any dispute relating to workmanship, price, unauthorised extras, attendance, no-show, cancellation or completion should be raised through the Platform within 72 hours of the Job being marked complete. TruckFix may request evidence including photographs, diagnostics, job notes, messages, invoices, parts details and attendance records. TruckFix\'s dispute process is an administrative marketplace process only.' },
  { heading: '14. Refunds & Chargebacks', body: 'Refunds are not automatic and depend on the specific facts, including attendance, time spent, diagnostics completed, parts ordered, approval records and evidence of workmanship issues. If a Fleet Operator raises a card chargeback without first using TruckFix\'s dispute process, TruckFix may suspend the account and recover associated fees, administrative costs and losses where legally permitted.' },
  { heading: '15. Prohibited Conduct', body: 'Users must not: use the Platform unlawfully or fraudulently; submit false Jobs, false quotes or false evidence; impersonate another person or business; misuse another User\'s contact details or personal data; solicit off-platform payment for Platform-generated Jobs; harass, threaten or abuse another User; upload malicious code or interfere with the Platform; scrape, copy or commercially exploit Platform content without permission; or post defamatory, infringing, obscene or unlawful content.' },
  { heading: '16. Verification & No Endorsement', body: 'TruckFix may review licences, insurance, identity documents and other onboarding materials, but does not guarantee their authenticity, completeness or ongoing validity. Profile badges, ratings, labels and "verified" markers are provided for convenience only and are not guarantees or warranties by TruckFix.' },
  { heading: '17. Reviews & User Content', body: 'You grant TruckFix a non-exclusive, worldwide, royalty-free licence to use, host, reproduce, display, adapt and publish content you submit for the purpose of operating, improving, protecting and promoting the Platform. TruckFix may remove, edit or moderate content at its discretion. You warrant that any content you submit is lawful and does not infringe any third-party rights.' },
  { heading: '18. Data Protection & Privacy', body: 'TruckFix processes personal data in accordance with applicable UK data protection law, including the UK GDPR and the Data Protection Act 2018. TruckFix may collect and use personal data, business information, vehicle information, location data, communications, device data and payment metadata for purposes including account creation, job matching, fraud prevention, payment processing, complaints handling, customer support, legal compliance, and service improvement. TruckFix may share relevant data with Mechanics, Fleet Operators, payment processors, identity-check providers, insurers, professional advisers, IT providers and authorities where reasonably necessary.' },
  { heading: '19. Safety & Emergencies', body: 'TruckFix is a commercial coordination platform and does not replace emergency services. In any accident, medical emergency, fire, road traffic danger, crime, violent incident, fuel spill or other urgent safety event, Users must first contact the appropriate emergency services, including 999 or 112, before or alongside using the Platform. TruckFix does not guarantee response times, roadside safety or repair outcomes.' },
  { heading: '20. Intellectual Property', body: 'All intellectual property rights in the Platform, including software, workflows, branding, logos, text, graphics, databases and designs, belong to TruckFix or its licensors. Users receive a limited, revocable, non-exclusive, non-transferable right to use the Platform for its intended business purpose. Users must not copy, reverse engineer, extract, resell, republish or otherwise exploit the Platform except as permitted by law or with TruckFix\'s written consent.' },
  { heading: '21. Platform Availability', body: 'TruckFix does not guarantee uninterrupted or error-free access to the Platform. The Platform may be unavailable due to maintenance, updates, outages, network failures, third-party service issues, cyber incidents or events beyond our reasonable control. TruckFix is not liable for losses caused by technical downtime, mapping errors, delayed notifications, payment-provider outages, GPS inaccuracies or mobile/network failures.' },
  { heading: '22. Disclaimer', body: 'The Platform is provided on an "as is" and "as available" basis. To the fullest extent permitted by law, TruckFix gives no representation or warranty regarding Mechanic quality or fitness, Fleet Operator solvency or conduct, the legality, safety or quality of any repair or part, uninterrupted platform access, or the accuracy of user-generated information, ETAs, quotes or diagnostics. Nothing in these Terms excludes any statutory rights that cannot lawfully be excluded.' },
  { heading: '23. Limitation of Liability', body: 'Nothing in these Terms excludes or limits liability for: death or personal injury caused by negligence; fraud or fraudulent misrepresentation; or any other liability which cannot lawfully be excluded. Subject to those exceptions, TruckFix\'s total aggregate liability arising out of any claim shall not exceed the greater of: the Platform Fees actually retained by TruckFix in relation to the relevant Job; or £2,500. TruckFix shall not be liable for loss of profit, revenue, business, contracts, goodwill, business interruption, loss of anticipated savings, or indirect or consequential loss.' },
  { heading: '24. Indemnity', body: 'Each User shall indemnify TruckFix, its officers, employees and contractors against all claims, losses, liabilities, damages, costs and expenses arising out of or in connection with: that User\'s breach of these Terms; that User\'s unlawful, fraudulent or negligent act or omission; defective workmanship or unsafe work carried out by a Mechanic; inaccurate job information supplied by a Fleet Operator; tax, VAT, employment or regulatory non-compliance by that User; or infringement of a third party\'s rights by that User.' },
  { heading: '25. Suspension & Termination', body: 'TruckFix may suspend, restrict or terminate any account or Job immediately where we reasonably believe there is fraud or attempted fraud, a chargeback risk, abusive behaviour, a safety risk, failure of verification, breach of these Terms, a legal or regulatory concern, or reputational harm to the Platform. A User may stop using the Platform at any time, but remains liable for outstanding fees, disputes, reversals, claims and obligations accrued before closure.' },
  { heading: '26. Changes to These Terms', body: 'TruckFix may amend these Terms from time to time. Updated Terms will be published in the Platform or on the website with a revised "Last updated" date. Continued use of the Platform after updated Terms take effect constitutes acceptance of the revised Terms.' },
  { heading: '27. Governing Law & Jurisdiction', body: 'These Terms are governed by the laws of England and Wales. The courts of England and Wales shall have exclusive jurisdiction, except that TruckFix may seek urgent interim relief in any court of competent jurisdiction.' },
  { heading: '28. Contact', body: 'TruckFix Ltd — For legal enquiries: legal@truckfix.co.uk — For support queries please use the Help & Support section inside the app.' },
];

function makeTermsScreen(next: string, btnLabel: string) {
  return function TermsScreen({ onNavigate }: NavProps) {
    const [accepted, setAccepted] = useState(false);
    const [scrolledToBottom, setScrolledToBottom] = useState(false);
    const scrollRef = useRef<HTMLDivElement>(null);

    const handleScroll = () => {
      const el = scrollRef.current;
      if (!el) return;
      if (el.scrollHeight - el.scrollTop - el.clientHeight < 50) setScrolledToBottom(true);
    };

    return (
      <div className="h-full bg-[#0a0a0a] flex flex-col">
        {/* Header */}
        <div className="px-5 pt-5 pb-3 border-b border-[#1a1a1a] flex-shrink-0">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-10 h-10 bg-yellow-400 rounded-xl flex items-center justify-center flex-shrink-0">
              <FileText className="w-5 h-5 text-black" />
            </div>
            <div>
              <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">One Last Step</p>
              <h2 className="text-white font-black text-base tracking-tight">Terms &amp; Conditions</h2>
            </div>
          </div>
          {/* Read-progress banner */}
          {!scrolledToBottom ? (
            <div className="flex items-center gap-2 px-3 py-2 bg-yellow-400/8 border border-yellow-400/25 rounded-xl">
              <ChevronDown className="w-4 h-4 text-yellow-400 flex-shrink-0 animate-bounce" />
              <p className="text-yellow-400 text-[11px] font-semibold">Scroll down to read all terms before accepting</p>
            </div>
          ) : (
            <div className="flex items-center gap-2 px-3 py-2 bg-green-400/8 border border-green-400/20 rounded-xl">
              <Check className="w-4 h-4 text-green-400 flex-shrink-0" strokeWidth={3} />
              <p className="text-green-400 text-[11px] font-semibold">All terms read — tick the box below to accept</p>
            </div>
          )}
        </div>

        {/* Scrollable T&C body */}
        <div
          ref={scrollRef}
          onScroll={handleScroll}
          className="flex-1 overflow-y-auto px-5 py-4 space-y-2"
          style={{ scrollbarWidth: 'none' }}
        >
          {/* Preamble */}
          <div className="bg-[#111] rounded-xl p-4 border border-[#1e1e1e]">
            <p className="text-yellow-400 text-[11px] font-black uppercase tracking-widest mb-1.5">TruckFix Terms and Conditions</p>
            <p className="text-gray-600 text-[10px] mb-2">Last updated: 9 March 2026</p>
            <p className="text-gray-300 text-[12px] leading-relaxed">These Terms govern access to and use of the TruckFix website, mobile application, platform and related services. The Platform is operated by TruckFix Ltd, a company registered in England and Wales. By creating an account, accessing the Platform, requesting services, quoting for jobs, accepting jobs, making payments, or otherwise using the Platform, you agree to these Terms. If you do not agree, you must not use the Platform.</p>
          </div>

          {TERMS_SECTIONS.map(({ heading, body }) => (
            <div key={heading} className="bg-[#111] rounded-xl p-4 border border-[#1e1e1e]">
              <p className="text-yellow-400 text-[11px] font-black uppercase tracking-widest mb-2">{heading}</p>
              <p className="text-gray-300 text-[12px] leading-relaxed">{body}</p>
            </div>
          ))}
          <div className="h-3" />
        </div>

        {/* Accept footer */}
        <div className="px-5 pt-4 pb-6 border-t border-[#1a1a1a] space-y-3 flex-shrink-0 bg-[#0a0a0a]">
          <button
            onClick={() => scrolledToBottom && setAccepted(!accepted)}
            className={`flex items-start gap-3 w-full transition-opacity ${scrolledToBottom ? 'opacity-100' : 'opacity-35 cursor-not-allowed'}`}
          >
            <div className={`w-5 h-5 rounded flex items-center justify-center border-2 transition-colors flex-shrink-0 mt-0.5 ${accepted ? 'bg-yellow-400 border-yellow-400' : 'border-[#444]'}`}>
              {accepted && <Check className="w-3 h-3 text-black" strokeWidth={3} />}
            </div>
            <span className="text-gray-300 text-[12px] text-left leading-snug">
              I have read and agree to the TruckFix <span className="text-yellow-400 font-semibold">Terms &amp; Conditions</span> and <span className="text-yellow-400 font-semibold">Privacy Policy</span>
            </span>
          </button>
          <button
            onClick={() => accepted && onNavigate(next)}
            className={`w-full py-4 rounded-xl font-black text-sm tracking-widest uppercase transition-all ${accepted ? 'bg-yellow-400 text-black active:scale-[0.98]' : 'bg-[#1a1a1a] text-gray-600 cursor-not-allowed'}`}
          >
            {btnLabel}
          </button>
        </div>
      </div>
    );
  };
}
const FleetTermsScreen   = makeTermsScreen('fleet-dashboard', 'Accept & Enter TruckFix →');
const MechanicTermsScreen = makeTermsScreen('pending', 'Accept & Submit Application');

// ─── Login ────────────────────────────────────────────────────────────────────────
function LoginScreen({ onNavigate }: NavProps) {
  return (
    <div className="h-full bg-[#0a0a0a] flex flex-col overflow-y-auto" style={{ scrollbarWidth: 'none' }}>
      <div className="flex-1 flex flex-col justify-center px-7 py-8">

        {/* ── Centred logo block ── */}
        <div className="flex flex-col items-center mb-10">
          <div className="relative mb-4">
            <div className="absolute inset-0 bg-yellow-400 rounded-2xl blur-[18px] opacity-25" />
            <div className="relative w-16 h-16 bg-yellow-400 rounded-2xl flex items-center justify-center shadow-xl">
              <Wrench className="w-8 h-8 text-black" strokeWidth={2.5} />
            </div>
          </div>
          <h1 className="text-white font-black tracking-tight" style={{ fontSize: 38, letterSpacing: 2 }}>
            TRUCK<span className="text-yellow-400">FIX</span>
          </h1>
        </div>

        {/* ── Fields ── */}
        <div className="space-y-4">
          <Input label="Email Address" placeholder="driver@fleetco.co.za" type="email" icon={<Mail className="w-4 h-4" />} />
          <Input label="Password" placeholder="••••••••••" type="password" icon={<Lock className="w-4 h-4" />} />

          <div className="pt-2">
            <PrimaryBtn onClick={() => onNavigate('fleet-dashboard')}>Sign In to TruckFix</PrimaryBtn>
          </div>
        </div>
      </div>

      {/* ── Footer links ── */}
      <div className="px-7 pb-10 flex flex-col items-center gap-3">
        <div className="h-px w-full bg-[#1a1a1a]" />
        <div className="flex items-center gap-1.5 pt-1">
          <span className="text-gray-600 text-[13px]">New to TruckFix?</span>
          <button
            onClick={() => onNavigate('role-select')}
            className="text-yellow-400 text-[13px] font-semibold"
          >
            Create Account
          </button>
        </div>
        <button className="text-gray-600 text-[12px] hover:text-yellow-400 transition-colors">
          Forgot password?
        </button>
      </div>
    </div>
  );
}

// ─── Role Select ────────────────────────────────────────────────────────────────
function RoleSelectScreen({ onNavigate }: NavProps) {
  const [selected, setSelected] = useState<string | null>(null);
  return (
    <div className="h-full bg-[#0a0a0a] flex flex-col overflow-y-auto px-6 py-8" style={{ scrollbarWidth: 'none' }}>
      <button onClick={() => onNavigate('login')} className="flex items-center gap-1.5 text-gray-600 text-[12px] mb-8">
        <ChevronLeft className="w-4 h-4" /> Back to Login
      </button>

      <h2 className="text-white font-black text-2xl mb-2 tracking-tight">Who are you?</h2>
      <p className="text-gray-600 text-[13px] mb-8">Select your account type to get started</p>

      <div className="space-y-4">
        {[
          {
            id: 'fleet',
            icon: Truck,
            title: 'Fleet Operator',
            subtitle: 'Manage vehicles & request breakdown assistance',
            perks: ['Post breakdown jobs', 'Track repairs live', 'Full service history & invoices'],
            next: 'fleet-register',
          },
          {
            id: 'mechanic',
            icon: Wrench,
            title: 'Service Provider',
            subtitle: 'Mechanics, technicians & service companies',
            perks: ['Browse nearby jobs', 'Submit competitive quotes', 'Get paid instantly'],
            next: 'mechanic-register',
          },
        ].map(({ id, icon: Icon, title, subtitle, perks, next }) => {
          const active = selected === id;
          return (
            <button
              key={id}
              onClick={() => setSelected(id)}
              className={`w-full text-left rounded-2xl p-5 border-2 transition-all ${active ? 'border-yellow-400 bg-yellow-400/5' : 'border-[#1e1e1e] bg-[#0f0f0f]'}`}
            >
              <div className="flex items-start justify-between mb-3">
                <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${active ? 'bg-yellow-400' : 'bg-[#1a1a1a]'}`}>
                  <Icon className={`w-6 h-6 ${active ? 'text-black' : 'text-gray-500'}`} strokeWidth={2} />
                </div>
                <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center transition-colors ${active ? 'border-yellow-400 bg-yellow-400' : 'border-[#333]'}`}>
                  {active && <Check className="w-3 h-3 text-black" strokeWidth={3} />}
                </div>
              </div>
              <p className={`font-black text-base mb-0.5 ${active ? 'text-white' : 'text-gray-300'}`}>{title}</p>
              <p className="text-gray-600 text-[11px] mb-3">{subtitle}</p>
              <div className="space-y-1">
                {perks.map(p => (
                  <div key={p} className="flex items-center gap-2">
                    <div className={`w-1.5 h-1.5 rounded-full ${active ? 'bg-yellow-400' : 'bg-[#333]'}`} />
                    <span className="text-[11px] text-gray-500">{p}</span>
                  </div>
                ))}
              </div>
            </button>
          );
        })}
      </div>

      <div className="mt-8">
        <PrimaryBtn onClick={() => selected && onNavigate(selected === 'fleet' ? 'fleet-register' : 'mechanic-register')}>
          Continue as {selected === 'fleet' ? 'Fleet Operator' : selected === 'mechanic' ? 'Mechanic' : '...'}
        </PrimaryBtn>
      </div>
    </div>
  );
}

// ─── Fleet Register ──────────────────────────────────────────────────────────────
function FleetRegisterScreen({ onNavigate }: NavProps) {
  const [showPass, setShowPass] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');

  const bothFilled = password.length > 0 && confirm.length > 0;
  const matches = password === confirm;
  const canSubmit = password.length >= 1 && matches;

  return (
    <div className="h-full bg-[#0a0a0a] flex flex-col">
      {/* Header */}
      <div className="px-6 pt-5 pb-5 border-b border-[#1a1a1a] flex-shrink-0">
        <button onClick={() => onNavigate('role-select')} className="flex items-center gap-1.5 text-gray-600 text-[12px] mb-4">
          <ChevronLeft className="w-4 h-4" /> Back
        </button>
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-yellow-400 rounded-xl flex items-center justify-center">
            <Truck className="w-5 h-5 text-black" strokeWidth={2.5} />
          </div>
          <div>
            <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-0.5">Fleet Operator</p>
            <h2 className="text-white font-black text-lg tracking-tight">Create Account</h2>
          </div>
        </div>
      </div>

      {/* Fields */}
      <div className="flex-1 overflow-y-auto px-6 py-6 space-y-4" style={{ scrollbarWidth: 'none' }}>
        <Input
          label="Company Name"
          placeholder="Logistix Transport (Pty) Ltd"
          icon={<Building2 className="w-4 h-4" />}
        />
        <Input
          label="Full Name"
          placeholder="John Khumalo"
          icon={<User className="w-4 h-4" />}
        />
        <Input
          label="Email Address"
          placeholder="john@logistix.co.za"
          type="email"
          icon={<Mail className="w-4 h-4" />}
        />

        {/* Password */}
        <div className="space-y-1.5">
          <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Password</label>
          <div className="relative flex items-center">
            <div className="absolute left-3.5 text-gray-600"><Lock className="w-4 h-4" /></div>
            <input
              type={showPass ? 'text' : 'password'}
              value={password}
              onChange={e => setPassword(e.target.value)}
              placeholder="Create a strong password"
              className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl py-3.5 pl-10 pr-11 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm transition-colors"
            />
            <button onClick={() => setShowPass(!showPass)} className="absolute right-3.5 text-gray-600">
              {showPass ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
            </button>
          </div>
        </div>

        {/* Confirm Password */}
        <div className="space-y-1.5">
          <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Confirm Password</label>
          <div className={`relative flex items-center rounded-xl transition-all ${bothFilled ? (matches ? 'ring-1 ring-green-400/40' : 'ring-1 ring-red-400/40') : ''}`}>
            <div className="absolute left-3.5 text-gray-600"><Lock className="w-4 h-4" /></div>
            <input
              type={showConfirm ? 'text' : 'password'}
              value={confirm}
              onChange={e => setConfirm(e.target.value)}
              placeholder="Re-enter your password"
              className={`w-full bg-[#111] border rounded-xl py-3.5 pl-10 pr-11 text-white placeholder:text-gray-700 focus:outline-none text-sm transition-colors ${
                bothFilled
                  ? matches
                    ? 'border-green-400/50 focus:border-green-400/70'
                    : 'border-red-400/50 focus:border-red-400/70'
                  : 'border-[#2a2a2a] focus:border-yellow-400/60'
              }`}
            />
            <button onClick={() => setShowConfirm(!showConfirm)} className="absolute right-3.5 text-gray-600">
              {showConfirm ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
            </button>
          </div>
          {bothFilled && (
            <p className={`text-[10px] font-semibold flex items-center gap-1 ${matches ? 'text-green-400' : 'text-red-400'}`}>
              {matches
                ? <><Check className="w-3 h-3" strokeWidth={3} /> Passwords match</>
                : <>✕ Passwords don't match</>
              }
            </p>
          )}
        </div>
      </div>

      {/* Footer */}
      <div className="px-6 pb-8 pt-3 border-t border-[#1a1a1a] flex-shrink-0 space-y-3">
        <button
          onClick={() => onNavigate('terms')}
          className="w-full py-4 rounded-xl font-black text-sm tracking-widest uppercase bg-yellow-400 text-black active:scale-[0.98] transition-transform"
        >
          Create Account →
        </button>
        <p className="text-center text-gray-600 text-[11px]">
          Already registered?{' '}
          <button onClick={() => onNavigate('login')} className="text-yellow-400 font-semibold">Sign in</button>
        </p>
      </div>
    </div>
  );
}

// ─── Mechanic Register ────────────────────────────────────────────────────────────
function MechanicRegisterScreen({ onNavigate }: NavProps) {
  const [avatar, setAvatar] = useState<string | null>(null);
  const [radius, setRadius] = useState(30);
  const [showPass, setShowPass] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [businessType, setBusinessType] = useState<'sole-trader' | 'company'>('sole-trader');
  const [mechanicEmails, setMechanicEmails] = useState<string[]>(['']);
  const fileRef = useRef<HTMLInputElement>(null);

  const handleAvatar = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const url = URL.createObjectURL(file);
      setAvatar(url);
    }
  };

  const radiusLabel = radius <= 5 ? 'Local (≤5 mi)' : radius <= 15 ? 'Town / City' : radius <= 30 ? 'Regional' : radius <= 50 ? 'Wide Area' : 'Nationwide';
  const bothFilled = password.length > 0 && confirm.length > 0;
  const matches = password === confirm;
  const canSubmit = password.length >= 1 && matches;

  const addMechanicEmail = () => {
    setMechanicEmails([...mechanicEmails, '']);
  };

  const removeMechanicEmail = (index: number) => {
    setMechanicEmails(mechanicEmails.filter((_, i) => i !== index));
  };

  const updateMechanicEmail = (index: number, value: string) => {
    const updated = [...mechanicEmails];
    updated[index] = value;
    setMechanicEmails(updated);
  };

  return (
    <div className="h-full bg-[#0a0a0a] flex flex-col">
      {/* Header */}
      <div className="px-6 pt-5 pb-4 border-b border-[#1a1a1a] flex-shrink-0">
        <button onClick={() => onNavigate('role-select')} className="flex items-center gap-1.5 text-gray-600 text-[12px] mb-4">
          <ChevronLeft className="w-4 h-4" /> Back
        </button>
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-yellow-400 rounded-xl flex items-center justify-center">
            <Wrench className="w-5 h-5 text-black" strokeWidth={2.5} />
          </div>
          <div>
            <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-0.5">Service Provider</p>
            <h2 className="text-white font-black text-lg tracking-tight">Create Account</h2>
          </div>
        </div>
      </div>

      {/* Scrollable form body */}
      <div className="flex-1 overflow-y-auto px-6 py-5 space-y-6" style={{ scrollbarWidth: 'none' }}>

        {/* ── Business Type Selection ── */}
        <div className="space-y-3">
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Business Type</p>
          <div className="grid grid-cols-2 gap-2.5">
            <button
              onClick={() => setBusinessType('sole-trader')}
              className={`p-4 rounded-xl border-2 transition-all ${
                businessType === 'sole-trader'
                  ? 'border-yellow-400 bg-yellow-400/5'
                  : 'border-[#2a2a2a] bg-[#111] hover:border-[#3a3a3a]'
              }`}
            >
              <div className="flex flex-col items-center gap-2">
                <User className={`w-6 h-6 ${businessType === 'sole-trader' ? 'text-yellow-400' : 'text-gray-600'}`} />
                <div className="text-center">
                  <p className={`text-[11px] font-black ${businessType === 'sole-trader' ? 'text-yellow-400' : 'text-white'}`}>
                    Sole Trader
                  </p>
                  <p className="text-gray-600 text-[9px] mt-0.5">Working alone</p>
                </div>
              </div>
            </button>
            <button
              onClick={() => setBusinessType('company')}
              className={`p-4 rounded-xl border-2 transition-all ${
                businessType === 'company'
                  ? 'border-yellow-400 bg-yellow-400/5'
                  : 'border-[#2a2a2a] bg-[#111] hover:border-[#3a3a3a]'
              }`}
            >
              <div className="flex flex-col items-center gap-2">
                <Building2 className={`w-6 h-6 ${businessType === 'company' ? 'text-yellow-400' : 'text-gray-600'}`} />
                <div className="text-center">
                  <p className={`text-[11px] font-black ${businessType === 'company' ? 'text-yellow-400' : 'text-white'}`}>
                    Company
                  </p>
                  <p className="text-gray-600 text-[9px] mt-0.5">Multiple mechanics</p>
                </div>
              </div>
            </button>
          </div>
          <div className={`p-3 rounded-xl border transition-all ${
            businessType === 'company' 
              ? 'bg-green-400/5 border-green-400/20' 
              : 'bg-[#111] border-[#1e1e1e]'
          }`}>
            <p className="text-gray-400 text-[10px] leading-relaxed">
              {businessType === 'sole-trader' 
                ? '✓ You work alone and manage all jobs yourself. You\'ll see all financial information and job details.'
                : '✓ You can add multiple mechanics to your team. You\'ll manage finances while mechanics only see their assigned jobs.'
              }
            </p>
          </div>
        </div>

        {/* ── Profile Photo ── */}
        <div className="flex flex-col items-center">
          <input ref={fileRef} type="file" accept="image/*" className="hidden" onChange={handleAvatar} />
          <button
            onClick={() => fileRef.current?.click()}
            className="relative group"
          >
            <div className={`w-20 h-20 rounded-2xl border-2 border-dashed flex items-center justify-center overflow-hidden transition-colors ${avatar ? 'border-yellow-400/60' : 'border-[#2a2a2a] hover:border-yellow-400/40'}`}>
              {avatar ? (
                <img src={avatar} alt="Profile" className="w-full h-full object-cover" />
              ) : (
                <div className="flex flex-col items-center gap-1.5">
                  <Camera className="w-6 h-6 text-gray-600 group-hover:text-yellow-400/60 transition-colors" />
                  <span className="text-gray-700 text-[9px] font-semibold tracking-wide">PHOTO</span>
                </div>
              )}
            </div>
            {/* Edit badge */}
            <div className="absolute -bottom-1.5 -right-1.5 w-6 h-6 bg-yellow-400 rounded-full flex items-center justify-center border-2 border-[#0a0a0a]">
              <Plus className="w-3 h-3 text-black" strokeWidth={3} />
            </div>
          </button>
          <p className="text-gray-700 text-[10px] mt-3 tracking-wide">
            {businessType === 'company' ? 'Company logo' : 'Profile photo'} <span className="text-gray-600">(optional)</span>
          </p>
        </div>

        {/* ── Personal/Company Info ── */}
        <div className="space-y-3">
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">
            {businessType === 'company' ? 'Company Info' : 'Personal Info'}
          </p>
          {businessType === 'company' ? (
            <>
              <Input
                label="Company Name"
                placeholder="TechMech Workshop Ltd"
                icon={<Building2 className="w-4 h-4" />}
              />
              <Input
                label="Trading Name (if different)"
                placeholder="e.g. FastFix Mobile Mechanics"
                icon={<Briefcase className="w-4 h-4" />}
              />
              <Input
                label="Your Name (Owner/Manager)"
                placeholder="James Mitchell"
                icon={<User className="w-4 h-4" />}
              />
            </>
          ) : (
            <Input
              label="Full Name"
              placeholder="James Mitchell"
              icon={<User className="w-4 h-4" />}
            />
          )}
          <Input
            label="Email Address"
            placeholder="james@fixmobile.co.uk"
            type="email"
            icon={<Mail className="w-4 h-4" />}
          />
          <Input
            label="Phone Number"
            placeholder="+44 7700 900 000"
            type="tel"
            icon={<Phone className="w-4 h-4" />}
          />
        </div>

        {/* ── Rates ── */}
        <div className="space-y-3">
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Rates (£ GBP)</p>

          {/* Call-out charge */}
          <div className="space-y-1.5">
            <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Call-out Charge</label>
            <div className="relative flex items-center">
              <div className="absolute left-3.5 text-gray-600"><DollarSign className="w-4 h-4" /></div>
              <span className="absolute left-9 text-gray-500 text-sm font-semibold">£</span>
              <input
                type="number"
                defaultValue="85"
                placeholder="85"
                className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl py-3.5 pl-14 pr-4 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm font-semibold transition-colors"
              />
            </div>
          </div>

          {/* Hourly charge */}
          <div className="space-y-1.5">
            <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Hourly Rate</label>
            <div className="relative flex items-center">
              <div className="absolute left-3.5 text-gray-600"><DollarSign className="w-4 h-4" /></div>
              <span className="absolute left-9 text-gray-500 text-sm font-semibold">£</span>
              <input
                type="number"
                defaultValue="65"
                placeholder="65"
                className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl py-3.5 pl-14 pr-4 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm font-semibold transition-colors"
              />
              <span className="absolute right-4 text-gray-600 text-[11px]">/ hr</span>
            </div>
          </div>

          {/* Emergency extra */}
          <div className="space-y-1.5">
            <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold flex items-center gap-1.5">
              Emergency Surcharge
              <span className="px-1.5 py-0.5 bg-red-400/10 border border-red-400/30 rounded text-red-400 text-[8px] font-black normal-case tracking-normal">CRITICAL JOBS</span>
            </label>
            <div className="relative flex items-center">
              <div className="absolute left-3.5 text-red-400/70"><Zap className="w-4 h-4" /></div>
              <span className="absolute left-9 text-gray-500 text-sm font-semibold">+£</span>
              <input
                type="number"
                defaultValue="45"
                placeholder="45"
                className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl py-3.5 pl-14 pr-4 text-white placeholder:text-gray-700 focus:outline-none focus:border-red-400/30 text-sm font-semibold transition-colors"
              />
              <span className="absolute right-4 text-gray-600 text-[11px]">flat</span>
            </div>
            <p className="text-gray-700 text-[10px]">Added automatically on CRITICAL urgency jobs</p>
          </div>
        </div>

        {/* ── Service Area ── */}
        <div className="space-y-3">
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Service Area</p>

          {/* Base postcode */}
          <div className="space-y-1.5">
            <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Base Postcode</label>
            <div className="relative flex items-center">
              <div className="absolute left-3.5 text-gray-600"><MapPin className="w-4 h-4" /></div>
              <input
                type="text"
                placeholder="e.g. M1 1AE"
                maxLength={10}
                className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl py-3.5 pl-10 pr-4 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm font-semibold tracking-widest transition-colors"
              />
            </div>
            <p className="text-gray-700 text-[10px]">Jobs within your radius are measured from this postcode</p>
          </div>

          {/* Radius slider */}
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Coverage Radius</label>
              <div className="flex items-center gap-1.5">
                <span className="text-white font-black text-sm">{radius} mi</span>
                <span className="text-gray-600 text-[10px]">· {radiusLabel}</span>
              </div>
            </div>
            <div className="bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-4">
              <input
                type="range"
                min={5}
                max={100}
                step={5}
                value={radius}
                onChange={e => setRadius(Number(e.target.value))}
                className="w-full cursor-pointer" style={{ accentColor: '#FBBF24' }}
              />
              <div className="flex justify-between mt-2">
                {['5 mi', '25 mi', '50 mi', '75 mi', '100 mi'].map(l => (
                  <span key={l} className="text-gray-700 text-[9px]">{l}</span>
                ))}
              </div>
            </div>
            <div className="flex gap-2">
              {[5, 15, 30, 60].map(r => (
                <button
                  key={r}
                  onClick={() => setRadius(r)}
                  className={`flex-1 py-2 rounded-lg border text-[10px] font-semibold transition-colors ${radius === r ? 'border-yellow-400 bg-yellow-400/10 text-yellow-400' : 'border-[#1e1e1e] text-gray-600'}`}
                >
                  {r} mi
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* ── Add Mechanics (Company Only) ── */}
        {businessType === 'company' && (
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Team Mechanics</p>
              <div className="px-2 py-1 bg-green-400/10 border border-green-400/30 rounded text-green-400 text-[8px] font-black">
                OPTIONAL
              </div>
            </div>
            
            <div className="p-3 rounded-xl bg-[#111] border border-[#1e1e1e]">
              <p className="text-gray-400 text-[10px] leading-relaxed mb-2">
                Add email addresses for each mechanic in your team. They'll receive login invitations to create their own accounts. Each mechanic will only see jobs assigned to them and won't have access to financial information.
              </p>
            </div>

            <div className="space-y-2.5">
              {mechanicEmails.map((email, index) => (
                <div key={index} className="flex items-center gap-2">
                  <div className="flex-1 relative">
                    <div className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-600">
                      <Mail className="w-4 h-4" />
                    </div>
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => updateMechanicEmail(index, e.target.value)}
                      placeholder={`mechanic${index + 1}@workshop.com`}
                      className="w-full bg-[#0f0f0f] border border-[#2a2a2a] rounded-xl py-3 pl-10 pr-4 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm transition-colors"
                    />
                  </div>
                  {mechanicEmails.length > 1 && (
                    <button
                      onClick={() => removeMechanicEmail(index)}
                      className="w-10 h-10 rounded-xl bg-[#0f0f0f] border border-[#2a2a2a] flex items-center justify-center text-red-400 hover:border-red-400/40 hover:bg-red-400/5 transition-all"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  )}
                </div>
              ))}
            </div>

            <button
              onClick={addMechanicEmail}
              className="w-full py-3 rounded-xl border-2 border-dashed border-[#2a2a2a] hover:border-yellow-400/40 text-gray-500 hover:text-yellow-400 text-[11px] font-bold uppercase tracking-widest transition-all flex items-center justify-center gap-2"
            >
              <Plus className="w-4 h-4" />
              Add Another Mechanic
            </button>

            <div className="flex items-start gap-2 p-3 rounded-xl bg-blue-400/5 border border-blue-400/20">
              <Info className="w-4 h-4 text-blue-400 flex-shrink-0 mt-0.5" />
              <p className="text-blue-400 text-[10px] leading-relaxed">
                You can also add mechanics later from your company profile settings. Invitations will be sent after admin approval.
              </p>
            </div>
          </div>
        )}

        {/* ── Security ── */}
        <div className="space-y-3">
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Security</p>

          {/* Password */}
          <div className="space-y-1.5">
            <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Password</label>
            <div className="relative flex items-center">
              <div className="absolute left-3.5 text-gray-600"><Lock className="w-4 h-4" /></div>
              <input
                type={showPass ? 'text' : 'password'}
                value={password}
                onChange={e => setPassword(e.target.value)}
                placeholder="Create a strong password"
                className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl py-3.5 pl-10 pr-11 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm transition-colors"
              />
              <button onClick={() => setShowPass(!showPass)} className="absolute right-3.5 text-gray-600">
                {showPass ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
          </div>

          {/* Confirm Password */}
          <div className="space-y-1.5">
            <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Confirm Password</label>
            <div className="relative flex items-center">
              <div className="absolute left-3.5 text-gray-600"><Lock className="w-4 h-4" /></div>
              <input
                type={showConfirm ? 'text' : 'password'}
                value={confirm}
                onChange={e => setConfirm(e.target.value)}
                placeholder="Re-enter your password"
                className={`w-full bg-[#111] border rounded-xl py-3.5 pl-10 pr-11 text-white placeholder:text-gray-700 focus:outline-none text-sm transition-colors ${
                  bothFilled
                    ? matches
                      ? 'border-green-400/50 focus:border-green-400/70'
                      : 'border-red-400/50 focus:border-red-400/70'
                    : 'border-[#2a2a2a] focus:border-yellow-400/60'
                }`}
              />
              <button onClick={() => setShowConfirm(!showConfirm)} className="absolute right-3.5 text-gray-600">
                {showConfirm ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
            {bothFilled && (
              <p className={`text-[10px] font-semibold flex items-center gap-1 ${matches ? 'text-green-400' : 'text-red-400'}`}>
                {matches
                  ? <><Check className="w-3 h-3" strokeWidth={3} /> Passwords match</>
                  : <>✕ Passwords don't match</>
                }
              </p>
            )}
          </div>
        </div>

        <div className="h-2" />
      </div>

      {/* Footer CTA */}
      <div className="px-6 pb-8 pt-3 border-t border-[#1a1a1a] flex-shrink-0 space-y-3">
        <button
          onClick={() => onNavigate('mechanic-terms')}
          className="w-full py-4 rounded-xl font-black text-sm tracking-widest uppercase bg-yellow-400 text-black active:scale-[0.98] transition-transform"
        >
          Create Account →
        </button>
        <p className="text-center text-gray-600 text-[11px]">
          Already registered?{' '}
          <button onClick={() => onNavigate('login')} className="text-yellow-400 font-semibold">Sign in</button>
        </p>
      </div>
    </div>
  );
}

// ─── Pending Approval ────────────────────────────────────────────────────────────
function PendingApprovalScreen({ onNavigate }: NavProps) {
  const steps = [
    { label: 'Application Submitted', sub: 'Received 07 Mar 2026 · 14:32', done: true },
    { label: 'Background Check', sub: 'Industry compliance screening', done: false, active: true },
    { label: 'Account Activated', sub: 'We\'ll notify you once your account is live', done: false },
  ];
  return (
    <div className="h-full bg-[#0a0a0a] flex flex-col overflow-y-auto px-6 py-8" style={{ scrollbarWidth: 'none' }}>
      <div className="flex flex-col items-center mb-10">
        <div className="relative mb-6">
          <div className="absolute inset-0 bg-yellow-400 rounded-full blur-[30px] opacity-20" />
          <div className="relative w-24 h-24 bg-[#111] border-2 border-yellow-400/40 rounded-full flex items-center justify-center">
            <Clock className="w-10 h-10 text-yellow-400" />
          </div>
          <div className="absolute -bottom-1 -right-1 w-7 h-7 bg-yellow-400 rounded-full flex items-center justify-center border-2 border-[#0a0a0a]">
            <span className="text-black text-xs font-black">!</span>
          </div>
        </div>
        <h2 className="text-white font-black text-2xl tracking-tight mb-2">Under Review</h2>
        <p className="text-gray-500 text-[13px] text-center leading-relaxed max-w-[260px]">
          Your application is being processed. This typically takes 2-4 business hours.
        </p>
      </div>

      <div className="bg-[#0f0f0f] rounded-2xl p-5 border border-[#1a1a1a] mb-6">
        <p className="text-yellow-400 text-[11px] font-black uppercase tracking-widest mb-4">Verification Progress</p>
        <div className="space-y-4">
          {steps.map(({ label, sub, done, active }, i) => (
            <div key={label} className="flex gap-4">
              <div className="flex flex-col items-center">
                <div className={`w-7 h-7 rounded-full flex items-center justify-center border-2 flex-shrink-0 ${done ? 'bg-yellow-400 border-yellow-400' : active ? 'border-yellow-400 bg-transparent' : 'border-[#2a2a2a]'}`}>
                  {done ? <Check className="w-3.5 h-3.5 text-black" strokeWidth={3} /> : active ? <div className="w-2 h-2 bg-yellow-400 rounded-full animate-pulse" /> : <div className="w-2 h-2 bg-[#333] rounded-full" />}
                </div>
                {i < steps.length - 1 && <div className={`w-px flex-1 mt-1.5 min-h-[20px] ${done ? 'bg-yellow-400/40' : 'bg-[#1e1e1e]'}`} />}
              </div>
              <div className="pb-4">
                <p className={`text-sm font-semibold ${done || active ? 'text-white' : 'text-gray-600'}`}>{label}</p>
                <p className="text-gray-600 text-[11px] mt-0.5">{sub}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className="bg-[#111] rounded-xl p-4 border border-[#1e1e1e] mb-6 flex gap-3">
        <AlertCircle className="w-4 h-4 text-yellow-400 flex-shrink-0 mt-0.5" />
        <div>
          <p className="text-white text-[12px] font-semibold mb-0.5">Keep an eye on your inbox</p>
          <p className="text-gray-500 text-[11px] leading-relaxed">We'll send your login credentials to the email you provided once approved.</p>
        </div>
      </div>

      <button onClick={() => onNavigate('splash')} className="text-gray-600 text-[13px] text-center py-2">
        ← Return to Home
      </button>
    </div>
  );
}

// ─── Main Export ─────────────────────────────────────────────────────────────────
export function AuthFlow({ screen, onNavigate }: { screen: string; onNavigate: (s: string) => void }) {
  const screens: Record<string, React.FC<NavProps>> = {
    'splash': SplashScreen,
    'terms': FleetTermsScreen,
    'mechanic-terms': MechanicTermsScreen,
    'login': LoginScreen,
    'role-select': RoleSelectScreen,
    'fleet-register': FleetRegisterScreen,
    'mechanic-register': MechanicRegisterScreen,
    'pending': PendingApprovalScreen,
  };
  const Screen = screens[screen] ?? SplashScreen;
  return <Screen onNavigate={onNavigate} />;
}