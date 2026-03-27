import { Link } from "react-router";
import { motion } from "motion/react";
import { 
  FileText, 
  Briefcase, 
  MessageSquare, 
  Wrench, 
  Target, 
  Upload,
  Video,
  ChevronRight,
  TrendingUp,
  AlertCircle
} from "lucide-react";
import { PieChart, Pie, Cell, ResponsiveContainer, Label } from "recharts";

export default function DashboardScreen() {
  const resumeScore = 78;
  const scoreData = [
    { name: "Score", value: resumeScore },
    { name: "Remaining", value: 100 - resumeScore },
  ];
  const scoreColors = ["#4f46e5", "#e2e8f0"];

  const modules = [
    { 
      title: "Resume Analysis", 
      icon: FileText, 
      color: "bg-blue-100 text-blue-600",
      path: "/app/resume/upload",
      desc: "Get AI feedback on your CV"
    },
    { 
      title: "Skill Gap", 
      icon: Target, 
      color: "bg-purple-100 text-purple-600",
      path: "/app/resume/skills",
      desc: "Identify missing skills"
    },
    { 
      title: "Mock Interview", 
      icon: Video, 
      color: "bg-green-100 text-green-600",
      path: "/app/interview/setup",
      desc: "Practice with AI avatar"
    },
    { 
      title: "Job Tracker", 
      icon: Briefcase, 
      color: "bg-orange-100 text-orange-600",
      path: "/app/jobs",
      desc: "Manage your applications"
    },
    { 
      title: "AI Career Chat", 
      icon: MessageSquare, 
      color: "bg-indigo-100 text-indigo-600",
      path: "/app/chat",
      desc: "Get instant career advice"
    },
    { 
      title: "Career Tools", 
      icon: Wrench, 
      color: "bg-rose-100 text-rose-600",
      path: "/app/tools",
      desc: "Generators & utilities"
    },
  ];

  return (
    <div className="space-y-8 pb-20">
      {/* Welcome Section */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Hello, Alex! 👋</h1>
          <p className="text-slate-500">Ready to boost your career today?</p>
        </div>
      </div>

      {/* Hero: Resume Score */}
      <motion.div 
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100 flex flex-col md:flex-row items-center gap-8"
      >
        <div className="relative w-40 h-40 flex-shrink-0">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={scoreData}
                cx="50%"
                cy="50%"
                innerRadius={60}
                outerRadius={80}
                startAngle={90}
                endAngle={-270}
                dataKey="value"
                stroke="none"
              >
                {scoreData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={scoreColors[index]} />
                ))}
                <Label
                  value={resumeScore}
                  position="center"
                  className="text-3xl font-bold fill-indigo-600"
                />
              </Pie>
            </PieChart>
          </ResponsiveContainer>
          <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
            <span className="mt-8 text-xs font-medium text-slate-400">ATS Score</span>
          </div>
        </div>

        <div className="flex-1 space-y-4">
          <div>
            <h3 className="text-lg font-semibold text-slate-900">Your Resume is Strong! 🚀</h3>
            <p className="text-slate-500 text-sm">You're in the top 20% of candidates. Improve your impact metrics to reach 85+.</p>
          </div>
          
          <div className="flex gap-3">
            <Link 
              to="/app/resume/analysis"
              className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700 transition-colors"
            >
              View Analysis
            </Link>
            <Link 
              to="/app/resume/upload"
              className="inline-flex items-center px-4 py-2 bg-indigo-50 text-indigo-700 rounded-lg text-sm font-medium hover:bg-indigo-100 transition-colors"
            >
              Update Resume
            </Link>
          </div>
        </div>
      </motion.div>

      {/* Quick Stats / Alerts */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="bg-orange-50 rounded-xl p-4 border border-orange-100 flex items-start gap-3">
          <div className="p-2 bg-orange-100 rounded-lg text-orange-600">
            <AlertCircle size={20} />
          </div>
          <div>
            <h4 className="font-semibold text-orange-900">Action Required</h4>
            <p className="text-sm text-orange-700">2 job applications need follow-up today.</p>
          </div>
        </div>
        <div className="bg-green-50 rounded-xl p-4 border border-green-100 flex items-start gap-3">
          <div className="p-2 bg-green-100 rounded-lg text-green-600">
            <TrendingUp size={20} />
          </div>
          <div>
            <h4 className="font-semibold text-green-900">Market Insight</h4>
            <p className="text-sm text-green-700">Product Designer roles up 15% this week.</p>
          </div>
        </div>
      </div>

      {/* Modules Grid */}
      <div>
        <h2 className="text-lg font-bold text-slate-900 mb-4">Quick Access</h2>
        <div className="grid grid-cols-2 lg:grid-cols-3 gap-4">
          {modules.map((module, index) => (
            <Link to={module.path} key={module.title}>
              <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: index * 0.05 }}
                className="bg-white p-4 rounded-xl shadow-sm border border-slate-100 hover:shadow-md hover:border-indigo-100 transition-all group h-full"
              >
                <div className={`w-10 h-10 rounded-lg ${module.color} flex items-center justify-center mb-3 group-hover:scale-110 transition-transform`}>
                  <module.icon size={20} />
                </div>
                <h3 className="font-semibold text-slate-900 mb-1">{module.title}</h3>
                <p className="text-xs text-slate-500 mb-2">{module.desc}</p>
                <div className="flex justify-end">
                  <div className="p-1 rounded-full bg-slate-50 text-slate-400 group-hover:bg-indigo-50 group-hover:text-indigo-600 transition-colors">
                    <ChevronRight size={16} />
                  </div>
                </div>
              </motion.div>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
