import React, { useState, useEffect, useRef } from 'react';
import {
  LayoutDashboard, PlusCircle, Navigation, User, Wrench, Bell,
  MapPin, ChevronRight, Clock, AlertTriangle, CheckCircle, Zap,
  Truck, Phone, Star, CreditCard, Building2, X, ArrowUp, Settings,
  FileText, TrendingUp, Calendar, Shield, Edit3, LogOut, Package,
  ChevronDown, ChevronUp, AlertCircle, Check, Lock, Search, Crosshair,
  Camera, ImageIcon, UserCircle, MessageCircle, ExternalLink, Download, FileCheck, ArrowLeft,
  HelpCircle, Send, Briefcase, DollarSign
} from 'lucide-react';
import { ChatScreen, CancelJobSheet, NotificationsScreen, PaymentMethodsScreen, VehicleFleetScreen } from '../shared/TruckFixFeatures';

const MECHANIC_IMG = "https://images.unsplash.com/photo-1615906655593-ad0386982a0f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYWxlJTIwbWVjaGFuaWMlMjBwb3J0cmFpdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NzI5MTk3NjB8MA&ixlib=rb-4.1.0&q=80&w=400";

function PrimaryBtn({ children, onClick, className = '' }: any) {
  return (
    <button onClick={onClick} className={`w-full bg-yellow-400 text-black py-4 rounded-xl font-black text-sm tracking-widest uppercase active:scale-[0.98] transition-transform ${className}`}>
      {children}
    </button>
  );
}

function Input({ label, placeholder, type = 'text' }: any) {
  return (
    <div className="space-y-1.5">
      {label && <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">{label}</label>}
      <input type={type} placeholder={placeholder} className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm" />
    </div>
  );
}

function MapPreview({ height = 180, showRoute = false }: { height?: number; showRoute?: boolean }) {
  return (
    <div className="relative rounded-xl overflow-hidden border border-[#2a2a2a]" style={{ height }}>
      <div className="absolute inset-0 bg-[#0d1520]" />
      <div className="absolute inset-0" style={{ backgroundImage: 'linear-gradient(#1a2535 1px, transparent 1px), linear-gradient(90deg, #1a2535 1px, transparent 1px)', backgroundSize: '28px 28px' }} />
      <svg className="absolute inset-0 w-full h-full" viewBox={`0 0 390 ${height}`} preserveAspectRatio="none">
        {/* Roads */}
        <path d={`M0 ${height * 0.5} Q130 ${height * 0.42} 195 ${height * 0.5} Q260 ${height * 0.58} 390 ${height * 0.5}`} stroke="#1e3a4f" strokeWidth="14" fill="none" />
        <path d={`M0 ${height * 0.5} Q130 ${height * 0.42} 195 ${height * 0.5} Q260 ${height * 0.58} 390 ${height * 0.5}`} stroke="#264a5e" strokeWidth="7" fill="none" />
        <line x1="195" y1="0" x2="195" y2={height} stroke="#1e3a4f" strokeWidth="10" />
        <line x1="195" y1="0" x2="195" y2={height} stroke="#264a5e" strokeWidth="4" strokeDasharray="12 8" />
        <line x1="0" y1={height * 0.22} x2="390" y2={height * 0.22} stroke="#1a3040" strokeWidth="6" />
        <line x1="0" y1={height * 0.78} x2="390" y2={height * 0.78} stroke="#1a3040" strokeWidth="6" />
        {showRoute && <path d="M75 140 Q195 60 315 145" stroke="#FBBF24" strokeWidth="2.5" fill="none" strokeDasharray="8 5" opacity="0.8" />}
        {/* Origin pin */}
        <circle cx="75" cy={height * 0.6} r="9" fill="#FBBF24" />
        <circle cx="75" cy={height * 0.6} r="4.5" fill="#000" />
        {/* Dest pin */}
        <circle cx="315" cy={height * 0.55} r="9" fill="#ef4444" />
        <circle cx="315" cy={height * 0.55} r="4" fill="#fff" />
        {/* Mechanic dot */}
        {showRoute && <circle cx="185" cy={height * 0.38} r="7" fill="#22c55e" />}
        {showRoute && <circle cx="185" cy={height * 0.38} r="3.5" fill="#fff" />}
      </svg>
      <div className="absolute bottom-2 left-3 text-[10px] text-gray-600 font-medium">TruckFix Maps</div>
      <div className="absolute top-2 right-2 bg-black/60 rounded-lg px-2 py-1 text-[10px] text-yellow-400 font-semibold border border-yellow-400/20">
        LIVE
      </div>
    </div>
  );
}

// ─── Dashboard ───────────────────────────────────────���────────────────────────────

// ─── Dashboard: Quotes for Posted Job ─────────────────────────────────────────
const POSTED_QUOTES = [
  { id:'q1', name:'James Mitchell',   rating:4.8, jobs:211, verified:true,  distance:'4.2 km', eta:'12 min', img:MECHANIC_IMG, labour:'£85', callout:'£35', parts:'£25', total:'£145', speciality:'Tyres & Suspension', responded:'2 min ago' },
  { id:'q2', name:'Tom Stevens',   rating:4.7, jobs:163, verified:true,  distance:'7.8 km', eta:'22 min', img:MECHANIC_IMG, labour:'£80', callout:'£35', parts:'£20', total:'£135', speciality:'Tyres & Axles',       responded:'5 min ago' },
  { id:'q3', name:'Paul Davies',  rating:4.5, jobs:98,  verified:false, distance:'11 km',  eta:'31 min', img:MECHANIC_IMG, labour:'£70', callout:'£30', parts:'£18', total:'£118', speciality:'General HGV',          responded:'9 min ago' },
];

function DashboardJobSheet({ job, onClose, onOpenChat, onCancel }: { job: any; onClose: () => void; onOpenChat?: () => void; onCancel?: () => void }) {
  const [expandedQuote, setExpandedQuote] = useState<string | null>(null);
  const [accepted, setAccepted] = useState<string | null>(null);
  const isPosted = job.status === 'POSTED';

  return (
    <div className="absolute inset-0 bg-black/85 z-50 flex flex-col justify-end" onClick={onClose}>
      <div className="bg-[#0e0e0e] rounded-t-3xl border-t border-[#2a2a2a] flex flex-col max-h-[90%]" onClick={e => e.stopPropagation()}>
        <div className="flex justify-center pt-3 pb-1 flex-shrink-0">
          <div className="w-10 h-1 bg-[#333] rounded-full" />
        </div>
        <div className="px-5 pt-2 pb-3.5 border-b border-[#1a1a1a] flex-shrink-0">
          <div className="flex items-start justify-between">
            <div className="flex-1 min-w-0 pr-3">
              <div className="flex flex-wrap items-center gap-1.5 mb-1.5">
                <span className="text-gray-500 text-[10px] font-mono">{job.id}</span>
                <span className={`text-[9px] font-black uppercase tracking-widest px-1.5 py-0.5 rounded-full border ${job.urgencyBg} ${job.urgencyColor}`}>{job.urgency}</span>
                <span className={`flex items-center gap-1 text-[9px] font-black uppercase tracking-wide ${job.statusColor}`}>
                  <div className={`w-1.5 h-1.5 rounded-full ${job.statusBg} ${isPosted ? 'animate-pulse' : ''}`} />
                  {job.status}
                </span>
              </div>
              <p className="text-white font-black text-[15px] tracking-tight">{job.truck}</p>
              <p className="text-gray-400 text-[11px] mt-0.5">{job.issue}</p>
            </div>
            <button onClick={onClose} className="w-8 h-8 bg-[#1a1a1a] rounded-xl flex items-center justify-center flex-shrink-0">
              <X className="w-3.5 h-3.5 text-gray-500" />
            </button>
          </div>
        </div>
        <div className="overflow-y-auto flex-1 px-5 py-4 space-y-3" style={{ scrollbarWidth: 'none' }}>
          {isPosted && !accepted && (
            <>
              <div className="flex items-center justify-between">
                <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Quotes Received</p>
                <span className="text-gray-500 text-[10px]">{POSTED_QUOTES.length} mechanics responded</span>
              </div>
              {POSTED_QUOTES.map((q, i) => {
                const isExpanded = expandedQuote === q.id;
                const isBest = i === 0;
                return (
                  <div key={q.id} className={`bg-[#111] rounded-xl border overflow-hidden ${isBest ? 'border-yellow-400/30' : 'border-[#1e1e1e]'}`}>
                    {isBest && (
                      <div className="bg-yellow-400/10 px-3 py-1 border-b border-yellow-400/20 flex items-center gap-1.5">
                        <Star className="w-3 h-3 fill-yellow-400 text-yellow-400" />
                        <span className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Fastest &amp; Highest Rated</span>
                      </div>
                    )}
                    <div className="p-3.5">
                      <div className="flex items-center gap-3 mb-3">
                        <img src={q.img} alt={q.name} className="w-11 h-11 rounded-xl object-cover flex-shrink-0 border border-[#2a2a2a]" />
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-1.5 mb-0.5">
                            <p className="text-white font-black text-[13px]">{q.name}</p>
                            {q.verified && <span className="text-[8px] font-black px-1.5 py-0.5 rounded bg-green-400/15 text-green-400 border border-green-400/30">VERIFIED</span>}
                          </div>
                          <div className="flex items-center gap-1.5 flex-wrap">
                            <Star className="w-3 h-3 fill-yellow-400 text-yellow-400" />
                            <span className="text-yellow-400 text-[11px] font-semibold">{q.rating}</span>
                            <span className="text-gray-500 text-[10px]">· {q.jobs} jobs · {q.speciality}</span>
                          </div>
                        </div>
                        <div className="text-right flex-shrink-0">
                          <p className="text-yellow-400 font-black text-[16px]">{q.total}</p>
                          <p className="text-gray-500 text-[10px]">{q.responded}</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-2 mb-3">
                        <div className="flex items-center gap-1.5 bg-[#0f0f0f] rounded-lg px-2.5 py-1.5 border border-[#1e1e1e]">
                          <Navigation className="w-3 h-3 text-orange-400" />
                          <span className="text-orange-400 text-[11px] font-black">ETA {q.eta}</span>
                        </div>
                        <div className="flex items-center gap-1.5 bg-[#0f0f0f] rounded-lg px-2.5 py-1.5 border border-[#1e1e1e]">
                          <MapPin className="w-3 h-3 text-gray-500" />
                          <span className="text-gray-400 text-[11px] font-semibold">{q.distance} away</span>
                        </div>
                      </div>
                      {isExpanded && (
                        <div className="bg-[#0d0d0d] rounded-xl border border-[#1e1e1e] p-3 mb-3">
                          <p className="text-gray-500 text-[10px] font-black uppercase tracking-widest mb-2">Quote Breakdown</p>
                          {[{ label:'Labour', val:q.labour },{ label:'Call-out Fee', val:q.callout },{ label:'Parts (est.)', val:q.parts }].map(row => (
                            <div key={row.label} className="flex justify-between mb-1.5 last:mb-0">
                              <span className="text-gray-400 text-[11px]">{row.label}</span>
                              <span className="text-white text-[11px] font-semibold">{row.val}</span>
                            </div>
                          ))}
                          <div className="flex justify-between border-t border-[#2a2a2a] pt-1.5 mt-1.5">
                            <span className="text-white text-[12px] font-black">Total</span>
                            <span className="text-yellow-400 text-[13px] font-black">{q.total}</span>
                          </div>
                        </div>
                      )}
                      <div className="flex gap-2">
                        <button onClick={() => setAccepted(q.id)} className="flex-1 bg-yellow-400 text-black py-2.5 rounded-lg font-black text-[12px] tracking-widest uppercase flex items-center justify-center gap-1.5 active:scale-[0.98] transition-transform">
                          <CheckCircle className="w-3.5 h-3.5" /> Accept · {q.total}
                        </button>
                        <button onClick={() => setExpandedQuote(isExpanded ? null : q.id)} className="bg-[#1a1a1a] border border-[#2a2a2a] px-3.5 rounded-lg flex items-center justify-center">
                          {isExpanded ? <ChevronUp className="w-4 h-4 text-gray-400" /> : <ChevronDown className="w-4 h-4 text-gray-400" />}
                        </button>
                      </div>
                    </div>
                  </div>
                );
              })}
            </>
          )}
          {isPosted && accepted && (
            <div className="text-center py-8">
              <div className="w-16 h-16 bg-green-400/15 rounded-2xl flex items-center justify-center mx-auto mb-4 border border-green-400/30">
                <CheckCircle className="w-8 h-8 text-green-400" />
              </div>
              <p className="text-white font-black text-[16px] mb-1.5">Quote Accepted!</p>
              <p className="text-gray-400 text-[12px] leading-relaxed">The mechanic has been notified. We'll notify you when they start their journey.</p>
            </div>
          )}
          {!isPosted && (
            <>
              <MapPreview height={140} showRoute={job.status === 'EN ROUTE'} />
              <div className="bg-[#111] rounded-xl border border-[#1e1e1e] p-3.5">
                <p className="text-gray-500 text-[10px] font-black uppercase tracking-widest mb-3">Status</p>
                {[
                  { label:'Job Posted',        done:true,  highlight:false },
                  { label:'Mechanic Assigned', done:true,  highlight:false },
                  { label:'En Route',          done:true,  highlight:job.status==='EN ROUTE' },
                  { label:'On Site',           done:job.status==='ON SITE', highlight:job.status==='ON SITE' },
                  { label:'Completed',         done:false, highlight:false },
                ].map((step, idx) => (
                  <div key={step.label} className="flex items-center gap-3 mb-2 last:mb-0">
                    <div className={`w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0 ${step.done ? (step.highlight ? 'bg-yellow-400' : 'bg-green-500') : 'bg-[#1a1a1a] border border-[#2a2a2a]'}`}>
                      {step.done ? <Check className="w-3 h-3 text-black" strokeWidth={3} /> : <div className="w-1.5 h-1.5 rounded-full bg-[#333]" />}
                    </div>
                    <span className={`text-[12px] font-semibold flex-1 ${step.done ? 'text-white' : 'text-gray-600'}`}>{step.label}</span>
                    {idx === 2 && job.status === 'EN ROUTE' && job.eta && (
                      <span className="text-orange-400 text-[10px] font-black">ETA {job.eta}</span>
                    )}
                  </div>
                ))}
              </div>
              <div className="bg-[#111] rounded-xl border border-[#1e1e1e] p-3.5 flex items-center gap-3">
                <img src={MECHANIC_IMG} alt="Mechanic" className="w-12 h-12 rounded-xl object-cover flex-shrink-0 border border-[#2a2a2a]" />
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-1.5 mb-0.5">
                    <p className="text-white font-black text-[13px]">{job.mechanic}</p>
                    <span className="text-[8px] font-black px-1.5 py-0.5 rounded bg-green-400/15 text-green-400 border border-green-400/30">VERIFIED</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <Star className="w-3 h-3 fill-yellow-400 text-yellow-400" />
                    <span className="text-yellow-400 text-[11px] font-semibold">4.9</span>
                    <span className="text-gray-500 text-[11px]">· 184 jobs</span>
                  </div>
                </div>
                <a href="tel:+447734567890" className="w-10 h-10 bg-yellow-400/10 border border-yellow-400/30 rounded-xl flex items-center justify-center flex-shrink-0">
                  <Phone className="w-4 h-4 text-yellow-400" />
                </a>
              </div>
            </>
          )}
        </div>
        <div className="px-5 pb-5 pt-3 border-t border-[#1a1a1a] flex-shrink-0">
          {!isPosted && (
            <div className="flex gap-2 mb-2">
              <button
                onClick={() => { onOpenChat?.(); onClose(); }}
                className="flex-1 bg-[#1a1a1a] border border-[#2a2a2a] text-white py-3 rounded-xl font-semibold text-[12px] tracking-wide flex items-center justify-center gap-2 active:scale-95 transition-transform"
              >
                <MessageCircle className="w-4 h-4 text-yellow-400" />
                Chat with Mechanic
              </button>
              <button
                onClick={() => { onCancel?.(); onClose(); }}
                className="flex-1 bg-red-500/10 border border-red-500/30 text-red-400 py-3 rounded-xl font-semibold text-[12px] tracking-wide active:scale-95 transition-transform"
              >
                Cancel Job
              </button>
            </div>
          )}
          <button onClick={onClose} className="w-full border border-[#2a2a2a] text-gray-500 py-3 rounded-xl font-semibold text-[12px] tracking-wide">
            Close
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Invoice Modal ────────────────────────────────────────────────────────────
// ─── Job Completion Approval & Review ────────────────���───────────────────────
function CompletionReviewSheet({ job, onClose, onComplete }: { job: any; onClose: () => void; onComplete: () => void }) {
  const [showApproval, setShowApproval] = useState(true);
  const [showReview, setShowReview] = useState(false);
  const [rating, setRating] = useState(0);
  const [reviewText, setReviewText] = useState('');
  const [reviewSubmitted, setReviewSubmitted] = useState(false);

  const handleApprove = () => {
    setShowApproval(false);
    setShowReview(true);
  };

  const handleSubmitReview = () => {
    if (rating > 0) {
      setReviewSubmitted(true);
      setTimeout(() => {
        onComplete();
        onClose();
      }, 1500);
    }
  };

  if (showApproval) {
    return (
      <div className="absolute inset-0 bg-black/90 z-50 flex flex-col justify-end" onClick={onClose}>
        <div className="bg-[#0e0e0e] rounded-t-3xl border-t border-[#2a2a2a] p-6 flex flex-col" onClick={e => e.stopPropagation()}>
          <div className="w-10 h-1 bg-[#333] rounded-full mx-auto mb-5" />
          <div className="w-16 h-16 bg-green-400/15 rounded-2xl flex items-center justify-center mb-4 border border-green-400/30 mx-auto">
            <CheckCircle className="w-8 h-8 text-green-400" />
          </div>
          <p className="text-white font-black text-[18px] tracking-tight text-center mb-2">Job Completed</p>
          <p className="text-gray-400 text-[13px] text-center mb-6 px-4">
            {job.mechanic} has marked this job as complete. Review the work and approve to release payment.
          </p>

          {/* Job Summary */}
          <div className="bg-[#111] rounded-xl border border-[#1e1e1e] p-4 mb-5">
            <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-3">Job Summary</p>
            <div className="space-y-2.5">
              {[
                { label: 'Vehicle', value: job.truck },
                { label: 'Mechanic', value: job.mechanic },
                { label: 'Total Cost', value: job.total || job.pay }
              ].map(({ label, value }) => (
                <div key={label} className="flex justify-between">
                  <span className="text-gray-500 text-[12px]">{label}</span>
                  <span className="text-white text-[12px] font-semibold">{value}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Payment Release Notice */}
          <div className="bg-yellow-400/10 border border-yellow-400/30 rounded-xl p-3 flex gap-2 mb-5">
            <AlertCircle className="w-4 h-4 text-yellow-400 flex-shrink-0 mt-0.5" />
            <p className="text-yellow-400 text-[11px] leading-relaxed">
              Funds will be released to the mechanic within 24 hours of approval
            </p>
          </div>

          {/* Approve Button */}
          <button
            onClick={handleApprove}
            className="w-full bg-green-400 text-black py-4 rounded-xl font-black text-sm tracking-widest uppercase"
          >
            Approve & Continue
          </button>
          <button onClick={onClose} className="w-full py-3 text-gray-600 text-[12px] font-semibold mt-2">
            Review Later
          </button>
        </div>
      </div>
    );
  }

  if (showReview) {
    return (
      <div className="absolute inset-0 bg-black/90 z-50 flex flex-col justify-end" onClick={onClose}>
        <div className="bg-[#0e0e0e] rounded-t-3xl border-t border-[#2a2a2a] p-6 flex flex-col" onClick={e => e.stopPropagation()}>
          {reviewSubmitted ? (
            <div className="flex flex-col items-center text-center py-6">
              <div className="w-16 h-16 bg-green-400/15 rounded-2xl flex items-center justify-center mb-4 border border-green-400/30">
                <CheckCircle className="w-8 h-8 text-green-400" />
              </div>
              <p className="text-white font-black text-lg mb-1">Review Submitted!</p>
              <p className="text-gray-400 text-[12px]">Payment will be released within 24 hours</p>
            </div>
          ) : (
            <>
              <div className="w-10 h-1 bg-[#333] rounded-full mx-auto mb-5" />
              <p className="text-white font-black text-[17px] tracking-tight text-center mb-2">Rate Mechanic</p>
              <p className="text-gray-500 text-[12px] text-center mb-5">How was your experience with {job.mechanic}?</p>
              
              {/* Star Rating */}
              <div className="flex justify-center gap-3 mb-6">
                {[1, 2, 3, 4, 5].map(star => (
                  <button
                    key={star}
                    onClick={() => setRating(star)}
                    className="transition-transform active:scale-95"
                  >
                    <Star
                      className={`w-10 h-10 ${star <= rating ? 'fill-yellow-400 text-yellow-400' : 'text-gray-700'}`}
                    />
                  </button>
                ))}
              </div>

              {/* Feedback Text */}
              <div className="space-y-2 mb-5">
                <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Feedback (Optional)</label>
                <textarea
                  value={reviewText}
                  onChange={e => setReviewText(e.target.value)}
                  placeholder="Share your experience with this mechanic..."
                  rows={3}
                  className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/40 text-[12px] resize-none"
                />
              </div>

              {/* Submit Button */}
              <button
                onClick={handleSubmitReview}
                disabled={rating === 0}
                className={`w-full py-4 rounded-xl font-black text-sm tracking-widest uppercase transition-opacity ${
                  rating > 0 ? 'bg-yellow-400 text-black' : 'bg-yellow-400/30 text-black/40 cursor-not-allowed'
                }`}
              >
                Submit Review
              </button>
              <button onClick={onClose} className="w-full py-3 text-gray-600 text-[12px] font-semibold mt-2">
                Skip for now
              </button>
            </>
          )}
        </div>
      </div>
    );
  }

  return null;
}

function InvoiceModal({ job, onClose }: { job: any; onClose: () => void }) {
  // Build invoice lines from job data
  const lines = [
    { desc: 'Call-out Fee',     qty: 1,   unit: 85,  total: 85  },
    { desc: 'Labour (1.5 hrs)', qty: 1.5, unit: 65,  total: 97.50 },
    ...(job.parts || []).map((part: any) => ({
      desc: part.name,
      qty: 1,
      unit: part.cost,
      total: part.cost
    }))
  ];
  const subtotal = lines.reduce((s, l) => s + l.total, 0);
  const vat      = +(subtotal * 0.20).toFixed(2);
  const grand    = subtotal + vat;

  const handleDownloadPDF = () => {
    const invoiceHTML = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Invoice ${job.invoiceNo}</title>
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
    .text-center { text-align: center; }
    
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
        <div class="invoice-no">${job.invoiceNo}</div>
        <div class="invoice-date">Tax Invoice · ${job.completedDate}</div>
      </div>
    </div>
    
    <div class="details">
      <div class="details-box">
        <div class="details-title">Billed To (Fleet Operator)</div>
        <div class="details-name">Logistix Transport</div>
        <div class="details-info">VAT Reg: GB 412 033 4501</div>
        <div class="details-info">Industrial Estate</div>
        <div class="details-info">Johannesburg, GP</div>
        <div class="details-info">South Africa</div>
      </div>
      <div class="details-box">
        <div class="details-title">Service Provider (Mechanic)</div>
        <div class="details-name">${job.mechanic}</div>
        <div class="details-info">TruckFix Verified Mechanic</div>
        <div class="rating">${'★'.repeat(job.rating)}${'☆'.repeat(5-job.rating)} ${job.rating}.0</div>
      </div>
    </div>
    
    <div class="job-info">
      <div class="job-row">
        <span class="job-label">Job Reference</span>
        <span class="job-value">${job.id}</span>
      </div>
      <div class="job-row">
        <span class="job-label">Vehicle</span>
        <span class="job-value">${job.truck}</span>
      </div>
      <div class="job-row">
        <span class="job-label">Service Date</span>
        <span class="job-value">${job.completedDate}</span>
      </div>
      <div class="job-row">
        <span class="job-label">Location</span>
        <span class="job-value">${job.location}</span>
      </div>
    </div>
    
    <table>
      <thead>
        <tr>
          <th>Description</th>
          <th class="text-center">Qty</th>
          <th class="text-right">Unit Price</th>
          <th class="text-right">Total</th>
        </tr>
      </thead>
      <tbody>
        ${lines.map(l => `<tr><td><strong>${l.desc}</strong></td><td class="text-center">${l.qty}</td><td class="text-right">£${l.unit}</td><td class="text-right">£${l.total.toLocaleString()}</td></tr>`).join('')}
      </tbody>
    </table>
    
    <div class="totals">
      <div class="totals-row">
        <span>Subtotal</span>
        <span><strong>£${subtotal.toLocaleString()}</strong></span>
      </div>
      <div class="totals-row">
        <span>VAT (20%)</span>
        <span><strong>£${vat.toLocaleString()}</strong></span>
      </div>
      <div class="total-final">
        <span>TOTAL DUE</span>
        <span>£${grand.toLocaleString()}</span>
      </div>
    </div>
    
    <div class="status">✓ PAID · ${job.completedDate}</div>
    
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
    const a = document.createElement('a');
    a.href = url;
    a.download = `TruckFix_Invoice_${job.invoiceNo}_${job.id}.html`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  return (
    <div className="absolute inset-0 z-40 bg-black/80 flex flex-col justify-end">
      <div className="bg-[#0d0d0d] rounded-t-3xl border-t border-[#2a2a2a] flex flex-col max-h-[92%]">
        <div className="flex justify-center pt-3 pb-1 flex-shrink-0">
          <div className="w-10 h-1 bg-[#333] rounded-full" />
        </div>
        <div className="px-5 py-3 border-b border-[#1a1a1a] flex items-center justify-between flex-shrink-0">
          <div className="flex items-center gap-2">
            <FileText className="w-4 h-4 text-yellow-400" />
            <div>
              <p className="text-white font-black text-sm">{job.invoiceNo}</p>
              <p className="text-gray-600 text-[10px]">Tax Invoice</p>
            </div>
          </div>
          <button onClick={onClose} className="w-7 h-7 bg-[#1a1a1a] rounded-full flex items-center justify-center">
            <X className="w-3.5 h-3.5 text-gray-500" />
          </button>
        </div>
        <div className="overflow-y-auto flex-1 px-5 py-4 space-y-4" style={{ scrollbarWidth: 'none' }}>
          <div className="grid grid-cols-2 gap-3">
            <div className="bg-[#111] rounded-xl p-3 border border-[#1e1e1e]">
              <p className="text-gray-600 text-[9px] uppercase tracking-widest mb-1.5">Billed To</p>
              <p className="text-white text-[11px] font-black">Logistix Transport</p>
              <p className="text-gray-600 text-[10px] mt-0.5">VAT: 4120334501</p>
              <p className="text-gray-600 text-[10px]">Johannesburg, GP</p>
            </div>
            <div className="bg-[#111] rounded-xl p-3 border border-[#1e1e1e]">
              <p className="text-gray-600 text-[9px] uppercase tracking-widest mb-1.5">Mechanic</p>
              <p className="text-white text-[11px] font-black">{job.mechanic}</p>
              <p className="text-gray-600 text-[10px] mt-0.5">TruckFix Verified</p>
              <div className="flex items-center gap-0.5 mt-1">
                {[1,2,3,4,5].map(s => (
                  <Star key={s} className={`w-2.5 h-2.5 ${s <= job.rating ? 'fill-yellow-400 text-yellow-400' : 'text-gray-700'}`} />
                ))}
                <span className="text-yellow-400 text-[9px] ml-0.5">{job.rating}.0</span>
              </div>
            </div>
          </div>
          <div className="bg-[#111] rounded-xl p-3 border border-[#1e1e1e] space-y-1.5">
            {[
              { label: 'Job Ref',   value: job.id,            mono: true  },
              { label: 'Vehicle',   value: job.truck,          mono: false },
              { label: 'Completed', value: job.completedDate,  mono: false },
              { label: 'Location',  value: job.location,       mono: false },
            ].map(({ label, value, mono }) => (
              <div key={label} className="flex justify-between">
                <span className="text-gray-600 text-[11px]">{label}</span>
                <span className={`text-white text-[11px] font-semibold ${mono ? 'font-mono' : ''}`}>{value}</span>
              </div>
            ))}
          </div>
          <div className="bg-[#111] rounded-xl border border-[#1e1e1e] overflow-hidden">
            <div className="px-3 py-2 bg-[#161616] border-b border-[#1e1e1e] grid grid-cols-12 gap-1">
              <span className="text-gray-600 text-[9px] uppercase tracking-widest col-span-5">Description</span>
              <span className="text-gray-600 text-[9px] uppercase tracking-widest col-span-2 text-center">Qty</span>
              <span className="text-gray-600 text-[9px] uppercase tracking-widest col-span-2 text-right">Unit</span>
              <span className="text-gray-600 text-[9px] uppercase tracking-widest col-span-3 text-right">Total</span>
            </div>
            {lines.map((l, i) => (
              <div key={i} className="px-3 py-2.5 grid grid-cols-12 gap-1 border-b border-[#1a1a1a] last:border-0">
                <span className="text-white text-[11px] col-span-5">{l.desc}</span>
                <span className="text-gray-500 text-[11px] col-span-2 text-center">{l.qty}</span>
                <span className="text-gray-500 text-[11px] col-span-2 text-right">£{l.unit}</span>
                <span className="text-white text-[11px] font-semibold col-span-3 text-right">£{l.total.toLocaleString()}</span>
              </div>
            ))}
          </div>
          <div className="bg-[#111] rounded-xl border border-[#1e1e1e] overflow-hidden">
            <div className="px-4 py-2.5 flex justify-between border-b border-[#1a1a1a]">
              <span className="text-gray-500 text-[11px]">Subtotal</span>
              <span className="text-white text-[11px] font-semibold">£{subtotal.toLocaleString()}</span>
            </div>
            <div className="px-4 py-2.5 flex justify-between border-b border-[#1a1a1a]">
              <span className="text-gray-500 text-[11px]">VAT (20%)</span>
              <span className="text-white text-[11px] font-semibold">£{vat.toLocaleString()}</span>
            </div>
            <div className="px-4 py-3 flex justify-between bg-yellow-400/5 border-t border-yellow-400/20">
              <span className="text-yellow-400 text-[12px] font-black uppercase tracking-wide">Total Due</span>
              <span className="text-yellow-400 font-black text-sm">£{grand.toLocaleString()}</span>
            </div>
          </div>
          <div className="flex items-center justify-center gap-2 py-2">
            <CheckCircle className="w-4 h-4 text-green-400" />
            <span className="text-green-400 text-[12px] font-black uppercase tracking-widest">PAID · {job.completedDate}</span>
          </div>
        </div>
        <div className="px-5 pb-5 pt-3 border-t border-[#1a1a1a] flex gap-2.5 flex-shrink-0">
          <button onClick={handleDownloadPDF} className="flex-1 flex items-center justify-center gap-2 bg-yellow-400 text-black py-3.5 rounded-xl font-black text-[12px] tracking-widest uppercase active:scale-[0.98] transition-transform">
            <Download className="w-4 h-4" />
            Download PDF
          </button>
          <button onClick={onClose} className="w-12 h-12 bg-[#111] border border-[#2a2a2a] rounded-xl flex items-center justify-center flex-shrink-0">
            <X className="w-4 h-4 text-gray-500" />
          </button>
        </div>
      </div>
    </div>
  );
}

function FleetDashboard({ setTab }: { setTab: (t: string) => void }) {
  const [jobView, setJobView] = useState<'active' | 'completed'>('active');
  const [invoiceJob, setInvoiceJob] = useState<any>(null);
  const [selectedJob, setSelectedJob] = useState<any>(null);
  const [completionReviewJob, setCompletionReviewJob] = useState<any>(null);
  const [showNotifications, setShowNotifications] = useState(false);
  const [showChat, setShowChat] = useState(false);
  const [showCancelSheet, setShowCancelSheet] = useState(false);
  const [chatJob, setChatJob] = useState<any>(null);

  const activeJobs = [
    {
      id: 'TF-8823', truck: 'WC 234-567 · Flatbed',
      issue: 'Brake system repair — awaiting your approval',
      mechanic: 'James M.', status: 'AWAITING APPROVAL', urgency: 'MEDIUM', eta: null, pay: '£275',
      statusColor: 'text-yellow-400', statusBg: 'bg-yellow-500', statusBorder: 'border-l-yellow-500',
      urgencyColor: 'text-blue-400', urgencyBg: 'bg-blue-400/15 border-blue-400/30',
    },
    {
      id: 'TF-8821', truck: 'CA 456-789 · Tautliner',
      issue: 'Engine overheating — M1 near Birmingham',
      mechanic: 'James M.', status: 'EN ROUTE', urgency: 'HIGH', eta: '18 min',
      statusColor: 'text-orange-400', statusBg: 'bg-orange-500', statusBorder: 'border-l-orange-500',
      urgencyColor: 'text-orange-400', urgencyBg: 'bg-orange-400/15 border-orange-400/30',
    },
    {
      id: 'TF-8819', truck: 'GP 112-033 · Rigid Truck',
      issue: 'Left rear tyre blowout — N14 off-ramp',
      mechanic: 'Awaiting mechanic…', status: 'POSTED', urgency: 'CRITICAL', eta: null,
      statusColor: 'text-red-400', statusBg: 'bg-red-500', statusBorder: 'border-l-red-500',
      urgencyColor: 'text-red-400', urgencyBg: 'bg-red-400/15 border-red-400/30',
    },
    {
      id: 'TF-8814', truck: 'KZN 78-99 · Tanker',
      issue: 'Air brake fault — Port of Durban',
      mechanic: 'Sipho M.', status: 'ON SITE', urgency: 'MEDIUM', eta: null,
      statusColor: 'text-green-400', statusBg: 'bg-green-500', statusBorder: 'border-l-green-500',
      urgencyColor: 'text-blue-400', urgencyBg: 'bg-blue-400/15 border-blue-400/30',
    },
  ];

  const completedJobs = [
    { id: 'TF-8800', truck: 'CA 456-789 · Tautliner',   issue: 'Coolant leak — radiator hose replaced',   mechanic: 'James M.', rating: 5, completedDate: '8 Mar 2026',  total: '£285', invoiceNo: 'INV-2026-0088', location: 'M1, Birmingham', parts: [{ name: 'Radiator hose', cost: 45 }, { name: 'Coolant (5L)', cost: 28 }] },
    { id: 'TF-8791', truck: 'GP 112-033 · Rigid Truck',  issue: 'Battery failure — new battery fitted',     mechanic: 'Tom S.',  rating: 5, completedDate: '5 Mar 2026',  total: '£210', invoiceNo: 'INV-2026-0085', location: 'M6, Manchester', parts: [{ name: 'Heavy-duty battery 12V', cost: 95 }] },
    { id: 'TF-8783', truck: 'KZN 78-99 · Tanker',        issue: 'Air brake actuator replaced',              mechanic: 'Paul K.',  rating: 4, completedDate: '2 Mar 2026',  total: '£425', invoiceNo: 'INV-2026-0081', location: 'A1, Leeds', parts: [{ name: 'Air brake actuator', cost: 185 }, { name: 'Brake line fittings', cost: 22 }] },
    { id: 'TF-8771', truck: 'WC 234-567 · Flatbed',      issue: 'Dual tyre blowout — 2 tyres replaced',    mechanic: 'Deon V.',   rating: 4, completedDate: '27 Feb 2026', total: '£170', invoiceNo: 'INV-2026-0077', location: 'N2 Somerset West, WC', parts: [{ name: 'Heavy-duty tyre 295/80R22.5', cost: 145 }, { name: 'Wheel valve', cost: 8 }] },
    { id: 'TF-8760', truck: 'FS 901-445 · Semi',         issue: 'Starter motor replaced',                  mechanic: 'Sipho M.',  rating: 5, completedDate: '22 Feb 2026', total: '£260', invoiceNo: 'INV-2026-0071', location: 'Bloemfontein CBD, FS', parts: [{ name: 'Starter motor assembly', cost: 125 }] },
  ];

  return (
    <div className="h-full bg-[#080808] flex flex-col overflow-y-auto relative" style={{ scrollbarWidth: 'none' }}>

      {/* Invoice modal */}
      {invoiceJob && <InvoiceModal job={invoiceJob} onClose={() => setInvoiceJob(null)} />}

      {/* Job detail sheet */}
      {selectedJob && <DashboardJobSheet 
        job={selectedJob} 
        onClose={() => setSelectedJob(null)} 
        onOpenChat={() => { setChatJob(selectedJob); setShowChat(true); setSelectedJob(null); }}
        onCancel={() => setShowCancelSheet(true)}
      />}

      {/* Completion review sheet */}
      {completionReviewJob && (
        <CompletionReviewSheet 
          job={completionReviewJob} 
          onClose={() => setCompletionReviewJob(null)}
          onComplete={() => {
            // Move job to completed and show success message
            setCompletionReviewJob(null);
          }}
        />
      )}

      {/* Notifications overlay */}
      {showNotifications && <NotificationsScreen onClose={() => setShowNotifications(false)} />}

      {/* Chat overlay */}
      {showChat && chatJob && <ChatScreen job={chatJob} onClose={() => {setShowChat(false); setChatJob(null);}} role="fleet" />}

      {/* Cancel job sheet */}
      {showCancelSheet && selectedJob && (
        <CancelJobSheet 
          job={selectedJob} 
          mechanicEnRoute={selectedJob.status === 'EN ROUTE'} 
          onClose={() => setShowCancelSheet(false)} 
          onConfirm={() => {
            setShowCancelSheet(false);
            setSelectedJob(null);
          }} 
        />
      )}

      {/* Header */}
      <div className="px-5 pt-4 pb-3 bg-[#080808] sticky top-0 z-10">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-gray-400 text-[11px] font-semibold uppercase tracking-widest">Good morning</p>
            <h2 className="text-white font-black text-xl tracking-tight">Logistix Transport</h2>
          </div>
          <div className="flex items-center gap-2.5">
            <button onClick={() => setShowNotifications(true)} className="relative w-9 h-9 bg-[#111] rounded-xl border border-[#1e1e1e] flex items-center justify-center">
              <Bell className="w-4 h-4 text-gray-400" />
              <div className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full border border-[#111]" />
            </button>
            <button onClick={() => setTab('profile')} className="w-9 h-9 bg-yellow-400 rounded-xl flex items-center justify-center hover:bg-yellow-300 transition-colors">
              <span className="text-black font-black text-xs">LT</span>
            </button>
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="px-5 pb-4">
        <div className="grid grid-cols-3 gap-2.5">
          {[
            { label: 'Active', value: '3', icon: Zap, color: 'text-yellow-400', dot: 'bg-yellow-400' },
            { label: 'Awaiting', value: '1', icon: AlertTriangle, color: 'text-red-400', dot: 'bg-red-500' },
            { label: 'This Month', value: '14', icon: CheckCircle, color: 'text-green-400', dot: 'bg-green-500' },
          ].map(({ label, value, icon: Icon, color, dot }) => (
            <div key={label} className="bg-[#0f0f0f] border border-[#1a1a1a] rounded-xl p-3">
              <div className="flex items-center gap-1.5 mb-2">
                <div className={`w-2 h-2 rounded-full ${dot}`} />
                <Icon className={`w-3 h-3 ${color}`} />
              </div>
              <p className={`font-black text-2xl ${color}`}>{value}</p>
              <p className="text-gray-600 text-[10px] font-medium uppercase tracking-wider mt-0.5">{label}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Awaiting Approval Banner */}
      {activeJobs.some(j => j.status === 'AWAITING APPROVAL') && (
        <div className="px-5 pb-4">
          <button 
            onClick={() => setCompletionReviewJob(activeJobs.find(j => j.status === 'AWAITING APPROVAL'))} 
            className="w-full bg-green-400/10 border-2 border-green-400/30 rounded-xl p-3.5 flex items-center gap-3 active:scale-[0.98] transition-transform"
          >
            <div className="w-10 h-10 bg-green-400/20 rounded-xl flex items-center justify-center flex-shrink-0">
              <CheckCircle className="w-5 h-5 text-green-400" />
            </div>
            <div className="flex-1 text-left">
              <p className="text-green-400 font-black text-sm tracking-tight">Job Awaiting Approval</p>
              <p className="text-green-400/70 text-[11px]">Tap to review & release payment</p>
            </div>
            <ChevronRight className="w-5 h-5 text-green-400" />
          </button>
        </div>
      )}

      {/* Post Job CTA */}
      <div className="px-5 pb-4">
        <button onClick={() => setTab('post-job')} className="w-full bg-yellow-400 rounded-xl p-4 flex items-center justify-between group">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 bg-black/20 rounded-xl flex items-center justify-center">
              <PlusCircle className="w-5 h-5 text-black" />
            </div>
            <div className="text-left">
              <p className="text-black font-black text-sm tracking-tight">Post a Breakdown Job</p>
              <p className="text-black/60 text-[11px]">Get mechanics responding in minutes</p>
            </div>
          </div>
          <ChevronRight className="w-5 h-5 text-black/60 group-hover:translate-x-0.5 transition-transform" />
        </button>
      </div>

      {/* ── Jobs section with Active / Completed toggle ── */}
      <div className="px-5 pb-2">

        {/* Segmented toggle header */}
        <div className="flex items-center justify-between mb-3">
          <div className="flex bg-[#111] border border-[#1e1e1e] rounded-xl p-0.5 gap-0.5">
            <button
              onClick={() => setJobView('active')}
              className={`px-3.5 py-1.5 rounded-lg text-[11px] font-black uppercase tracking-wide transition-all ${
                jobView === 'active' ? 'bg-yellow-400 text-black' : 'text-gray-600'
              }`}
            >
              Active
              <span className={`ml-1.5 text-[9px] px-1.5 py-0.5 rounded-full ${jobView === 'active' ? 'bg-black/20 text-black' : 'bg-[#1e1e1e] text-gray-600'}`}>
                {activeJobs.length}
              </span>
            </button>
            <button
              onClick={() => setJobView('completed')}
              className={`px-3.5 py-1.5 rounded-lg text-[11px] font-black uppercase tracking-wide transition-all ${
                jobView === 'completed' ? 'bg-yellow-400 text-black' : 'text-gray-600'
              }`}
            >
              Completed
              <span className={`ml-1.5 text-[9px] px-1.5 py-0.5 rounded-full ${jobView === 'completed' ? 'bg-black/20 text-black' : 'bg-[#1e1e1e] text-gray-600'}`}>
                {completedJobs.length}
              </span>
            </button>
          </div>
          {jobView === 'active' && (
            <button onClick={() => setTab('tracking')} className="text-yellow-400 text-[11px] font-semibold">View All</button>
          )}
        </div>

        {/* ── Active jobs list ── */}
        {jobView === 'active' && (
          <div className="space-y-2.5">
            {activeJobs.map(job => (
              <button
                key={job.id}
                onClick={() => {
                  if (job.status === 'AWAITING APPROVAL') {
                    setCompletionReviewJob(job);
                  } else {
                    setSelectedJob(job);
                  }
                }}
                className={`w-full text-left bg-[#0f0f0f] rounded-xl border border-[#1e1e1e] border-l-4 ${job.statusBorder} overflow-hidden transition-opacity active:opacity-80`}
              >
                <div className="p-3.5">
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex items-center gap-2">
                      <span className="text-gray-600 text-[10px] font-mono">{job.id}</span>
                      <span className={`text-[9px] font-black uppercase tracking-widest px-1.5 py-0.5 rounded-full border ${job.urgencyBg} ${job.urgencyColor}`}>
                        {job.urgency}
                      </span>
                    </div>
                    <span className={`flex items-center gap-1 px-2 py-0.5 rounded-lg text-[9px] font-black uppercase tracking-wide ${job.statusColor}`}>
                      <div className={`w-1.5 h-1.5 rounded-full ${job.statusBg}`} />
                      {job.status}
                    </span>
                  </div>
                  <p className="text-white text-[12px] font-semibold mb-1">{job.truck}</p>
                  <p className="text-white text-[12px] mb-2.5 line-clamp-1">{job.issue}</p>
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-1.5">
                      <div className="w-4 h-4 bg-[#1a1a1a] rounded-full flex items-center justify-center">
                        <Wrench className="w-2.5 h-2.5 text-gray-500" />
                      </div>
                      <span className="text-gray-400 text-[11px]">{job.mechanic}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      {job.eta && <span className="text-yellow-400 text-[11px] font-semibold">ETA {job.eta}</span>}
                      <ChevronRight className="w-3.5 h-3.5 text-gray-600" />
                    </div>
                  </div>
                </div>
              </button>
            ))}
          </div>
        )}

        {/* ── Completed jobs list ── */}
        {jobView === 'completed' && (
          <div className="space-y-2.5">
            {completedJobs.map(job => (
              <div key={job.id} className="bg-[#0f0f0f] rounded-xl border border-[#1e1e1e] border-l-4 border-l-green-500 overflow-hidden">
                <div className="p-3.5">
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex items-center gap-2">
                      <span className="text-gray-600 text-[10px] font-mono">{job.id}</span>
                      <span className="text-[9px] font-black uppercase tracking-widest px-1.5 py-0.5 rounded-full border text-green-400 bg-green-400/10 border-green-400/30">DONE</span>
                    </div>
                    <span className="text-gray-600 text-[10px]">{job.completedDate}</span>
                  </div>
                  <p className="text-white text-[12px] font-semibold mb-0.5">{job.truck}</p>
                  <p className="text-white text-[12px] mb-2.5 line-clamp-1">{job.issue}</p>
                  <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center gap-1.5">
                      <div className="w-4 h-4 bg-[#1a1a1a] rounded-full flex items-center justify-center">
                        <Wrench className="w-2.5 h-2.5 text-gray-500" />
                      </div>
                      <span className="text-gray-300 text-[11px]">{job.mechanic}</span>
                      <div className="flex items-center gap-0.5 ml-1">
                        {[1,2,3,4,5].map(s => (
                          <Star key={s} className={`w-2.5 h-2.5 ${s <= job.rating ? 'fill-yellow-400 text-yellow-400' : 'text-gray-700'}`} />
                        ))}
                      </div>
                    </div>
                    <span className="text-white font-black text-sm">{job.total}</span>
                  </div>
                  {/* Invoice actions */}
                  <div className="flex items-center gap-2 pt-2.5 border-t border-[#1a1a1a]">
                    <button
                      onClick={() => setInvoiceJob(job)}
                      className="flex-1 flex items-center justify-center gap-1.5 bg-[#111] border border-[#2a2a2a] hover:border-yellow-400/40 rounded-lg py-2 transition-colors group"
                    >
                      <FileText className="w-3.5 h-3.5 text-gray-500 group-hover:text-yellow-400 transition-colors" />
                      <span className="text-gray-400 group-hover:text-yellow-400 text-[11px] font-semibold transition-colors">View Invoice</span>
                    </button>
                    <button
                      onClick={() => setInvoiceJob(job)}
                      className="flex items-center justify-center gap-1.5 bg-[#111] border border-[#2a2a2a] hover:border-yellow-400/40 rounded-lg py-2 px-3 transition-colors group"
                    >
                      <Download className="w-3.5 h-3.5 text-gray-500 group-hover:text-yellow-400 transition-colors" />
                      <span className="text-gray-400 group-hover:text-yellow-400 text-[11px] font-semibold transition-colors">PDF</span>
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Monthly stats bar */}
      <div className="px-5 py-4 mt-2">
        <div className="bg-[#0f0f0f] rounded-xl p-4 border border-[#1a1a1a]">
          <div className="flex items-center justify-between mb-3">
            <p className="text-white text-[12px] font-black">March Spend</p>
            <p className="text-yellow-400 font-black text-sm">£4,250</p>
          </div>
          <div className="h-2 bg-[#1a1a1a] rounded-full overflow-hidden">
            <div className="h-full bg-yellow-400 rounded-full" style={{ width: '64%' }} />
          </div>
          <p className="text-gray-600 text-[10px] mt-1.5">64% of monthly budget (£6,500)</p>
        </div>
      </div>
    </div>
  );
}

// ─── Post Job ─────────────────────────────────────────────────────────────────────

const UK_ADDRESSES = [
  'M1 Motorway, Junction 24 — Leicester Services',
  'M6 Motorway, Corley Services, Warwickshire',
  'M25 Motorway, Thurrock Services, Essex',
  'A1(M) Motorway, Wetherby Services, Yorkshire',
  'M62 Motorway, Birch Services, Manchester',
  'Birmingham City Centre, Broad St, West Midlands',
  'Manchester City Centre, Deansgate, Greater Manchester',
  'M4 Motorway, Reading Services, Berkshire',
  'Leeds City Centre, Wellington St, West Yorkshire',
  'Liverpool Docks, Seaforth, Merseyside',
  'Heathrow Airport, Bath Rd, London',
  'Sheffield Industrial Estate, South Yorkshire',
  'Bristol City Centre, Temple Meads, Bristol',
  'M5 Motorway, Sedgemoor Services, Somerset',
  'Newcastle upon Tyne, Quayside, Tyne and Wear',
];

const JOB_TYPES = [
  { icon: '🛞', label: 'Flat / Damaged Tyre' },
  { icon: '🔋', label: 'Battery Failure / Jump Start' },
  { icon: '🔑', label: "Engine Won't Start" },
  { icon: '🚧', label: 'Breakdown (Unknown Issue)' },
  { icon: '🌡️', label: 'Overheating' },
  { icon: '🛑', label: 'Brake Problem' },
  { icon: '⚡', label: 'Electrical Issue' },
  { icon: '⛽', label: 'Fuel Issue (Wrong Fuel / Empty)' },
  { icon: '🚛', label: 'Vehicle Recovery / Towing' },
  { icon: '🔧', label: 'Diagnostic Check' },
  { icon: '🔒', label: 'Locked Out of Vehicle' },
  { icon: '📋', label: 'Other (Describe in Notes)' },
];

function PostJob({ setTab, profileComplete, prefilledVehicle }: { setTab: (t: string) => void; profileComplete: boolean; prefilledVehicle?: any }) {
  const [jobMode, setJobMode] = useState<'EMERGENCY' | 'SCHEDULABLE'>('EMERGENCY');
  const [fromDate, setFromDate] = useState('');
  const [fromTime, setFromTime] = useState('');
  const [toDate, setToDate] = useState('');
  const [toTime, setToTime] = useState('');
  const [priority, setPriority] = useState('HIGH');
  const [locationQuery, setLocationQuery] = useState('');
  const [locationFocused, setLocationFocused] = useState(false);
  const [selectedLocation, setSelectedLocation] = useState('');
  const [jobType, setJobType] = useState('');
  const [jobTypeOpen, setJobTypeOpen] = useState(false);
  const [vehicleReg, setVehicleReg] = useState(prefilledVehicle?.reg || 'CA 456-789');
  const [vehicleMake, setVehicleMake] = useState(prefilledVehicle ? `${prefilledVehicle.make} ${prefilledVehicle.model}` : '');
  const [trailerMake, setTrailerMake] = useState('');
  const [tyreSize, setTyreSize] = useState('');
  const [tyreSide, setTyreSide] = useState('');
  const [tyreAxle, setTyreAxle] = useState('');
  const [driverName, setDriverName] = useState('');
  const [driverNumber, setDriverNumber] = useState('');
  const [notes, setNotes] = useState('');
  const [photos, setPhotos] = useState<string[]>([]);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const locationRef = useRef<HTMLDivElement>(null);
  const jobTypeRef = useRef<HTMLDivElement>(null);

  const filteredAddresses = locationQuery.length >= 2
    ? UK_ADDRESSES.filter(a => a.toLowerCase().includes(locationQuery.toLowerCase()))
    : UK_ADDRESSES.slice(0, 5);

  const showLocationDropdown = locationFocused && !selectedLocation;
  const isTyreJob = jobType === 'Flat / Damaged Tyre';

  useEffect(() => {
    function handler(e: MouseEvent) {
      if (jobTypeRef.current && !jobTypeRef.current.contains(e.target as Node)) setJobTypeOpen(false);
      if (locationRef.current && !locationRef.current.contains(e.target as Node)) setLocationFocused(false);
    }
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const files = Array.from(e.target.files ?? []);
    files.forEach(file => {
      const reader = new FileReader();
      reader.onload = ev => {
        if (ev.target?.result) setPhotos(prev => [...prev, ev.target!.result as string]);
      };
      reader.readAsDataURL(file);
    });
    e.target.value = '';
  }

  // ── Profile gate ──────────────────────────────────────────────────────────────
  if (!profileComplete) {
    const missing = [
      { section: 'Company Details', fields: 'Company name, Reg number, VAT number' },
      { section: 'Contact Person', fields: 'Name, role, phone, email' },
      { section: 'Billing & Payment', fields: 'Card number, expiry, CCV' },
    ];
    return (
      <div className="h-full bg-[#080808] flex flex-col">
        {/* Header */}
        <div className="px-5 pt-4 pb-3 border-b border-[#1a1a1a] flex-shrink-0">
          <h2 className="text-white font-black text-xl tracking-tight">Post Job</h2>
          <p className="text-gray-600 text-[12px] mt-0.5">Get mechanics responding in minutes</p>
        </div>

        <div className="flex-1 flex flex-col items-center justify-center px-6 text-center gap-5">
          {/* Icon */}
          <div className="w-16 h-16 rounded-2xl bg-yellow-400/10 border border-yellow-400/30 flex items-center justify-center">
            <AlertCircle className="w-8 h-8 text-yellow-400" />
          </div>

          <div>
            <p className="text-white font-black text-base tracking-tight mb-1.5">Complete your profile first</p>
            <p className="text-gray-500 text-[12px] leading-relaxed">
              Before posting a job you must fill in all required profile details so mechanics and billing can be processed correctly.
            </p>
          </div>

          {/* Missing sections checklist */}
          <div className="w-full bg-[#0f0f0f] rounded-xl border border-[#1a1a1a] overflow-hidden">
            <div className="px-4 py-2.5 border-b border-[#1a1a1a]">
              <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Required sections</p>
            </div>
            <div className="divide-y divide-[#1a1a1a]">
              {missing.map(({ section, fields }) => (
                <div key={section} className="px-4 py-3 flex items-start gap-3">
                  <div className="w-4 h-4 rounded-full border-2 border-red-500/60 flex-shrink-0 mt-0.5" />
                  <div className="text-left">
                    <p className="text-white text-[12px] font-semibold">{section}</p>
                    <p className="text-gray-600 text-[10px] mt-0.5">{fields}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <button
            onClick={() => setTab('edit-profile')}
            className="w-full bg-yellow-400 text-black py-4 rounded-xl font-black text-sm tracking-widest uppercase active:scale-[0.98] transition-transform"
          >
            Complete Profile →
          </button>
          <p className="text-gray-700 text-[10px]">You will be redirected back here once saved.</p>
        </div>
      </div>
    );
  }

  // ── Normal Post Job form ──────────────────────────────────────────��────────────
  return (
    <div className="h-full bg-[#080808] flex flex-col">
      <div className="px-5 pt-4 pb-3 border-b border-[#1a1a1a] flex-shrink-0">
        <h2 className="text-white font-black text-xl tracking-tight">Post Job</h2>
        <p className="text-gray-600 text-[12px] mt-0.5">Fill in details to find a mechanic fast</p>
      </div>

      <div className="flex-1 overflow-y-auto px-5 py-4 space-y-5" style={{ scrollbarWidth: 'none' }}>

        {/* ─�� 1. Emergency / Schedulable ─── */}
        <div className="space-y-2">
          <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Job Mode</label>
          <div className="grid grid-cols-2 gap-2">
            <button
              onClick={() => setJobMode('EMERGENCY')}
              className={`py-3.5 px-3 rounded-xl border flex flex-col items-center gap-1.5 transition-all ${jobMode === 'EMERGENCY' ? 'border-red-500 bg-red-500/10' : 'border-[#1e1e1e] bg-[#0f0f0f]'}`}
            >
              <span className="text-xl">🚨</span>
              <span className={`text-[11px] font-black uppercase tracking-wide ${jobMode === 'EMERGENCY' ? 'text-red-400' : 'text-gray-600'}`}>Emergency</span>
              <span className={`text-[9px] ${jobMode === 'EMERGENCY' ? 'text-red-400/70' : 'text-gray-700'}`}>Dispatch now</span>
            </button>
            <button
              onClick={() => setJobMode('SCHEDULABLE')}
              className={`py-3.5 px-3 rounded-xl border flex flex-col items-center gap-1.5 transition-all ${jobMode === 'SCHEDULABLE' ? 'border-yellow-400 bg-yellow-400/10' : 'border-[#1e1e1e] bg-[#0f0f0f]'}`}
            >
              <span className="text-xl">📅</span>
              <span className={`text-[11px] font-black uppercase tracking-wide ${jobMode === 'SCHEDULABLE' ? 'text-yellow-400' : 'text-gray-600'}`}>Schedulable</span>
              <span className={`text-[9px] ${jobMode === 'SCHEDULABLE' ? 'text-yellow-400/70' : 'text-gray-700'}`}>Pick date & time</span>
            </button>
          </div>

          {/* Date/time picker — Schedulable only */}
          {jobMode === 'SCHEDULABLE' && (
            <div className="bg-[#0f0f0f] border border-yellow-400/20 rounded-xl p-4 space-y-3 mt-1">
              <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Truck Available Window</p>
              <div>
                <p className="text-gray-600 text-[10px] font-semibold uppercase tracking-widest mb-1.5">From</p>
                <div className="flex gap-2">
                  <div className="flex-1 relative">
                    <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-gray-600 pointer-events-none" />
                    <input type="date" value={fromDate} onChange={e => setFromDate(e.target.value)}
                      className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl pl-8 pr-2 py-2.5 text-white focus:outline-none focus:border-yellow-400/60 text-[12px] [color-scheme:dark]" />
                  </div>
                  <div className="flex-1 relative">
                    <Clock className="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-gray-600 pointer-events-none" />
                    <input type="time" value={fromTime} onChange={e => setFromTime(e.target.value)}
                      className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl pl-8 pr-2 py-2.5 text-white focus:outline-none focus:border-yellow-400/60 text-[12px] [color-scheme:dark]" />
                  </div>
                </div>
              </div>
              <div>
                <p className="text-gray-600 text-[10px] font-semibold uppercase tracking-widest mb-1.5">
                  To <span className="normal-case text-gray-700">(optional)</span>
                </p>
                <div className="flex gap-2">
                  <div className="flex-1 relative">
                    <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-gray-600 pointer-events-none" />
                    <input type="date" value={toDate} onChange={e => setToDate(e.target.value)}
                      className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl pl-8 pr-2 py-2.5 text-white focus:outline-none focus:border-yellow-400/60 text-[12px] [color-scheme:dark]" />
                  </div>
                  <div className="flex-1 relative">
                    <Clock className="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-gray-600 pointer-events-none" />
                    <input type="time" value={toTime} onChange={e => setToTime(e.target.value)}
                      className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl pl-8 pr-2 py-2.5 text-white focus:outline-none focus:border-yellow-400/60 text-[12px] [color-scheme:dark]" />
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* ── 2. Vehicle Details ─── */}
        <div className="space-y-2.5">
          <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Vehicle Details</label>

          {/* Reg text input */}
          <div>
            <p className="text-gray-700 text-[10px] uppercase tracking-widest mb-1.5">Registration</p>
            <input
              type="text"
              value={vehicleReg}
              onChange={e => setVehicleReg(e.target.value)}
              placeholder="e.g. CA 456-789"
              className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-[13px] uppercase"
            />
          </div>

          {/* Make & model */}
          <div>
            <p className="text-gray-700 text-[10px] uppercase tracking-widest mb-1.5">Vehicle Make & Model</p>
            <input
              type="text"
              value={vehicleMake}
              onChange={e => setVehicleMake(e.target.value)}
              placeholder="e.g. Mercedes Actros 2645, Volvo FH16…"
              className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-[13px]"
            />
          </div>

          {/* Trailer — optional */}
          <div>
            <div className="flex items-center justify-between mb-1.5">
              <p className="text-gray-700 text-[10px] uppercase tracking-widest">Trailer Make & Model</p>
              <span className="text-gray-700 text-[10px]">Optional</span>
            </div>
            <input
              type="text"
              value={trailerMake}
              onChange={e => setTrailerMake(e.target.value)}
              placeholder="e.g. Henred Fruehauf, SA Truck Bodies…"
              className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-[13px]"
            />
          </div>
        </div>

        {/* ── 3. Job Category dropdown ─── */}
        <div className="space-y-1.5" ref={jobTypeRef}>
          <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Job Category</label>
          <button
            onClick={() => setJobTypeOpen(o => !o)}
            className={`w-full bg-[#111] border rounded-xl px-4 py-3 flex items-center justify-between text-left transition-colors ${jobTypeOpen ? 'border-yellow-400/60' : 'border-[#2a2a2a]'}`}
          >
            <span className={`text-[13px] ${jobType ? 'text-white' : 'text-gray-700'}`}>
              {jobType ? `${JOB_TYPES.find(j => j.label === jobType)?.icon}  ${jobType}` : 'Select job category…'}
            </span>
            <ChevronDown className={`w-4 h-4 text-gray-600 transition-transform flex-shrink-0 ${jobTypeOpen ? 'rotate-180' : ''}`} />
          </button>
          {jobTypeOpen && (
            <div className="bg-[#111] border border-[#2a2a2a] rounded-xl overflow-hidden shadow-xl">
              {JOB_TYPES.map(({ icon, label }) => (
                <button
                  key={label}
                  onClick={() => { setJobType(label); setJobTypeOpen(false); }}
                  className={`w-full flex items-center gap-3 px-4 py-3 text-left border-b border-[#1a1a1a] last:border-0 transition-colors hover:bg-[#1a1a1a] ${jobType === label ? 'bg-yellow-400/10' : ''}`}
                >
                  <span className="text-base w-6 text-center">{icon}</span>
                  <span className={`text-[13px] font-semibold ${jobType === label ? 'text-yellow-400' : 'text-gray-400'}`}>{label}</span>
                  {jobType === label && <Check className="w-3.5 h-3.5 text-yellow-400 ml-auto flex-shrink-0" />}
                </button>
              ))}
            </div>
          )}
        </div>

        {/* ── 3b. Tyre Details — only when Flat / Damaged Tyre is selected ── */}
        {isTyreJob && (
          <div className="bg-[#0f0f0f] border border-yellow-400/20 rounded-xl p-4 space-y-4">
            <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">🛞 Tyre Details</p>

            {/* Tyre Size */}
            <div>
              <p className="text-gray-600 text-[10px] uppercase tracking-widest mb-1.5">Tyre Size</p>
              <input
                type="text"
                value={tyreSize}
                onChange={e => setTyreSize(e.target.value)}
                placeholder="e.g. 295/80 R22.5, 315/70 R22.5…"
                className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-[13px]"
              />
            </div>

            {/* Side */}
            <div>
              <p className="text-gray-600 text-[10px] uppercase tracking-widest mb-2">Side</p>
              <div className="grid grid-cols-3 gap-1.5">
                {[
                  { id: 'NS',   label: 'Near Side', sub: 'Left / Kerb'  },
                  { id: 'OS',   label: 'Off Side',  sub: 'Right / Road' },
                  { id: 'BOTH', label: 'Both',      sub: 'NS & OS'      },
                ].map(opt => (
                  <button
                    key={opt.id}
                    onClick={() => setTyreSide(opt.id)}
                    className={`py-2.5 px-2 rounded-xl border flex flex-col items-center gap-0.5 transition-all ${tyreSide === opt.id ? 'border-yellow-400 bg-yellow-400/10' : 'border-[#2a2a2a] bg-[#111]'}`}
                  >
                    <span className={`text-[11px] font-black uppercase tracking-wide ${tyreSide === opt.id ? 'text-yellow-400' : 'text-gray-500'}`}>{opt.label}</span>
                    <span className={`text-[9px] ${tyreSide === opt.id ? 'text-yellow-400/60' : 'text-gray-700'}`}>{opt.sub}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Axle Position — free text input */}
            <div>
              <p className="text-gray-600 text-[10px] uppercase tracking-widest mb-2">Axle Position</p>
              <input
                type="text"
                value={tyreAxle}
                onChange={e => setTyreAxle(e.target.value)}
                placeholder="e.g. Steer, Drive 1, Drive 2, Tag, Trailer 1…"
                className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-[13px]"
              />
              <p className="text-gray-700 text-[10px] mt-1">Type the axle — e.g. "Drive 1", "Steer", "Trailer 2"</p>
            </div>

            {/* Summary — shows when both side + axle are filled */}
            {tyreSide && tyreAxle && (
              <div className="flex items-center gap-3 bg-yellow-400/5 border border-yellow-400/20 rounded-xl px-3 py-2.5">
                <span className="text-xl flex-shrink-0">🛞</span>
                <div>
                  <p className="text-yellow-400 text-[11px] font-black">
                    {tyreSide === 'NS' ? 'Near Side (Left)' : tyreSide === 'OS' ? 'Off Side (Right)' : 'Both Sides'}
                    {' · '}{tyreAxle}
                  </p>
                  {tyreSize && <p className="text-gray-500 text-[10px] mt-0.5">Size: {tyreSize}</p>}
                </div>
              </div>
            )}
          </div>
        )}

        {/* ── 4. Location ─── */}
        <div className="space-y-2" ref={locationRef}>
          <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Breakdown Location</label>

          {/* Search input */}
          <div className="relative">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-600 pointer-events-none" />
            <input
              type="text"
              value={selectedLocation || locationQuery}
              onChange={e => { setSelectedLocation(''); setLocationQuery(e.target.value); }}
              onFocus={() => setLocationFocused(true)}
              placeholder="Type a street, highway or landmark…"
              className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl pl-10 pr-10 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-[13px]"
            />
            {(selectedLocation || locationQuery) && (
              <button
                onClick={() => { setSelectedLocation(''); setLocationQuery(''); }}
                className="absolute right-3.5 top-1/2 -translate-y-1/2 w-5 h-5 rounded-full bg-[#2a2a2a] flex items-center justify-center"
              >
                <X className="w-3 h-3 text-gray-400" />
              </button>
            )}
          </div>

          {/* Address suggestions dropdown */}
          {showLocationDropdown && (
            <div className="bg-[#111] border border-[#2a2a2a] rounded-xl overflow-hidden shadow-xl">
              {filteredAddresses.length === 0 ? (
                <div className="px-4 py-3 text-gray-600 text-[12px]">No results found</div>
              ) : (
                filteredAddresses.map(addr => (
                  <button
                    key={addr}
                    onMouseDown={() => { setSelectedLocation(addr); setLocationQuery(''); setLocationFocused(false); }}
                    className="w-full flex items-center gap-3 px-4 py-3 border-b border-[#1a1a1a] last:border-0 hover:bg-[#1a1a1a] text-left transition-colors"
                  >
                    <MapPin className="w-3.5 h-3.5 text-gray-600 flex-shrink-0" />
                    <span className="text-gray-300 text-[12px]">{addr}</span>
                  </button>
                ))
              )}
            </div>
          )}

          {/* Use GPS button */}
          <button
            onClick={() => { setSelectedLocation('N1 Highway, km 184 — Current GPS Position, GP'); setLocationQuery(''); setLocationFocused(false); }}
            className="w-full flex items-center gap-3 bg-[#0f0f0f] border border-[#1e1e1e] rounded-xl px-4 py-2.5 hover:border-yellow-400/30 transition-colors"
          >
            <div className="w-7 h-7 bg-yellow-400/10 border border-yellow-400/20 rounded-lg flex items-center justify-center flex-shrink-0">
              <Crosshair className="w-3.5 h-3.5 text-yellow-400" />
            </div>
            <div className="text-left">
              <p className="text-white text-[12px] font-semibold">Use my current location</p>
              <p className="text-gray-600 text-[10px]">GPS · 25.8°S, 28.2°E</p>
            </div>
          </button>

          {/* Map preview when location is set */}
          {selectedLocation && <MapPreview height={120} />}
        </div>

        {/* ── 5. Driver Details ─── */}
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Driver Details</label>
            <span className="text-gray-700 text-[10px]">Optional</span>
          </div>
          <div className="flex gap-2">
            <div className="flex-1 relative">
              <UserCircle className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-600 pointer-events-none" />
              <input
                type="text"
                value={driverName}
                onChange={e => setDriverName(e.target.value)}
                placeholder="Driver name"
                className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl pl-9 pr-3 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-[13px]"
              />
            </div>
            <div className="flex-1 relative">
              <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-600 pointer-events-none" />
              <input
                type="tel"
                value={driverNumber}
                onChange={e => setDriverNumber(e.target.value)}
                placeholder="+27 82 000 0000"
                className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl pl-9 pr-3 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-[13px]"
              />
            </div>
          </div>
        </div>

        {/* ── 6. Photo Upload ─── */}
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Photos</label>
            <span className="text-gray-700 text-[10px]">Optional · up to 5</span>
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => {
                if (fileInputRef.current) {
                  fileInputRef.current.setAttribute('capture', 'environment');
                  fileInputRef.current.click();
                }
              }}
              className="flex-1 flex items-center justify-center gap-2 py-3 bg-[#0f0f0f] border border-[#1e1e1e] rounded-xl hover:border-yellow-400/30 active:bg-[#1a1a1a] transition-colors"
            >
              <Camera className="w-4 h-4 text-yellow-400" />
              <span className="text-gray-400 text-[12px] font-semibold">Camera</span>
            </button>
            <button
              onClick={() => {
                if (fileInputRef.current) {
                  fileInputRef.current.removeAttribute('capture');
                  fileInputRef.current.click();
                }
              }}
              className="flex-1 flex items-center justify-center gap-2 py-3 bg-[#0f0f0f] border border-[#1e1e1e] rounded-xl hover:border-yellow-400/30 active:bg-[#1a1a1a] transition-colors"
            >
              <ImageIcon className="w-4 h-4 text-yellow-400" />
              <span className="text-gray-400 text-[12px] font-semibold">Gallery</span>
            </button>
            <input ref={fileInputRef} type="file" accept="image/*" multiple className="hidden" onChange={handleFileChange} />
          </div>
          {photos.length > 0 ? (
            <div className="flex gap-2 flex-wrap">
              {photos.map((src, i) => (
                <div key={i} className="relative w-[72px] h-[72px] rounded-xl overflow-hidden border border-[#2a2a2a]">
                  <img src={src} alt={`photo-${i}`} className="w-full h-full object-cover" />
                  <button
                    onClick={() => setPhotos(prev => prev.filter((_, idx) => idx !== i))}
                    className="absolute top-1 right-1 w-4 h-4 bg-black/70 rounded-full flex items-center justify-center"
                  >
                    <X className="w-2.5 h-2.5 text-white" />
                  </button>
                </div>
              ))}
              {photos.length < 5 && (
                <button
                  onClick={() => fileInputRef.current?.click()}
                  className="w-[72px] h-[72px] rounded-xl border border-dashed border-[#2a2a2a] flex items-center justify-center hover:border-yellow-400/40 transition-colors"
                >
                  <PlusCircle className="w-5 h-5 text-gray-700" />
                </button>
              )}
            </div>
          ) : (
            <div className="h-[72px] rounded-xl border border-dashed border-[#1e1e1e] flex items-center justify-center gap-2">
              <ImageIcon className="w-4 h-4 text-gray-700" />
              <span className="text-gray-700 text-[11px]">No photos added yet</span>
            </div>
          )}
          <p className="text-gray-700 text-[10px]">Helps mechanics diagnose before arriving on site</p>
        </div>

        {/* ── 7. Notes ─── */}
        <div className="space-y-1.5">
          <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Notes</label>
          <textarea
            value={notes}
            onChange={e => setNotes(e.target.value)}
            placeholder="Describe the problem in detail — symptoms, warning lights, sounds, what happened before breakdown…"
            rows={4}
            className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm resize-none"
          />
          <p className="text-gray-700 text-[10px] text-right">{notes.length} / 500</p>
        </div>

        {/* ── 9. Payment Pre-Auth ─── */}
        <div className="bg-[#0f0f0f] rounded-xl p-4 border border-[#1a1a1a]">
          <div className="flex items-center justify-between mb-2">
            <p className="text-white text-[12px] font-black">Payment Pre-Auth</p>
            <span className="text-yellow-400 text-[12px] font-black">£220</span>
          </div>
          <div className="h-2 bg-[#1a1a1a] rounded-full overflow-hidden mb-1.5">
            <div className="h-full bg-yellow-400 rounded-full" style={{ width: '50%' }} />
          </div>
          <div className="flex justify-between">
            <span className="text-gray-600 text-[10px]">£50</span>
            <span className="text-gray-600 text-[10px]">£450</span>
          </div>
          <div className="mt-2.5 flex items-center gap-2">
            <CreditCard className="w-3.5 h-3.5 text-gray-600" />
            <span className="text-gray-500 text-[11px]">VISA •••• 4891 · Held until completion</span>
          </div>
        </div>

      </div>

      {/* Footer CTA */}
      <div className="px-5 pb-5 pt-3 border-t border-[#1a1a1a] flex-shrink-0 space-y-2.5">
        <PrimaryBtn onClick={() => setTab('tracking')}>
          {jobMode === 'EMERGENCY' ? '🚨 Post Emergency Job' : '📅 Schedule Job'}
        </PrimaryBtn>
        <p className="text-gray-700 text-[10px] text-center">
          {jobMode === 'EMERGENCY'
            ? 'Mechanics will respond within minutes. Your job is now live.'
            : 'Mechanics will be notified and can quote on your scheduled window.'}
        </p>
      </div>
    </div>
  );
}

// ─── Job Tracking ────────────────────────────────────────────────────────────────
const STATUS_FLOW = ['posted', 'assigned', 'en_route', 'arrived', 'in_progress', 'completed'] as const;
type JobStatus = typeof STATUS_FLOW[number];

const TIMELINE_STEPS: { key: JobStatus; label: string; time: string }[] = [
  { key: 'posted',      label: 'Posted',      time: '14:32' },
  { key: 'assigned',    label: 'Assigned',    time: '14:38' },
  { key: 'en_route',    label: 'En Route',    time: '14:41' },
  { key: 'arrived',     label: 'Arrived',     time: 'ETA 14:58' },
  { key: 'in_progress', label: 'In Progress', time: '—' },
  { key: 'completed',   label: 'Completed',   time: '—' },
];

const PAYMENT_STATUS_CONFIG: Record<string, { label: string; color: string; bg: string }> = {
  authorised: { label: 'Authorised',          color: 'text-orange-400', bg: 'bg-orange-400/10 border-orange-400/30' },
  paid:       { label: 'Paid',                color: 'text-green-400',  bg: 'bg-green-400/10 border-green-400/30'  },
  refunded:   { label: 'Refunded',            color: 'text-blue-400',   bg: 'bg-blue-400/10 border-blue-400/30'   },
  released:   { label: 'Released to Mechanic',color: 'text-yellow-400', bg: 'bg-yellow-400/10 border-yellow-400/30' },
};

// ─── Fleet Tracking List ─────────────────────────────────────────────────────────
type TrackStatus = 'posted' | 'assigned' | 'en_route' | 'on_site';
type FleetJob = {
  id: string; truck: string; issue: string; status: TrackStatus;
  mechanic: string | null; eta: string | null; pay: string; ago: string;
  jobKind: 'emergency' | 'scheduled';
  quoteAgreed?: boolean;   // emergency: fee applies once quote agreed + mechanic assigned
  scheduledFor?: string;   // scheduled: ISO date — fee if <24 hrs away
};

// Computed once so the 24-hr window logic works live in the demo
const _30hFromNow = new Date(Date.now() + 30 * 3_600_000).toISOString(); // >24 hrs → free
const _6hFromNow  = new Date(Date.now() +  6 * 3_600_000).toISOString(); // <24 hrs → 10% fee

const FLEET_JOBS: FleetJob[] = [
  { id: 'TF-8821', truck: 'Tautliner · CA 456-789',   issue: 'Engine overheating — M1 near Birmingham',   status: 'posted',   mechanic: null,        eta: null,     pay: '£165', ago: '4 min ago',  jobKind: 'emergency', quoteAgreed: false },
  { id: 'TF-8819', truck: 'Rigid Truck · GP 112-033', issue: 'Left rear tyre blowout — M6 services',  status: 'assigned', mechanic: 'Tom S.',  eta: null,     pay: '£95',  ago: '18 min ago', jobKind: 'scheduled', scheduledFor: _30hFromNow },
  { id: 'TF-8822', truck: 'Tanker · KZN 78-99',       issue: 'Air brake fault — A1 Leeds',       status: 'en_route', mechanic: 'James M.', eta: '12 min', pay: '£310', ago: '35 min ago', jobKind: 'scheduled', scheduledFor: _6hFromNow  },
  { id: 'TF-8814', truck: 'Semi · WC 234-567',        issue: 'Fuel leak suspected — M25 London', status: 'on_site',  mechanic: 'Paul K.',  eta: null,     pay: '£185', ago: '1 hr ago',   jobKind: 'emergency', quoteAgreed: true  },
];

const TRACK_CFG: Record<TrackStatus, { label: string; shortLabel: string; dot: string; text: string; badge: string; pulse: boolean }> = {
  posted:   { label: 'Posted — Awaiting Mechanic', shortLabel: 'Posted',   dot: 'bg-red-400',    text: 'text-red-400',    badge: 'bg-red-400/10    border-red-400/30',    pulse: true  },
  assigned: { label: 'Assigned',                   shortLabel: 'Assigned', dot: 'bg-blue-400',   text: 'text-blue-400',   badge: 'bg-blue-400/10   border-blue-400/30',   pulse: false },
  en_route: { label: 'En Route',                   shortLabel: 'En Route', dot: 'bg-orange-400', text: 'text-orange-400', badge: 'bg-orange-400/10 border-orange-400/30', pulse: true  },
  on_site:  { label: 'On Site',                    shortLabel: 'On Site',  dot: 'bg-green-400',  text: 'text-green-400',  badge: 'bg-green-400/10  border-green-400/30',  pulse: true  },
};

function JobTracking({ setTab }: { setTab: (t: string) => void }) {
  const [cancelJob, setCancelJob] = useState<FleetJob | null>(null);

  // ── Cancellation fee rules ──────────────────────────────────────────────
  // Emergency: 10% once mechanic is en route (on the way)
  // Scheduled: free if >24 hrs away; 10% if <24 hrs away
  const hoursUntil = (iso: string) => (new Date(iso).getTime() - Date.now()) / 3_600_000;
  const hasFee = (job: FleetJob): boolean => {
    if (job.status === 'en_route' || job.status === 'on_site') return true; // mechanic on the way or arrived — fee always applies
    if (job.jobKind === 'emergency') return false; // emergency jobs: free cancellation until mechanic is en route
    return job.scheduledFor ? hoursUntil(job.scheduledFor) < 24 : false;
  };
  const feeAmount  = (job: FleetJob) => `£${Math.round(parseFloat(job.pay.replace('£', '')) * 0.1)}`;
  const canCancel  = (s: TrackStatus) => s !== 'on_site';

  return (
    <div className="h-full bg-[#080808] flex flex-col relative">

      {/* ── Cancel Modal ── */}
      {cancelJob && (
        <div className="absolute inset-0 bg-black/85 z-50 flex items-end p-5">
          <div className="w-full bg-[#111] rounded-2xl p-5 border border-[#2a2a2a]">
            <div className="flex items-start gap-3 mb-4">
              <div className="w-9 h-9 rounded-xl bg-red-500/15 flex items-center justify-center flex-shrink-0">
                <AlertTriangle className="w-5 h-5 text-red-400" />
              </div>
              <div className="flex-1">
                <p className="text-white font-black text-base mb-1">Cancel {cancelJob.id}?</p>
                <p className="text-white text-[12px] mb-1.5">{cancelJob.truck}</p>
                {hasFee(cancelJob) ? (
                  cancelJob.jobKind === 'emergency' ? (
                    <p className="text-gray-300 text-[12px] leading-relaxed">
                      The mechanic is <span className="text-orange-400 font-semibold">on the way</span>. A <span className="text-red-400 font-semibold">10% cancellation fee ({feeAmount(cancelJob)})</span> applies for emergency jobs once the mechanic is en route.
                    </p>
                  ) : (
                    <p className="text-gray-300 text-[12px] leading-relaxed">
                      Your booking is <span className="text-orange-400 font-semibold">less than 24 hours away</span>. A <span className="text-red-400 font-semibold">10% late-cancellation fee ({feeAmount(cancelJob)})</span> applies.
                    </p>
                  )
                ) : (
                  <p className="text-gray-300 text-[12px] leading-relaxed">
                    {cancelJob.status === 'posted' 
                      ? 'No mechanic assigned yet — free cancellation.'
                      : 'Mechanic has not started journey — free cancellation.'}
                  </p>
                )}
              </div>
            </div>
            {hasFee(cancelJob) && (
              <div className="bg-red-500/8 border border-red-500/20 rounded-xl px-4 py-2.5 mb-4 flex items-center gap-2.5">
                <AlertCircle className="w-4 h-4 text-red-400 flex-shrink-0" />
                <p className="text-red-400 text-[11px] font-semibold">10% cancellation fee · {feeAmount(cancelJob)} · Non-refundable</p>
              </div>
            )}
            <div className="space-y-2">
              <button onClick={() => setCancelJob(null)} className="w-full bg-red-500 text-white py-3.5 rounded-xl font-black text-[13px] tracking-wide">
                {hasFee(cancelJob) ? `Confirm Cancellation (${feeAmount(cancelJob)} fee)` : 'Confirm Cancellation — Free'}
              </button>
              <button onClick={() => setCancelJob(null)} className="w-full border border-[#2a2a2a] text-gray-300 py-3.5 rounded-xl font-semibold text-[13px]">
                Keep Job Active
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ── Header ── */}
      <div className="px-5 pt-4 pb-3 border-b border-[#1a1a1a] flex-shrink-0">
        <h2 className="text-white font-black text-xl tracking-tight">Job Tracking</h2>
        <p className="text-gray-500 text-[11px] mt-0.5">{FLEET_JOBS.length} active jobs</p>
      </div>

      {/* ── Job Cards ── */}
      <div className="flex-1 overflow-y-auto px-5 py-3 space-y-3" style={{ scrollbarWidth: 'none' }}>
        {FLEET_JOBS.map(job => {
          const cfg = TRACK_CFG[job.status];
          return (
            <div key={job.id} className="bg-[#0f0f0f] rounded-xl border border-[#1a1a1a] overflow-hidden">
              <div className="flex">
                {/* Left status accent bar */}
                <div className={`w-1 flex-shrink-0 ${cfg.dot}`} />
                <div className="flex-1 p-4">

                  {/* Top row — job ID + status badge */}
                  <div className="flex items-start justify-between mb-1.5">
                    <div className="flex-1 min-w-0 pr-2">
                      <div className="flex items-center gap-2 mb-0.5">
                        <span className="text-gray-500 text-[10px] font-mono">{job.id}</span>
                        <span className="text-gray-600 text-[10px]">·</span>
                        <span className="text-gray-500 text-[10px]">{job.ago}</span>
                      </div>
                      <p className="text-white font-black text-[13px]">{job.truck}</p>
                    </div>
                    <div className={`flex items-center gap-1.5 px-2.5 py-1 rounded-lg border text-[9px] font-black uppercase tracking-wide flex-shrink-0 ${cfg.badge} ${cfg.text}`}>
                      <span className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${cfg.dot} ${cfg.pulse ? 'animate-pulse' : ''}`} />
                      {cfg.shortLabel}
                    </div>
                  </div>

                  {/* Issue */}
                  <p className="text-white text-[12px] mb-3 line-clamp-1">{job.issue}</p>

                  {/* Mechanic + ETA + pay */}
                  <div className="flex items-center justify-between mb-3">
                    {job.mechanic ? (
                      <div className="flex items-center gap-1.5">
                        <div className="w-5 h-5 bg-[#1a1a1a] rounded-full flex items-center justify-center">
                          <Wrench className="w-2.5 h-2.5 text-gray-500" />
                        </div>
                        <span className="text-gray-300 text-[11px] font-semibold">{job.mechanic}</span>
                      </div>
                    ) : (
                      <div className="flex items-center gap-1.5">
                        <div className="w-5 h-5 bg-[#1a1a1a] rounded-full flex items-center justify-center">
                          <Clock className="w-2.5 h-2.5 text-gray-600" />
                        </div>
                        <span className="text-gray-500 text-[11px]">Awaiting mechanic…</span>
                      </div>
                    )}
                    <div className="flex items-center gap-3">
                      {job.eta && (
                        <div className="flex items-center gap-1">
                          <Navigation className="w-3 h-3 text-orange-400" />
                          <span className="text-orange-400 text-[11px] font-black">{job.eta}</span>
                        </div>
                      )}
                      <span className="text-yellow-400 font-black text-sm">{job.pay}</span>
                    </div>
                  </div>

                  {/* Action row */}
                  <div className="flex gap-2 pt-2.5 border-t border-[#1a1a1a]">
                    <button
                      onClick={() => setTab('tracking-detail')}
                      className="flex-1 bg-[#111] border border-[#2a2a2a] rounded-lg py-2 text-[11px] font-semibold text-gray-300 hover:border-yellow-400/30 transition-colors flex items-center justify-center gap-1.5"
                    >
                      <MapPin className="w-3 h-3 text-yellow-400" /> Track Job
                    </button>
                    {canCancel(job.status) ? (
                      <button
                        onClick={() => setCancelJob(job)}
                        className={`flex-1 rounded-lg py-2 text-[11px] font-semibold border flex items-center justify-center gap-1.5 transition-colors ${
                          hasFee(job)
                            ? 'border-red-500/40 text-red-400 bg-red-500/5 hover:bg-red-500/10'
                            : 'border-[#2a2a2a] text-gray-400 hover:border-red-500/30 hover:text-red-400'
                        }`}
                      >
                        <X className="w-3 h-3" />
                        {job.status === 'en_route' ? 'Cancel' : hasFee(job) ? `Cancel · ${feeAmount(job)}` : 'Cancel · Free'}
                      </button>
                    ) : (
                      <div className="flex-1 rounded-lg py-2 text-[11px] font-semibold border border-[#1a1a1a] text-gray-600 flex items-center justify-center gap-1.5">
                        <CheckCircle className="w-3 h-3" /> Mechanic on site
                      </div>
                    )}
                  </div>

                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ─── Job Tracking Detail (single job) ────────────────────────────────────────────
function JobTrackingDetail({ setTab }: { setTab: (t: string) => void }) {
  const [jobStatus, setJobStatus] = useState<JobStatus>('en_route');
  const [cancelModal, setCancelModal] = useState(false);
  const [contactModal, setContactModal] = useState(false);
  const [paymentStatus, setPaymentStatus] = useState<'authorised' | 'paid' | 'refunded' | 'released'>('authorised');

  // ── Rating state ──────────────────────────────────────────────
  const [ratingModal, setRatingModal]       = useState(false);
  const [ratingHover, setRatingHover]       = useState(0);
  const [ratingValue, setRatingValue]       = useState(0);
  const [ratingComment, setRatingComment]   = useState('');
  const [ratingSubmitted, setRatingSubmitted] = useState(false);

  const submitRating = () => {
    if (ratingValue === 0) return;
    setRatingSubmitted(true);
    setTimeout(() => setRatingModal(false), 1800);
  };

  const currentIdx             = STATUS_FLOW.indexOf(jobStatus);
  const mechanicAssigned       = currentIdx >= 1;
  const mechanicStartedJourney = currentIdx >= 2; // kept for reference

  // ── Demo job: emergency, quote agreed, £310 ── 10% = £31 ──────────────
  const isEmergencyJob = true;
  const quoteAgreed    = true;
  const detailQuote    = 310;
  const detailFeeAmt   = `£${Math.round(detailQuote * 0.1)}`; // £31
  const detailHasFee   =
    jobStatus === 'en_route' || jobStatus === 'arrived' || jobStatus === 'in_progress'; // fee applies once mechanic is en route or beyond

  const payment = PAYMENT_STATUS_CONFIG[paymentStatus];

  return (
    <div className="h-full bg-[#080808] flex flex-col relative">

      {/* ── Cancel Modal ── */}
      {cancelModal && (
        <div className="absolute inset-0 bg-black/85 z-50 flex items-end p-5">
          <div className="w-full bg-[#111] rounded-2xl p-5 border border-[#2a2a2a]">
            <div className="flex items-start gap-3 mb-4">
              <div className="w-9 h-9 rounded-xl bg-red-500/15 flex items-center justify-center flex-shrink-0">
                <AlertTriangle className="w-5 h-5 text-red-400" />
              </div>
              <div>
                <p className="text-white font-black text-base mb-1">Cancel this job?</p>
                {detailHasFee ? (
                  <p className="text-gray-400 text-[12px] leading-relaxed">
                    The mechanic is <span className="text-orange-400 font-semibold">on the way</span>. A{' '}
                    <span className="text-red-400 font-semibold">10% cancellation fee ({detailFeeAmt})</span>{' '}
                    applies for emergency jobs once the mechanic is en route.
                  </p>
                ) : (
                  <p className="text-gray-400 text-[12px] leading-relaxed">
                    {jobStatus === 'posted' 
                      ? 'No mechanic assigned yet — free cancellation.'
                      : 'Mechanic has not started journey — free cancellation.'}
                  </p>
                )}
              </div>
            </div>
            {detailHasFee && (
              <div className="bg-red-500/8 border border-red-500/20 rounded-xl px-4 py-2.5 mb-4 flex items-center gap-2.5">
                <AlertCircle className="w-4 h-4 text-red-400 flex-shrink-0" />
                <p className="text-red-400 text-[11px] font-semibold">10% cancellation fee · {detailFeeAmt} · Non-refundable</p>
              </div>
            )}
            <div className="space-y-2">
              <button
                onClick={() => setCancelModal(false)}
                className="w-full bg-red-500 text-white py-3.5 rounded-xl font-black text-[13px] tracking-wide"
              >
                {detailHasFee ? `Confirm Cancellation (${detailFeeAmt} fee)` : 'Confirm Cancellation — Free'}
              </button>
              <button
                onClick={() => setCancelModal(false)}
                className="w-full border border-[#2a2a2a] text-gray-400 py-3.5 rounded-xl font-semibold text-[13px]"
              >
                Keep Job Active
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ── Contact Modal ── */}
      {contactModal && (
        <div className="absolute inset-0 bg-black/85 z-50 flex items-end p-5">
          <div className="w-full bg-[#111] rounded-2xl p-5 border border-[#2a2a2a]">
            <div className="flex items-center gap-3 mb-4">
              <img src={MECHANIC_IMG} alt="Mechanic" className="w-10 h-10 rounded-xl object-cover" />
              <div>
                <p className="text-white font-black text-sm">James Mitchell</p>
                <p className="text-gray-500 text-[11px]">+44 7734 567 890</p>
              </div>
              <button onClick={() => setContactModal(false)} className="ml-auto w-7 h-7 rounded-lg bg-[#1a1a1a] flex items-center justify-center">
                <X className="w-3.5 h-3.5 text-gray-500" />
              </button>
            </div>
            <div className="space-y-2">
              <a href="tel:+447734567890" className="w-full bg-yellow-400 text-black py-3.5 rounded-xl font-black text-[13px] tracking-wide flex items-center justify-center gap-2">
                <Phone className="w-4 h-4" /> Call Mechanic
              </a>
              <button className="w-full border border-[#2a2a2a] text-white py-3.5 rounded-xl font-semibold text-[13px] flex items-center justify-center gap-2">
                <MessageCircle className="w-4 h-4 text-gray-400" /> Send Message
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ── Rating Modal ── */}
      {ratingModal && (
        <div className="absolute inset-0 z-50 bg-black/80 flex items-end" onClick={() => !ratingSubmitted && setRatingModal(false)}>
          <div
            className="w-full bg-[#0e0e0e] rounded-t-3xl border-t border-[#2a2a2a] px-5 pt-5 pb-8"
            onClick={e => e.stopPropagation()}
          >
            {ratingSubmitted ? (
              <div className="flex flex-col items-center py-6">
                <div className="relative mb-4">
                  <div className="absolute inset-0 bg-green-400 rounded-full blur-[24px] opacity-25" />
                  <div className="relative w-16 h-16 bg-[#0f0f0f] border-2 border-green-400 rounded-full flex items-center justify-center">
                    <CheckCircle className="w-8 h-8 text-green-400" />
                  </div>
                </div>
                <p className="text-white font-black text-lg mb-1">Review Submitted!</p>
                <p className="text-gray-500 text-[12px] text-center">Thanks for rating James. Your feedback helps keep the network reliable.</p>
              </div>
            ) : (
              <>
                <div className="w-10 h-1 bg-[#2a2a2a] rounded-full mx-auto mb-5" />

                {/* Mechanic row */}
                <div className="flex items-center gap-3 mb-5">
                  <img src={MECHANIC_IMG} alt="Mechanic" className="w-12 h-12 rounded-xl object-cover flex-shrink-0" />
                  <div>
                    <p className="text-white font-black text-sm">James Mitchell</p>
                    <p className="text-gray-500 text-[11px]">Job TF-8821 · Engine overheating</p>
                  </div>
                </div>

                {/* Stars */}
                <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-3">Your Rating</p>
                <div className="flex items-center justify-center gap-3 mb-1">
                  {[1,2,3,4,5].map(i => (
                    <button
                      key={i}
                      onMouseEnter={() => setRatingHover(i)}
                      onMouseLeave={() => setRatingHover(0)}
                      onClick={() => setRatingValue(i)}
                      className="active:scale-90 transition-transform"
                    >
                      <Star
                        className={`w-10 h-10 transition-colors ${
                          i <= (ratingHover || ratingValue)
                            ? 'fill-yellow-400 text-yellow-400'
                            : 'text-[#2a2a2a] fill-[#2a2a2a]'
                        }`}
                      />
                    </button>
                  ))}
                </div>
                <p className="text-center text-gray-500 text-[12px] mb-5 h-4">
                  {ratingValue === 1 ? 'Poor' : ratingValue === 2 ? 'Fair' : ratingValue === 3 ? 'Good' : ratingValue === 4 ? 'Very Good' : ratingValue === 5 ? 'Excellent!' : ''}
                </p>

                {/* Comment */}
                <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-2">
                  Comment <span className="text-gray-700 normal-case tracking-normal font-normal ml-1">Optional</span>
                </p>
                <textarea
                  value={ratingComment}
                  onChange={e => setRatingComment(e.target.value)}
                  placeholder="Punctuality, quality of repair, professionalism..."
                  rows={3}
                  className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/50 text-[12px] resize-none mb-4"
                />

                <button
                  onClick={submitRating}
                  disabled={ratingValue === 0}
                  className={`w-full py-4 rounded-xl font-black text-[13px] tracking-widest uppercase flex items-center justify-center gap-2 transition-all active:scale-[0.98] ${
                    ratingValue > 0 ? 'bg-yellow-400 text-black' : 'bg-[#1a1a1a] text-gray-700 cursor-not-allowed'
                  }`}
                >
                  <Star className="w-4 h-4" /> Submit Review
                </button>
                <button onClick={() => setRatingModal(false)} className="w-full text-gray-600 text-[12px] py-2 mt-1">
                  Not now
                </button>
              </>
            )}
          </div>
        </div>
      )}

      {/* ── Scrollable Content ── */}
      <div className="flex-1 overflow-y-auto flex flex-col" style={{ scrollbarWidth: 'none' }}>

      {/* ── Header ── */}
      <div className="px-5 pt-4 pb-3 border-b border-[#1a1a1a] flex-shrink-0">
        <div className="flex items-center gap-3 mb-0.5">
          <button onClick={() => setTab('tracking')} className="w-8 h-8 bg-[#111] rounded-xl border border-[#2a2a2a] flex items-center justify-center flex-shrink-0">
            <ArrowLeft className="w-4 h-4 text-gray-400" />
          </button>
          <div className="flex-1">
            <div className="flex items-center justify-between">
              <h2 className="text-white font-black text-lg tracking-tight">TF-8821</h2>
              <span className={`flex items-center gap-1.5 px-2.5 py-1 rounded-lg border text-[9px] font-black uppercase tracking-wide ${TRACK_CFG['en_route'].badge} ${TRACK_CFG['en_route'].text}`}>
                <span className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${TRACK_CFG['en_route'].dot} animate-pulse`} /> En Route
              </span>
            </div>
            <p className="text-gray-400 text-[11px] mt-0.5">CA 456-789 · Tautliner · Engine overheating</p>
          </div>
        </div>
      </div>

      {/* ── Status Timeline ── */}
      <div className="mx-5 mb-4 bg-[#0f0f0f] rounded-xl border border-[#1e1e1e] p-4">
        <p className="text-yellow-400 text-[11px] font-black uppercase tracking-widest mb-4">Status Timeline</p>
        <div>
          {TIMELINE_STEPS.map(({ key, label, time }, i) => {
            const stepIdx  = STATUS_FLOW.indexOf(key);
            const isDone   = stepIdx <= currentIdx;
            const isActive = stepIdx === currentIdx;
            const isLast   = i === TIMELINE_STEPS.length - 1;
            return (
              <div key={key} className="flex gap-3">
                {/* Dot + connector */}
                <div className="flex flex-col items-center">
                  <div className={`w-7 h-7 rounded-full flex items-center justify-center border-2 flex-shrink-0 transition-all ${
                    isActive
                      ? 'bg-yellow-400 border-yellow-400 shadow-[0_0_12px_rgba(251,191,36,0.5)]'
                      : isDone
                        ? 'bg-yellow-400 border-yellow-400'
                        : 'border-[#2a2a2a] bg-[#0f0f0f]'
                  }`}>
                    {isDone
                      ? <Check className="w-3.5 h-3.5 text-black" strokeWidth={3} />
                      : <div className="w-2 h-2 bg-[#2a2a2a] rounded-full" />
                    }
                  </div>
                  {!isLast && (
                    <div className={`w-px my-1 ${isDone && !isActive ? 'bg-yellow-400/50' : isDone ? 'bg-yellow-400/30' : 'bg-[#1e1e1e]'}`} style={{ minHeight: 22 }} />
                  )}
                </div>
                {/* Label */}
                <div className="pb-3 flex-1 flex items-start justify-between">
                  <p className={`text-[13px] font-black ${isActive ? 'text-yellow-400' : isDone ? 'text-white' : 'text-gray-700'}`}>{label}</p>
                  <p className={`text-[10px] font-mono ${isDone ? isActive ? 'text-yellow-400/70' : 'text-gray-500' : 'text-gray-800'}`}>{isDone || isActive ? time : '—'}</p>
                </div>
              </div>
            );
          })}
        </div>
        {/* Demo stepper */}
        <div className="mt-1 pt-3 border-t border-[#1a1a1a] flex items-center gap-2">
          <p className="text-gray-700 text-[9px] uppercase tracking-widest">Demo:</p>
          {STATUS_FLOW.map((s) => (
            <button
              key={s}
              onClick={() => setJobStatus(s)}
              className={`flex-1 py-1 rounded-lg text-[8px] font-black transition-colors ${jobStatus === s ? 'bg-yellow-400 text-black' : 'bg-[#1a1a1a] text-gray-600'}`}
            >
              {s.replace('_', ' ')}
            </button>
          ))}
        </div>
      </div>

      {/* ── Mechanic Info Card ── */}
      {mechanicAssigned ? (
        <div className="mx-5 mb-4 bg-[#0f0f0f] rounded-xl border border-[#1e1e1e] p-4">
          <p className="text-yellow-400 text-[11px] font-black uppercase tracking-widest mb-3">Assigned Mechanic</p>
          <div className="flex items-center gap-3">
            <img src={MECHANIC_IMG} alt="Mechanic" className="w-12 h-12 rounded-xl object-cover flex-shrink-0" />
            <div className="flex-1 min-w-0">
              <p className="text-white font-black text-sm">James Mitchell</p>
              <div className="flex items-center gap-1.5 mt-0.5">
                <Star className="w-3 h-3 fill-yellow-400 text-yellow-400" />
                <span className="text-yellow-400 text-[11px] font-semibold">4.9</span>
                <span className="text-gray-400 text-[11px]">· 184 jobs</span>
              </div>
              <p className="text-gray-300 text-[11px] mt-0.5">+44 7734 567 890</p>
            </div>
            <a href="tel:+447734567890" className="w-10 h-10 bg-yellow-400 rounded-xl flex items-center justify-center flex-shrink-0 active:scale-95 transition-transform">
              <Phone className="w-4 h-4 text-black" />
            </a>
          </div>
          {/* ETA row */}
          <div className="mt-3 pt-3 border-t border-[#1a1a1a] flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Clock className="w-3.5 h-3.5 text-gray-600" />
              <span className="text-gray-500 text-[12px]">ETA (from mechanic)</span>
            </div>
            <span className="text-white text-[12px] font-black">18 min</span>
          </div>
        </div>
      ) : (
        <div className="mx-5 mb-4 bg-[#0f0f0f] rounded-xl border border-[#1e1e1e] p-4 flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-[#1a1a1a] flex items-center justify-center flex-shrink-0">
            <Wrench className="w-5 h-5 text-gray-700" />
          </div>
          <div>
            <p className="text-gray-500 text-[12px] font-semibold">Awaiting mechanic assignment</p>
            <p className="text-gray-700 text-[10px] mt-0.5">A nearby mechanic will be assigned shortly</p>
          </div>
        </div>
      )}

      {/* ── Location Section ── */}
      <div className="mx-5 mb-4 bg-[#0f0f0f] rounded-xl border border-[#1e1e1e] p-4">
        <p className="text-yellow-400 text-[11px] font-black uppercase tracking-widest mb-3">Breakdown Location</p>
        <div className="flex items-start gap-2.5 mb-3">
          <MapPin className="w-4 h-4 text-gray-400 flex-shrink-0 mt-0.5" />
          <p className="text-white text-[13px] leading-snug">N1 Northbound, near Buccleuch Interchange, Sandton, Gauteng</p>
        </div>
        <a
          href="https://maps.google.com/?q=-26.0467,28.0713"
          target="_blank"
          rel="noopener noreferrer"
          className="w-full border border-yellow-400/30 bg-yellow-400/5 text-yellow-400 py-2.5 rounded-xl font-black text-[12px] tracking-wide flex items-center justify-center gap-2 active:scale-[0.98] transition-transform"
        >
          <ExternalLink className="w-3.5 h-3.5" /> Open in Google Maps
        </a>
      </div>

      {/* ── Payment Status ── */}
      <div className="mx-5 mb-4 bg-[#0f0f0f] rounded-xl border border-[#1e1e1e] p-4">
        <div className="flex items-center justify-between mb-3">
          <p className="text-yellow-400 text-[11px] font-black uppercase tracking-widest">Payment</p>
          <span className={`text-[10px] font-black px-2.5 py-1 rounded-lg border ${payment.bg} ${payment.color}`}>
            {payment.label}
          </span>
        </div>
        <div className="space-y-2">
          <div className="flex justify-between items-center">
            <span className="text-gray-600 text-[12px]">Quote Amount</span>
            <span className="text-white text-[12px] font-black">£165</span>
          </div>
          <div className="flex justify-between items-center">
            <span className="text-gray-600 text-[12px]">Platform Fee (12%)</span>
            <span className="text-gray-500 text-[12px] font-semibold">£20</span>
          </div>
          <div className="flex justify-between items-center">
            <span className="text-gray-600 text-[12px]">Pre-Auth Held</span>
            <span className="text-orange-400 text-[12px] font-semibold">£220</span>
          </div>
          <div className="flex justify-between items-center">
            <span className="text-gray-600 text-[12px]">Card</span>
            <span className="text-gray-500 text-[12px]">VISA •••• 4891</span>
          </div>
          <div className="border-t border-[#2a2a2a] pt-2 flex justify-between">
            <span className="text-white text-[12px] font-black">Total Payable</span>
            <span className="text-yellow-400 text-[12px] font-black">£185</span>
          </div>
        </div>
        {/* Demo: cycle payment status */}
        <div className="mt-3 pt-3 border-t border-[#1a1a1a] flex gap-1.5">
          {(['authorised', 'paid', 'refunded', 'released'] as const).map(s => (
            <button
              key={s}
              onClick={() => setPaymentStatus(s)}
              className={`flex-1 py-1 rounded-lg text-[8px] font-black transition-colors ${paymentStatus === s ? 'bg-yellow-400 text-black' : 'bg-[#1a1a1a] text-gray-600'}`}
            >
              {s}
            </button>
          ))}
        </div>
      </div>

      {/* ── Invoice Download — visible whenever funds are released ── */}
      {paymentStatus === 'released' && (
        <div className="mx-5 mb-4 bg-[#0f0f0f] rounded-xl border border-yellow-400/20 p-4">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-9 h-9 rounded-xl bg-yellow-400/10 flex items-center justify-center flex-shrink-0">
              <FileCheck className="w-5 h-5 text-yellow-400" />
            </div>
            <div>
              <p className="text-white text-[13px] font-black">Invoice Ready</p>
              <p className="text-gray-500 text-[10px]">TF-8821 · CA 456-789 · 8 Mar 2026</p>
            </div>
          </div>
          <div className="bg-[#111] rounded-xl p-3 mb-3 space-y-1.5">
            <div className="flex justify-between">
              <span className="text-gray-600 text-[11px]">Labour & Parts</span>
              <span className="text-white text-[11px] font-semibold">£165.00</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600 text-[11px]">Platform Fee (12%)</span>
              <span className="text-gray-500 text-[11px]">£20.00</span>
            </div>
            <div className="flex justify-between border-t border-[#2a2a2a] pt-1.5">
              <span className="text-white text-[11px] font-black">Total Charged</span>
              <span className="text-yellow-400 text-[11px] font-black">£185.00</span>
            </div>
          </div>
          <button className="w-full bg-yellow-400 text-black py-3.5 rounded-xl font-black text-[13px] tracking-widest uppercase flex items-center justify-center gap-2 active:scale-[0.98] transition-transform">
            <Download className="w-4 h-4" /> Download Invoice (PDF)
          </button>
          <p className="text-center text-gray-700 text-[9px] mt-2">Invoice ref: TF-INV-20260308-8821</p>
        </div>
      )}

      {/* ── Rate Mechanic ── */}
      {paymentStatus === 'released' && !ratingSubmitted && (
        <div className="mx-5 mb-4">
          <button
            onClick={() => setRatingModal(true)}
            className="w-full bg-[#0f0f0f] border border-yellow-400/30 rounded-xl py-4 flex items-center justify-center gap-2.5 active:scale-[0.98] transition-transform"
          >
            <div className="flex items-center gap-0.5">
              {[1,2,3,4,5].map(i => (
                <Star key={i} className="w-4 h-4 fill-yellow-400 text-yellow-400" />
              ))}
            </div>
            <span className="text-yellow-400 font-black text-[13px] tracking-wide uppercase">Rate Your Mechanic</span>
          </button>
        </div>
      )}
      {paymentStatus === 'released' && ratingSubmitted && (
        <div className="mx-5 mb-4 bg-green-400/10 border border-green-400/30 rounded-xl px-4 py-3 flex items-center gap-2.5">
          <CheckCircle className="w-4 h-4 text-green-400 flex-shrink-0" />
          <p className="text-green-400 text-[12px] font-semibold">Review submitted — thank you!</p>
        </div>
      )}

      {/* ── Action Buttons ── */}
      <div className="px-5 pb-6 space-y-2.5">
        {mechanicStartedJourney && paymentStatus !== 'released' && (
          <button
            onClick={() => setContactModal(true)}
            className="w-full bg-yellow-400 text-black py-4 rounded-xl font-black text-[13px] tracking-widest uppercase flex items-center justify-center gap-2 active:scale-[0.98] transition-transform"
          >
            <MessageCircle className="w-4 h-4" /> Contact Mechanic
          </button>
        )}
        {/* Cancel — hidden once funds are released */}
        {paymentStatus !== 'released' && (
          <button
            onClick={() => setCancelModal(true)}
            className="w-full border border-red-500/30 text-red-400 py-3.5 rounded-xl font-semibold text-[12px] tracking-wide bg-red-500/5 active:scale-[0.98] transition-transform"
          >
            {detailHasFee ? `Cancel Job · ${detailFeeAmt} fee (10%)` : 'Cancel Job — Free'}
          </button>
        )}
      </div>

      </div>
    </div>
  );
}

// ─── Quote Received ───────────────────────────────────────────────────────────────
function QuoteReceived({ setTab }: { setTab: (t: string) => void }) {
  const [state, setState] = useState<'idle' | 'accepted' | 'declined'>('idle');
  // Quote total = £165; cancellation fee = 10% once accepted
  const quoteTotal     = 165;
  const cancellationFee = `£${Math.round(quoteTotal * 0.1)}`; // £17

  if (state === 'accepted') {
    return (
      <div className="h-full bg-[#080808] flex flex-col items-center justify-center px-8 text-center">
        <div className="relative mb-5">
          <div className="absolute inset-0 bg-green-400 rounded-full blur-[32px] opacity-25" />
          <div className="relative w-20 h-20 bg-[#0f0f0f] border-2 border-green-400 rounded-full flex items-center justify-center">
            <CheckCircle className="w-10 h-10 text-green-400" />
          </div>
        </div>
        <p className="text-white font-black text-xl mb-2">Quote Accepted!</p>
        <p className="text-gray-400 text-[13px] leading-relaxed mb-2">
          <span className="text-white font-semibold">James Mitchell</span> has been confirmed for job <span className="text-yellow-400 font-semibold">TF-8821</span>.
        </p>
        <p className="text-gray-400 text-[12px] leading-relaxed mb-6">
          He will set off shortly. By accepting this quote, a <span className="text-red-400 font-semibold">10% cancellation fee</span> now applies if you cancel this emergency job.
        </p>
        <button onClick={() => setTab('tracking')} className="w-full bg-yellow-400 text-black py-4 rounded-xl font-black text-[13px] tracking-widest uppercase flex items-center justify-center gap-2">
          <Navigation className="w-4 h-4" /> Track Job
        </button>
        <button onClick={() => setState('idle')} className="w-full text-gray-500 text-[12px] py-3">
          Back
        </button>
      </div>
    );
  }

  if (state === 'declined') {
    return (
      <div className="h-full bg-[#080808] flex flex-col items-center justify-center px-8 text-center">
        <div className="w-16 h-16 bg-[#1a1a1a] border border-[#2a2a2a] rounded-full flex items-center justify-center mb-5">
          <X className="w-8 h-8 text-gray-500" />
        </div>
        <p className="text-white font-black text-xl mb-2">Quote Declined</p>
        <p className="text-gray-400 text-[13px] leading-relaxed mb-6">
          The mechanic's quote for <span className="text-yellow-400 font-semibold">TF-8821</span> has been declined. Your job remains live and other mechanics can still respond.
        </p>
        <button onClick={() => setTab('tracking')} className="w-full bg-[#111] border border-[#2a2a2a] text-white py-4 rounded-xl font-black text-[13px]">
          Back to Tracking
        </button>
        <button onClick={() => setState('idle')} className="w-full text-gray-500 text-[12px] py-3">
          View Quote Again
        </button>
      </div>
    );
  }

  return (
    <div className="h-full bg-[#080808] flex flex-col relative overflow-hidden">

      {/* ── Dimmed dashboard hint (top portion) ── */}
      <div className="flex-1 flex flex-col justify-end relative">
        {/* Fake blurred bg to imply the app is underneath */}
        <div className="absolute inset-0 flex flex-col px-5 pt-5 opacity-20 pointer-events-none select-none">
          <p className="text-white font-black text-xl mb-3">Dashboard</p>
          <div className="grid grid-cols-3 gap-2 mb-4">
            {['Active', 'Awaiting', 'Month'].map(l => (
              <div key={l} className="bg-[#0f0f0f] rounded-xl border border-[#1a1a1a] p-3 h-16" />
            ))}
          </div>
          <div className="bg-yellow-400/20 rounded-xl h-14 mb-3" />
          <div className="space-y-2">
            <div className="bg-[#0f0f0f] rounded-xl h-20 border border-[#1a1a1a]" />
            <div className="bg-[#0f0f0f] rounded-xl h-20 border border-[#1a1a1a]" />
          </div>
        </div>

        {/* ── Push notification banner ── */}
        <div className="absolute top-4 left-4 right-4 z-20">
          <div className="bg-[#161616] border border-yellow-400/40 rounded-2xl p-3.5 flex items-center gap-3 shadow-[0_4px_32px_rgba(0,0,0,0.7)]">
            <div className="w-10 h-10 bg-yellow-400/15 rounded-xl flex items-center justify-center flex-shrink-0">
              <Bell className="w-5 h-5 text-yellow-400" />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-white font-black text-[12px]">New Quote — TF-8821</p>
              <p className="text-gray-400 text-[11px] truncate">James Mitchell quoted £165 · responded in 3 min</p>
            </div>
            <span className="text-yellow-400 text-[10px] font-black flex-shrink-0">NOW</span>
          </div>
        </div>

        {/* ── Quote Sheet ── */}
        <div className="relative z-10 bg-[#0e0e0e] rounded-t-3xl border-t border-[#2a2a2a] pt-5 pb-6 px-5 shadow-[0_-8px_48px_rgba(0,0,0,0.8)]">

          {/* Handle */}
          <div className="w-10 h-1 bg-[#333] rounded-full mx-auto mb-5" />

          {/* Sheet header */}
          <div className="flex items-center justify-between mb-4">
            <div>
              <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-0.5">New Quote Received</p>
              <h2 className="text-white font-black text-lg tracking-tight">TF-8821</h2>
              <p className="text-gray-400 text-[11px]">Tautliner · CA 456-789 · Engine overheating</p>
            </div>
            <span className="text-[9px] font-black px-2.5 py-1 rounded-lg bg-orange-400/10 border border-orange-400/30 text-orange-400 uppercase">HIGH</span>
          </div>

          {/* Mechanic card */}
          <div className="bg-[#111] rounded-xl border border-[#1e1e1e] p-3.5 flex items-center gap-3 mb-3">
            <img src={MECHANIC_IMG} alt="Mechanic" className="w-12 h-12 rounded-xl object-cover flex-shrink-0 border border-[#2a2a2a]" />
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-1.5 mb-0.5">
                <p className="text-white font-black text-[13px]">James Mitchell</p>
                <span className="text-[9px] font-black px-1.5 py-0.5 rounded bg-green-400/15 text-green-400 border border-green-400/30">VERIFIED</span>
              </div>
              <div className="flex items-center gap-1.5">
                <Star className="w-3 h-3 fill-yellow-400 text-yellow-400" />
                <span className="text-yellow-400 text-[11px] font-semibold">4.9</span>
                <span className="text-gray-500 text-[11px]">· 184 jobs</span>
                <span className="text-gray-600 text-[11px]">·</span>
                <Navigation className="w-3 h-3 text-orange-400" />
                <span className="text-orange-400 text-[11px] font-semibold">18 min ETA</span>
              </div>
            </div>
          </div>

          {/* Quote breakdown */}
          <div className="bg-[#111] rounded-xl border border-[#1e1e1e] p-3.5 mb-3">
            <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-2.5">Quote Breakdown</p>
            <div className="space-y-1.5">
              <div className="flex justify-between items-center">
                <span className="text-gray-400 text-[12px]">Labour (est. 1.5 hrs × £75)</span>
                <span className="text-white text-[12px] font-semibold">£112</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-400 text-[12px]">Call-out Fee</span>
                <span className="text-white text-[12px] font-semibold">£35</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-400 text-[12px]">Parts (est.)</span>
                <span className="text-white text-[12px] font-semibold">£18</span>
              </div>
              <div className="flex justify-between items-center border-t border-[#2a2a2a] pt-1.5 mt-1">
                <span className="text-white text-[13px] font-black">Total</span>
                <span className="text-yellow-400 text-[15px] font-black">£165</span>
              </div>
            </div>
          </div>

          {/* Cancellation policy */}
          <div className="bg-[#0f0f0f] border border-[#1e1e1e] rounded-xl p-3.5 mb-4">
            <div className="flex items-center gap-2 mb-3">
              <AlertTriangle className="w-3.5 h-3.5 text-yellow-400 flex-shrink-0" />
              <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Cancellation Policy</p>
            </div>
            <div className="space-y-2">
              <div className="flex items-start gap-2.5">
                <div className="w-5 h-5 rounded-full bg-green-400/15 border border-green-400/30 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <Check className="w-3 h-3 text-green-400" strokeWidth={3} />
                </div>
                <p className="text-white text-[12px] leading-snug"><span className="text-green-400 font-semibold">Free cancellation</span> before the mechanic is on route</p>
              </div>
              <div className="flex items-start gap-2.5">
                <div className="w-5 h-5 rounded-full bg-red-400/15 border border-red-400/30 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <AlertTriangle className="w-3 h-3 text-red-400" strokeWidth={2.5} />
                </div>
                <p className="text-white text-[12px] leading-snug"><span className="text-red-400 font-semibold">10% cancellation fee</span> once the mechanic is on the way</p>
              </div>
            </div>
          </div>

          {/* CTA buttons */}
          <div className="space-y-2">
            <button
              onClick={() => setState('accepted')}
              className="w-full bg-yellow-400 text-black py-4 rounded-xl font-black text-[13px] tracking-widest uppercase flex items-center justify-center gap-2 active:scale-[0.98] transition-transform"
            >
              <CheckCircle className="w-4 h-4" /> Accept Quote — £165
            </button>
            <button
              onClick={() => setState('declined')}
              className="w-full border border-[#2a2a2a] text-gray-400 py-3.5 rounded-xl font-semibold text-[12px] hover:border-red-500/30 hover:text-red-400 transition-colors"
            >
              Decline Quote
            </button>
          </div>

        </div>
      </div>
    </div>
  );
}

// ─── Help & Support Sheet (Fleet) ─────────────────────────────────────────────
function FleetHelpSheet({ onClose }: { onClose: () => void }) {
  const [category, setCategory] = useState<string | null>(null);
  const [message, setMessage] = useState('');
  const [sent, setSent] = useState(false);

  const categories = [
    { id: 'job',      label: 'Job / Booking',     icon: Zap },
    { id: 'payment',  label: 'Payment / Invoice',  icon: CreditCard },
    { id: 'account',  label: 'Account & Profile',  icon: User },
    { id: 'mechanic', label: 'Mechanic Issue',      icon: Wrench },
    { id: 'other',    label: 'Other',              icon: HelpCircle },
  ];

  if (sent) {
    return (
      <div className="absolute inset-0 bg-black/85 z-50 flex flex-col justify-end" onClick={onClose}>
        <div className="bg-[#0e0e0e] rounded-t-3xl border-t border-[#2a2a2a] p-6 flex flex-col items-center text-center" onClick={e => e.stopPropagation()}>
          <div className="w-10 h-1 bg-[#333] rounded-full mx-auto mb-5 mt-1" />
          <div className="w-16 h-16 bg-green-400/15 rounded-2xl flex items-center justify-center mb-4 border border-green-400/30">
            <CheckCircle className="w-8 h-8 text-green-400" />
          </div>
          <p className="text-white font-black text-[16px] mb-1.5">Message Sent!</p>
          <p className="text-gray-400 text-[12px] leading-relaxed mb-6">Our support team will respond within 24 hours via your registered email address.</p>
          <button onClick={onClose} className="w-full bg-yellow-400 text-black py-3.5 rounded-xl font-black text-[12px] tracking-widest uppercase">Done</button>
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
            <p className="text-gray-600 text-[10px] mt-1.5">Sent from: john@logistix.co.za · Fleet Operator</p>
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

// ─── Fleet Profile ────────────────────────────────────────────────────────────────
function FleetProfile({ setTab, openHelp, onLogout }: { setTab: (t: string) => void; openHelp: () => void; onLogout?: () => void }) {
  return (
    <div className="h-full bg-[#080808] overflow-y-auto" style={{ scrollbarWidth: 'none' }}>
      {/* Header */}
      <div className="px-5 pt-5 pb-5 flex flex-col items-center border-b border-[#1a1a1a]">
        <div className="w-16 h-16 bg-yellow-400 rounded-2xl flex items-center justify-center mb-3 shadow-[0_0_30px_rgba(251,191,36,0.2)]">
          <span className="text-black font-black text-xl">LT</span>
        </div>
        <h2 className="text-white font-black text-lg tracking-tight">Logistix Transport</h2>
        <p className="text-gray-500 text-[12px] mt-0.5">john@logistix.co.za</p>
      </div>

      <div className="px-5 space-y-3 py-5 pb-8">

        {/* Company Details */}
        <Section title="Company Details">
          <Row label="Company Name" value="Logistix Transport (Pty) Ltd" />
          <Row label="Reg Number" value="2019/223456/07" />
          <Row label="VAT Number" value="4120889456" />
          <Row label="Fleet Size" value="21–50 vehicles" />
        </Section>

        {/* Contact Person */}
        <Section title="Contact Person">
          <Row label="Name" value="John Khumalo" />
          <Row label="Role" value="Fleet Manager" />
          <Row label="Phone" value="+44 7712 345 678" />
          <Row label="Email" value="john@logistix.co.za" />
        </Section>

        {/* Billing & Payment */}
        <Section title="Billing & Payment">
          <Row label="Card Number" value="VISA •••• 4891" />
          <Row label="Expiry" value="09 / 28" />
          <Row label="CCV" value="•••" />
          <Row label="Billing Address" value="123 Logistics Ave, JHB" />
        </Section>

        {/* Actions */}
        <button
          onClick={() => setTab('edit-profile')}
          className="w-full bg-yellow-400 rounded-xl py-3.5 flex items-center justify-center gap-2 text-black text-[12px] font-black tracking-wide"
        >
          <Edit3 className="w-4 h-4" /> Edit Profile
        </button>

        {/* Payment Methods */}
        <button
          onClick={() => setTab('payment-methods')}
          className="w-full bg-[#0f0f0f] border border-[#1e1e1e] rounded-xl py-3.5 flex items-center gap-3 px-4 hover:border-yellow-400/30 transition-colors"
        >
          <div className="w-8 h-8 bg-yellow-400/10 rounded-lg flex items-center justify-center flex-shrink-0">
            <CreditCard className="w-4 h-4 text-yellow-400" />
          </div>
          <div className="flex-1 text-left">
            <p className="text-white text-[12px] font-semibold">Payment Methods</p>
            <p className="text-gray-600 text-[10px]">Manage your cards & billing</p>
          </div>
          <ChevronRight className="w-4 h-4 text-gray-600" />
        </button>

        {/* My Fleet */}
        <button
          onClick={() => setTab('vehicles')}
          className="w-full bg-[#0f0f0f] border border-[#1e1e1e] rounded-xl py-3.5 flex items-center gap-3 px-4 hover:border-yellow-400/30 transition-colors"
        >
          <div className="w-8 h-8 bg-yellow-400/10 rounded-lg flex items-center justify-center flex-shrink-0">
            <Truck className="w-4 h-4 text-yellow-400" />
          </div>
          <div className="flex-1 text-left">
            <p className="text-white text-[12px] font-semibold">My Fleet</p>
            <p className="text-gray-600 text-[10px]">Manage your vehicles</p>
          </div>
          <ChevronRight className="w-4 h-4 text-gray-600" />
        </button>

        {/* Help & Support */}
        <button
          onClick={openHelp}
          className="w-full bg-[#0f0f0f] border border-[#1e1e1e] rounded-xl py-3.5 flex items-center gap-3 px-4 hover:border-yellow-400/30 transition-colors"
        >
          <div className="w-8 h-8 bg-yellow-400/10 rounded-lg flex items-center justify-center flex-shrink-0">
            <HelpCircle className="w-4 h-4 text-yellow-400" />
          </div>
          <div className="flex-1 text-left">
            <p className="text-white text-[12px] font-semibold">Help &amp; Support</p>
            <p className="text-gray-600 text-[10px]">Send a message to the TruckFix team</p>
          </div>
          <ChevronRight className="w-4 h-4 text-gray-600" />
        </button>

        <button 
          onClick={onLogout}
          className="w-full border border-red-500/20 rounded-xl py-3.5 flex items-center justify-center gap-2 text-red-400 text-[12px] font-semibold bg-red-500/5 active:scale-[0.98] transition-transform"
        >
          <LogOut className="w-4 h-4" /> Log Out
        </button>

        {/* Created at */}
        <p className="text-center text-gray-700 text-[10px] pt-2">Account created · 07 Mar 2026 · TruckFix v2.4.1</p>
      </div>
    </div>
  );
}

// ─── Fleet Edit Profile ───────────────────────────────────────────────────────────
function FleetEditProfile({ setTab, onSave }: { setTab: (t: string) => void; onSave: () => void }) {
  return (
    <div className="h-full bg-[#080808] flex flex-col">
      {/* Header */}
      <div className="px-5 pt-5 pb-4 border-b border-[#1a1a1a] flex items-center gap-3 flex-shrink-0">
        <button
          onClick={() => setTab('profile')}
          className="w-8 h-8 rounded-xl bg-[#111] border border-[#2a2a2a] flex items-center justify-center"
        >
          <ChevronDown className="w-4 h-4 text-gray-400 rotate-90" />
        </button>
        <div>
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">Fleet Operator</p>
          <h2 className="text-white font-black text-base tracking-tight">Edit Profile</h2>
        </div>
      </div>

      {/* Scrollable fields */}
      <div className="flex-1 overflow-y-auto px-5 py-5 space-y-5" style={{ scrollbarWidth: 'none' }}>

        {/* Company Details */}
        <div>
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-3">Company Details</p>
          <div className="space-y-3">
            <Input label="Company Name" placeholder="Logistix Transport (Pty) Ltd" />
            <Input label="Reg Number" placeholder="2019/223456/07" />
            <Input label="VAT Number" placeholder="4120889456" />
            <div className="space-y-1.5">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">
                Fleet Size <span className="normal-case tracking-normal text-gray-700">(optional)</span>
              </label>
              <select className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-yellow-400/60 text-sm appearance-none">
                <option>21–50 vehicles</option>
                <option>1–5 vehicles</option>
                <option>6–20 vehicles</option>
                <option>51–100 vehicles</option>
                <option>100+ vehicles</option>
              </select>
            </div>
          </div>
        </div>

        <div className="h-px bg-[#1a1a1a]" />

        {/* Contact Person */}
        <div>
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-3">Contact Person</p>
          <div className="space-y-3">
            <Input label="Full Name" placeholder="John Khumalo" />
            <Input label="Role / Title" placeholder="Fleet Manager" />
            <Input label="Phone" placeholder="+27 82 123 4567" type="tel" />
            <Input label="Email" placeholder="john@logistix.co.za" type="email" />
          </div>
        </div>

        <div className="h-px bg-[#1a1a1a]" />

        {/* Billing & Payment */}
        <div>
          <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest mb-3">Billing & Payment</p>
          <div className="space-y-3">
            {/* Card number with lock icon */}
            <div className="space-y-1.5">
              <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Card Number</label>
              <div className="relative">
                <input
                  type="text"
                  placeholder="1234  5678  9012  3456"
                  maxLength={19}
                  className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 pr-10 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm tracking-widest"
                />
                <Lock className="absolute right-3.5 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-gray-700" />
              </div>
            </div>
            {/* Expiry + CCV side by side */}
            <div className="flex gap-3">
              <div className="space-y-1.5 flex-1">
                <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Expiry</label>
                <input
                  type="text"
                  placeholder="MM / YY"
                  maxLength={7}
                  className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm tracking-widest"
                />
              </div>
              <div className="space-y-1.5 flex-1">
                <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">CCV</label>
                <div className="relative">
                  <input
                    type="password"
                    placeholder="•••"
                    maxLength={4}
                    className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 pr-10 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm"
                  />
                  <Lock className="absolute right-3.5 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-gray-700" />
                </div>
              </div>
            </div>
            <Input label="Billing Address" placeholder="123 Logistics Ave, Johannesburg" />
          </div>
          {/* Security note */}
          <div className="flex items-center gap-2 mt-3">
            <Lock className="w-3 h-3 text-gray-700 flex-shrink-0" />
            <p className="text-gray-700 text-[10px]">Card details are encrypted and stored securely. TruckFix never stores raw card data.</p>
          </div>
        </div>

        {/* Bottom padding */}
        <div className="h-4" />
      </div>

      {/* Save footer */}
      <div className="px-5 pb-6 pt-3 border-t border-[#1a1a1a] space-y-2.5 flex-shrink-0">
        <PrimaryBtn onClick={onSave}>Save Changes</PrimaryBtn>
        <button
          onClick={() => setTab('profile')}
          className="w-full py-3 text-gray-600 text-[12px] font-semibold"
        >
          Cancel
        </button>
      </div>
    </div>
  );
}

function Section({ title, children }: any) {
  return (
    <div className="bg-[#0f0f0f] rounded-xl border border-[#1a1a1a] overflow-hidden">
      <div className="px-4 py-2.5 border-b border-[#1a1a1a]">
        <p className="text-yellow-400 text-[10px] font-black uppercase tracking-widest">{title}</p>
      </div>
      <div className="p-4 space-y-2.5">{children}</div>
    </div>
  );
}

function Row({ label, value }: any) {
  return (
    <div className="flex items-center justify-between">
      <span className="text-gray-600 text-[12px]">{label}</span>
      <span className="text-white text-[12px] font-semibold">{value}</span>
    </div>
  );
}

// ─── Vehicle Detail ───────────────────────────────────────────────────────────────
function VehicleDetail({ vehicle, onClose, onRequestService }: { vehicle: any; onClose: () => void; onRequestService?: (vehicle: any) => void }) {
  const [showEditSheet, setShowEditSheet] = useState(false);
  const [editFormData, setEditFormData] = useState({
    reg: vehicle.reg,
    make: vehicle.make,
    model: vehicle.model,
    type: vehicle.type,
    vin: vehicle.vin,
    mileage: vehicle.mileage,
  });

  const handleSave = () => {
    setShowEditSheet(false);
  };

  return (
    <div className="h-full bg-[#080808] overflow-y-auto relative" style={{ scrollbarWidth: 'none' }}>
      {/* Header */}
      <div className="px-5 pt-5 pb-4 border-b border-[#1a1a1a] flex items-center gap-3">
        <button onClick={onClose} className="w-9 h-9 bg-[#1a1a1a] rounded-xl flex items-center justify-center flex-shrink-0">
          <ArrowLeft className="w-4 h-4 text-gray-400" />
        </button>
        <div className="flex-1">
          <p className="text-white font-black text-lg">{editFormData.reg}</p>
          <p className="text-gray-500 text-[11px]">{editFormData.make} {editFormData.model}</p>
        </div>
      </div>

      <div className="px-5 py-5 space-y-4 pb-24">
        {/* Vehicle Info */}
        <Section title="Vehicle Information">
          <Row label="Registration" value={editFormData.reg} />
          <Row label="Make" value={editFormData.make} />
          <Row label="Model" value={editFormData.model} />
        </Section>

        {/* Recent Jobs */}
        <Section title="Recent Jobs">
          <div className="space-y-2.5">
            <div className="bg-[#0a0a0a] rounded-lg p-3 border border-[#1e1e1e]">
              <div className="flex items-center justify-between mb-2">
                <p className="text-white text-[12px] font-semibold">Engine diagnostics</p>
                <span className="text-green-400 text-[9px] font-black uppercase tracking-wide px-1.5 py-0.5 bg-green-400/10 border border-green-400/30 rounded">Complete</span>
              </div>
              <p className="text-gray-600 text-[10px]">2 Mar 2025 · James Mitchell</p>
            </div>
            <div className="bg-[#0a0a0a] rounded-lg p-3 border border-[#1e1e1e]">
              <div className="flex items-center justify-between mb-2">
                <p className="text-white text-[12px] font-semibold">Brake replacement</p>
                <span className="text-green-400 text-[9px] font-black uppercase tracking-wide px-1.5 py-0.5 bg-green-400/10 border border-green-400/30 rounded">Complete</span>
              </div>
              <p className="text-gray-600 text-[10px]">15 Jan 2025 · Tom Stevens</p>
            </div>
          </div>
        </Section>

        {/* Actions */}
        <button 
          onClick={() => onRequestService?.(vehicle)}
          className="w-full bg-yellow-400 rounded-xl py-3.5 flex items-center justify-center gap-2 text-black text-[12px] font-black tracking-wide uppercase active:scale-[0.98] transition-transform"
        >
          <Wrench className="w-4 h-4" /> Request Service
        </button>
        
        <button 
          onClick={() => setShowEditSheet(true)}
          className="w-full bg-[#0f0f0f] border border-[#1e1e1e] rounded-xl py-3.5 flex items-center justify-center gap-2 text-gray-400 text-[12px] font-semibold active:scale-[0.98] transition-transform"
        >
          <Edit3 className="w-4 h-4" /> Edit Vehicle Details
        </button>
      </div>

      {/* Edit Vehicle Sheet */}
      {showEditSheet && (
        <div className="absolute inset-0 bg-black/85 z-50 flex flex-col justify-end" onClick={() => setShowEditSheet(false)}>
          <div className="bg-[#0e0e0e] rounded-t-3xl border-t border-[#2a2a2a] flex flex-col max-h-[85%]" onClick={e => e.stopPropagation()}>
            <div className="flex justify-center pt-3 pb-1 flex-shrink-0">
              <div className="w-10 h-1 bg-[#333] rounded-full" />
            </div>
            <div className="px-5 pt-2 pb-3 border-b border-[#1a1a1a] flex items-center justify-between flex-shrink-0">
              <p className="text-white font-black text-lg">Edit Vehicle</p>
              <button onClick={() => setShowEditSheet(false)} className="w-8 h-8 bg-[#1a1a1a] rounded-xl flex items-center justify-center">
                <X className="w-3.5 h-3.5 text-gray-500" />
              </button>
            </div>
            <div className="flex-1 overflow-y-auto px-5 py-4 space-y-3" style={{ scrollbarWidth: 'none' }}>
              <div className="space-y-1.5">
                <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Registration</label>
                <input 
                  type="text" 
                  value={editFormData.reg}
                  onChange={(e) => setEditFormData({...editFormData, reg: e.target.value})}
                  className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm" 
                />
              </div>
              <div className="space-y-1.5">
                <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Make</label>
                <input 
                  type="text" 
                  value={editFormData.make}
                  onChange={(e) => setEditFormData({...editFormData, make: e.target.value})}
                  className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm" 
                />
              </div>
              <div className="space-y-1.5">
                <label className="text-[11px] text-gray-500 uppercase tracking-widest font-semibold">Model</label>
                <input 
                  type="text" 
                  value={editFormData.model}
                  onChange={(e) => setEditFormData({...editFormData, model: e.target.value})}
                  className="w-full bg-[#111] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder:text-gray-700 focus:outline-none focus:border-yellow-400/60 text-sm" 
                />
              </div>
            </div>
            <div className="px-5 py-4 border-t border-[#1a1a1a] flex-shrink-0 space-y-2">
              <button
                onClick={handleSave}
                className="w-full bg-yellow-400 text-black py-4 rounded-xl font-black text-sm tracking-widest uppercase active:scale-[0.98] transition-transform"
              >
                Save Changes
              </button>
              <button
                onClick={() => setShowEditSheet(false)}
                className="w-full py-2.5 text-gray-600 text-[12px] font-semibold"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────────
function BottomNav({ active, setTab }: { active: string; setTab: (t: string) => void }) {
  const tabs = [
    { id: 'dashboard', icon: LayoutDashboard, label: 'Dashboard' },
    { id: 'post-job', icon: PlusCircle, label: 'Post Job' },
    { id: 'tracking', icon: Navigation, label: 'Tracking' },
    { id: 'profile', icon: User, label: 'Profile' },
  ];
  return (
    <div className="flex-shrink-0 bg-[#080808] border-t border-[#1a1a1a] pb-2 pt-1">
      <div className="flex">
        {tabs.map(({ id, icon: Icon, label }) => {
          // tracking-detail is a sub-screen of tracking — keep Tracking tab highlighted
          const isActive = active === id || (id === 'tracking' && active === 'tracking-detail');
          return (
            <button key={id} onClick={() => setTab(id)} className="flex-1 flex flex-col items-center gap-1 py-2">
              <div className={`w-7 h-7 rounded-xl flex items-center justify-center transition-colors ${isActive ? 'bg-yellow-400' : ''}`}>
                <Icon className={`w-3.5 h-3.5 ${isActive ? 'text-black' : 'text-gray-600'}`} strokeWidth={isActive ? 2.5 : 2} />
              </div>
              <span className={`text-[8px] font-semibold transition-colors ${isActive ? 'text-yellow-400' : 'text-gray-700'}`}>{label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ─── Main Export ─────────────────────────────────────────────────────────────────
const tabMap: Record<string, string> = {
  'fleet-dashboard':      'dashboard',
  'fleet-post-job':       'post-job',
  'fleet-tracking':       'tracking',
  'fleet-quote-received': 'quote-received',
  'fleet-profile':        'profile',
  'fleet-edit-profile':   'edit-profile',
};

export function FleetApp({ screen, onLogout }: { screen: string; onLogout?: () => void }) {
  const [tab, setTab] = useState<string>(() => tabMap[screen] ?? 'dashboard');
  const [profileComplete, setProfileComplete] = useState<boolean>(
    () => localStorage.getItem('truckfix_fleet_profile_complete') === 'true'
  );
  const [helpOpen, setHelpOpen] = useState(false);
  const [selectedVehicle, setSelectedVehicle] = useState<any>(null);
  const [prefilledVehicle, setPrefilledVehicle] = useState<any>(null);

  useEffect(() => {
    const mapped = tabMap[screen];
    if (mapped) setTab(mapped);
  }, [screen]);

  const handleSaveProfile = () => {
    localStorage.setItem('truckfix_fleet_profile_complete', 'true');
    setProfileComplete(true);
    setTab('profile');
  };

  const handleSelectVehicle = (vehicle: any) => {
    setSelectedVehicle(vehicle);
    setTab('vehicle-detail');
  };

  const handleRequestService = (vehicle: any) => {
    setPrefilledVehicle(vehicle);
    setTab('post-job');
  };

  function renderScreen() {
    switch (tab) {
      case 'dashboard':    return <FleetDashboard setTab={setTab} />;
      case 'post-job':     return <PostJob setTab={setTab} profileComplete={profileComplete} prefilledVehicle={prefilledVehicle} />;
      case 'tracking':        return <JobTracking setTab={setTab} />;
      case 'tracking-detail': return <JobTrackingDetail setTab={setTab} />;
      case 'quote-received':  return <QuoteReceived setTab={setTab} />;
      case 'profile':         return <FleetProfile setTab={setTab} openHelp={() => setHelpOpen(true)} onLogout={onLogout} />;
      case 'edit-profile': return <FleetEditProfile setTab={setTab} onSave={handleSaveProfile} />;
      case 'payment-methods': return <PaymentMethodsScreen onClose={() => setTab('profile')} />;
      case 'vehicles':        return <VehicleFleetScreen onClose={() => setTab('profile')} onSelectVehicle={handleSelectVehicle} />;
      case 'vehicle-detail':  return selectedVehicle ? <VehicleDetail vehicle={selectedVehicle} onClose={() => setTab('vehicles')} onRequestService={handleRequestService} /> : <FleetDashboard setTab={setTab} />;
      default:             return <FleetDashboard setTab={setTab} />;
    }
  }

  return (
    <div className="h-full flex flex-col bg-[#080808] relative">
      {helpOpen && <FleetHelpSheet onClose={() => setHelpOpen(false)} />}
      <div className="flex-1 overflow-hidden">
        {renderScreen()}
      </div>
      <BottomNav active={tab} setTab={setTab} />
    </div>
  );
}