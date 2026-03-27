import { useEffect } from "react";
import { useNavigate } from "react-router";
import { motion } from "motion/react";
import { Briefcase } from "lucide-react";

export default function SplashScreen() {
  const navigate = useNavigate();

  useEffect(() => {
    const timer = setTimeout(() => {
      // Simulate auth check - redirect to dashboard if session exists, else login
      // For demo, we go to Login
      navigate("/auth/login");
    }, 2500);

    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div className="min-h-screen bg-indigo-600 flex flex-col items-center justify-center text-white overflow-hidden relative">
      <motion.div
        className="absolute inset-0 opacity-20"
        animate={{
          backgroundPosition: ["0% 0%", "100% 100%"],
        }}
        transition={{ duration: 20, repeat: Infinity, repeatType: "reverse" }}
        style={{
          backgroundImage: "radial-gradient(circle at center, white 1px, transparent 1px)",
          backgroundSize: "40px 40px",
        }}
      />
      
      <motion.div
        initial={{ scale: 0.5, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.8, type: "spring" }}
        className="relative z-10 flex flex-col items-center"
      >
        <div className="w-24 h-24 bg-white rounded-2xl flex items-center justify-center text-indigo-600 mb-6 shadow-2xl">
          <Briefcase size={48} strokeWidth={2.5} />
        </div>
        <motion.h1 
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.3 }}
          className="text-4xl font-bold tracking-tight mb-2"
        >
          CareerAI
        </motion.h1>
        <motion.p 
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="text-indigo-200 text-lg"
        >
          Your personal career co-pilot
        </motion.p>
      </motion.div>

      <motion.div 
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1, duration: 1 }}
        className="absolute bottom-10 left-0 right-0 flex justify-center"
      >
        <div className="w-12 h-1 bg-white/30 rounded-full overflow-hidden">
          <motion.div 
            className="h-full bg-white rounded-full"
            initial={{ width: "0%" }}
            animate={{ width: "100%" }}
            transition={{ duration: 2, ease: "easeInOut" }}
          />
        </div>
      </motion.div>
    </div>
  );
}
