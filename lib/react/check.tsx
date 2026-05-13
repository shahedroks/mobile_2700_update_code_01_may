import React, { useState, useEffect } from 'react';
import {
  LayoutDashboard, Users, Briefcase, TrendingUp, Clock,
  MapPin, Star, ChevronRight, Plus, Search, Filter, Calendar,
  DollarSign, CheckCircle, AlertCircle, User, UserPlus, Award,
  Activity, Target, Zap, Phone, Mail, MoreVertical, Eye, Edit, Edit3,
  ChevronDown, ChevronLeft, X, MessageCircle, FileText, Ban, HelpCircle, LogOut, Trash2, Download, Send, Wrench
} from 'lucide-react';

// Mock Data
const MECHANICS = [
  { id: 'M-001', name: 'John Smith', status: 'active', activeJobs: 2, rating: 4.8, completed: 45, phone: '07700 900123', email: 'john.smith@example.com', joinedDate: 'Jan 2024', specialties: ['Engine Repair', 'Diagnostics', 'Brake Systems'] },
  { id: 'M-002', name: 'Mike Johnson', status: 'active', activeJobs: 1, rating: 4.9, completed: 38, phone: '07700 900456', email: 'mike.johnson@example.com', joinedDate: 'Mar 2024', specialties: ['Electrical', 'Air Systems', 'Transmission'] },
  { id: 'M-003', name: 'Dave Wilson', status: 'busy', activeJobs: 3, rating: 4.7, completed: 52, phone: '07700 900789', email: 'dave.wilson@example.com', joinedDate: 'Nov 2023', specialties: ['Suspension', 'Steering', 'Tyre Services'] },
  { id: 'M-004', name: 'Tom Brown', status: 'offline', activeJobs: 0, rating: 4.6, completed: 29, phone: '07700 900321', email: 'tom.brown@example.com', joinedDate: 'May 2024', specialties: ['Hydraulics', 'Cooling Systems', 'General Service'] },
];

// Available jobs to quote on (NEW)
const AVAILABLE_JOBS = [
  { id: 'TF-8901', vehicle: 'DAF XF', issue: 'Engine warning light', urgency: 'urgent', location: 'M1 Services', distance: '8 miles', time: '5 min ago', fleetRating: 4.7 },
  { id: 'TF-8902', vehicle: 'Scania R450', issue: 'Brake system fault', urgency: 'high', location: 'Birmingham', distance: '12 miles', time: '18 min ago', fleetRating: 4.9 },
  { id: 'TF-8903', vehicle: 'Volvo FH16', issue: 'Coolant leak', urgency: 'medium', location: 'Manchester', distance: '25 miles', time: '45 min ago', fleetRating: 4.5 },
  { id: 'TF-8904', vehicle: 'Mercedes Actros', issue: 'Electrical fault', urgency: 'low', location: 'Leeds', distance: '32 miles', time: '1 hr ago', fleetRating: 4.8 },
  { id: 'TF-8905', vehicle: 'MAN TGX', issue: 'Flat tyre + inspection', urgency: 'high', location: 'Sheffield', distance: '18 miles', time: '23 min ago', fleetRating: 4.6 },
];

// My quotes (jobs company has quoted on)
const MY_QUOTES = [
  { id: 'TF-8898', vehicle: 'DAF CF', issue: 'Oil leak', status: 'pending', quote: '£320', location: 'M6 Services', time: '2 hrs ago' },
  { id: 'TF-8899', vehicle: 'Iveco Stralis', issue: 'Battery dead', status: 'accepted', quote: '£180', location: 'Birmingham', time: '4 hrs ago', assignedTo: null },
  { id: 'TF-8897', vehicle: 'Renault T-High', issue: 'Suspension fault', status: 'rejected', quote: '£540', location: 'Manchester', time: '1 day ago' },
];

const JOBS = [
  { id: 'TF-8821', vehicle: 'DAF XF', issue: 'Engine warning light', status: 'unassigned', urgency: 'high', location: 'M1 Services', time: '12 min ago', price: '£450' },
  { id: 'TF-8822', vehicle: 'Scania R450', issue: 'Brake system fault', status: 'assigned', mechanic: 'John Smith', urgency: 'urgent', location: 'Birmingham', time: '25 min ago', price: '£680' },
  { id: 'TF-8823', vehicle: 'Volvo FH16', issue: 'Coolant leak', status: 'assigned', mechanic: 'Mike Johnson', urgency: 'medium', location: 'Manchester', time: '1 hr ago', price: '£320' },
  { id: 'TF-8824', vehicle: 'Mercedes Actros', issue: 'Electrical fault', status: 'in-progress', mechanic: 'Dave Wilson', urgency: 'low', location: 'Leeds', time: '2 hrs ago', price: '£540' },
];

// Jobs completed by mechanics pending company confirmation
const PENDING_REVIEW_JOBS = [
  { 
    id: 'TF-8820', 
    vehicle: 'MAN TGX', 
    issue: 'Hydraulic system fault', 
    status: 'pending-review', 
    mechanic: 'John Smith', 
    urgency: 'high', 
    location: 'M6 Services', 
    completedAt: '2 hrs ago',
    fleet: 'Peak Haulage Ltd',
    invoice: {
      callOut: 85,
      labourHours: 2.5,
      hourlyRate: 65,
      partsCost: 145,
      parts: [
        { name: 'Hydraulic pump seal kit', cost: 95 },
        { name: 'Hydraulic fluid (10L)', cost: 50 }
      ],
      totalGross: 397.50
    }
  },
  { 
    id: 'TF-8819', 
    vehicle: 'Iveco Stralis', 
    issue: 'Battery replacement', 
    status: 'pending-review', 
    mechanic: 'Mike Johnson', 
    urgency: 'medium', 
    location: 'Birmingham Depot', 
    completedAt: '4 hrs ago',
    fleet: 'Swift Freight',
    invoice: {
      callOut: 85,
      labourHours: 0.75,
      hourlyRate: 65,
      partsCost: 95,
      parts: [
        { name: 'Heavy-duty battery 12V', cost: 95 }
      ],
      totalGross: 228.75
    }
  },
];

// ─── Job Feed (Browse & Quote) ───────────────────────────────────────────────
function CompanyJobFeed() {
  const [activeTab, setActiveTab] = useState<'available' | 'my-quotes'>('available');
  const [showQuoteModal, setShowQuoteModal] = useState(false);
  const [selectedJob, setSelectedJob] = useState<any>(null);

  return (
    <div className="h-full bg-black overflow-y-auto pb-20 relative">
      {/* Header */}
      <div className="bg-[#0f0f0f] border-b border-[#2a2a2a] px-4 py-4 sticky top-0 z-10">
        <div className="flex items-center justify-between mb-3">
          <div>
            <h1 className="text-white font-black text-xl tracking-tight">Job Feed</h1>
            <p className="text-gray-500 text-xs mt-0.5">Browse & send quotes</p>
          </div>
          <div className="bg-yellow-400/10 border border-yellow-400/30 px-3 py-1.5 rounded-lg">
            <span className="text-yellow-400 font-black text-sm">{AVAILABLE_JOBS.length}</span>
            <span className="text-yellow-400/80 text-xs ml-1">new</span>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex gap-2">
          <button
            onClick={() => setActiveTab('available')}
            className={`flex-1 py-2 rounded-lg text-xs font-bold ${
              activeTab === 'available'
                ? 'bg-yellow-400 text-black'
                : 'bg-[#1a1a1a] text-gray-500 border border-[#2a2a2a]'
            }`}
          >
            Available Jobs ({AVAILABLE_JOBS.length})
          </button>
          <button
            onClick={() => setActiveTab('my-quotes')}
            className={`flex-1 py-2 rounded-lg text-xs font-bold ${
              activeTab === 'my-quotes'
                ? 'bg-yellow-400 text-black'
                : 'bg-[#1a1a1a] text-gray-500 border border-[#2a2a2a]'
            }`}
          >
            My Quotes ({MY_QUOTES.length})
          </button>
        </div>
      </div>

      <div className="p-4 space-y-3">
        {activeTab === 'available' ? (
          // Available Jobs
          <>
            {AVAILABLE_JOBS.map((job) => (
              <div key={job.id} className="bg-[#0f0f0f] border border-[#2a2a2a] rounded-xl p-4">
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-gray-600 text-xs font-mono">{job.id}</span>
                      <span className={`px-2 py-0.5 rounded text-[10px] font-black ${
                        job.urgency === 'urgent' ? 'bg-red-400/10 text-red-400 border border-red-400/30' :
                        job.urgency === 'high' ? 'bg-orange-400/10 text-orange-400 border border-orange-400/30' :
                        'bg-blue-400/10 text-blue-400 border border-blue-400/30'
                      }`}>
                        {job.urgency.toUpperCase()}
                      </span>
                      <div className="flex items-center gap-1">
                        <Star className="w-3 h-3 text-yellow-400 fill-yellow-400" />
                        <span className="text-yellow-400 text-xs font-semibold">{job.fleetRating}</span>
                      </div>
                    </div>
                    <h3 className="text-white font-bold text-sm mb-1">{job.vehicle}</h3>
                    <p className="text-gray-500 text-xs">{job.issue}</p>
                  </div>
                  <span className="text-gray-600 text-xs">{job.time}</span>
                </div>

                <div className="flex items-center gap-3 mb-3 text-xs">
                  <div className="flex items-center gap-1 text-gray-600">
                    <MapPin className="w-3.5 h-3.5" />
                    <span>{job.location}</span>
                  </div>
                  <div className="flex items-center gap-1 text-green-400">
                    <Target className="w-3.5 h-3.5" />
                    <span>{job.distance}</span>
                  </div>
                </div>

                <button
                  onClick={() => {
                    setSelectedJob(job);
                    setShowQuoteModal(true);
                  }}
                  className="w-full bg-yellow-400 text-black py-2.5 rounded-lg font-black text-sm"
                >
                  Send Quote
                </button>
              </div>
            ))}
          </>
        ) : (
          // My Quotes
          <>
            {MY_QUOTES.map((quote) => (
              <div key={quote.id} className="bg-[#0f0f0f] border border-[#2a2a2a] rounded-xl p-4">
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-gray-600 text-xs font-mono">{quote.id}</span>
                      <span className={`px-2 py-0.5 rounded text-[10px] font-black ${
                        quote.status === 'accepted' ? 'bg-green-400/10 text-green-400 border border-green-400/30' :
                        quote.status === 'pending' ? 'bg-yellow-400/10 text-yellow-400 border border-yellow-400/30' :
                        'bg-red-400/10 text-red-400 border border-red-400/30'
                      }`}>
                        {quote.status.toUpperCase()}
                      </span>
                    </div>
                    <h3 className="text-white font-bold text-sm mb-1">{quote.vehicle}</h3>
                    <p className="text-gray-500 text-xs">{quote.issue}</p>
                  </div>
                  <p className="text-green-400 font-black text-lg">{quote.quote}</p>
                </div>

                <div className="flex items-center gap-3 mb-3 text-xs">
                  <div className="flex items-center gap-1 text-gray-600">
                    <MapPin className="w-3.5 h-3.5" />
                    <span>{quote.location}</span>
                  </div>
                  <div className="flex items-center gap-1 text-gray-600">
                    <Clock className="w-3.5 h-3.5" />
                    <span>{quote.time}</span>
                  </div>
                </div>

                {quote.status === 'accepted' && (
                  <div className="bg-green-400/10 border border-green-400/30 rounded-lg p-3 flex items-center justify-between">
                    <span className="text-green-400 text-xs font-semibold">✓ Quote accepted - Assign mechanic</span>
                    <button className="text-yellow-400 text-xs font-black">Assign</button>
                  </div>
                )}
              </div>
            ))}
          </>
        )}
      </div>

      {/* Quote Submission Modal */}
      {showQuoteModal && selectedJob && (
        <div className="absolute inset-0 bg-black/80 flex items-end z-50">
          <div className="w-full bg-[#0f0f0f] rounded-t-2xl border-t border-[#2a2a2a]">
            <div className="px-4 py-4 border-b border-[#2a2a2a] flex items-center justify-between">
              <div>
                <h2 className="text-white font-black text-lg">Submit Quote</h2>
                <p className="text-gray-600 text-xs">{selectedJob.id} · {selectedJob.vehicle}</p>
              </div>
              <button onClick={() => setShowQuoteModal(false)}>
                <X className="w-5 h-5 text-gray-600" />
              </button>
            </div>

            <div className="p-4 space-y-4">
              {/* Job Details */}
              <div className="bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl p-4">
                <h3 className="text-white font-bold text-sm mb-2">{selectedJob.issue}</h3>
                <div className="space-y-1.5 text-xs">
                  <div className="flex items-center gap-2 text-gray-500">
                    <MapPin className="w-3.5 h-3.5" />
                    <span>{selectedJob.location} ({selectedJob.distance})</span>
                  </div>
                  <div className="flex items-center gap-2 text-gray-500">
                    <Clock className="w-3.5 h-3.5" />
                    <span>Posted {selectedJob.time}</span>
                  </div>
                </div>
              </div>

              {/* Quote Amount */}
              <div>
                <label className="text-gray-500 text-xs font-semibold mb-2 block">Quote Amount</label>
                <div className="relative">
                  <span className="absolute left-4 top-1/2 -translate-y-1/2 text-white text-xl font-black">£</span>
                  <input
                    type="number"
                    placeholder="0"
                    className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg pl-10 pr-4 py-4 text-white text-2xl font-black placeholder-gray-600 focus:outline-none focus:border-yellow-400/40"
                  />
                </div>
              </div>

              {/* Estimated Time */}
              <div>
                <label className="text-gray-500 text-xs font-semibold mb-2 block">Estimated Arrival (minutes)</label>
                <input
                  type="number"
                  placeholder="30"
                  className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg px-4 py-3 text-white text-sm placeholder-gray-600 focus:outline-none focus:border-yellow-400/40"
                />
              </div>

              {/* Notes */}
              <div>
                <label className="text-gray-500 text-xs font-semibold mb-2 block">Additional Notes (Optional)</label>
                <textarea
                  rows={3}
                  placeholder="Any additional information..."
                  className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg px-4 py-3 text-white text-sm placeholder-gray-600 focus:outline-none focus:border-yellow-400/40 resize-none"
                />
              </div>

              <button 
                onClick={() => setShowQuoteModal(false)}
                className="w-full bg-yellow-400 text-black py-3.5 rounded-lg font-black text-sm"
              >
                Submit Quote
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Company Dashboard ────────────────────────────────────────────────────────
function CompanyDashboard({ navigateToJobs, navigateToTeam }: { 
  navigateToJobs: (filter?: string) => void;
  navigateToTeam: () => void;
}) {
  return (
    <div className="h-full bg-black overflow-y-auto pb-20">
      {/* Header */}
      <div className="bg-[#0f0f0f] border-b border-[#2a2a2a] px-4 py-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-white font-black text-xl tracking-tight">Swift Mechanics Ltd</h1>
            <p className="text-gray-500 text-xs mt-0.5">Company Dashboard</p>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 bg-green-400 rounded-full shadow-[0_0_6px_rgba(34,197,94,0.6)]" />
            <span className="text-green-400 text-xs font-semibold">4 Active Mechanics</span>
          </div>
        </div>
      </div>

      <div className="p-4 space-y-4">
        {/* Stats Grid */}
        <div className="grid grid-cols-2 gap-3">
          <div className="bg-[#0f0f0f] border border-yellow-400/30 rounded-xl p-4">
            <div className="flex items-center gap-2 mb-2">
              <Briefcase className="w-4 h-4 text-yellow-400" />
              <span className="text-yellow-400 text-xs font-black uppercase tracking-wide">Active Jobs</span>
            </div>
            <p className="text-white font-black text-3xl">6</p>
            <p className="text-gray-600 text-xs mt-1">2 unassigned</p>
          </div>

          <div className="bg-[#0f0f0f] border border-green-400/30 rounded-xl p-4">
            <div className="flex items-center gap-2 mb-2">
              <Users className="w-4 h-4 text-green-400" />
              <span className="text-green-400 text-xs font-black uppercase tracking-wide">Mechanics</span>
            </div>
            <p className="text-white font-black text-3xl">4</p>
            <p className="text-gray-600 text-xs mt-1">3 online</p>
          </div>

          <div className="bg-[#0f0f0f] border border-blue-400/30 rounded-xl p-4">
            <div className="flex items-center gap-2 mb-2">
              <DollarSign className="w-4 h-4 text-blue-400" />
              <span className="text-blue-400 text-xs font-black uppercase tracking-wide">This Month</span>
            </div>
            <p className="text-white font-black text-3xl">£18.4k</p>
            <p className="text-green-400 text-xs mt-1">+12% vs last</p>
          </div>

          <div className="bg-[#0f0f0f] border border-orange-400/30 rounded-xl p-4">
            <div className="flex items-center gap-2 mb-2">
              <Star className="w-4 h-4 text-orange-400" />
              <span className="text-orange-400 text-xs font-black uppercase tracking-wide">Avg Rating</span>
            </div>
            <p className="text-white font-black text-3xl">4.8</p>
            <p className="text-gray-600 text-xs mt-1">156 reviews</p>
          </div>
        </div>

        {/* Unassigned Jobs Alert */}
        <div className="bg-yellow-400/5 border border-yellow-400/30 rounded-xl p-4">
          <div className="flex items-start gap-3">
            <AlertCircle className="w-5 h-5 text-yellow-400 flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="text-yellow-400 font-bold text-sm mb-1">2 Jobs Need Assignment</p>
              <p className="text-gray-500 text-xs mb-3">Assign mechanics to new job requests</p>
              <button 
                onClick={() => navigateToJobs('Unassigned')}
                className="bg-yellow-400 text-black px-4 py-2 rounded-lg font-black text-xs"
              >
                Assign Now
              </button>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="space-y-2">
          <p className="text-gray-600 text-xs font-black uppercase tracking-wide px-1">Quick Actions</p>
          <div className="grid grid-cols-2 gap-2">
            <button 
              onClick={navigateToTeam}
              className="bg-[#0f0f0f] border border-[#2a2a2a] rounded-xl p-3 text-left hover:border-yellow-400/40 transition-colors"
            >
              <Users className="w-5 h-5 text-yellow-400 mb-2" />
              <p className="text-white text-sm font-semibold">Manage Team</p>
              <p className="text-gray-600 text-xs">4 mechanics</p>
            </button>
            <button
              onClick={navigateToTeam}
              className="bg-[#0f0f0f] border border-[#2a2a2a] rounded-xl p-3 text-left hover:border-yellow-400/40 transition-colors"
            >
              <UserPlus className="w-5 h-5 text-green-400 mb-2" />
              <p className="text-white text-sm font-semibold">Add Mechanic</p>
              <p className="text-gray-600 text-xs">Send invite</p>
            </button>
          </div>
        </div>

        {/* Recent Activity */}
        <div className="space-y-2">
          <p className="text-gray-600 text-xs font-black uppercase tracking-wide px-1">Recent Activity</p>
          <div className="bg-[#0f0f0f] border border-[#2a2a2a] rounded-xl divide-y divide-[#1a1a1a]">
            {[
              { action: 'Job completed', detail: 'TF-8820 by John Smith', time: '5 min ago', icon: CheckCircle, color: 'green' },
              { action: 'New job assigned', detail: 'TF-8822 to Mike Johnson', time: '25 min ago', icon: Briefcase, color: 'yellow' },
              { action: 'Mechanic online', detail: 'Dave Wilson started shift', time: '1 hr ago', icon: User, color: 'blue' },
            ].map((item, idx) => {
              const Icon = item.icon;
              return (
                <div key={idx} className="p-3 flex items-center gap-3">
                  <Icon className={`w-4 h-4 text-${item.color}-400 flex-shrink-0`} />
                  <div className="flex-1 min-w-0">
                    <p className="text-white text-sm font-medium">{item.action}</p>
                    <p className="text-gray-600 text-xs truncate">{item.detail}</p>
                  </div>
                  <span className="text-gray-700 text-xs flex-shrink-0">{item.time}</span>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── Jobs Management (Assign Mechanics) ──────────────────────────────────────
function CompanyJobs({ initialFilter }: { initialFilter?: string }) {
  const [showAssignModal, setShowAssignModal] = useState(false);
  const [selectedJob, setSelectedJob] = useState<any>(null);
  const [selectedMechanic, setSelectedMechanic] = useState<string | null>(null);
  const [showInvoiceModal, setShowInvoiceModal] = useState(false);
  const [selectedInvoice, setSelectedInvoice] = useState<any>(null);
  const [activeFilter, setActiveFilter] = useState(initialFilter || 'All');
  
  // Update filter when initialFilter prop changes
  React.useEffect(() => {
    if (initialFilter) {
      setActiveFilter(initialFilter);
    }
  }, [initialFilter]);
  
  // Invoice editing state
  const [editCallOut, setEditCallOut] = useState('85');
  const [editLabourHours, setEditLabourHours] = useState('2.5');
  const [editPartsCost, setEditPartsCost] = useState('145');
  const [editPartsList, setEditPartsList] = useState<Array<{ name: string; cost: string }>>([]);

  const handleConfirmAssignment = () => {
    if (selectedMechanic) {
      // In production: API call to assign mechanic
      setShowAssignModal(false);
      setSelectedMechanic(null);
    }
  };

  const handleApproveJob = () => {
    // In production: API call to approve and finalize job with edited values
    setShowInvoiceModal(false);
    setSelectedInvoice(null);
  };
  
  // When opening invoice modal, initialize with current values
  const handleOpenInvoice = (job: any) => {
    setSelectedInvoice(job);
    setEditCallOut(job.invoice.callOut.toString());
    setEditLabourHours(job.invoice.labourHours.toString());
    setEditPartsCost(job.invoice.partsCost.toString());
    // Initialize parts list from job data
    const parts = (job.invoice.parts || []).map((p: any) => ({
      name: p.name,
      cost: p.cost.toString()
    }));
    setEditPartsList(parts);
    setShowInvoiceModal(true);
  };
  
  // Calculate edited total
  const labourRate = selectedInvoice?.invoice.hourlyRate || 65;
  const totalCallOut = parseFloat(editCallOut) || 0;
  const totalLabour = (parseFloat(editLabourHours) || 0) * labourRate;
  const totalParts = editPartsList.reduce((sum, part) => sum + (parseFloat(part.cost) || 0), 0);
  const editedTotal = totalCallOut + totalLabour + totalParts;
  
  // Parts list management functions
  const addEditPart = () => {
    setEditPartsList([...editPartsList, { name: '', cost: '' }]);
  };

  const removeEditPart = (index: number) => {
    setEditPartsList(editPartsList.filter((_, i) => i !== index));
  };

  const updateEditPartName = (index: number, name: string) => {
    const updated = [...editPartsList];
    updated[index].name = name;
    setEditPartsList(updated);
  };

  const updateEditPartCost = (index: number, cost: string) => {
    const updated = [...editPartsList];
    updated[index].cost = cost;
    setEditPartsList(updated);
  };

  return (
    <div className="h-full bg-black overflow-y-auto pb-20 relative">
      {/* Header */}
      <div className="bg-[#0f0f0f] border-b border-[#2a2a2a] px-4 py-4 sticky top-0 z-10">
        <div className="flex items-center justify-between mb-3">
          <div>
            <h1 className="text-white font-black text-xl tracking-tight">Job Management</h1>
            <p className="text-gray-500 text-xs mt-0.5">Assign & track jobs</p>
          </div>
          <div className="bg-yellow-400/10 border border-yellow-400/30 px-3 py-1.5 rounded-lg">
            <span className="text-yellow-400 font-black text-sm">{PENDING_REVIEW_JOBS.length}</span>
            <span className="text-yellow-400/80 text-xs ml-1">pending</span>
          </div>
        </div>

        {/* Filter Tabs */}
        <div className="flex gap-2 overflow-x-auto" style={{ scrollbarWidth: 'none' }}>
          {['All', 'Pending Review', 'Unassigned', 'Assigned', 'In Progress'].map((filter) => (
            <button
              key={filter}
              onClick={() => setActiveFilter(filter)}
              className={`px-3 py-1.5 rounded-lg text-xs font-bold whitespace-nowrap relative ${
                activeFilter === filter
                  ? 'bg-yellow-400 text-black'
                  : 'bg-[#1a1a1a] text-gray-500 border border-[#2a2a2a]'
              }`}
            >
              {filter}
              {filter === 'Pending Review' && PENDING_REVIEW_JOBS.length > 0 && (
                <span className="absolute -top-1 -right-1 w-4 h-4 bg-red-500 rounded-full text-white text-[9px] font-black flex items-center justify-center">
                  {PENDING_REVIEW_JOBS.length}
                </span>
              )}
            </button>
          ))}
        </div>
      </div>

      <div className="p-4 space-y-3">
        {/* Pending Review Jobs */}
        {(activeFilter === 'All' || activeFilter === 'Pending Review') && PENDING_REVIEW_JOBS.map((job) => (
          <div key={job.id} className="bg-[#0f0f0f] border border-yellow-400/30 rounded-xl p-4">
            <div className="flex items-start justify-between mb-3">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-gray-600 text-xs font-mono">{job.id}</span>
                  <span className="px-2 py-0.5 rounded text-[10px] font-black bg-yellow-400/10 text-yellow-400 border border-yellow-400/30">
                    PENDING REVIEW
                  </span>
                </div>
                <h3 className="text-white font-bold text-sm mb-1">{job.vehicle}</h3>
                <p className="text-gray-500 text-xs">{job.issue}</p>
              </div>
            </div>

            <div className="flex items-center gap-3 mb-3 text-xs">
              <div className="flex items-center gap-1 text-gray-600">
                <MapPin className="w-3.5 h-3.5" />
                <span>{job.location}</span>
              </div>
              <div className="flex items-center gap-1 text-gray-600">
                <Clock className="w-3.5 h-3.5" />
                <span>Completed {job.completedAt}</span>
              </div>
            </div>

            <div className="flex items-center justify-between bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg p-3 mb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 bg-green-400/20 rounded-full flex items-center justify-center">
                  <User className="w-4 h-4 text-green-400" />
                </div>
                <div>
                  <p className="text-white text-xs font-semibold">{job.mechanic}</p>
                  <p className="text-gray-600 text-[10px]">Completed job</p>
                </div>
              </div>
              <div className="text-right">
                <p className="text-yellow-400 font-black text-lg">£{job.invoice.totalGross.toFixed(2)}</p>
                <p className="text-gray-600 text-[10px]">Total invoice</p>
              </div>
            </div>

            <button
              onClick={() => handleOpenInvoice(job)}
              className="w-full bg-yellow-400 text-black py-2.5 rounded-lg font-black text-sm flex items-center justify-center gap-2"
            >
              <Eye className="w-4 h-4" />
              Review & Approve Invoice
            </button>
          </div>
        ))}

        {/* Regular Jobs */}
        {JOBS.filter(job => {
          if (activeFilter === 'All') return true;
          if (activeFilter === 'Pending Review') return false;
          if (activeFilter === 'Unassigned') return job.status === 'unassigned';
          if (activeFilter === 'Assigned') return job.status === 'assigned';
          if (activeFilter === 'In Progress') return job.status === 'in-progress';
          return true;
        }).map((job) => (
          <div key={job.id} className="bg-[#0f0f0f] border border-[#2a2a2a] rounded-xl p-4">
            <div className="flex items-start justify-between mb-3">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-gray-600 text-xs font-mono">{job.id}</span>
                  <span className={`px-2 py-0.5 rounded text-[10px] font-black ${
                    job.urgency === 'urgent' ? 'bg-red-400/10 text-red-400 border border-red-400/30' :
                    job.urgency === 'high' ? 'bg-orange-400/10 text-orange-400 border border-orange-400/30' :
                    'bg-blue-400/10 text-blue-400 border border-blue-400/30'
                  }`}>
                    {job.urgency.toUpperCase()}
                  </span>
                </div>
                <h3 className="text-white font-bold text-sm mb-1">{job.vehicle}</h3>
                <p className="text-gray-500 text-xs">{job.issue}</p>
              </div>
              <p className="text-green-400 font-black text-lg">{job.price}</p>
            </div>

            <div className="flex items-center gap-3 mb-3 text-xs">
              <div className="flex items-center gap-1 text-gray-600">
                <MapPin className="w-3.5 h-3.5" />
                <span>{job.location}</span>
              </div>
              <div className="flex items-center gap-1 text-gray-600">
                <Clock className="w-3.5 h-3.5" />
                <span>{job.time}</span>
              </div>
            </div>

            {/* Assignment Status */}
            {job.status === 'unassigned' ? (
              <button
                onClick={() => {
                  setSelectedJob(job);
                  setShowAssignModal(true);
                }}
                className="w-full bg-yellow-400 text-black py-2.5 rounded-lg font-black text-sm flex items-center justify-center gap-2"
              >
                <UserPlus className="w-4 h-4" />
                Assign Mechanic
              </button>
            ) : (
              <div className="flex items-center justify-between bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg p-3">
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 bg-green-400/20 rounded-full flex items-center justify-center">
                    <User className="w-4 h-4 text-green-400" />
                  </div>
                  <div>
                    <p className="text-white text-xs font-semibold">{job.mechanic}</p>
                    <p className="text-gray-600 text-[10px]">{job.status.replace('-', ' ')}</p>
                  </div>
                </div>
                <button className="text-yellow-400 text-xs font-bold">Reassign</button>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Assign Mechanic Modal */}
      {showAssignModal && (
        <div className="absolute inset-0 bg-black/80 flex items-end z-50">
          <div className="w-full bg-[#0f0f0f] rounded-t-2xl border-t border-[#2a2a2a] max-h-[80vh] flex flex-col">
            <div className="flex-shrink-0 bg-[#0f0f0f] border-b border-[#2a2a2a] px-4 py-4 flex items-center justify-between">
              <div>
                <h2 className="text-white font-black text-lg">Assign Mechanic</h2>
                <p className="text-gray-600 text-xs">{selectedJob?.id} · {selectedJob?.vehicle}</p>
              </div>
              <button onClick={() => {
                setShowAssignModal(false);
                setSelectedMechanic(null);
              }}>
                <X className="w-5 h-5 text-gray-600" />
              </button>
            </div>

            <div className="flex-1 overflow-y-auto p-4 space-y-2" style={{ scrollbarWidth: 'none' }}>
              {MECHANICS.map((mechanic) => {
                const isSelected = selectedMechanic === mechanic.id;
                return (
                  <button
                    key={mechanic.id}
                    onClick={() => setSelectedMechanic(mechanic.id)}
                    className={`w-full rounded-xl p-4 text-left transition-all ${
                      isSelected 
                        ? 'bg-[#1a1a1a] border-2 border-yellow-400' 
                        : 'bg-[#1a1a1a] border border-[#2a2a2a] hover:border-yellow-400/40'
                    }`}
                  >
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center gap-3">
                        <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                          isSelected ? 'bg-yellow-400/30' : 'bg-yellow-400/20'
                        }`}>
                          <User className={`w-5 h-5 ${isSelected ? 'text-yellow-400' : 'text-yellow-400'}`} />
                        </div>
                        <div>
                          <p className="text-white font-bold text-sm">{mechanic.name}</p>
                          <p className="text-gray-600 text-xs">{mechanic.id}</p>
                        </div>
                      </div>
                      <div className={`w-2 h-2 rounded-full ${
                        mechanic.status === 'active' ? 'bg-green-400 shadow-[0_0_6px_rgba(34,197,94,0.6)]' :
                        mechanic.status === 'busy' ? 'bg-orange-400' : 'bg-gray-600'
                      }`} />
                    </div>

                    <div className="flex items-center gap-4 text-xs">
                      <div className="flex items-center gap-1">
                        <Star className="w-3.5 h-3.5 text-yellow-400 fill-yellow-400" />
                        <span className="text-yellow-400 font-semibold">{mechanic.rating}</span>
                      </div>
                      <span className="text-gray-600">
                        {mechanic.activeJobs} active · {mechanic.completed} completed
                      </span>
                    </div>
                  </button>
                );
              })}
            </div>

            <div className="flex-shrink-0 bg-[#0f0f0f] border-t border-[#2a2a2a] p-4">
              <button 
                onClick={handleConfirmAssignment}
                disabled={!selectedMechanic}
                className={`w-full py-3 rounded-lg font-black transition-opacity ${
                  selectedMechanic 
                    ? 'bg-yellow-400 text-black' 
                    : 'bg-yellow-400/30 text-black/40 cursor-not-allowed'
                }`}
              >
                Confirm Assignment
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Invoice Review Modal */}
      {showInvoiceModal && selectedInvoice && (
        <div className="absolute inset-0 bg-black/80 flex items-end z-50">
          <div className="w-full bg-[#0f0f0f] rounded-t-2xl border-t border-[#2a2a2a] max-h-[80vh] flex flex-col">
            <div className="flex-shrink-0 bg-[#0f0f0f] border-b border-[#2a2a2a] px-4 py-4 flex items-center justify-between">
              <div>
                <h2 className="text-white font-black text-lg">Review Invoice</h2>
                <p className="text-gray-600 text-xs">{selectedInvoice.id} · {selectedInvoice.vehicle}</p>
              </div>
              <button onClick={() => setShowInvoiceModal(false)}>
                <X className="w-5 h-5 text-gray-600" />
              </button>
            </div>

            <div className="flex-1 overflow-y-auto p-4 space-y-4" style={{ scrollbarWidth: 'none' }}>
              {/* Job Details */}
              <div className="bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl p-4">
                <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-3">Job Details</p>
                <div className="space-y-2">
                  <div className="flex justify-between">
                    <span className="text-gray-500 text-xs">Issue</span>
                    <span className="text-white text-xs font-semibold">{selectedInvoice.issue}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500 text-xs">Location</span>
                    <span className="text-white text-xs font-semibold">{selectedInvoice.location}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500 text-xs">Mechanic</span>
                    <span className="text-white text-xs font-semibold">{selectedInvoice.mechanic}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500 text-xs">Fleet Operator</span>
                    <span className="text-white text-xs font-semibold">{selectedInvoice.fleet}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500 text-xs">Completed</span>
                    <span className="text-white text-xs font-semibold">{selectedInvoice.completedAt}</span>
                  </div>
                </div>
              </div>

              {/* Invoice Breakdown */}
              <div className="bg-[#1a1a1a] border border-yellow-400/40 rounded-xl p-4">
                <div className="flex items-center gap-2 mb-3">
                  <FileText className="w-4 h-4 text-yellow-400" />
                  <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Job Invoice</p>
                </div>
                
                <div className="space-y-3">
                  {/* Call Out Charge - Editable */}
                  <div>
                    <label className="text-[10px] text-gray-500 uppercase tracking-widest font-semibold">Call Out Charge</label>
                    <div className="relative mt-1">
                      <span className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-500 text-sm">£</span>
                      <input
                        type="number"
                        step="0.01"
                        value={editCallOut}
                        onChange={e => setEditCallOut(e.target.value)}
                        className="w-full bg-[#0f0f0f] border border-[#2a2a2a] rounded-xl pl-8 pr-4 py-3 text-white focus:outline-none focus:border-yellow-400/60 text-sm"
                      />
                    </div>
                  </div>

                  {/* Labour Time - Editable */}
                  <div>
                    <label className="text-[10px] text-gray-500 uppercase tracking-widest font-semibold">Labour Time (Hours)</label>
                    <div className="mt-1 flex gap-2">
                      <input
                        type="number"
                        step="0.25"
                        value={editLabourHours}
                        onChange={e => setEditLabourHours(e.target.value)}
                        className="flex-1 bg-[#0f0f0f] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-yellow-400/60 text-sm"
                      />
                      <div className="bg-[#0f0f0f] border border-[#2a2a2a] rounded-xl px-4 py-3 flex items-center whitespace-nowrap">
                        <p className="text-gray-500 text-sm">@ £{labourRate}/hr</p>
                      </div>
                    </div>
                    <p className="text-gray-500 text-xs mt-1.5">Labour total: £{totalLabour.toFixed(2)}</p>
                  </div>

                  {/* Parts - Editable */}
                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <label className="text-[10px] text-gray-500 uppercase tracking-widest font-semibold">Parts Used</label>
                      <button
                        onClick={addEditPart}
                        className="flex items-center gap-1 px-2.5 py-1.5 bg-[#0f0f0f] border border-[#2a2a2a] hover:border-yellow-400/40 rounded-lg transition-colors"
                      >
                        <Plus className="w-3 h-3 text-yellow-400" />
                        <span className="text-[10px] text-gray-400 font-semibold">Add Part</span>
                      </button>
                    </div>
                    
                    {editPartsList.length === 0 ? (
                      <div className="bg-[#080808] border border-[#1a1a1a] rounded-xl p-4 text-center">
                        <p className="text-gray-600 text-xs">No parts added</p>
                        <p className="text-gray-700 text-[10px] mt-0.5">Click "Add Part" to itemize parts costs</p>
                      </div>
                    ) : (
                      <div className="space-y-2">
                        {editPartsList.map((part, index) => (
                          <div key={index} className="bg-[#080808] border border-[#1a1a1a] rounded-xl p-3 space-y-2">
                            <div className="flex gap-2">
                              <input
                                type="text"
                                value={part.name}
                                onChange={e => updateEditPartName(index, e.target.value)}
                                placeholder="Part name (e.g., Hydraulic seal)"
                                className="flex-1 bg-[#0f0f0f] border border-[#2a2a2a] rounded-lg px-3 py-2 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-xs"
                              />
                              <button
                                onClick={() => removeEditPart(index)}
                                className="w-8 h-8 bg-[#0f0f0f] border border-[#2a2a2a] hover:border-red-400/40 rounded-lg flex items-center justify-center transition-colors group flex-shrink-0"
                              >
                                <Trash2 className="w-3.5 h-3.5 text-gray-600 group-hover:text-red-400 transition-colors" />
                              </button>
                            </div>
                            <div className="relative">
                              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500 text-xs">£</span>
                              <input
                                type="number"
                                step="0.01"
                                value={part.cost}
                                onChange={e => updateEditPartCost(index, e.target.value)}
                                placeholder="0.00"
                                className="w-full bg-[#0f0f0f] border border-[#2a2a2a] rounded-lg pl-7 pr-3 py-2 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-xs"
                              />
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                    
                    {editPartsList.length > 0 && (
                      <p className="text-gray-500 text-xs">Parts total: £{totalParts.toFixed(2)}</p>
                    )}
                  </div>

                  {/* Total - Dynamically Calculated */}
                  <div className="border-t border-[#2a2a2a] pt-3 mt-3">
                    <div className="flex justify-between items-center">
                      <span className="text-gray-400 text-sm font-semibold">Total Invoice</span>
                      <span className="text-yellow-400 font-black text-2xl">£{editedTotal.toFixed(2)}</span>
                    </div>
                  </div>
                </div>
              </div>

              <div className="bg-blue-400/10 border border-blue-400/30 rounded-xl p-3 flex gap-3">
                <HelpCircle className="w-5 h-5 text-blue-400 flex-shrink-0 mt-0.5" />
                <div>
                  <p className="text-blue-400 text-xs font-bold mb-1">Company Review</p>
                  <p className="text-gray-400 text-xs">Review and approve this invoice to finalize the job. The amount will be charged to the fleet operator.</p>
                </div>
              </div>
            </div>

            <div className="flex-shrink-0 bg-[#0f0f0f] border-t border-[#2a2a2a] p-4 space-y-2">
              <button 
                onClick={handleApproveJob}
                className="w-full bg-green-400 text-black py-3 rounded-lg font-black transition-opacity"
              >
                ✓ Approve & Complete Job
              </button>
              <button 
                onClick={() => setShowInvoiceModal(false)}
                className="w-full bg-[#1a1a1a] border border-[#2a2a2a] text-white py-3 rounded-lg font-bold"
              >
                Back
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Team Management (Standalone Screen) ──────────────────────────────────────
function CompanyTeam() {
  const [showInviteModal, setShowInviteModal] = useState(false);
  const [selectedMechanic, setSelectedMechanic] = useState<any>(null);
  const [showRemoveConfirm, setShowRemoveConfirm] = useState(false);

  const handleRemoveMechanic = () => {
    // In production: API call to remove mechanic from team
    setShowRemoveConfirm(false);
    setSelectedMechanic(null);
  };

  return (
    <div className="h-full bg-black overflow-y-auto pb-20 relative">
      {/* Header */}
      <div className="bg-[#0f0f0f] border-b border-[#2a2a2a] px-4 py-4">
        <div className="flex items-center justify-between mb-3">
          <div>
            <h1 className="text-white font-black text-xl tracking-tight">Team Management</h1>
            <p className="text-gray-500 text-xs mt-0.5">Manage your mechanics</p>
          </div>
          <button
            onClick={() => setShowInviteModal(true)}
            className="bg-yellow-400 text-black px-3 py-2 rounded-lg font-black text-xs flex items-center gap-1.5"
          >
            <UserPlus className="w-4 h-4" />
            Invite
          </button>
        </div>
      </div>

      <div className="p-4 space-y-3">
        {MECHANICS.map((mechanic) => (
          <div key={mechanic.id} className="bg-[#0f0f0f] border border-[#2a2a2a] rounded-xl p-4">
            <div className="flex items-start justify-between mb-3">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-yellow-400/20 rounded-full flex items-center justify-center">
                  <User className="w-6 h-6 text-yellow-400" />
                </div>
                <div>
                  <h3 className="text-white font-bold text-sm">{mechanic.name}</h3>
                  <p className="text-gray-600 text-xs">{mechanic.id}</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <div className={`w-2 h-2 rounded-full ${
                  mechanic.status === 'active' ? 'bg-green-400 shadow-[0_0_6px_rgba(34,197,94,0.6)]' :
                  mechanic.status === 'busy' ? 'bg-orange-400' : 'bg-gray-600'
                }`} />
                <span className={`text-xs font-semibold ${
                  mechanic.status === 'active' ? 'text-green-400' :
                  mechanic.status === 'busy' ? 'text-orange-400' : 'text-gray-600'
                }`}>
                  {mechanic.status}
                </span>
              </div>
            </div>

            <div className="grid grid-cols-3 gap-3 mb-3">
              <div className="bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg p-2 text-center">
                <p className="text-yellow-400 font-black text-lg">{mechanic.rating}</p>
                <p className="text-gray-600 text-[10px]">Rating</p>
              </div>
              <div className="bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg p-2 text-center">
                <p className="text-orange-400 font-black text-lg">{mechanic.activeJobs}</p>
                <p className="text-gray-600 text-[10px]">Active</p>
              </div>
              <div className="bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg p-2 text-center">
                <p className="text-green-400 font-black text-lg">{mechanic.completed}</p>
                <p className="text-gray-600 text-[10px]">Done</p>
              </div>
            </div>

            <div className="flex gap-2">
              <button 
                onClick={() => setSelectedMechanic(mechanic)}
                className="flex-1 bg-[#1a1a1a] border border-[#2a2a2a] text-gray-600 py-2 rounded-lg text-xs font-bold hover:border-yellow-400/40 transition-colors flex items-center justify-center gap-1.5"
              >
                <MoreVertical className="w-4 h-4" />
                More
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Mechanic Details Sheet */}
      {selectedMechanic && (
        <div className="absolute inset-0 bg-black/90 flex items-end z-50" onClick={() => setSelectedMechanic(null)}>
          <div className="w-full bg-[#0f0f0f] rounded-t-3xl border-t border-[#2a2a2a] max-h-[85vh] flex flex-col" onClick={e => e.stopPropagation()}>
            {/* Handle */}
            <div className="w-10 h-1 bg-[#333] rounded-full mx-auto mt-3 mb-4" />
            
            {/* Header */}
            <div className="px-5 pb-4 border-b border-[#1a1a1a]">
              <div className="flex items-start gap-3 mb-4">
                <div className="w-14 h-14 bg-yellow-400/20 rounded-full flex items-center justify-center">
                  <User className="w-7 h-7 text-yellow-400" />
                </div>
                <div className="flex-1">
                  <h3 className="text-white font-black text-lg tracking-tight">{selectedMechanic.name}</h3>
                  <p className="text-gray-600 text-xs mb-1">{selectedMechanic.id}</p>
                  <div className="flex items-center gap-2">
                    <div className={`w-2 h-2 rounded-full ${
                      selectedMechanic.status === 'active' ? 'bg-green-400 shadow-[0_0_6px_rgba(34,197,94,0.6)]' :
                      selectedMechanic.status === 'busy' ? 'bg-orange-400' : 'bg-gray-600'
                    }`} />
                    <span className={`text-xs font-semibold capitalize ${
                      selectedMechanic.status === 'active' ? 'text-green-400' :
                      selectedMechanic.status === 'busy' ? 'text-orange-400' : 'text-gray-600'
                    }`}>
                      {selectedMechanic.status}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            {/* Scrollable Content */}
            <div className="flex-1 overflow-y-auto px-5 py-4 space-y-4" style={{ scrollbarWidth: 'none' }}>
              {/* Performance Stats */}
              <div>
                <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-3">Performance</p>
                <div className="grid grid-cols-3 gap-3">
                  <div className="bg-[#111] border border-[#1a1a1a] rounded-xl p-3 text-center">
                    <p className="text-yellow-400 font-black text-2xl mb-1">{selectedMechanic.rating}</p>
                    <p className="text-gray-600 text-[10px] uppercase tracking-wide">Rating</p>
                  </div>
                  <div className="bg-[#111] border border-[#1a1a1a] rounded-xl p-3 text-center">
                    <p className="text-orange-400 font-black text-2xl mb-1">{selectedMechanic.activeJobs}</p>
                    <p className="text-gray-600 text-[10px] uppercase tracking-wide">Active</p>
                  </div>
                  <div className="bg-[#111] border border-[#1a1a1a] rounded-xl p-3 text-center">
                    <p className="text-green-400 font-black text-2xl mb-1">{selectedMechanic.completed}</p>
                    <p className="text-gray-600 text-[10px] uppercase tracking-wide">Done</p>
                  </div>
                </div>
              </div>

              {/* Contact Info */}
              <div>
                <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-3">Contact</p>
                <div className="bg-[#111] border border-[#1a1a1a] rounded-xl p-4 space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-gray-500 text-xs">Email</span>
                    <span className="text-white text-xs font-semibold">{selectedMechanic.email}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-gray-500 text-xs">Phone</span>
                    <span className="text-white text-xs font-semibold">{selectedMechanic.phone}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-gray-500 text-xs">Joined</span>
                    <span className="text-white text-xs font-semibold">{selectedMechanic.joinedDate}</span>
                  </div>
                </div>
              </div>

              {/* Specialties */}
              <div>
                <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-3">Specialties</p>
                <div className="flex flex-wrap gap-2">
                  {selectedMechanic.specialties.map((specialty: string, idx: number) => (
                    <span key={idx} className="px-3 py-1.5 bg-yellow-400/10 border border-yellow-400/30 rounded-lg text-yellow-400 text-xs font-semibold">
                      {specialty}
                    </span>
                  ))}
                </div>
              </div>

              {/* Action Buttons */}
              <div className="grid grid-cols-2 gap-3 pt-2">
                <a 
                  href={`tel:${selectedMechanic.phone}`}
                  className="bg-yellow-400 text-black py-3 rounded-xl font-black text-xs uppercase tracking-wider flex items-center justify-center gap-2"
                >
                  <Phone className="w-4 h-4" />
                  Call
                </a>
                <button className="bg-[#111] border border-[#2a2a2a] text-white py-3 rounded-xl font-black text-xs uppercase tracking-wider flex items-center justify-center gap-2">
                  <MessageCircle className="w-4 h-4" />
                  Message
                </button>
              </div>

              {/* Remove from Team */}
              <button 
                onClick={() => setShowRemoveConfirm(true)}
                className="w-full bg-red-400/10 border border-red-400/30 text-red-400 py-3 rounded-xl font-black text-xs uppercase tracking-wider mb-4"
              >
                Remove from Team
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Remove Confirmation Modal */}
      {showRemoveConfirm && (
        <div className="absolute inset-0 bg-black/90 flex items-center justify-center z-[60] px-4">
          <div className="w-full max-w-sm bg-[#0f0f0f] border border-red-400/30 rounded-2xl p-5">
            <div className="w-12 h-12 bg-red-400/10 border border-red-400/30 rounded-full flex items-center justify-center mx-auto mb-4">
              <AlertCircle className="w-6 h-6 text-red-400" />
            </div>
            <h3 className="text-white font-black text-lg text-center mb-2">Remove Mechanic?</h3>
            <p className="text-gray-400 text-xs text-center mb-6">
              Are you sure you want to remove <span className="text-white font-semibold">{selectedMechanic?.name}</span> from your team? This action cannot be undone.
            </p>
            <div className="space-y-2">
              <button 
                onClick={handleRemoveMechanic}
                className="w-full bg-red-400 text-black py-3 rounded-xl font-black text-sm"
              >
                Yes, Remove
              </button>
              <button 
                onClick={() => setShowRemoveConfirm(false)}
                className="w-full bg-[#1a1a1a] border border-[#2a2a2a] text-white py-3 rounded-xl font-bold text-sm"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Invite Modal */}
      {showInviteModal && (
        <div className="absolute inset-0 bg-black/80 flex items-end z-50">
          <div className="w-full bg-[#0f0f0f] rounded-t-2xl border-t border-[#2a2a2a]">
            <div className="px-4 py-4 border-b border-[#2a2a2a] flex items-center justify-between">
              <h2 className="text-white font-black text-lg">Invite Mechanic</h2>
              <button onClick={() => setShowInviteModal(false)}>
                <X className="w-5 h-5 text-gray-600" />
              </button>
            </div>

            <div className="p-4 space-y-4">
              <div>
                <label className="text-gray-500 text-xs font-semibold mb-2 block">Email Address</label>
                <input
                  type="email"
                  placeholder="mechanic@example.com"
                  className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg px-4 py-3 text-white placeholder-gray-600 text-sm focus:outline-none focus:border-yellow-400/40"
                />
              </div>

              <div>
                <label className="text-gray-500 text-xs font-semibold mb-2 block">Full Name</label>
                <input
                  type="text"
                  placeholder="John Smith"
                  className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg px-4 py-3 text-white placeholder-gray-600 text-sm focus:outline-none focus:border-yellow-400/40"
                />
              </div>

              <button className="w-full bg-yellow-400 text-black py-3 rounded-lg font-black">
                Send Invitation
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Company Profile ──────────────────────────────────────────────────────────
function CompanyProfile({ navigateToTeam, navigateToEditProfile, navigateToEarnings, onLogout }: { 
  navigateToTeam: () => void;
  navigateToEditProfile: () => void;
  navigateToEarnings: () => void;
  onLogout?: () => void;
}) {
  const [showHelpModal, setShowHelpModal] = useState(false);

  return (
    <>
      {showHelpModal && <HelpSupportSheet role="company" onClose={() => setShowHelpModal(false)} />}
    <div className="h-full bg-[#080808] overflow-y-auto pb-20" style={{ scrollbarWidth: 'none' }}>
      {/* Header */}
      <div className="px-5 pt-4 pb-2">
        <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Company</p>
        <h2 className="text-white font-black text-base tracking-tight">Profile</h2>
      </div>

      {/* Hero Section */}
      <div className="px-5 pt-2 pb-5 flex flex-col items-center">
        <div className="relative mb-3">
          <div className="w-20 h-20 rounded-2xl bg-yellow-400/20 border-2 border-yellow-400/30 flex items-center justify-center">
            <Briefcase className="w-10 h-10 text-yellow-400" />
          </div>
          <div className="absolute -bottom-1 -right-1 w-6 h-6 bg-green-400 rounded-full border-2 border-[#080808] flex items-center justify-center">
            <span className="text-black text-[8px] font-black">✓</span>
          </div>
        </div>
        <h2 className="text-white font-black text-lg tracking-tight">Swift Mechanics Ltd</h2>
        <div className="flex items-center gap-1.5 mt-1.5">
          {[1,2,3,4,5].map(i => <Star key={i} className={`w-3.5 h-3.5 ${i <= 5 ? 'fill-yellow-400 text-yellow-400' : 'text-gray-600'}`} />)}
          <span className="text-yellow-400 text-[12px] font-semibold ml-1">4.8</span>
        </div>
      </div>

      <div className="px-5 space-y-3 pb-8">
        {/* Stats */}
        <div className="grid grid-cols-3 gap-2">
          {[
            { label: 'Total Jobs', value: '156' },
            { label: 'Avg Rating', value: '4.8' },
            { label: 'Response', value: '8 min' },
          ].map(({ label, value }) => (
            <div key={label} className="bg-[#0f0f0f] rounded-xl border border-[#1a1a1a] p-3 text-center">
              <p className="text-yellow-400 font-black text-lg">{value}</p>
              <p className="text-gray-600 text-[10px] mt-0.5">{label}</p>
            </div>
          ))}
        </div>

        {/* Edit Profile Button */}
        <button
          onClick={navigateToEditProfile}
          className="w-full bg-yellow-400 rounded-xl py-3.5 flex items-center justify-center gap-2 text-black text-[12px] font-black tracking-wide"
        >
          <Edit3 className="w-4 h-4" /> Edit Profile
        </button>

        {/* Company Details */}
        <div className="bg-[#0f0f0f] rounded-xl border border-[#1a1a1a] overflow-hidden">
          <div className="px-4 py-2.5 border-b border-[#1a1a1a]">
            <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Company Details</p>
          </div>
          <div className="p-4 space-y-2.5">
            <div className="flex justify-between"><span className="text-gray-500 text-[12px]">Company Name</span><span className="text-white text-[12px] font-semibold">Swift Mechanics Ltd</span></div>
            <div className="flex justify-between"><span className="text-gray-500 text-[12px]">Registration</span><span className="text-white text-[12px] font-semibold">12345678</span></div>
            <div className="flex justify-between"><span className="text-gray-500 text-[12px]">VAT Number</span><span className="text-gray-600 text-[12px]">Not registered</span></div>
            <div className="h-px bg-[#1e1e1e]" />
            <div className="flex justify-between"><span className="text-gray-500 text-[12px]">Base Location</span><span className="text-white text-[12px] font-semibold">Birmingham, UK</span></div>
            <div className="flex justify-between"><span className="text-gray-500 text-[12px]">Service Radius</span><span className="text-white text-[12px] font-semibold">50 miles</span></div>
          </div>
        </div>

        {/* Team Overview */}
        <div className="bg-[#0f0f0f] rounded-xl border border-[#1a1a1a] overflow-hidden">
          <div className="px-4 py-2.5 border-b border-[#1a1a1a]">
            <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Team Overview</p>
          </div>
          <div className="p-4 space-y-2.5">
            <div className="flex justify-between"><span className="text-gray-500 text-[12px]">Total Mechanics</span><span className="text-white text-[12px] font-semibold">{MECHANICS.length}</span></div>
            <div className="flex justify-between"><span className="text-gray-500 text-[12px]">Online Now</span><span className="text-green-400 text-[12px] font-semibold">{MECHANICS.filter(m => m.status === 'active').length}</span></div>
            <div className="flex justify-between"><span className="text-gray-500 text-[12px]">Active Jobs</span><span className="text-orange-400 text-[12px] font-semibold">{MECHANICS.reduce((sum, m) => sum + m.activeJobs, 0)}</span></div>
          </div>
        </div>

        {/* Bank & Billing */}
        <div className="bg-[#0f0f0f] rounded-xl border border-[#1a1a1a] overflow-hidden">
          <div className="px-4 py-2.5 border-b border-[#1a1a1a]">
            <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Bank & Billing</p>
          </div>
          <div className="p-4 space-y-2.5">
            <div className="flex justify-between"><span className="text-gray-500 text-[12px]">Bank</span><span className="text-white text-[12px] font-semibold">Barclays Business</span></div>
            <div className="flex justify-between"><span className="text-gray-500 text-[12px]">Account</span><span className="text-white text-[12px] font-semibold">•••• •••• 9876</span></div>
            <div className="flex justify-between"><span className="text-gray-500 text-[12px]">Sort Code</span><span className="text-white text-[12px] font-semibold">20-45-99</span></div>
            <div className="h-px bg-[#1e1e1e]" />
            <div className="flex justify-between"><span className="text-gray-500 text-[12px]">Billing Address</span><span className="text-white text-[12px] font-semibold text-right max-w-[60%]">45 Industrial Park, Birmingham B12 8QT</span></div>
          </div>
        </div>

        {/* Action Buttons */}
        <button 
          onClick={navigateToEarnings}
          className="w-full bg-[#0f0f0f] border border-[#1e1e1e] rounded-xl py-3.5 flex items-center gap-3 px-4 hover:border-yellow-400/30 transition-colors"
        >
          <div className="w-8 h-8 bg-yellow-400/10 rounded-lg flex items-center justify-center flex-shrink-0">
            <DollarSign className="w-4 h-4 text-yellow-400" />
          </div>
          <div className="flex-1 text-left">
            <p className="text-white text-[12px] font-semibold">Earnings & Invoices</p>
            <p className="text-gray-600 text-[10px]">View company revenue & job history</p>
          </div>
          <ChevronRight className="w-4 h-4 text-gray-600" />
        </button>

        <button 
          onClick={navigateToTeam}
          className="w-full bg-[#0f0f0f] border border-[#1e1e1e] rounded-xl py-3.5 flex items-center gap-3 px-4 hover:border-yellow-400/30 transition-colors"
        >
          <div className="w-8 h-8 bg-yellow-400/10 rounded-lg flex items-center justify-center flex-shrink-0">
            <Users className="w-4 h-4 text-yellow-400" />
          </div>
          <div className="flex-1 text-left">
            <p className="text-white text-[12px] font-semibold">Manage Team</p>
            <p className="text-gray-600 text-[10px]">View & invite mechanics ({MECHANICS.length} total)</p>
          </div>
          <ChevronRight className="w-4 h-4 text-gray-600" />
        </button>

        <button 
          onClick={() => setShowHelpModal(true)}
          className="w-full bg-[#0f0f0f] border border-[#1e1e1e] rounded-xl py-3.5 flex items-center gap-3 px-4 hover:border-yellow-400/30 transition-colors"
        >
          <div className="w-8 h-8 bg-yellow-400/10 rounded-lg flex items-center justify-center flex-shrink-0">
            <HelpCircle className="w-4 h-4 text-yellow-400" />
          </div>
          <div className="flex-1 text-left">
            <p className="text-white text-[12px] font-semibold">Help & Support</p>
            <p className="text-gray-600 text-[10px]">Contact TruckFix support team</p>
          </div>
          <ChevronRight className="w-4 h-4 text-gray-600" />
        </button>

        <button 
          onClick={onLogout}
          className="w-full border border-red-500/20 rounded-xl py-3.5 flex items-center justify-center gap-2 text-red-400 text-[12px] font-semibold bg-red-500/5 active:scale-[0.98] transition-transform"
        >
          <LogOut className="w-4 h-4" /> Log Out
        </button>

        <p className="text-center text-gray-700 text-[10px] pt-1">TruckFix v2.4.1 · Member since Jan 2026</p>
      </div>
    </div>
    </>
  );
}

// ─── Company Edit Profile ──────────────────────────────����──────────────────────
function CompanyEditProfile({ navigateToProfile }: { navigateToProfile: () => void }) {
  // Track original values to detect changes that require re-approval
  const originalValues = {
    companyName: 'Swift Mechanics Ltd',
    hourlyRate: '75',
    emergencyRate: '95',
    calloutFee: '35',
  };
  
  const [companyName, setCompanyName] = useState('Swift Mechanics Ltd');
  const [hourlyRate, setHourlyRate] = useState('75');
  const [emergencyRate, setEmergencyRate] = useState('95');
  const [calloutFee, setCalloutFee] = useState('35');
  const [serviceRadius, setServiceRadius] = useState('50');
  const [showReapprovalWarning, setShowReapprovalWarning] = useState(false);

  // Check if company name or rates have changed (requires re-approval)
  const needsReapproval = 
    companyName !== originalValues.companyName ||
    Number(hourlyRate) !== Number(originalValues.hourlyRate) ||
    Number(emergencyRate) !== Number(originalValues.emergencyRate) ||
    Number(calloutFee) !== Number(originalValues.calloutFee);

  const handleSave = () => {
    if (needsReapproval) {
      setShowReapprovalWarning(true);
    } else {
      navigateToProfile();
    }
  };

  if (showReapprovalWarning) {
    return (
      <div className="h-full bg-[#080808] flex flex-col items-center justify-center px-8 text-center">
        <div className="relative mb-5">
          <div className="absolute inset-0 bg-yellow-400 rounded-full blur-[32px] opacity-20" />
          <div className="relative w-16 h-16 bg-[#0f0f0f] border-2 border-yellow-400 rounded-full flex items-center justify-center">
            <AlertCircle className="w-8 h-8 text-yellow-400" />
          </div>
        </div>
        <p className="text-white font-black text-xl mb-2">Profile Under Review</p>
        <p className="text-gray-400 text-sm leading-relaxed mb-6 max-w-[280px]">
          You've changed your company name or rates. Your profile must be re-approved by TruckFix before you can receive new jobs.
        </p>
        <div className="w-full space-y-2.5">
          <button
            onClick={navigateToProfile}
            className="w-full bg-yellow-400 text-black py-4 rounded-xl font-black text-sm tracking-widest uppercase"
          >
            I Understand
          </button>
          <p className="text-gray-600 text-[11px]">Approval typically takes 2-4 business hours</p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full bg-[#080808] flex flex-col">
      <div className="px-5 pt-5 pb-4 border-b border-[#1a1a1a] flex items-center gap-3 flex-shrink-0">
        <button onClick={navigateToProfile} className="w-8 h-8 rounded-xl bg-[#111] border border-[#2a2a2a] flex items-center justify-center">
          <ChevronLeft className="w-4 h-4 text-gray-400" />
        </button>
        <div>
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Company</p>
          <h2 className="text-white font-black text-base tracking-tight">Edit Profile</h2>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 py-5 pb-20 space-y-5" style={{ scrollbarWidth: 'none' }}>
        {/* Company Details */}
        <div>
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-3">Company Details</p>
          <div className="bg-yellow-400/5 border border-yellow-400/30 rounded-xl p-4 mb-3">
            <div className="flex items-start gap-2">
              <AlertCircle className="w-4 h-4 text-yellow-400 flex-shrink-0 mt-0.5" />
              <p className="text-yellow-400 text-[11px] leading-relaxed">
                Changing your company name requires re-approval. Your account will be temporarily restricted until verified.
              </p>
            </div>
          </div>
          <div className="space-y-3">
            <div className="space-y-1.5">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Company Name</label>
              <input 
                value={companyName}
                onChange={e => setCompanyName(e.target.value)}
                className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-yellow-400/60 text-sm" 
              />
            </div>
            <div className="space-y-1.5">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Registration Number</label>
              <input defaultValue="12345678" className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-yellow-400/60 text-sm" />
            </div>
            <div className="space-y-1.5">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">VAT Number <span className="text-gray-700 font-normal normal-case tracking-normal">(if applicable)</span></label>
              <input placeholder="e.g. GB 123 4567 89" className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm" />
            </div>
          </div>
        </div>

        {/* Service Details */}
        <div>
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-3">Service Coverage</p>
          <div className="space-y-3">
            <div className="space-y-1.5">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Base Location</label>
              <input defaultValue="Birmingham, UK" className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-yellow-400/60 text-sm" />
            </div>
            <div className="space-y-1.5">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Service Radius (miles)</label>
              <input 
                value={serviceRadius}
                onChange={e => setServiceRadius(e.target.value)}
                type="number"
                className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-yellow-400/60 text-sm" 
              />
            </div>
          </div>
        </div>

        {/* Rates */}
        <div>
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-3">Pricing</p>
          <div className="bg-yellow-400/5 border border-yellow-400/30 rounded-xl p-4 mb-3">
            <div className="flex items-start gap-2">
              <AlertCircle className="w-4 h-4 text-yellow-400 flex-shrink-0 mt-0.5" />
              <p className="text-yellow-400 text-[11px] leading-relaxed">
                Changing your rates requires re-approval to ensure pricing compliance.
              </p>
            </div>
          </div>
          <div className="space-y-3">
            <div className="space-y-1.5">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Hourly Rate (£)</label>
              <input 
                value={hourlyRate}
                onChange={e => setHourlyRate(e.target.value)}
                type="number" 
                className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-yellow-400/60 text-sm" 
              />
            </div>
            <div className="space-y-1.5">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Emergency Rate (£/hr)</label>
              <input 
                value={emergencyRate}
                onChange={e => setEmergencyRate(e.target.value)}
                type="number" 
                className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-yellow-400/60 text-sm" 
              />
            </div>
            <div className="space-y-1.5">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Call-out Fee (£)</label>
              <input 
                value={calloutFee}
                onChange={e => setCalloutFee(e.target.value)}
                type="number" 
                className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-yellow-400/60 text-sm" 
              />
            </div>
          </div>
        </div>

        {/* Bank & Billing */}
        <div>
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-3">Bank & Billing</p>
          <div className="space-y-3">
            <div className="space-y-1.5">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Bank Name</label>
              <input defaultValue="Barclays Business" className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-yellow-400/60 text-sm" />
            </div>
            <div className="space-y-1.5">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Account Number</label>
              <input defaultValue="••••9876" type="password" className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-yellow-400/60 text-sm" />
            </div>
            <div className="space-y-1.5">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Sort Code</label>
              <input defaultValue="20-45-99" className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-yellow-400/60 text-sm" />
            </div>
            <div className="h-px bg-[#1a1a1a]" />
            <div className="space-y-1.5">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Billing Address</label>
              <input defaultValue="45 Industrial Park, Birmingham B12 8QT" className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-yellow-400/60 text-sm" />
            </div>
          </div>
        </div>

        <div className="h-4" />
      </div>

      <div className="px-5 pb-6 pt-3 border-t border-[#1a1a1a] space-y-2.5 flex-shrink-0">
        <button onClick={handleSave} className="w-full bg-yellow-400 text-black py-4 rounded-xl font-black text-sm tracking-widest uppercase">
          Save Changes
        </button>
        <button onClick={navigateToProfile} className="w-full py-3 text-gray-600 text-[12px] font-semibold">
          Cancel
        </button>
      </div>
    </div>
  );
}

// ─── Earnings ─────────────────────────────────────────────────────────────────
const COMPLETED_JOBS = [
  { id: 'TF-8810', truck: 'Rigid 8T · GP 221-560', issue: 'Fuel system fault', mechanic: 'Jake Wilson', date: '7 Mar 2026', gross: 185, net: 163, rating: 5, hours: '1h 45m' },
  { id: 'TF-8797', truck: 'Flatbed · WC 334-112',  issue: 'Tyre replacement x2', mechanic: 'Jake Wilson', date: '5 Mar 2026', gross: 140, net: 123, rating: 5, hours: '55m' },
  { id: 'TF-8782', truck: 'Tautliner · CA 100-221',issue: 'Air brake adjustment', mechanic: 'Dan McCarthy', date: '3 Mar 2026', gross: 220, net: 194, rating: 4, hours: '2h 10m' },
  { id: 'TF-8771', truck: 'Tanker · KZN 44-310',   issue: 'Coolant system flush', mechanic: 'Sam Hughes', date: '28 Feb 2026',gross: 165, net: 145, rating: 5, hours: '1h 20m' },
  { id: 'TF-8760', truck: 'Rigid 18T · WC 887-002',issue: 'Engine diagnostics',  mechanic: 'Jake Wilson', date: '25 Feb 2026',gross: 95,  net: 84,  rating: 4, hours: '40m' },
  { id: 'TF-8744', truck: 'Flatbed · GP 551-889',  issue: 'Suspension repair',   mechanic: 'Dan McCarthy', date: '21 Feb 2026',gross: 310, net: 273, rating: 5, hours: '3h 05m' },
];

const MONTHLY_BARS = [
  { month: 'Oct', net: 820  },
  { month: 'Nov', net: 1140 },
  { month: 'Dec', net: 960  },
  { month: 'Jan', net: 1380 },
  { month: 'Feb', net: 1050 },
  { month: 'Mar', net: 480, current: true },
];

function CompanyEarnings({ navigateToProfile }: { navigateToProfile: () => void }) {
  const [invoiceJob, setInvoiceJob] = useState<typeof COMPLETED_JOBS[0] | null>(null);
  const marchGross = COMPLETED_JOBS.filter(j => j.date.includes('Mar')).reduce((s, j) => s + j.gross, 0);
  const marchNet   = COMPLETED_JOBS.filter(j => j.date.includes('Mar')).reduce((s, j) => s + j.net, 0);
  const allTimeNet = COMPLETED_JOBS.reduce((s, j) => s + j.net, 0);
  const maxBar = Math.max(...MONTHLY_BARS.map(b => b.net));

  return (
    <div className="h-full bg-[#080808] flex flex-col relative">
      {/* Header */}
      <div className="px-5 pt-5 pb-4 border-b border-[#1a1a1a] flex items-center gap-3 flex-shrink-0">
        <button onClick={navigateToProfile} className="w-8 h-8 rounded-xl bg-[#111] border border-[#2a2a2a] flex items-center justify-center">
          <ChevronLeft className="w-4 h-4 text-gray-400" />
        </button>
        <div>
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Company</p>
          <h2 className="text-white font-black text-base tracking-tight">Earnings &amp; Invoices</h2>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 py-4 space-y-4" style={{ scrollbarWidth: 'none' }}>
        {/* Summary cards */}
        <div className="grid grid-cols-3 gap-2">
          {[
            { label: 'Mar Gross', value: `£${marchGross}`, sub: 'Before platform fee' },
            { label: 'Mar Net',   value: `£${marchNet}`,   sub: 'After 12% fee' },
            { label: 'All-time',  value: `£${allTimeNet}`, sub: 'Net since Mar 2026' },
          ].map(({ label, value, sub }) => (
            <div key={label} className="bg-[#0f0f0f] rounded-xl border border-[#1a1a1a] p-3 text-center">
              <p className="text-yellow-400 font-black text-[15px]">{value}</p>
              <p className="text-gray-500 text-[9px] mt-0.5 uppercase tracking-wide font-semibold">{label}</p>
              <p className="text-gray-700 text-[9px] mt-0.5">{sub}</p>
            </div>
          ))}
        </div>

        {/* Monthly bar chart */}
        <div className="bg-[#0f0f0f] rounded-xl border border-[#1a1a1a] p-4">
          <div className="flex items-center justify-between mb-3">
            <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Monthly Net Income</p>
            <p className="text-gray-600 text-[10px]">Last 6 months</p>
          </div>
          <div className="flex items-end gap-2 h-[90px]">
            {MONTHLY_BARS.map(bar => {
              const pct = (bar.net / maxBar) * 100;
              return (
                <div key={bar.month} className="flex-1 flex flex-col items-center gap-1.5">
                  <p className={`text-[8px] font-black leading-none ${bar.current ? 'text-yellow-400' : 'text-gray-700'}`}>
                    £{bar.net >= 1000 ? (bar.net / 1000).toFixed(1) + 'k' : bar.net}
                  </p>
                  <div className="w-full flex items-end" style={{ height: 56 }}>
                    <div
                      className={`w-full rounded-t-md ${bar.current ? 'bg-yellow-400' : 'bg-[#222]'}`}
                      style={{ height: `${Math.max(pct, 4)}%` }}
                    />
                  </div>
                  <p className={`text-[9px] font-semibold ${bar.current ? 'text-yellow-400' : 'text-gray-600'}`}>{bar.month}</p>
                </div>
              );
            })}
          </div>
          <p className="text-gray-700 text-[9px] mt-2 text-center">12% platform fee already deducted from net figures</p>
        </div>

        {/* Completed Jobs list */}
        <div>
          <div className="flex items-center justify-between mb-2.5">
            <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Completed Jobs</p>
            <span className="text-gray-600 text-[10px]">{COMPLETED_JOBS.length} jobs</span>
          </div>
          <div className="space-y-2.5">
            {COMPLETED_JOBS.map(job => (
              <div key={job.id} className="bg-[#0f0f0f] rounded-xl border border-[#1a1a1a] overflow-hidden">
                <div className="p-3.5">
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex-1 min-w-0 pr-2">
                      <div className="flex items-center gap-1.5 mb-0.5">
                        <span className="text-gray-600 text-[10px] font-mono">{job.id}</span>
                        <span className="text-gray-700 text-[10px]">·</span>
                        <span className="text-gray-500 text-[10px]">{job.date}</span>
                      </div>
                      <p className="text-white text-[12px] font-semibold mb-0.5">{job.truck}</p>
                      <p className="text-gray-500 text-[11px]">{job.issue}</p>
                    </div>
                    <div className="text-right flex-shrink-0">
                      <p className="text-yellow-400 font-black text-[15px]">£{job.net}</p>
                      <p className="text-gray-600 text-[9px]">net earned</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2 mb-3">
                    <div className="flex items-center gap-0.5">
                      {[1,2,3,4,5].map(s => (
                        <Star key={s} className={`w-2.5 h-2.5 ${s <= job.rating ? 'fill-yellow-400 text-yellow-400' : 'text-gray-700'}`} />
                      ))}
                    </div>
                    <span className="text-gray-600 text-[10px]">·</span>
                    <span className="text-gray-500 text-[10px]">{job.mechanic}</span>
                    <span className="text-gray-600 text-[10px]">·</span>
                    <Clock className="w-2.5 h-2.5 text-gray-600 flex-shrink-0" />
                    <span className="text-gray-500 text-[10px]">{job.hours}</span>
                  </div>
                  <div className="pt-2.5 border-t border-[#1a1a1a]">
                    <button
                      onClick={() => setInvoiceJob(job)}
                      className="w-full bg-[#111] border border-[#2a2a2a] hover:border-yellow-400/40 rounded-lg px-2.5 py-2 transition-colors group"
                    >
                      <div className="space-y-0.5 mb-2">
                        <div className="flex justify-between">
                          <span className="text-gray-600 text-[10px]">Gross</span>
                          <span className="text-white text-[10px] font-semibold">£{job.gross}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600 text-[10px]">Fee (12%)</span>
                          <span className="text-gray-500 text-[10px]">-£{job.gross - job.net}</span>
                        </div>
                        <div className="flex justify-between border-t border-[#2a2a2a] pt-0.5 mt-0.5">
                          <span className="text-yellow-400 text-[10px] font-black">Net</span>
                          <span className="text-yellow-400 text-[10px] font-black">£{job.net}</span>
                        </div>
                      </div>
                      <div className="flex items-center justify-center gap-1.5 pt-1.5 border-t border-[#1e1e1e]">
                        <FileText className="w-3.5 h-3.5 text-gray-500 group-hover:text-yellow-400 transition-colors" />
                        <span className="text-gray-400 group-hover:text-yellow-400 text-[11px] font-semibold transition-colors">View Invoice</span>
                      </div>
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
        <div className="h-2" />
      </div>

      {/* Invoice sheet */}
      {invoiceJob && (() => {
        const handleDownloadPDF = () => {
          const invoiceHTML = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Invoice INV-${invoiceJob.id}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { 
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif; 
      background: #fff; 
      color: #000; 
      padding: 50px;
      line-height: 1.6;
    }
    .invoice-container { max-width: 900px; margin: 0 auto; }
    
    .header { 
      display: flex; 
      justify-content: space-between; 
      align-items: flex-start;
      margin-bottom: 40px; 
      padding-bottom: 30px; 
      border-bottom: 4px solid #000;
    }
    .logo-container {
      display: flex;
      align-items: center;
    }
    .logo-image {
      height: 65px;
      width: auto;
      object-fit: contain;
    }
    .invoice-info { text-align: right; }
    .invoice-no { 
      font-size: 28px; 
      font-weight: 900; 
      color: #000;
      margin-bottom: 4px;
    }
    .invoice-date { 
      font-size: 13px; 
      color: #666;
      font-weight: 500;
    }
    
    .details { 
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 20px; 
      margin-bottom: 40px; 
    }
    .details-box { 
      background: #f8f8f8; 
      padding: 20px; 
      border-radius: 8px;
      border: 1px solid #e5e5e5;
    }
    .details-title { 
      font-size: 10px; 
      color: #666; 
      text-transform: uppercase; 
      letter-spacing: 1px;
      margin-bottom: 12px; 
      font-weight: 700;
    }
    .details-name {
      font-weight: 700;
      font-size: 16px;
      margin-bottom: 6px;
      color: #000;
    }
    .details-info {
      font-size: 13px;
      color: #666;
      margin-bottom: 3px;
    }
    .rating {
      color: #facc15;
      font-size: 14px;
      margin-top: 4px;
    }
    
    .job-info { 
      background: #fffbeb; 
      padding: 20px; 
      border-radius: 8px; 
      margin-bottom: 30px;
      border: 2px solid #facc15;
    }
    .job-row {
      display: flex;
      justify-content: space-between;
      padding: 8px 0;
      border-bottom: 1px solid #fef3c7;
    }
    .job-row:last-child { border-bottom: none; }
    .job-label {
      color: #92400e;
      font-size: 12px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    .job-value {
      font-weight: 700;
      color: #000;
      font-size: 14px;
    }
    
    table { 
      width: 100%; 
      border-collapse: collapse; 
      margin: 30px 0;
      border: 1px solid #e5e5e5;
    }
    th { 
      background: #000; 
      color: #facc15;
      padding: 14px 16px; 
      text-align: left; 
      font-size: 11px; 
      text-transform: uppercase; 
      font-weight: 700;
      letter-spacing: 1px;
    }
    td { 
      padding: 14px 16px; 
      border-bottom: 1px solid #e5e5e5;
      font-size: 14px;
    }
    tr:last-child td { border-bottom: none; }
    .text-right { text-align: right; }
    
    .totals { 
      margin-left: auto; 
      width: 350px; 
      margin-top: 30px;
      border: 2px solid #e5e5e5;
      border-radius: 8px;
      overflow: hidden;
    }
    .totals-row { 
      display: flex; 
      justify-content: space-between; 
      padding: 14px 20px; 
      border-bottom: 1px solid #e5e5e5;
      font-size: 14px;
    }
    .totals-row:last-child { border-bottom: none; }
    .total-final { 
      background: #000; 
      color: #facc15;
      font-weight: 900; 
      font-size: 20px; 
      padding: 20px;
      display: flex;
      justify-content: space-between;
    }
    
    .status { 
      text-align: center; 
      margin: 40px 0; 
      padding: 18px; 
      background: #000;
      color: #facc15;
      font-weight: 900; 
      border-radius: 8px;
      font-size: 16px;
      letter-spacing: 2px;
    }
    
    .footer {
      text-align: center; 
      margin-top: 60px; 
      padding-top: 30px; 
      border-top: 2px solid #e5e5e5; 
      color: #999; 
      font-size: 11px;
    }
    .footer p { margin-bottom: 4px; }
    
    @media print {
      body { padding: 20px; }
      .invoice-container { max-width: 100%; }
    }
  </style>
</head>
<body>
  <div class="invoice-container">
    <div class="header">
      <div class="logo-container">
        <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='400' height='200' viewBox='0 0 400 200'%3E%3Cdefs%3E%3Cpattern id='stripes' patternUnits='userSpaceOnUse' width='60' height='60' patternTransform='rotate(45)'%3E%3Crect width='30' height='60' fill='%23facc15'/%3E%3Crect x='30' width='30' height='60' fill='%23000'/%3E%3C/pattern%3E%3C/defs%3E%3Crect width='400' height='200' fill='url(%23stripes)'/%3E%3Crect y='60' width='400' height='80' fill='%23000'/%3E%3Ctext x='50' y='130' font-family='Arial Black, sans-serif' font-size='52' font-weight='900' fill='white'%3ETRUCK%3C/text%3E%3Ctext x='245' y='130' font-family='Arial Black, sans-serif' font-size='52' font-weight='900' fill='%23facc15'%3EFIX%3C/text%3E%3C/svg%3E" alt="TruckFix" class="logo-image" />
      </div>
      <div class="invoice-info">
        <div class="invoice-no">INV-${invoiceJob.id}</div>
        <div class="invoice-date">Tax Invoice · ${invoiceJob.date}</div>
      </div>
    </div>
    
    <div class="details">
      <div class="details-box">
        <div class="details-title">From (Company)</div>
        <div class="details-name">United Mechanics Ltd</div>
        <div class="details-info">VAT Reg: GB 123 456 789</div>
        <div class="details-info">45 Industrial Park</div>
        <div class="details-info">Birmingham B12 8QT</div>
        <div class="details-info">United Kingdom</div>
      </div>
      <div class="details-box">
        <div class="details-title">Assigned Mechanic</div>
        <div class="details-name">${invoiceJob.mechanic}</div>
        <div class="details-info">Company Employee</div>
        <div class="rating">${'★'.repeat(invoiceJob.rating)}${'☆'.repeat(5-invoiceJob.rating)} ${invoiceJob.rating}.0</div>
      </div>
    </div>
    
    <div class="job-info">
      <div class="job-row">
        <span class="job-label">Job Reference</span>
        <span class="job-value">${invoiceJob.id}</span>
      </div>
      <div class="job-row">
        <span class="job-label">Vehicle</span>
        <span class="job-value">${invoiceJob.truck}</span>
      </div>
      <div class="job-row">
        <span class="job-label">Issue Description</span>
        <span class="job-value">${invoiceJob.issue}</span>
      </div>
      <div class="job-row">
        <span class="job-label">Time on Site</span>
        <span class="job-value">${invoiceJob.hours}</span>
      </div>
      <div class="job-row">
        <span class="job-label">Service Date</span>
        <span class="job-value">${invoiceJob.date}</span>
      </div>
    </div>
    
    <table>
      <thead>
        <tr>
          <th>Description</th>
          <th class="text-right">Unit Price</th>
          <th class="text-right">Total</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><strong>Labour Charges</strong></td>
          <td class="text-right">£${Math.round(invoiceJob.gross * 0.55)}</td>
          <td class="text-right">£${Math.round(invoiceJob.gross * 0.55)}</td>
        </tr>
        <tr>
          <td><strong>Emergency Call-out Fee</strong></td>
          <td class="text-right">£35</td>
          <td class="text-right">£35</td>
        </tr>
        <tr>
          <td><strong>Parts & Materials</strong></td>
          <td class="text-right">£${Math.round(invoiceJob.gross * 0.25)}</td>
          <td class="text-right">£${Math.round(invoiceJob.gross * 0.25)}</td>
        </tr>
      </tbody>
    </table>
    
    <div class="totals">
      <div class="totals-row">
        <span>Gross Total</span>
        <span><strong>£${invoiceJob.gross}</strong></span>
      </div>
      <div class="totals-row">
        <span>Platform Fee (12%)</span>
        <span><strong>-£${invoiceJob.gross - invoiceJob.net}</strong></span>
      </div>
      <div class="total-final">
        <span>NET PAYOUT</span>
        <span>£${invoiceJob.net}</span>
      </div>
    </div>
    
    <div class="status">✓ PAID · ${invoiceJob.date}</div>
    
    <div class="footer">
      <p><strong>TruckFix Platform</strong> · Emergency HGV Breakdown & Repair Services</p>
      <p>This is a digitally generated invoice from the TruckFix platform</p>
      <p>For support contact: support@truckfix.co.uk</p>
    </div>
  </div>
</body>
</html>`;

          const blob = new Blob([invoiceHTML], { type: 'text/html' });
          const url = URL.createObjectURL(blob);
          const link = document.createElement('a');
          link.href = url;
          link.download = `TruckFix_Invoice_${invoiceJob.id}.html`;
          document.body.appendChild(link);
          link.click();
          document.body.removeChild(link);
          URL.revokeObjectURL(url);
        };

        return (
          <div className="absolute inset-0 bg-black/80 flex items-end z-50 animate-in fade-in duration-200">
            <div className="w-full bg-[#0a0a0a] rounded-t-3xl border-t border-[#1a1a1a] max-h-[70%] flex flex-col animate-in slide-in-from-bottom duration-300">
              <div className="px-5 pt-4 pb-3 border-b border-[#1a1a1a] flex items-center justify-between flex-shrink-0">
                <div>
                  <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Invoice</p>
                  <h3 className="text-white font-black text-base">INV-{invoiceJob.id}</h3>
                </div>
                <button onClick={() => setInvoiceJob(null)} className="w-8 h-8 rounded-xl bg-[#111] border border-[#2a2a2a] flex items-center justify-center">
                  <X className="w-4 h-4 text-gray-400" />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto px-5 py-4 space-y-4" style={{ scrollbarWidth: 'none' }}>
                {/* Invoice info */}
                <div className="bg-[#0f0f0f] rounded-xl border border-[#1a1a1a] p-4 space-y-3">
                  <div className="flex justify-between">
                    <span className="text-gray-500 text-[11px]">Job ID</span>
                    <span className="text-white text-[11px] font-semibold font-mono">{invoiceJob.id}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500 text-[11px]">Date</span>
                    <span className="text-white text-[11px] font-semibold">{invoiceJob.date}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500 text-[11px]">Vehicle</span>
                    <span className="text-white text-[11px] font-semibold">{invoiceJob.truck}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500 text-[11px]">Issue</span>
                    <span className="text-white text-[11px] font-semibold">{invoiceJob.issue}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500 text-[11px]">Mechanic</span>
                    <span className="text-white text-[11px] font-semibold">{invoiceJob.mechanic}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500 text-[11px]">Duration</span>
                    <span className="text-white text-[11px] font-semibold">{invoiceJob.hours}</span>
                  </div>
                </div>

                {/* Cost breakdown */}
                <div className="bg-[#0f0f0f] rounded-xl border border-[#1a1a1a] p-4 space-y-2.5">
                  <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Cost Breakdown</p>
                  <div className="flex justify-between">
                    <span className="text-gray-500 text-[11px]">Gross Amount</span>
                    <span className="text-white text-[11px] font-semibold">£{invoiceJob.gross}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500 text-[11px]">Platform Fee (12%)</span>
                    <span className="text-gray-500 text-[11px]">-£{invoiceJob.gross - invoiceJob.net}</span>
                  </div>
                  <div className="pt-2.5 border-t border-[#2a2a2a] flex justify-between items-center">
                    <span className="text-yellow-400 text-[12px] font-black uppercase tracking-wider">Net Payout</span>
                    <span className="text-yellow-400 font-black text-xl">£{invoiceJob.net}</span>
                  </div>
                </div>

                {/* Rating */}
                <div className="bg-[#0f0f0f] rounded-xl border border-[#1a1a1a] p-4">
                  <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-2">Rating</p>
                  <div className="flex items-center gap-1">
                    {[1,2,3,4,5].map(s => (
                      <Star key={s} className={`w-4 h-4 ${s <= invoiceJob.rating ? 'fill-yellow-400 text-yellow-400' : 'text-gray-700'}`} />
                    ))}
                  </div>
                </div>
              </div>

              <div className="px-5 pb-6 pt-3 border-t border-[#1a1a1a] space-y-2.5 flex-shrink-0">
                <button onClick={handleDownloadPDF} className="w-full bg-yellow-400 text-black py-4 rounded-xl font-black text-sm tracking-widest uppercase flex items-center justify-center gap-2">
                  <Download className="w-4 h-4" />
                  Download Invoice
                </button>
                <button onClick={() => setInvoiceJob(null)} className="w-full py-3 text-gray-600 text-[12px] font-semibold">
                  Close
                </button>
              </div>
            </div>
          </div>
        );
      })()}
    </div>
  );
}

// ─── Help & Support Sheet ─────────────────────────────────────────────────────────
function HelpSupportSheet({ role, onClose }: { role: 'company' | 'mechanic-employee'; onClose: () => void }) {
  const [category, setCategory] = useState<string | null>(null);
  const [message, setMessage] = useState('');
  const [sent, setSent] = useState(false);

  const categories = [
    { id: 'technical', label: 'Technical Issue', icon: Wrench },
    { id: 'payment',   label: 'Payment / Billing', icon: DollarSign },
    { id: 'account',   label: 'Account & Profile', icon: User },
    { id: 'job',       label: 'Job / Booking',     icon: Briefcase },
    { id: 'other',     label: 'Other',             icon: HelpCircle },
  ];

  if (sent) {
    return (
      <div className="absolute inset-0 bg-black/85 z-50 flex flex-col justify-end" onClick={onClose}>
        <div className="bg-[#0e0e0e] rounded-t-3xl border-t border-[#2a2a2a] p-6 flex flex-col items-center text-center" onClick={e => e.stopPropagation()}>
          <div className="flex justify-center mb-1 pt-1">
            <div className="w-10 h-1 bg-[#333] rounded-full" />
          </div>
          <div className="w-16 h-16 bg-green-400/15 rounded-2xl flex items-center justify-center mb-4 mt-4 border border-green-400/30">
            <CheckCircle className="w-8 h-8 text-green-400" />
          </div>
          <p className="text-white font-black text-[16px] mb-1.5">Message Sent!</p>
          <p className="text-gray-400 text-[12px] leading-relaxed mb-6">Our support team will respond within 24 hours via your registered email address.</p>
          <button onClick={onClose} className="w-full bg-yellow-400 text-black py-3.5 rounded-xl font-black text-[12px] tracking-widest uppercase">
            Done
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="absolute inset-0 bg-black/85 z-50 flex flex-col justify-end" onClick={onClose}>
      <div className="bg-[#0e0e0e] rounded-t-3xl border-t border-[#2a2a2a] flex flex-col max-h-[88%]" onClick={e => e.stopPropagation()}>
        <div className="flex justify-center pt-3 pb-1 flex-shrink-0">
          <div className="w-10 h-1 bg-[#333] rounded-full" />
        </div>
        <div className="px-5 pt-2 pb-4 border-b border-[#1a1a1a] flex items-center justify-between flex-shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-yellow-400/10 rounded-xl border border-yellow-400/20 flex items-center justify-center">
              <HelpCircle className="w-5 h-5 text-yellow-400" />
            </div>
            <div>
              <p className="text-white font-black text-[15px] tracking-tight">Help &amp; Support</p>
              <p className="text-gray-500 text-[10px]">We usually reply within 24 hours</p>
            </div>
          </div>
          <button onClick={onClose} className="w-8 h-8 bg-[#1a1a1a] rounded-xl flex items-center justify-center">
            <X className="w-3.5 h-3.5 text-gray-500" />
          </button>
        </div>
        <div className="overflow-y-auto flex-1 px-5 py-4 space-y-4" style={{ scrollbarWidth: 'none' }}>
          <div>
            <p className="text-gray-500 text-[10px] font-black uppercase tracking-widest mb-2.5">What's this about?</p>
            <div className="grid grid-cols-2 gap-2">
              {categories.map(c => {
                const Icon = c.icon;
                const sel = category === c.id;
                return (
                  <button
                    key={c.id}
                    onClick={() => setCategory(c.id)}
                    className={`flex items-center gap-2.5 px-3 py-3 rounded-xl border transition-all ${sel ? 'border-yellow-400/50 bg-yellow-400/8' : 'border-[#1e1e1e] bg-[#111]'}`}
                  >
                    <Icon className={`w-4 h-4 flex-shrink-0 ${sel ? 'text-yellow-400' : 'text-gray-500'}`} />
                    <span className={`text-[11px] font-semibold text-left ${sel ? 'text-yellow-400' : 'text-gray-400'}`}>{c.label}</span>
                  </button>
                );
              })}
            </div>
          </div>
          <div>
            <p className="text-gray-500 text-[10px] font-black uppercase tracking-widest mb-2.5">Your Message</p>
            <textarea
              value={message}
              onChange={e => setMessage(e.target.value)}
              placeholder="Describe your issue or question in as much detail as possible..."
              rows={5}
              className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/40 text-[12px] resize-none leading-relaxed"
            />
            <p className="text-gray-600 text-[10px] mt-1.5">Sent from: {role === 'company' ? 'admin@swiftmechanics.co.uk · Company' : 'john.smith@swiftmechanics.co.uk · Mechanic Employee'}</p>
          </div>
        </div>
        <div className="px-5 pb-5 pt-3 border-t border-[#1a1a1a] flex-shrink-0 space-y-2">
          <button
            onClick={() => { if (category && message.trim()) setSent(true); }}
            className={`w-full py-3.5 rounded-xl font-black text-[12px] tracking-widest uppercase flex items-center justify-center gap-2 transition-opacity ${category && message.trim() ? 'bg-yellow-400 text-black' : 'bg-yellow-400/30 text-black/40 cursor-not-allowed'}`}
          >
            <Send className="w-4 h-4" /> Send Message
          </button>
          <button onClick={onClose} className="w-full py-2.5 text-gray-600 text-[12px] font-semibold">Cancel</button>
        </div>
      </div>
    </div>
  );
}

// ─── Main Export ──────────────────────────────────────────────────────────────
export function CompanyApp({ screen: initialScreen, onLogout }: { screen: string; onLogout?: () => void }) {
  const [currentScreen, setCurrentScreen] = useState(initialScreen || 'company-dashboard');
  const [jobsFilter, setJobsFilter] = useState<string>('All');
  
  // Sync external navigation (sidebar) with internal state
  React.useEffect(() => {
    setCurrentScreen(initialScreen);
  }, [initialScreen]);
  
  // Navigation helpers
  const navigateToJobs = (filter?: string) => {
    setJobsFilter(filter || 'All');
    setCurrentScreen('company-jobs');
  };
  const navigateToTeam = () => setCurrentScreen('company-team');
  const navigateToProfile = () => setCurrentScreen('company-profile');
  const navigateToEditProfile = () => setCurrentScreen('company-edit-profile');
  const navigateToEarnings = () => setCurrentScreen('company-earnings');
  
  // Shared Bottom Tab Bar Component
  const TabBar = ({ activeScreen }: { activeScreen: string }) => {
    const tabs = [
      { id: 'company-dashboard', icon: LayoutDashboard, label: 'Dashboard' },
      { id: 'company-job-feed', icon: Search, label: 'Feed' },
      { id: 'company-jobs', icon: Briefcase, label: 'Jobs' },
      { id: 'company-team', icon: Users, label: 'Team' },
      { id: 'company-profile', icon: User, label: 'Profile' },
    ];

    return (
      <div className="flex-shrink-0 bg-[#080808] border-t border-[#1a1a1a] pb-2 pt-1">
        <div className="flex">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            // Keep profile tab active when viewing earnings or edit-profile
            const isActive = activeScreen === tab.id || 
              (tab.id === 'company-profile' && (activeScreen === 'company-earnings' || activeScreen === 'company-edit-profile'));
            return (
              <button
                key={tab.id}
                onClick={() => setCurrentScreen(tab.id)}
                className="flex-1 flex flex-col items-center gap-1 py-2 relative"
              >
                <div className={`w-7 h-7 rounded-xl flex items-center justify-center transition-colors ${isActive ? 'bg-yellow-400' : ''}`}>
                  <Icon className={`w-3.5 h-3.5 ${isActive ? 'text-black' : 'text-gray-600'}`} strokeWidth={isActive ? 2.5 : 2} />
                  {tab.id === 'company-jobs' && PENDING_REVIEW_JOBS.length > 0 && (
                    <span className="absolute -top-0.5 -right-0.5 w-4 h-4 bg-red-500 rounded-full text-white text-[9px] font-black flex items-center justify-center">
                      {PENDING_REVIEW_JOBS.length}
                    </span>
                  )}
                </div>
                <span className={`text-[8px] font-semibold transition-colors ${isActive ? 'text-yellow-400' : 'text-gray-700'}`}>
                  {tab.label}
                </span>
              </button>
            );
          })}
        </div>
      </div>
    );
  };

  // Render current screen without its own tab bar
  const renderScreen = () => {
    switch (currentScreen) {
      case 'company-dashboard':
        return <CompanyDashboard navigateToJobs={navigateToJobs} navigateToTeam={navigateToTeam} />;
      case 'company-job-feed':
        return <CompanyJobFeed />;
      case 'company-jobs':
        return <CompanyJobs initialFilter={jobsFilter} />;
      case 'company-team':
        return <CompanyTeam />;
      case 'company-earnings':
        return <CompanyEarnings navigateToProfile={navigateToProfile} />;
      case 'company-profile':
        return <CompanyProfile navigateToTeam={navigateToTeam} navigateToEditProfile={navigateToEditProfile} navigateToEarnings={navigateToEarnings} onLogout={onLogout} />;
      case 'company-edit-profile':
        return <CompanyEditProfile navigateToProfile={navigateToProfile} />;
      default:
        return <CompanyDashboard navigateToJobs={navigateToJobs} navigateToTeam={navigateToTeam} />;
    }
  };

  return (
    <div className="h-full flex flex-col relative">
      {renderScreen()}
      <TabBar activeScreen={currentScreen} />
    </div>
  );
}
