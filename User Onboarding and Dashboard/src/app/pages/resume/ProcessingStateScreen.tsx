import { useEffect, useState } from "react";
import { useNavigate } from "react-router";
import { motion } from "motion/react";
import { Loader2, FileText, CheckCircle2, BrainCircuit } from "lucide-react";

export default function ProcessingStateScreen() {
  const navigate = useNavigate();
  const [step, setStep] = useState(0);

  const steps = [
    { label: "Extracting text...", icon: FileText },
    { label: "Parsing structure...", icon: Loader2 },
    { label: "AI Analysis in progress...", icon: BrainCircuit },
    { label: "Generating insights...", icon: CheckCircle2 },
  ];

  useEffect(() => {
    const timer = setInterval(() => {
      setStep((prev) => {
        if (prev >= steps.length - 1) {
          clearInterval(timer);
          setTimeout(() => navigate("/app/resume/analysis"), 1000);
          return prev;
        }
        return prev + 1;
      });
    }, 1500);

    return () => clearInterval(timer);
  }, [navigate]);

  return (
    <div className="min-h-[60vh] flex flex-col items-center justify-center p-8">
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        className="w-full max-w-md bg-white rounded-2xl shadow-xl border border-slate-100 p-8 relative overflow-hidden"
      >
        <div className="absolute top-0 left-0 w-full h-1 bg-slate-100">
          <motion.div 
            className="h-full bg-indigo-600"
            initial={{ width: "0%" }}
            animate={{ width: `${((step + 1) / steps.length) * 100}%` }}
            transition={{ duration: 0.5 }}
          />
        </div>

        <div className="flex flex-col items-center text-center space-y-6">
          <div className="relative">
            <div className="w-20 h-20 bg-indigo-50 rounded-full flex items-center justify-center text-indigo-600">
              <motion.div
                animate={{ rotate: step < 3 ? 360 : 0 }}
                transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
              >
                {step < 3 ? <Loader2 size={40} /> : <CheckCircle2 size={40} />}
              </motion.div>
            </div>
          </div>

          <div>
            <h2 className="text-2xl font-bold text-slate-900 mb-2">Analyzing Resume</h2>
            <p className="text-slate-500">Please wait while we process your document</p>
          </div>

          <div className="w-full space-y-3">
            {steps.map((s, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, x: -10 }}
                animate={{ 
                  opacity: i <= step ? 1 : 0.3, 
                  x: 0,
                  scale: i === step ? 1.02 : 1
                }}
                className={`
                  flex items-center gap-3 p-3 rounded-lg transition-colors
                  ${i === step ? 'bg-indigo-50 border border-indigo-100' : 'bg-transparent'}
                `}
              >
                <div className={`
                  w-6 h-6 rounded-full flex items-center justify-center text-xs
                  ${i < step ? 'bg-green-100 text-green-600' : i === step ? 'bg-indigo-100 text-indigo-600' : 'bg-slate-100 text-slate-400'}
                `}>
                  {i < step ? <CheckCircle2 size={14} /> : i + 1}
                </div>
                <span className={`text-sm font-medium ${i <= step ? 'text-slate-900' : 'text-slate-400'}`}>
                  {s.label}
                </span>
              </motion.div>
            ))}
          </div>
        </div>
      </motion.div>
    </div>
  );
}
