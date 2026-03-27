import { useState } from "react";
import { useNavigate } from "react-router";
import { motion } from "motion/react";
import {
  ArrowLeft,
  DollarSign,
  Sparkles,
  Copy,
  CheckCircle2,
  TrendingUp,
  MapPin,
  Briefcase,
} from "lucide-react";
import { toast } from "sonner";
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";

const salaryData = [
  { percentile: "10th", salary: 95000 },
  { percentile: "25th", salary: 115000 },
  { percentile: "50th", salary: 140000 },
  { percentile: "75th", salary: 165000 },
  { percentile: "90th", salary: 195000 },
];

const negotiationScript = `Thank you for extending this offer - I'm genuinely excited about the opportunity to join [Company] as a Senior Product Designer.

After researching market data for this role in San Francisco, I've found that the typical range is $140,000 - $165,000 for someone with my experience level. Given my track record of delivering measurable results, including a 25% reduction in cart abandonment and leading a design system used across 5 teams, I'd like to discuss a base salary of $155,000.

I'm also interested in discussing:
- Signing bonus to bridge the gap between my current compensation
- Equity/RSU package details  
- Professional development budget

I'm very flexible and open to finding a package that works for both of us. I'd love to discuss this further.`;

export default function SalaryNegotiatorScreen() {
  const navigate = useNavigate();
  const [role, setRole] = useState("");
  const [location, setLocation] = useState("");
  const [experience, setExperience] = useState("mid");
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [showResults, setShowResults] = useState(false);
  const [copied, setCopied] = useState(false);

  const handleAnalyze = () => {
    if (!role.trim()) {
      toast.error("Please enter a role");
      return;
    }
    setIsAnalyzing(true);
    setTimeout(() => {
      setShowResults(true);
      setIsAnalyzing(false);
    }, 2000);
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(negotiationScript);
    setCopied(true);
    toast.success("Script copied!");
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <button
        onClick={() => navigate("/app/tools")}
        className="flex items-center gap-2 text-slate-500 hover:text-slate-700 text-sm font-medium transition-colors"
      >
        <ArrowLeft size={16} /> Back to Tools
      </button>

      <div className="flex items-center gap-3">
        <div className="w-10 h-10 bg-orange-100 rounded-xl flex items-center justify-center">
          <DollarSign size={20} className="text-orange-600" />
        </div>
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Salary Negotiator</h1>
          <p className="text-sm text-slate-500">Get market data and a personalized negotiation script.</p>
        </div>
      </div>

      {/* Input Form */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 space-y-6"
      >
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Target Role</label>
            <div className="relative">
              <Briefcase className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={16} />
              <input
                type="text"
                value={role}
                onChange={(e) => setRole(e.target.value)}
                placeholder="e.g. Senior Product Designer"
                className="w-full pl-10 pr-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 text-sm"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Location</label>
            <div className="relative">
              <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={16} />
              <input
                type="text"
                value={location}
                onChange={(e) => setLocation(e.target.value)}
                placeholder="e.g. San Francisco, CA"
                className="w-full pl-10 pr-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 text-sm"
              />
            </div>
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-slate-700 mb-2">Experience Level</label>
          <div className="grid grid-cols-3 gap-3">
            {[
              { value: "entry", label: "Entry (0-2 yrs)" },
              { value: "mid", label: "Mid (3-5 yrs)" },
              { value: "senior", label: "Senior (6+ yrs)" },
            ].map((lvl) => (
              <button
                key={lvl.value}
                onClick={() => setExperience(lvl.value)}
                className={`py-2.5 px-4 rounded-lg border text-sm font-medium transition-all
                  ${experience === lvl.value
                    ? "bg-indigo-50 border-indigo-500 text-indigo-700 ring-1 ring-indigo-500"
                    : "bg-white border-slate-200 text-slate-700 hover:bg-slate-50"
                  }`}
              >
                {lvl.label}
              </button>
            ))}
          </div>
        </div>

        <button
          onClick={handleAnalyze}
          disabled={isAnalyzing}
          className="w-full py-3 bg-indigo-600 text-white rounded-xl font-medium hover:bg-indigo-700 disabled:opacity-50 transition-colors flex items-center justify-center gap-2"
        >
          {isAnalyzing ? (
            <>
              <Sparkles size={18} className="animate-spin" /> Analyzing Market Data...
            </>
          ) : (
            <>
              <TrendingUp size={18} /> Analyze Salary Range
            </>
          )}
        </button>
      </motion.div>

      {showResults && (
        <>
          {/* Market Data Chart */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6"
          >
            <h3 className="font-semibold text-slate-900 mb-1">Market Salary Range</h3>
            <p className="text-sm text-slate-500 mb-6">
              Based on {role || "Product Designer"} in {location || "San Francisco"}
            </p>

            <div className="grid grid-cols-3 gap-4 mb-6">
              <div className="bg-blue-50 rounded-xl p-4 text-center border border-blue-100">
                <p className="text-xs text-blue-600 font-medium">25th Percentile</p>
                <p className="text-2xl font-bold text-blue-700 mt-1">$115K</p>
              </div>
              <div className="bg-indigo-50 rounded-xl p-4 text-center border border-indigo-100">
                <p className="text-xs text-indigo-600 font-medium">Median</p>
                <p className="text-2xl font-bold text-indigo-700 mt-1">$140K</p>
              </div>
              <div className="bg-purple-50 rounded-xl p-4 text-center border border-purple-100">
                <p className="text-xs text-purple-600 font-medium">75th Percentile</p>
                <p className="text-2xl font-bold text-purple-700 mt-1">$165K</p>
              </div>
            </div>

            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={salaryData}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} />
                  <XAxis dataKey="percentile" tick={{ fontSize: 12 }} />
                  <YAxis
                    tick={{ fontSize: 12 }}
                    tickFormatter={(v) => `$${v / 1000}K`}
                  />
                  <Tooltip formatter={(v: number) => [`$${v.toLocaleString()}`, "Salary"]} />
                  <Bar dataKey="salary" fill="#4f46e5" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </motion.div>

          {/* Negotiation Script */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6"
          >
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="font-semibold text-slate-900">Negotiation Script</h3>
                <p className="text-sm text-slate-500">Personalized based on your profile and market data</p>
              </div>
              <button
                onClick={handleCopy}
                className="flex items-center gap-2 px-3 py-1.5 bg-indigo-50 text-indigo-700 rounded-lg text-sm font-medium hover:bg-indigo-100 transition-colors"
              >
                {copied ? <CheckCircle2 size={14} /> : <Copy size={14} />}
                {copied ? "Copied!" : "Copy Script"}
              </button>
            </div>
            <div className="bg-slate-50 rounded-xl p-6 border border-slate-100">
              <pre className="text-sm text-slate-700 whitespace-pre-wrap font-sans leading-relaxed">
                {negotiationScript}
              </pre>
            </div>
          </motion.div>
        </>
      )}
    </div>
  );
}
