import { Link } from "react-router";
import { motion } from "motion/react";
import {
  MessageSquare,
  Plus,
  ChevronRight,
  Clock,
  Sparkles,
  Search,
} from "lucide-react";
import { useState } from "react";

const mockThreads = [
  {
    id: "1",
    title: "Resume improvement tips",
    lastMessage: "Here are 5 ways to improve your summary section...",
    date: "Today",
    messageCount: 12,
  },
  {
    id: "2",
    title: "Salary negotiation strategy",
    lastMessage: "Based on market data, you should ask for...",
    date: "Yesterday",
    messageCount: 8,
  },
  {
    id: "3",
    title: "Interview preparation for Stripe",
    lastMessage: "Stripe typically focuses on system design and...",
    date: "Feb 25",
    messageCount: 15,
  },
  {
    id: "4",
    title: "Career transition to Product Management",
    lastMessage: "Your UX background gives you a strong edge...",
    date: "Feb 22",
    messageCount: 6,
  },
  {
    id: "5",
    title: "Portfolio review feedback",
    lastMessage: "I'd recommend reorganizing your case studies...",
    date: "Feb 18",
    messageCount: 10,
  },
];

export default function AICareerChatScreen() {
  const [searchQuery, setSearchQuery] = useState("");

  const filteredThreads = mockThreads.filter(
    (t) =>
      t.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      t.lastMessage.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">AI Career Chat</h1>
          <p className="text-slate-500 text-sm">Get personalized career guidance anytime.</p>
        </div>
        <Link
          to="/app/chat/new"
          className="px-4 py-2.5 bg-indigo-600 text-white rounded-xl font-medium hover:bg-indigo-700 transition-colors flex items-center gap-2"
        >
          <Plus size={18} /> New Chat
        </Link>
      </div>

      {/* Quick Prompts */}
      <div className="bg-gradient-to-r from-indigo-50 to-purple-50 rounded-2xl border border-indigo-100 p-6">
        <div className="flex items-center gap-2 mb-4">
          <Sparkles size={18} className="text-indigo-600" />
          <h3 className="font-semibold text-slate-900">Quick Prompts</h3>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {[
            "Help me prepare for a technical interview",
            "Review my career path options",
            "How to negotiate a higher salary",
            "What skills should I learn next?",
          ].map((prompt) => (
            <Link
              to="/app/chat/new"
              key={prompt}
              className="bg-white p-3 rounded-lg border border-indigo-100 text-sm text-slate-700 hover:border-indigo-300 hover:shadow-sm transition-all flex items-center justify-between"
            >
              <span>{prompt}</span>
              <ChevronRight size={14} className="text-slate-400" />
            </Link>
          ))}
        </div>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
        <input
          type="text"
          placeholder="Search conversations..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
        />
      </div>

      {/* Thread List */}
      <div className="space-y-3">
        {filteredThreads.map((thread, idx) => (
          <Link to="/app/chat/new" key={thread.id}>
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: idx * 0.05 }}
              className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm hover:shadow-md hover:border-indigo-100 transition-all group cursor-pointer"
            >
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 bg-indigo-100 rounded-lg flex items-center justify-center flex-shrink-0">
                  <MessageSquare size={18} className="text-indigo-600" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <h4 className="font-semibold text-slate-900 text-sm truncate">{thread.title}</h4>
                    <span className="text-xs text-slate-400 flex-shrink-0 ml-2">{thread.date}</span>
                  </div>
                  <p className="text-sm text-slate-500 mt-1 truncate">{thread.lastMessage}</p>
                  <div className="flex items-center gap-3 mt-2 text-xs text-slate-400">
                    <span className="flex items-center gap-1">
                      <Clock size={10} /> {thread.messageCount} messages
                    </span>
                  </div>
                </div>
                <ChevronRight size={16} className="text-slate-300 group-hover:text-indigo-500 mt-3 flex-shrink-0 transition-colors" />
              </div>
            </motion.div>
          </Link>
        ))}
      </div>
    </div>
  );
}
