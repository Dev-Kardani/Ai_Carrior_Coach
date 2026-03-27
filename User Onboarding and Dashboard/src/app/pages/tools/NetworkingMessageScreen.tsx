import { useState } from "react";
import { useNavigate } from "react-router";
import { motion } from "motion/react";
import { ArrowLeft, Users, Copy, Sparkles, CheckCircle2 } from "lucide-react";
import { toast } from "sonner";

const intents = [
  { label: "Informational Interview", value: "info" },
  { label: "Referral Request", value: "referral" },
  { label: "Coffee Chat", value: "coffee" },
  { label: "Mentorship", value: "mentorship" },
];

const generatedMessages: Record<string, string> = {
  info: `Hi [Name],

I came across your profile while researching professionals in the Product Design space at [Company]. I'm really impressed by your work on [specific project/achievement].

I'm currently exploring opportunities in this field and would love to learn more about your experience. Would you be open to a brief 15-minute chat sometime this week or next?

I'd really appreciate any insights you could share.

Best regards,
Alex Morgan`,
  referral: `Hi [Name],

I hope this message finds you well! I noticed that [Company] is hiring for a Senior Designer role, and I'm very excited about the opportunity.

Given your experience there, I was wondering if you'd be comfortable sharing my profile with the hiring team, or if you could point me to the right person to connect with.

I'd be happy to share my portfolio and resume for your review first.

Thank you so much!
Alex Morgan`,
  coffee: `Hi [Name],

I've been following your work in the design community and your recent post about [topic] really resonated with me.

I'd love to grab a virtual coffee and chat about your career journey. I'm particularly curious about how you transitioned into your current role.

No pressure at all - just a casual conversation. Let me know if you have 20 minutes free sometime!

Cheers,
Alex Morgan`,
  mentorship: `Hi [Name],

I'm reaching out because I deeply admire your career trajectory in [field]. Your talk at [event] inspired me to pursue a similar path.

I'm currently at a crossroads in my career and would greatly value your perspective. Would you be open to an occasional mentorship conversation?

I'm happy to work around your schedule and keep our chats focused and efficient.

With gratitude,
Alex Morgan`,
};

export default function NetworkingMessageScreen() {
  const navigate = useNavigate();
  const [selectedIntent, setSelectedIntent] = useState("");
  const [isGenerating, setIsGenerating] = useState(false);
  const [message, setMessage] = useState("");
  const [copied, setCopied] = useState(false);

  const handleGenerate = () => {
    if (!selectedIntent) {
      toast.error("Please select an intent first");
      return;
    }
    setIsGenerating(true);
    setTimeout(() => {
      setMessage(generatedMessages[selectedIntent] || generatedMessages.info);
      setIsGenerating(false);
    }, 1500);
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(message);
    setCopied(true);
    toast.success("Copied to clipboard!");
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <button
        onClick={() => navigate("/app/tools")}
        className="flex items-center gap-2 text-slate-500 hover:text-slate-700 text-sm font-medium transition-colors"
      >
        <ArrowLeft size={16} /> Back to Tools
      </button>

      <div className="flex items-center gap-3">
        <div className="w-10 h-10 bg-green-100 rounded-xl flex items-center justify-center">
          <Users size={20} className="text-green-600" />
        </div>
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Networking Message Generator</h1>
          <p className="text-sm text-slate-500">Create professional LinkedIn outreach messages.</p>
        </div>
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 space-y-6"
      >
        <div>
          <label className="block text-sm font-medium text-slate-700 mb-3">What's your intent?</label>
          <div className="grid grid-cols-2 gap-3">
            {intents.map((intent) => (
              <button
                key={intent.value}
                onClick={() => setSelectedIntent(intent.value)}
                className={`p-4 rounded-xl border text-left text-sm transition-all
                  ${selectedIntent === intent.value
                    ? "bg-indigo-50 border-indigo-500 text-indigo-700 ring-1 ring-indigo-500"
                    : "bg-white border-slate-200 text-slate-700 hover:bg-slate-50"
                  }`}
              >
                <span className="font-medium">{intent.label}</span>
              </button>
            ))}
          </div>
        </div>

        <button
          onClick={handleGenerate}
          disabled={isGenerating || !selectedIntent}
          className="w-full py-3 bg-indigo-600 text-white rounded-xl font-medium hover:bg-indigo-700 disabled:opacity-50 transition-colors flex items-center justify-center gap-2"
        >
          {isGenerating ? (
            <>
              <Sparkles size={18} className="animate-spin" /> Generating...
            </>
          ) : (
            <>
              <Sparkles size={18} /> Generate Message
            </>
          )}
        </button>
      </motion.div>

      {message && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6"
        >
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-slate-900">LinkedIn Message Draft</h3>
            <button
              onClick={handleCopy}
              className="flex items-center gap-2 px-3 py-1.5 bg-indigo-50 text-indigo-700 rounded-lg text-sm font-medium hover:bg-indigo-100 transition-colors"
            >
              {copied ? <CheckCircle2 size={14} /> : <Copy size={14} />}
              {copied ? "Copied!" : "Copy"}
            </button>
          </div>
          <div className="bg-slate-50 rounded-xl p-6 border border-slate-100">
            <pre className="text-sm text-slate-700 whitespace-pre-wrap font-sans leading-relaxed">{message}</pre>
          </div>
        </motion.div>
      )}
    </div>
  );
}
