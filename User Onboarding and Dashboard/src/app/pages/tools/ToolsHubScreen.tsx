import { Link } from "react-router";
import { motion } from "motion/react";
import {
  FileText,
  Users,
  Palette,
  DollarSign,
  ChevronRight,
  TrendingUp,
  Sparkles,
} from "lucide-react";

const tools = [
  {
    id: "cover-letter",
    title: "Cover Letter Generator",
    description: "Create tailored cover letters from job descriptions with AI.",
    icon: FileText,
    color: "bg-blue-100 text-blue-600",
    path: "/app/tools/cover-letter",
  },
  {
    id: "networking",
    title: "Networking Message",
    description: "Draft professional LinkedIn messages for cold outreach.",
    icon: Users,
    color: "bg-green-100 text-green-600",
    path: "/app/tools/networking",
  },
  {
    id: "portfolio",
    title: "Portfolio Architect",
    description: "Organize and showcase your best projects strategically.",
    icon: Palette,
    color: "bg-purple-100 text-purple-600",
    path: "/app/tools/portfolio",
  },
  {
    id: "salary",
    title: "Salary Negotiator",
    description: "Get market data and negotiation scripts for your role.",
    icon: DollarSign,
    color: "bg-orange-100 text-orange-600",
    path: "/app/tools/salary",
  },
  {
    id: "insights",
    title: "Market Insights",
    description: "Explore real-time trends, demand, and hiring activity.",
    icon: TrendingUp,
    color: "bg-indigo-100 text-indigo-600",
    path: "/app",
  },
];

export default function ToolsHubScreen() {
  return (
    <div className="max-w-4xl mx-auto space-y-8">
      <div className="text-center">
        <h1 className="text-3xl font-bold text-slate-900">Career Tools</h1>
        <p className="mt-2 text-slate-500">AI-powered generators and utilities to accelerate your job search.</p>
      </div>

      {/* Hero Card */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-gradient-to-r from-indigo-600 to-purple-600 rounded-2xl p-8 text-white relative overflow-hidden"
      >
        <div className="absolute top-0 right-0 w-64 h-64 bg-white/10 rounded-full -translate-y-32 translate-x-32" />
        <div className="relative z-10">
          <div className="flex items-center gap-3 mb-4">
            <Sparkles size={24} />
            <h2 className="text-xl font-bold">AI-Powered Career Toolkit</h2>
          </div>
          <p className="text-indigo-100 max-w-lg">
            Each tool uses AI to generate professional content tailored to your profile and target roles.
            Save hours of manual work and stand out from the competition.
          </p>
        </div>
      </motion.div>

      {/* Tool Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {tools.map((tool, idx) => (
          <Link to={tool.path} key={tool.id}>
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: idx * 0.08 }}
              className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm hover:shadow-md hover:border-indigo-100 transition-all group h-full"
            >
              <div className="flex items-start justify-between">
                <div className={`w-12 h-12 rounded-xl ${tool.color} flex items-center justify-center mb-4 group-hover:scale-110 transition-transform`}>
                  <tool.icon size={24} />
                </div>
                <div className="p-2 rounded-full bg-slate-50 text-slate-400 group-hover:bg-indigo-50 group-hover:text-indigo-600 transition-colors">
                  <ChevronRight size={16} />
                </div>
              </div>
              <h3 className="font-semibold text-slate-900 mb-2">{tool.title}</h3>
              <p className="text-sm text-slate-500">{tool.description}</p>
            </motion.div>
          </Link>
        ))}
      </div>
    </div>
  );
}
