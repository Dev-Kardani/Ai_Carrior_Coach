import { useState, useRef, useEffect } from "react";
import { useNavigate } from "react-router";
import { motion } from "motion/react";
import { Send, Bot, User, ArrowLeft, Sparkles } from "lucide-react";

interface Message {
  id: string;
  role: "user" | "assistant";
  content: string;
}

const quickPrompts = [
  "What skills are in demand for Product Designers in 2026?",
  "Help me prepare for a behavioral interview",
  "How should I structure my portfolio?",
  "What's the best way to network on LinkedIn?",
];

const aiResponses: Record<string, string> = {
  default:
    "That's a great question! Based on current market trends, I'd recommend focusing on building a strong portfolio that showcases your problem-solving process, not just final designs. Would you like me to dive deeper into any specific area?",
  skills:
    "For 2026, the top skills for Product Designers include: 1) AI/ML integration design, 2) Design systems at scale, 3) Data-informed design decisions, 4) Accessibility expertise, and 5) Cross-platform design. Would you like a detailed learning roadmap for any of these?",
  interview:
    "For behavioral interviews, I recommend the STAR method (Situation, Task, Action, Result). Prepare 5-7 stories that cover: leadership, conflict resolution, failure/learning, collaboration, and innovation. Want me to run a practice session?",
  portfolio:
    "A strong portfolio should have: 1) 3-5 detailed case studies, 2) A clear narrative showing your process, 3) Measurable outcomes, 4) Your role clearly defined, and 5) A personal brand that stands out. Shall I review your current portfolio structure?",
  network:
    "LinkedIn networking tips: 1) Personalize every connection request, 2) Engage with content from target companies, 3) Share your own insights weekly, 4) Join relevant groups, and 5) Follow up after virtual events. Want me to draft a networking message template?",
};

function getAIResponse(input: string): string {
  const lower = input.toLowerCase();
  if (lower.includes("skill") || lower.includes("demand")) return aiResponses.skills;
  if (lower.includes("interview") || lower.includes("behavioral")) return aiResponses.interview;
  if (lower.includes("portfolio") || lower.includes("structure")) return aiResponses.portfolio;
  if (lower.includes("network") || lower.includes("linkedin")) return aiResponses.network;
  return aiResponses.default;
}

export default function NewChatScreen() {
  const navigate = useNavigate();
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [isTyping, setIsTyping] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: "smooth" });
  }, [messages, isTyping]);

  const sendMessage = (text: string) => {
    if (!text.trim()) return;

    const userMsg: Message = { id: Date.now().toString(), role: "user", content: text };
    setMessages((prev) => [...prev, userMsg]);
    setInput("");
    setIsTyping(true);

    setTimeout(() => {
      const aiMsg: Message = {
        id: (Date.now() + 1).toString(),
        role: "assistant",
        content: getAIResponse(text),
      };
      setMessages((prev) => [...prev, aiMsg]);
      setIsTyping(false);
    }, 1500);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    sendMessage(input);
  };

  return (
    <div className="flex flex-col h-[calc(100vh-120px)] max-w-3xl mx-auto">
      {/* Header */}
      <div className="flex items-center gap-3 pb-4 border-b border-slate-200">
        <button
          onClick={() => navigate("/app/chat")}
          className="p-2 text-slate-500 hover:text-slate-700 transition-colors"
        >
          <ArrowLeft size={18} />
        </button>
        <div className="w-8 h-8 bg-indigo-100 rounded-lg flex items-center justify-center">
          <Bot size={18} className="text-indigo-600" />
        </div>
        <div>
          <h2 className="font-semibold text-slate-900 text-sm">CareerAI Assistant</h2>
          <p className="text-xs text-green-500">Online</p>
        </div>
      </div>

      {/* Messages Area */}
      <div ref={scrollRef} className="flex-1 overflow-y-auto py-6 space-y-4">
        {messages.length === 0 && (
          <div className="flex flex-col items-center justify-center h-full text-center px-4">
            <div className="w-16 h-16 bg-indigo-100 rounded-2xl flex items-center justify-center mb-4">
              <Sparkles size={32} className="text-indigo-600" />
            </div>
            <h3 className="font-semibold text-slate-900 mb-2">Start a conversation</h3>
            <p className="text-sm text-slate-500 max-w-md mb-6">
              Ask me anything about your career, resume, interviews, or job search strategy.
            </p>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 w-full max-w-lg">
              {quickPrompts.map((prompt) => (
                <button
                  key={prompt}
                  onClick={() => sendMessage(prompt)}
                  className="p-3 bg-white border border-slate-200 rounded-xl text-sm text-slate-700 hover:border-indigo-300 hover:bg-indigo-50 transition-all text-left"
                >
                  {prompt}
                </button>
              ))}
            </div>
          </div>
        )}

        {messages.map((msg) => (
          <motion.div
            key={msg.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className={`flex gap-3 ${msg.role === "user" ? "justify-end" : "justify-start"}`}
          >
            {msg.role === "assistant" && (
              <div className="w-8 h-8 bg-indigo-100 rounded-full flex items-center justify-center flex-shrink-0">
                <Bot size={16} className="text-indigo-600" />
              </div>
            )}
            <div
              className={`max-w-[75%] p-4 rounded-2xl text-sm ${
                msg.role === "user"
                  ? "bg-indigo-600 text-white rounded-tr-sm"
                  : "bg-white border border-slate-200 text-slate-700 rounded-tl-sm"
              }`}
            >
              {msg.content}
            </div>
            {msg.role === "user" && (
              <div className="w-8 h-8 bg-slate-200 rounded-full flex items-center justify-center flex-shrink-0">
                <User size={16} className="text-slate-600" />
              </div>
            )}
          </motion.div>
        ))}

        {isTyping && (
          <div className="flex gap-3">
            <div className="w-8 h-8 bg-indigo-100 rounded-full flex items-center justify-center flex-shrink-0">
              <Bot size={16} className="text-indigo-600" />
            </div>
            <div className="bg-white border border-slate-200 rounded-2xl rounded-tl-sm p-4">
              <div className="flex gap-1">
                <span className="w-2 h-2 bg-slate-400 rounded-full animate-bounce" />
                <span className="w-2 h-2 bg-slate-400 rounded-full animate-bounce" style={{ animationDelay: "150ms" }} />
                <span className="w-2 h-2 bg-slate-400 rounded-full animate-bounce" style={{ animationDelay: "300ms" }} />
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Input Area */}
      <form onSubmit={handleSubmit} className="border-t border-slate-200 pt-4">
        <div className="flex gap-3">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Ask me anything about your career..."
            className="flex-1 px-4 py-3 bg-white border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
          />
          <button
            type="submit"
            disabled={!input.trim() || isTyping}
            className="px-4 py-3 bg-indigo-600 text-white rounded-xl hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            <Send size={18} />
          </button>
        </div>
      </form>
    </div>
  );
}
