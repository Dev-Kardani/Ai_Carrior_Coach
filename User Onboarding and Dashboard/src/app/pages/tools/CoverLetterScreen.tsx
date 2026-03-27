import { useState } from "react";
import { useNavigate } from "react-router";
import { motion } from "motion/react";
import { ArrowLeft, FileText, Copy, Sparkles, CheckCircle2 } from "lucide-react";
import { toast } from "sonner";

const generatedLetter = `Dear Hiring Manager,

I am writing to express my strong interest in the Senior Product Designer position at Stripe. With over 5 years of experience designing intuitive digital products, I am confident in my ability to contribute to your team's mission of building the economic infrastructure for the internet.

In my current role, I have led the redesign of key user flows that resulted in a 35% increase in user engagement and a 20% reduction in support tickets. I am particularly drawn to Stripe's commitment to creating seamless payment experiences, and I believe my expertise in user research, prototyping, and design systems would be a valuable addition.

I am excited about the opportunity to bring my skills in cross-functional collaboration and data-driven design to Stripe. I look forward to discussing how my background aligns with your team's goals.

Best regards,
Alex Morgan`;

export default function CoverLetterScreen() {
  const navigate = useNavigate();
  const [jobDescription, setJobDescription] = useState("");
  const [isGenerating, setIsGenerating] = useState(false);
  const [letter, setLetter] = useState("");
  const [copied, setCopied] = useState(false);

  const handleGenerate = () => {
    if (!jobDescription.trim()) {
      toast.error("Please paste a job description first");
      return;
    }
    setIsGenerating(true);
    setTimeout(() => {
      setLetter(generatedLetter);
      setIsGenerating(false);
    }, 2000);
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(letter);
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
        <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
          <FileText size={20} className="text-blue-600" />
        </div>
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Cover Letter Generator</h1>
          <p className="text-sm text-slate-500">Paste a job description to generate a tailored cover letter.</p>
        </div>
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 space-y-6"
      >
        <div>
          <label className="block text-sm font-medium text-slate-700 mb-2">Job Description</label>
          <textarea
            value={jobDescription}
            onChange={(e) => setJobDescription(e.target.value)}
            rows={6}
            placeholder="Paste the full job description here..."
            className="w-full px-4 py-3 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm resize-none"
          />
        </div>

        <button
          onClick={handleGenerate}
          disabled={isGenerating}
          className="w-full py-3 bg-indigo-600 text-white rounded-xl font-medium hover:bg-indigo-700 disabled:opacity-50 transition-colors flex items-center justify-center gap-2"
        >
          {isGenerating ? (
            <>
              <Sparkles size={18} className="animate-spin" /> Generating...
            </>
          ) : (
            <>
              <Sparkles size={18} /> Generate Cover Letter
            </>
          )}
        </button>
      </motion.div>

      {letter && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6"
        >
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-slate-900">Generated Cover Letter</h3>
            <button
              onClick={handleCopy}
              className="flex items-center gap-2 px-3 py-1.5 bg-indigo-50 text-indigo-700 rounded-lg text-sm font-medium hover:bg-indigo-100 transition-colors"
            >
              {copied ? <CheckCircle2 size={14} /> : <Copy size={14} />}
              {copied ? "Copied!" : "Copy"}
            </button>
          </div>
          <div className="bg-slate-50 rounded-xl p-6 border border-slate-100">
            <pre className="text-sm text-slate-700 whitespace-pre-wrap font-sans leading-relaxed">{letter}</pre>
          </div>
        </motion.div>
      )}
    </div>
  );
}
