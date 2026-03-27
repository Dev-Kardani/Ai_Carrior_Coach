import { Link } from "react-router";
import { motion } from "motion/react";
import {
  Award,
  MessageSquare,
  ThumbsUp,
  ThumbsDown,
  Lightbulb,
  BarChart3,
  ArrowRight,
  RotateCcw,
} from "lucide-react";
import { PieChart, Pie, Cell, ResponsiveContainer, Label } from "recharts";

const overallScore = 72;
const scoreData = [
  { name: "Score", value: overallScore },
  { name: "Remaining", value: 100 - overallScore },
];
const scoreColors = ["#4f46e5", "#e2e8f0"];

const categoryScores = [
  { label: "Communication", score: 85, color: "bg-green-500" },
  { label: "Technical Depth", score: 60, color: "bg-yellow-500" },
  { label: "Problem Solving", score: 75, color: "bg-blue-500" },
  { label: "Confidence", score: 70, color: "bg-purple-500" },
  { label: "Structure", score: 68, color: "bg-orange-500" },
];

const questionFeedback = [
  {
    question: "Tell me about a challenging project you worked on.",
    verdict: "good",
    feedback: "You provided a clear STAR framework response with good detail on the situation and your actions.",
    tip: "Add specific metrics or outcomes to strengthen your impact statement.",
  },
  {
    question: "How do you approach breaking down a complex problem?",
    verdict: "average",
    feedback: "The structure was logical but lacked a concrete example to back up your methodology.",
    tip: "Use a real-world example next time to make it more compelling.",
  },
  {
    question: "Describe collaborating with a difficult team member.",
    verdict: "good",
    feedback: "Great emotional intelligence shown. You demonstrated empathy and resolution skills.",
    tip: "Mention what you learned from the experience for extra depth.",
  },
  {
    question: "What's your process for learning new technologies?",
    verdict: "needs_work",
    feedback: "Response was too vague and didn't show a structured learning approach.",
    tip: "Mention specific resources, projects, or courses you've used recently.",
  },
  {
    question: "Where do you see yourself in 5 years?",
    verdict: "good",
    feedback: "Well-aligned with the role's growth path. Showed ambition without overreaching.",
    tip: "Tie it more specifically to the company's mission for bonus points.",
  },
];

export default function MockInterviewFeedbackScreen() {
  return (
    <div className="space-y-8 pb-10">
      <div className="text-center">
        <h1 className="text-3xl font-bold text-slate-900">Interview Feedback</h1>
        <p className="mt-2 text-slate-500">Here's how you performed across all questions.</p>
      </div>

      {/* Score Hero */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 flex flex-col items-center"
        >
          <div className="w-40 h-40 relative">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={scoreData}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={78}
                  startAngle={90}
                  endAngle={-270}
                  dataKey="value"
                  stroke="none"
                >
                  {scoreData.map((_, i) => (
                    <Cell key={i} fill={scoreColors[i]} />
                  ))}
                  <Label value={`${overallScore}%`} position="center" className="text-2xl font-bold fill-slate-900" />
                </Pie>
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="mt-4 text-center">
            <p className="font-semibold text-slate-900 flex items-center gap-2 justify-center">
              <Award size={18} className="text-indigo-600" /> Overall Score
            </p>
            <p className="text-sm text-slate-500 mt-1">Above average for this role</p>
          </div>
        </motion.div>

        {/* Category Breakdown */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="md:col-span-2 bg-white rounded-2xl shadow-sm border border-slate-200 p-6"
        >
          <h3 className="font-semibold text-slate-900 mb-4 flex items-center gap-2">
            <BarChart3 size={18} className="text-indigo-600" /> Skill Breakdown
          </h3>
          <div className="space-y-4">
            {categoryScores.map((cat) => (
              <div key={cat.label}>
                <div className="flex justify-between mb-1">
                  <span className="text-sm font-medium text-slate-700">{cat.label}</span>
                  <span className="text-sm font-semibold text-slate-900">{cat.score}%</span>
                </div>
                <div className="w-full h-2.5 bg-slate-100 rounded-full overflow-hidden">
                  <motion.div
                    className={`h-full rounded-full ${cat.color}`}
                    initial={{ width: 0 }}
                    animate={{ width: `${cat.score}%` }}
                    transition={{ duration: 0.8, delay: 0.2 }}
                  />
                </div>
              </div>
            ))}
          </div>
        </motion.div>
      </div>

      {/* Per-Question Feedback */}
      <div>
        <h2 className="text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
          <MessageSquare size={18} className="text-indigo-600" /> Question-by-Question Review
        </h2>
        <div className="space-y-4">
          {questionFeedback.map((q, idx) => (
            <motion.div
              key={idx}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: idx * 0.05 }}
              className="bg-white rounded-xl border border-slate-200 shadow-sm p-5"
            >
              <div className="flex items-start gap-3 mb-3">
                <div className={`p-1.5 rounded-lg flex-shrink-0 ${
                  q.verdict === "good" ? "bg-green-100 text-green-600" :
                  q.verdict === "average" ? "bg-yellow-100 text-yellow-600" :
                  "bg-red-100 text-red-600"
                }`}>
                  {q.verdict === "good" ? <ThumbsUp size={16} /> :
                   q.verdict === "average" ? <BarChart3 size={16} /> :
                   <ThumbsDown size={16} />}
                </div>
                <div>
                  <h4 className="font-semibold text-slate-900 text-sm">Q{idx + 1}: {q.question}</h4>
                  <p className="text-slate-600 text-sm mt-1">{q.feedback}</p>
                </div>
              </div>
              <div className="ml-9 bg-indigo-50 rounded-lg p-3 flex items-start gap-2">
                <Lightbulb size={14} className="text-indigo-600 mt-0.5 flex-shrink-0" />
                <p className="text-sm text-indigo-800">{q.tip}</p>
              </div>
            </motion.div>
          ))}
        </div>
      </div>

      {/* Actions */}
      <div className="flex flex-col sm:flex-row gap-4 pt-4">
        <Link
          to="/app/interview/setup"
          className="flex-1 flex items-center justify-center gap-2 py-3 border border-indigo-200 text-indigo-700 bg-indigo-50 hover:bg-indigo-100 rounded-xl font-medium transition-colors"
        >
          <RotateCcw size={18} /> Try Again
        </Link>
        <Link
          to="/app"
          className="flex-1 flex items-center justify-center gap-2 py-3 bg-indigo-600 text-white rounded-xl font-medium hover:bg-indigo-700 transition-colors"
        >
          Back to Dashboard <ArrowRight size={18} />
        </Link>
      </div>
    </div>
  );
}
