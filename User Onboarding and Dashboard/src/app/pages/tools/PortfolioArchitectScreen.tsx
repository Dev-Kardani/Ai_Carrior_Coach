import { useState } from "react";
import { useNavigate } from "react-router";
import { motion } from "motion/react";
import {
  ArrowLeft,
  Palette,
  Plus,
  ExternalLink,
  Edit,
  Trash2,
  GripVertical,
  Sparkles,
  Image,
} from "lucide-react";
import { toast } from "sonner";

interface Project {
  id: string;
  title: string;
  description: string;
  role: string;
  tags: string[];
  impact: string;
}

const initialProjects: Project[] = [
  {
    id: "1",
    title: "Payment Flow Redesign",
    description: "Redesigned the checkout experience for a fintech platform, reducing cart abandonment by 25%.",
    role: "Lead Designer",
    tags: ["UX Design", "Fintech", "User Research"],
    impact: "25% reduction in cart abandonment",
  },
  {
    id: "2",
    title: "Design System v2.0",
    description: "Built a comprehensive design system with 200+ components used across 5 product teams.",
    role: "Design Systems Lead",
    tags: ["Design Systems", "Figma", "Documentation"],
    impact: "40% faster design-to-dev handoff",
  },
  {
    id: "3",
    title: "Mobile App Onboarding",
    description: "Created a personalized onboarding flow that improved user activation by 35%.",
    role: "Product Designer",
    tags: ["Mobile", "Onboarding", "A/B Testing"],
    impact: "35% increase in activation rate",
  },
];

export default function PortfolioArchitectScreen() {
  const navigate = useNavigate();
  const [projects, setProjects] = useState(initialProjects);
  const [showAddForm, setShowAddForm] = useState(false);
  const [newProject, setNewProject] = useState({
    title: "",
    description: "",
    role: "",
    tags: "",
    impact: "",
  });

  const handleAdd = () => {
    if (!newProject.title.trim()) {
      toast.error("Please add a project title");
      return;
    }
    const project: Project = {
      id: Date.now().toString(),
      title: newProject.title,
      description: newProject.description,
      role: newProject.role,
      tags: newProject.tags.split(",").map((t) => t.trim()).filter(Boolean),
      impact: newProject.impact,
    };
    setProjects([...projects, project]);
    setNewProject({ title: "", description: "", role: "", tags: "", impact: "" });
    setShowAddForm(false);
    toast.success("Project added!");
  };

  const handleDelete = (id: string) => {
    setProjects(projects.filter((p) => p.id !== id));
    toast.success("Project removed");
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <button
        onClick={() => navigate("/app/tools")}
        className="flex items-center gap-2 text-slate-500 hover:text-slate-700 text-sm font-medium transition-colors"
      >
        <ArrowLeft size={16} /> Back to Tools
      </button>

      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-purple-100 rounded-xl flex items-center justify-center">
            <Palette size={20} className="text-purple-600" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Portfolio Architect</h1>
            <p className="text-sm text-slate-500">Organize and showcase your best work.</p>
          </div>
        </div>
        <button
          onClick={() => setShowAddForm(!showAddForm)}
          className="px-4 py-2 bg-indigo-600 text-white rounded-xl font-medium hover:bg-indigo-700 transition-colors flex items-center gap-2"
        >
          <Plus size={16} /> Add Project
        </button>
      </div>

      {/* AI Suggestion Banner */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-gradient-to-r from-purple-50 to-indigo-50 rounded-xl border border-purple-100 p-4 flex items-start gap-3"
      >
        <Sparkles size={18} className="text-purple-600 mt-0.5 flex-shrink-0" />
        <div>
          <p className="text-sm font-medium text-purple-900">AI Recommendation</p>
          <p className="text-sm text-purple-700 mt-0.5">
            Based on your target role as Product Designer, we recommend showcasing 3-5 projects that highlight user research, design systems, and measurable impact.
          </p>
        </div>
      </motion.div>

      {/* Add Form */}
      {showAddForm && (
        <motion.div
          initial={{ opacity: 0, height: 0 }}
          animate={{ opacity: 1, height: "auto" }}
          className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 space-y-4"
        >
          <h3 className="font-semibold text-slate-900">New Project</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input
              type="text"
              placeholder="Project Title"
              value={newProject.title}
              onChange={(e) => setNewProject({ ...newProject, title: e.target.value })}
              className="px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 text-sm"
            />
            <input
              type="text"
              placeholder="Your Role"
              value={newProject.role}
              onChange={(e) => setNewProject({ ...newProject, role: e.target.value })}
              className="px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 text-sm"
            />
          </div>
          <textarea
            placeholder="Project Description"
            value={newProject.description}
            onChange={(e) => setNewProject({ ...newProject, description: e.target.value })}
            rows={3}
            className="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 text-sm resize-none"
          />
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input
              type="text"
              placeholder="Tags (comma-separated)"
              value={newProject.tags}
              onChange={(e) => setNewProject({ ...newProject, tags: e.target.value })}
              className="px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 text-sm"
            />
            <input
              type="text"
              placeholder="Key Impact (e.g., 25% increase)"
              value={newProject.impact}
              onChange={(e) => setNewProject({ ...newProject, impact: e.target.value })}
              className="px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 text-sm"
            />
          </div>
          <div className="flex gap-3 justify-end">
            <button
              onClick={() => setShowAddForm(false)}
              className="px-4 py-2 text-slate-600 bg-slate-100 rounded-lg text-sm hover:bg-slate-200 transition-colors"
            >
              Cancel
            </button>
            <button
              onClick={handleAdd}
              className="px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700 transition-colors"
            >
              Save Project
            </button>
          </div>
        </motion.div>
      )}

      {/* Project Cards */}
      <div className="space-y-4">
        {projects.map((project, idx) => (
          <motion.div
            key={project.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: idx * 0.05 }}
            className="bg-white rounded-xl border border-slate-200 shadow-sm p-6 hover:shadow-md transition-all"
          >
            <div className="flex items-start justify-between">
              <div className="flex items-start gap-4 flex-1">
                <div className="w-16 h-16 bg-slate-100 rounded-xl flex items-center justify-center flex-shrink-0">
                  <Image size={24} className="text-slate-400" />
                </div>
                <div className="flex-1">
                  <h3 className="font-semibold text-slate-900">{project.title}</h3>
                  <p className="text-sm text-slate-500 mt-1">{project.description}</p>
                  <div className="flex flex-wrap gap-2 mt-3">
                    {project.tags.map((tag) => (
                      <span
                        key={tag}
                        className="px-2 py-0.5 bg-indigo-50 text-indigo-600 rounded-full text-xs font-medium"
                      >
                        {tag}
                      </span>
                    ))}
                  </div>
                  <div className="flex items-center gap-4 mt-3 text-xs text-slate-400">
                    <span className="font-medium text-slate-600">{project.role}</span>
                    {project.impact && (
                      <span className="text-green-600 font-medium">{project.impact}</span>
                    )}
                  </div>
                </div>
              </div>
              <button
                onClick={() => handleDelete(project.id)}
                className="p-2 text-slate-400 hover:text-red-500 transition-colors"
              >
                <Trash2 size={16} />
              </button>
            </div>
          </motion.div>
        ))}
      </div>
    </div>
  );
}
