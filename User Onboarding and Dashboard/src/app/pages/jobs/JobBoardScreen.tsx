import { useState } from "react";
import { Link } from "react-router";
import { motion } from "motion/react";
import {
  Plus,
  Search,
  Briefcase,
  MapPin,
  Calendar,
  ChevronRight,
  Building2,
  GripVertical,
} from "lucide-react";

interface Job {
  id: string;
  company: string;
  title: string;
  location: string;
  salary: string;
  date: string;
  status: string;
}

const initialJobs: Record<string, Job[]> = {
  Wishlist: [
    { id: "1", company: "Spotify", title: "Product Designer", location: "Remote", salary: "$120k-$150k", date: "Feb 20", status: "Wishlist" },
  ],
  Applied: [
    { id: "2", company: "Stripe", title: "Senior UX Designer", location: "San Francisco", salary: "$140k-$170k", date: "Feb 18", status: "Applied" },
    { id: "3", company: "Figma", title: "Design Engineer", location: "New York", salary: "$130k-$160k", date: "Feb 15", status: "Applied" },
  ],
  Interview: [
    { id: "4", company: "Notion", title: "Staff Designer", location: "Remote", salary: "$150k-$180k", date: "Feb 10", status: "Interview" },
  ],
  Offer: [
    { id: "5", company: "Linear", title: "Product Designer", location: "Remote", salary: "$135k-$165k", date: "Feb 5", status: "Offer" },
  ],
  Rejected: [
    { id: "6", company: "Meta", title: "UX Designer", location: "Menlo Park", salary: "$145k-$175k", date: "Jan 28", status: "Rejected" },
  ],
};

const columnColors: Record<string, string> = {
  Wishlist: "border-slate-300 bg-slate-50",
  Applied: "border-blue-300 bg-blue-50",
  Interview: "border-yellow-300 bg-yellow-50",
  Offer: "border-green-300 bg-green-50",
  Rejected: "border-red-300 bg-red-50",
};

const dotColors: Record<string, string> = {
  Wishlist: "bg-slate-400",
  Applied: "bg-blue-500",
  Interview: "bg-yellow-500",
  Offer: "bg-green-500",
  Rejected: "bg-red-500",
};

export default function JobBoardScreen() {
  const [jobs] = useState(initialJobs);
  const [searchQuery, setSearchQuery] = useState("");

  const filteredJobs = Object.entries(jobs).reduce((acc, [status, jobList]) => {
    acc[status] = jobList.filter(
      (j) =>
        j.company.toLowerCase().includes(searchQuery.toLowerCase()) ||
        j.title.toLowerCase().includes(searchQuery.toLowerCase())
    );
    return acc;
  }, {} as Record<string, Job[]>);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Job Tracker</h1>
          <p className="text-slate-500 text-sm">
            Track your applications through every stage.
          </p>
        </div>
        <Link
          to="/app/jobs/new"
          className="px-4 py-2.5 bg-indigo-600 text-white rounded-xl font-medium hover:bg-indigo-700 transition-colors flex items-center gap-2"
        >
          <Plus size={18} /> Add Job
        </Link>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
        <input
          type="text"
          placeholder="Search jobs by company or title..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
        />
      </div>

      {/* Kanban Board */}
      <div className="flex gap-4 overflow-x-auto pb-4 -mx-4 px-4 md:mx-0 md:px-0">
        {Object.entries(filteredJobs).map(([status, jobList]) => (
          <div key={status} className="min-w-[280px] flex-1">
            <div className={`rounded-t-xl border-t-4 ${columnColors[status]} p-3`}>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className={`w-2.5 h-2.5 rounded-full ${dotColors[status]}`} />
                  <span className="font-semibold text-slate-700 text-sm">{status}</span>
                </div>
                <span className="text-xs text-slate-400 bg-white px-2 py-0.5 rounded-full">
                  {jobList.length}
                </span>
              </div>
            </div>

            <div className="bg-slate-50/50 rounded-b-xl border border-t-0 border-slate-200 p-2 space-y-2 min-h-[200px]">
              {jobList.map((job, idx) => (
                <Link to={`/app/jobs/${job.id}`} key={job.id}>
                  <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: idx * 0.05 }}
                    className="bg-white p-3 rounded-lg border border-slate-100 shadow-sm hover:shadow-md hover:border-indigo-100 transition-all cursor-pointer group"
                  >
                    <div className="flex items-start justify-between mb-2">
                      <div className="flex items-center gap-2">
                        <div className="w-8 h-8 bg-slate-100 rounded-lg flex items-center justify-center">
                          <Building2 size={14} className="text-slate-500" />
                        </div>
                        <div>
                          <p className="font-semibold text-slate-900 text-sm">{job.company}</p>
                          <p className="text-xs text-slate-500">{job.title}</p>
                        </div>
                      </div>
                      <ChevronRight
                        size={14}
                        className="text-slate-300 group-hover:text-indigo-500 transition-colors"
                      />
                    </div>
                    <div className="flex items-center gap-3 text-xs text-slate-400">
                      <span className="flex items-center gap-1">
                        <MapPin size={10} /> {job.location}
                      </span>
                      <span className="flex items-center gap-1">
                        <Calendar size={10} /> {job.date}
                      </span>
                    </div>
                    <p className="text-xs text-indigo-600 font-medium mt-2">{job.salary}</p>
                  </motion.div>
                </Link>
              ))}

              {jobList.length === 0 && (
                <div className="text-center py-8 text-xs text-slate-400">
                  No jobs in this stage
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
