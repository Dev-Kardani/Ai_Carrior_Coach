import { Link } from "react-router";
import { motion } from "motion/react";
import { 
  CheckCircle2, 
  XCircle, 
  AlertTriangle, 
  ChevronDown, 
  ChevronUp, 
  Target,
  ArrowRight
} from "lucide-react";
import { useState } from "react";
import { PieChart, Pie, Cell, ResponsiveContainer, Label } from "recharts";

export default function ResumeAnalysisScreen() {
  const [expandedSection, setExpandedSection] = useState<string | null>("strengths");

  const score = 78;
  const scoreData = [
    { name: "Score", value: score },
    { name: "Remaining", value: 100 - score },
  ];
  const scoreColors = ["#4f46e5", "#e2e8f0"];

  const sections = [
    {
      id: "strengths",
      title: "Strengths",
      icon: CheckCircle2,
      color: "text-green-600",
      bg: "bg-green-50",
      items: [
        "Strong use of action verbs",
        "Clear contact information",
        "Good educational background structure",
        "Consistent formatting throughout"
      ]
    },
    {
      id: "weaknesses",
      title: "Weaknesses",
      icon: XCircle,
      color: "text-red-600",
      bg: "bg-red-50",
      items: [
        "Missing quantifiable results in 2 roles",
        "Summary section is too generic",
        "Skills section needs better categorization"
      ]
    },
    {
      id: "ats",
      title: "ATS Compatibility",
      icon: AlertTriangle,
      color: "text-orange-600",
      bg: "bg-orange-50",
      items: [
        "Complex tables found - might confuse parsers",
        "Standard font used (Good)",
        "Keyword density is slightly low for 'Product Design'"
      ]
    },
    {
      id: "suggestions",
      title: "AI Suggestions",
      icon: Target,
      color: "text-blue-600",
      bg: "bg-blue-50",
      items: [
        "Add a 'Projects' section to showcase portfolio",
        "Include more industry-specific keywords like 'Figma', 'User Research'",
        "Rewrite the first bullet point of your latest role to focus on impact"
      ]
    }
  ];

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-slate-900">Analysis Results</h1>
        <div className="flex gap-3">
          <Link to="/app/resume/skills" className="px-4 py-2 text-indigo-600 bg-indigo-50 hover:bg-indigo-100 rounded-lg text-sm font-medium transition-colors">
            View Skill Gap
          </Link>
          <button className="px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700 transition-colors">
            Download Report
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Score Card */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-white rounded-xl shadow-sm border border-slate-200 p-6 flex flex-col items-center justify-center text-center"
        >
          <h2 className="text-lg font-semibold text-slate-900 mb-4">Overall Score</h2>
          <div className="w-48 h-48 relative">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={scoreData}
                  cx="50%"
                  cy="50%"
                  innerRadius={70}
                  outerRadius={90}
                  startAngle={90}
                  endAngle={-270}
                  dataKey="value"
                  stroke="none"
                >
                  {scoreData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={scoreColors[index]} />
                  ))}
                  <Label
                    value={`${score}/100`}
                    position="center"
                    className="text-3xl font-bold fill-slate-900"
                  />
                </Pie>
              </PieChart>
            </ResponsiveContainer>
          </div>
          <p className="mt-4 text-slate-500 text-sm">
            Top 20% of candidates applying for similar roles.
          </p>
        </motion.div>

        {/* Detailed Breakdown */}
        <div className="md:col-span-2 space-y-4">
          {sections.map((section, idx) => (
            <motion.div
              key={section.id}
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: idx * 0.1 }}
              className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden"
            >
              <button
                onClick={() => setExpandedSection(expandedSection === section.id ? null : section.id)}
                className="w-full flex items-center justify-between p-4 hover:bg-slate-50 transition-colors"
              >
                <div className="flex items-center gap-3">
                  <div className={`p-2 rounded-lg ${section.bg} ${section.color}`}>
                    <section.icon size={20} />
                  </div>
                  <span className="font-semibold text-slate-900">{section.title}</span>
                </div>
                {expandedSection === section.id ? <ChevronUp size={20} className="text-slate-400" /> : <ChevronDown size={20} className="text-slate-400" />}
              </button>
              
              <AnimateHeight isExpanded={expandedSection === section.id}>
                <div className="px-4 pb-4 pt-0 pl-16">
                  <ul className="space-y-2">
                    {section.items.map((item, i) => (
                      <li key={i} className="text-slate-600 text-sm list-disc">
                        {item}
                      </li>
                    ))}
                  </ul>
                </div>
              </AnimateHeight>
            </motion.div>
          ))}
        </div>
      </div>
      
      <div className="flex justify-end pt-6">
        <Link 
            to="/app/resume/skills"
            className="group flex items-center gap-2 text-indigo-600 font-medium hover:text-indigo-800 transition-colors"
        >
            Next: Analyze Skill Gaps <ArrowRight size={18} className="group-hover:translate-x-1 transition-transform" />
        </Link>
      </div>
    </div>
  );
}

// Simple Helper for height animation
function AnimateHeight({ isExpanded, children }: { isExpanded: boolean, children: React.ReactNode }) {
  return (
    <motion.div
      initial={false}
      animate={{ height: isExpanded ? "auto" : 0, opacity: isExpanded ? 1 : 0 }}
      transition={{ duration: 0.3, ease: "easeInOut" }}
      className="overflow-hidden"
    >
      {children}
    </motion.div>
  );
}
