import { useState } from "react";
import { useNavigate } from "react-router";
import { motion } from "motion/react";
import { Briefcase, MapPin, Target, Check } from "lucide-react";
import { toast } from "sonner";

export default function ProfileSetupScreen() {
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);
  const [formData, setFormData] = useState({
    role: "",
    experience: "entry",
    location: "",
    goals: [] as string[]
  });

  const goals = [
    "Find a new job",
    "Switch careers",
    "Improve resume",
    "Practice interviewing",
    "Networking"
  ];

  const toggleGoal = (goal: string) => {
    if (formData.goals.includes(goal)) {
      setFormData({...formData, goals: formData.goals.filter(g => g !== goal)});
    } else {
      setFormData({...formData, goals: [...formData.goals, goal]});
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    
    setTimeout(() => {
      setIsLoading(false);
      toast.success("Profile setup complete!");
      navigate("/app");
    }, 1500);
  };

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative overflow-hidden">
      <div className="absolute top-0 left-0 w-full h-96 bg-indigo-600 skew-y-3 transform -translate-y-24 z-0" />
      
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="sm:mx-auto sm:w-full sm:max-w-2xl relative z-10"
      >
        <div className="bg-white/90 backdrop-blur-lg shadow-xl sm:rounded-xl border border-white/50 overflow-hidden">
          <div className="px-4 py-5 sm:p-6">
            <div className="text-center mb-8">
              <h2 className="text-2xl font-bold text-slate-900">Let's set up your profile</h2>
              <p className="mt-1 text-sm text-slate-500">
                Help us personalize your career journey
              </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label htmlFor="role" className="block text-sm font-medium text-slate-700">
                    Target Role
                  </label>
                  <div className="mt-1 relative rounded-md shadow-sm">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <Target className="h-5 w-5 text-slate-400" />
                    </div>
                    <input
                      type="text"
                      id="role"
                      required
                      className="focus:ring-indigo-500 focus:border-indigo-500 block w-full pl-10 sm:text-sm border-slate-300 rounded-md py-2.5"
                      placeholder="e.g. Product Designer"
                      value={formData.role}
                      onChange={(e) => setFormData({...formData, role: e.target.value})}
                    />
                  </div>
                </div>

                <div>
                  <label htmlFor="location" className="block text-sm font-medium text-slate-700">
                    Preferred Location
                  </label>
                  <div className="mt-1 relative rounded-md shadow-sm">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <MapPin className="h-5 w-5 text-slate-400" />
                    </div>
                    <input
                      type="text"
                      id="location"
                      className="focus:ring-indigo-500 focus:border-indigo-500 block w-full pl-10 sm:text-sm border-slate-300 rounded-md py-2.5"
                      placeholder="e.g. Remote, New York"
                      value={formData.location}
                      onChange={(e) => setFormData({...formData, location: e.target.value})}
                    />
                  </div>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 mb-2">
                  Experience Level
                </label>
                <div className="grid grid-cols-3 gap-3">
                  {['entry', 'mid', 'senior'].map((level) => (
                    <button
                      key={level}
                      type="button"
                      onClick={() => setFormData({...formData, experience: level})}
                      className={`
                        py-3 px-4 rounded-lg border text-sm font-medium capitalize transition-all
                        ${formData.experience === level 
                          ? 'bg-indigo-50 border-indigo-500 text-indigo-700 ring-1 ring-indigo-500' 
                          : 'bg-white border-slate-200 text-slate-700 hover:bg-slate-50'}
                      `}
                    >
                      {level} Level
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 mb-2">
                  What are your goals? (Select all that apply)
                </label>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {goals.map((goal) => (
                    <button
                      key={goal}
                      type="button"
                      onClick={() => toggleGoal(goal)}
                      className={`
                        relative flex items-center py-3 px-4 rounded-lg border text-left text-sm font-medium transition-all
                        ${formData.goals.includes(goal) 
                          ? 'bg-indigo-50 border-indigo-500 text-indigo-700' 
                          : 'bg-white border-slate-200 text-slate-700 hover:bg-slate-50'}
                      `}
                    >
                      <span className="flex-1">{goal}</span>
                      {formData.goals.includes(goal) && (
                        <Check className="h-4 w-4 text-indigo-600" />
                      )}
                    </button>
                  ))}
                </div>
              </div>

              <div className="pt-4 border-t border-slate-100">
                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-base font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors disabled:opacity-70"
                >
                  {isLoading ? "Saving Profile..." : "Complete Setup"}
                </button>
              </div>
            </form>
          </div>
        </div>
      </motion.div>
    </div>
  );
}
