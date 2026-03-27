import { useState } from "react";
import { Link } from "react-router";
import { motion } from "motion/react";
import { 
  Target, 
  Check, 
  Clock, 
  BookOpen, 
  ArrowRight, 
  ExternalLink
} from "lucide-react";
import { ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid } from "recharts";

export default function SkillGapScreen() {
  const [targetRole, setTargetRole] = useState("Product Designer");
  const [activeTab, setActiveTab] = useState<'missing' | 'roadmap'>('missing');

  const skillsData = [
    { name: "Figma", current: 90, target: 85, fullMark: 100 },
    { name: "React", current: 40, target: 70, fullMark: 100 },
    { name: "UX Research", current: 65, target: 80, fullMark: 100 },
    { name: "Prototyping", current: 85, target: 80, fullMark: 100 },
    { name: "HTML/CSS", current: 60, target: 60, fullMark: 100 },
  ];

  const missingSkills = [
    { name: "React System Design", priority: "High", timeframe: "2 weeks" },
    { name: "Advanced Prototyping", priority: "Medium", timeframe: "1 week" },
    { name: "User Testing Analysis", priority: "Medium", timeframe: "1 week" },
  ];

  const roadmap = [
    { 
      phase: "Phase 1: Foundations", 
      items: [
        { title: "React Hooks Deep Dive", type: "Course", duration: "4h" },
        { title: "Component Library Basics", type: "Project", duration: "10h" }
      ]
    },
    { 
      phase: "Phase 2: Advanced", 
      items: [
        { title: "State Management (Redux/Context)", type: "Course", duration: "6h" },
        { title: "Build a Design System", type: "Project", duration: "15h" }
      ]
    }
  ];

  return (
    <div className="space-y-6">
      <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
        <label className="block text-sm font-medium text-slate-700 mb-2">Target Role Analysis</label>
        <div className="flex gap-4">
          <input
            type="text"
            value={targetRole}
            onChange={(e) => setTargetRole(e.target.value)}
            className="flex-1 rounded-lg border-slate-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
          />
          <button className="bg-indigo-600 text-white px-6 py-2 rounded-lg font-medium hover:bg-indigo-700 transition-colors">
            Analyze
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Chart */}
        <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm"
        >
          <h3 className="text-lg font-bold text-slate-900 mb-6">Current vs Target Skills</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={skillsData} layout="vertical" margin={{ left: 40 }}>
                <CartesianGrid strokeDasharray="3 3" horizontal={true} vertical={false} />
                <XAxis type="number" domain={[0, 100]} hide />
                <YAxis dataKey="name" type="category" width={100} tick={{ fontSize: 12 }} />
                <Tooltip />
                <Bar dataKey="current" fill="#4f46e5" name="Your Level" radius={[0, 4, 4, 0]} barSize={20} />
                <Bar dataKey="target" fill="#e2e8f0" name="Target Level" radius={[0, 4, 4, 0]} barSize={20} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

        {/* Actionable Tabs */}
        <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm flex flex-col"
        >
          <div className="flex space-x-4 border-b border-slate-100 mb-4">
            <button
              onClick={() => setActiveTab('missing')}
              className={`pb-2 text-sm font-medium transition-colors ${activeTab === 'missing' ? 'text-indigo-600 border-b-2 border-indigo-600' : 'text-slate-500 hover:text-slate-700'}`}
            >
              Missing Skills
            </button>
            <button
              onClick={() => setActiveTab('roadmap')}
              className={`pb-2 text-sm font-medium transition-colors ${activeTab === 'roadmap' ? 'text-indigo-600 border-b-2 border-indigo-600' : 'text-slate-500 hover:text-slate-700'}`}
            >
              Learning Roadmap
            </button>
          </div>

          <div className="flex-1 overflow-y-auto pr-2">
            {activeTab === 'missing' ? (
              <div className="space-y-3">
                {missingSkills.map((skill, idx) => (
                  <div key={idx} className="flex items-center justify-between p-3 bg-slate-50 rounded-lg border border-slate-100">
                    <div>
                      <h4 className="font-semibold text-slate-900">{skill.name}</h4>
                      <span className={`text-xs px-2 py-0.5 rounded-full ${skill.priority === 'High' ? 'bg-red-100 text-red-600' : 'bg-yellow-100 text-yellow-600'}`}>
                        {skill.priority} Priority
                      </span>
                    </div>
                    <div className="text-right">
                        <span className="text-xs text-slate-500 block mb-1">Est. time</span>
                        <span className="text-sm font-medium text-slate-700">{skill.timeframe}</span>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="space-y-6">
                {roadmap.map((phase, idx) => (
                  <div key={idx} className="relative pl-4 border-l-2 border-indigo-100">
                    <div className="absolute -left-1.5 top-0 w-3 h-3 bg-indigo-600 rounded-full" />
                    <h4 className="text-sm font-bold text-indigo-900 mb-3">{phase.phase}</h4>
                    <div className="space-y-2">
                      {phase.items.map((item, i) => (
                        <div key={i} className="flex items-center justify-between bg-slate-50 p-2 rounded border border-slate-100">
                          <div className="flex items-center gap-2">
                            {item.type === 'Course' ? <BookOpen size={14} className="text-slate-400" /> : <Target size={14} className="text-slate-400" />}
                            <span className="text-sm text-slate-700">{item.title}</span>
                          </div>
                          <span className="text-xs text-slate-500">{item.duration}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
          
          <div className="mt-6 pt-4 border-t border-slate-100 text-center">
            <button className="text-indigo-600 text-sm font-medium hover:text-indigo-800 flex items-center justify-center gap-2">
              Generate Detailed Study Plan <ExternalLink size={14} />
            </button>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
