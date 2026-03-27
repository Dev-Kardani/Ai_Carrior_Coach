import { Link, useParams, useNavigate } from "react-router";
import { motion } from "motion/react";
import {
  ArrowLeft,
  Building2,
  MapPin,
  DollarSign,
  Calendar,
  ExternalLink,
  Edit,
  Trash2,
  MessageSquare,
  Sparkles,
} from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

const mockJob = {
  id: "2",
  company: "Stripe",
  title: "Senior UX Designer",
  location: "San Francisco, CA",
  salary: "$140,000 - $170,000",
  status: "Applied",
  dateApplied: "February 18, 2026",
  url: "https://stripe.com/careers",
  notes: "Referred by John from the design team. Focus on payment flow redesign. Second round expected next week.",
  timeline: [
    { date: "Feb 18", event: "Application submitted", type: "action" },
    { date: "Feb 20", event: "Recruiter viewed profile", type: "info" },
    { date: "Feb 22", event: "Phone screen scheduled", type: "action" },
  ],
};

export default function JobDetailViewScreen() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [showAIFollowUp, setShowAIFollowUp] = useState(false);
  const [aiMessage, setAiMessage] = useState("");

  const generateFollowUp = () => {
    setShowAIFollowUp(true);
    setTimeout(() => {
      setAiMessage(
        `Hi [Hiring Manager],\n\nI hope this message finds you well. I wanted to follow up on my application for the ${mockJob.title} position at ${mockJob.company}. I'm very excited about the opportunity to contribute to your team.\n\nI'd love to discuss how my experience in UX design and my passion for creating intuitive payment experiences align with the role. Would you have time for a brief conversation this week?\n\nBest regards,\nAlex Morgan`
      );
    }, 1500);
  };

  const handleDelete = () => {
    toast.success("Job removed from tracker");
    navigate("/app/jobs");
  };

  const statusColor: Record<string, string> = {
    Wishlist: "bg-slate-100 text-slate-700",
    Applied: "bg-blue-100 text-blue-700",
    Interview: "bg-yellow-100 text-yellow-700",
    Offer: "bg-green-100 text-green-700",
    Rejected: "bg-red-100 text-red-700",
  };

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <button
        onClick={() => navigate("/app/jobs")}
        className="flex items-center gap-2 text-slate-500 hover:text-slate-700 text-sm font-medium transition-colors"
      >
        <ArrowLeft size={16} /> Back to Job Board
      </button>

      {/* Job Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6"
      >
        <div className="flex flex-col sm:flex-row justify-between gap-4">
          <div className="flex items-start gap-4">
            <div className="w-14 h-14 bg-indigo-100 rounded-xl flex items-center justify-center flex-shrink-0">
              <Building2 size={28} className="text-indigo-600" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-slate-900">{mockJob.title}</h1>
              <p className="text-slate-600">{mockJob.company}</p>
              <div className="flex flex-wrap items-center gap-3 mt-2 text-sm text-slate-500">
                <span className="flex items-center gap-1"><MapPin size={14} /> {mockJob.location}</span>
                <span className="flex items-center gap-1"><DollarSign size={14} /> {mockJob.salary}</span>
                <span className="flex items-center gap-1"><Calendar size={14} /> {mockJob.dateApplied}</span>
              </div>
            </div>
          </div>
          <div className="flex items-start gap-2">
            <span className={`px-3 py-1 rounded-full text-sm font-medium ${statusColor[mockJob.status]}`}>
              {mockJob.status}
            </span>
          </div>
        </div>

        <div className="flex gap-3 mt-6 pt-4 border-t border-slate-100">
          <Link
            to={`/app/jobs/${id}/edit`}
            className="px-4 py-2 text-sm font-medium bg-indigo-50 text-indigo-700 rounded-lg hover:bg-indigo-100 transition-colors flex items-center gap-2"
          >
            <Edit size={14} /> Edit
          </Link>
          <a
            href={mockJob.url}
            target="_blank"
            rel="noreferrer"
            className="px-4 py-2 text-sm font-medium bg-slate-50 text-slate-700 rounded-lg hover:bg-slate-100 transition-colors flex items-center gap-2"
          >
            <ExternalLink size={14} /> View Posting
          </a>
          <button
            onClick={handleDelete}
            className="px-4 py-2 text-sm font-medium bg-red-50 text-red-600 rounded-lg hover:bg-red-100 transition-colors flex items-center gap-2"
          >
            <Trash2 size={14} /> Remove
          </button>
        </div>
      </motion.div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Notes */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="bg-white rounded-xl shadow-sm border border-slate-200 p-5"
        >
          <h3 className="font-semibold text-slate-900 mb-3 flex items-center gap-2">
            <MessageSquare size={16} className="text-indigo-600" /> Notes
          </h3>
          <p className="text-sm text-slate-600 whitespace-pre-line">{mockJob.notes}</p>
        </motion.div>

        {/* Timeline */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.15 }}
          className="bg-white rounded-xl shadow-sm border border-slate-200 p-5"
        >
          <h3 className="font-semibold text-slate-900 mb-3 flex items-center gap-2">
            <Calendar size={16} className="text-indigo-600" /> Activity Timeline
          </h3>
          <div className="space-y-4">
            {mockJob.timeline.map((item, idx) => (
              <div key={idx} className="flex gap-3">
                <div className="flex flex-col items-center">
                  <div className={`w-2.5 h-2.5 rounded-full ${item.type === "action" ? "bg-indigo-500" : "bg-slate-300"}`} />
                  {idx < mockJob.timeline.length - 1 && <div className="w-0.5 flex-1 bg-slate-200 mt-1" />}
                </div>
                <div className="pb-4">
                  <p className="text-sm font-medium text-slate-900">{item.event}</p>
                  <p className="text-xs text-slate-400">{item.date}</p>
                </div>
              </div>
            ))}
          </div>
        </motion.div>
      </div>

      {/* AI Follow-up Generator */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="bg-gradient-to-r from-indigo-50 to-purple-50 rounded-2xl border border-indigo-100 p-6"
      >
        <div className="flex items-center gap-3 mb-4">
          <div className="w-10 h-10 bg-indigo-100 rounded-xl flex items-center justify-center">
            <Sparkles size={20} className="text-indigo-600" />
          </div>
          <div>
            <h3 className="font-semibold text-slate-900">AI Follow-Up Generator</h3>
            <p className="text-sm text-slate-500">Generate a professional follow-up message</p>
          </div>
        </div>

        {!showAIFollowUp ? (
          <button
            onClick={generateFollowUp}
            className="w-full py-3 bg-indigo-600 text-white rounded-xl font-medium hover:bg-indigo-700 transition-colors"
          >
            Generate Follow-Up Email
          </button>
        ) : aiMessage ? (
          <div className="bg-white rounded-xl p-4 border border-indigo-100">
            <pre className="text-sm text-slate-700 whitespace-pre-wrap font-sans">{aiMessage}</pre>
            <button
              onClick={() => {
                navigator.clipboard.writeText(aiMessage);
                toast.success("Copied to clipboard!");
              }}
              className="mt-3 px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700 transition-colors"
            >
              Copy to Clipboard
            </button>
          </div>
        ) : (
          <div className="flex items-center justify-center py-6">
            <div className="flex gap-1">
              <span className="w-2 h-2 bg-indigo-400 rounded-full animate-bounce" />
              <span className="w-2 h-2 bg-indigo-400 rounded-full animate-bounce" style={{ animationDelay: "150ms" }} />
              <span className="w-2 h-2 bg-indigo-400 rounded-full animate-bounce" style={{ animationDelay: "300ms" }} />
            </div>
          </div>
        )}
      </motion.div>
    </div>
  );
}
