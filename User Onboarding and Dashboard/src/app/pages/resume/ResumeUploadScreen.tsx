import { useState, useCallback } from "react";
import { useNavigate } from "react-router";
import { motion } from "motion/react";
import { Upload, FileText, CheckCircle2, AlertCircle } from "lucide-react";
import { toast } from "sonner";

export default function ResumeUploadScreen() {
  const navigate = useNavigate();
  const [isDragging, setIsDragging] = useState(false);
  const [file, setFile] = useState<File | null>(null);

  const onDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  }, []);

  const onDragLeave = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
  }, []);

  const onDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      const droppedFile = e.dataTransfer.files[0];
      if (droppedFile.type === "application/pdf") {
        setFile(droppedFile);
        toast.success("File uploaded successfully");
      } else {
        toast.error("Please upload a PDF file");
      }
    }
  }, []);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
        const selectedFile = e.target.files[0];
        if (selectedFile.type === "application/pdf") {
            setFile(selectedFile);
        } else {
            toast.error("Please upload a PDF file");
        }
    }
  };

  const handleAnalyze = () => {
    if (!file) return;
    navigate("/app/resume/processing");
  };

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div className="text-center">
        <h1 className="text-3xl font-bold text-slate-900">Upload Your Resume</h1>
        <p className="mt-2 text-slate-600">
          We'll analyze your CV against millions of job descriptions to give you actionable feedback.
        </p>
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-white rounded-2xl shadow-sm border border-slate-200 p-8"
      >
        <div
          onDragOver={onDragOver}
          onDragLeave={onDragLeave}
          onDrop={onDrop}
          className={`
            border-2 border-dashed rounded-xl p-10 flex flex-col items-center justify-center transition-colors cursor-pointer
            ${isDragging ? "border-indigo-500 bg-indigo-50" : "border-slate-300 hover:bg-slate-50"}
            ${file ? "border-green-500 bg-green-50" : ""}
          `}
          onClick={() => document.getElementById('file-upload')?.click()}
        >
          <input
            id="file-upload"
            type="file"
            className="hidden"
            accept=".pdf"
            onChange={handleFileChange}
          />
          
          {file ? (
            <div className="text-center">
              <div className="w-16 h-16 bg-green-100 text-green-600 rounded-full flex items-center justify-center mx-auto mb-4">
                <CheckCircle2 size={32} />
              </div>
              <p className="font-semibold text-slate-900">{file.name}</p>
              <p className="text-sm text-slate-500">{(file.size / 1024 / 1024).toFixed(2)} MB</p>
              <button 
                onClick={(e) => { e.stopPropagation(); setFile(null); }}
                className="mt-4 text-sm text-red-500 hover:text-red-700 font-medium"
              >
                Remove file
              </button>
            </div>
          ) : (
            <div className="text-center">
              <div className="w-16 h-16 bg-indigo-100 text-indigo-600 rounded-full flex items-center justify-center mx-auto mb-4">
                <Upload size={32} />
              </div>
              <p className="font-semibold text-slate-900 mb-1">
                Click to upload or drag and drop
              </p>
              <p className="text-sm text-slate-500">
                PDF only (max. 10MB)
              </p>
            </div>
          )}
        </div>

        <div className="mt-6 flex justify-end">
          <button
            onClick={handleAnalyze}
            disabled={!file}
            className="px-6 py-2.5 bg-indigo-600 text-white rounded-lg font-medium hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            Analyze Resume
          </button>
        </div>
      </motion.div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-blue-50 p-4 rounded-lg border border-blue-100">
          <FileText className="text-blue-600 mb-2" size={24} />
          <h3 className="font-semibold text-blue-900 text-sm">ATS Check</h3>
          <p className="text-xs text-blue-700 mt-1">
            See how well your resume parses for applicant tracking systems.
          </p>
        </div>
        <div className="bg-purple-50 p-4 rounded-lg border border-purple-100">
          <CheckCircle2 className="text-purple-600 mb-2" size={24} />
          <h3 className="font-semibold text-purple-900 text-sm">Action Verbs</h3>
          <p className="text-xs text-purple-700 mt-1">
            We'll highlight weak verbs and suggest stronger alternatives.
          </p>
        </div>
        <div className="bg-orange-50 p-4 rounded-lg border border-orange-100">
          <AlertCircle className="text-orange-600 mb-2" size={24} />
          <h3 className="font-semibold text-orange-900 text-sm">Formatting</h3>
          <p className="text-xs text-orange-700 mt-1">
            Check specifically for layout issues that confuse bots.
          </p>
        </div>
      </div>
    </div>
  );
}
