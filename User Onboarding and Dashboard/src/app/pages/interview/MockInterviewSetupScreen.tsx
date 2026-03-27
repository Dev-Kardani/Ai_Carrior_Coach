import { useState } from "react";
import { useNavigate } from "react-router";
import { motion } from "motion/react";
import { Video, Mic, Clock, ArrowRight, Briefcase } from "lucide-react";

const roles = [
  "Software Engineer",
  "Product Designer",
  "Data Scientist",
  "Product Manager",
  "Marketing Manager",
  "Sales Representative",
  "DevOps Engineer",
  "UX Researcher",
];

const difficulties = [
  { label: "Easy", desc: "Introductory behavioral questions", color: "bg-green-50 border-green-200 text-green-700" },
  { label: "Medium", desc: "Mix of technical & behavioral", color: "bg-yellow-50 border-yellow-200 text-yellow-700" },
  { label: "Hard", desc: "Advanced technical deep-dives", color: "bg-red-50 border-red-200 text-red-700" },
];

export default function MockInterviewSetupScreen() {
  const navigate = useNavigate();
  const [selectedRole, setSelectedRole] = useState("Software Engineer");
  const [selectedDifficulty, setSelectedDifficulty] = useState("Medium");
  const [questionCount, setQuestionCount] = useState(5);

  const handleStart = () => {
    navigate("/app/interview/active");
  };

  return (
    <div className="max-w-3xl mx-auto space-y-8">
      <div className="text-center">
        <h1 className="text-3xl font-bold text-slate-900">Mock Interview Setup</h1>
        <p className="mt-2 text-slate-500">Configure your practice session and let AI challenge you.</p>
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-white rounded-2xl shadow-sm border border-slate-200 p-8 space-y-8"
      >
        {/* Role Selection */}
        <div>
          <label className="block text-sm font-medium text-slate-700 mb-3">
            <Briefcase className="inline mr-2 h-4 w-4" />
            Select Target Role
          </label>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            {roles.map((role) => (
              <button
                key={role}
                onClick={() => setSelectedRole(role)}
                className={`p-3 rounded-lg border text-sm font-medium transition-all text-left
                  ${selectedRole === role
                    ? "bg-indigo-50 border-indigo-500 text-indigo-700 ring-1 ring-indigo-500"
                    : "bg-white border-slate-200 text-slate-700 hover:bg-slate-50"
                  }`}
              >
                {role}
              </button>
            ))}
          </div>
        </div>

        {/* Difficulty */}
        <div>
          <label className="block text-sm font-medium text-slate-700 mb-3">
            <Video className="inline mr-2 h-4 w-4" />
            Difficulty Level
          </label>
          <div className="grid grid-cols-3 gap-4">
            {difficulties.map((d) => (
              <button
                key={d.label}
                onClick={() => setSelectedDifficulty(d.label)}
                className={`p-4 rounded-xl border text-left transition-all
                  ${selectedDifficulty === d.label
                    ? `${d.color} ring-1 ring-current`
                    : "bg-white border-slate-200 text-slate-700 hover:bg-slate-50"
                  }`}
              >
                <span className="font-semibold block">{d.label}</span>
                <span className="text-xs mt-1 block opacity-70">{d.desc}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Questions Count */}
        <div>
          <label className="block text-sm font-medium text-slate-700 mb-3">
            <Clock className="inline mr-2 h-4 w-4" />
            Number of Questions: <span className="text-indigo-600">{questionCount}</span>
          </label>
          <input
            type="range"
            min={3}
            max={10}
            value={questionCount}
            onChange={(e) => setQuestionCount(Number(e.target.value))}
            className="w-full h-2 bg-slate-200 rounded-lg appearance-none cursor-pointer accent-indigo-600"
          />
          <div className="flex justify-between text-xs text-slate-400 mt-1">
            <span>3 questions</span>
            <span>10 questions</span>
          </div>
        </div>

        {/* Summary & Start */}
        <div className="bg-indigo-50 rounded-xl p-4 flex items-center justify-between">
          <div>
            <p className="text-sm text-indigo-900">
              <span className="font-semibold">{selectedRole}</span> · {selectedDifficulty} · {questionCount} questions
            </p>
            <p className="text-xs text-indigo-600 mt-1">Estimated time: ~{questionCount * 3} minutes</p>
          </div>
          <div className="flex items-center gap-2 text-xs text-indigo-500">
            <Mic size={14} /> Audio enabled
          </div>
        </div>

        <button
          onClick={handleStart}
          className="w-full py-3 bg-indigo-600 text-white rounded-xl font-medium hover:bg-indigo-700 transition-colors flex items-center justify-center gap-2"
        >
          Start Interview <ArrowRight size={18} />
        </button>
      </motion.div>
    </div>
  );
}
