import { useState } from "react";
import { useNavigate } from "react-router";
import { motion, AnimatePresence } from "motion/react";
import { Mic, MicOff, ChevronRight, Clock, User, Bot, Send } from "lucide-react";

const interviewQuestions = [
  "Tell me about a challenging project you worked on and how you handled it.",
  "How do you approach breaking down a complex problem into smaller parts?",
  "Describe a time when you had to collaborate with a difficult team member.",
  "What's your process for learning new technologies or skills?",
  "Where do you see yourself in 5 years, and how does this role fit into that plan?",
];

export default function MockInterviewExecutionScreen() {
  const navigate = useNavigate();
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [answers, setAnswers] = useState<string[]>(Array(interviewQuestions.length).fill(""));
  const [currentAnswer, setCurrentAnswer] = useState("");
  const [isMicOn, setIsMicOn] = useState(true);
  const [isThinking, setIsThinking] = useState(false);

  const handleSubmitAnswer = () => {
    const updatedAnswers = [...answers];
    updatedAnswers[currentQuestion] = currentAnswer;
    setAnswers(updatedAnswers);
    setCurrentAnswer("");

    if (currentQuestion < interviewQuestions.length - 1) {
      setIsThinking(true);
      setTimeout(() => {
        setIsThinking(false);
        setCurrentQuestion((prev) => prev + 1);
      }, 1200);
    } else {
      navigate("/app/interview/feedback");
    }
  };

  const progress = ((currentQuestion + 1) / interviewQuestions.length) * 100;

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Mock Interview</h1>
          <p className="text-slate-500 text-sm">Question {currentQuestion + 1} of {interviewQuestions.length}</p>
        </div>
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-1 text-sm text-slate-500">
            <Clock size={16} />
            <span>~{(interviewQuestions.length - currentQuestion) * 3} min left</span>
          </div>
          <button
            onClick={() => setIsMicOn(!isMicOn)}
            className={`p-2 rounded-lg transition-colors ${isMicOn ? "bg-green-100 text-green-600" : "bg-red-100 text-red-600"}`}
          >
            {isMicOn ? <Mic size={18} /> : <MicOff size={18} />}
          </button>
        </div>
      </div>

      {/* Progress Bar */}
      <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
        <motion.div
          className="h-full bg-indigo-600 rounded-full"
          animate={{ width: `${progress}%` }}
          transition={{ duration: 0.4 }}
        />
      </div>

      {/* Question Area */}
      <AnimatePresence mode="wait">
        <motion.div
          key={currentQuestion}
          initial={{ opacity: 0, x: 30 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: -30 }}
          transition={{ duration: 0.3 }}
          className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 space-y-6"
        >
          {/* AI Interviewer */}
          <div className="flex gap-4">
            <div className="w-10 h-10 rounded-full bg-indigo-100 flex items-center justify-center flex-shrink-0">
              <Bot size={20} className="text-indigo-600" />
            </div>
            <div className="bg-indigo-50 rounded-2xl rounded-tl-sm p-4 flex-1">
              <p className="text-slate-800">{interviewQuestions[currentQuestion]}</p>
            </div>
          </div>

          {/* Thinking indicator */}
          {isThinking && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="flex gap-4"
            >
              <div className="w-10 h-10 rounded-full bg-indigo-100 flex items-center justify-center flex-shrink-0">
                <Bot size={20} className="text-indigo-600" />
              </div>
              <div className="bg-indigo-50 rounded-2xl rounded-tl-sm p-4">
                <div className="flex gap-1">
                  <span className="w-2 h-2 bg-indigo-400 rounded-full animate-bounce" style={{ animationDelay: "0ms" }} />
                  <span className="w-2 h-2 bg-indigo-400 rounded-full animate-bounce" style={{ animationDelay: "150ms" }} />
                  <span className="w-2 h-2 bg-indigo-400 rounded-full animate-bounce" style={{ animationDelay: "300ms" }} />
                </div>
              </div>
            </motion.div>
          )}

          {/* Previous Answer */}
          {answers[currentQuestion] && (
            <div className="flex gap-4 justify-end">
              <div className="bg-slate-100 rounded-2xl rounded-tr-sm p-4 max-w-[80%]">
                <p className="text-slate-700 text-sm">{answers[currentQuestion]}</p>
              </div>
              <div className="w-10 h-10 rounded-full bg-slate-200 flex items-center justify-center flex-shrink-0">
                <User size={20} className="text-slate-600" />
              </div>
            </div>
          )}

          {/* Answer Input */}
          <div className="flex gap-3">
            <textarea
              value={currentAnswer}
              onChange={(e) => setCurrentAnswer(e.target.value)}
              placeholder="Type your answer here..."
              rows={3}
              className="flex-1 rounded-xl border border-slate-200 p-4 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 resize-none"
            />
          </div>

          <div className="flex justify-between items-center">
            <span className="text-xs text-slate-400">
              {currentQuestion === interviewQuestions.length - 1 ? "Last question!" : `${interviewQuestions.length - currentQuestion - 1} questions remaining`}
            </span>
            <button
              onClick={handleSubmitAnswer}
              disabled={!currentAnswer.trim()}
              className="px-6 py-2.5 bg-indigo-600 text-white rounded-xl font-medium hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center gap-2"
            >
              {currentQuestion === interviewQuestions.length - 1 ? (
                <>Finish Interview <Send size={16} /></>
              ) : (
                <>Next Question <ChevronRight size={16} /></>
              )}
            </button>
          </div>
        </motion.div>
      </AnimatePresence>

      {/* Question Navigation Dots */}
      <div className="flex justify-center gap-2">
        {interviewQuestions.map((_, i) => (
          <div
            key={i}
            className={`w-3 h-3 rounded-full transition-colors ${
              i === currentQuestion
                ? "bg-indigo-600"
                : i < currentQuestion
                ? "bg-indigo-300"
                : "bg-slate-200"
            }`}
          />
        ))}
      </div>
    </div>
  );
}
